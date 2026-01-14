package com.dinod.ocean_view_resort.service;

import com.dinod.ocean_view_resort.model.User;
import java.util.List;

public interface StaffService {
    boolean addStaff(User user, String designation);

    boolean updateStaff(User user, String designation);

    boolean deleteStaff(int userId);

    List<User> getAllStaff();

    User getStaffById(int userId);

    List<User> searchStaff(String query, String type);
}
