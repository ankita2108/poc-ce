package com.alight;

import static org.hamcrest.Matchers.containsString;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.content;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.redirectedUrl;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.web.servlet.MockMvc;

@SpringBootTest
@AutoConfigureMockMvc
public class TemplateServerTest {

    @Autowired
    private MockMvc mockMvc;

    @Test
    public void homeShouldReturnDefaultMessage() throws Exception {
        this.mockMvc.perform(get("/")).andExpect(status().is3xxRedirection())
                .andExpect(redirectedUrl("/index.html"));
    }

    @Test
    public void helloworldShouldReturnDefaultMessage() throws Exception {
        this.mockMvc.perform(get("/helloworld")).andExpect(status().isOk())
                .andExpect(content().string(containsString("Hello")));
    }

    @Test
    public void goodbyeShouldReturnDefaultMessage() throws Exception {
        this.mockMvc.perform(get("/goodbye")).andExpect(status().isOk())
                .andExpect(content().string(containsString("Goodbye")));
    }
}
