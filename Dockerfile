FROM nvidia/cuda:11.8.0-cudnn8-devel-ubuntu20.04
ENV LANG=C.UTF-8
WORKDIR /root/
ENV TZ="Asia/Tokyo"
ENV DEBIAN_FRONTEND=noninteractive
ENV SUMO_HOME=/usr/share/sumo

# Update and install essential packages
RUN rm -rf /var/lib/apt/lists/* && \
    apt-get update && \
    apt-get upgrade -y 

# Install system dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        software-properties-common && \
    add-apt-repository ppa:deadsnakes/ppa && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        build-essential \
        git \
        wget \
        make \
        libssl-dev \
        zlib1g-dev \
        libbz2-dev \
        libreadline-dev \
        libsqlite3-dev \
        libffi-dev \
        liblzma-dev \
        curl \
        libncurses5-dev \
        libncursesw5-dev \
        xz-utils \
        tk-dev \
        libgdbm-dev \
        libc6-dev \
        libexpat1-dev \
        gcc \
        tcl \
        tcl-dev \
        python3.10 \
        python3.10-dev \
        python3.10-venv \
        python3-pip \
        software-properties-common \ 
        lsb-release \
        openjdk-17-jdk \ 
        openjdk-17-jre && \
    wget https://github.com/Kitware/CMake/releases/download/v3.21.4/cmake-3.21.4-linux-x86_64.tar.gz && \
    tar -xvf cmake-3.21.4-linux-x86_64.tar.gz && \
    cp -r cmake-3.21.4-linux-x86_64/bin/* /usr/local/bin/ && \
    cp -r cmake-3.21.4-linux-x86_64/share/* /usr/local/share/ && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Set Python 3.10 as the default python3 interpreter
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.10 1 && \
    update-alternatives --config python3

# Force a fresh installation of pip
RUN apt-get update && apt-get install -y curl && \
    curl -sS https://bootstrap.pypa.io/get-pip.py | python3.10 && \
    python3.10 -m pip install --upgrade "pip<24" && \
    python3.10 -m pip install torch==2.2.0 torchvision==0.17.0 torchaudio==2.2.0 --index-url https://download.pytorch.org/whl/cu118 && \
    python3.10 -m pip install ma_gym==0.0.13 

# Install No Gil Python 3.10
RUN git clone https://github.com/jackyk02/python-nogil && \
    cd python-nogil && \
    ./configure --enable-shared CFLAGS=-fPIC && \
    make -j$(nproc) && \
    make install && \
    ldconfig

# Clone and build lingua-franca
RUN cd ~/.. && \
    git clone https://github.com/lf-lang/lingua-franca.git && \
    cd lingua-franca && \
    git checkout d4201912c65cfe6e944dbf12c6ce9cf446d6c90c && \
    git submodule update --init --recursive && \
    ./gradlew assemble
        

# Clone the benchmark repository
# RUN git clone https://github.com/jackyk02/parallel_rl_benchmarks.git

# Set up and build the example in the benchmark
# RUN cd /parallel_rl_benchmarks/6.Multi_Agent_Inference/lf_src_file && \
#     /lingua-franca/build/install/lf-cli/bin/lfc trafficv4.lf && \
#     cp /parallel_rl_benchmarks/6.Multi_Agent_Inference/marl_4_agents/lf/policy_agent_*.pth \
#        /parallel_rl_benchmarks/6.Multi_Agent_Inference/lf_src_file/src-gen/trafficv4

# ==================================================================
# config & cleanup
# ------------------------------------------------------------------

RUN rm /usr/local/bin/python3 && \
    ln -s /usr/bin/python3.10 /usr/local/bin/python3 && \
    ldconfig && \
    apt-get -y clean && \
    apt-get -y autoremove && \
    rm -rf /var/lib/apt/lists/* /tmp/* 
