package com.alight.util;

import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertTrue;

public class GoodbyeUtilTest {

    @Test
    public void testLib() throws Exception {
        assertTrue(new GoodbyeUtil("World").toString().contains("Goodbye, World."));
    }
}
