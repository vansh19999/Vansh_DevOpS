param location string
param mysqlServerName string
param mysqlAdminUser string
@secure()
param mysqlAdminPassword string

resource mysql 'Microsoft.DBforMySQL/flexibleServers@2022-01-01' = {
  name: mysqlServerName
  location: location
  properties: {
    administratorLogin: mysqlAdminUser
    administratorLoginPassword: mysqlAdminPassword
    version: '8.0.21'
    storage: {
      storageSizeGB: 32
    }
  }
  sku: {
    name: 'Standard_B1ms'
    tier: 'Burstable'
    family: 'B'
    capacity: 1
  }
}
