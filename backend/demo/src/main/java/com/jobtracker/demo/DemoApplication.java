package com.jobtracker.demo;

import jakarta.annotation.PostConstruct;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.env.Environment;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class DemoApplication {

    @Autowired
    private Environment env;

    @PostConstruct
    public void debug() {
        System.out.println("================================");
        System.out.println("ENV MONGODB_URI = " + System.getenv("MONGODB_URI"));
        System.out.println("SPRING URI = " + env.getProperty("spring.data.mongodb.uri"));
        System.out.println("================================");
    }

    public static void main(String[] args) {
        SpringApplication.run(DemoApplication.class, args);
    }
}