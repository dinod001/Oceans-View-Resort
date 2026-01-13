package com.dinod.ocean_view_resort.utills;

import java.sql.Connection;
import java.sql.SQLException;

public interface ConnectionProvider {

    Connection createConnection() throws SQLException;
}
