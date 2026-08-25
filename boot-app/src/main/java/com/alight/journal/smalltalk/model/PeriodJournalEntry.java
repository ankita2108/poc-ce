package com.alight.journal.smalltalk.model;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.time.Period;
import java.time.YearMonth;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.List;

public class PeriodJournalEntry {

    private LocalDate startDate;
    private LocalDate endDate;
    private BigDecimal amount;
    private String value;

    public PeriodJournalEntry() {
    }

    public PeriodJournalEntry(LocalDate startDate, LocalDate endDate, BigDecimal amount, String value) {
        this.startDate = startDate;
        this.endDate = endDate;
        this.amount = amount;
        this.value = value;
    }

    public LocalDate getStartDate() {
        return startDate;
    }

    public void setStartDate(LocalDate startDate) {
        this.startDate = startDate;
    }

    public LocalDate getEndDate() {
        return endDate;
    }

    public void setEndDate(LocalDate endDate) {
        this.endDate = endDate;
    }

    public BigDecimal getAmount() {
        return amount;
    }

    public void setAmount(BigDecimal amount) {
        this.amount = amount;
    }

    public String getValue() {
        return value;
    }

    public void setValue(String value) {
        this.value = value;
    }

    public PeriodJournalEntry copy() {
        return new PeriodJournalEntry(startDate, endDate, amount, value);
    }

    public boolean isIntersecting(PeriodJournalEntry other) {
        return !startDate.isAfter(other.endDate) && !endDate.isBefore(other.startDate);
    }

    public PeriodJournalEntry mergeWith(PeriodJournalEntry other) {
        LocalDate mergedStart = startDate.isBefore(other.startDate) ? startDate : other.startDate;
        LocalDate mergedEnd = endDate.isAfter(other.endDate) ? endDate : other.endDate;
        return new PeriodJournalEntry(mergedStart, mergedEnd, amount, value);
    }

    public PeriodJournalEntry intersectionWith(PeriodJournalEntry other, ProrationPolicy prorationPolicy) {
        if (!isIntersecting(other)) {
            return null;
        }
        LocalDate intersectionStart = startDate.isAfter(other.startDate) ? startDate : other.startDate;
        LocalDate intersectionEnd = endDate.isBefore(other.endDate) ? endDate : other.endDate;
        BigDecimal proratedAmount = amount;
        if (amount != null && prorationPolicy != null) {
            proratedAmount = prorationPolicy.prorate(amount, inclusiveDays(intersectionStart, intersectionEnd),
                    inclusiveDays());
        }
        return new PeriodJournalEntry(intersectionStart, intersectionEnd, proratedAmount, value);
    }

    public PeriodJournalEntry divideNumber(BigDecimal number) {
        BigDecimal dividedAmount = null;
        if (amount != null) {
            dividedAmount = amount.divide(number, 13, RoundingMode.HALF_UP);
        }
        return new PeriodJournalEntry(startDate, endDate, dividedAmount, value);
    }

    public PeriodJournalEntry multiplyNumber(BigDecimal number) {
        BigDecimal result = amount != null ? amount.multiply(number) : null;
        return new PeriodJournalEntry(startDate, endDate, result, value);
    }

    public PeriodJournalEntry addValue(BigDecimal val) {
        BigDecimal result = amount != null ? amount.add(val) : val;
        return new PeriodJournalEntry(startDate, endDate, result, value);
    }

    public PeriodJournalEntry subtractValue(BigDecimal val) {
        BigDecimal result = amount != null ? amount.subtract(val) : val != null ? val.negate() : null;
        return new PeriodJournalEntry(startDate, endDate, result, value);
    }

    public PeriodJournalEntry negated() {
        BigDecimal neg = amount != null ? amount.negate() : null;
        return new PeriodJournalEntry(startDate, endDate, neg, value);
    }

    // --- Period splitting ---

    public List<PeriodJournalEntry> asCalendarMonths() {
        List<PeriodJournalEntry> result = new ArrayList<>();
        LocalDate current = startDate;
        while (!current.isAfter(endDate)) {
            YearMonth ym = YearMonth.from(current);
            LocalDate monthEnd = ym.atEndOfMonth();
            LocalDate segEnd = monthEnd.isBefore(endDate) ? monthEnd : endDate;
            result.add(proratedEntry(current, segEnd));
            current = segEnd.plusDays(1);
        }
        return result;
    }

