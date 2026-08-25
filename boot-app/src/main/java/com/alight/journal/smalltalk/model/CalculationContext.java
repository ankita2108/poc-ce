package com.alight.journal.smalltalk.model;

public class CalculationContext {

    private final ProrationPolicy journalProrationPolicy;

    public CalculationContext(ProrationPolicy journalProrationPolicy) {
        this.journalProrationPolicy = journalProrationPolicy;
    }

    public ProrationPolicy journalProrationPolicy() {
        return journalProrationPolicy;
    }
}
