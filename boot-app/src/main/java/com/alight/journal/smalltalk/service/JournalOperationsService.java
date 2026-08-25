package com.alight.journal.smalltalk.service;

import java.io.IOException;
import java.math.BigDecimal;
import java.nio.file.Path;
import java.time.LocalDate;
import java.util.List;
import java.util.Map;

import org.springframework.stereotype.Service;

import com.alight.journal.smalltalk.dto.JournalOperationRequest;
import com.alight.journal.smalltalk.dto.JournalOperationResponse;
import com.alight.journal.smalltalk.io.JournalOperationsFileReader;
import com.alight.journal.smalltalk.model.AmountPeriodJournal;
import com.alight.journal.smalltalk.model.DuplicateResolutionPolicy;
import com.alight.journal.smalltalk.model.Journal;
import com.alight.journal.smalltalk.model.PeriodJournal;
import com.alight.journal.smalltalk.model.RatePeriodJournal;

@Service
public class JournalOperationsService {

    private final JournalOperationsFileReader fileReader;

    public JournalOperationsService(JournalOperationsFileReader fileReader) {
        this.fileReader = fileReader;
    }

    public JournalOperationResponse execute(JournalOperationRequest request) {
        if (request.getOperationType() == null || request.getOperationType().isBlank()) {
            return JournalOperationResponse.error(null, List.of("operationType is required"));
        }
        if (request.getJournal() == null) {
            return JournalOperationResponse.error(request.getOperationType(), List.of("journal is required"));
        }

        String op = request.getOperationType().toUpperCase();
        PeriodJournal journal = request.getJournal();
        PeriodJournal second = request.getSecondJournal();
        Map<String, Object> params = request.getParameters() != null ? request.getParameters() : Map.of();

        try {
            switch (op) {
                case "ADD":
                    return journalResult(op, journal.add(requireSecond(second, op)));
                case "SUBTRACT":
                    return journalResult(op, journal.subtract(requireSecond(second, op)));
                case "MULTIPLY":
                    return journalResult(op, journal.multiplyByNumber(toBigDecimal(params, "number")));
                case "DIVIDE":
                    return journalResult(op, journal.divideNumber(toBigDecimal(params, "number")));
                case "INTERSECT":
                    return journalResult(op, journal.intersect(requireSecond(second, op)));
                case "NON_INTERSECT":
                    return journalResult(op, journal.nonIntersect(requireSecond(second, op)));
                case "AS_MONTHLY":
                    return journalResult(op, journal.asMonthly());
                case "AS_ANNUAL":
                    return journalResult(op, journal.asAnnual(toDate(params, "anniversaryDate")));
                case "AS_CALENDAR_YEARS":
                    return journalResult(op, journal.asCalendarYears());
                case "AS_QUARTERLY":
                    return journalResult(op, journal.asQuarter(toDate(params, "quarterStart")));
                case "AS_SEMI_MONTHLY":
                    return journalResult(op, journal.asSemiMonthlyOn(toInt(params, "dayOfMonth", 15)));
                case "AS_DAILY":
                    return journalResult(op, toAmountJournal(journal).asDaily());
                case "AS_AMOUNT":
                    return journalResult(op, toRateJournal(journal).asAmount());
                case "RESOLVE_OVERLAPS":
                    return journalResult(op, journal.resolveOverlapsWith(
                            toString(params, "policy", "ADD")));
                case "RESOLVE_DUPLICATES":
                    return journalResult(op,
                            journal.resolveDuplicates(DuplicateResolutionPolicy.valueOf(
                                    toString(params, "policy", "ADD"))));
                case "VALUE_OVER":
                    return scalarResult(op, journal.valueOver(
                            secondEntry(second)));
                case "VALUE_BEFORE":
                    return scalarResult(op, journal.valueBefore(toDate(params, "date")));
                case "VALUE_AFTER":
                    return scalarResult(op, journal.valueAfter(toDate(params, "date")));
                case "SUM":
                    return scalarResult(op, journal.sum());
                case "AVERAGE":
                    return scalarResult(op, journal.average());
                case "MAX":
                    return scalarResult(op, journal.max());
                case "MIN":
                    return scalarResult(op, journal.min());
                case "ACCUMULATE":
                    return journalResult(op, toAmountJournal(journal)
                            .accumulateOver(toDate(params, "anniversaryDate")));
                case "APPLY_BASE_RATE":
                    return journalResult(op, toAmountJournal(journal).applyBaseRate(
                            toBigDecimal(params, "base"),
                            toBigDecimal(params, "growth"),
                            toInt(params, "decimals", 2)));
                case "PAY_CAP":
                    return journalResult(op, toAmountJournal(journal)
                            .asPayCappedJournalWith(requireSecond(second, op)));
                case "PAY_CUM_CAP":
                    return journalResult(op, toAmountJournal(journal)
                            .asPayCumCappedJournalWith(requireSecond(second, op)));
                case "HIGHEST_CONSECUTIVE":
                    return journalResult(op, journal.asHighestConsecutive(toInt(params, "count", 3)));
                case "FIND_VALUE_FROM_START":
                    return scalarResult(op, toAmountJournal(journal)
                            .findValueFromStart(toBigDecimal(params, "threshold")));
                case "FIND_VALUE_FROM_END":
                    return scalarResult(op, toAmountJournal(journal)
                            .findValueFromEnd(toBigDecimal(params, "threshold")));
                case "PERIODS_BETWEEN":
                    return journalResult(op, journal.periodsBetween(
                            toDate(params, "fromDate"), toDate(params, "toDate")));
                case "CONTIGUOUS_CHECK":
                    return scalarResult(op, journal.isContiguous());
                case "AGGREGATE":
                    return journalResult(op, journal.aggregateFromStartForEntries(
                            toInt(params, "groupSize", 3)));
                default:
                    return JournalOperationResponse.error(op,
                            List.of("Unsupported operation type: " + op));
            }
        } catch (IllegalArgumentException e) {
            return JournalOperationResponse.error(op, List.of(e.getMessage()));
        }
    }