    public List<PeriodJournalEntry> asCalendarYears() {
        List<PeriodJournalEntry> result = new ArrayList<>();
        LocalDate current = startDate;
        while (!current.isAfter(endDate)) {
            LocalDate yearEnd = LocalDate.of(current.getYear(), 12, 31);
            LocalDate segEnd = yearEnd.isBefore(endDate) ? yearEnd : endDate;
            result.add(proratedEntry(current, segEnd));
            current = segEnd.plusDays(1);
        }
        return result;
    }

    public List<PeriodJournalEntry> asAnniversaryYears(LocalDate anniversaryDate) {
        List<PeriodJournalEntry> result = new ArrayList<>();
        LocalDate current = startDate;
        while (!current.isAfter(endDate)) {
            LocalDate annivInYear = anniversaryDate.withYear(current.getYear());
            if (annivInYear.isBefore(current) || annivInYear.equals(current)) {
                annivInYear = annivInYear.plusYears(1);
            }
            LocalDate segEnd = annivInYear.minusDays(1);
            if (segEnd.isAfter(endDate))
                segEnd = endDate;
            result.add(proratedEntry(current, segEnd));
            current = segEnd.plusDays(1);
        }
        return result;
    }

    public List<PeriodJournalEntry> asQuarters(LocalDate quarterStart) {
        List<PeriodJournalEntry> result = new ArrayList<>();
        LocalDate current = startDate;
        while (!current.isAfter(endDate)) {
            LocalDate qEnd = current.plusMonths(3).withDayOfMonth(1).minusDays(1);
            LocalDate segEnd = qEnd.isBefore(endDate) ? qEnd : endDate;
            result.add(proratedEntry(current, segEnd));
            current = segEnd.plusDays(1);
        }
        return result;
    }

    public List<PeriodJournalEntry> asSemiMonths(int dayOfMonth) {
        List<PeriodJournalEntry> result = new ArrayList<>();
        LocalDate current = startDate;
        while (!current.isAfter(endDate)) {
            LocalDate segEnd;
            if (current.getDayOfMonth() <= dayOfMonth) {
                segEnd = current.withDayOfMonth(Math.min(dayOfMonth, current.lengthOfMonth()));
            } else {
                segEnd = YearMonth.from(current).atEndOfMonth();
            }
            if (segEnd.isAfter(endDate))
                segEnd = endDate;
            if (segEnd.isBefore(current))
                segEnd = current;
            result.add(proratedEntry(current, segEnd));
            current = segEnd.plusDays(1);
        }
        return result;
    }

    public List<PeriodJournalEntry> asBiWeekly(LocalDate referenceDate) {
        List<PeriodJournalEntry> result = new ArrayList<>();
        LocalDate current = startDate;
        while (!current.isAfter(endDate)) {
            LocalDate segEnd = current.plusDays(13);
            if (segEnd.isAfter(endDate))
                segEnd = endDate;
            result.add(proratedEntry(current, segEnd));
            current = segEnd.plusDays(1);
        }
        return result;
    }

    // --- Combination ---

    public PeriodJournalEntry combine(PeriodJournalEntry other) {
        LocalDate combinedStart = startDate.isBefore(other.startDate) ? startDate : other.startDate;
        LocalDate combinedEnd = endDate.isAfter(other.endDate) ? endDate : other.endDate;
        BigDecimal combinedAmount = null;
        if (amount != null && other.amount != null) {
            combinedAmount = amount.add(other.amount);
        } else if (amount != null) {
            combinedAmount = amount;
        } else {
            combinedAmount = other.amount;
        }
        return new PeriodJournalEntry(combinedStart, combinedEnd, combinedAmount, value);
    }

    public PeriodJournalEntry combineIfContiguous(PeriodJournalEntry other) {
        if (isContiguousWith(other)) {
            return combine(other);
        }
        return null;
    }

    // --- Non-intersection (period subtraction) ---

