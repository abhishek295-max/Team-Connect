package boot;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.builder.SpringApplicationBuilder;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.autoconfigure.domain.EntityScan;
import org.springframework.boot.web.servlet.support.SpringBootServletInitializer;
import org.springframework.data.jpa.repository.config.EnableJpaRepositories;
import org.springframework.scheduling.annotation.EnableScheduling;

/** Spring Boot entry point. Existing servlets, filters, and listeners remain the web layer. */
@SpringBootApplication(scanBasePackages = {"boot", "controller", "filter", "util", "dao", "model", "service", "repository", "config", "chat", "ems"})
@EntityScan(basePackages = {"model", "ems.model"})
@EnableJpaRepositories(basePackages = {"repository", "ems.repository"})
@EnableScheduling
public class OnlineChatApplication extends SpringBootServletInitializer {

    @Override
    protected SpringApplicationBuilder configure(SpringApplicationBuilder application) {
        return application.sources(OnlineChatApplication.class);
    }

    public static void main(String[] args) {
        SpringApplication.run(OnlineChatApplication.class, args);
    }
}
