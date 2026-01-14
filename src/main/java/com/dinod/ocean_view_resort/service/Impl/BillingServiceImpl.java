package com.dinod.ocean_view_resort.service.Impl;

import com.dinod.ocean_view_resort.dao.BillingDao;
import com.dinod.ocean_view_resort.dao.Impl.BillingDaoImpl;
import com.dinod.ocean_view_resort.model.Billing;
import com.dinod.ocean_view_resort.service.BillingService;

public class BillingServiceImpl implements BillingService {

    private BillingDao billingDao;

    public BillingServiceImpl() {
        this.billingDao = new BillingDaoImpl();
    }

    public BillingServiceImpl(BillingDao billingDao) {
        this.billingDao = billingDao;
    }

    @Override
    public Billing generateBill(int reservationNo) {
        // 1. Call DAO to execute stored procedure
        billingDao.generateBill(reservationNo);

        // 2. Fetch the newly generated bill to return it
        return billingDao.getBillByReservationId(reservationNo);
    }

    @Override
    public Billing getBillByReservationId(int reservationNo) {
        return billingDao.getBillByReservationId(reservationNo);
    }
}
