package com.alight.util;

import org.apache.commons.lang3.StringUtils;

public class HelloWorldUtil {
    String greeting;

    public HelloWorldUtil(String message) {
        message = StringUtils.prependIfMissing(message, "Hello, ");
        message = StringUtils.appendIfMissing(message, "!");
        this.greeting = message;
    }

    @Override
    public String toString() {
        return greeting;
    }
}
