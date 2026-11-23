# ---------- Build Stage ----------
FROM maven:3.9.9-eclipse-temurin-17 AS builder

WORKDIR /app

COPY pom.xml .
RUN mvn dependency:go-offline

COPY . .

RUN mvn clean package -DskipTests

# ---------- Runtime Stage ----------
FROM eclipse-temurin:17-jre

WORKDIR /app
COPY --from=builder /app/target/Online_Chat_App.war /app/team-connect.war

EXPOSE 10000

CMD ["sh", "-c", "exec java ${JAVA_OPTS:-} -jar /app/team-connect.war"]
