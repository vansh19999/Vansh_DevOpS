def updateCertsOnVM(vmName) {
    echo "Starting certificate update process on VM: ${vmName}"


        sh """#!/bin/bash
        set -e  # Exit on error

        echo "Logging in to Azure using Service Principal..."
        az login --service-principal -u "$AZURE_CLIENT_ID" -p "$AZURE_CLIENT_SECRET" -t "$AZURE_TENANT_ID" > /dev/null || {
            echo "Azure login failed. Exiting..."
            exit 1
        }

        echo "Azure Logged In"

        # Function to extract error messages
        beautify() {
            python3 -c 'import json, sys; data = sys.stdin.read(); print(json.loads(data).get("value")[0]["message"])' || {
                echo "Failed to parse JSON response"
            }
        }

        az vm run-command invoke -g Test -n "${vmName}" --command-id RunShellScript --scripts "
            echo 'Running the update_certs.sh script...'
            if [ -f "/opt//devops.scripts/shell/_server_setup/ssl_cert_setup/certs--dev/update_certs.sh" ]; then
                cd /opt//devops.scripts/shell/_server_setup/ssl_cert_setup/certs--dev
                /bin/bash update_certs.sh || {
                    echo 'Certificate update script failed.'
                    exit 1
                }
            else
                echo 'Certificate update script not found. Exiting...'
                exit 1
            fi
        " | beautify  || {
            echo "Command execution on VM ${vmName} failed."
            exit 1
        }

        echo "Certificate update process completed successfully."
        """
}

def installCleanupOnVM(vmName) {
    echo "Starting Cleanup Script installation on VM: ${vmName}"

        sh """#!/bin/bash
        set -e  # Exit on error

        echo "Logging in to Azure using Service Principal..."
        az login --service-principal -u "$AZURE_CLIENT_ID" -p "$AZURE_CLIENT_SECRET" -t "$AZURE_TENANT_ID" > /dev/null || {
            echo "Azure login failed. Exiting..."
            exit 1
        }

        echo "Azure Logged In"

        # Function to extract error messages
        beautify() {
            python3 -c 'import json, sys; data = sys.stdin.read(); print(json.loads(data).get("value")[0]["message"])' || {
                echo "Failed to parse JSON response"
            }
        }

        az vm run-command invoke -g Test -n "${vmName}" --command-id RunShellScript --scripts "
            echo 'Running install.sh script...'
            if [ -f "/opt//devops.scripts/shell/_server_setup/server_cleanup/install.sh" ]; then
                cd /opt//devops.scripts/shell/_server_setup/server_cleanup/
                /bin/bash install.sh || {
                    echo 'Cleanup script installation failed.'
                    exit 1
                }
            else
                echo 'Install script not found. Exiting...'
                exit 1
            fi
        " | beautify || {
            echo "Command execution on VM ${vmName} failed."
            exit 1
        }

        echo "Cleanup script installation completed successfully."
        """

}

def performOps(vmName) {

    withCredentials([
        azureServicePrincipal(credentialsId: 'Add creds'),
    ]) {
        sh """#!/bin/bash

        echo "Logging in to Azure using Service Principal..."
        az login --service-principal -u $AZURE_CLIENT_ID -p $AZURE_CLIENT_SECRET -t $AZURE_TENANT_ID > /dev/null || {
            echo "Azure login failed. Exiting..."
            exit 1
        }

        echo "Azure Logged In"

        # Function to extract error messages
        beautify() {
            python3 -c 'import json, sys; data = sys.stdin.read(); print(json.loads(data).get("value")[0]["message"])' || {
                echo "Failed to parse JSON response"
            }
        }

        echo "Running remote command on VM: ${vmName}"
        az vm run-command invoke -g Test -n ${vmName} --command-id RunShellScript --scripts "

            echo 'Cleaning up existing workspace...'

            echo 'Removing existing /devops.scripts directory if it exists...'
            rm -rf /devops.scripts || echo 'Directory does not exist, skipping removal.'

        " | beautify || {
                    echo "Command execution on VM ${vmName} failed."
                    exit 1
        }

        az vm run-command invoke -g Test -n ${vmName} --command-id RunShellScript --scripts "

            echo 'Creating /opt/ directory if it does not exist...'
            mkdir -p /opt/ || { echo 'Failed to create directory /opt/'; exit 1; }

            echo 'Changing to /opt/ directory...'
            cd /opt/ || { echo 'Failed to change directory to /opt/'; exit 1; }

            echo 'Cloning the repository...'
            git clone https://@github.com//devops.scripts.git || {
                echo 'Git clone failed. Exiting...'
                exit 1
            }

        " | beautify || {
                    echo "Command execution on VM ${vmName} failed."
                    exit 1
        }
        """


        if (OPERATION_TYPE.contains("Update-Certs")) {
            updateCertsOnVM(vmName)
        }

        if (OPERATION_TYPE.contains("Install-Cleanup")) {
            installCleanupOnVM(vmName)
        }
    }
}

node {
    stage('Execute Operation') {
        def virtual_list = virtual_machine.split(',')
        def vmActions = [:]

        virtual_list.each { vmName ->
            vmActions[vmName] = {
                performOps(vmName)
            }
        }

        parallel vmActions
    }
}