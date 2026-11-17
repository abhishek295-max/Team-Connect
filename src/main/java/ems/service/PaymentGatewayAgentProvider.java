package ems.service;

import ems.model.Employee;

import java.util.List;

public interface PaymentGatewayAgentProvider {
    boolean hasPayoutAccount(Employee employee);

    List<PayoutMismatch> reconcile();

    record PayoutMismatch(
            Long employeeId,
            String employeeName,
            String payrollStatus,
            String gatewayStatus,
            String explanation) {
    }
}
