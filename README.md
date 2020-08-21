# update-iks-client
Docker image for updating the client versions in the iks-client image

1. Create a SSH key pair (e.g. update-iks-client.pem & update-iks-client.pub)
2. Add the public key to your GitHub profile
3. Copy the private key to this directory
4. Update the `update.sh` script with the name of your private key (e.g. update-iks-client.pem) and the GitHub repo name containing the iks-client
5. Update the `build.sh` script with your email address and GitHub name you want the commits associated with
6. Run `build.sh` to build the image
7. Run `update.sh` to run the image and update your iks-client

