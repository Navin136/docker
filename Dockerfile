FROM ubuntu:latest
MAINTAINER Navin136

# Environment Variables
ENV DEBIAN_FRONTEND noninteractive
ENV LANG=C.UTF-8
ENV JAVA_OPTS=" -Xmx7G "
ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
ENV USE_CCACHE=1
ENV HOME=/root
WORKDIR /tmp

# Install Required Packages while building docker image
RUN apt-get update -y
RUN apt-get update -y
RUN apt-get install ccache locales wget curl rclone zip unzip bc bison build-essential zlib1g-dev libzstd-dev lib32z1-dev flex g++ g++-multilib gawk gcc gcc-multilib git gnupg gperf nano tmate sudo tar libncurses5-dev libssl-dev libxml-simple-perl apt-utils texinfo unzip w3m xsltproc zip zlib1g-dev lzip pngquant python2.7 python-all-dev re2c schedtool squashfs-tools subversion maven ncftp ncurses-dev patch patchelf pkg-config pngcrush libsdl1.2-dev libssl-dev libtool libxml2 libxml2-utils '^lzma.*' lzop libexpat1-dev libgmp-dev '^liblz4-.*' '^liblzma.*' libmpc-dev libmpfr-dev libncurses5-dev htop imagemagick lib32ncurses5-dev lib32z1-dev libtinfo5 libc6-dev libcap-dev clang cmake flex adb autoconf automake axel -y
RUN apt-get install gcc llvm lld g++-multilib clang git libxml2 python2 python-is-python3 python3-pip gcc llvm lld g++-multilib clang default-jre git automake lzop bison gperf build-essential zip curl zlib1g-dev g++-multilib libxml2-utils bzip2 libbz2-dev libbz2-1.0 libghc-bzlib-dev squashfs-tools pngcrush schedtool dpkg-dev liblz4-tool make optipng bc libstdc++6 libncurses5 wget python3 python3-pip gcc clang libssl-dev rsync flex git-lfs libz3-dev libz3-4 axel tar bc binutils-dev bison build-essential ca-certificates ccache clang cmake curl file flex git libelf-dev libssl-dev lld make ninja-build python3-dev texinfo u-boot-tools xz-utils zlib1g-dev -y
RUN apt-get install tzdata flex bison pigz -y
RUN apt-mark hold tzdata
RUN echo 'en_US.UTF-8 UTF-8' > /etc/locale.gen
RUN /usr/sbin/locale-gen
RUN ln -snf /usr/share/zoneinfo/Asia/Kolkata /etc/localtime
RUN echo Asia/Kolkata > /etc/timezone
RUN curl --create-dirs -L -o /usr/local/bin/repo -O -L https://storage.googleapis.com/git-repo-downloads/repo
RUN chmod a+rx /usr/local/bin/repo
RUN git config --global user.name Navin136
RUN git config --global user.email nkwhitehat@gmail.com

# Copt Rootfs
COPY rootfs /
