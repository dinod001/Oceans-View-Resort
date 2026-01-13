package com.dinod.ocean_view_resort.utills;

import java.io.IOException;
import java.io.InputStream;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.Properties;

public class DBConnection implements ConnectionProvider {
    private Connection connection = null;
    private static final Properties dbProperties = loadProperties();

    // Singleton instance for static access
    private static final DBConnection INSTANCE = new DBConnection();

    // Load configuration from properties file
    private static Properties loadProperties() {
        Properties props = new Properties();
        try (InputStream input = DBConnection.class.getClassLoader()
                .getResourceAsStream("db.properties")) {
            if (input == null) {
                System.err.println("Unable to find db.properties, using defaults");
                // Fallback to defaults
                props.setProperty("db.url", "jdbc:mysql://localhost:3306/ocean_view_resort_db");
                props.setProperty("db.user", "root");
                props.setProperty("db.password", "1234");
                props.setProperty("db.driver", "com.mysql.cj.jdbc.Driver");
                return props;
            }
            props.load(input);
        } catch (IOException e) {
            e.printStackTrace();
            throw new RuntimeException("Failed to load database configuration", e);
        }
        return props;
    }

    // Prevent direct instantiation (use getInstance() or static methods)
    private DBConnection() {
    }

    /**
     * Static method for backward compatibility.
     * Delegates to the singleton instance.
     */
    public static Connection getConnection() throws SQLException, ClassNotFoundException {
        return INSTANCE.createConnection();
    }

    public static DBConnection getInstance() {
        return INSTANCE;
    }

    @Override
    public Connection createConnection() throws SQLException {
        try {
            if (connection == null || connection.isClosed()) {
                String driver = dbProperties.getProperty("db.driver");
                String url = dbProperties.getProperty("db.url");
                String user = dbProperties.getProperty("db.user");
                String password = dbProperties.getProperty("db.password");

                Class.forName(driver);
                connection = DriverManager.getConnection(url, user, password);
            }
            return connection;
        } catch (ClassNotFoundException e) {
            throw new SQLException("Database driver not found", e);
        }
    }
}
