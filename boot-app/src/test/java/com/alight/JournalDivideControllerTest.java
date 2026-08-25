package com.alight;

import java.math.BigDecimal;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

import com.alight.journal.smalltalk.dto.JournalDivideRequest;
import com.alight.journal.smalltalk.util.JournalDivideTestUtil;
import com.fasterxml.jackson.databind.ObjectMapper;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest
@AutoConfigureMockMvc
public class JournalDivideControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @Test
    public void shouldCalculateJournalDivisionFromRestPayload() throws Exception {
        JournalDivideRequest request = JournalDivideTestUtil.request(
                JournalDivideTestUtil.journal("target",
                        JournalDivideTestUtil.entry("2024-01-01", "2024-01-31", "100.00")),
                new BigDecimal("4"));

        String requestBody = objectMapper.writeValueAsString(request);

        mockMvc.perform(post("/api/journal-divisions")
                .contentType(MediaType.APPLICATION_JSON)
                .content(requestBody))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.calculatorUserName").value("JrnlDivide"))
                .andExpect(jsonPath("$.explanation").value("Returns a journal with values equal to the existing journal values divided by the number provided."))
                .andExpect(jsonPath("$.resultJournal.entries[0].startDate").value("2024-01-01"))
                .andExpect(jsonPath("$.resultJournal.entries[0].endDate").value("2024-01-31"))
                .andExpect(jsonPath("$.resultJournal.entries[0].amount").value(25.00));
    }

    @Test
    public void shouldReturnArgumentDescriptions() throws Exception {
        JournalDivideRequest request = JournalDivideTestUtil.request(
                JournalDivideTestUtil.journal("target",
                        JournalDivideTestUtil.entry("2024-01-01", "2024-01-31", "50.00")),
                new BigDecimal("2"));

        String requestBody = objectMapper.writeValueAsString(request);

        mockMvc.perform(post("/api/journal-divisions")
                .contentType(MediaType.APPLICATION_JSON)
                .content(requestBody))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.argumentDescriptions[0].name").value("journal"))
                .andExpect(jsonPath("$.argumentDescriptions[0].dataType").value("Journal"))
                .andExpect(jsonPath("$.argumentDescriptions[1].name").value("number"))
                .andExpect(jsonPath("$.argumentDescriptions[1].dataType").value("Number"));
    }

    @Test
    public void shouldCalculateFromTestEndpoint() throws Exception {
        mockMvc.perform(get("/api/journal-divisions/test")
                .param("amount", "200.00")
                .param("number", "5"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.calculatorUserName").value("JrnlDivide"))
                .andExpect(jsonPath("$.resultJournal.entries[0].amount").value(40.00));
    }
}
