package com.dinod.ocean_view_resort.dao;

import com.dinod.ocean_view_resort.model.User;

public interface UserDao {
    boolean isUserExists(String userName);

    boolean saveUser(User user);

    User findUserByUsernameAndPassword(String username, String password);
}
