FROM ubuntu:bionic

WORKDIR /tmp

# Versioning
ENV MAVEN_VERSION 3.6.0
ENV GRADLE_VERSION 5.6.4
ENV RUBY_VERSION 3.1.1

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

# install jdk 12
RUN curl -L -o openjdk12.tar.gz https://download.java.net/java/GA/jdk12.0.2/e482c34c86bd4bf8b56c0b35558996b9/10/GPL/openjdk-12.0.2_linux-x64_bin.tar.gz && \
    tar xvf openjdk12.tar.gz && \
    rm openjdk12.tar.gz && \
    sudo mv jdk-12.0.2 /opt/ && \
    sudo rm /opt/jdk-12.0.2/lib/src.zip
ENV JAVA_HOME=/opt/jdk-12.0.2
ENV PATH=$PATH:$JAVA_HOME/bin
RUN java -version

# install maven
RUN curl -O https://archive.apache.org/dist/maven/maven-3/$MAVEN_VERSION/binaries/apache-maven-$MAVEN_VERSION-bin.tar.gz && \
    tar -xf apache-maven-$MAVEN_VERSION-bin.tar.gz; rm -rf apache-maven-$MAVEN_VERSION-bin.tar.gz && \
    mv apache-maven-$MAVEN_VERSION /usr/local/lib/maven && \
    ln -s /usr/local/lib/maven/bin/mvn /usr/local/bin/mvn

# install gradle
RUN curl -L -o gradle.zip https://services.gradle.org/distributions/gradle-$GRADLE_VERSION-bin.zip && \
    unzip -q gradle.zip && \
    rm gradle.zip && \
    mv gradle-$GRADLE_VERSION /root/gradle
ENV PATH=/root/gradle/bin:$PATH

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
