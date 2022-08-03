ARG CUDA_VERSION=11.6.2
ARG OS_VERSION=20.04
ARG TRT_VERSION=8.4.2

# ---------------------------------------------------------------------------
FROM nvcr.io/nvidia/cuda:${CUDA_VERSION}-cudnn8-runtime-ubuntu${OS_VERSION} as tensorrt-runner
# ---------------------------------------------------------------------------

ARG TRT_VERSION
ARG CUDA_VERSION

ENV DEBIAN_FRONTEND noninteractive

RUN v="${TRT_VERSION%.*}-1+cuda${CUDA_VERSION%.*}" \
  && apt update -y && apt install -y \
  libnvinfer8=${v} \
  libnvonnxparsers8=${v} \
  libnvparsers8=${v} \
  libnvinfer-plugin8=${v} \
  && rm -rf /var/lib/apt/lists/*

# -----------------------------------------------------------------
FROM nvcr.io/nvidia/cuda:${CUDA_VERSION}-cudnn8-devel-ubuntu${OS_VERSION} as builder
# -----------------------------------------------------------------

ARG TRT_VERSION
ARG CUDA_VERSION

ENV DEBIAN_FRONTEND noninteractive

RUN v="${TRT_VERSION%.*}-1+cuda${CUDA_VERSION%.*}" \
  && apt update -y && apt install -y \
  libnvinfer-dev=${v} \
  libnvonnxparsers-dev=${v} \
  libnvparsers-dev=${v} \
  libnvinfer-plugin-dev=${v} \
  wget \
  git \
  zlib1g-dev \
  libzip-dev \
  && rm -rf /var/lib/apt/lists/*

RUN wget https://github.com/Kitware/CMake/releases/download/v3.24.0-rc5/cmake-3.24.0-rc5-linux-x86_64.sh \
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

RUN apt update -y && apt install --no-install-recommends -y \
  zlib1g-dev \
  libzip-dev \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY --from=builder /KataGo/cpp/build/katago /app/katago
RUN chmod +x /app/katago

ENTRYPOINT ["/app/katago"]
