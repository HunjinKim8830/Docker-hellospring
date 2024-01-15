## dockerhub hellospring link
<https://hub.docker.com/repository/docker/hunjin/hellospring/general>

---
## 사용방법

### 
1. docker-compose.yml 파일을 다운 받는다
2. 터미널을 열고 docker-compose.yml 파일이 있는 경로로 이동한다
3. 해당 경로에서 docker-compose up 명령어를 입력한다
###
    docker-compose up

## 어떤 프로젝트인가? ##

이 프로젝트는 도커 사용법을 이해하기 위한 프로젝트이다

자바, 스프링부트, JPA 등을 이용해 만든 프로젝트를 Dockerfile을 이용하여 이미지화하고, 도커 허브의 리포지토리에 올린다

이후 사용자는 docker-compose.yml 파일에 명시된 대로 도커 허브에 있는 h2db와 hellospring 이미지를 다운받고, 이를 통해 컨테이너를 실행

결과적으로 프로그램이 실행되게 된다

## 어째서 h2db의 버전이 2.1.214 이상 임에도 jdk17이 아닌 jdk11인가 ##
h2db의 이미지를 올린 oscarfonts씨가 이미지 작성을 jdk11로 했기 때문이다
그래서 springboot 버전도 2.x.x로 해야된다 3.x.x로 하면 여러가지 에러가 발생한다

## Build Stage ##
### 종속성 추출
### 빌드 작업을 위한 JDK 베이스이미지
FROM openjdk:11-jdk-slim as build

### 워킹 디렉토리 설정
WORKDIR /workspace/app

### 빌드에 필요한 Gradle 소스 복사
COPY gradle gradle

COPY build.gradle settings.gradle gradlew ./

COPY src src

### 빌드 진행
RUN ./gradlew bootJar # 빌드 진행

RUN mkdir -p build/libs/dependency && (cd build/libs/dependency; jar -xf ../*.jar) # 종속성 추출

## Run Stage ##

### 실행 작업을 위한 JRE 베이스이미지
FROM openjdk:11-jre-slim

### 호스트 서버에 전달이 필요한 데이터 저장공간
VOLUME /tmp

### Arugument에 종속성 경로를 추가
ARG DEPENDENCY=/workspace/app/build/libs/dependency

### Build Stage에서 추출된 종속성 카피하기
COPY --from=build ${DEPENDENCY}/BOOT-INF/lib /app/lib

COPY --from=build ${DEPENDENCY}/META-INF /app/META-INF

COPY --from=build ${DEPENDENCY}/BOOT-INF/classes /app

### 실행하기
ENTRYPOINT ["java","-cp","app:app/lib/*","hello.hellospring.HelloSpringApplication"]

## Docker 이미지 빌드 명령어

    docker build -t {도커 사용자명}/{원하는 이름}:{tag} .

## Docker 이미지를 도커 허브에 푸쉬하는 명령어

    docker push {도커 사용자명}/{원하는 이름}:{tag}

## 이 프로젝트를 진행하면서 ##
처음에는 도커허브에 올린 이미지만 다운 받아서 실행시키려 했었다

하지만 h2db연결이 끊겼다며 에러가 났는데, 
도커 이미지는 스프링부트 프로젝트를 Dockefile을 따라 만든 것이지 
docker-compose.yml의 내용이 들어가 있는 것은 아니었기에 그랬었다
(컨테이너 생성이 안되는 것은 당연했던 것)

하지만 나는 하나이 도커 이미지에 모든것을 넣고 실행시키고 싶어했고, 
그러기 위해 조사하면 할수록 Dockerfile에 모든 것을 집어넣는 것은 독립성에 좋지 못하다는 점과 
docker-compose up이라는 명령어를 사용하는 것이 권장하는 방법이라는 것을 알게되었다

결국 처음했던 방식이 맞았었다. 괜히 도커이미지 하나로 해보겠다고 하다가
결과는 이상한 곳에서 삽질하고 있었다.

---

### Thank you ###