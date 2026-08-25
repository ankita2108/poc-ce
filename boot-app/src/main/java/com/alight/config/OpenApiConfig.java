package com.alight.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Info;

@Configuration
public class OpenApiConfig {

    @Bean
    public OpenAPI templateOpenApi() {
        return new OpenAPI()
                .info(new Info()
                        .title("Calculator Modernization APIs")
                        .description("Swagger UI for Journal calculator endpoints")
                        .version("v1"));
    }
}
