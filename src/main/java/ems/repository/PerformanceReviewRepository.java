package ems.repository;
import ems.model.PerformanceReview; import org.springframework.data.jpa.repository.JpaRepository; import java.util.List;
public interface PerformanceReviewRepository extends JpaRepository<PerformanceReview,Long>{List<PerformanceReview> findByEmployeeIdOrderByReviewDateDesc(Long id);}
