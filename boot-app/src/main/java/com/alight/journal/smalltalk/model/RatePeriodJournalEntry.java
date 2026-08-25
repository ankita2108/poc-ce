package com.alight.journal.smalltalk.model;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;

public abstract class RatePeriodJournalEntry extends PeriodJournalEntry {

    public RatePeriodJournalEntry() {
    }

    public RatePeriodJournalEntry(LocalDate startDate, LocalDate endDate, BigDecimal rateValue) {
        super(startDate, endDate, rateValue, null);
    }

    public abstract BigDecimal rateFactor();

    public BigDecimal getRateValue() {
        return getAmount();
    }

    public void setRateValue(BigDecimal rateValue) {
        setAmount(rateValue);
    }

    public BigDecimal asAmount() {
        if (getRateValue() == null)
            return BigDecimal.ZERO;
        BigDecimal years = BigDecimal.valueOf(years());
        return getRateValue().multiply(years).multiply(rateFactor());
    }

    public BigDecimal asAmount(BigDecimal denominator) {
        if (getRateValue() == null || denominator == null)
            return BigDecimal.ZERO;
        return getRateValue().divide(denominator, 13, RoundingMode.HALF_UP);
    }

    public void addConsistent(RatePeriodJournalEntry other) {
        if (getRateValue() == null || other.getRateValue() == null)
            return;
        if (getRateValue().compareTo(BigDecimal.ZERO) == 0) {
            setRateValue(other.getRateValue());
            return;
        }
        if (other.getRateValue().compareTo(BigDecimal.ZERO) == 0)
            return;
        if (getRateValue().compareTo(other.getRateValue()) != 0) {
            throw new IllegalStateException(
                    "Conflicting rate values: " + getRateValue() + " vs " + other.getRateValue());
        }
    }

    @Override
    public PeriodJournalEntry intersectionWith(PeriodJournalEntry other, ProrationPolicy prorationPolicy) {
        if (!isIntersecting(other))
            return null;
        LocalDate intersectionStart = getStartDate().isAfter(other.getStartDate()) ? getStartDate()
                : other.getStartDate();
        LocalDate intersectionEnd = getEndDate().isBefore(other.getEndDate()) ? getEndDate() : other.getEndDate();
        return createRateEntry(intersectionStart, intersectionEnd, getRateValue());
    }

    @Override
    public PeriodJournalEntry mergeWith(PeriodJournalEntry other) {
        LocalDate mergedStart = getStartDate().isBefore(other.getStartDate()) ? getStartDate() : other.getStartDate();
        LocalDate mergedEnd = getEndDate().isAfter(other.getEndDate()) ? getEndDate() : other.getEndDate();
        return createRateEntry(mergedStart, mergedEnd, getRateValue());
    }

    @Override
    public PeriodJournalEntry divideNumber(BigDecimal number) {
        BigDecimal divided = getRateValue() != null
                ? getRateValue().divide(number, 13, RoundingMode.HALF_UP)
                : null;
        return createRateEntry(getStartDate(), getEndDate(), divided);
    }

    protected abstract RatePeriodJournalEntry createRateEntry(LocalDate start, LocalDate end, BigDecimal value);

    public boolean isAnnually() {
        return false;
    }

    public boolean isMonthly() {
        return false;
    }

    public boolean isHourly() {
        return false;
    }
}
