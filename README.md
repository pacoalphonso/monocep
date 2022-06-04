# What is Monocep?
Monocep is a configuration layer built using Azure Bicep to provide readily-made templates for easier deployment of Azure resources with little to no knowledge necessary on ARM templates or Azure Bicep.

# Why Monocep?
Monocep is designed to cut down deployment time of Azure resources by attempting to diminish, if not remove, the time it takes for developers to learn about ARM templates or Azure Bicep just to be able to deploy these resources to Azure. It primarily does this through the use of templates - a set of Bicep code which only ask for the required parameters to deploy the requested resources. 

To give an example, consider a developer with little to no experience on ARM templates or Azure Bicep who needs to deploy an Azure AppService with Application Insights behind a Vnet, SQL Server with an SQL database, and store the connection string in Azure Keyvault in an automated way. To do this, said developer would need to learn first about the proper configuration of each required component in either ARM templates or Azure Bicep, and learn how to combine the resources so that the AppService is properly configured with Application Insights, configure a subnet inside the Vnet, put the App Service behind the Vnet using the created subnet, create the SQL Server which will contain the SQL Database, and store the SQL Server connection string in the Azure Keyvault. The time and effort it takes to accomplish this is sure to take up a significant amount of time for the developer. 

In contrast, by using a Monocep template which already does this, the only thing needed from the developer are the required parameters, i.e. in this case, location, name, username, and password, then execute the deployment using either Azure CLI or Powershell, which takes only a few minutes.

# Monocep Conventions
// TODO
