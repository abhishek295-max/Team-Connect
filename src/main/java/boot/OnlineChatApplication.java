package boot;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.autoconfigure.domain.EntityScan;
import org.springframework.data.jpa.repository.config.EnableJpaRepositories;

/** Spring Boot entry point. Existing servlets, filters, and listeners remain the web layer. */
@SpringBootApplication(scanBasePackages = {"boot", "controller", "filter", "util", "dao", "model", "service", "repository", "config", "chat"})
@EntityScan(basePackages = "model")
@EnableJpaRepositories(basePackages = "repository")
public class OnlineChatApplication {
    public static void main(String[] args) {
        SpringApplication.run(OnlineChatApplication.class, args);
    }
}
