package com.alight.journal.smalltalk.io;

import java.io.IOException;
import java.nio.file.Path;

import org.springframework.stereotype.Component;

import com.alight.journal.smalltalk.dto.JournalIntersectRequest;
import com.fasterxml.jackson.databind.ObjectMapper;

@Component
public class JournalIntersectFileReader {

    private final ObjectMapper objectMapper;

    public JournalIntersectFileReader(ObjectMapper objectMapper) {
        this.objectMapper = objectMapper;
    }

    public JournalIntersectRequest read(Path path) throws IOException {
        return objectMapper.readValue(path.toFile(), JournalIntersectRequest.class);
    }
}
