package service;

import dao.UserDAO;
import model.User;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;
import repository.JpaUserRepository;
import repository.UserRepository;

import java.util.List;

@Service
public class UserService {

    private final UserRepository repository;
    private final JpaUserRepository jpaRepository;
    private final BCryptPasswordEncoder passwordEncoder = new BCryptPasswordEncoder();

    public UserService(UserRepository repository, JpaUserRepository jpaRepository) {
        this.repository = repository;
        this.jpaRepository = jpaRepository;
    }

    public User authenticate(String username, String password) {
        if (username == null || username.isBlank() || password == null || password.isBlank()) {
            return null;
        }

        User user = jpaRepository.findByUsername(username.trim()).orElse(null);
        if (user == null || "DISABLED".equalsIgnoreCase(user.getStatus())
                || "SUSPENDED".equalsIgnoreCase(user.getStatus())) {
            return null;
        }

        String storedPassword = user.getPassword();
        boolean matches = storedPassword != null && (storedPassword.equals(password)
                || (storedPassword.startsWith("$2") && passwordEncoder.matches(password, storedPassword)));
        if (!matches) {
            return null;
        }

        if (!storedPassword.startsWith("$2")) {
            user.setPassword(passwordEncoder.encode(password));
            jpaRepository.save(user);
        }
        return user;
    }

    public User find(int id) {
        return jpaRepository.findById(id).orElse(null);
    }

    public List<User> contacts(int userId) {
        return repository.findContacts(userId);
    }

    public UserDAO.RegistrationResult register(String username, String email, String password) {
        return repository.register(username, email, password);
    }

    public boolean delete(int userId) {
        return repository.delete(userId);
    }
}
