package com.dinod.ocean_view_resort.service.Impl;

import com.dinod.ocean_view_resort.dao.StaffDao;
import com.dinod.ocean_view_resort.dao.Impl.StaffDaoImpl;
import com.dinod.ocean_view_resort.model.User;
import com.dinod.ocean_view_resort.service.StaffService;
import java.util.List;

public class StaffServiceImpl implements StaffService {
    private StaffDao staffDao;

    public StaffServiceImpl() {
        this.staffDao = new StaffDaoImpl();
    }

    public StaffServiceImpl(StaffDao staffDao) {
        this.staffDao = staffDao;
    }

    @Override
    public boolean addStaff(User user, String designation) {
        validateStaffData(user, true);
        return staffDao.addStaff(user, designation);
    }

    @Override
    public boolean updateStaff(User user, String designation) {
        validateStaffData(user, false);
        return staffDao.updateStaff(user, designation);
    }

    @Override
    public boolean deleteStaff(int userId) {
        return staffDao.deleteStaff(userId);
    }

    @Override
    public List<User> getAllStaff() {
        return staffDao.getAllStaff();
    }

    @Override
    public User getStaffById(int userId) {
        return staffDao.getStaffById(userId);
    }

    @Override
    public List<User> searchStaff(String query, String type) {
        if (query == null || query.trim().isEmpty()) {
            return staffDao.getAllStaff();
        }

        switch (type != null ? type.toLowerCase() : "") {
            case "email":
                return staffDao.searchStaffByEmail(query);
            case "contact":
                return staffDao.searchStaffByContact(query);
            case "name":
            default:
                return staffDao.searchStaffByName(query);
        }
    }

    private void validateStaffData(User user, boolean isNew) {
        if (user.getUserName() == null || user.getUserName().trim().isEmpty()) {
            throw new IllegalArgumentException("Username is required!");
        }
        if (user.getEmail() == null || user.getEmail().trim().isEmpty()) {
            throw new IllegalArgumentException("Email is required!");
        }
        if (user.getRole() == null || user.getRole().trim().isEmpty()) {
            throw new IllegalArgumentException("Role must be specified (Admin or Staff)!");
        }

        if (isNew) {
            if (user.getPassword() == null || user.getPassword().trim().isEmpty()) {
                throw new IllegalArgumentException("Password is required for new registration!");
            }
            if (staffDao.isUsernameExists(user.getUserName())) {
                throw new IllegalArgumentException("Username '" + user.getUserName() + "' is already taken!");
            }
            if (staffDao.isEmailExists(user.getEmail())) {
                throw new IllegalArgumentException("Email '" + user.getEmail() + "' is already registered!");
            }
        } else {
            // For updates, we should check if email changed and if new email belongs to
            // another user
            User existing = staffDao.getStaffById(user.getId());
            if (existing != null && !existing.getEmail().equalsIgnoreCase(user.getEmail())) {
                if (staffDao.isEmailExists(user.getEmail())) {
                    throw new IllegalArgumentException(
                            "Email '" + user.getEmail() + "' is already registered to another user!");
                }
            }
        }
    }
}
