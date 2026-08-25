package com.alight.journal.smalltalk.dto;

import com.alight.journal.smalltalk.model.PeriodJournal;

public class JournalIntersectRequest {

    private PeriodJournal targetJournal;
    private PeriodJournal maskingJournal;
    private String prorationPolicy;
    private Integer multiplierDecimals;
    private Integer resultDecimals;
    private String contextJournalProrationPolicy;

    public PeriodJournal getTargetJournal() {
        return targetJournal;
    }

    public void setTargetJournal(PeriodJournal targetJournal) {
        this.targetJournal = targetJournal;
    }

    public PeriodJournal getMaskingJournal() {
        return maskingJournal;
    }

    public void setMaskingJournal(PeriodJournal maskingJournal) {
        this.maskingJournal = maskingJournal;
    }

    public String getProrationPolicy() {
        return prorationPolicy;
    }

    public void setProrationPolicy(String prorationPolicy) {
        this.prorationPolicy = prorationPolicy;
    }

    public Integer getMultiplierDecimals() {
        return multiplierDecimals;
    }

    public void setMultiplierDecimals(Integer multiplierDecimals) {
        this.multiplierDecimals = multiplierDecimals;
    }

    public Integer getResultDecimals() {
        return resultDecimals;
    }

    public void setResultDecimals(Integer resultDecimals) {
        this.resultDecimals = resultDecimals;
    }

    public String getContextJournalProrationPolicy() {
        return contextJournalProrationPolicy;
    }

    public void setContextJournalProrationPolicy(String contextJournalProrationPolicy) {
        this.contextJournalProrationPolicy = contextJournalProrationPolicy;
    }
}
