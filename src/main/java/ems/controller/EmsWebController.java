package ems.controller;

import ems.model.Employee; import ems.service.EmsAccessService; import model.User; import org.springframework.stereotype.Controller; import org.springframework.ui.Model; import org.springframework.web.bind.annotation.*; import service.UserService;
import jakarta.servlet.http.*;

@Controller
public class EmsWebController {
    private final UserService users; private final EmsAccessService access;
    public EmsWebController(UserService u,EmsAccessService a){users=u;access=a;}
    @GetMapping("/ems/login") public String loginPage(){return "views/ems-login";}
    @PostMapping("/ems/login") public String login(@RequestParam String username,@RequestParam String password,HttpServletRequest request,Model model){User user=users.authenticate(username,password);if(user==null){model.addAttribute("error","Invalid TeamConnect credentials.");return "views/ems-login";}if("ADMIN".equalsIgnoreCase(user.getRole())||"MODERATOR".equalsIgnoreCase(user.getRole()))return "redirect:/admin";HttpSession old=request.getSession(false);if(old!=null)old.invalidate();HttpSession s=request.getSession(true);s.setAttribute("userId",user.getId());s.setAttribute("username",user.getUsername());s.setAttribute("email",user.getEmail());try{Employee e=access.currentEmployee(request);return "redirect:/ems/"+e.getRole().toLowerCase();}catch(Exception ex){model.addAttribute("error","This TeamConnect account is not linked to an employee profile.");return "views/ems-login";}}
    @GetMapping("/ems") public String home(HttpServletRequest request){try{Employee e=access.currentEmployee(request);return "redirect:/ems/"+e.getRole().toLowerCase();}catch(Exception ignored){return "redirect:/ems/login";}}
    @GetMapping("/ems/admin") public String adminWorkspace(HttpServletRequest request){if(!access.admin(request))return "redirect:/admin";return "views/ems-admin";}
    @GetMapping("/ems/{role}") public String dashboard(@PathVariable String role,HttpServletRequest request,Model model){Employee e=access.currentEmployee(request);if(!role.equalsIgnoreCase(e.getRole())&&!access.admin(request))return "redirect:/ems/"+e.getRole().toLowerCase();model.addAttribute("employee",e);model.addAttribute("emsRole",e.getRole());return "views/ems-dashboard";}
}
