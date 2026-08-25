package com.alight.journal.smalltalk.controller;

import java.io.IOException;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;
import java.util.Map;

import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

import com.alight.journal.smalltalk.dto.JournalOperationFileRequest;
import com.alight.journal.smalltalk.dto.JournalOperationRequest;
import com.alight.journal.smalltalk.dto.JournalOperationResponse;
import com.alight.journal.smalltalk.model.PeriodJournal;
import com.alight.journal.smalltalk.model.PeriodJournalEntry;
import com.alight.journal.smalltalk.service.JournalOperationsService;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;

@RestController
@RequestMapping("/api/journal-operations")
@Tag(name = "Journal Operations", description = "Endpoints for all journal calculation operations (period transforms, arithmetic, overlap resolution, statistics, etc.)")
public class JournalOperationsController {

    private final JournalOperationsService service;

    public JournalOperationsController(JournalOperationsService service) {
        this.service = service;
    }

    @PostMapping("/calculate")
    @ResponseStatus(HttpStatus.OK)
    @Operation(summary = "Execute a journal operation", description = "Dispatches the requested operation on the provided journal(s). "
            + "Supports arithmetic, period transforms, overlap resolution, statistics, and more.")
    public JournalOperationResponse calculate(@RequestBody JournalOperationRequest request) {
        return service.execute(request);
    }

    @PostMapping("/from-file")
    @ResponseStatus(HttpStatus.OK)
    @Operation(summary = "Execute a journal operation from a JSON file", description = "Reads a JournalOperationRequest from the specified file path and executes it.")
    public JournalOperationResponse calculateFromFile(@RequestBody JournalOperationFileRequest request)
            throws IOException {
        return service.executeFromFile(request.getFilePath());
    }

    @GetMapping("/operations")
    @ResponseStatus(HttpStatus.OK)
    @Operation(summary = "List all supported operation types", description = "Returns the list of valid operationType values that can be used in requests.")
    public List<String> supportedOperations() {
        return service.supportedOperations();
    }

    @GetMapping("/test/add")
    @ResponseStatus(HttpStatus.OK)
    @Operation(summary = "Test: Add two journals", description = "Quick test endpoint that creates two single-entry journals and adds them together.")
    public JournalOperationResponse testAdd(
            @Parameter(description = "Start date of first journal entry") @RequestParam(defaultValue = "2024-01-01") String startDate1,
            @Parameter(description = "End date of first journal entry") @RequestParam(defaultValue = "2024-06-30") String endDate1,
            @Parameter(description = "Amount of first journal entry") @RequestParam(defaultValue = "5000.00") String amount1,
            @Parameter(description = "Start date of second journal entry") @RequestParam(defaultValue = "2024-04-01") String startDate2,
            @Parameter(description = "End date of second journal entry") @RequestParam(defaultValue = "2024-12-31") String endDate2,
            @Parameter(description = "Amount of second journal entry") @RequestParam(defaultValue = "3000.00") String amount2) {
        JournalOperationRequest request = new JournalOperationRequest();
        request.setOperationType("ADD");
        request.setJournal(buildJournal("journal1", startDate1, endDate1, amount1));
        request.setSecondJournal(buildJournal("journal2", startDate2, endDate2, amount2));
        return service.execute(request);
    }

    @GetMapping("/test/as-monthly")
    @ResponseStatus(HttpStatus.OK)
    @Operation(summary = "Test: Convert journal to monthly periods", description = "Quick test endpoint that splits a journal entry into calendar months.")
    public JournalOperationResponse testAsMonthly(
            @Parameter(description = "Start date") @RequestParam(defaultValue = "2024-01-15") String startDate,
            @Parameter(description = "End date") @RequestParam(defaultValue = "2024-04-20") String endDate,
            @Parameter(description = "Amount") @RequestParam(defaultValue = "12000.00") String amount) {
        JournalOperationRequest request = new JournalOperationRequest();
        request.setOperationType("AS_MONTHLY");
        request.setJournal(buildJournal("input", startDate, endDate, amount));
        return service.execute(request);
    }

