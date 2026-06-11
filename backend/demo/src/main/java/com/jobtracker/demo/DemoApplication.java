package com.jobtracker.demo;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class DemoApplication {

	public static void main(String[] args) {
		    System.out.println("========== DEBUG ==========");
    System.out.println("MONGODB_URI = " + System.getenv("MONGODB_URI"));
    System.out.println("===========================");

    SpringApplication.run(DemoApplication.class, args);

   
	}

}
