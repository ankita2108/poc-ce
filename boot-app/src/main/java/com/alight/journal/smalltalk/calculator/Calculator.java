package com.alight.journal.smalltalk.calculator;

import java.util.List;

import com.alight.journal.smalltalk.SmalltalkObject;
import com.alight.journal.smalltalk.model.CalculationContext;

public abstract class Calculator extends SmalltalkObject {

    public static String journalBlock() {
        return "Journal";
    }

    public static String numberBlock() {
        return "Number";
    }

    public static String periodJournalBlock() {
        return "PeriodJournal";
    }

    public static String stringBlock() {
        return "String";
    }

    public String explanation() {
        return "No Explanation Available";
    }

    @Override
    public boolean isCalculator() {
        return true;
    }

    public boolean isCalculatorType() {
        return true;
    }

    public abstract Object calculateIn(CalculationContext context);

    public List<String> category() {
        return List.of("Uncategorized");
    }
}
