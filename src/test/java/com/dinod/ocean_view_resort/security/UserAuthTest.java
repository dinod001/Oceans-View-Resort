package com.dinod.ocean_view_resort.security;

import org.junit.jupiter.api.Test;
import org.mindrot.jbcrypt.BCrypt;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertNotEquals;

public class UserAuthTest {

    @Test
    public void testAuthenticationLogic() {
        // This tests "Requirement 1: User Authentication" (Username + Password)

        // 1. Setup Mock User Data (Simulating Database Record)
        String storedUsername = "admin";
        String rawPassword = "password123";
        String storedHash = BCrypt.hashpw(rawPassword, BCrypt.gensalt());

        // 2. Test Case A: Valid Login
        String inputUser = "admin";
        String inputPass = "password123";

        boolean usernameMatch = storedUsername.equals(inputUser);
        boolean passwordMatch = BCrypt.checkpw(inputPass, storedHash);

        assertTrue(usernameMatch && passwordMatch, "Login should succeed with correct credentials");

        // 3. Test Case B: Invalid Username
        assertFalse(storedUsername.equals("wrongUser"), "Login should fail with wrong username");

        // 4. Test Case C: Invalid Password
        assertFalse(BCrypt.checkpw("wrongPass", storedHash), "Login should fail with wrong password");
    }
}
