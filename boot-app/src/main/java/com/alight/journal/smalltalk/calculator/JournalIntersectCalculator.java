package com.alight.journal.smalltalk.calculator;

import java.util.ArrayList;
import java.util.List;

import com.alight.journal.smalltalk.model.ArgumentDescription;
import com.alight.journal.smalltalk.model.CalculationContext;
import com.alight.journal.smalltalk.model.HAProrationPolicyConstants;
import com.alight.journal.smalltalk.model.PeriodJournal;
import com.alight.journal.smalltalk.model.PeriodJournalEntry;
import com.alight.journal.smalltalk.model.ProrationPolicy;

public class JournalIntersectCalculator extends JournalAbstractCalculator {

    public static List<ArgumentDescription> computeArgumentDescriptions() {
        List<ArgumentDescription> result = new ArrayList<>();
        result.add(new ArgumentDescription(
                "target_journal",
                Calculator.periodJournalBlock(),
                null,
                null,
                "The period journal containing the entries to be returned if they are reflected in both the target and masking Journals.",
                true));
        result.add(new ArgumentDescription(
                "masking_journal",
                Calculator.periodJournalBlock(),
                null,
                null,
                "The period journal containing the entries that will be compared to the target journal to determine any intersection.",
                true));
        result.add(new ArgumentDescription(
                "proration_policy",
                Calculator.stringBlock(),
                null,
                HAProrationPolicyConstants.keys(),
                "The policy used to compute prorated amounts.",
                false));
        result.add(new ArgumentDescription(
                "multiplier_decimals",
                Calculator.numberBlock(),
                null,
                List.of(1, 2, 3, 4, 5, 6, 7, 8),
                "The number of decimal places maintained in the proration multiplier (i.e., time in prorated result / time in entire entry).",
                false));
        result.add(new ArgumentDescription(
                "result_decimals",
                Calculator.numberBlock(),
                null,
                List.of(1, 2, 3, 4, 5, 6, 7, 8),
                "The number of decimal places maintained in the prorated amount (i.e., original entry value * proration multiplier).",
                false));
        return result;
    }

    @Override
    public List<ArgumentDescription> argumentDescriptions() {
        return computeArgumentDescriptions();
    }

    @Override
    public String explanation() {
        return "Returns a version of target_journal containing only those periods reflected in both target_journal and masking_journal. Note that both journals must be period based journals. If an entry must be split, proration is preformed based on proration_policy, multiplier_decimals and result_decimals.";
    }

    @Override
    public String userName() {
        return "JrnlIntersect";
    }

    @Override
    public PeriodJournal calculateIn(CalculationContext context, List<Object> arguments) {
        return targetJournal(arguments, context).intersect(maskingJournal(arguments, context));
    }

    public PeriodJournal maskingJournal(List<Object> arguments, CalculationContext context) {
        PeriodJournal maskJrnl = ((PeriodJournal) arguments.get(1)).copyNamedWithoutStorage()
                .prorationPolicy(maskingProrationPolicy(arguments, context));
        return maskJrnl.copyWithEntrys(maskJrnl.resolve(maskJrnl.copyEntrys(), PeriodJournalEntry::isIntersecting));
    }

    public ProrationPolicy maskingProrationPolicy(List<Object> arguments, CalculationContext context) {
        if (arguments.get(2) != null) {
            return prorationPolicy(arguments);
        }
        PeriodJournal maskingJournal = (PeriodJournal) arguments.get(1);
        return maskingJournal.getProrationPolicy() == null
                ? context == null ? null : context.journalProrationPolicy()
                : maskingJournal.getProrationPolicy();
    }

    public Integer multiplierDecimals(List<Object> arguments) {
        return (Integer) arguments.get(3);
    }

    public ProrationPolicy prorationPolicy(List<Object> arguments) {
        return HAProrationPolicyConstants.at((String) arguments.get(2))
                .multiplierDecimals(multiplierDecimals(arguments))
                .resultDecimals(resultDecimals(arguments));
    }

    public Integer resultDecimals(List<Object> arguments) {
        return (Integer) arguments.get(4);
    }

    @Override
    public Object returnTypeBlock(List<Object> arguments) {
        return Calculator.journalBlock();
    }

    public PeriodJournal targetJournal(List<Object> arguments, CalculationContext context) {
        return ((PeriodJournal) arguments.get(0)).copyNamedWithoutStorage()
                .prorationPolicy(targetProrationPolicy(arguments, context));
    }

    public ProrationPolicy targetProrationPolicy(List<Object> arguments, CalculationContext context) {
        if (arguments.get(2) != null) {
            return prorationPolicy(arguments);
        }
        PeriodJournal targetJournal = (PeriodJournal) arguments.get(0);
        return targetJournal.getProrationPolicy() == null
                ? context == null ? null : context.journalProrationPolicy()
                : targetJournal.getProrationPolicy();
    }
}
