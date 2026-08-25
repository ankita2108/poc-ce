package com.alight.journal.smalltalk.model;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.function.Function;
import java.util.function.Predicate;
import java.util.stream.Collectors;

import com.alight.journal.smalltalk.StoredObject;

public class Journal extends StoredObject {

    private List<PeriodJournalEntry> entries = new ArrayList<>();
    private boolean isNamed;

    public Journal() {
    }

    public Journal(List<PeriodJournalEntry> entries) {
        this.entries = entries != null ? new ArrayList<>(entries) : new ArrayList<>();
    }

    public List<PeriodJournalEntry> getEntries() {
        return entries;
    }

    public void setEntries(List<PeriodJournalEntry> entries) {
        this.entries = entries != null ? new ArrayList<>(entries) : new ArrayList<>();
    }

    public boolean isNamed() {
        return isNamed;
    }

    public void setNamed(boolean named) {
        this.isNamed = named;
    }

    // --- Collection behavior ---

    public void add(PeriodJournalEntry entry) {
        entries.add(entry);
    }

    public void addAll(List<PeriodJournalEntry> newEntries) {
        entries.addAll(newEntries);
    }

    public void remove(PeriodJournalEntry entry) {
        entries.remove(entry);
    }

    public int size() {
        return entries.size();
    }

    public boolean isEmpty() {
        return entries.isEmpty();
    }

    public PeriodJournalEntry firstEntry() {
        return entries.isEmpty() ? null : entries.get(0);
    }

    public PeriodJournalEntry lastEntry() {
        return entries.isEmpty() ? null : entries.get(entries.size() - 1);
    }

    public List<Object> keys() {
        return entries.stream()
                .map(e -> (Object) e.getStartDate())
                .collect(Collectors.toList());
    }

    public List<BigDecimal> values() {
        return entries.stream()
                .map(PeriodJournalEntry::getAmount)
                .collect(Collectors.toList());
    }

    // --- Functional transforms ---

    public Journal collect(Function<PeriodJournalEntry, PeriodJournalEntry> mapper) {
        List<PeriodJournalEntry> result = entries.stream()
                .map(mapper)
                .collect(Collectors.toList());
        return new Journal(result);
    }

    public Journal reject(Predicate<PeriodJournalEntry> predicate) {
        List<PeriodJournalEntry> result = entries.stream()
                .filter(predicate.negate())
                .collect(Collectors.toList());
        return new Journal(result);
    }

    public Journal select(Predicate<PeriodJournalEntry> predicate) {
        List<PeriodJournalEntry> result = entries.stream()
                .filter(predicate)
                .collect(Collectors.toList());
        return new Journal(result);
    }

    public Journal negated() {
        List<PeriodJournalEntry> result = entries.stream()
                .map(PeriodJournalEntry::negated)
                .collect(Collectors.toList());
        return new Journal(result);
    }

    public Journal multiplyNumber(BigDecimal number) {
        List<PeriodJournalEntry> result = entries.stream()
                .map(e -> e.multiplyNumber(number))
                .collect(Collectors.toList());
        return new Journal(result);
    }

    public Journal divideNumber(BigDecimal number) {
        List<PeriodJournalEntry> result = entries.stream()
                .map(e -> e.divideNumber(number))
                .collect(Collectors.toList());
        return new Journal(result);
    }

    // --- Statistics ---

    public BigDecimal sum() {
        return entries.stream()
                .map(PeriodJournalEntry::getAmount)
                .filter(a -> a != null)
                .reduce(BigDecimal.ZERO, BigDecimal::add);
    }

    public BigDecimal average() {
        List<BigDecimal> amounts = entries.stream()
                .map(PeriodJournalEntry::getAmount)
                .filter(a -> a != null)
                .collect(Collectors.toList());
        if (amounts.isEmpty())
            return BigDecimal.ZERO;
        BigDecimal total = amounts.stream().reduce(BigDecimal.ZERO, BigDecimal::add);
        return total.divide(BigDecimal.valueOf(amounts.size()), 13, RoundingMode.HALF_UP);
    }

    public BigDecimal max() {
        return entries.stream()
                .map(PeriodJournalEntry::getAmount)
                .filter(a -> a != null)
                .max(BigDecimal::compareTo)
                .orElse(BigDecimal.ZERO);
    }

