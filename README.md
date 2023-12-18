<a name="top"></a>

## Project Overview
In this project, we will be building a Java application using the following tools:

- Maven <img src="https://i0.wp.com/www.vexevsolutions.com/wp-content/uploads/2018/10/maven-logo-black-on-white.png?ssl=1" alt="Maven" width="auto" height="20">
- Docker <img src="http://logos-download.com/wp-content/uploads/2016/09/Docker_logo.png" alt="Docker" width="auto" height="20">
- Docker-compose <img src="http://gw.tnode.com/docker/img/docker-compose-1x-logo.png" alt="Docker-compose" width="auto" height="20">
- Terraform <img src="https://neodoo.es/wp-content/uploads/2020/09/logo_terraform_2-480x480.png" alt="Terraform" width="auto" height="20">
- Bash <img src="https://download.logo.wine/logo/Bash_(Unix_shell)/Bash_(Unix_shell)-Logo.wine.png" alt="Bash" width="auto" height="20">
- MySQL <img src="https://sqlbackupandftp.com/blog/wp-content/uploads/2015/01/mysql-logo_2800x2800_pixels1.png" alt="MySQL" width="auto" height="20">
- Nginx <img src="https://logodownload.org/wp-content/uploads/2018/03/nginx-logo-1.png" alt="Nginx" width="auto" height="15">
- Certbot <img src="https://4.bp.blogspot.com/-LWgLSaYn24g/WSv0NWjmQ9I/AAAAAAAAGF4/SSCIQPjN8hIjbz6zgxhkPcGjPHMduCKqACLcB/s1600/certbot-logo.png" alt="Certbot" width="auto" height="15">
- Let's Encrypt <img src="https://readyspace.com.hk/wp-content/uploads/2016/10/lets-encrypt-webpage-W750xH855.png" alt="Let's Encrypt" width="auto" height="20">
- Yandex Cloud <img src="https://raw.githubusercontent.com/tamarinvs19/tamarinvs19/master/imgs/yandex_cloud.png" alt="YC" width="auto" height="15">

---

## Acknowledgements
We would like to express our gratitude to [spring-projects](https://github.com/spring-projects) for providing the open-source code of the [Spring PetClinic Sample Application](https://github.com/spring-projects/spring-petclinic). Their contribution has been instrumental in the development of this project.

![](https://springframework.guru/wp-content/uploads/2015/02/spring-framework-project-logo.png)

---

## Project Goals <img src="http://getdrawings.com/free-icon-bw/objective-icon-png-12.png" alt="goals" width="auto" height="70">

- Setting up and deploying the **Java** application *Spring-petclinic*, connecting it to a **MySQL** database, hosting it publicly using **TLS** encryption with the help of a virtual machine on **Yandex Cloud**, Docker containerization, proper configuration of the **Nginx** web server, and automating the acquisition and renewal of certificates using **Certbot**.

- Practicing working with **Maven**, understanding the process of automating application build and the structure of POM files.

- Working with **Docker**: installing it correctly, writing a **Dockerfile**, understanding its syntax, building images, administering and reading container logs, and exploring **Docker Networks**.

- Writing a **Docker-compose** script to automate container configuration based on images provided by [docker-hub](https://hub.docker.com), as well as custom-built images, managing dependencies and networks, configuring ports, and setting up the application using a `.yml` file. Writing a **Multi-stage building**

- Understanding the process of automating environment setup using **Terraform**: writing a configuration file, configuring providers and resources, passing variables and metadata to the configuration file, writing a **remote-exec** script, understanding the **Provisioner** block to control the order of commands for environment setup in the virtual machine, and configuring **security groups**.

- Practicing the writing and optimization of **Bash** scripts, working with variables, loops, and conditional statements, simplifying and automating everyday processes, setting up automatic certificate renewal through **Certbot**, and automating **Nginx** configuration.

- Configuring **MySQL**: creating and administering databases and tables, configuring it to work with the **Java** application, creating and configuring user privileges, containerizing it with **Docker**, configuring the network interface for proper integration with other project components, and configuring it using **Docker-compose**.

- Configuring reverse proxy with **Nginx**, understanding the configuration file, deploying it in a **Docker** environment, continuous configuration using **Certbot** for certificate acquisition and renewal.

- Working with automatic certificate retrieval and renewal, deploying it in a **Docker** environment, configuring it to run continuously, monitoring the presence and validity of certificates issued by **Let's Encrypt**, and creating dummy certificates.

- Testing the built stack in a staging environment using **Let's Encrypt**, as well as obtaining a trusted certificate for **HTTPS** configuration.

- Gaining experience with a remote virtual environment on **Yandex Cloud**, learning **Yandex CLI**, working with networks and subnets, configuring **Security groups**, and administering a remote host through **SSH**.

[Up](#top)
