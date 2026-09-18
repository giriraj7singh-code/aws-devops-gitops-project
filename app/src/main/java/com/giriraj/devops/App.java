package com.giriraj.devops;

import com.sun.net.httpserver.HttpExchange;
import com.sun.net.httpserver.HttpServer;

import java.io.IOException;
import java.io.OutputStream;
import java.net.InetSocketAddress;
import java.nio.charset.StandardCharsets;

public class App {

    public static void main(String[] args) throws Exception {
        int port = Integer.parseInt(
                System.getenv().getOrDefault("PORT", "8080")
        );

        HttpServer server = HttpServer.create(
                new InetSocketAddress("0.0.0.0", port), 0
        );

        server.createContext("/", exchange ->
                sendJson(exchange, 200,
                        "{\"message\":\"Giriraj DevOps API is running\"}")
        );

        server.createContext("/health", exchange ->
                sendJson(exchange, 200,
                        "{\"status\":\"UP\"}")
        );

        server.createContext("/api/info", exchange ->
                sendJson(exchange, 200, buildInfoResponse())
        );

        server.start();
        System.out.println("DevOps API started on port " + port);

        Thread.currentThread().join();
    }

    static String buildInfoResponse() {
        String environment = System.getenv()
                .getOrDefault("APP_ENV", "development");

        return "{\"application\":\"devops-api\","
                + "\"version\":\"1.0.0\","
                + "\"environment\":\"" + environment + "\"}";
    }

    private static void sendJson(
            HttpExchange exchange,
            int status,
            String response
    ) throws IOException {

        byte[] data = response.getBytes(StandardCharsets.UTF_8);

        exchange.getResponseHeaders()
                .set("Content-Type", "application/json");

        exchange.sendResponseHeaders(status, data.length);

        try (OutputStream output = exchange.getResponseBody()) {
            output.write(data);
        }
    }
}
