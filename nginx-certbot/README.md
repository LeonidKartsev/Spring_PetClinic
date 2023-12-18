<a name="top"></a>
# NGINX/Certbot <img src="https://logodownload.org/wp-content/uploads/2018/03/nginx-logo-1.png" alt="Nginx" width="auto" height="50"> <img src="https://4.bp.blogspot.com/-LWgLSaYn24g/WSv0NWjmQ9I/AAAAAAAAGF4/SSCIQPjN8hIjbz6zgxhkPcGjPHMduCKqACLcB/s1600/certbot-logo.png" alt="Certbot" width="auto" height="50">

The final step in deploying our project is to configure **Nginx** and set up **Certbot** for automatic certificate acquisition and renewal for our server.

It is assumed that we have already acquired our own domain and assigned its external IP address to the virtual machine.

Let's consider the configuration files:

### `conf.d/default.conf` <img src="https://logodownload.org/wp-content/uploads/2018/03/nginx-logo-1.png" alt="Nginx" width="auto" height="35">
The **Nginx** configuration file. Let's take a closer look at it:

- Its first server block listens on port 80 and configures redirection to HTTPS. It also includes configuration for **Let's Encrypt** certificate authentication.

- The second server block listens on port 443 (HTTPS) and configures proxying of requests to http://springboot-server:8080. This means that all incoming HTTPS requests will be redirected to the specified server (in this case, a link to our application container) running on port 8080. SSL certificates used for encrypting the connection are also defined in this block.

- When server errors occur (e.g., 500, 502, 503, 504 errors), the page /usr/share/nginx/html/50x.html will be displayed.

### `nginx_certbot.yml` <img src="http://gw.tnode.com/docker/img/docker-compose-1x-logo.png" alt="Docker-compose" width="auto" height="35">

A script for launching, operating, and interacting between Nginx and Certbot services. Let's take a closer look at it:

- The nginxserver service:
  - Uses the Nginx version 1.25.1 image based on Alpine Linux.
  - The container will be named "nginxserver".
  - The container will automatically restart unless explicitly stopped.
  - Directories ./conf.d on the host machine are mounted to /etc/nginx/conf.d in the container, ./certbot/conf on the host machine is mounted to /etc/letsencrypt in the container, and ./certbot/www on the host machine is mounted to /var/www/certbot in the container. This is where our certificates and configurations will be located.
  - The container listens on ports 80 and 443 (HTTP and HTTPS).
  - After starting the container, the command `/bin/sh -c 'while :; do sleep 6h & wait $${!}; nginx -s reload; done & nginx -g "daemon off;"'` will be executed to run the container in daemon mode and reload Nginx every 6 hours to update the certificates if there are any new ones.

- The certbot service:
  - Uses the certbot/certbot image.
  - The container will be named "certbot".
  - The container will automatically restart unless explicitly stopped.
  - Directory ./certbot/conf on the host machine is mounted to /etc/letsencrypt in the container, and ./certbot/www on the host machine is mounted to /var/www/certbot in the container.
  - After starting the container, the command `/bin/sh -c 'trap exit TERM; while :; do certbot renew; sleep 12h & wait $${!}; done;'` will be executed to automatically renew SSL certificates every 12 hours.

  ### `init_letsencrypt.sh` <img src="https://download.logo.wine/logo/Bash_(Unix_shell)/Bash_(Unix_shell)-Logo.wine.png" alt="Bash" width="auto" height="45">

This script sets up the containers for Nginx and Certbot, and defines the execution order of commands for both services, which involves obtaining and renewing the SSL certificate.
Let's take a closer look at it:

 - Check if Docker Compose is installed. If it's not installed, the script displays an error and exits.
