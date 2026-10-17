package ems.repository;
import ems.model.SalaryRecord; import org.springframework.data.jpa.repository.JpaRepository; import java.util.List;
public interface SalaryRecordRepository extends JpaRepository<SalaryRecord,Long>{List<SalaryRecord> findByEmployeeIdOrderByPaymentDateDesc(Long id);}
