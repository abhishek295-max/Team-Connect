package ems.repository;
import ems.model.LeaveRequest; import org.springframework.data.jpa.repository.JpaRepository; import java.util.*;
public interface LeaveRequestRepository extends JpaRepository<LeaveRequest,Long>{List<LeaveRequest> findByEmployeeIdOrderByAppliedOnDesc(Long id); List<LeaveRequest> findAllByOrderByAppliedOnDesc();}