    @GetMapping("/test/resolve-overlaps")
    @ResponseStatus(HttpStatus.OK)
    @Operation(summary = "Test: Resolve overlapping journal entries", description = "Creates overlapping entries and resolves them with the specified policy.")
    public JournalOperationResponse testResolveOverlaps(
            @Parameter(description = "Start date of first entry") @RequestParam(defaultValue = "2024-01-01") String startDate1,
            @Parameter(description = "End date of first entry") @RequestParam(defaultValue = "2024-06-30") String endDate1,
            @Parameter(description = "Amount of first entry") @RequestParam(defaultValue = "6000.00") String amount1,
            @Parameter(description = "Start date of second (overlapping) entry") @RequestParam(defaultValue = "2024-04-01") String startDate2,
            @Parameter(description = "End date of second entry") @RequestParam(defaultValue = "2024-09-30") String endDate2,
            @Parameter(description = "Amount of second entry") @RequestParam(defaultValue = "4000.00") String amount2,
            @Parameter(description = "Resolution policy: ADD, MERGE, HIGHEST, LOWEST, FIRST, LAST") @RequestParam(defaultValue = "ADD") String policy) {
        PeriodJournal journal = new PeriodJournal();
        journal.setName("overlapping");
        PeriodJournalEntry e1 = new PeriodJournalEntry(LocalDate.parse(startDate1), LocalDate.parse(endDate1),
                new BigDecimal(amount1), null);
        PeriodJournalEntry e2 = new PeriodJournalEntry(LocalDate.parse(startDate2), LocalDate.parse(endDate2),
                new BigDecimal(amount2), null);
        journal.setEntries(List.of(e1, e2));

        JournalOperationRequest request = new JournalOperationRequest();
        request.setOperationType("RESOLVE_OVERLAPS");
        request.setJournal(journal);
        request.setParameters(Map.of("policy", policy));
        return service.execute(request);
    }

    @GetMapping("/test/intersect")
    @ResponseStatus(HttpStatus.OK)
    @Operation(summary = "Test: Intersect two journals", description = "Intersects a target journal with a masking journal, prorating amounts over the overlap period.")
    public JournalOperationResponse testIntersect(
            @Parameter(description = "Target start") @RequestParam(defaultValue = "2024-01-01") String targetStart,
            @Parameter(description = "Target end") @RequestParam(defaultValue = "2024-12-31") String targetEnd,
            @Parameter(description = "Target amount") @RequestParam(defaultValue = "36500.00") String targetAmount,
            @Parameter(description = "Mask start") @RequestParam(defaultValue = "2024-03-01") String maskStart,
            @Parameter(description = "Mask end") @RequestParam(defaultValue = "2024-08-31") String maskEnd) {
        JournalOperationRequest request = new JournalOperationRequest();
        request.setOperationType("INTERSECT");
        request.setJournal(buildJournal("target", targetStart, targetEnd, targetAmount));
        request.setSecondJournal(buildJournal("mask", maskStart, maskEnd, null));
        return service.execute(request);
    }

    @GetMapping("/test/sum")
    @ResponseStatus(HttpStatus.OK)
    @Operation(summary = "Test: Sum all journal entry amounts", description = "Returns the total sum of all entry amounts in the journal.")
    public JournalOperationResponse testSum(
            @Parameter(description = "Comma-separated amounts for entries") @RequestParam(defaultValue = "1000,2000,3000,4000") String amounts) {
        String[] parts = amounts.split(",");
        PeriodJournal journal = new PeriodJournal();
        journal.setName("sumTest");
        LocalDate start = LocalDate.of(2024, 1, 1);
        List<PeriodJournalEntry> entries = new java.util.ArrayList<>();
        for (String part : parts) {
            LocalDate end = start.plusMonths(1).minusDays(1);
            entries.add(new PeriodJournalEntry(start, end, new BigDecimal(part.trim()), null));
            start = end.plusDays(1);
        }
        journal.setEntries(entries);

        JournalOperationRequest request = new JournalOperationRequest();
        request.setOperationType("SUM");
        request.setJournal(journal);
        return service.execute(request);
    }

