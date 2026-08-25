package com.alight.journal.smalltalk.model;

import java.math.RoundingMode;
import java.util.List;
import java.util.Map;
import java.util.TreeMap;

public final class HAProrationPolicyConstants {

    private static final Map<String, RoundingMode> POLICIES = new TreeMap<>(String.CASE_INSENSITIVE_ORDER);

    static {
        POLICIES.put("ACTUAL_DAYS", RoundingMode.HALF_UP);
        POLICIES.put("ACTUAL_DAYS_DOWN", RoundingMode.DOWN);
        POLICIES.put("ACTUAL_DAYS_UP", RoundingMode.UP);
    }

    private HAProrationPolicyConstants() {
    }

    public static List<String> keys() {
        return List.copyOf(POLICIES.keySet());
    }

    public static ProrationPolicy at(String key) {
        String lookupKey = key == null ? "ACTUAL_DAYS" : key;
        RoundingMode roundingMode = POLICIES.get(lookupKey);
        if (roundingMode == null) {
            throw new IllegalArgumentException("Unsupported proration policy: " + key);
        }
        return new ProrationPolicy(lookupKey, roundingMode, 8, 8);
    }
}
