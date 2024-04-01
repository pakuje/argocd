# 1. 베이스 이미지 캐싱 활용(추가)
# base라는 이름의 레이어를 생성
FROM openjdk:11-jre-slim AS base

# 2. Use Maven image to build the application(기존)
FROM maven:3.6.3-jdk-11 AS build
# 작업 디렉토리를 /app으로 설정
WORKDIR /app
# 현재 디렉토리의 pom.xml 파일을 build 레이어의 /app 디렉토리에 복사
COPY pom.xml .

# 3. 이전 레이어 캐싱(추가)
# Maven을 사용하여 프로젝트의 모든 종속성을 다운로드하고 오프라인 모드로 캐싱
# Maven Offline 모드를 통해 이후 레이어에서 다시 종속성을 다운로드할 필요 없이 캐시된 종속성을 사용
RUN mvn dependency:go-offline

# 4. 이전 레이어 캐싱 활용(기존)
COPY src ./src
# Maven을 사용하여 프로젝트를 빌드하고 target 디렉토리에 JAR 파일을 생성
RUN mvn clean package

# 5. Use OpenJDK image to run the application(추가)
FROM openjdk:11-jre-slim
# build 레이어의 /app/target 디렉토리에 있는 모든 JAR 파일을 마지막 레이어의 /usr/app/app.jar에 복사
COPY --from=build /app/target/*.jar /usr/app/app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "/usr/app/app.jar"]
