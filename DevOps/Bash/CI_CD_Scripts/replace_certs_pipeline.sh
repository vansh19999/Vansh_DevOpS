#!/bin/bash

# Step 1: Backup old certificates
echo "Backing up existing certificates..."
BACKUP_DIR="/var/lib/docker/volumes/webServerData/_data/backup_$(date +%Y%m%d%H%M%S)"
mkdir -p "$BACKUP_DIR"
cp /var/lib/docker/volumes/webServerData/_data/*.pem "$BACKUP_DIR"
echo "Certificates backed up to $BACKUP_DIR"

# Step 2: Copy new certificates
echo "Copying new certificates..."
cp ./*.pem /var/lib/docker/volumes/webServerData/_data/
if [ $? -eq 0 ]; then
    echo "New certificates copied successfully."
else
    echo "Failed to copy new certificates. Aborting."
    exit 1
fi

# Step 3: Restart the service
echo "Restarting Apache service..."
docker restart posapache
sleep 20
if [ $? -eq 0 ]; then
    echo "Apache restarted successfully."
else
    echo "Failed to restart Apache. Please check the service."
    exit 1
fi

# Step 4: Verify the new certificates
echo "Verifying the new certificates..."
CERT_INFO=$(curl -vkI https://0.0.0.0/application/ 2>&1 | grep "expire date\|subject")
if [ $? -eq 0 ]; then
    echo "Certificate details:"
    echo "${CERT_INFO}"
else
    echo "Failed to verify the certificate using curl."
    echo "You may manually check using OpenSSL:"
    echo | openssl s_client -connect localhost:443 2>/dev/null | openssl x509 -noout -dates -subject
fi