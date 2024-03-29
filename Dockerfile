# 1. 베이스 이미지 캐싱 활용(추가)
FROM openjdk:11-jre-slim AS base

# Use Maven image to build the application(기존)
FROM maven:3.6.3-jdk-11 AS build
WORKDIR /app
COPY pom.xml .

# 2. 이전 레이어 캐싱(추가)
RUN mvn dependency:go-offline

# 이전 레이어 캐싱 활용(기존)
COPY src ./src
RUN mvn clean package

# Use OpenJDK image to run the application(추가)
FROM openjdk:11-jre-slim
COPY --from=build /app/target/*.jar /usr/app/app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "/usr/app/app.jar"]
