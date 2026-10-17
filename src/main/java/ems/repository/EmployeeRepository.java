package ems.repository;
import ems.model.Employee; import org.springframework.data.jpa.repository.JpaRepository; import java.util.*;
public interface EmployeeRepository extends JpaRepository<Employee,Long>{Optional<Employee> findByTeamConnectUserId(Integer id); Optional<Employee> findByEmsEmployeeId(Long id); Optional<Employee> findByEmailIgnoreCase(String email); List<Employee> findAllByOrderByNameAsc();}
