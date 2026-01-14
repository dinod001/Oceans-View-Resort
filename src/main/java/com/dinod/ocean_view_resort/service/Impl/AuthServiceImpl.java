package com.dinod.ocean_view_resort.service.Impl;

import com.dinod.ocean_view_resort.dao.AuthDao;
import com.dinod.ocean_view_resort.dao.Impl.AuthDaoImpl;
import com.dinod.ocean_view_resort.model.User;
import com.dinod.ocean_view_resort.service.AuthService;

public class AuthServiceImpl implements AuthService {

    private AuthDao authDao;

    public AuthServiceImpl() {
        this.authDao = new AuthDaoImpl();
    }

    public AuthServiceImpl(AuthDao authDao) {
        this.authDao = authDao;
    }

    @Override
    public User authenticate(String username, String password) {
        return authDao.findUserByUsernameAndPassword(username, password);
    }
}
