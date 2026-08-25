package com.alight;

import java.nio.file.Files;
import java.nio.file.Path;
import java.time.LocalDate;

import static org.assertj.core.api.Assertions.assertThat;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.json.AutoConfigureJsonTesters;
import org.springframework.boot.test.context.SpringBootTest;

import com.alight.journal.smalltalk.dto.JournalIntersectRequest;
import com.alight.journal.smalltalk.dto.JournalIntersectResponse;
import com.alight.journal.smalltalk.service.JournalIntersectService;
import com.alight.journal.smalltalk.util.JournalIntersectTestUtil;
import com.fasterxml.jackson.databind.ObjectMapper;

@SpringBootTest
@AutoConfigureJsonTesters
public class JournalIntersectServiceTest {

    @Autowired
    private JournalIntersectService journalIntersectService;

    @Autowired
    private ObjectMapper objectMapper;

    @Test
    public void shouldProrateTargetJournalIntersection() {
        JournalIntersectRequest request = JournalIntersectTestUtil.request(
            JournalIntersectTestUtil.journal("target", JournalIntersectTestUtil.entry("2024-01-01", "2024-01-10", "100.00")),
            JournalIntersectTestUtil.journal("mask", JournalIntersectTestUtil.entry("2024-01-05", "2024-01-07", "1.00")),
            "ACTUAL_DAYS",
            4,
            2);

        JournalIntersectResponse response = journalIntersectService.calculate(request);

        assertThat(response.getCalculatorUserName()).isEqualTo("JrnlIntersect");
        assertThat(response.getResultJournal().getEntries()).hasSize(1);
        assertThat(response.getResultJournal().getEntries().get(0).getStartDate()).isEqualTo(LocalDate.of(2024, 1, 5));
        assertThat(response.getResultJournal().getEntries().get(0).getEndDate()).isEqualTo(LocalDate.of(2024, 1, 7));
        assertThat(response.getResultJournal().getEntries().get(0).getAmount()).isEqualByComparingTo("30.00");
    }

    @Test
    public void shouldReadRequestFromTextFile() throws Exception {
        JournalIntersectRequest request = JournalIntersectTestUtil.request(
            JournalIntersectTestUtil.journal("target", JournalIntersectTestUtil.entry("2024-02-01", "2024-02-10", "200.00")),
            JournalIntersectTestUtil.journal(
                "mask",
                JournalIntersectTestUtil.entry("2024-02-04", "2024-02-05", "1.00"),
                JournalIntersectTestUtil.entry("2024-02-05", "2024-02-08", "1.00")),
            "ACTUAL_DAYS",
            4,
            2);

        Path tempFile = Files.createTempFile("journal-intersect", ".json");
        Files.writeString(tempFile, objectMapper.writeValueAsString(request));

        JournalIntersectResponse response = journalIntersectService.calculateFromFile(tempFile.toString());

        assertThat(response.getResultJournal().getEntries()).hasSize(1);
        assertThat(response.getResultJournal().getEntries().get(0).getStartDate()).isEqualTo(LocalDate.of(2024, 2, 4));
        assertThat(response.getResultJournal().getEntries().get(0).getEndDate()).isEqualTo(LocalDate.of(2024, 2, 8));
        assertThat(response.getResultJournal().getEntries().get(0).getAmount()).isEqualByComparingTo("100.00");
    }

}