package com.alight.journal.smalltalk.calculator;

import java.util.ArrayList;
import java.util.List;

import com.alight.journal.smalltalk.model.ArgumentDescription;
import com.alight.journal.smalltalk.model.CalculationContext;

public abstract class CalculatorWithArguments extends Calculator {

    private List<Object> inputArguments;

    public List<ArgumentDescription> argumentDescriptions() {
        return List.of();
    }

    public List<Object> defaultArguments() {
        List<Object> defaults = new ArrayList<>();
        argumentDescriptions().forEach(argumentDescription -> defaults.add(argumentDescription.getDefaultValue()));
        return defaults;
    }

    public boolean hasArgumentDescriptions() {
        return !argumentDescriptions().isEmpty();
    }

    public void initializeWithArguments(List<Object> arguments) {
        inputArguments(arguments);
    }

    public List<Object> inputArguments() {
        if (inputArguments == null) {
            inputArguments = defaultArguments();
        }
        return inputArguments;
    }

    public void inputArguments(List<Object> arguments) {
        inputArguments = arguments;
    }

    public int numberOfArguments() {
        return argumentDescriptions().size();
    }

    @Override
    public Object calculateIn(CalculationContext context) {
        return calculateIn(context, inputArguments());
    }

    public abstract Object calculateIn(CalculationContext context, List<Object> arguments);

    public abstract Object returnTypeBlock(List<Object> arguments);
}
