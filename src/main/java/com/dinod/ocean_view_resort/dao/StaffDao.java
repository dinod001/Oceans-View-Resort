package com.dinod.ocean_view_resort.dao;

import com.dinod.ocean_view_resort.model.User;
import java.util.List;

public interface StaffDao {
    boolean addStaff(User user, String designation);

    boolean updateStaff(User user, String designation);

    boolean deleteStaff(int userId);

    List<User> getAllStaff();

    User getStaffById(int userId);

    List<User> searchStaffByName(String name);

    List<User> searchStaffByEmail(String email);

    List<User> searchStaffByContact(String contact);

    boolean isUsernameExists(String username);

    boolean isEmailExists(String email);
}
