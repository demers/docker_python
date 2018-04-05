FROM ubuntu:17.10

MAINTAINER FND <fndemers@gmail.com>

# Access SSH login
ENV USERNAME=ubuntu
ENV PASSWORD=ubuntu

ENV PROJECTNAME=PYTHON3

ENV WORKDIRECTORY /home/ubuntu

RUN apt-get update

RUN apt-get install -y vim-nox curl git

# Install a basic SSH server
RUN apt install -y openssh-server
RUN sed -i 's|session    required     pam_loginuid.so|session    optional     pam_loginuid.so|g' /etc/pam.d/sshd
RUN mkdir -p /var/run/sshd
RUN /usr/bin/ssh-keygen -A

# Add user to the image
RUN adduser --quiet --disabled-password --shell /bin/bash --home /home/${USERNAME} --gecos "User" ${USERNAME}
# Set password for the Ubuntu user (you may want to alter this).
RUN echo "$USERNAME:$PASSWORD" | chpasswd

RUN apt install -y fish
#RUN chsh -s /usr/bin/fish ubuntu

# Installation X11.
RUN apt install -y xauth vim-gtk

RUN apt-get update

# Installation Python 3
RUN apt install -y git python3 python3-pip python3-mock python3-tk
# Mise à jour PIP
RUN pip3 install --upgrade pip
RUN pip3 install flake8
RUN pip3 install flake8-docstrings
RUN pip3 install pylint

WORKDIR ${WORKDIRECTORY}

RUN git clone https://github.com/pyenv/pyenv.git ~/.pyenv
RUN echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.bash_profile
RUN echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.bash_profile
RUN echo -e 'if command -v pyenv 1>/dev/null 2>&1; then\n  eval "$(pyenv init -)"\nfi' >> ~/.bash_profile

RUN cd ${WORKDIRECTORY} \
    && git clone git://github.com/zaiste/vimified.git \
    && ln -sfn vimified/ ~/.vim \
    && ln -sfn vimified/vimrc ~/.vimrc \
    && cd vimified \
    && mkdir bundle \
    && mkdir -p tmp/backup tmp/swap tmp/undo \
    && git clone https://github.com/gmarik/vundle.git bundle/vundle \
    && echo "let g:vimified_packages = ['general', 'coding', 'fancy', 'indent', 'css', 'os', 'ruby', 'js', 'haskell', 'python', 'color']" > local.vimrc

COPY after.vimrc ${WORKDIRECTORY}/vimified/

COPY extra.vimrc ${WORKDIRECTORY}/vimified

RUN cd ${WORKDIRECTORY} \
    && ln -s vimified .vim \
    && ln -s vimified/vimrc .vimrc

RUN echo "vim +BundleInstall +qall" >> ${WORKDIRECTORY}/.bash_profile
#RUN vim +BundleInstall +qall 2&> /dev/null

RUN echo "export PS1=\"\\e[0;31m $PROJECTNAME\\e[m \$PS1\"" >> ${WORKDIRECTORY}/.bash_profile

RUN echo "export PYTHONPATH=." >> ${WORKDIRECTORY}/.bash_profile

RUN cd ${WORKDIRECTORY} \
    && mkdir work \
    && chown -R $USERNAME:$PASSWORD work vimified .vim .vimrc .bash_profile

# Standard SSH port
EXPOSE 22

# Start SSHD server...
CMD ["/usr/sbin/sshd", "-D"]

