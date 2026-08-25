package com.alight.journal.smalltalk.model;

import java.math.BigDecimal;
import java.time.LocalDate;

public class AnnualRatePeriodJournalEntry extends RatePeriodJournalEntry {

    public AnnualRatePeriodJournalEntry() {
    }

    public AnnualRatePeriodJournalEntry(LocalDate startDate, LocalDate endDate, BigDecimal rateValue) {
        super(startDate, endDate, rateValue);
    }

    @Override
    public BigDecimal rateFactor() {
        return BigDecimal.ONE;
    }

    @Override
    public boolean isAnnually() {
        return true;
    }

    @Override
    public PeriodJournalEntry copy() {
        return new AnnualRatePeriodJournalEntry(getStartDate(), getEndDate(), getRateValue());
    }

    @Override
    protected RatePeriodJournalEntry createRateEntry(LocalDate start, LocalDate end, BigDecimal value) {
        return new AnnualRatePeriodJournalEntry(start, end, value);
    }
}
