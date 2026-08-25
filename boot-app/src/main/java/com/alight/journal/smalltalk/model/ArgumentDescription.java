package com.alight.journal.smalltalk.model;

import java.util.List;

public class ArgumentDescription {

    private final String name;
    private final String dataType;
    private final Object defaultValue;
    private final List<?> validValues;
    private final String explanation;
    private final boolean required;

    public ArgumentDescription(String name, String dataType, Object defaultValue, List<?> validValues,
            String explanation, boolean required) {
        this.name = name;
        this.dataType = dataType;
        this.defaultValue = defaultValue;
        this.validValues = validValues;
        this.explanation = explanation;
        this.required = required;
    }

    public String getName() {
        return name;
    }

    public String getDataType() {
        return dataType;
    }

    public Object getDefaultValue() {
        return defaultValue;
    }

    public List<?> getValidValues() {
        return validValues;
    }

    public String getExplanation() {
        return explanation;
    }

    public boolean isRequired() {
        return required;
    }
}
