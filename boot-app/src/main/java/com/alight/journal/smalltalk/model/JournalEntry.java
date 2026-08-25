package com.alight.journal.smalltalk.model;

import java.math.BigDecimal;
import java.math.RoundingMode;

import com.alight.journal.smalltalk.StoredObject;

public class JournalEntry extends StoredObject {

    private Object key;
    private Object value;

    public JournalEntry() {
    }

    public JournalEntry(Object key, Object value) {
        this.key = key;
        this.value = value;
    }

    public Object getKey() {
        return key;
    }

    public void setKey(Object key) {
        this.key = key;
    }

    public Object getEntryValue() {
        return value;
    }

    public void setEntryValue(Object value) {
        this.value = value;
    }

    public BigDecimal numericValue() {
        if (value instanceof BigDecimal)
            return (BigDecimal) value;
        if (value instanceof Number)
            return BigDecimal.valueOf(((Number) value).doubleValue());
        if (value instanceof String)
            return stringToValue((String) value);
        return BigDecimal.ZERO;
    }

    public BigDecimal stringToValue(String str) {
        if (str == null || str.isBlank())
            return null;
        try {
            return new BigDecimal(str.trim());
        } catch (NumberFormatException e) {
            return null;
        }
    }

    public JournalEntry add(JournalEntry other) {
        BigDecimal result = numericValue().add(other.numericValue());
        return new JournalEntry(key, result);
    }

    public JournalEntry subtract(JournalEntry other) {
        BigDecimal result = numericValue().subtract(other.numericValue());
        return new JournalEntry(key, result);
    }

    public JournalEntry multiply(BigDecimal factor) {
        BigDecimal result = numericValue().multiply(factor);
        return new JournalEntry(key, result);
    }

    public JournalEntry divide(BigDecimal divisor) {
        BigDecimal result = numericValue().divide(divisor, 13, RoundingMode.HALF_UP);
        return new JournalEntry(key, result);
    }

    public JournalEntry copy() {
        return new JournalEntry(key, value);
    }

    public JournalEntry deepCopy() {
        return copy();
    }

    public boolean isValid() {
        return key != null && value != null;
    }

    public boolean isKey(Object otherKey) {
        if (key == null)
            return otherKey == null;
        return key.equals(otherKey);
    }

    public boolean isValue(Object otherValue) {
        if (value == null)
            return otherValue == null;
        return value.equals(otherValue);
    }
}
