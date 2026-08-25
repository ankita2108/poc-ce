package com.alight.journal.smalltalk.model;

import java.math.BigDecimal;
import java.math.RoundingMode;

public class ProrationPolicy {

    private final String name;
    private final RoundingMode roundingMode;
    private final int multiplierDecimals;
    private final int resultDecimals;

    public ProrationPolicy(String name, RoundingMode roundingMode, int multiplierDecimals, int resultDecimals) {
        this.name = name;
        this.roundingMode = roundingMode;
        this.multiplierDecimals = multiplierDecimals;
        this.resultDecimals = resultDecimals;
    }

    public String getName() {
        return name;
    }

    public int getMultiplierDecimals() {
        return multiplierDecimals;
    }

    public int getResultDecimals() {
        return resultDecimals;
    }

    public ProrationPolicy multiplierDecimals(Integer decimals) {
        return new ProrationPolicy(name, roundingMode, decimals == null ? multiplierDecimals : decimals, resultDecimals);
    }

    public ProrationPolicy resultDecimals(Integer decimals) {
        return new ProrationPolicy(name, roundingMode, multiplierDecimals, decimals == null ? resultDecimals : decimals);
    }

    public BigDecimal multiplier(long overlapDays, long totalDays) {
        if (totalDays <= 0L) {
            return BigDecimal.ZERO;
        }
        return BigDecimal.valueOf(overlapDays)
                .divide(BigDecimal.valueOf(totalDays), multiplierDecimals, roundingMode);
    }

    public BigDecimal prorate(BigDecimal amount, long overlapDays, long totalDays) {
        return amount.multiply(multiplier(overlapDays, totalDays)).setScale(resultDecimals, roundingMode);
    }
}
