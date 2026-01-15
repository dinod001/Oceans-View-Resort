package com.dinod.ocean_view_resort.dao.Impl;

import com.dinod.ocean_view_resort.dao.AuthDao;
import com.dinod.ocean_view_resort.model.User;
import com.dinod.ocean_view_resort.utills.ConnectionProvider;
import com.dinod.ocean_view_resort.utills.DBConnection;

import org.mindrot.jbcrypt.BCrypt;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class AuthDaoImpl implements AuthDao {

    private ConnectionProvider connectionProvider;

    public AuthDaoImpl() {
        this.connectionProvider = DBConnection.getInstance();
    }

    public AuthDaoImpl(ConnectionProvider connectionProvider) {
        this.connectionProvider = connectionProvider;
    }

    @Override
    public User findUserByUsernameAndPassword(String username, String password) {
        try (Connection con = connectionProvider.createConnection()) {
            String query = "SELECT * FROM users WHERE username = ?";
            PreparedStatement ps = con.prepareStatement(query);
            ps.setString(1, username);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                String storedPassword = rs.getString("password");

                boolean isValid = false;
                // Check if it's a BCrypt hash
                if (storedPassword != null && storedPassword.startsWith("$2a$")) {
                    isValid = BCrypt.checkpw(password, storedPassword);
                } else {
                    // Fallback for plain-text passwords during migration
                    isValid = password.equals(storedPassword);
                }

                if (isValid) {
                    User user = new User();
                    user.setId(rs.getInt("user_id"));
                    user.setUserName(rs.getString("username"));
                    user.setRole(rs.getString("role"));
                    return user;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }
}
