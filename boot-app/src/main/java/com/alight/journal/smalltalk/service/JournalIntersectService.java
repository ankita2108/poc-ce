package com.alight.journal.smalltalk.service;

import java.io.IOException;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.List;

import org.springframework.stereotype.Service;

import com.alight.journal.smalltalk.calculator.JournalIntersectCalculator;
import com.alight.journal.smalltalk.dto.JournalIntersectRequest;
import com.alight.journal.smalltalk.dto.JournalIntersectResponse;
import com.alight.journal.smalltalk.io.JournalIntersectFileReader;
import com.alight.journal.smalltalk.model.CalculationContext;
import com.alight.journal.smalltalk.model.HAProrationPolicyConstants;
import com.alight.journal.smalltalk.model.PeriodJournal;
import com.alight.journal.smalltalk.model.ProrationPolicy;

@Service
public class JournalIntersectService {

    private final JournalIntersectCalculator calculator = new JournalIntersectCalculator();
    private final JournalIntersectFileReader fileReader;

    public JournalIntersectService(JournalIntersectFileReader fileReader) {
        this.fileReader = fileReader;
    }

    public JournalIntersectResponse calculate(JournalIntersectRequest request) {
        CalculationContext context = new CalculationContext(resolveContextPolicy(request));
        List<Object> arguments = new ArrayList<>();
        arguments.add(request.getTargetJournal());
        arguments.add(request.getMaskingJournal());
        arguments.add(request.getProrationPolicy());
        arguments.add(request.getMultiplierDecimals());
        arguments.add(request.getResultDecimals());

        PeriodJournal resultJournal = calculator.calculateIn(context, arguments);
        return new JournalIntersectResponse(
                calculator.userName(),
                calculator.explanation(),
                calculator.argumentDescriptions(),
                resultJournal);
    }

    public JournalIntersectResponse calculateFromFile(String filePath) throws IOException {
        return calculate(fileReader.read(Path.of(filePath)));
    }

    private ProrationPolicy resolveContextPolicy(JournalIntersectRequest request) {
        if (request.getContextJournalProrationPolicy() == null) {
            return null;
        }
        return HAProrationPolicyConstants.at(request.getContextJournalProrationPolicy())
                .multiplierDecimals(request.getMultiplierDecimals())
                .resultDecimals(request.getResultDecimals());
    }
}
