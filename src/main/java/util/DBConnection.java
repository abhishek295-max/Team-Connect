package util;

import java.sql.Connection;
import java.sql.DriverManager;

public class DBConnection {

    private static final String DEFAULT_URL =
            "jdbc:mysql://localhost:3306/online_chat_app?createDatabaseIfNotExist=true&useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC";
    private static final String DEFAULT_USER = "root";
    private static final String DEFAULT_PASSWORD = "";

    private static final String URL = System.getProperty(
            "app.database.url",
            System.getenv().getOrDefault("DB_URL", DEFAULT_URL)
    );

    private static final String USER = System.getProperty(
            "app.database.username",
            System.getenv().getOrDefault("DB_USERNAME", DEFAULT_USER)
    );

    private static final String PASSWORD = System.getProperty(
            "app.database.password",
            System.getenv().getOrDefault("DB_PASSWORD", DEFAULT_PASSWORD)
    );

    public static Connection getConnection() {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            return DriverManager.getConnection(URL, USER, PASSWORD);
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }
}