```shell
if ! [ -x "$(command -v docker-compose)" ]; then
  echo 'Error: docker compose is not installed.' >&2
  exit 1
fi
```
 - Variables are set:

  - domains: a list of domain names for which an SSL certificate will be created. Please insert your actual domain here.
  - rsa_key_size: RSA key size (4096 bits).
  - data_path: the path to the directory where Certbot data will be stored.
  - email: email address for communication with Let's Encrypt. Please specify your email here.
  - staging: a flag to use the Let's Encrypt staging server (for testing).
 - The existence of the $data_path directory is checked. If it already exists, the script prompts the user to confirm whether to continue and replace the existing certificate.
 ```shell
 if [ -d "$data_path" ]; then
    read -p "Existing data found for $domains Continue and replace existing certificate? (y/N)" decision
  if [ "$decision" != "Y" ] && [ "$decision" != "y" ]; then
      exit
  fi
fi
```

- Checking for the existence of the `$data_path` directory. If it already exists, the script asks the user whether to continue and replace the existing certificate.
```shell
if [ -d "$data_path" ]; then
    read -p "Existing data found for $domains. Continue and replace the existing certificate? (y/N)" decision
    if [ "$decision" != "Y" ] && [ "$decision" != "y" ]; then
        exit
    fi
fi
```

- If the required configuration files (`options-ssl-nginx.conf` and `ssl-dhparams.pem`) are not present in the **$data_path/conf directory**, they are downloaded using `curl`.
- Creating a temporary dummy certificate for the domain $domains using Docker Compose and OpenSSL. The certificate is saved in the directory $data_path/conf/live/$domains
```shell
path="/etc/letsencrypt/live/$domains"
mkdir -p "$data_path/conf/live/$domains"
docker-compose -f nginx_certbot.yml run --rm --entrypoint "\
  openssl req -x509 -nodes -newkey rsa:$rsa_key_size -days 1\
  -keyout '$path/privkey.pem'\
  -out '$path/fullchain.pem'\
  -subj '/CN=localhost'" certbot
echo
```
- The Nginx container is launched using Docker Compose to generate self-signed certificates and test the configuration's functionality with them.
- The temporary dummy certificate is removed
```shell
docker-compose -f nginx_certbot.yml run --rm --entrypoint "\
  rm -Rf /etc/letsencrypt/live/$domains && \
  rm -Rf /etc/letsencrypt/archive/$domains && \
  rm -Rf /etc/letsencrypt/renewal/$domains.conf" certbot
echo
```
- In the further steps, preparations are made to obtain a **Let's Encrypt** certificate. The presence of current domains is checked and compiled into a list to be passed to Let's Encrypt using the `-d` argument. The existence of an email is verified for a valid request.

- The value of the **staging** variable is checked. If it is not equal to **"0"**, the `--staging` argument is set to activate the testing mode.
```shell
if [ $staging != "0" ]; then staging_arg="--staging";
fi
```
 - *In the testing mode, dummy certificates are issued. These certificates are not trusted and should not be used in a production environment. However, they allow testing the configuration to avoid triggering rate limits with Let's Encrypt for excessive certificate requests.*

- An SSL certificate is requested from Let's Encrypt for the domain `$domains` using **Certbot** and **Docker-Compose**. Parameters such as the RSA key size, acceptance of terms of service, and email registration (if specified) are used.
```shell
docker-compose -f nginx_certbot.yml run --rm --entrypoint "\
  certbot certonly --webroot -w /var/www/certbot \
  $staging_arg \
  $email_arg \
  $domain_args \
  --rsa-key-size $rsa_key_size \
  --agree-tos \
  --force-renewal" certbot
echo
```
- Nginx is restarted to apply the new certificate.
- The Certbot container is launched to enable automatic certificate renewal in the future.

After running this script, you will find your SSL certificate (`fullchain.pem`) and private key (`privkey.pem`) in the directory `$data_path/conf/live/$domains`, which will be used to configure a secure connection with your Nginx server.

Make sure to provide the actual domain and email before running the `init_letsencrypt.sh` script.

As a result, we have a deployed application accessible over HTTPS with an automatically updated Let's Encrypt certificate through Certbot. We have automated these processes, making the application's operation continuous and independent of the admin.

[Up](#top)
