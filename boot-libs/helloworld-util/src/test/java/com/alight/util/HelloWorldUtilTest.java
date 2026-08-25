package com.alight.util;

import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertTrue;

public class HelloWorldUtilTest {

    @Test
    public void testLib() throws Exception {
        assertTrue(new HelloWorldUtil("World").toString().contains("Hello, World!"));
    }
}
