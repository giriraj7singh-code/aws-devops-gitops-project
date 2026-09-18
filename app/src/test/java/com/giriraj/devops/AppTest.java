package com.giriraj.devops;

import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertTrue;

class AppTest {

    @Test
    void infoResponseContainsApplicationDetails() {
        String response = App.buildInfoResponse();

        assertTrue(response.contains("\"application\":\"devops-api\""));
        assertTrue(response.contains("\"version\":\"1.0.0\""));
        assertTrue(response.contains("\"environment\":"));
    }
}
