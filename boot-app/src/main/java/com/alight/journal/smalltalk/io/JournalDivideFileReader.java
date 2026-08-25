package com.alight.journal.smalltalk.io;

import java.io.IOException;
import java.nio.file.Path;

import org.springframework.stereotype.Component;

import com.alight.journal.smalltalk.dto.JournalDivideRequest;
import com.fasterxml.jackson.databind.ObjectMapper;

@Component
public class JournalDivideFileReader {

    private final ObjectMapper objectMapper;

    public JournalDivideFileReader(ObjectMapper objectMapper) {
        this.objectMapper = objectMapper;
    }

    public JournalDivideRequest read(Path path) throws IOException {
        return objectMapper.readValue(path.toFile(), JournalDivideRequest.class);
    }
}
