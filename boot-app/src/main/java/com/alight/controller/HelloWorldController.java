package com.alight.controller;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import com.alight.util.HelloWorldUtil;
import com.alight.util.GoodbyeUtil;

@RestController
public class HelloWorldController {

    @Value("${app.base.config:undefined}")
    private String externalBaseConfig;

    @Value("${app.service.config:undefined}")
    private String externalServiceConfig;

    @GetMapping("/helloworld")
    public String helloWorld() {
        HelloWorldUtil greeting = new HelloWorldUtil("World");
        return String.format(
                "<html><body><h1>%s</h1><br>External Config: %s</br></body></html>",
                greeting, externalBaseConfig);
    }

    @GetMapping("/goodbye")
    public String goodbye() {
        GoodbyeUtil farewell = new GoodbyeUtil("World");
        return String.format("<html><body><h1>%s</h1><br>External Config: %s</br></body></html>",
                farewell, externalServiceConfig);
    }
}
