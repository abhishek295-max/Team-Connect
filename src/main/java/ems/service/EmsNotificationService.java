package ems.service;

import jakarta.mail.MessagingException; import jakarta.mail.internet.MimeMessage;
import org.springframework.beans.factory.ObjectProvider; import org.springframework.beans.factory.annotation.Value; import org.springframework.jdbc.core.JdbcTemplate; import org.springframework.mail.javamail.JavaMailSender; import org.springframework.mail.javamail.MimeMessageHelper; import org.springframework.stereotype.Service;

@Service
public class EmsNotificationService {
    private final JdbcTemplate jdbc; private final ObjectProvider<JavaMailSender> mail;
    @Value("${ems.mail.enabled:false}") private boolean mailEnabled; @Value("${ems.mail.from:no-reply@example.com}") private String from;
    public EmsNotificationService(JdbcTemplate j,ObjectProvider<JavaMailSender> m){jdbc=j;mail=m;}
    public void notifyUser(Integer userId,String title,String message){if(userId==null)return; jdbc.update("INSERT INTO admin_notifications(title,message,type,recipient_id,created_by) VALUES(?,?,?,?,?)",title,message,"EMS",userId,"EMS");}
    public void email(String address,String subject,String body){if(!mailEnabled||address==null||address.isBlank())return;java.util.List<String> setting=jdbc.queryForList("SELECT setting_value FROM system_settings WHERE setting_key = ?",String.class,"EMAIL_NOTIFICATIONS_ENABLED");if(!setting.isEmpty()&&!Boolean.parseBoolean(setting.get(0)))return;JavaMailSender sender=mail.getIfAvailable();if(sender==null)return;try{MimeMessage m=sender.createMimeMessage();MimeMessageHelper h=new MimeMessageHelper(m,"UTF-8");h.setFrom(from);h.setTo(address);h.setSubject(subject);h.setText(body,false);sender.send(m);}catch(MessagingException ignored){}}
}
