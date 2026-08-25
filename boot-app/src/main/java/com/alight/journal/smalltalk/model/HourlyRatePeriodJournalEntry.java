package com.alight.journal.smalltalk.model;

import java.math.BigDecimal;
import java.time.LocalDate;

public class HourlyRatePeriodJournalEntry extends RatePeriodJournalEntry {

    private static final BigDecimal RATE_FACTOR = BigDecimal.valueOf(2080);

    public HourlyRatePeriodJournalEntry() {
    }

    public HourlyRatePeriodJournalEntry(LocalDate startDate, LocalDate endDate, BigDecimal rateValue) {
        super(startDate, endDate, rateValue);
    }

    @Override
    public BigDecimal rateFactor() {
        return RATE_FACTOR;
    }

    @Override
    public boolean isHourly() {
        return true;
    }

    @Override
    public PeriodJournalEntry copy() {
        return new HourlyRatePeriodJournalEntry(getStartDate(), getEndDate(), getRateValue());
    }

    @Override
    protected RatePeriodJournalEntry createRateEntry(LocalDate start, LocalDate end, BigDecimal value) {
        return new HourlyRatePeriodJournalEntry(start, end, value);
    }
}
