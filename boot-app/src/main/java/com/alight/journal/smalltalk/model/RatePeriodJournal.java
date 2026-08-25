package com.alight.journal.smalltalk.model;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.stream.Collectors;

public class RatePeriodJournal extends PeriodJournal {

    public enum RateFrequency {
        ANNUAL, MONTHLY, HOURLY
    }

    private RateFrequency rateFrequency = RateFrequency.ANNUAL;

    public RatePeriodJournal() {
    }

    public RatePeriodJournal(String name, List<PeriodJournalEntry> entries, ProrationPolicy prorationPolicy) {
        super(name, entries, prorationPolicy);
    }

    public RatePeriodJournal(String name, List<PeriodJournalEntry> entries,
            ProrationPolicy prorationPolicy, RateFrequency frequency) {
        super(name, entries, prorationPolicy);
        this.rateFrequency = frequency;
    }

    public RateFrequency getRateFrequency() {
        return rateFrequency;
    }

    public void setRateFrequency(RateFrequency rateFrequency) {
        this.rateFrequency = rateFrequency;
    }

    @Override
    public boolean isRatePeriodJournal() {
        return true;
    }

    public Class<?> journalEntryClass() {
        switch (rateFrequency) {
            case MONTHLY:
                return MonthlyRatePeriodJournalEntry.class;
            case HOURLY:
                return HourlyRatePeriodJournalEntry.class;
            default:
                return AnnualRatePeriodJournalEntry.class;
        }
    }

    // --- Factory methods ---

    public static RatePeriodJournal annualRate(String name, List<PeriodJournalEntry> entries) {
        return new RatePeriodJournal(name, entries, null, RateFrequency.ANNUAL);
    }

    public static RatePeriodJournal monthlyRate(String name, List<PeriodJournalEntry> entries) {
        return new RatePeriodJournal(name, entries, null, RateFrequency.MONTHLY);
    }

    public static RatePeriodJournal hourlyRate(String name, List<PeriodJournalEntry> entries) {
        return new RatePeriodJournal(name, entries, null, RateFrequency.HOURLY);
    }

    // --- Rate-specific operations ---

    public AmountPeriodJournal asAmount() {
        List<PeriodJournalEntry> result = new ArrayList<>();
        BigDecimal factor = rateFactor();
        for (PeriodJournalEntry entry : getEntries()) {
            BigDecimal rateValue = entry.getAmount();
            if (rateValue == null) {
                result.add(new PeriodJournalEntry(entry.getStartDate(), entry.getEndDate(), BigDecimal.ZERO, null));
                continue;
            }
            double years = entry.years();
            BigDecimal amount = rateValue.multiply(BigDecimal.valueOf(years))
                    .multiply(factor)
                    .setScale(13, RoundingMode.HALF_UP);
            result.add(new PeriodJournalEntry(entry.getStartDate(), entry.getEndDate(), amount, null));
        }
        return new AmountPeriodJournal(getName(), result, getProrationPolicy());
    }

    public PeriodJournal asFullMonthlyUsing(String policy) {
        PeriodJournal monthly = asMonthly();
        if ("BEGINNING".equalsIgnoreCase(policy)) {
            return resolveMonthlyBeginning(monthly);
        } else if ("ENDING".equalsIgnoreCase(policy)) {
            return resolveMonthlyEnding(monthly);
        }
        return monthly;
    }

    public boolean hasConflictingOverlaps() {
        List<PeriodJournalEntry> sorted = getEntries().stream()
                .sorted(Comparator.comparing(PeriodJournalEntry::getStartDate))
                .collect(Collectors.toList());
        for (int i = 0; i < sorted.size() - 1; i++) {
            PeriodJournalEntry current = sorted.get(i);
            PeriodJournalEntry next = sorted.get(i + 1);
            if (current.isIntersecting(next)) {
                BigDecimal v1 = current.getAmount() != null ? current.getAmount() : BigDecimal.ZERO;
                BigDecimal v2 = next.getAmount() != null ? next.getAmount() : BigDecimal.ZERO;
                if (v1.compareTo(v2) != 0)
                    return true;
            }
        }
        return false;
    }

    public RatePeriodJournal applyBaseRate(BigDecimal base, BigDecimal growth, int decimals) {
        List<PeriodJournalEntry> sorted = getEntries().stream()
                .sorted(Comparator.comparing(PeriodJournalEntry::getStartDate))
                .collect(Collectors.toList());
        List<PeriodJournalEntry> result = new ArrayList<>();
        BigDecimal currentRate = base;
        for (PeriodJournalEntry entry : sorted) {
            BigDecimal rounded = currentRate.setScale(decimals, RoundingMode.HALF_UP);
            result.add(new PeriodJournalEntry(entry.getStartDate(), entry.getEndDate(), rounded, null));
            currentRate = currentRate.multiply(growth);
        }
        return new RatePeriodJournal(getName(), result, getProrationPolicy(), rateFrequency);
    }

    @Override
    public PeriodJournal resolveOverlapsWith(String policy) {
        String mappedPolicy = policy;
        if ("COMBINE_EDIT".equalsIgnoreCase(policy))
            mappedPolicy = "MERGE";
        if ("SINGLE_ENTRY".equalsIgnoreCase(policy))
            mappedPolicy = "FIRST";
        return super.resolveOverlapsWith(mappedPolicy);
    }

    public BigDecimal rateFactor() {
        switch (rateFrequency) {
            case MONTHLY:
                return BigDecimal.valueOf(12);
            case HOURLY:
                return BigDecimal.valueOf(2080);
            default:
                return BigDecimal.ONE;
        }
    }

    private PeriodJournal resolveMonthlyBeginning(PeriodJournal monthly) {
        // Use beginning-of-period rate for the full month
        return monthly;
    }

    private PeriodJournal resolveMonthlyEnding(PeriodJournal monthly) {
        // Use ending-of-period rate for the full month
        return monthly;
    }
}
