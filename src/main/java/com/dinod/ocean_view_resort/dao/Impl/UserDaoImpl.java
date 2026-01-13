package com.dinod.ocean_view_resort.dao.Impl;

import com.dinod.ocean_view_resort.dao.UserDao;
import com.dinod.ocean_view_resort.model.User;
import com.dinod.ocean_view_resort.utills.ConnectionProvider;
import com.dinod.ocean_view_resort.utills.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class UserDaoImpl implements UserDao {

    private ConnectionProvider connectionProvider;

    public UserDaoImpl() {
        this.connectionProvider = DBConnection.getInstance();
    }

    public UserDaoImpl(ConnectionProvider connectionProvider) {
        this.connectionProvider = connectionProvider;
    }

    @Override
    public boolean isUserExists(String userName) {
        try {
            Connection con = connectionProvider.createConnection();
            String query = "SELECT username FROM users WHERE username = ?";
            PreparedStatement ps = con.prepareStatement(query);
            ps.setString(1, userName);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                return true;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    @Override
    public boolean saveUser(User user) {
        Connection con = null;
        try {
            con = connectionProvider.createConnection();
            // Start Transaction
            con.setAutoCommit(false);

            String query = "INSERT INTO users (username, password, role) VALUES (?, ?, ?)";
            // Request generated keys
            PreparedStatement ps = con.prepareStatement(query, PreparedStatement.RETURN_GENERATED_KEYS);
            ps.setString(1, user.getUserName());
            ps.setString(2, user.getPassword());
            ps.setString(3, user.getRole());

            int result = ps.executeUpdate();

            if (result > 0) {
                // Get the generated User ID
                ResultSet rs = ps.getGeneratedKeys();
                if (rs.next()) {
                    int userId = rs.getInt(1);

                    // Insert into specific role table
                    boolean roleInsertSuccess = false;
                    if ("Staff".equalsIgnoreCase(user.getRole())) {
                        String staffQuery = "INSERT INTO staff (staff_id, designation) VALUES (?, 'General Staff')";
                        PreparedStatement staffPs = con.prepareStatement(staffQuery);
                        staffPs.setInt(1, userId);
                        roleInsertSuccess = staffPs.executeUpdate() > 0;
                        staffPs.close();
                    } else if ("Admin".equalsIgnoreCase(user.getRole())) {
                        String adminQuery = "INSERT INTO admins (admin_id) VALUES (?)";
                        PreparedStatement adminPs = con.prepareStatement(adminQuery);
                        adminPs.setInt(1, userId);
                        roleInsertSuccess = adminPs.executeUpdate() > 0;
                        adminPs.close();
                    }

                    if (roleInsertSuccess) {
                        con.commit();
                        return true;
                    }
                }
            }
            // If we get here, something failed
            con.rollback();
        } catch (SQLException e) {
            e.printStackTrace();
            if (con != null) {
                try {
                    con.rollback();
                } catch (SQLException ex) {
                    ex.printStackTrace();
                }
            }
        } finally {
            if (con != null) {
                try {
                    con.setAutoCommit(true);
                    con.close();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
        }
        return false;
    }

    @Override
    public User findUserByUsernameAndPassword(String username, String password) {
        try {
            Connection con = connectionProvider.createConnection();
            String query = "SELECT * FROM users WHERE username = ? AND password = ?";
            PreparedStatement ps = con.prepareStatement(query);
            ps.setString(1, username);
            ps.setString(2, password);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                User user = new User();
                user.setId(rs.getInt("user_id"));
                user.setUserName(rs.getString("username"));
                user.setRole(rs.getString("role"));
                // We typically don't set password in returned object for security, but keeping
                // it simple for now
                return user;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }
}
