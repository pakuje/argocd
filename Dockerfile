# Use Maven image to build the application
FROM maven:3.6.3-jdk-11 AS build
WORKDIR /app
COPY pom.xml .
COPY src ./src
RUN mvn clean package

# Use OpenJDK image to run the application
FROM openjdk:11-jre-slim
COPY --from=build /app/target/*.jar /usr/app/app.jar
EXPOSE 80
ENTRYPOINT ["java", "-jar", "/usr/app/app.jar"]
