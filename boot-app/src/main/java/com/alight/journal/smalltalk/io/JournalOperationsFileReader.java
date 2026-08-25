package com.alight.journal.smalltalk.io;

import java.io.IOException;
import java.nio.file.Path;

import org.springframework.stereotype.Component;

import com.alight.journal.smalltalk.dto.JournalOperationRequest;
import com.fasterxml.jackson.databind.ObjectMapper;

@Component
public class JournalOperationsFileReader {

    private final ObjectMapper objectMapper;

    public JournalOperationsFileReader(ObjectMapper objectMapper) {
        this.objectMapper = objectMapper;
    }

    public JournalOperationRequest read(Path path) throws IOException {
        return objectMapper.readValue(path.toFile(), JournalOperationRequest.class);
    }
}
