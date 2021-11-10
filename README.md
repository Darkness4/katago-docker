# KataGo Docker / Remote / Slurm+Pyxis

This guide is meant to run KataGo with TensorRT in a container.

It may also work with other version of KataGo (OpenCL, CUDA, Eigen), but you will have to edit the Dockerfile.

## Run KataGo in a Docker container

1. Install Docker. If you are using NVIDIA, you have to install the [NVIDIA Container Runtime](https://nvidia.github.io/nvidia-container-runtime/).

2. Clone the repository.

4. Build the docker image or use `darkness4/katago:cuda11.4.2-cudnn8-ubuntu20.04-trt8.2.0.6-ea` :

   ```sh
   docker build -t katago:tensorrt .
   ```
   
5. Download a KataGo model from [KataGo Training](https://katagotraining.org) and name it `default_model.bin.gz`.
6. Create an executable (shell script) to run katago :

   ```sh
   #!/bin/sh
   # katago.sh
   
   docker run --rm --gpus all -i \
     -v "$(pwd)/default_gtp.cfg:/app/default_gtp.cfg:ro" \
     -v "$(pwd)/default_model.bin.gz:/app/default_model.bin.gz" \
     katago:tensorrt \
     $@
   
   ```
   
7. Use `katago.sh` as the main entrypoint.

   ```sh
   chmod +x katago.sh
   ./katago.sh --help
   ```

## Run KataGo remotely with Docker and SSH

**On the remote machine:**

1. Install the SSH server and [push your ssh key to your user](https://www.ssh.com/academy/ssh/copy-id). The authentication must not use a password.

2. Install Docker in the remote machine. If you are using NVIDIA, you have to install the [NVIDIA Container Runtime](https://nvidia.github.io/nvidia-container-runtime/).

3. Clone the repository.

5. Build the docker image or use `darkness4/katago:cuda11.4.2-cudnn8-ubuntu20.04-trt8.2.0.6-ea` :

   ```sh
   docker build -t katago:tensorrt .
   ```
   
6. Download a KataGo model from [KataGo Training](https://katagotraining.org) and name it `default_model.bin.gz`.

7. Create an executable (shell script) to run katago :

   ```sh
   #!/bin/sh
   # /home/remote-user/katago.sh

   docker run --rm --gpus all -i \
     -v "$(pwd)/default_gtp.cfg:/app/default_gtp.cfg:ro" \
     -v "$(pwd)/default_model.bin.gz:/app/default_model.bin.gz" \
     katago:tensorrt \
     $@

   ```

8. Make it executable and test it.

   ```sh
   chmod +x katago.sh
   ./katago.sh --help
   ```

**On your local machine:**

1. Create an executable

   ```sh
   #!/bin/sh
   # katago-remote.sh

   ssh remote-user@remote-machine /home/remote-user/katago.sh $@
   ```

2. Make it executable and test it.

   ```sh
   chmod +x katago-remote.sh
   ./katago-remote.sh --help
   ```

## Run KataGo on Slurm+Pyxis

**On any machine:**

Skip this part if you perfer to use the Docker image `darkness4/katago:cuda11.4.2-cudnn8-ubuntu20.04-trt8.2.0.6-ea`.

1. Clone the repository.

3. Build the docker image:

   ```sh
   docker build -t user/katago:tensorrt .
   ```
   
4. Push in a registry:

   ```sh
   docker push user/katago:tensorrt
   ```

**On the remote machine:**

1. Install Slurm, Pyxis, Enroot, [NVIDIA Container Runtime](https://nvidia.github.io/nvidia-container-runtime/).
2. Download a KataGo model from [KataGo Training](https://katagotraining.org) and name it `default_model.bin.gz`. You have also to put the `default_gtp.cfg`.
3. Create an executable (shell script) to run katago in a slurm job:

   ```sh
   #!/bin/sh
   # /home/remote-user/katago.sh

   set -ex

   if [ ! -f "$(pwd)/katago.sqsh" ]; then
     srun --ntasks=1 \
       --container-image=user/katago:tensorrt \
       --container-save="$(pwd)/katago.sqsh" \
       true
   fi

   tries=1; while [ "$tries" -lt 10 ]; do
     if file "$(pwd)/katago.sqsh" | grep -q "Squashfs  filesystem"; then
       break
     fi
     echo "Image is not complete. Wait a few seconds... ($tries/ 10)"
     sleep 10
     tries=$((tries+1))
   done
   if [ "$tries" -ge 10 ]; then
     echo "Image import failure. Please try again."
     exit 1
   fi

   srun --gpus=1 \
     --container-image="$(pwd)/katago.sqsh" \
     --container-mounts="$(pwd)/default_gtp.cfg:/app/default_gtp. cfg:ro,$(pwd)/default_model.bin.gz:/app/default_model.bin. gz:ro" \
     /app/katago $@

   ```

4. Make it executable and test it.

   ```sh
   chmod +x katago.sh
   ./katago.sh --help
   ```

**On your local machine:**

1. Create an executable

   ```sh
   #!/bin/sh
   # katago-remote.sh

   ssh remote-user@remote-machine /home/remote-user/katago.sh $@
   ```

2. Make it executable and test it.

   ```sh
   chmod +x katago-remote.sh
   ./katago-remote.sh --help
   ```

