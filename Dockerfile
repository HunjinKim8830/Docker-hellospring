##### Build Stage #####
# 종속성 추출
# 빌드 작업을 위한 JDK 베이스이미지
FROM openjdk:11-jdk-slim as build

# 워킹 디렉토리 설정
WORKDIR /workspace/app

# 빌드에 필요한 Gradle 소스 복사
COPY gradle gradle
COPY build.gradle settings.gradle gradlew ./
COPY src src

# 빌드 진행
RUN ./gradlew bootJar # 빌드 진행
RUN mkdir -p build/libs/dependency && (cd build/libs/dependency; jar -xf ../*.jar) # 종속성 추출

##### Run Stage #####

# 실행 작업을 위한 JRE 베이스이미지
FROM openjdk:11-jre-slim

# 호스트 서버에 전달이 필요한 데이터 저장공간
VOLUME /tmp

# Arugument에 종속성 경로를 추가
ARG DEPENDENCY=/workspace/app/build/libs/dependency

# Build Stage에서 추출된 종속성 카피하기
COPY --from=build ${DEPENDENCY}/BOOT-INF/lib /app/lib
COPY --from=build ${DEPENDENCY}/META-INF /app/META-INF
COPY --from=build ${DEPENDENCY}/BOOT-INF/classes /app

# 실행하기
ENTRYPOINT ["java","-cp","app:app/lib/*","hello.hellospring.HelloSpringApplication"]
