package com.alight.journal.smalltalk.model;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.time.YearMonth;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.stream.Collectors;

public class AmountPeriodJournal extends PeriodJournal {

    public AmountPeriodJournal() {
    }

    public AmountPeriodJournal(String name, List<PeriodJournalEntry> entries, ProrationPolicy prorationPolicy) {
        super(name, entries, prorationPolicy);
    }

    public Class<?> journalEntryClass() {
        return AmountPeriodJournalEntry.class;
    }

    @Override
    public boolean isAmountPeriodJournal() {
        return true;
    }

    // --- Amount-specific operations ---

    public AmountPeriodJournal accumulateOver(LocalDate anniversaryDate) {
        List<PeriodJournalEntry> sorted = getEntries().stream()
                .sorted(Comparator.comparing(PeriodJournalEntry::getStartDate))
                .collect(Collectors.toList());
        List<PeriodJournalEntry> result = new ArrayList<>();
        BigDecimal accumulator = BigDecimal.ZERO;
        int lastYear = -1;

        for (PeriodJournalEntry entry : sorted) {
            int annivYear = anniversaryYear(entry.getStartDate(), anniversaryDate);
            if (annivYear != lastYear) {
                accumulator = BigDecimal.ZERO;
                lastYear = annivYear;
            }
            accumulator = accumulator.add(entry.getAmount() != null ? entry.getAmount() : BigDecimal.ZERO);
            result.add(new PeriodJournalEntry(entry.getStartDate(), entry.getEndDate(), accumulator, null));
        }
        return new AmountPeriodJournal(getName(), result, getProrationPolicy());
    }

    public AmountPeriodJournal addAmountEntry(BigDecimal amount, LocalDate from, LocalDate to) {
        List<PeriodJournalEntry> newEntries = new ArrayList<>(copyEntrys());
        newEntries.add(new AmountPeriodJournalEntry(from, to, amount));
        AmountPeriodJournal result = new AmountPeriodJournal(getName(), newEntries, getProrationPolicy());
        if (result.hasOverlappingEntries()) {
            PeriodJournal resolved = result.resolveOverlapsWith("ADD");
            return new AmountPeriodJournal(getName(), resolved.getEntries(), getProrationPolicy());
        }
        return result;
    }

    public AmountPeriodJournal applyBaseRate(BigDecimal base, BigDecimal growth, int decimals) {
        List<PeriodJournalEntry> sorted = getEntries().stream()
                .sorted(Comparator.comparing(PeriodJournalEntry::getStartDate))
                .collect(Collectors.toList());
        List<PeriodJournalEntry> result = new ArrayList<>();
        BigDecimal currentRate = base;

        for (int i = 0; i < sorted.size(); i++) {
            PeriodJournalEntry entry = sorted.get(i);
            BigDecimal rounded = currentRate.setScale(decimals, RoundingMode.HALF_UP);
            result.add(new PeriodJournalEntry(entry.getStartDate(), entry.getEndDate(), rounded, null));
            currentRate = currentRate.multiply(growth);
        }
        return new AmountPeriodJournal(getName(), result, getProrationPolicy());
    }

    public AmountPeriodJournal applyForfeitMinimum(BigDecimal serviceMinimum, BigDecimal breakMinimum) {
        List<PeriodJournalEntry> sorted = getEntries().stream()
                .sorted(Comparator.comparing(PeriodJournalEntry::getStartDate))
                .collect(Collectors.toList());
        List<PeriodJournalEntry> result = new ArrayList<>();
        BigDecimal cumulative = BigDecimal.ZERO;

        for (int i = 0; i < sorted.size(); i++) {
            PeriodJournalEntry entry = sorted.get(i);
            cumulative = cumulative.add(entry.getAmount() != null ? entry.getAmount() : BigDecimal.ZERO);

            if (i < sorted.size() - 1) {
                LocalDate nextStart = sorted.get(i + 1).getStartDate();
                long gapDays = PeriodJournalEntry.inclusiveDays(entry.getEndDate().plusDays(1), nextStart.minusDays(1));
                if (gapDays > 0 && BigDecimal.valueOf(gapDays).compareTo(breakMinimum) >= 0
                        && cumulative.compareTo(serviceMinimum) < 0) {
                    cumulative = BigDecimal.ZERO;
                    continue;
                }
            }
            result.add(entry.copy());
        }
        return new AmountPeriodJournal(getName(), result, getProrationPolicy());
    }

