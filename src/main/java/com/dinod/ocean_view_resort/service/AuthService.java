package com.dinod.ocean_view_resort.service;

import com.dinod.ocean_view_resort.model.User;

public interface AuthService {
    User authenticate(String username, String password);
}
