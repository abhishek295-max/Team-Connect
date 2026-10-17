package ems.repository;
import ems.model.Attendance; import org.springframework.data.jpa.repository.JpaRepository; import java.time.LocalDate; import java.util.*;
public interface AttendanceRepository extends JpaRepository<Attendance,Long>{List<Attendance> findByEmployeeIdOrderByDateDesc(Long id); Optional<Attendance> findByEmployeeIdAndDate(Long id, LocalDate date);}
