package com.alight.journal.smalltalk.util;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

import com.alight.journal.smalltalk.dto.JournalIntersectRequest;
import com.alight.journal.smalltalk.model.PeriodJournal;
import com.alight.journal.smalltalk.model.PeriodJournalEntry;

public final class JournalIntersectTestUtil {

    private JournalIntersectTestUtil() {
    }

    public static JournalIntersectRequest request(
            PeriodJournal targetJournal,
            PeriodJournal maskingJournal,
            String prorationPolicy,
            Integer multiplierDecimals,
            Integer resultDecimals) {
        JournalIntersectRequest request = new JournalIntersectRequest();
        request.setTargetJournal(targetJournal);
        request.setMaskingJournal(maskingJournal);
        request.setProrationPolicy(prorationPolicy);
        request.setMultiplierDecimals(multiplierDecimals);
        request.setResultDecimals(resultDecimals);
        return request;
    }

    public static PeriodJournal journal(String name, PeriodJournalEntry... entries) {
        PeriodJournal journal = new PeriodJournal();
        journal.setName(name);
        journal.setEntries(List.of(entries));
        return journal;
    }

    public static PeriodJournalEntry entry(String startDate, String endDate, String amount) {
        return new PeriodJournalEntry(
                LocalDate.parse(startDate),
                LocalDate.parse(endDate),
                new BigDecimal(amount),
                null);
    }
}