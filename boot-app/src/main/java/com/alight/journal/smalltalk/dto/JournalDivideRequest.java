package com.alight.journal.smalltalk.dto;

import java.math.BigDecimal;

import com.alight.journal.smalltalk.model.PeriodJournal;

public class JournalDivideRequest {

    private PeriodJournal journal;
    private BigDecimal number;

    public PeriodJournal getJournal() {
        return journal;
    }

    public void setJournal(PeriodJournal journal) {
        this.journal = journal;
    }

    public BigDecimal getNumber() {
        return number;
    }

    public void setNumber(BigDecimal number) {
        this.number = number;
    }
}
