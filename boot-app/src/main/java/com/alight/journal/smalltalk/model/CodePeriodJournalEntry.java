package com.alight.journal.smalltalk.model;

import java.math.BigDecimal;
import java.time.LocalDate;

public class CodePeriodJournalEntry extends PeriodJournalEntry {

    public CodePeriodJournalEntry() {
    }

    public CodePeriodJournalEntry(LocalDate startDate, LocalDate endDate, String code) {
        super(startDate, endDate, null, code);
    }

    public String getCode() {
        return getValue();
    }

    public void setCode(String code) {
        setValue(code);
    }

    @Override
    public PeriodJournalEntry copy() {
        return new CodePeriodJournalEntry(getStartDate(), getEndDate(), getValue());
    }

    public CodePeriodJournalEntry combine(CodePeriodJournalEntry other) {
        if (getValue() == null || getValue().equals(other.getValue())) {
            return new CodePeriodJournalEntry(
                    getStartDate().isBefore(other.getStartDate()) ? getStartDate() : other.getStartDate(),
                    getEndDate().isAfter(other.getEndDate()) ? getEndDate() : other.getEndDate(),
                    other.getValue());
        }
        return new CodePeriodJournalEntry(
                getStartDate().isBefore(other.getStartDate()) ? getStartDate() : other.getStartDate(),
                getEndDate().isAfter(other.getEndDate()) ? getEndDate() : other.getEndDate(),
                getValue() + other.getValue());
    }

    public CodePeriodJournalEntry combine(CodePeriodJournalEntry other, String policy) {
        LocalDate mergedStart = getStartDate().isBefore(other.getStartDate()) ? getStartDate() : other.getStartDate();
        LocalDate mergedEnd = getEndDate().isAfter(other.getEndDate()) ? getEndDate() : other.getEndDate();
        String resultValue;
        switch (policy.toUpperCase()) {
            case "C":
                resultValue = (getValue() != null ? getValue() : "")
                        + (other.getValue() != null ? other.getValue() : "");
                break;
            case "F":
                resultValue = getValue();
                break;
            case "L":
                resultValue = other.getValue();
                break;
            default:
                resultValue = getValue();
        }
        return new CodePeriodJournalEntry(mergedStart, mergedEnd, resultValue);
    }

    public String codeValueOver(PeriodJournalEntry period) {
        if (isIntersecting(period)) {
            return getValue();
        }
        return "";
    }

    @Override
    public BigDecimal valueOver(PeriodJournalEntry period) {
        // Code entries have no numeric value to prorate
        return BigDecimal.ZERO;
    }

    @Override
    public PeriodJournalEntry intersectionWith(PeriodJournalEntry other, ProrationPolicy prorationPolicy) {
        if (!isIntersecting(other))
            return null;
        LocalDate intersectionStart = getStartDate().isAfter(other.getStartDate()) ? getStartDate()
                : other.getStartDate();
        LocalDate intersectionEnd = getEndDate().isBefore(other.getEndDate()) ? getEndDate() : other.getEndDate();
        return new CodePeriodJournalEntry(intersectionStart, intersectionEnd, getValue());
    }

    @Override
    public PeriodJournalEntry divideNumber(BigDecimal number) {
        return copy();
    }

    @Override
    public BigDecimal getAmount() {
        return null;
    }
}
