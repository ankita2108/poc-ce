package com.alight.journal.smalltalk.model;

import java.math.BigDecimal;
import java.time.LocalDate;

public class MonthlyRatePeriodJournalEntry extends RatePeriodJournalEntry {

    private static final BigDecimal RATE_FACTOR = BigDecimal.valueOf(12);

    public MonthlyRatePeriodJournalEntry() {
    }

    public MonthlyRatePeriodJournalEntry(LocalDate startDate, LocalDate endDate, BigDecimal rateValue) {
        super(startDate, endDate, rateValue);
    }

    @Override
    public BigDecimal rateFactor() {
        return RATE_FACTOR;
    }

    @Override
    public boolean isMonthly() {
        return true;
    }

    @Override
    public PeriodJournalEntry copy() {
        return new MonthlyRatePeriodJournalEntry(getStartDate(), getEndDate(), getRateValue());
    }

    @Override
    protected RatePeriodJournalEntry createRateEntry(LocalDate start, LocalDate end, BigDecimal value) {
        return new MonthlyRatePeriodJournalEntry(start, end, value);
    }
}
