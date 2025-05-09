package com.example.project;

import com.example.payment.service.PaymentService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.context.annotation.ComponentScans;

@SpringBootApplication
@ComponentScan(basePackages = {
        "com.example.project",
        "com.example.payment"
})
public class ProjectApplication implements CommandLineRunner {

    @Autowired
    private PaymentService paymentService;

    public static void main(String[] args) {
        SpringApplication.run(ProjectApplication.class, args);
    }

    @Override
    public void run(String... args) throws Exception {
        paymentService.testService();
    }
}
