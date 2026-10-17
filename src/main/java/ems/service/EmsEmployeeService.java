package ems.service;

import ems.model.*; import ems.repository.*; import org.springframework.stereotype.Service; import org.springframework.transaction.annotation.Transactional;
import java.util.*;

@Service @Transactional
public class EmsEmployeeService {
    private final EmployeeRepository employees; private final DepartmentRepository departments; private final EmsAccessService access;
    public EmsEmployeeService(EmployeeRepository e,DepartmentRepository d,EmsAccessService a){employees=e;departments=d;access=a;}
    @Transactional(readOnly=true) public List<Employee> all(){return employees.findAllByOrderByNameAsc();}
    @Transactional(readOnly=true) public Employee one(Long id){return employees.findById(id).orElseThrow(()->new NoSuchElementException("Employee not found"));}
    public Employee save(Employee e,Long departmentId){if(departmentId!=null)e.setDepartment(departments.findById(departmentId).orElseThrow(()->new NoSuchElementException("Department not found"))); return employees.save(e);}
    public Employee update(Long id,Employee source,Long departmentId){Employee e=one(id); e.setName(source.getName());e.setEmail(source.getEmail());e.setPhone(source.getPhone());e.setGender(source.getGender());e.setJobTitle(source.getJobTitle());e.setHireDate(source.getHireDate());e.setSalary(source.getSalary());e.setAddress(source.getAddress());e.setRole(source.getRole());e.setStatus(source.getStatus());if(departmentId!=null)e.setDepartment(departments.findById(departmentId).orElseThrow());return employees.save(e);}
    public Employee status(Long id,String status){Employee e=one(id);e.setStatus(status);return employees.save(e);}
    public Employee createLinked(Integer userId,String name,String email,String role){Employee e=new Employee();e.setTeamConnectUserId(userId);e.setName(name);e.setEmail(email);e.setRole(role==null?"EMPLOYEE":role.toUpperCase());e.setStatus("ACTIVE");return employees.save(e);}
    public void syncAccount(Integer userId,String role,String status){employees.findByTeamConnectUserId(userId).ifPresent(e->{if(role!=null)e.setRole(role.toUpperCase());if(status!=null)e.setStatus(status.toUpperCase());employees.save(e);});}
}
