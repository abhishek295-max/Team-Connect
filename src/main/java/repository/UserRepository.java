package repository;

import dao.UserDAO;
import model.User;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public class UserRepository {

    private final UserDAO dao = new UserDAO();

    public User findById(int id) {
        return dao.findById(id);
    }

    public List<User> findContacts(int userId) {
        return dao.findContacts(userId);
    }

    public User authenticate(String username, String password) {
        return dao.authenticate(username, password);
    }

    public UserDAO.RegistrationResult register(String username, String email, String password) {
        return dao.registerUser(username, email, password);
    }

    public boolean delete(int userId) {
        return dao.deleteAccount(userId);
    }
}
