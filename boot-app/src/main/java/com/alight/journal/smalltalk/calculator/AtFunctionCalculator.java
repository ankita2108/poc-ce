package com.alight.journal.smalltalk.calculator;

import java.util.List;

import com.alight.journal.smalltalk.model.PeriodJournal;

public abstract class AtFunctionCalculator extends CalculatorWithArguments {

    @Override
    public List<String> category() {
        return List.of("Uncategorized");
    }

    public String hiddenName() {
        return "Hidden";
    }

    public String userName() {
        return hiddenName();
    }

    public List<String> editCodePeriodJrnl(Object journal) {
        if (journal instanceof PeriodJournal periodJournal && periodJournal.isCodePeriodJournal()) {
            return List.of("Input journal type is invalid. Expected: Rate or Amount period journal");
        }
        return null;
    }

    public List<String> editAmountCodePeriodJrnl(Object journal) {
        if (journal instanceof PeriodJournal periodJournal
                && (periodJournal.isAmountPeriodJournal() || periodJournal.isCodePeriodJournal())) {
            return List.of("Input journal type is invalid. Expected: Rate period journal");
        }
        return null;
    }

    public List<String> editRatePeriodJrnl(Object journal) {
        if (journal instanceof PeriodJournal periodJournal && periodJournal.isRatePeriodJournal()) {
            return List.of("Input journal type is invalid. Expected: Code or Amount period journal");
        }
        return null;
    }
}
