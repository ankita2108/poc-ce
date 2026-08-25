package com.alight.journal.smalltalk.dto;

import io.swagger.v3.oas.annotations.media.Schema;

@Schema(description = "Request to execute a journal operation from a file")
public class JournalOperationFileRequest {

    @Schema(description = "Path to the JSON file containing JournalOperationRequest", example = "/data/operation.json")
    private String filePath;

    public String getFilePath() {
        return filePath;
    }

    public void setFilePath(String filePath) {
        this.filePath = filePath;
    }
}
