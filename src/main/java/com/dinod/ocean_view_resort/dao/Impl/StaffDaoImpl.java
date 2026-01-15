package com.dinod.ocean_view_resort.dao.Impl;

import com.dinod.ocean_view_resort.dao.StaffDao;
import com.dinod.ocean_view_resort.model.User;
import com.dinod.ocean_view_resort.model.Staff;
import com.dinod.ocean_view_resort.utills.ConnectionProvider;
import com.dinod.ocean_view_resort.utills.DBConnection;
import org.mindrot.jbcrypt.BCrypt;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class StaffDaoImpl implements StaffDao {
    private ConnectionProvider connectionProvider;

    public StaffDaoImpl() {
        this.connectionProvider = DBConnection.getInstance();
    }

    @Override
    public boolean addStaff(User user, String designation) {
        String userQuery = "INSERT INTO users (username, email, password, contact_no, address, role) VALUES (?, ?, ?, ?, ?, ?)";
        Connection con = null;
        try {
            con = connectionProvider.createConnection();
            con.setAutoCommit(false);

            try (PreparedStatement ps = con.prepareStatement(userQuery, Statement.RETURN_GENERATED_KEYS)) {
                ps.setString(1, user.getUserName());
                ps.setString(2, user.getEmail());
                String hashedPassword = BCrypt.hashpw(user.getPassword(), BCrypt.gensalt());
                ps.setString(3, hashedPassword);
                ps.setString(4, user.getContactNo());
                ps.setString(5, user.getAddress());
                ps.setString(6, user.getRole());

                int affected = ps.executeUpdate();
                if (affected > 0) {
                    try (ResultSet rs = ps.getGeneratedKeys()) {
                        if (rs.next()) {
                            int userId = rs.getInt(1);
                            boolean roleSuccess = false;

                            if ("Staff".equalsIgnoreCase(user.getRole())) {
                                String staffQuery = "INSERT INTO staff (staff_id, designation) VALUES (?, ?)";
                                try (PreparedStatement psStaff = con.prepareStatement(staffQuery)) {
                                    psStaff.setInt(1, userId);
                                    psStaff.setString(2, designation != null ? designation : "General Staff");
                                    roleSuccess = psStaff.executeUpdate() > 0;
                                }
                            } else if ("Admin".equalsIgnoreCase(user.getRole())) {
                                String adminQuery = "INSERT INTO admins (admin_id) VALUES (?)";
                                try (PreparedStatement psAdmin = con.prepareStatement(adminQuery)) {
                                    psAdmin.setInt(1, userId);
                                    roleSuccess = psAdmin.executeUpdate() > 0;
                                }
                            }

                            if (roleSuccess) {
                                con.commit();
                                return true;
                            }
                        }
                    }
                }
                con.rollback();
            }
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
    public boolean updateStaff(User user, String designation) {
        boolean hasPassword = user.getPassword() != null && !user.getPassword().trim().isEmpty();
        String userQuery = hasPassword
                ? "UPDATE users SET email = ?, contact_no = ?, address = ?, role = ?, password = ? WHERE user_id = ?"
                : "UPDATE users SET email = ?, contact_no = ?, address = ?, role = ? WHERE user_id = ?";

        Connection con = null;
        try {
            con = connectionProvider.createConnection();
            con.setAutoCommit(false);

            try (PreparedStatement ps = con.prepareStatement(userQuery)) {
                ps.setString(1, user.getEmail());
                ps.setString(2, user.getContactNo());
                ps.setString(3, user.getAddress());
                ps.setString(4, user.getRole());

                if (hasPassword) {
                    String hashedPassword = BCrypt.hashpw(user.getPassword(), BCrypt.gensalt());
                    ps.setString(5, hashedPassword);
                    ps.setInt(6, user.getId());
                } else {
                    ps.setInt(5, user.getId());
                }

                int affected = ps.executeUpdate();
                if (affected > 0) {
                    boolean roleSuccess = false;
                    // We might need to handle role changes here (delete from old, insert to new)
                    // But for simplicity in Staff Management, we'll assume role stays same or
                    // handles designation update
                    if ("Staff".equalsIgnoreCase(user.getRole())) {
                        String staffQuery = "UPDATE staff SET designation = ? WHERE staff_id = ?";
                        try (PreparedStatement psStaff = con.prepareStatement(staffQuery)) {
                            psStaff.setString(1, designation);
                            psStaff.setInt(2, user.getId());
                            psStaff.executeUpdate(); // Might be 0 if changing from Admin to Staff
                            roleSuccess = true;
                        }
                    } else {
                        roleSuccess = true; // Admin has no extra fields to update
                    }

                    if (roleSuccess) {
                        con.commit();
                        return true;
                    }
                }
                con.rollback();
            }
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
    public boolean deleteStaff(int userId) {
        String query = "DELETE FROM users WHERE user_id = ?";
        try (Connection con = connectionProvider.createConnection();
                PreparedStatement ps = con.prepareStatement(query)) {
            ps.setInt(1, userId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    @Override
    public List<User> getAllStaff() {
        List<User> staffList = new ArrayList<>();
        String query = "SELECT u.*, s.designation FROM users u " +
                "LEFT JOIN staff s ON u.user_id = s.staff_id " +
                "WHERE u.role IN ('Staff', 'Admin')";
        try (Connection con = connectionProvider.createConnection();
                PreparedStatement ps = con.prepareStatement(query);
                ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                staffList.add(mapResultSetToUser(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return staffList;
    }

    @Override
    public User getStaffById(int userId) {
        String query = "SELECT u.*, s.designation FROM users u " +
                "LEFT JOIN staff s ON u.user_id = s.staff_id " +
                "WHERE u.user_id = ?";
        try (Connection con = connectionProvider.createConnection();
                PreparedStatement ps = con.prepareStatement(query)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToUser(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    @Override
    public List<User> searchStaffByName(String name) {
        return searchUsers("username", name);
    }

    @Override
    public List<User> searchStaffByEmail(String email) {
        return searchUsers("email", email);
    }

    @Override
    public List<User> searchStaffByContact(String contact) {
        return searchUsers("contact_no", contact);
    }

    private List<User> searchUsers(String field, String value) {
        List<User> list = new ArrayList<>();
        String query = "SELECT u.*, s.designation FROM users u " +
                "LEFT JOIN staff s ON u.user_id = s.staff_id " +
                "WHERE u.role IN ('Staff', 'Admin') AND u." + field + " LIKE ?";
        try (Connection con = connectionProvider.createConnection();
                PreparedStatement ps = con.prepareStatement(query)) {
            ps.setString(1, "%" + value + "%");
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSetToUser(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    @Override
    public boolean isUsernameExists(String username) {
        String query = "SELECT 1 FROM users WHERE username = ?";
        try (Connection con = connectionProvider.createConnection();
                PreparedStatement ps = con.prepareStatement(query)) {
            ps.setString(1, username);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    @Override
    public boolean isEmailExists(String email) {
        String query = "SELECT 1 FROM users WHERE email = ?";
        try (Connection con = connectionProvider.createConnection();
                PreparedStatement ps = con.prepareStatement(query)) {
            ps.setString(1, email);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    private User mapResultSetToUser(ResultSet rs) throws SQLException {
        String role = rs.getString("role");
        User user;
        if ("Staff".equalsIgnoreCase(role)) {
            Staff s = new Staff();
            s.setDesignation(rs.getString("designation"));
            user = s;
        } else {
            user = new User();
        }
        user.setId(rs.getInt("user_id"));
        user.setUserName(rs.getString("username"));
        user.setEmail(rs.getString("email"));
        user.setRole(role);
        user.setContactNo(rs.getString("contact_no"));
        user.setAddress(rs.getString("address"));
        return user;
    }
}
