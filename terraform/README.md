<a name="top"></a>
# Working with Terraform <img src="https://neodoo.es/wp-content/uploads/2020/09/logo_terraform_2-480x480.png" alt="Terraform" width="auto" height="50">

In this part of the project, we will explore working with Terraform, configuring the Yandex Cloud configuration, and automating the infrastructure deployment with a ready-made application and a database in a Docker environment.

## Registration and Authentication in Yandex Cloud using CLI <img src="https://raw.githubusercontent.com/tamarinvs19/tamarinvs19/master/imgs/yandex_cloud.png" alt="YC" width="auto" height="30">

First, we need to register on [Yandex Cloud](https://cloud.yandex.com/) and access the console for working with cloud services.

In this case, we will configure the infrastructure using CLI - a plugin for managing services via the command line of your device:

```shell
curl -sSL https://storage.yandexcloud.net/yandexcloud-yc/install.sh | bash
```

After the installation is complete, restart your command shell.

During the interactive profile creation process, you can authenticate using the `yc init` command:

- Obtain an OAuth token in the Yandex.OAuth service by following this [link](https://oauth.yandex.com/authorize?response_type=token&client_id=1a6990aa636648e9b2ef855fa7bec2fb) - copy the token to your clipboard or save it.
- Execute the `yc init` command to configure your CLI profile.

For more information on configuring the CLI profile, refer to the [official documentation](https://cloud.yandex.com/docs/cli/quickstart).

**Additionally, to ensure the stack works correctly, you need to obtain a Service Account Key file:**

1. Go to the Yandex Cloud Console.
2. Open the **Service Accounts** page.
3. Select the desired service account or create a new one.
4. Click on the **Create Key** button.
5. Choose the **JSON** format for the key file and click **Create**.
6. Save the downloaded JSON file to a secure location.

Keep the Service Account Key file safe, as it provides access to your cloud resources.  Also, to ensure the proper functioning of the stack, you need to obtain a static public IP address. For more information on obtaining a static IP address, please refer to the [official documentation](https://cloud.yandex.com/docs/vpc/operations/get-static-ip).
 Before starting to work with Terraform, you need to add authentication parameters to the environment variable:

```shell
export YC_TOKEN=$(yc iam create-token)
export YC_CLOUD_ID=$(yc iam config get cloud-id)
export YC_FOLDER_ID=$(yc iam config get folder-id)

```


This process is automated. There is a script in the current folder that passes the parameters to the environment variable. Execute the following command: 

```shell
. ./export_identifications_yc.sh 
```

Please make sure that the file has executable permissions. If not, execute the following command: ```sudo chmod +x export_identifications_yc.sh```

## Initializing Terraform

To install Terraform, you can use the package manager Brew if you're working on Mac OS:

```bash
brew install terraform
```


Once you have obtained the necessary credentials and set up the CLI profile, you can initialize Terraform in your project directory:

```shell
terraform init  
```

## Working Directory

A working directory is required for working with Terraform, and it's already present in our repository.

The configuration files with the `.tf` extension are located in the current directory and are necessary for creating the project infrastructure on the remote server. Let's take a closer look at them:

`main.tf`: This is the main configuration file that is used to set up the environment. It contains the following blocks:

- terraform:
  - This block specifies the required providers and the Terraform version to use. We are using the yandex-cloud/yandex provider to interact with Yandex Cloud.
  - The Terraform version should be 0.92 or higher.
- provider:
  - This block defines the "yandex" provider and sets the deployment zone to **ru-central1-a** for working with Yandex Cloud. You can choose a different zone based on your preference.
- resource "yandex_vpc_security_group":
  - This block defines the yandex_vpc_security_group resource, which is used to create a virtual private network (VPC) security group in Yandex Cloud. It specifies the name, description, and network_id of the security group. It also defines ingress traffic rules to allow connections on specified ports using the TCP protocol.
- resource "yandex_compute_instance":
  - This block defines the yandex_compute_instance resource, which is used to create a virtual machine (VM) in Yandex Cloud. It specifies the VM name, resources (cores and memory), boot disk, network interface, metadata (user-data and ssh-keys), and SSH connection parameters. It also defines the connection for Terraform authentication inside the created instance and a provisioner "remote-exec" that contains a set of commands to execute on the VM after its creation. This block ensures the complete infrastructure is created with a running application and a database in a Docker environment. You will need to configure Nginx and Certbot later. **Note that an example metadata file (meta.txt) is located in the current directory. Please fill it in with your personal data.**

`variables.tf`:
- This file passes our variables. You need to fill it with your own network ID, subnet ID, NAT IP address, and image ID. In our main.tf, they are already marked as var.network_id, for example.

`output.tf`:
- This is an additional configuration file that displays the external and internal IP addresses of the created instance in our command line.

Let's now look at the remaining files:

`  .terraformrc`:
- This file stores the mirror configuration for Terraform to work correctly with the Yandex provider. Please note that the configuration should be placed in the user's home directory. Therefore, please move the file to the home directory using the command:

```shell
mv .terraformrc ~/
```

`terraform.tfvars`:
- This file also contains the necessary variables to pass to main.tf. Please translate them from `variables.tf` accordingly.

This way, the provider is defined, and the working environment is set up on the remote instance. We have configured the CLI, obtained a static IP, and deployed a complete instance with a running application and a database.

[Up](#top)
