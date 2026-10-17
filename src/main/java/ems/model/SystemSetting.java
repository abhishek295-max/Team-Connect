package ems.model;
import jakarta.persistence.*;
@Entity @Table(name="system_settings") public class SystemSetting { @Id @Column(name="setting_key") private String key; @Column(name="setting_value",nullable=false) private String value; public SystemSetting(){} public SystemSetting(String k,String v){key=k;value=v;} public String getKey(){return key;} public String getValue(){return value;} public void setValue(String v){value=v;} }
