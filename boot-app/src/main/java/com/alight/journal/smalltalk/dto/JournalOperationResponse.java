package com.alight.journal.smalltalk.dto;

import java.util.List;

import com.alight.journal.smalltalk.model.PeriodJournal;

import io.swagger.v3.oas.annotations.media.Schema;

@Schema(description = "Response from a journal operation")
public class JournalOperationResponse {

    @Schema(description = "The operation that was performed")
    private String operationType;

    @Schema(description = "Result journal (for journal-producing operations)")
    private PeriodJournal result;

    @Schema(description = "Scalar result (for operations that return a single value like SUM, AVERAGE)")
    private Object scalarResult;

    @Schema(description = "Validation or processing errors")
    private List<String> errors;

    public JournalOperationResponse() {
    }

    public JournalOperationResponse(String operationType, PeriodJournal result, Object scalarResult,
            List<String> errors) {
        this.operationType = operationType;
        this.result = result;
        this.scalarResult = scalarResult;
        this.errors = errors;
    }

    public static JournalOperationResponse success(String operationType, PeriodJournal result) {
        return new JournalOperationResponse(operationType, result, null, null);
    }

    public static JournalOperationResponse scalar(String operationType, Object scalarResult) {
        return new JournalOperationResponse(operationType, null, scalarResult, null);
    }

    public static JournalOperationResponse error(String operationType, List<String> errors) {
        return new JournalOperationResponse(operationType, null, null, errors);
    }

    public String getOperationType() {
        return operationType;
    }

    public void setOperationType(String operationType) {
        this.operationType = operationType;
    }

    public PeriodJournal getResult() {
        return result;
    }

    public void setResult(PeriodJournal result) {
        this.result = result;
    }

    public Object getScalarResult() {
        return scalarResult;
    }

    public void setScalarResult(Object scalarResult) {
        this.scalarResult = scalarResult;
    }

    public List<String> getErrors() {
        return errors;
    }

    public void setErrors(List<String> errors) {
        this.errors = errors;
    }
}
