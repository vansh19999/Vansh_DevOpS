param location string
param vnetName string
param addressPrefix string
param subnetName string
param subnetPrefix string
param keyVaultName string
param vmName string
param adminUsername string
param vmAdminPassword string
param mysqlServerName string
param mysqlAdminUser string
param mysqlAdminPassword string
param cosmosDbName string

module vnetModule './vnet.bicep' = {
  name: 'vnetDeployment'
  params: {
    location: location
    vnetName: vnetName
    addressPrefix: addressPrefix
    subnetName: subnetName
    subnetPrefix: subnetPrefix
  }
}

module keyVaultModule './keyvault.bicep' = {
  name: 'keyVaultDeployment'
  params: {
    location: location
    keyVaultName: keyVaultName
  }
}

module vmModule './vm.bicep' = {
  name: 'vmDeployment'
  params: {
    location: location
    vmName: vmName
    adminUsername: adminUsername
    vmAdminPassword: vmAdminPassword
    subnetId: vnetModule.outputs.subnetId
  }
}

module mysqlModule './mysql.bicep' = {
  name: 'mysqlDeployment'
  params: {
    location: location
    mysqlServerName: mysqlServerName
    mysqlAdminUser: mysqlAdminUser
    mysqlAdminPassword: mysqlAdminPassword
  }
}

module cosmosModule './cosmos.bicep' = {
  name: 'cosmosDeployment'
  params: {
    location: location
    cosmosDbName: cosmosDbName
  }
}
