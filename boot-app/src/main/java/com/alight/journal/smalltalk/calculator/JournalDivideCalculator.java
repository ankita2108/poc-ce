package com.alight.journal.smalltalk.calculator;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;

import com.alight.journal.smalltalk.model.ArgumentDescription;
import com.alight.journal.smalltalk.model.CalculationContext;
import com.alight.journal.smalltalk.model.PeriodJournal;

public class JournalDivideCalculator extends JournalAbstractCalculator {

    public static List<ArgumentDescription> computeArgumentDescriptions() {
        List<ArgumentDescription> result = new ArrayList<>();
        result.add(new ArgumentDescription(
                "journal",
                Calculator.journalBlock(),
                null,
                null,
                "Journal to be used.",
                false));
        result.add(new ArgumentDescription(
                "number",
                Calculator.numberBlock(),
                null,
                null,
                "Number used to divide journal.",
                false));
        return result;
    }

    @Override
    public List<ArgumentDescription> argumentDescriptions() {
        return computeArgumentDescriptions();
    }

    @Override
    public String explanation() {
        return "Returns a journal with values equal to the existing journal values divided by the number provided.";
    }

    @Override
    public String userName() {
        return "JrnlDivide";
    }

    @Override
    public PeriodJournal calculateIn(CalculationContext context, List<Object> arguments) {
        return journal(arguments).divideNumber(number(arguments));
    }

    public BigDecimal number(List<Object> arguments) {
        Object arg = arguments.get(1);
        if (arg instanceof BigDecimal) {
            return (BigDecimal) arg;
        }
        return new BigDecimal(arg.toString());
    }

    public List<String> relationalErrors(List<Object> arguments) {
        List<String> errors = editCodePeriodJrnl(arguments.get(0));
        if (errors != null) {
            return errors;
        }
        return null;
    }

    @Override
    public Object returnTypeBlock(List<Object> arguments) {
        return Calculator.journalBlock();
    }
}
