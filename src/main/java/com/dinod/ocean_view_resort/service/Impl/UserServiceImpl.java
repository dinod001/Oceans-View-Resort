package com.dinod.ocean_view_resort.service.Impl;

import com.dinod.ocean_view_resort.dao.Impl.UserDaoImpl;
import com.dinod.ocean_view_resort.dao.UserDao;
import com.dinod.ocean_view_resort.model.User;
import com.dinod.ocean_view_resort.service.UserService;

public class UserServiceImpl implements UserService {

    private UserDao userDao;

    public UserServiceImpl() {
        this.userDao = new UserDaoImpl();
    }

    public UserServiceImpl(UserDao userDao) {
        this.userDao = userDao;
    }

    @Override
    public boolean validateCredentials(User user) {
        if (user.getUserName() == null || user.getUserName().trim().isEmpty()) {
            throw new IllegalArgumentException("Username cannot be empty!");
        }
        if (user.getPassword() == null || user.getPassword().trim().isEmpty()) {
            throw new IllegalArgumentException("Password cannot be empty!");
        }

        if (userDao.isUserExists(user.getUserName())) {
            throw new IllegalArgumentException("User already registered with this name!");
        }

        return userDao.saveUser(user);
    }

    @Override
    public User authenticate(String username, String password) {
        return userDao.findUserByUsernameAndPassword(username, password);
    }
}
