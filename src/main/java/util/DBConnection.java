package util;

import java.sql.Connection;
import java.sql.DriverManager;

public class DBConnection {

    private static final String URL = System.getProperty(
            "app.database.url",
            System.getenv().getOrDefault(
                    "DB_URL",
                    "jdbc:mysql://localhost:3306/online_chat_app?useSSL=false&serverTimezone=UTC"
            )
    );

    private static final String USER = System.getProperty(
            "app.database.username",
            System.getenv().getOrDefault("DB_USERNAME", "root")
    );

    private static final String PASSWORD = System.getProperty(
            "app.database.password",
            System.getenv().getOrDefault("DB_PASSWORD", "")
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
