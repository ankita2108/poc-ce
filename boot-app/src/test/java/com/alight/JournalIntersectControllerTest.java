package com.alight;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

import com.alight.journal.smalltalk.dto.JournalIntersectRequest;
import com.alight.journal.smalltalk.util.JournalIntersectTestUtil;
import com.fasterxml.jackson.databind.ObjectMapper;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest
@AutoConfigureMockMvc
public class JournalIntersectControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @Test
    public void shouldCalculateJournalIntersectionFromRestPayload() throws Exception {
        JournalIntersectRequest request = JournalIntersectTestUtil.request(
                JournalIntersectTestUtil.journal("target", JournalIntersectTestUtil.entry("2024-03-01", "2024-03-10", "100.00")),
                JournalIntersectTestUtil.journal("mask", JournalIntersectTestUtil.entry("2024-03-06", "2024-03-10", "1.00")),
                "ACTUAL_DAYS",
                4,
                2);

        String requestBody = objectMapper.writeValueAsString(request);

        mockMvc.perform(post("/api/journal-intersections")
                .contentType(MediaType.APPLICATION_JSON)
                .content(requestBody))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.calculatorUserName").value("JrnlIntersect"))
                .andExpect(jsonPath("$.resultJournal.entries[0].startDate").value("2024-03-06"))
                .andExpect(jsonPath("$.resultJournal.entries[0].endDate").value("2024-03-10"))
                .andExpect(jsonPath("$.resultJournal.entries[0].amount").value(50.00));
    }
}