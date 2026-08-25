package com.alight.journal.smalltalk.dto;

import java.util.List;

import com.alight.journal.smalltalk.model.ArgumentDescription;
import com.alight.journal.smalltalk.model.PeriodJournal;

public class JournalDivideResponse {

    private final String calculatorUserName;
    private final String explanation;
    private final List<ArgumentDescription> argumentDescriptions;
    private final PeriodJournal resultJournal;

    public JournalDivideResponse(String calculatorUserName, String explanation,
            List<ArgumentDescription> argumentDescriptions, PeriodJournal resultJournal) {
        this.calculatorUserName = calculatorUserName;
        this.explanation = explanation;
        this.argumentDescriptions = argumentDescriptions;
        this.resultJournal = resultJournal;
    }

    public String getCalculatorUserName() {
        return calculatorUserName;
    }

    public String getExplanation() {
        return explanation;
    }

    public List<ArgumentDescription> getArgumentDescriptions() {
        return argumentDescriptions;
    }

    public PeriodJournal getResultJournal() {
        return resultJournal;
    }
}
