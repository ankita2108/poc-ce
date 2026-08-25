package com.alight;

import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;

@SpringBootTest
public class SmokeTest {

    @Test
    public void startFromMain() throws Exception {
        TemplateApplication.main(new String[] { "--server.port=0" });
    }
}
