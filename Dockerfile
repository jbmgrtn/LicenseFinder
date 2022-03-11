FROM ubuntu:bionic

WORKDIR /tmp

# Versioning
ENV RUBY_VERSION 3.1.1
ENV JAVA_VERSION 17

# programs needed for building
RUN apt-get update && apt-get install -y \
  build-essential \
  curl \
  sudo \
  unzip \
  wget \
  gnupg2 \
  apt-utils \
  software-properties-common \
  bzr

RUN add-apt-repository ppa:git-core/ppa && apt-get update && apt-get install -y git

# nodejs seems to be required for the one of the gems
RUN curl -sL https://deb.nodesource.com/setup_14.x | bash - && \
    apt-get -y install nodejs

# install JDK
# https://docs.azul.com/core/zulu-openjdk/install/debian#install-from-azul-apt-repository
# add Azul's public key
RUN apt-key adv \
  --keyserver hkp://keyserver.ubuntu.com:80 \
  --recv-keys 0xB1998361219BD9C9
# download and install the package that adds 
# the Azul APT repository to the list of sources 
RUN curl -O https://cdn.azul.com/zulu/bin/zulu-repo_1.0.0-3_all.deb
# install the package
RUN apt-get install ./zulu-repo_1.0.0-3_all.deb
# update the package sources
RUN apt-get update
# install Azul Zulu JDK
RUN apt-get install -y zulu${JAVA_VERSION}-jdk
RUN java -version

WORKDIR /tmp
# Fix the locale
RUN apt-get install -y locales
RUN locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

#install rvm
RUN apt-add-repository -y ppa:rael-gc/rvm && \
    apt update && apt install -y rvm && \
    /usr/share/rvm/bin/rvm install --default $RUBY_VERSION

# install bundler
RUN bash -lc "gem update --system && gem install bundler"

# install license_finder
COPY . /LicenseFinder
RUN bash -lc "cd /LicenseFinder && bundle config set no-cache 'true' && bundle install -j4 && bundle pristine && rake install"

WORKDIR /

CMD cd /scan && /bin/bash -l
