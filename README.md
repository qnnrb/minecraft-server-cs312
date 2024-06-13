# **How to deploy a Minecraft Java Server with Terraform and an AWS EC2 instance**
This tutorial will show you the resources needed to deploy a Minecraft server with Terraform and AWS, and the steps to deploy the server and take it down.
## Requirements
1. Terraform (1.8.4)
2. AWS Account
3. AWS CLI (2.15.59)

## Steps
1. Ensure that your AWS credentials are accurate and up to date. To check the credentials on your machine, navigate to the /.aws directory and look at the file entitled "credentials". Make sure the value of all three fields is consistent with the AWS Management Console.
 
2. Check that you have both Terraform and the AWS CLI correctly installed by running these two commands: 

3. Create a directory that you will deploy your server in and enter it. Copy the files "main.tf" and "script.sh" from this repo into this directory. 

4. Use the command 
```console
terraform init
```
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;to initialize terraform and its dependencies. 

5. Use the command
```console
terraform plan
```
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;to see the resources that will be created upon application. 

6. Use the command 
```console
terraform apply 
```
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;and then enter "yes" when prompted to create the resources in AWS to run the server. 

7. Wait for about a minute for the resources to initialize and then use the public IP to connect to the Minecraft server. You can alternatively use the command 
```console
nmap -sV -Pn -p T:25565 <Public_IP>
```
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;to ensure that the server is up and running. 

8. If you wish to delete the resources that terraform created, then enter 
```console
terraform destroy
```
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;This will permanently delete all the resources that were created. 

### Resources Used
- Used for the server configuration script: https://aws.amazon.com/blogs/gametech/setting-up-a-minecraft-java-server-on-amazon-ec2/#:~:text=Setting%20up%20a%20Minecraft%20Java%20server%20on%20Amazon,files%2C%20and%20more%207%20Cleaning%20up%208%20Conclusion
- Used for associating subnets to route tables: https://stackoverflow.com/questions/51739482/terraform-how-to-associate-multiple-subnet-to-route-table
