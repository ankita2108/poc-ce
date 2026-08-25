package com.alight.journal.smalltalk.model;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.function.BiPredicate;
import java.util.stream.Collectors;

public class PeriodJournal extends Journal {

    private String name;
    private ProrationPolicy prorationPolicy;

    public PeriodJournal() {
    }

    public PeriodJournal(String name, List<PeriodJournalEntry> entries, ProrationPolicy prorationPolicy) {
        super(entries != null ? entries.stream().map(PeriodJournalEntry::copy).collect(Collectors.toList())
                : new ArrayList<>());
        this.name = name;
        this.prorationPolicy = prorationPolicy;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    @Override
    public void setEntries(List<PeriodJournalEntry> entries) {
        super.setEntries(entries != null
                ? entries.stream().map(PeriodJournalEntry::copy).collect(Collectors.toList())
                : new ArrayList<>());
    }

    public ProrationPolicy getProrationPolicy() {
        return prorationPolicy;
    }

    public void setProrationPolicy(ProrationPolicy prorationPolicy) {
        this.prorationPolicy = prorationPolicy;
    }

    public PeriodJournal copyNamedWithoutStorage() {
        return new PeriodJournal(name, copyEntrys(), prorationPolicy);
    }

    public PeriodJournal prorationPolicy(ProrationPolicy policy) {
        setProrationPolicy(policy);
        return this;
    }

    public PeriodJournal copyWithEntrys(List<PeriodJournalEntry> updatedEntries) {
        return new PeriodJournal(name, updatedEntries, prorationPolicy);
    }

    public List<PeriodJournalEntry> copyEntrys() {
        List<PeriodJournalEntry> copiedEntries = new ArrayList<>();
        getEntries().forEach(entry -> copiedEntries.add(entry.copy()));
        return copiedEntries;
    }

    // --- Resolve (merge adjacent/overlapping same-period entries) ---

    public List<PeriodJournalEntry> resolve(List<PeriodJournalEntry> sourceEntries,
            BiPredicate<PeriodJournalEntry, PeriodJournalEntry> samePeriodBlock) {
        List<PeriodJournalEntry> sortedEntries = new ArrayList<>();
        sourceEntries.forEach(entry -> sortedEntries.add(entry.copy()));
        sortedEntries.sort(Comparator.comparing(PeriodJournalEntry::getStartDate)
                .thenComparing(PeriodJournalEntry::getEndDate));

        List<PeriodJournalEntry> resolvedEntries = new ArrayList<>();
        for (PeriodJournalEntry nextEntry : sortedEntries) {
            if (resolvedEntries.isEmpty()) {
                resolvedEntries.add(nextEntry);
                continue;
            }
            PeriodJournalEntry currentEntry = resolvedEntries.get(resolvedEntries.size() - 1);
            if (samePeriodBlock.test(currentEntry, nextEntry)) {
                resolvedEntries.set(resolvedEntries.size() - 1, currentEntry.mergeWith(nextEntry));
                continue;
            }
            resolvedEntries.add(nextEntry);
        }
        return resolvedEntries;
    }

    // --- Intersection ---

    public PeriodJournal intersect(PeriodJournal maskingJournal) {
        ProrationPolicy effectivePolicy = prorationPolicy != null
                ? prorationPolicy
                : maskingJournal.getProrationPolicy() != null ? maskingJournal.getProrationPolicy()
                        : HAProrationPolicyConstants.at("ACTUAL_DAYS");

        List<PeriodJournalEntry> intersectedEntries = new ArrayList<>();
        for (PeriodJournalEntry targetEntry : getEntries()) {
            for (PeriodJournalEntry maskEntry : maskingJournal.getEntries()) {
                PeriodJournalEntry intersectedEntry = targetEntry.intersectionWith(maskEntry, effectivePolicy);
                if (intersectedEntry != null) {
                    intersectedEntries.add(intersectedEntry);
                }
            }
        }
        return copyWithEntrys(intersectedEntries).prorationPolicy(effectivePolicy);
    }

    // --- Non-intersection (period subtraction) ---

    public PeriodJournal nonIntersect(PeriodJournal maskingJournal) {
        List<PeriodJournalEntry> result = new ArrayList<>();
        for (PeriodJournalEntry targetEntry : getEntries()) {
            List<PeriodJournalEntry> remaining = List.of(targetEntry.copy());
            for (PeriodJournalEntry maskEntry : maskingJournal.getEntries()) {
                List<PeriodJournalEntry> next = new ArrayList<>();
                for (PeriodJournalEntry r : remaining) {
                    next.addAll(r.nonIntersect(maskEntry));
                }
                remaining = next;
            }
            result.addAll(remaining);
        }
        return copyWithEntrys(result);
    }

    // --- Arithmetic ---

    @Override
    public PeriodJournal divideNumber(BigDecimal number) {
        List<PeriodJournalEntry> dividedEntries = new ArrayList<>();
        for (PeriodJournalEntry entry : getEntries()) {
            dividedEntries.add(entry.divideNumber(number));
        }
        return new PeriodJournal(name, dividedEntries, prorationPolicy);
    }

    public PeriodJournal multiplyByNumber(BigDecimal number) {
        List<PeriodJournalEntry> result = new ArrayList<>();
        for (PeriodJournalEntry entry : getEntries()) {
            result.add(entry.multiplyNumber(number));
        }
        return new PeriodJournal(name, result, prorationPolicy);
    }

    public PeriodJournal add(PeriodJournal other) {
        List<PeriodJournalEntry> combined = new ArrayList<>(copyEntrys());
        combined.addAll(other.copyEntrys());
        PeriodJournal result = copyWithEntrys(combined);
        if (result.hasOverlappingEntries()) {
            return result.resolveOverlapsWith("ADD");
        }
        return result;
    }

    public PeriodJournal subtract(PeriodJournal other) {
        PeriodJournal negated = other.negated();
        return add(negated);
    }

    @Override
    public PeriodJournal negated() {
        List<PeriodJournalEntry> result = getEntries().stream()
                .map(PeriodJournalEntry::negated)
                .collect(Collectors.toList());
        return new PeriodJournal(name, result, prorationPolicy);
    }

    public PeriodJournal alignedAddJrnl(PeriodJournal other) {
        return alignedBinaryOp(other, BigDecimal::add);
    }

    public PeriodJournal alignedSubJrnl(PeriodJournal other) {
        return alignedBinaryOp(other, BigDecimal::subtract);
    }

    public PeriodJournal alignedMultiplyJrnl(PeriodJournal other) {
        return alignedBinaryOp(other, BigDecimal::multiply);
    }

    public PeriodJournal alignedDivJrnl(PeriodJournal other) {
        return alignedBinaryOp(other, (a, b) -> a.divide(b, 13, RoundingMode.HALF_UP));
    }

    public PeriodJournal alignedMaxJrnl(PeriodJournal other) {
        return alignedBinaryOp(other, (a, b) -> a.compareTo(b) >= 0 ? a : b);
    }

    public PeriodJournal alignedMinJrnl(PeriodJournal other) {
        return alignedBinaryOp(other, (a, b) -> a.compareTo(b) <= 0 ? a : b);
    }

    private PeriodJournal alignedBinaryOp(PeriodJournal other,
            java.util.function.BiFunction<BigDecimal, BigDecimal, BigDecimal> op) {
        PeriodJournal intersected = this.intersect(other);
        List<PeriodJournalEntry> result = new ArrayList<>();
        for (PeriodJournalEntry entry : intersected.getEntries()) {
            BigDecimal thisVal = valueOver(entry);
            BigDecimal otherVal = other.valueOver(entry);
            BigDecimal computed = op.apply(
                    thisVal != null ? thisVal : BigDecimal.ZERO,
                    otherVal != null ? otherVal : BigDecimal.ZERO);
            result.add(new PeriodJournalEntry(entry.getStartDate(), entry.getEndDate(), computed, null));
        }
        return copyWithEntrys(result);
    }

    // --- Period transformations ---

    public PeriodJournal asMonthly() {
        List<PeriodJournalEntry> result = new ArrayList<>();
        for (PeriodJournalEntry entry : getEntries()) {
            result.addAll(entry.asCalendarMonths());
        }
        return resolveEntries(result);
    }

    public PeriodJournal asMonthly(LocalDate referenceDate) {
        return asMonthly();
    }

    public PeriodJournal asCalendarYears() {
        List<PeriodJournalEntry> result = new ArrayList<>();
        for (PeriodJournalEntry entry : getEntries()) {
            result.addAll(entry.asCalendarYears());
        }
        return resolveEntries(result);
    }

    public PeriodJournal asAnnual(LocalDate anniversaryDate) {
        List<PeriodJournalEntry> result = new ArrayList<>();
        for (PeriodJournalEntry entry : getEntries()) {
            result.addAll(entry.asAnniversaryYears(anniversaryDate));
        }
        return resolveEntries(result);
    }

    public PeriodJournal asFullAnnual(LocalDate anniversaryDate) {
        return asAnnual(anniversaryDate);
    }

    public PeriodJournal asQuarter(LocalDate quarterStart) {
        List<PeriodJournalEntry> result = new ArrayList<>();
        for (PeriodJournalEntry entry : getEntries()) {
            result.addAll(entry.asQuarters(quarterStart));
        }
        return resolveEntries(result);
    }

    public PeriodJournal asSemiMonthlyOn(int dayOfMonth) {
        List<PeriodJournalEntry> result = new ArrayList<>();
        for (PeriodJournalEntry entry : getEntries()) {
            result.addAll(entry.asSemiMonths(dayOfMonth));
        }
        return resolveEntries(result);
    }

    public PeriodJournal asBiWeeklyFor(LocalDate referenceDate) {
        List<PeriodJournalEntry> result = new ArrayList<>();
        for (PeriodJournalEntry entry : getEntries()) {
            result.addAll(entry.asBiWeekly(referenceDate));
        }
        return resolveEntries(result);
    }

    // --- Contiguity ---

    public boolean isContiguous() {
        List<PeriodJournalEntry> sorted = getSortedEntries();
        for (int i = 0; i < sorted.size() - 1; i++) {
            if (!sorted.get(i).isContiguousWith(sorted.get(i + 1))) {
                return false;
            }
        }
        return true;
    }

    public boolean isFragmented() {
        return !isContiguous();
    }

    public List<PeriodJournal> contiguousPeriods() {
        List<PeriodJournal> result = new ArrayList<>();
        List<PeriodJournalEntry> sorted = getSortedEntries();
        List<PeriodJournalEntry> current = new ArrayList<>();
        for (PeriodJournalEntry entry : sorted) {
            if (current.isEmpty()) {
                current.add(entry);
            } else if (current.get(current.size() - 1).isContiguousWith(entry)) {
                current.add(entry);
            } else {
                result.add(copyWithEntrys(current));
                current = new ArrayList<>();
                current.add(entry);
            }
        }
        if (!current.isEmpty())
            result.add(copyWithEntrys(current));
        return result;
    }

    public List<PeriodJournalEntry> fragmentedEntries() {
        List<PeriodJournalEntry> result = new ArrayList<>();
        List<PeriodJournalEntry> sorted = getSortedEntries();
        for (int i = 0; i < sorted.size() - 1; i++) {
            if (!sorted.get(i).isContiguousWith(sorted.get(i + 1))) {
                result.add(sorted.get(i));
            }
        }
        return result;
    }

    public List<PeriodJournalEntry> missingPeriodEntries() {
        List<PeriodJournalEntry> result = new ArrayList<>();
        List<PeriodJournalEntry> sorted = getSortedEntries();
        for (int i = 0; i < sorted.size() - 1; i++) {
            LocalDate gapStart = sorted.get(i).getEndDate().plusDays(1);
            LocalDate gapEnd = sorted.get(i + 1).getStartDate().minusDays(1);
            if (!gapStart.isAfter(gapEnd)) {
                result.add(new PeriodJournalEntry(gapStart, gapEnd, BigDecimal.ZERO, null));
            }
        }
        return result;
    }

    // --- Overlap resolution ---

    public boolean hasOverlappingEntries() {
        List<PeriodJournalEntry> sorted = getSortedEntries();
        for (int i = 0; i < sorted.size() - 1; i++) {
            if (sorted.get(i).isIntersecting(sorted.get(i + 1))) {
                return true;
            }
        }
        return false;
    }

    public PeriodJournal resolveOverlaps() {
        return resolveOverlapsWith("ADD");
    }

    public PeriodJournal resolveOverlapsWith(String policy) {
        if (!hasOverlappingEntries())
            return copyWithEntrys(copyEntrys());
        List<LocalDate> atomicDates = resolvedOverlapPeriods();
        List<PeriodJournalEntry> atomicEntries = buildAtomicEntries(atomicDates);

        switch (policy.toUpperCase()) {
            case "ADD":
                return addOfOverlappingEntries(atomicEntries);
            case "MERGE":
                return mergeOfOverlappingEntries(atomicEntries);
            case "HIGHEST":
                return highestOfOverlappingEntries(atomicEntries);
            case "LOWEST":
                return lowestOfOverlappingEntries(atomicEntries);
            case "FIRST":
                return firstOfOverlappingEntries(atomicEntries);
            case "LAST":
                return lastOfOverlappingEntries(atomicEntries);
            case "COMBINE_EDIT":
                return mergeOfOverlappingEntries(atomicEntries);
            case "SINGLE_ENTRY":
                return firstOfOverlappingEntries(atomicEntries);
            default:
                return addOfOverlappingEntries(atomicEntries);
        }
    }

    public List<LocalDate> resolvedOverlapPeriods() {
        List<LocalDate> dates = new ArrayList<>();
        for (PeriodJournalEntry entry : getEntries()) {
            dates.add(entry.getStartDate());
            dates.add(entry.getEndDate().plusDays(1));
        }
        dates.sort(LocalDate::compareTo);
        return dates.stream().distinct().collect(Collectors.toList());
    }

    private List<PeriodJournalEntry> buildAtomicEntries(List<LocalDate> atomicDates) {
        List<PeriodJournalEntry> result = new ArrayList<>();
        for (int i = 0; i < atomicDates.size() - 1; i++) {
            LocalDate start = atomicDates.get(i);
            LocalDate end = atomicDates.get(i + 1).minusDays(1);
            if (!start.isAfter(end)) {
                result.add(new PeriodJournalEntry(start, end, BigDecimal.ZERO, null));
            }
        }
        return result;
    }

    private PeriodJournal addOfOverlappingEntries(List<PeriodJournalEntry> atomicEntries) {
        List<PeriodJournalEntry> result = new ArrayList<>();
        for (PeriodJournalEntry atomic : atomicEntries) {
            BigDecimal sum = BigDecimal.ZERO;
            for (PeriodJournalEntry entry : getEntries()) {
                if (entry.isIntersecting(atomic)) {
                    BigDecimal val = entry.valueOver(atomic);
                    if (val != null)
                        sum = sum.add(val);
                }
            }
            result.add(new PeriodJournalEntry(atomic.getStartDate(), atomic.getEndDate(), sum, null));
        }
        return copyWithEntrys(result);
    }

    private PeriodJournal highestOfOverlappingEntries(List<PeriodJournalEntry> atomicEntries) {
        List<PeriodJournalEntry> result = new ArrayList<>();
        for (PeriodJournalEntry atomic : atomicEntries) {
            BigDecimal highest = null;
            for (PeriodJournalEntry entry : getEntries()) {
                if (entry.isIntersecting(atomic)) {
                    BigDecimal val = entry.valueOver(atomic);
                    if (val != null && (highest == null || val.compareTo(highest) > 0)) {
                        highest = val;
                    }
                }
            }
            result.add(new PeriodJournalEntry(atomic.getStartDate(), atomic.getEndDate(),
                    highest != null ? highest : BigDecimal.ZERO, null));
        }
        return copyWithEntrys(result);
    }

    private PeriodJournal lowestOfOverlappingEntries(List<PeriodJournalEntry> atomicEntries) {
        List<PeriodJournalEntry> result = new ArrayList<>();
        for (PeriodJournalEntry atomic : atomicEntries) {
            BigDecimal lowest = null;
            for (PeriodJournalEntry entry : getEntries()) {
                if (entry.isIntersecting(atomic)) {
                    BigDecimal val = entry.valueOver(atomic);
                    if (val != null && (lowest == null || val.compareTo(lowest) < 0)) {
                        lowest = val;
                    }
                }
            }
            result.add(new PeriodJournalEntry(atomic.getStartDate(), atomic.getEndDate(),
                    lowest != null ? lowest : BigDecimal.ZERO, null));
        }
        return copyWithEntrys(result);
    }

    private PeriodJournal firstOfOverlappingEntries(List<PeriodJournalEntry> atomicEntries) {
        List<PeriodJournalEntry> result = new ArrayList<>();
        for (PeriodJournalEntry atomic : atomicEntries) {
            BigDecimal first = BigDecimal.ZERO;
            for (PeriodJournalEntry entry : getEntries()) {
                if (entry.isIntersecting(atomic)) {
                    first = entry.valueOver(atomic);
                    break;
                }
            }
            result.add(new PeriodJournalEntry(atomic.getStartDate(), atomic.getEndDate(), first, null));
        }
        return copyWithEntrys(result);
    }

    private PeriodJournal lastOfOverlappingEntries(List<PeriodJournalEntry> atomicEntries) {
        List<PeriodJournalEntry> result = new ArrayList<>();
        for (PeriodJournalEntry atomic : atomicEntries) {
            BigDecimal last = BigDecimal.ZERO;
            for (PeriodJournalEntry entry : getEntries()) {
                if (entry.isIntersecting(atomic)) {
                    last = entry.valueOver(atomic);
                }
            }
            result.add(new PeriodJournalEntry(atomic.getStartDate(), atomic.getEndDate(), last, null));
        }
        return copyWithEntrys(result);
    }

    private PeriodJournal mergeOfOverlappingEntries(List<PeriodJournalEntry> atomicEntries) {
        // Merge deduplicates values, then sums unique values
        List<PeriodJournalEntry> result = new ArrayList<>();
        for (PeriodJournalEntry atomic : atomicEntries) {
            List<BigDecimal> uniqueValues = new ArrayList<>();
            for (PeriodJournalEntry entry : getEntries()) {
                if (entry.isIntersecting(atomic)) {
                    BigDecimal val = entry.valueOver(atomic);
                    if (val != null && uniqueValues.stream().noneMatch(v -> v.compareTo(val) == 0)) {
                        uniqueValues.add(val);
                    }
                }
            }
            BigDecimal sum = uniqueValues.stream().reduce(BigDecimal.ZERO, BigDecimal::add);
            result.add(new PeriodJournalEntry(atomic.getStartDate(), atomic.getEndDate(), sum, null));
        }
        return copyWithEntrys(result);
    }

    // --- Value querying ---

    public BigDecimal valueOver(PeriodJournalEntry period) {
        BigDecimal total = BigDecimal.ZERO;
        for (PeriodJournalEntry entry : getEntries()) {
            if (entry.isIntersecting(period)) {
                BigDecimal val = entry.valueOver(period);
                if (val != null)
                    total = total.add(val);
            }
        }
        return total;
    }

    public BigDecimal valueOverAll(PeriodJournal other) {
        BigDecimal total = BigDecimal.ZERO;
        for (PeriodJournalEntry entry : other.getEntries()) {
            total = total.add(valueOver(entry));
        }
        return total;
    }

    public BigDecimal valueBefore(LocalDate date) {
        BigDecimal total = BigDecimal.ZERO;
        PeriodJournalEntry queryPeriod = new PeriodJournalEntry(
                LocalDate.of(1800, 1, 1), date.minusDays(1), null, null);
        for (PeriodJournalEntry entry : getEntries()) {
            if (entry.isIntersecting(queryPeriod)) {
                BigDecimal val = entry.valueOver(queryPeriod);
                if (val != null)
                    total = total.add(val);
            }
        }
        return total;
    }

    public BigDecimal valueAfter(LocalDate date) {
        BigDecimal total = BigDecimal.ZERO;
        PeriodJournalEntry queryPeriod = new PeriodJournalEntry(
                date.plusDays(1), LocalDate.of(2299, 12, 31), null, null);
        for (PeriodJournalEntry entry : getEntries()) {
            if (entry.isIntersecting(queryPeriod)) {
                BigDecimal val = entry.valueOver(queryPeriod);
                if (val != null)
                    total = total.add(val);
            }
        }
        return total;
    }

    public BigDecimal completePeriodValueBefore(LocalDate date) {
        BigDecimal total = BigDecimal.ZERO;
        for (PeriodJournalEntry entry : getEntries()) {
            if (entry.getEndDate().isBefore(date)) {
                if (entry.getAmount() != null)
                    total = total.add(entry.getAmount());
            }
        }
        return total;
    }

    public BigDecimal completePeriodValueAfter(LocalDate date) {
        BigDecimal total = BigDecimal.ZERO;
        for (PeriodJournalEntry entry : getEntries()) {
            if (entry.getStartDate().isAfter(date)) {
                if (entry.getAmount() != null)
                    total = total.add(entry.getAmount());
            }
        }
        return total;
    }

    // --- Date querying ---

    public LocalDate fromDateAfter(LocalDate date) {
        return getSortedEntries().stream()
                .map(PeriodJournalEntry::getStartDate)
                .filter(d -> d.isAfter(date))
                .findFirst().orElse(null);
    }

    public LocalDate toDateBefore(LocalDate date) {
        List<PeriodJournalEntry> sorted = getSortedEntries();
        LocalDate result = null;
        for (PeriodJournalEntry entry : sorted) {
            if (entry.getEndDate().isBefore(date))
                result = entry.getEndDate();
        }
        return result;
    }

    public LocalDate throughDateAfter(LocalDate date) {
        return getSortedEntries().stream()
                .map(PeriodJournalEntry::getEndDate)
                .filter(d -> d.isAfter(date))
                .findFirst().orElse(null);
    }

    public LocalDate completePeriodFromDateAfter(LocalDate date, LocalDate defaultDate) {
        LocalDate result = fromDateAfter(date);
        return result != null ? result : defaultDate;
    }

    // --- Periods between/not between ---

    public PeriodJournal periodsBetween(LocalDate from, LocalDate to) {
        PeriodJournalEntry mask = new PeriodJournalEntry(from, to, null, null);
        PeriodJournal maskJournal = new PeriodJournal(null, List.of(mask), null);
        return intersect(maskJournal);
    }

    public PeriodJournal periodsNotBetween(LocalDate from, LocalDate to) {
        PeriodJournalEntry mask = new PeriodJournalEntry(from, to, null, null);
        PeriodJournal maskJournal = new PeriodJournal(null, List.of(mask), null);
        return nonIntersect(maskJournal);
    }

    // --- Grouping/aggregation ---

    public PeriodJournal aggregateFromStartForEntries(int n) {
        List<PeriodJournalEntry> sorted = getSortedEntries();
        List<PeriodJournalEntry> result = new ArrayList<>();
        for (int i = 0; i < sorted.size(); i += n) {
            int end = Math.min(i + n, sorted.size());
            List<PeriodJournalEntry> group = sorted.subList(i, end);
            PeriodJournalEntry combined = aggregateGroup(group);
            result.add(combined);
        }
        return copyWithEntrys(result);
    }

    public PeriodJournal aggregateFromEndForEntries(int n) {
        List<PeriodJournalEntry> sorted = getSortedEntries();
        List<PeriodJournalEntry> result = new ArrayList<>();
        int start = sorted.size() % n;
        if (start > 0) {
            result.add(aggregateGroup(sorted.subList(0, start)));
        }
        for (int i = start; i < sorted.size(); i += n) {
            int end = Math.min(i + n, sorted.size());
            result.add(aggregateGroup(sorted.subList(i, end)));
        }
        return copyWithEntrys(result);
    }

    // --- Date journal ---

    public Map<LocalDate, BigDecimal> asDateJournal() {
        Map<LocalDate, BigDecimal> result = new LinkedHashMap<>();
        for (PeriodJournalEntry entry : getSortedEntries()) {
            result.put(entry.getStartDate(), entry.getAmount());
        }
        return result;
    }

    // --- Utility ---

    public boolean needsProrationPolicy() {
        return prorationPolicy == null;
    }

    public void setProrationPolicyIn(CalculationContext context) {
        if (prorationPolicy == null && context != null) {
            prorationPolicy = context.journalProrationPolicy();
        }
    }

    public LocalDate earliestDate() {
        return getEntries().stream().map(PeriodJournalEntry::getStartDate).min(LocalDate::compareTo).orElse(null);
    }

    public LocalDate latestDate() {
        return getEntries().stream().map(PeriodJournalEntry::getEndDate).max(LocalDate::compareTo).orElse(null);
    }

    public boolean isCodePeriodJournal() {
        return getEntries().stream().allMatch(e -> e.getAmount() == null && e.getValue() != null);
    }

    public boolean isAmountPeriodJournal() {
        return getEntries().stream().anyMatch(e -> e.getAmount() != null);
    }

    public boolean isRatePeriodJournal() {
        return getEntries().stream().anyMatch(e -> e instanceof RatePeriodJournalEntry);
    }

    // --- Helpers ---

    private List<PeriodJournalEntry> getSortedEntries() {
        List<PeriodJournalEntry> sorted = new ArrayList<>(getEntries());
        sorted.sort(Comparator.comparing(PeriodJournalEntry::getStartDate)
                .thenComparing(PeriodJournalEntry::getEndDate));
        return sorted;
    }

    private PeriodJournal resolveEntries(List<PeriodJournalEntry> entries) {
        List<PeriodJournalEntry> resolved = resolve(entries,
                (a, b) -> a.getStartDate().equals(b.getStartDate()) && a.getEndDate().equals(b.getEndDate()));
        return copyWithEntrys(resolved);
    }

    private PeriodJournalEntry aggregateGroup(List<PeriodJournalEntry> group) {
        LocalDate start = group.get(0).getStartDate();
        LocalDate end = group.get(group.size() - 1).getEndDate();
        BigDecimal total = BigDecimal.ZERO;
        for (PeriodJournalEntry e : group) {
            if (e.getAmount() != null)
                total = total.add(e.getAmount());
        }
        return new PeriodJournalEntry(start, end, total, null);
    }
}
