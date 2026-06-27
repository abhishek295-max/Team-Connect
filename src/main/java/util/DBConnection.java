package util;

import java.util.*;
import java.sql.*;

public class DBConnection {

    private static final String URL = "jdbc:mysql://reseau.proxy.rlwy.net:12340/railway";
    private static final String USER = "root";
    private static final String PASSWORD = "EIUvWRSqpLimyCmbCucfxsyhWefirfdD";

    public static Connection getConnection() {

        try {

            Class.forName("com.mysql.cj.jdbc.Driver");

            return DriverManager.getConnection(
                    URL, USER, PASSWORD);

        } catch(Exception e) {
            e.printStackTrace();
        }

        return null;
    }
}