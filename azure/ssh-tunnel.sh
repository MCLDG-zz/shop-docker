#establish ssh tunnel to Mesos master. See https://azure.microsoft.com/en-us/documentation/articles/container-service-connect/
ssh -L 80:localhost:80 -f -N mcdg@mcdgdnsmgmt.eastus.cloudapp.azure.com -p 2200 -i /c/Users/IBM_ADMIN/AzureKeys/myAzurePrivateKey_rsa

#
#You can now access the DC/OS-related endpoints at:
#
#    DC/OS: http://localhost/
#    Marathon: http://localhost/marathon
#    Mesos: http://localhost/mesos
#
#Similarly, you can reach the rest APIs for each application through this tunnel.
