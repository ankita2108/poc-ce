package com.alight;

import java.math.BigDecimal;
import java.nio.file.Files;
import java.nio.file.Path;
import java.time.LocalDate;

import static org.assertj.core.api.Assertions.assertThat;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.json.AutoConfigureJsonTesters;
import org.springframework.boot.test.context.SpringBootTest;

import com.alight.journal.smalltalk.dto.JournalDivideRequest;
import com.alight.journal.smalltalk.dto.JournalDivideResponse;
import com.alight.journal.smalltalk.service.JournalDivideService;
import com.alight.journal.smalltalk.util.JournalDivideTestUtil;
import com.fasterxml.jackson.databind.ObjectMapper;

@SpringBootTest
@AutoConfigureJsonTesters
public class JournalDivideServiceTest {

    @Autowired
    private JournalDivideService journalDivideService;

    @Autowired
    private ObjectMapper objectMapper;

    @Test
    public void shouldDivideJournalEntryAmountByNumber() {
        JournalDivideRequest request = JournalDivideTestUtil.request(
                JournalDivideTestUtil.journal("target",
                        JournalDivideTestUtil.entry("2024-01-01", "2024-01-31", "100.00")),
                new BigDecimal("4"));

        JournalDivideResponse response = journalDivideService.calculate(request);

        assertThat(response.getCalculatorUserName()).isEqualTo("JrnlDivide");
        assertThat(response.getExplanation()).contains("divided by the number provided");
        assertThat(response.getResultJournal().getEntries()).hasSize(1);
        assertThat(response.getResultJournal().getEntries().get(0).getStartDate()).isEqualTo(LocalDate.of(2024, 1, 1));
        assertThat(response.getResultJournal().getEntries().get(0).getEndDate()).isEqualTo(LocalDate.of(2024, 1, 31));
        assertThat(response.getResultJournal().getEntries().get(0).getAmount()).isEqualByComparingTo("25.00");
    }

    @Test
    public void shouldDivideMultipleJournalEntries() {
        JournalDivideRequest request = JournalDivideTestUtil.request(
                JournalDivideTestUtil.journal("multi",
                        JournalDivideTestUtil.entry("2024-01-01", "2024-01-31", "200.00"),
                        JournalDivideTestUtil.entry("2024-02-01", "2024-02-29", "300.00")),
                new BigDecimal("2"));

        JournalDivideResponse response = journalDivideService.calculate(request);

        assertThat(response.getResultJournal().getEntries()).hasSize(2);
        assertThat(response.getResultJournal().getEntries().get(0).getAmount()).isEqualByComparingTo("100.00");
        assertThat(response.getResultJournal().getEntries().get(1).getAmount()).isEqualByComparingTo("150.00");
    }

    @Test
    public void shouldReadRequestFromTextFile() throws Exception {
        JournalDivideRequest request = JournalDivideTestUtil.request(
                JournalDivideTestUtil.journal("file-test",
                        JournalDivideTestUtil.entry("2024-03-01", "2024-03-31", "120.00")),
                new BigDecimal("3"));

        Path tempFile = Files.createTempFile("journal-divide", ".json");
        Files.writeString(tempFile, objectMapper.writeValueAsString(request));

        JournalDivideResponse response = journalDivideService.calculateFromFile(tempFile.toString());

        assertThat(response.getResultJournal().getEntries()).hasSize(1);
        assertThat(response.getResultJournal().getEntries().get(0).getAmount()).isEqualByComparingTo("40.00");
    }
}