    public BigDecimal min() {
        return entries.stream()
                .map(PeriodJournalEntry::getAmount)
                .filter(a -> a != null)
                .min(BigDecimal::compareTo)
                .orElse(BigDecimal.ZERO);
    }

    public long occurrencesOf(BigDecimal value) {
        return entries.stream()
                .map(PeriodJournalEntry::getAmount)
                .filter(a -> a != null && a.compareTo(value) == 0)
                .count();
    }

    public BigDecimal mostOccurrences() {
        Map<BigDecimal, Long> freq = entries.stream()
                .map(PeriodJournalEntry::getAmount)
                .filter(a -> a != null)
                .collect(Collectors.groupingBy(a -> a, Collectors.counting()));
        return freq.entrySet().stream()
                .max(Map.Entry.comparingByValue())
                .map(Map.Entry::getKey)
                .orElse(BigDecimal.ZERO);
    }

    // --- Window analytics ---

    public Journal asLastConsecutive(int count) {
        if (entries.size() <= count)
            return new Journal(new ArrayList<>(entries));
        return new Journal(entries.subList(entries.size() - count, entries.size()));
    }

    public Journal asHighestConsecutive(int count) {
        if (entries.size() <= count)
            return new Journal(new ArrayList<>(entries));
        BigDecimal highestSum = null;
        int bestIndex = 0;
        for (int i = 0; i <= entries.size() - count; i++) {
            BigDecimal windowSum = BigDecimal.ZERO;
            for (int j = i; j < i + count; j++) {
                BigDecimal amt = entries.get(j).getAmount();
                if (amt != null)
                    windowSum = windowSum.add(amt);
            }
            if (highestSum == null || windowSum.compareTo(highestSum) > 0) {
                highestSum = windowSum;
                bestIndex = i;
            }
        }
        return new Journal(entries.subList(bestIndex, bestIndex + count));
    }

    public Journal asHighestNonConsecutive(int count) {
        List<PeriodJournalEntry> sorted = new ArrayList<>(entries);
        sorted.sort((a, b) -> {
            BigDecimal av = a.getAmount() != null ? a.getAmount() : BigDecimal.ZERO;
            BigDecimal bv = b.getAmount() != null ? b.getAmount() : BigDecimal.ZERO;
            return bv.compareTo(av);
        });
        int limit = Math.min(count, sorted.size());
        return new Journal(sorted.subList(0, limit));
    }

    public Journal asSecondHighestConsecutive(int count) {
        if (entries.size() <= count)
            return new Journal(new ArrayList<>(entries));
        BigDecimal highestSum = null;
        BigDecimal secondSum = null;
        int secondIndex = 0;
        int bestIndex = 0;
        for (int i = 0; i <= entries.size() - count; i++) {
            BigDecimal windowSum = BigDecimal.ZERO;
            for (int j = i; j < i + count; j++) {
                BigDecimal amt = entries.get(j).getAmount();
                if (amt != null)
                    windowSum = windowSum.add(amt);
            }
            if (highestSum == null || windowSum.compareTo(highestSum) > 0) {
                secondSum = highestSum;
                secondIndex = bestIndex;
                highestSum = windowSum;
                bestIndex = i;
            } else if (secondSum == null || windowSum.compareTo(secondSum) > 0) {
                secondSum = windowSum;
                secondIndex = i;
            }
        }
        return new Journal(entries.subList(secondIndex, secondIndex + count));
    }

    // --- Duplicate resolution ---

    public boolean hasDuplicateEntries() {
        for (int i = 0; i < entries.size() - 1; i++) {
            for (int j = i + 1; j < entries.size(); j++) {
                if (entries.get(i).getStartDate().equals(entries.get(j).getStartDate()) &&
                        entries.get(i).getEndDate().equals(entries.get(j).getEndDate())) {
                    return true;
                }
            }
        }
        return false;
    }