    public AmountPeriodJournal asDaily() {
        List<PeriodJournalEntry> result = new ArrayList<>();
        for (PeriodJournalEntry entry : getEntries()) {
            long totalDays = entry.inclusiveDays();
            BigDecimal dailyAmount = entry.getAmount() != null
                    ? entry.getAmount().divide(BigDecimal.valueOf(totalDays), 13, RoundingMode.HALF_UP)
                    : BigDecimal.ZERO;
            LocalDate current = entry.getStartDate();
            while (!current.isAfter(entry.getEndDate())) {
                result.add(new PeriodJournalEntry(current, current, dailyAmount, null));
                current = current.plusDays(1);
            }
        }
        return new AmountPeriodJournal(getName(), result, getProrationPolicy());
    }

    public AmountPeriodJournal asPayCapJournal() {
        List<PeriodJournalEntry> monthly = asMonthly().getEntries().stream()
                .sorted(Comparator.comparing(PeriodJournalEntry::getStartDate))
                .collect(Collectors.toList());
        List<PeriodJournalEntry> result = new ArrayList<>();

        for (int i = 0; i < monthly.size(); i++) {
            BigDecimal windowSum = BigDecimal.ZERO;
            int windowStart = Math.max(0, i - 11);
            for (int j = windowStart; j <= i; j++) {
                BigDecimal amt = monthly.get(j).getAmount();
                if (amt != null)
                    windowSum = windowSum.add(amt);
            }
            PeriodJournalEntry entry = monthly.get(i);
            result.add(new PeriodJournalEntry(entry.getStartDate(), entry.getEndDate(), windowSum, null));
        }
        return new AmountPeriodJournal(getName(), result, getProrationPolicy());
    }

    public AmountPeriodJournal asPayCappedJournalWith(PeriodJournal capTable) {
        List<PeriodJournalEntry> result = new ArrayList<>();
        for (PeriodJournalEntry entry : getEntries()) {
            BigDecimal cap = capTable.valueOver(entry);
            BigDecimal amt = entry.getAmount() != null ? entry.getAmount() : BigDecimal.ZERO;
            BigDecimal capped = cap != null && amt.compareTo(cap) > 0 ? cap : amt;
            result.add(new PeriodJournalEntry(entry.getStartDate(), entry.getEndDate(), capped, null));
        }
        return new AmountPeriodJournal(getName(), result, getProrationPolicy());
    }

    public AmountPeriodJournal asPayCumCappedJournalWith(PeriodJournal capTable) {
        List<PeriodJournalEntry> sorted = getEntries().stream()
                .sorted(Comparator.comparing(PeriodJournalEntry::getStartDate))
                .collect(Collectors.toList());
        List<PeriodJournalEntry> result = new ArrayList<>();
        BigDecimal cumulative = BigDecimal.ZERO;
        int lastYear = -1;
        BigDecimal yearCap = BigDecimal.ZERO;

        for (PeriodJournalEntry entry : sorted) {
            int year = entry.getStartDate().getYear();
            if (year != lastYear) {
                cumulative = BigDecimal.ZERO;
                yearCap = capTable.valueOver(entry);
                if (yearCap == null)
                    yearCap = BigDecimal.ZERO;
                lastYear = year;
            }
            BigDecimal amt = entry.getAmount() != null ? entry.getAmount() : BigDecimal.ZERO;
            BigDecimal remaining = yearCap.subtract(cumulative);
            BigDecimal capped = amt.compareTo(remaining) > 0 ? remaining : amt;
            if (capped.compareTo(BigDecimal.ZERO) < 0)
                capped = BigDecimal.ZERO;
            cumulative = cumulative.add(capped);
            result.add(new PeriodJournalEntry(entry.getStartDate(), entry.getEndDate(), capped, null));
        }
        return new AmountPeriodJournal(getName(), result, getProrationPolicy());
    }

    public List<PeriodJournalEntry> capEntries(List<PeriodJournalEntry> entries, BigDecimal cap) {
        List<PeriodJournalEntry> result = new ArrayList<>(entries);
        BigDecimal remaining = cap;
        for (int i = result.size() - 1; i >= 0; i--) {
            BigDecimal amt = result.get(i).getAmount() != null ? result.get(i).getAmount() : BigDecimal.ZERO;
            if (remaining.compareTo(amt) < 0) {
                result.set(i, new PeriodJournalEntry(
                        result.get(i).getStartDate(), result.get(i).getEndDate(), remaining, null));
                remaining = BigDecimal.ZERO;
            } else {
                remaining = remaining.subtract(amt);
            }
        }
        return result;
    }

    public BigDecimal creditMonthly(int roundingRule) {
        long totalMonths = 0;
        for (PeriodJournalEntry entry : getEntries()) {
            totalMonths += entry.completeMonths();
        }
        return BigDecimal.valueOf(totalMonths);
    }

