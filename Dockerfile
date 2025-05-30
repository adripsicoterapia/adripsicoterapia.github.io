FROM ubuntu:22.04

RUN  apt update
RUN  apt -y upgrade    

#Install locale for the website
RUN  apt install -y locales
RUN  dpkg-reconfigure locales &&  locale-gen C.UTF-8 &&   /usr/sbin/update-locale LANG=C.UTF-8
RUN  echo 'es_MX.UTF-8 UTF-8' >> /etc/locale.gen &&  locale-gen

# Set default locale for the environment
ENV LC_ALL C.UTF-8
ENV LANG es_MX.UTF-8
ENV LANGUAGE es_MX.UTF-8    

# Create the user
RUN echo 'eval "$(rbenv init -)"' >> /etc/profile.d/rbenv.sh
ARG USERNAME=remoteUser
ARG USER_UID=1000
ARG USER_GID=$USER_UID
RUN groupadd --gid $USER_GID $USERNAME \
     && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
     # [Optional] Add sudo support. Omit if you don't need to install software after connecting.     
     && apt-get install -y sudo \
     && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
     && chmod 0440 /etc/sudoers.d/$USERNAME

# ********************************************************
# * Anything else you want to do like clean up goes here *
# ********************************************************

# [Optional] Set the default user. Omit if you want to keep the default as root.
USER $USERNAME
# "#################################################"
# "Install Ubuntu prerequisites for Ruby and GitHub Pages (Jekyll)"
# "Partially based on https://gist.github.com/jhonnymoreira/777555ea809fd2f7c2ddf71540090526"
RUN sudo apt-get -y install git \
    curl \
    autoconf \
    bison \
    build-essential \
    libssl-dev \
    libyaml-dev \
    libreadline6-dev \
    zlib1g-dev \
    libncurses5-dev \
    libffi-dev \
    libgdbm6 \
    libgdbm-dev \
    libdb-dev \
    apt-utils

# "#################################################"
# "GitHub Pages/Jekyll is based on Ruby. Set the version and path"
# "As of this writing, use Ruby 3.4.4
# "Based on: https://talk.jekyllrb.com/t/liquid-4-0-3-tainted/7946/12"
ENV RBENV_ROOT /home/remoteUser/.rbenv
ENV RUBY_VERSION 3.4.4
ENV PATH ${RBENV_ROOT}/bin:${RBENV_ROOT}/shims:$PATH

# "#################################################"
# "Install rbenv to manage Ruby versions"

RUN   git clone https://github.com/rbenv/rbenv.git ${RBENV_ROOT} 
RUN   git clone https://github.com/rbenv/ruby-build.git ${RBENV_ROOT}/plugins/ruby-build 
    
#RUN sudo echo 'eval "$(rbenv init -)"' > /etc/profile.d/rbenv.sh
# "#################################################"
# "Install ruby and set the global version"
RUN  rbenv install ${RUBY_VERSION} \
  && rbenv global ${RUBY_VERSION}
# "#################################################"
# "Install the version of Jekyll that GitHub Pages supports"
# "Based on: https://pages.github.com/versions/"
# "Note: If you always want the latest 3.9.x version,"
# "       use this line instead:"
# "       RUN gem install jekyll -v '~>3.9'"
RUN  gem update --system && gem install jekyll && gem cleanup
