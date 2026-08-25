package com.alight.journal.smalltalk.util;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

import com.alight.journal.smalltalk.dto.JournalDivideRequest;
import com.alight.journal.smalltalk.model.PeriodJournal;
import com.alight.journal.smalltalk.model.PeriodJournalEntry;

public final class JournalDivideTestUtil {

    private JournalDivideTestUtil() {
    }

    public static JournalDivideRequest request(PeriodJournal journal, BigDecimal number) {
        JournalDivideRequest request = new JournalDivideRequest();
        request.setJournal(journal);
        request.setNumber(number);
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