    public BigDecimal creditYearly(int roundingRule) {
        BigDecimal months = creditMonthly(roundingRule);
        return months.divide(BigDecimal.valueOf(12), 13, RoundingMode.HALF_UP);
    }

    public LocalDate findValueFromEnd(BigDecimal threshold) {
        List<PeriodJournalEntry> sorted = getEntries().stream()
                .sorted(Comparator.comparing(PeriodJournalEntry::getStartDate).reversed())
                .collect(Collectors.toList());
        BigDecimal cumulative = BigDecimal.ZERO;
        for (PeriodJournalEntry entry : sorted) {
            BigDecimal amt = entry.getAmount() != null ? entry.getAmount() : BigDecimal.ZERO;
            if (cumulative.add(amt).compareTo(threshold) >= 0) {
                BigDecimal needed = threshold.subtract(cumulative);
                if (entry instanceof AmountPeriodJournalEntry) {
                    return ((AmountPeriodJournalEntry) entry).findValueFromEnd(needed);
                }
                return entry.getStartDate();
            }
            cumulative = cumulative.add(amt);
        }
        return getEntries().isEmpty() ? null : getEntries().get(0).getStartDate();
    }

    public LocalDate findValueFromStart(BigDecimal threshold) {
        List<PeriodJournalEntry> sorted = getEntries().stream()
                .sorted(Comparator.comparing(PeriodJournalEntry::getStartDate))
                .collect(Collectors.toList());
        BigDecimal cumulative = BigDecimal.ZERO;
        for (PeriodJournalEntry entry : sorted) {
            BigDecimal amt = entry.getAmount() != null ? entry.getAmount() : BigDecimal.ZERO;
            if (cumulative.add(amt).compareTo(threshold) >= 0) {
                BigDecimal needed = threshold.subtract(cumulative);
                if (entry instanceof AmountPeriodJournalEntry) {
                    return ((AmountPeriodJournalEntry) entry).findValueFromStart(needed);
                }
                return entry.getEndDate();
            }
            cumulative = cumulative.add(amt);
        }
        return getEntries().isEmpty() ? null : getEntries().get(getEntries().size() - 1).getEndDate();
    }

    public AmountPeriodJournal highestConsecutiveGroupOfTwelveEntries(int n, PeriodJournal capTable) {
        AmountPeriodJournal monthly = new AmountPeriodJournal(getName(), asMonthly().getEntries(),
                getProrationPolicy());
        if (capTable != null) {
            monthly = monthly.asPayCappedJournalWith(capTable);
        }
        List<PeriodJournalEntry> entries = monthly.getEntries().stream()
                .sorted(Comparator.comparing(PeriodJournalEntry::getStartDate))
                .collect(Collectors.toList());

        if (entries.size() <= 12 * n) {
            return new AmountPeriodJournal(getName(), entries, getProrationPolicy());
        }

        List<PeriodJournalEntry> bestGroup = new ArrayList<>();
        BigDecimal bestSum = BigDecimal.ZERO;
        for (int i = 0; i <= entries.size() - 12; i++) {
            BigDecimal windowSum = BigDecimal.ZERO;
            for (int j = i; j < i + 12; j++) {
                BigDecimal amt = entries.get(j).getAmount();
                if (amt != null)
                    windowSum = windowSum.add(amt);
            }
            if (windowSum.compareTo(bestSum) > 0) {
                bestSum = windowSum;
                bestGroup = new ArrayList<>(entries.subList(i, i + 12));
            }
        }
        return new AmountPeriodJournal(getName(), bestGroup, getProrationPolicy());
    }

    public AmountPeriodJournal prorateRoundedTo(int decimals) {
        List<PeriodJournalEntry> result = new ArrayList<>();
        List<PeriodJournalEntry> sorted = getEntries().stream()
                .sorted(Comparator.comparing(PeriodJournalEntry::getStartDate))
                .collect(Collectors.toList());
        for (int i = 0; i < sorted.size(); i++) {
            PeriodJournalEntry entry = sorted.get(i);
            if (i == 0 || i == sorted.size() - 1) {
                BigDecimal prorated = entry.getAmount() != null
                        ? entry.getAmount().setScale(decimals, RoundingMode.HALF_UP)
                        : null;
                result.add(new PeriodJournalEntry(entry.getStartDate(), entry.getEndDate(), prorated, null));
            } else {
                result.add(entry.copy());
            }
        }
        return new AmountPeriodJournal(getName(), result, getProrationPolicy());
    }

    private int anniversaryYear(LocalDate date, LocalDate anniversary) {
        LocalDate annivInYear = anniversary.withYear(date.getYear());
        if (date.isBefore(annivInYear))
            return date.getYear() - 1;
        return date.getYear();
    }
}
