package ems.service;

import ems.model.Employee;
import ems.repository.EmployeeRepository;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

@Service
public class EmsAccessService {
    private final EmployeeRepository employees;
    public EmsAccessService(EmployeeRepository employees){this.employees=employees;}
    public Integer userId(HttpServletRequest request){
        HttpSession s=request.getSession(false); Object id=s==null?null:s.getAttribute("userId");
        if(id==null) throw new ResponseStatusException(HttpStatus.UNAUTHORIZED,"Please log in again.");
        return Integer.valueOf(String.valueOf(id));
    }
    public boolean admin(HttpServletRequest request){HttpSession s=request.getSession(false); return s!=null && Boolean.TRUE.equals(s.getAttribute("adminAuthenticated"));}
    public Employee currentEmployee(HttpServletRequest request){
        Integer id=userId(request); return employees.findByTeamConnectUserId(id).orElseThrow(()->new ResponseStatusException(HttpStatus.FORBIDDEN,"No employee profile is linked to this account."));
    }
    public Employee requireEmployee(HttpServletRequest request, Long employeeId){
        if(admin(request)) return employees.findById(employeeId).orElseThrow(()->new ResponseStatusException(HttpStatus.NOT_FOUND,"Employee not found."));
        Employee current=currentEmployee(request);
        if(hasRole(current,"HR") || hasRole(current,"MANAGER")) return employees.findById(employeeId).orElseThrow(()->new ResponseStatusException(HttpStatus.NOT_FOUND,"Employee not found."));
        if(!current.getId().equals(employeeId)) throw new ResponseStatusException(HttpStatus.FORBIDDEN,"You can access only your own employee data.");
        return current;
    }
    public void requireAdmin(HttpServletRequest request){if(!admin(request)) throw new ResponseStatusException(HttpStatus.FORBIDDEN,"Administrator access required.");}
    public void requireHrOrAdmin(HttpServletRequest request){if(admin(request))return; Employee e=currentEmployee(request); if(!hasRole(e,"HR")) throw new ResponseStatusException(HttpStatus.FORBIDDEN,"HR or administrator access required.");}
    public boolean hasRole(Employee e,String role){return e!=null&&role.equalsIgnoreCase(e.getRole());}
}