    @GetMapping("/test/as-amount")
    @ResponseStatus(HttpStatus.OK)
    @Operation(summary = "Test: Convert rate journal to amount", description = "Converts a rate (annual/monthly/hourly) journal to an amount journal using rate factor * years * value.")
    public JournalOperationResponse testAsAmount(
            @Parameter(description = "Start date") @RequestParam(defaultValue = "2024-01-01") String startDate,
            @Parameter(description = "End date") @RequestParam(defaultValue = "2024-12-31") String endDate,
            @Parameter(description = "Rate value (e.g. annual salary)") @RequestParam(defaultValue = "75000.00") String rateValue) {
        JournalOperationRequest request = new JournalOperationRequest();
        request.setOperationType("AS_AMOUNT");
        request.setJournal(buildJournal("rateInput", startDate, endDate, rateValue));
        return service.execute(request);
    }

    @GetMapping("/test/value-before")
    @ResponseStatus(HttpStatus.OK)
    @Operation(summary = "Test: Get prorated value before a date", description = "Returns the prorated sum of all journal values occurring before the specified date.")
    public JournalOperationResponse testValueBefore(
            @Parameter(description = "Start date") @RequestParam(defaultValue = "2024-01-01") String startDate,
            @Parameter(description = "End date") @RequestParam(defaultValue = "2024-12-31") String endDate,
            @Parameter(description = "Amount") @RequestParam(defaultValue = "36500.00") String amount,
            @Parameter(description = "Date to query before") @RequestParam(defaultValue = "2024-07-01") String date) {
        JournalOperationRequest request = new JournalOperationRequest();
        request.setOperationType("VALUE_BEFORE");
        request.setJournal(buildJournal("input", startDate, endDate, amount));
        request.setParameters(Map.of("date", date));
        return service.execute(request);
    }

    @GetMapping("/test/contiguous-check")
    @ResponseStatus(HttpStatus.OK)
    @Operation(summary = "Test: Check if journal entries are contiguous", description = "Returns true if all entries are contiguous (no gaps between them).")
    public JournalOperationResponse testContiguousCheck(
            @Parameter(description = "Insert a gap between entries") @RequestParam(defaultValue = "false") boolean withGap) {
        PeriodJournal journal = new PeriodJournal();
        journal.setName("contiguousTest");
        PeriodJournalEntry e1 = new PeriodJournalEntry(
                LocalDate.of(2024, 1, 1), LocalDate.of(2024, 3, 31), new BigDecimal("3000"), null);
        LocalDate secondStart = withGap ? LocalDate.of(2024, 5, 1) : LocalDate.of(2024, 4, 1);
        PeriodJournalEntry e2 = new PeriodJournalEntry(
                secondStart, LocalDate.of(2024, 6, 30), new BigDecimal("3000"), null);
        journal.setEntries(List.of(e1, e2));

        JournalOperationRequest request = new JournalOperationRequest();
        request.setOperationType("CONTIGUOUS_CHECK");
        request.setJournal(journal);
        return service.execute(request);
    }

    private PeriodJournal buildJournal(String name, String startDate, String endDate, String amount) {
        PeriodJournal journal = new PeriodJournal();
        journal.setName(name);
        PeriodJournalEntry entry = new PeriodJournalEntry();
        entry.setStartDate(LocalDate.parse(startDate));
        entry.setEndDate(LocalDate.parse(endDate));
        if (amount != null && !amount.isBlank()) {
            entry.setAmount(new BigDecimal(amount));
        }
        journal.setEntries(List.of(entry));
        return journal;
    }
}
