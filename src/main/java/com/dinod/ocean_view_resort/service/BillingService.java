package com.dinod.ocean_view_resort.service;

import com.dinod.ocean_view_resort.model.Billing;

public interface BillingService {

    Billing generateBill(int reservationNo);

    Billing getBillByReservationId(int reservationNo);

    boolean cancelBillByReservationNo(int reservationNo);
}
