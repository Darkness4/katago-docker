ARG os="ubuntu2004"
ARG tag="cuda11.4-trt8.2.0.6-ea-20210922"

# ---------------------------------------------------------------------------
FROM nvcr.io/nvidia/cuda:11.4.2-cudnn8-runtime-ubuntu20.04 as tensorrt-runner
# ---------------------------------------------------------------------------

ARG os
ARG tag

ENV DEBIAN_FRONTEND noninteractive

COPY ./nv-tensorrt-repo-${os}-${tag}_1-1_amd64.deb ./nv-tensorrt-repo-${os}-${tag}_1-1_amd64.deb
RUN dpkg -i ./nv-tensorrt-repo-${os}-${tag}_1-1_amd64.deb
RUN apt-key add /var/nv-tensorrt-repo-${os}-${tag}/7fa2af80.pub \
  && apt update -y \
  && apt install --no-install-recommends -y libnvinfer-bin libnvinfer8 libnvparsers8 libnvonnxparsers8 libnvinfer-plugin8 zlib1g-dev libzip-dev \
  && rm -rf /var/lib/apt/lists/*

# -----------------------------------------------------------------
FROM nvcr.io/nvidia/cuda:11.4.2-cudnn8-devel-ubuntu20.04 as builder
# -----------------------------------------------------------------

ARG os
ARG tag

ENV DEBIAN_FRONTEND noninteractive

COPY ./nv-tensorrt-repo-${os}-${tag}_1-1_amd64.deb ./nv-tensorrt-repo-${os}-${tag}_1-1_amd64.deb
RUN dpkg -i ./nv-tensorrt-repo-${os}-${tag}_1-1_amd64.deb
RUN apt-key add /var/nv-tensorrt-repo-${os}-${tag}/7fa2af80.pub \
  && apt update -y \
  && apt install -y git build-essential wget tensorrt zlib1g-dev libzip-dev \
  && rm -rf /var/lib/apt/lists/*

RUN wget https://github.com/Kitware/CMake/releases/download/v3.22.0-rc2/cmake-3.22.0-rc2-linux-x86_64.sh \
  -q -O /tmp/cmake-install.sh \
  && chmod u+x /tmp/cmake-install.sh \
  && apt remove --purge -y cmake \
  && /tmp/cmake-install.sh --skip-license --prefix=/usr/local \
  && rm /tmp/cmake-install.sh

WORKDIR /

RUN git clone https://github.com/lightvector/KataGo.git && mkdir -p /KataGo/cpp/build

WORKDIR /KataGo/cpp/build

RUN cmake .. -DUSE_BACKEND=TENSORRT
RUN make -j$(nproc)

# ------------------
FROM tensorrt-runner
# ------------------

WORKDIR /app

COPY --from=builder /KataGo/cpp/build/katago /app/katago
RUN chmod +x /app/katago

ENTRYPOINT ["/app/katago"]
