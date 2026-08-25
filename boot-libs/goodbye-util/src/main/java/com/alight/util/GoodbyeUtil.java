package com.alight.util;

import org.apache.commons.lang3.StringUtils;

public class GoodbyeUtil {
    String greeting;

    public GoodbyeUtil(String message) {
        message = StringUtils.prependIfMissing(message, "Goodbye, ");
        message = StringUtils.appendIfMissing(message, ".");
        this.greeting = message;
    }

    @Override
    public String toString() {
        return greeting;
    }
}
