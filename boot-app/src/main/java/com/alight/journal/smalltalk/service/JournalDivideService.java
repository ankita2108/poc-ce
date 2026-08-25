package com.alight.journal.smalltalk.service;

import java.io.IOException;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.List;

import org.springframework.stereotype.Service;

import com.alight.journal.smalltalk.calculator.JournalDivideCalculator;
import com.alight.journal.smalltalk.dto.JournalDivideRequest;
import com.alight.journal.smalltalk.dto.JournalDivideResponse;
import com.alight.journal.smalltalk.io.JournalDivideFileReader;
import com.alight.journal.smalltalk.model.CalculationContext;
import com.alight.journal.smalltalk.model.PeriodJournal;

@Service
public class JournalDivideService {

    private final JournalDivideCalculator calculator = new JournalDivideCalculator();
    private final JournalDivideFileReader fileReader;

    public JournalDivideService(JournalDivideFileReader fileReader) {
        this.fileReader = fileReader;
    }

    public JournalDivideResponse calculate(JournalDivideRequest request) {
        List<String> validationErrors = calculator.relationalErrors(buildArguments(request));
        if (validationErrors != null && !validationErrors.isEmpty()) {
            throw new IllegalArgumentException(String.join("; ", validationErrors));
        }

        CalculationContext context = new CalculationContext(null);
        List<Object> arguments = buildArguments(request);

        PeriodJournal resultJournal = calculator.calculateIn(context, arguments);
        return new JournalDivideResponse(
                calculator.userName(),
                calculator.explanation(),
                calculator.argumentDescriptions(),
                resultJournal);
    }

    public JournalDivideResponse calculateFromFile(String filePath) throws IOException {
        return calculate(fileReader.read(Path.of(filePath)));
    }

    private List<Object> buildArguments(JournalDivideRequest request) {
        List<Object> arguments = new ArrayList<>();
        arguments.add(request.getJournal());
        arguments.add(request.getNumber());
        return arguments;
    }
}
