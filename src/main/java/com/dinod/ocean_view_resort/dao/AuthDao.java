package com.dinod.ocean_view_resort.dao;

import com.dinod.ocean_view_resort.model.User;

public interface AuthDao {
    User findUserByUsernameAndPassword(String username, String password);
}