    public List<PeriodJournalEntry> nonIntersect(PeriodJournalEntry mask) {
        List<PeriodJournalEntry> result = new ArrayList<>();
        if (!isIntersecting(mask)) {
            result.add(copy());
            return result;
        }
        if (startDate.isBefore(mask.startDate)) {
            result.add(proratedEntry(startDate, mask.startDate.minusDays(1)));
        }
        if (endDate.isAfter(mask.endDate)) {
            result.add(proratedEntry(mask.endDate.plusDays(1), endDate));
        }
        return result;
    }

    // --- Contiguity predicates ---

    public boolean isContiguousWith(PeriodJournalEntry other) {
        return endDate.plusDays(1).equals(other.startDate) ||
                other.endDate.plusDays(1).equals(startDate);
    }

    public boolean isSameMonthAndYear(PeriodJournalEntry other) {
        return startDate.getMonth() == other.startDate.getMonth() &&
                startDate.getYear() == other.startDate.getYear();
    }

    public boolean isSameAnniversary(PeriodJournalEntry other, LocalDate anniversaryDate) {
        int year1 = anniversaryYear(startDate, anniversaryDate);
        int year2 = anniversaryYear(other.startDate, anniversaryDate);
        return year1 == year2;
    }

    public boolean isSameQuarter(PeriodJournalEntry other, LocalDate quarterStart) {
        int q1 = (startDate.getMonthValue() - 1) / 3;
        int q2 = (other.startDate.getMonthValue() - 1) / 3;
        return q1 == q2 && startDate.getYear() == other.startDate.getYear();
    }

    // --- Date/period metrics ---

    public long days() {
        return inclusiveDays();
    }

    public long months() {
        return ChronoUnit.MONTHS.between(startDate, endDate.plusDays(1));
    }

    public double years() {
        return (double) inclusiveDays() / 365.25;
    }

    public long completeMonths() {
        Period p = Period.between(startDate, endDate.plusDays(1));
        return p.getYears() * 12L + p.getMonths();
    }

    public long completeYears(LocalDate anniversaryDate) {
        return ChronoUnit.YEARS.between(startDate, endDate.plusDays(1));
    }

    public long inclusiveDays() {
        return inclusiveDays(startDate, endDate);
    }

    public static long inclusiveDays(LocalDate startDate, LocalDate endDate) {
        return ChronoUnit.DAYS.between(startDate, endDate) + 1L;
    }

    // --- Value evaluation ---

    public BigDecimal valueOver(PeriodJournalEntry period) {
        if (!isIntersecting(period))
            return BigDecimal.ZERO;
        if (amount == null)
            return BigDecimal.ZERO;
        LocalDate overlapStart = startDate.isAfter(period.startDate) ? startDate : period.startDate;
        LocalDate overlapEnd = endDate.isBefore(period.endDate) ? endDate : period.endDate;
        long overlapDays = inclusiveDays(overlapStart, overlapEnd);
        long totalDays = inclusiveDays();
        if (totalDays == overlapDays)
            return amount;
        return amount.multiply(BigDecimal.valueOf(overlapDays))
                .divide(BigDecimal.valueOf(totalDays), 13, RoundingMode.HALF_UP);
    }

    // --- Comparison ---

    public int compareTo(PeriodJournalEntry other) {
        int cmp = startDate.compareTo(other.startDate);
        if (cmp != 0)
            return cmp;
        cmp = endDate.compareTo(other.endDate);
        if (cmp != 0)
            return cmp;
        if (amount != null && other.amount != null)
            return amount.compareTo(other.amount);
        return 0;
    }

    // --- Helpers ---

    private PeriodJournalEntry proratedEntry(LocalDate segStart, LocalDate segEnd) {
        if (amount == null)
            return new PeriodJournalEntry(segStart, segEnd, null, value);
        long segDays = inclusiveDays(segStart, segEnd);
        long totalDays = inclusiveDays();
        if (totalDays == segDays)
            return new PeriodJournalEntry(segStart, segEnd, amount, value);
        BigDecimal prorated = amount.multiply(BigDecimal.valueOf(segDays))
                .divide(BigDecimal.valueOf(totalDays), 13, RoundingMode.HALF_UP);
        return new PeriodJournalEntry(segStart, segEnd, prorated, value);
    }

    private int anniversaryYear(LocalDate date, LocalDate anniversary) {
        LocalDate annivInYear = anniversary.withYear(date.getYear());
        if (date.isBefore(annivInYear))
            return date.getYear() - 1;
        return date.getYear();
    }
}
