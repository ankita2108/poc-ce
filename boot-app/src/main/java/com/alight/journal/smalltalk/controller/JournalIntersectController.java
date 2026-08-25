package com.alight.journal.smalltalk.controller;

import java.io.IOException;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

import com.alight.journal.smalltalk.dto.JournalIntersectFileRequest;
import com.alight.journal.smalltalk.dto.JournalIntersectRequest;
import com.alight.journal.smalltalk.dto.JournalIntersectResponse;
import com.alight.journal.smalltalk.model.PeriodJournal;
import com.alight.journal.smalltalk.model.PeriodJournalEntry;
import com.alight.journal.smalltalk.service.JournalIntersectService;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;

@RestController
@RequestMapping("/api/journal-intersections")
@Tag(name = "Journal Intersect", description = "Intersect journal periods with masking journals and proration")
public class JournalIntersectController {

    private final JournalIntersectService journalIntersectService;

    public JournalIntersectController(JournalIntersectService journalIntersectService) {
        this.journalIntersectService = journalIntersectService;
    }

    @PostMapping
    @ResponseStatus(HttpStatus.OK)
    public JournalIntersectResponse calculate(@RequestBody JournalIntersectRequest request) {
        return journalIntersectService.calculate(request);
    }

    @GetMapping("/test")
    @ResponseStatus(HttpStatus.OK)
    public JournalIntersectResponse calculateTest(
            @RequestParam(defaultValue = "2024-03-01") String targetStart,
            @RequestParam(defaultValue = "2024-03-10") String targetEnd,
            @RequestParam(defaultValue = "100.00") String targetAmount,
            @RequestParam(defaultValue = "2024-03-06") String maskStart,
            @RequestParam(defaultValue = "2024-03-10") String maskEnd,
            @RequestParam(defaultValue = "ACTUAL_DAYS") String prorationPolicy,
            @RequestParam(defaultValue = "4") Integer multiplierDecimals,
            @RequestParam(defaultValue = "2") Integer resultDecimals,
            @RequestParam(required = false) String contextJournalProrationPolicy) {
        JournalIntersectRequest request = new JournalIntersectRequest();
        request.setTargetJournal(journal("target", targetStart, targetEnd, targetAmount));
        request.setMaskingJournal(journal("mask", maskStart, maskEnd, "1.00"));
        request.setProrationPolicy(prorationPolicy);
        request.setMultiplierDecimals(multiplierDecimals);
        request.setResultDecimals(resultDecimals);
        request.setContextJournalProrationPolicy(contextJournalProrationPolicy);
        return journalIntersectService.calculate(request);
    }

    @PostMapping("/from-file")
    @ResponseStatus(HttpStatus.OK)
    public JournalIntersectResponse calculateFromFile(@RequestBody JournalIntersectFileRequest request)
            throws IOException {
        return journalIntersectService.calculateFromFile(request.getFilePath());
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
