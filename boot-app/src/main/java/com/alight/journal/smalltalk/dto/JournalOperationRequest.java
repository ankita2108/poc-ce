package com.alight.journal.smalltalk.dto;

import java.util.Map;

import com.alight.journal.smalltalk.model.PeriodJournal;

import io.swagger.v3.oas.annotations.media.Schema;

@Schema(description = "Request for journal operations")
public class JournalOperationRequest {

    @Schema(description = "Operation type", example = "ADD", allowableValues = { "ADD", "SUBTRACT", "MULTIPLY",
            "DIVIDE", "INTERSECT", "NON_INTERSECT",
            "AS_MONTHLY", "AS_ANNUAL", "AS_CALENDAR_YEARS", "AS_QUARTERLY", "AS_SEMI_MONTHLY",
            "AS_DAILY", "AS_AMOUNT", "RESOLVE_OVERLAPS", "RESOLVE_DUPLICATES",
            "VALUE_OVER", "VALUE_BEFORE", "VALUE_AFTER", "SUM", "AVERAGE", "MAX", "MIN",
            "ACCUMULATE", "APPLY_BASE_RATE", "PAY_CAP", "PAY_CUM_CAP",
            "HIGHEST_CONSECUTIVE", "FIND_VALUE_FROM_START", "FIND_VALUE_FROM_END",
            "PERIODS_BETWEEN", "CONTIGUOUS_CHECK", "AGGREGATE" })
    private String operationType;

    @Schema(description = "Primary journal for the operation")
    private PeriodJournal journal;

    @Schema(description = "Secondary journal (for binary operations like ADD, INTERSECT, cap tables)")
    private PeriodJournal secondJournal;

    @Schema(description = "Additional parameters (dates, numbers, policies, decimals)")
    private Map<String, Object> parameters;

    public String getOperationType() {
        return operationType;
    }

    public void setOperationType(String operationType) {
        this.operationType = operationType;
    }

    public PeriodJournal getJournal() {
        return journal;
    }

    public void setJournal(PeriodJournal journal) {
        this.journal = journal;
    }

    public PeriodJournal getSecondJournal() {
        return secondJournal;
    }

    public void setSecondJournal(PeriodJournal secondJournal) {
        this.secondJournal = secondJournal;
    }

    public Map<String, Object> getParameters() {
        return parameters;
    }

    public void setParameters(Map<String, Object> parameters) {
        this.parameters = parameters;
    }
}
