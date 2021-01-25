FROM rust:1.49.0-buster

LABEL version="1.0"
LABEL description="Build crosvm, libminijail.so and seccomp policies."
LABEL maintainer="adam@adamkaminski.com"

ENV MINIJAIL_REPO=https://android.googlesource.com/platform/external/minijail
ENV CROSVM_REPO=https://chromium.googlesource.com/chromiumos/platform/crosvm
ENV ADHD_REPO=https://chromium.googlesource.com/chromiumos/third_party/adhd
ENV PLATFORM2_REPO=https://chromium.googlesource.com/chromiumos/platform2

# install dependencies
ARG DEBIAN_FRONTEND=noninteractive
RUN apt update && apt install -y \
    git \
    libcap-dev \
    libfdt-dev \
    && rm -rf /var/lib/apt/lists/*

# minijail
ARG MINIJAIL_COMMIT=master
RUN git clone ${MINIJAIL_REPO} aosp/external/minijail && \
    cd /aosp/external/minijail && \
    git checkout ${MINIJAIL_COMMIT}

# crosvm
ARG CROSVM_COMMIT=master
RUN git clone ${CROSVM_REPO} platform/crosvm && \
    cd /platform/crosvm && \
    git checkout ${CROSVM_COMMIT}

# adhd
ARG ADHD_COMMIT=master
RUN git clone ${ADHD_REPO} third_party/adhd && \
    cd /third_party/adhd && \
    git checkout ${ADHD_COMMIT}

# platform2
ARG PLATFORM2_COMMIT=master
RUN git clone ${PLATFORM2_REPO} && \
    cd /platform2 && \
    git checkout ${PLATFORM2_COMMIT}

# buiild and install minijail
WORKDIR /aosp/external/minijail
RUN make && \
    cp libminijail.so /usr/lib/ && \
    cp libminijail.h /usr/include/

RUN ldconfig

# build crosvm
WORKDIR /platform/crosvm
RUN cargo build --no-default-features --release
    
RUN mkdir /out && \
    cp /aosp/external/minijail/libminijail.so /out && \
    cp /platform/crosvm/target/release/crosvm /out && \
    cp -r /platform/crosvm/seccomp /out

WORKDIR /out
ENTRYPOINT ["tar", "cf", "-", "libminijail.so", "crosvm", "seccomp"]
