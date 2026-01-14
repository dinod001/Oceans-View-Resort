package com.dinod.ocean_view_resort.dao.Impl;

import com.dinod.ocean_view_resort.dao.BillingDao;
import com.dinod.ocean_view_resort.model.Billing;
import com.dinod.ocean_view_resort.utills.ConnectionProvider;
import com.dinod.ocean_view_resort.utills.DBConnection;

import java.sql.*;

public class BillingDaoImpl implements BillingDao {

    private ConnectionProvider connectionProvider;

    public BillingDaoImpl() {
        this.connectionProvider = DBConnection.getInstance();
    }

    public BillingDaoImpl(ConnectionProvider connectionProvider) {
        this.connectionProvider = connectionProvider;
    }

    @Override
    public void generateBill(int reservationNo) {
        try {
            Connection con = connectionProvider.createConnection();
            // Call the Stored Procedure
            String procedureCall = "{ call GenerateFinalBill(?) }";
            CallableStatement cs = con.prepareCall(procedureCall);
            cs.setInt(1, reservationNo);

            cs.execute();
            // No commit needed if auto-commit is on (default), otherwise con.commit();
            // cs.close(); handled by try-with-resources if we used it, otherwise explicitly
            // generic block
            cs.close();

        } catch (SQLException e) {
            e.printStackTrace();
            // In a real app we might rethrow or log
        }
    }

    @Override
    public Billing getBillByReservationId(int reservationNo) {
        try {
            Connection con = connectionProvider.createConnection();
            String query = "SELECT * FROM billings WHERE res_no = ?";
            PreparedStatement ps = con.prepareStatement(query);
            ps.setInt(1, reservationNo);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                Billing bill = new Billing();
                bill.setBillID(rs.getInt("bill_id"));
                bill.setResNo(rs.getInt("res_no"));
                bill.setTotalAmount(rs.getDouble("total_amount"));
                bill.setTax(rs.getDouble("tax"));
                return bill;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }
}
