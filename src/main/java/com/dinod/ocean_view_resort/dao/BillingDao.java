package com.dinod.ocean_view_resort.dao;

import com.dinod.ocean_view_resort.model.Billing;

public interface BillingDao {

    void generateBill(int reservationNo);

    Billing getBillByReservationId(int reservationNo);

    boolean updateBillStatus(int reservationNo, String status);
}
