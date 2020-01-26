#!/bin/sh

read  -p 'Notebook username: ' NB_U

# create user
adduser $NB_U
usermod -aG sudo $NB_U


apt update
apt-get upgrade -y

#firewall
ufw allow OpenSSH
yes | ufw enable

#ssh-keys
rsync --archive --chown=$NB_U:$NB_U ~/.ssh /home/$NB_U

# conda
cd /tmp/; curl -O https://repo.anaconda.com/archive/Anaconda3-2019.10-Linux-x86_64.sh
su - $NB_U -c 'bash /tmp/Anaconda3-2019.10-Linux-x86_64.sh -b'
su - $NB_U -c "source ~/anaconda3/etc/profile.d/conda.sh; conda init"

su - $NB_U -c "source ~/anaconda3/etc/profile.d/conda.sh; yes '' | conda update -y -n base -c defaults conda; conda create -y --name notebook python=3; conda activate notebook; conda install -y -c conda-forge pandoc; conda install -y -c simplect clojupyter; jupyter notebook --generate-config; echo $NB_PW > nb_pw.txt; echo $NB_PW >> nb_pw.txt;"

# Rstats
apt install -y apt-transport-https software-properties-common
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9
add-apt-repository 'deb https://cloud.r-project.org/bin/linux/ubuntu bionic/'

apt update -y
apt install -y libcurl4-openssl-dev libxml2-dev libssl-dev libudunits2-dev libcairo2-dev libfontconfig1-dev libpoppler-cpp-dev
apt-get install --yes r-base r-recommended r-base-dev
R -e 'install.packages(c("Rserve", "tidyverse", "ggthemes", "mice", "svglite", "randomForest"), lib="/usr/local/lib/R/site-library")'
