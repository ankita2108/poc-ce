package com.alight.journal.smalltalk.calculator;

import java.time.LocalDate;
import java.util.List;

import com.alight.journal.smalltalk.model.CalculationContext;
import com.alight.journal.smalltalk.model.PeriodJournal;

public abstract class JournalAbstractCalculator extends AtFunctionCalculator {

    private static final LocalDate TBA_HIGH_DATE = LocalDate.of(2299, 12, 31);
    private static final LocalDate TBA_LOW_DATE = LocalDate.of(1800, 1, 1);

    @Override
    public List<String> category() {
        return List.of("Journals");
    }

    @Override
    public String userName() {
        return hiddenName();
    }

    public Class<?> exceptionalResultClass() {
        return PeriodJournal.class;
    }

    public List<String> highDateError() {
        return List.of("Last date in journal must be before 12/31/2299");
    }

    public List<String> highDateError(List<Object> arguments, CalculationContext context) {
        PeriodJournal journal = journal(arguments, context);
        if (journal.isEmpty()) {
            return null;
        }
        return journal.latestDate().isBefore(TBA_HIGH_DATE) ? null : highDateError();
    }

    public PeriodJournal journal(List<Object> arguments) {
        return (PeriodJournal) arguments.get(0);
    }

    public PeriodJournal journal(List<Object> arguments, CalculationContext context) {
        PeriodJournal result = journal(arguments);
        if (result.needsProrationPolicy() && context != null && context.journalProrationPolicy() != null) {
            result.setProrationPolicyIn(context);
        }
        return result;
    }

    public List<String> lowDateError() {
        return List.of("First date in journal must be after 01/01/1800");
    }

    public List<String> lowDateError(List<Object> arguments, CalculationContext context) {
        PeriodJournal journal = journal(arguments, context);
        if (journal.isEmpty()) {
            return null;
        }
        return journal.earliestDate().isAfter(TBA_LOW_DATE) ? null : lowDateError();
    }

    public List<String> lowHighDateErrors(List<Object> arguments, CalculationContext context) {
        List<String> errors = highDateError(arguments, context);
        return errors == null ? lowDateError(arguments, context) : errors;
    }
}
