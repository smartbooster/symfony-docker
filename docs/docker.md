# Docker

## Install docker engine and docker compose plugin on Ubuntu 22.04

1. Set up Docker's apt repository.

```bash
# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl gnupg
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# Add the repository to Apt sources:
echo \
"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
$(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
```

2. Install the Docker packages.

```bash
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

3. Fix docker permission

```bash
sudo usermod -aG docker $USER
```

_You need to reboot to apply the change_

4. Verify that the Docker Engine installation is successful by running the hello-world image.

```bash
sudo docker run hello-world
```

_This command downloads a test image and runs it in a container. When the container runs, it prints a confirmation 
message and exits._

5. Verify that Docker Compose is installed correctly by checking the version.

```bash
docker compose version
# Expected output:
Docker Compose version vN.N.N
# Where vN.N.N is placeholder text standing in for the latest version.
```

_Instructions taken from [docker official install guide](https://docs.docker.com/engine/install/ubuntu/#install-using-the-repository) and [compose plugin install guide](https://docs.docker.com/compose/install/linux/#install-using-the-repository)._ 

## Update Docker version

To check your current Docker Engine version use the command : `docker version`

### 1. Remove the old installation
```bash
sudo apt remove docker.io docker-compose docker-doc containerd runc
```

### 2. Install dependencies
```bash
sudo apt install ca-certificates curl
```

### 3. Add the official GPG key
```bash
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
```

### 4. Add the official repository
```bash
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] \
https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo $VERSION_CODENAME) stable" | \
sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
```

### 5. Update and install
```bash
sudo apt update
sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

Now check again the version which should be the latest version.

## Clean unused docker images and volumes

First you can scan how much disk space docker used with the following command :

```bash
docker system df
```

If you need to make some space on your machine because your docker related files take too much space, you can run the 
following commands to clean your system :

```bash
# Remove all unused containers, networks, images (both dangling and unreferenced)
# https://docs.docker.com/engine/reference/commandline/system_prune/
docker system prune -a
# Remove all unused local volumes. Unused local volumes are those which are not referenced by any containers. By default, it only removes anonymous volumes.
# https://docs.docker.com/engine/reference/commandline/volume_prune/
docker volumes prune -a
```