    public JournalOperationResponse executeFromFile(String filePath) throws IOException {
        JournalOperationRequest request = fileReader.read(Path.of(filePath));
        return execute(request);
    }

    public List<String> supportedOperations() {
        return List.of(
                "ADD", "SUBTRACT", "MULTIPLY", "DIVIDE", "INTERSECT", "NON_INTERSECT",
                "AS_MONTHLY", "AS_ANNUAL", "AS_CALENDAR_YEARS", "AS_QUARTERLY", "AS_SEMI_MONTHLY",
                "AS_DAILY", "AS_AMOUNT", "RESOLVE_OVERLAPS", "RESOLVE_DUPLICATES",
                "VALUE_OVER", "VALUE_BEFORE", "VALUE_AFTER", "SUM", "AVERAGE", "MAX", "MIN",
                "ACCUMULATE", "APPLY_BASE_RATE", "PAY_CAP", "PAY_CUM_CAP",
                "HIGHEST_CONSECUTIVE", "FIND_VALUE_FROM_START", "FIND_VALUE_FROM_END",
                "PERIODS_BETWEEN", "CONTIGUOUS_CHECK", "AGGREGATE");
    }

    // --- Helpers ---

    private JournalOperationResponse journalResult(String op, PeriodJournal result) {
        return JournalOperationResponse.success(op, result);
    }

    private JournalOperationResponse journalResult(String op, Journal result) {
        if (result instanceof PeriodJournal) {
            return JournalOperationResponse.success(op, (PeriodJournal) result);
        }
        PeriodJournal pj = new PeriodJournal();
        pj.setEntries(result.getEntries());
        return JournalOperationResponse.success(op, pj);
    }

    private JournalOperationResponse scalarResult(String op, Object result) {
        return JournalOperationResponse.scalar(op, result);
    }

    private PeriodJournal requireSecond(PeriodJournal second, String op) {
        if (second == null) {
            throw new IllegalArgumentException("secondJournal is required for " + op);
        }
        return second;
    }

    private com.alight.journal.smalltalk.model.PeriodJournalEntry secondEntry(PeriodJournal second) {
        if (second == null || second.getEntries().isEmpty()) {
            throw new IllegalArgumentException("secondJournal with at least one entry is required for VALUE_OVER");
        }
        return second.getEntries().get(0);
    }

    private AmountPeriodJournal toAmountJournal(PeriodJournal journal) {
        if (journal instanceof AmountPeriodJournal)
            return (AmountPeriodJournal) journal;
        return new AmountPeriodJournal(journal.getName(), journal.getEntries(), journal.getProrationPolicy());
    }

    private RatePeriodJournal toRateJournal(PeriodJournal journal) {
        if (journal instanceof RatePeriodJournal)
            return (RatePeriodJournal) journal;
        return new RatePeriodJournal(journal.getName(), journal.getEntries(), journal.getProrationPolicy());
    }

    private BigDecimal toBigDecimal(Map<String, Object> params, String key) {
        Object val = params.get(key);
        if (val == null)
            throw new IllegalArgumentException("Parameter '" + key + "' is required");
        if (val instanceof Number)
            return BigDecimal.valueOf(((Number) val).doubleValue());
        return new BigDecimal(val.toString());
    }

    private LocalDate toDate(Map<String, Object> params, String key) {
        Object val = params.get(key);
        if (val == null)
            throw new IllegalArgumentException("Parameter '" + key + "' is required");
        return LocalDate.parse(val.toString());
    }

    private int toInt(Map<String, Object> params, String key, int defaultValue) {
        Object val = params.get(key);
        if (val == null)
            return defaultValue;
        if (val instanceof Number)
            return ((Number) val).intValue();
        return Integer.parseInt(val.toString());
    }

    private String toString(Map<String, Object> params, String key, String defaultValue) {
        Object val = params.get(key);
        if (val == null)
            return defaultValue;
        return val.toString();
    }
}
