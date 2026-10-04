package repository;

import model.User;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface JpaUserRepository extends JpaRepository<User, Integer> {

    Optional<User> findByUsername(String username);
}
