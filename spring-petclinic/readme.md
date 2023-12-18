<a name="top"></a>
# Application and Database <img src="https://springframework.guru/wp-content/uploads/2015/02/spring-framework-project-logo.png" alt="APP/DB" width="auto" height="50">

Here we will discuss our application and its interaction with the MySQL database.

The open-source code of the application was borrowed from [Spring projects](https://github.com/spring-projects). The features, functionality, and build process of the application can be found [here](https://github.com/spring-projects/spring-petclinic/blob/main/readme.md) in the official publisher's repository.

In our case, the application's `.jar` file will be built using **Maven** and then deployed in a Docker environment, where it will establish a connection with the MySQL database.

## Let's go through our configuration files:

- #### Dockerfile <img src="http://logos-download.com/wp-content/uploads/2016/09/Docker_logo.png" alt="Docker" width="auto" height="20">
   - This file is responsible for building the application image and using it in the Docker environment.

```shell
FROM maven as builder
```
This instruction specifies the base image from which we build our image. In this case, we use the Maven image to build our application. It will be used as a temporary stage (builder) for the project build.

```shell
WORKDIR ./spring-petclinic
```
This instruction sets the working directory inside the container. All subsequent instructions will be executed in this directory.

```shell
COPY ./src ./src
COPY ./pom.xml ./pom.xml
```
These instructions copy the application source code (./src) and the pom.xml file (Maven configuration file) into the container's **./spring-petclinic** directory. This is necessary for the subsequent Maven project build.

```shell
RUN mvn package
```
These instructions execute commands inside the container. `mvn package` is used to build the project with **Maven**.

```shell
FROM openjdk:17
```
This instruction specifies another base image on which the final image will be created. In this case, we use the **OpenJDK 17** image, which contains the Java runtime environment.

```shell
COPY --from=builder ./spring-petclinic/target/*.jar /opt/app.jar
```
This instruction copies the built JAR file from the temporary stage (builder) into the final image. The file will be copied to the /opt/app.jar path inside the container.

```shell
ENTRYPOINT ["java", "-jar", "/opt/app.jar"]
```
This instruction specifies the command to be executed when the container is launched. In this case, the command `java -jar /opt/app.jar` will be executed to run our Java application.

So, our application image is built and ready to use. In the future, when working with Docker-compose, we will refer to this Dockerfile.

- #### docker-compose_app.yml <img src="http://gw.tnode.com/docker/img/docker-compose-1x-logo.png" alt="Docker-compose" width="auto" height="25">
  - This is the script for launching and configuring containers. It will help us set up the environment and connect the application with the database.

```shell
services:
  mysqlserver:
    image: mysql/mysql-server
    container_name: mysqlserver
    restart: always
    ports:
      - "3306:3306"
    environment:
      - MYSQL_ROOT_PASSWORD=root
      - MYSQL_USER=petclinic
      - MYSQL_PASSWORD=petclinic
      - MYSQL_DATABASE=petclinic
    networks:
      - mysqlnet
    healthcheck:
      test: ["CMD", "mysqladmin" ,"ping", "-h", "localhost"]
      timeout: 5s
      retries: 10
```
In this block, the **mysqlserver service** is defined, which will be launched in a container. It uses the **mysql/mysql-server** image and will be named **mysqlserver**. Some settings for this service include automatic restart (`restart: always`), **host port forwarding to container port** (`ports: - "3306:3306"`), **environment variables** for MySQL database configuration (`environment`), and the **network** it will be part of (`networks`). There is also a **health check** (`healthcheck`) that will be performed using `mysqladmin ping` to ensure that the MySQL server is running.

```shell
springboot-server:
  build:
    context: .
    dockerfile: Dockerfile
  container_name: springboot-server
  restart: always
  depends_on:
    mysqlserver:
      condition: service_healthy
  environment:
    - SPRING_PROFILES_ACTIVE=mysql
  ports:
    - "8080:8080"
  networks:
    - mysqlnet
```
In this block, the **springboot-server service** is defined, which will be built using the **Dockerfile** (`build`). It will be named **springboot-server** and has some settings, including **automatic restart** (`restart: always`), **dependency on the mysqlserver service** to ensure that the MySQL database is up and running (`depends_on`). There is also an environment variable for **configuring the Spring Boot profile** (`SPRING_PROFILES_ACTIVE=mysql`), **host port forwarding to container port** (`ports: - "8080:8080"`), and the **network** it will be part of (`networks`).

```shell
networks:
  mysqlnet:
    name: mysqlnet
    external: true
```
This block defines the `mysqlnet` network that will be used to establish communication between the services. It has the name `mysqlnet` and the `external: true` flag, indicating the use of an external network.

**It is very important** to ensure that the configuration in the file `spring-petclinic/src/main/resources/application-mysql.properties` is set according to the template, with the correct parameters:

- `spring.datasource.url` - the link to your database according to the container name and port 3306
- `spring.datasource.username` - MySQL username
- `spring.datasource.password` - MySQL user password

Thus, we have provided instructions for building the application image and written a script for its interaction with the environment and the database. In the future, using this configuration, Terraform will build our image and deploy the application with the database in a Docker environment on a remote instance.

[Up](#top)
