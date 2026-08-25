package com.alight.journal.smalltalk.model;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;

public class AmountPeriodJournalEntry extends PeriodJournalEntry {

    private ProrationPolicy prorationPolicy;

    public AmountPeriodJournalEntry() {
    }

    public AmountPeriodJournalEntry(LocalDate startDate, LocalDate endDate, BigDecimal amount) {
        super(startDate, endDate, amount, null);
    }

    public AmountPeriodJournalEntry(LocalDate startDate, LocalDate endDate, BigDecimal amount,
            ProrationPolicy prorationPolicy) {
        super(startDate, endDate, amount, null);
        this.prorationPolicy = prorationPolicy;
    }

    public ProrationPolicy getProrationPolicy() {
        return prorationPolicy;
    }

    public void setProrationPolicy(ProrationPolicy prorationPolicy) {
        this.prorationPolicy = prorationPolicy;
    }

    public ProrationPolicy defaultProrationPolicy() {
        return prorationPolicy != null ? prorationPolicy : HAProrationPolicyConstants.at("ACTUAL_DAYS");
    }

    public boolean needsProrationPolicy() {
        return prorationPolicy == null;
    }

    @Override
    public PeriodJournalEntry copy() {
        return new AmountPeriodJournalEntry(getStartDate(), getEndDate(), getAmount(), prorationPolicy);
    }

    @Override
    public PeriodJournalEntry intersectionWith(PeriodJournalEntry other, ProrationPolicy policy) {
        if (!isIntersecting(other))
            return null;
        LocalDate intersectionStart = getStartDate().isAfter(other.getStartDate()) ? getStartDate()
                : other.getStartDate();
        LocalDate intersectionEnd = getEndDate().isBefore(other.getEndDate()) ? getEndDate() : other.getEndDate();

        ProrationPolicy effectivePolicy = policy != null ? policy : defaultProrationPolicy();
        BigDecimal proratedAmount = getAmount();
        if (proratedAmount != null) {
            proratedAmount = effectivePolicy.prorate(proratedAmount,
                    inclusiveDays(intersectionStart, intersectionEnd), inclusiveDays());
        }
        return new AmountPeriodJournalEntry(intersectionStart, intersectionEnd, proratedAmount, effectivePolicy);
    }

    public BigDecimal valueOverAnnualRoundedTo(int decimals) {
        if (getAmount() == null)
            return BigDecimal.ZERO;
        BigDecimal years = BigDecimal.valueOf(years());
        if (years.compareTo(BigDecimal.ZERO) == 0)
            return BigDecimal.ZERO;
        return getAmount().divide(years, decimals, RoundingMode.HALF_UP);
    }

    public BigDecimal valueOverBiWeeklyRoundedTo(int decimals, int periodsPerYear, int year) {
        if (getAmount() == null)
            return BigDecimal.ZERO;
        BigDecimal periods = BigDecimal.valueOf(periodsPerYear);
        return getAmount().divide(periods, decimals, RoundingMode.HALF_UP);
    }

    public BigDecimal valueOverSemiMonthlyRoundedTo(int decimals, int dayOfMonth) {
        if (getAmount() == null)
            return BigDecimal.ZERO;
        return getAmount().divide(BigDecimal.valueOf(24), decimals, RoundingMode.HALF_UP);
    }

    public LocalDate findValueFromEnd(BigDecimal threshold) {
        if (getAmount() == null || threshold == null)
            return null;
        ProrationPolicy policy = defaultProrationPolicy();
        long totalDays = inclusiveDays();
        if (totalDays <= 0)
            return getEndDate();
        BigDecimal dailyRate = getAmount().divide(BigDecimal.valueOf(totalDays), 13, RoundingMode.HALF_UP);
        if (dailyRate.compareTo(BigDecimal.ZERO) == 0)
            return getEndDate();
        long daysNeeded = threshold.divide(dailyRate, 0, RoundingMode.CEILING).longValue();
        if (daysNeeded >= totalDays)
            return getStartDate();
        return getEndDate().minusDays(daysNeeded - 1);
    }

    public LocalDate findValueFromStart(BigDecimal threshold) {
        if (getAmount() == null || threshold == null)
            return null;
        long totalDays = inclusiveDays();
        if (totalDays <= 0)
            return getStartDate();
        BigDecimal dailyRate = getAmount().divide(BigDecimal.valueOf(totalDays), 13, RoundingMode.HALF_UP);
        if (dailyRate.compareTo(BigDecimal.ZERO) == 0)
            return getStartDate();
        long daysNeeded = threshold.divide(dailyRate, 0, RoundingMode.CEILING).longValue();
        if (daysNeeded >= totalDays)
            return getEndDate();
        return getStartDate().plusDays(daysNeeded - 1);
    }
}
