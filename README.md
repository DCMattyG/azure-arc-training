# Azure Arc-enabled servers LevelUp Training

![LevelUp Deployment Diagram](./docs/levelup-diagram.png)

The following README will guide you on how to automatically deploy an ArcBox for use with the Azure Arc-enabled servers LevelUp training.

Azure VMs leverage the [Azure Instance Metadata Service (IMDS)](https://docs.microsoft.com/en-us/azure/virtual-machines/windows/instance-metadata-service) to communicate with Azure,and is also how Azure knows that a particular VM is running inside Azure (or even running as anested VM within an Azure VM). Onboarding such Azure VMs to Arc is not allowed and the process will fail.

However, **for demo purposes only**, the below lab and guide will allow you to use and onboard VMs running on Hyper-V within an Azure VM to Azure Arc by blocking communication to IMDS. This will allow us to simulate servers which are deployed outside of Azure (i.e "on-premises" or in other cloud platforms)

> **Note: It is not expected for an Azure VM to be projected as an Azure Arc-enabled server. The below scenario is unsupported and should ONLY be used for demo and testing purposes.**

## Prerequisites

* ArcBox LevelUp requires 16 DSv4-series vCPUs when deploying with default parameters such as VM series/size. Ensure you have sufficient vCPU quota available in your Azure subscription and the region where you plan to deploy ArcBox. You can use the below Az CLI command to check your vCPU utilization.

  ```shell
  az vm list-usage --location "<location>" --output table
  ```

  ![Screenshot showing az vm list-usage](./docs/vcpu-availability.png)

* [Install or update Azure CLI to version 2.40.0 and above](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest). Use the below command to check your current installed version.

  ```shell
  az --version
  ```

* Create Azure service principal (SP).

  You will need `Microsoft.Authorization/roleAssignments/write` permission on the target subscription in order to successfully assign the appropriate permissions to the Service Principal used in the automation. Azure built-in roles which contain this permission are as follows:

  * [Owner](https://docs.microsoft.com/en-us/azure/role-based-access-control/built-in-roles#owner)
  * [User Access Administrator](https://docs.microsoft.com/en-us/azure/role-based-access-control/built-in-roles#user-access-administrator)
  * [Co-Administrator](https://docs.microsoft.com/en-us/azure/role-based-access-control/classic-administrators)

  For additional information on assigning a user as a Subscription administrator, click [here](https://docs.microsoft.com/en-us/azure/role-based-access-control/role-assignments-portal-subscription-admin)

  To be able to complete the scenario and its related automation, Azure service principal assigned with the “Contributor” role on the subscription is required. To create it, login to your Azure account run the below command (this can also be done in [Azure Cloud Shell](https://shell.azure.com/)).

  ```shell
  az login
  az account set --subscription "<Subscription Id>"
  az ad sp create-for-rbac -n "<Unique SP Name>" --role "Owner" --scopes /subscriptions/<Subscription ID>
  ```

  For example:

  ```shell
  az ad sp create-for-rbac -n "http://AzureArcLevelUp" --role "Owner" --scopes /subscriptions/31c4b5fc-xxxx-xxxx-xxxx-5e377c3f41af
  ```

  Output should look like this:

  ```json
  {
      "appId": "XXXXXXXXXXXXXXXXXXXXXXXXXXXX",
      "displayName": "AzureArcLevelUp",
      "name": "http://AzureArcLevelUp",
      "password": "XXXXXXXXXXXXXXXXXXXXXXXXXXXX",
      "tenant": "XXXXXXXXXXXXXXXXXXXXXXXXXXXX"
  }
  ```

  > **Note: It is now mandatory to scope the SP to a specific [Azure subscription](https://learn.microsoft.com/en-us/cli/azure/ad/sp?view=azure-cli-latest#az-ad-sp-create-for-rbac).**

## ArcBox Azure Region Compatibility

ArcBox must be deployed to one of the following regions:
> **Deploying ArcBox outside of these regions may result in unexpected results or deployment errors.**

* East US
* East US 2
* West US 2
* North Europe
* West Europe
* France Central
* UK South
* Australia East
* Japan East
* Korea Central
* Southeast Asia

## Deploy the Template from the Azure Portal

1. Click the button below to deploy the LevelUp ArcBox template via the Azure Portal:

    [![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FDCMattyG%2Fazure-arc-training%2Fmain%2Farm%2Fazuredeploy.json/createUIDefinitionUri/https%3A%2F%2Fraw.githubusercontent.com%2FDCMattyG%2Fazure-arc-training%2Fmain%2Farm%2FcreateUiDefinition.json)

2. Choose a target subscription, region, resource group (or create a new one), and region. Click **next**:

    ![LevelUp Deployment Step 1](./docs/portal-deployment-01.png)

3. Fill in the corresponding fields from the Service Principal creation step above and the Windows VM login credentials. Click **next**:

    ![LevelUp Deployment Step 2](./docs/portal-deployment-02.png)

    > Please make sure to select a **unique** value for the Log Analytics Workspace Name (e.g. it doesn't overlap any existing Log Analytics Workspace within the target Resource Group)

4. Review the deployment details, then click **create** to begin the deployment:

    ![LevelUp Deployment Step 3](./docs/portal-deployment-03.png)

5. Once the deployment has finished, click **go to resource group**:

    ![LevelUp Deployment Complete](./docs/deployment-complete.png)

6. Select the **ArcBox-Client** virtual machine:

    ![LevelUp ArcBox VM](./docs/arcbox-vm.png)

7. Click on **Bastion** under **Operations** in the left-hand menu:

    ![LevelUp ArcBox Bastion](./docs/select-bastion.png)

8. Enter the **Username** and **Password** you set during the deployment (above) and click **Connect**:

    ![LevelUp ArcBox RDP](./docs/bastion-connect.png)

9. Watch and wait for the post-deployment automation script to finish:

    ![LevelUp ArcBox Post-Deployment](./docs/post-deployment-scripts.png)

10. Once the scripts have completed you should have 2 Linux and 2 Windows VMs, which can be found in **Hyper-V Manager** on the desktop:

    ![LevelUp ArcBox Hyper-V](./docs/hyper-v-manager.png)

11. Back in the Resource Group view, you can see that two of the Hyper-V VMs (Ubuntu-01 & Win2K19) have already been onboarded to Azure Arc on your behalf:

    ![LevelUp ArcBox Arc Onboarded VMs](./docs/onboarded-vms.png)

## Required Credentials

Use the below credentials for logging into the nested Hyper-V virtual machines:

* Windows Server (2019/2022)
  * Username: `Administrator`
  * Password: `ArcDemo123!!`
* Linux (Ubuntu/CentOS)
  * Username: `arcdemo`
  * Password: `ArcDemo123!!`