    public Journal resolveDuplicates(DuplicateResolutionPolicy policy) {
        switch (policy) {
            case ADD:
                return addDuplicateEntries();
            case MERGE:
                return mergeDuplicateEntries();
            case HIGHEST:
                return highestOfDuplicateEntries();
            case LOWEST:
                return lowestOfDuplicateEntries();
            case FIRST:
                return firstOfDuplicateEntries();
            case LAST:
                return lastOfDuplicateEntries();
            default:
                return new Journal(new ArrayList<>(entries));
        }
    }

    private Journal addDuplicateEntries() {
        Map<String, PeriodJournalEntry> grouped = new LinkedHashMap<>();
        for (PeriodJournalEntry entry : entries) {
            String key = entry.getStartDate() + "|" + entry.getEndDate();
            PeriodJournalEntry existing = grouped.get(key);
            if (existing != null) {
                BigDecimal sum = (existing.getAmount() != null ? existing.getAmount() : BigDecimal.ZERO)
                        .add(entry.getAmount() != null ? entry.getAmount() : BigDecimal.ZERO);
                grouped.put(key, new PeriodJournalEntry(existing.getStartDate(), existing.getEndDate(), sum,
                        existing.getValue()));
            } else {
                grouped.put(key, entry.copy());
            }
        }
        return new Journal(new ArrayList<>(grouped.values()));
    }

    private Journal mergeDuplicateEntries() {
        List<PeriodJournalEntry> result = new ArrayList<>();
        PeriodJournalEntry prev = null;
        for (PeriodJournalEntry entry : entries) {
            if (prev == null) {
                prev = entry.copy();
            } else if (prev.getStartDate().equals(entry.getStartDate())
                    && prev.getEndDate().equals(entry.getEndDate())) {
                BigDecimal sum = (prev.getAmount() != null ? prev.getAmount() : BigDecimal.ZERO)
                        .add(entry.getAmount() != null ? entry.getAmount() : BigDecimal.ZERO);
                prev = new PeriodJournalEntry(prev.getStartDate(), prev.getEndDate(), sum, prev.getValue());
            } else {
                result.add(prev);
                prev = entry.copy();
            }
        }
        if (prev != null)
            result.add(prev);
        return new Journal(result);
    }

    private Journal highestOfDuplicateEntries() {
        Map<String, PeriodJournalEntry> grouped = new LinkedHashMap<>();
        for (PeriodJournalEntry entry : entries) {
            String key = entry.getStartDate() + "|" + entry.getEndDate();
            PeriodJournalEntry existing = grouped.get(key);
            if (existing == null || (entry.getAmount() != null && existing.getAmount() != null
                    && entry.getAmount().compareTo(existing.getAmount()) > 0)) {
                grouped.put(key, entry.copy());
            }
        }
        return new Journal(new ArrayList<>(grouped.values()));
    }

    private Journal lowestOfDuplicateEntries() {
        Map<String, PeriodJournalEntry> grouped = new LinkedHashMap<>();
        for (PeriodJournalEntry entry : entries) {
            String key = entry.getStartDate() + "|" + entry.getEndDate();
            PeriodJournalEntry existing = grouped.get(key);
            if (existing == null || (entry.getAmount() != null && existing.getAmount() != null
                    && entry.getAmount().compareTo(existing.getAmount()) < 0)) {
                grouped.put(key, entry.copy());
            }
        }
        return new Journal(new ArrayList<>(grouped.values()));
    }

    private Journal firstOfDuplicateEntries() {
        Map<String, PeriodJournalEntry> grouped = new LinkedHashMap<>();
        for (PeriodJournalEntry entry : entries) {
            String key = entry.getStartDate() + "|" + entry.getEndDate();
            grouped.putIfAbsent(key, entry.copy());
        }
        return new Journal(new ArrayList<>(grouped.values()));
    }

    private Journal lastOfDuplicateEntries() {
        Map<String, PeriodJournalEntry> grouped = new LinkedHashMap<>();
        for (PeriodJournalEntry entry : entries) {
            String key = entry.getStartDate() + "|" + entry.getEndDate();
            grouped.put(key, entry.copy());
        }
        return new Journal(new ArrayList<>(grouped.values()));
    }

    // --- Copy ---

    public Journal copyWithEntries(List<PeriodJournalEntry> newEntries) {
        return new Journal(newEntries);
    }

    public Journal emptyCopy() {
        return new Journal(new ArrayList<>());
    }
}
