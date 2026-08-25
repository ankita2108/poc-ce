package com.alight.journal.smalltalk.controller;

import java.io.IOException;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

import com.alight.journal.smalltalk.dto.JournalDivideFileRequest;
import com.alight.journal.smalltalk.dto.JournalDivideRequest;
import com.alight.journal.smalltalk.dto.JournalDivideResponse;
import com.alight.journal.smalltalk.model.PeriodJournal;
import com.alight.journal.smalltalk.model.PeriodJournalEntry;
import com.alight.journal.smalltalk.service.JournalDivideService;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;

@RestController
@RequestMapping("/api/journal-divisions")
@Tag(name = "Journal Divide", description = "Divide journal entry amounts by a number")
public class JournalDivideController {

    private final JournalDivideService journalDivideService;

    public JournalDivideController(JournalDivideService journalDivideService) {
        this.journalDivideService = journalDivideService;
    }

    @PostMapping
    @ResponseStatus(HttpStatus.OK)
    public JournalDivideResponse calculate(@RequestBody JournalDivideRequest request) {
        return journalDivideService.calculate(request);
    }

    @GetMapping("/test")
    @ResponseStatus(HttpStatus.OK)
    public JournalDivideResponse calculateTest(
            @RequestParam(defaultValue = "2024-01-01") String startDate,
            @RequestParam(defaultValue = "2024-01-31") String endDate,
            @RequestParam(defaultValue = "100.00") String amount,
            @RequestParam(defaultValue = "7") String number) {
        JournalDivideRequest request = new JournalDivideRequest();
        request.setJournal(journal("input", startDate, endDate, amount));
        request.setNumber(new BigDecimal(number));
        return journalDivideService.calculate(request);
    }

    @PostMapping("/from-file")
    @ResponseStatus(HttpStatus.OK)
    public JournalDivideResponse calculateFromFile(@RequestBody JournalDivideFileRequest request) throws IOException {
        return journalDivideService.calculateFromFile(request.getFilePath());
    }

    @GetMapping("/from-file")
    @ResponseStatus(HttpStatus.OK)
    public JournalDivideResponse calculateFromFile(@RequestParam String filePath) throws IOException {
        return journalDivideService.calculateFromFile(filePath);
    }

    private PeriodJournal journal(String name, String startDate, String endDate, String amount) {
        PeriodJournalEntry entry = new PeriodJournalEntry();
        entry.setStartDate(LocalDate.parse(startDate));
        entry.setEndDate(LocalDate.parse(endDate));
        entry.setAmount(new BigDecimal(amount));

        PeriodJournal journal = new PeriodJournal();
        journal.setName(name);
        journal.setEntries(List.of(entry));
        return journal;
    }
}
