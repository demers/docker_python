FROM ubuntu:18.04

MAINTAINER FND <fndemers@gmail.com>

ENV TERM=xterm\
    TZ=America/Toronto\
    DEBIAN_FRONTEND=noninteractive

# Access SSH login
ENV USERNAME=ubuntu
ENV PASSWORD=ubuntu

ENV EMAIL="fndemers@gmail.com"
ENV NAME="F.-Nicola Demers"

ENV PROJECTNAME=PYTHON3

ENV WORKDIRECTORY /home/ubuntu

RUN apt-get update

RUN apt install -y apt-utils

RUN apt-get install -y vim-nox curl git exuberant-ctags

# Install a basic SSH server
RUN apt install -y openssh-server
RUN sed -i 's|session    required     pam_loginuid.so|session    optional     pam_loginuid.so|g' /etc/pam.d/sshd
RUN mkdir -p /var/run/sshd
RUN /usr/bin/ssh-keygen -A

# Add user to the image
RUN adduser --quiet --disabled-password --shell /bin/bash --home /home/${USERNAME} --gecos "User" ${USERNAME}
# Set password for the Ubuntu user (you may want to alter this).
RUN echo "$USERNAME:$PASSWORD" | chpasswd

RUN apt-get clean && apt-get -y update && apt-get install -y locales && locale-gen fr_CA.UTF-8
ENV TZ=America/Toronto
RUN unlink /etc/localtime
RUN ln -s /usr/share/zoneinfo/$TZ /etc/localtime

RUN apt install -y fish

# Ajout des droits sudoers
RUN apt-get install -y sudo
RUN echo "%ubuntu ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

RUN echo "export DISPLAY=:0.0" >> ${WORKDIRECTORY}/.bash_profile
RUN echo "export DISPLAY=:0.0" >> /root/.bash_profile

# Installation X11.
RUN apt install -y xauth vim-gtk

RUN apt-get update
RUN apt-get install -y build-essential cmake python3-dev

RUN apt -qy install gcc g++ make

RUN apt install -y software-properties-common apt-transport-https wget

# Installation Python 3
RUN apt install -y git python3 python3-pip python3-mock python3-tk
# Mise à jour PIP
RUN pip3 install --upgrade pip
RUN pip3 install flake8
RUN pip3 install flake8-docstrings
RUN pip3 install pylint
ENV PYTHONIOENCODING=utf-8

## Clean up when done
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

WORKDIR ${WORKDIRECTORY}

RUN git clone https://github.com/pyenv/pyenv.git ${WORKDIRECTORY}/.pyenv
RUN echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ${WORKDIRECTORY}/.bash_profile
RUN echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> ${WORKDIRECTORY}/.bash_profile
RUN echo 'eval "$(pyenv init -)"' >> ${WORKDIRECTORY}/.bash_profile

RUN echo "git config --global user.email '$EMAIL'" >> ${WORKDIRECTORY}/.bash_profile
RUN echo "git config --global user.name '$NAME'" >> ${WORKDIRECTORY}/.bash_profile

RUN cd ${WORKDIRECTORY} \
    && git clone git://github.com/zaiste/vimified.git \
    && ln -sfn vimified/ ${WORKDIRECTORY}/.vim \
    && ln -sfn vimified/vimrc ${WORKDIRECTORY}/.vimrc \
    && cd vimified \
    && mkdir bundle \
    && mkdir -p tmp/backup tmp/swap tmp/undo \
    && git clone https://github.com/gmarik/vundle.git bundle/vundle \
    && echo "let g:vimified_packages = ['general', 'coding', 'fancy', 'indent', 'css', 'os', 'ruby', 'js', 'haskell', 'python', 'color']" > local.vimrc

COPY after.vimrc ${WORKDIRECTORY}/vimified/

COPY extra.vimrc ${WORKDIRECTORY}/vimified

# Générer les tags de ctags.
RUN echo "ctags -f ${WORKDIRECTORY}/mytags -R ${WORKDIRECTORY}" >> ${WORKDIRECTORY}/.bash_profile

# Compiling YouCompleteMe only once...
RUN echo "if ! [ -f ~/.runonce_install ]; then" >> ${WORKDIRECTORY}/.bash_profile
RUN echo "touch ~/.runonce_install" >> ${WORKDIRECTORY}/.bash_profile
RUN echo "vim +BundleInstall +qall" >> ${WORKDIRECTORY}/.bash_profile
RUN echo "cd ~/.vim/bundle/YouCompleteMe" >> ${WORKDIRECTORY}/.bash_profile
RUN echo "./install.py --clang-completer" >> ${WORKDIRECTORY}/.bash_profile
RUN echo "fi" >> ${WORKDIRECTORY}/.bash_profile
RUN echo "cd ~/" >> ${WORKDIRECTORY}/.bash_profile

RUN echo "export PS1=\"\\e[0;31m $PROJECTNAME\\e[m \$PS1\"" >> ${WORKDIRECTORY}/.bash_profile

RUN echo "export PYTHONPATH=." >> ${WORKDIRECTORY}/.bash_profile

RUN cd ${WORKDIRECTORY} \
    && mkdir work \
    && chown -R $USERNAME:$USERNAME work vimified .vim .vimrc .bash_profile .pyenv

RUN pip3 install twisted
RUN pip3 install python-interface utils

# Standard SSH port
EXPOSE 22

# Start SSHD server...
CMD ["/usr/sbin/sshd", "-D"]

