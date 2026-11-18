#!/bin/env bash
# This was written for Ubuntu 24.04 LTS
# The script is to be executed as the superuser ("sudo su")
# Some inputs are expected while the script is being run

read -p "Enter your username: " username
#username="ubuntu"
# Check username correctness
[[ $(grep "^${username}:" /etc/passwd) ]] || (read -p "Invalid user name. Exiting" && exit)

sourcedir="/home/${username}/bin/source"
bindir="/home/${username}/bin"
#Enter MODELLER installation key. You only have to register and replace "xxx" with it. 
#** read -p "Enter your MODELLER key: " modeller_key
modeller_key="MODELIRANJE"

apt update

apt install -y ttf-mscorefonts-installer ubuntu-restricted-extras

#Directory for downloaded sources
mkdir -p ${sourcedir}
mkdir -p ${bindir}

# Dowload binaries ahead of time
cd ${sourcedir} 
wget https://download1.rstudio.org/electron/jammy/amd64/rstudio-2026.04.0-526-amd64.deb &
wget https://repo.anaconda.com/archive/Anaconda3-2025.12-2-Linux-x86_64.sh &
#wget https://ccsb.scripps.edu/mgltools/download/491/ -O mgltools.tar.gz & this site has connection issues, try later
wget https://www.ks.uiuc.edu/Research/vmd/vmd-1.9.3/files/final/vmd-1.9.3.bin.LINUXAMD64-CUDA8-OptiX4-OSPRay111p1.opengl.tar.gz &
wget https://az764295.vo.msecnd.net/stable/441438abd1ac652551dbe4d408dfcec8a499b8bf/code_1.75.1-1675893397_amd64.deb &
wget https://www.jalview.org/getdown/release/install4j/1.8/jalview-2_11_5_1-linux-x64-java_8.sh &

wait

#Generic installations
apt install -y vim git muscle autodock autogrid autodock-vina grace cmake g++ gedit csh tcsh libcanberra-gtk-module   # (failed to install)
#Latex installation
apt-get install texlive texstudio

#Set up vim profile for python (code highlighting & indentation)
cd /home/${username}
if [ -f .vimrc ];then cp .vimrc ".vimrc$(date +%s)";fi
echo "syntax on" > /home/${username}/.vimrc
echo "filetype indent plugin on" >> /home/${username}/.vimrc

# Display paging info in less
echo "LESS+='-M'" >> /home/${username}/.bashrc

# Install R
apt update -qq
apt install -y --no-install-recommends software-properties-common dirmngr
wget -qO- https://cloud.r-project.org/bin/linux/ubuntu/marutter_pubkey.asc | sudo tee -a /etc/apt/trusted.gpg.d/cran_ubuntu_key.asc
add-apt-repository -y "deb https://cloud.r-project.org/bin/linux/ubuntu $(lsb_release -cs)-cran40/"
apt install -y --no-install-recommends r-base
add-apt-repository -y ppa:c2d4u.team/c2d4u4.0+

# Install RStudio
cd $sourcedir 
apt install -y lib32gcc-s1 lib32stdc++6 libc6-i386 libclang-14-dev libclang-common-14-dev libclang-dev libclang1-14 libllvm14 libobjc-11-dev libobjc4 libpq5 libssl-dev

#wget https://download1.rstudio.org/electron/jammy/amd64/rstudio-2026.01.0-392-amd64.deb
[[ -f rstudio-2026.04.0-526-amd64.deb ]] && dpkg -i rstudio-2026.04.0-526-amd64.deb;apt -f install

#install jalview
[[ -f jalview-2_11_5_1-linux-x64-java_8.sh ]] && bash jalview-2_11_5_1-linux-x64-java_8.sh

#Get anaconda
#wget https://repo.anaconda.com/archive/Anaconda3-2025.12-2-Linux-x86_64.sh
[[ -f Anaconda3-2025.12-2-Linux-x86_64.sh  ]] && bash Anaconda3-2025.12-2-Linux-x86_64.sh  -b -p $bindir/conda && . ${bindir}/conda/bin/activate && conda init


# Switching to a different c and c++ compile this saves a lot of headache with gromacs installation
#apt -y install gcc-10 g++-10 gcc-11 g++-11 gcc-12 g++-12
#update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-10 10
#update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-10 10
#pdate-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-11 11
#update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-11 11
#update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-12 12
#update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-12 12
#
##Here, select the number corresponding to the gcc and g++ version you want to switch to
#update-alternatives --config gcc
#update-alternatives --config g++
#Install the ubuntu specific nvidia-cuda-toolkit with the new stuff
apt install nvidia-cuda-toolkit
##
## Install cuda toolkit as per cuda website
wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2404/x86_64/cuda-ubuntu2404.pin
mv cuda-ubuntu2404.pin /etc/apt/preferences.d/cuda-repository-pin-600
wget https://developer.download.nvidia.com/compute/cuda/13.2.1/local_installers/cuda-repo-ubuntu2404-13-2-local_13.2.1-595.58.03-1_amd64.deb
[[ -f cuda-repo-ubuntu2404-13-2-local_13.2.1-595.58.03-1_amd64.deb ]] && dpkg -i cuda-repo-ubuntu2404-13-2-local_13.2.1-595.58.03-1_amd64.deb
cp /var/cuda-repo-ubuntu2404-13-2-local/cuda-*-keyring.gpg /usr/share/keyrings/
apt-get update
apt-get -y install cuda-toolkit-13-2
##
# Fix color representation in git
echo "export LESS=-R" >> /home/${username}/.bashrc
 
conda config --add channels defaults
conda config --add channels bioconda
conda config --add channels conda-forge
#Accept terms and conditions
conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/main
conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/r

#python 3.11
#conda install -c conda-forge python=3.11   #Some packages might not work with newer python so installed this one before hand

#Accept terms and conditions
conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/main
conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/r

# Openbabel
#conda install -y -c openbabel openbabel

# ACPYPE
#conda install -y -c conda-forge acpype
conda create -n acpype -y -c conda-forge python=3.11 acpype pymol-open-source

#ambertools
conda create -n ambertools -y -c conda-forge python=3.11 ambertools

#pyemma 2.5.7
conda create -n pyemma257 -y -c conda-forge python=3.7 pyemma=2.5.7

#MODELLER
conda config --add channels salilab
conda install -y -c salilab modeller
sed -i "s/XXXX/${modeller_key}/" ${bindir}/conda/lib/modeller-*.*/modlib/modeller/config.py

#Install Open-Source PyMOL
conda install -y -c conda-forge pymol-open-source

#Installing GROMACS  ## We are going to install this manualy after installing nvidia toolkit
cd ${sourcedir}
gmxver="2024"
wget ftp://ftp.gromacs.org/pub/gromacs/gromacs-${gmxver}.tar.gz
tar xfz gromacs-${gmxver}.tar.gz
cd gromacs-${gmxver}
mkdir build && cd build
cmake .. -DGMX_BUILD_OWN_FFTW=ON -DREGRESSIONTEST_DOWNLOAD=ON #-DGMX_GPU=CUDA -DCUDAToolkit_ROOT=/usr/local/cuda
make -j`nproc`
make -j`nproc` check
make install
echo "#GROMACS" >> /home/${username}/.bashrc

# The 7 - NbLibSetupTests (Failed). This is caused by a mismatch in your C/C++ compiler version, missing dependencies, or conflicting GPU driver versions. Not sure if the gmx is then correctly configured, we shall see.


#PROPKA and PDB2PQR
cd ${sourcedir} && git clone https://github.com/jensengroup/propka && cd propka && pip install .
cd ${sourcedir} && git clone https://github.com/Electrostatics/pdb2pqr && cd pdb2pqr && pip install .

# Vina alternatives 
cd ${sourcedir}
git clone https://github.com/QVina/qvina && chmod +x ${sourcedir}/qvina/bin/qvina*
git clone https://github.com/sirimullalab/vinaXB
conda install -y -c bioconda smina
ln -s ${sourcedir}/vinaXB/linux/vinaXB ${bindir}/vinaXB
ln -s ${sourcedir}/qvina/bin/qvina02 ${bindir}/qvina02
ln -s ${sourcedir}/qvina/bin/qvina-w ${bindir}/qvina-w

#VMD
cd ${sourcedir}
apt install -y rlwrap
#wget https://www.ks.uiuc.edu/Research/vmd/vmd-1.9.3/files/final/vmd-1.9.3.bin.LINUXAMD64-CUDA8-OptiX4-OSPRay111p1.opengl.tar.gz
[[ -f vmd-1.9.3.bin.LINUXAMD64-CUDA8-OptiX4-OSPRay111p1.opengl.tar.gz ]] && tar zxvf vmd-1.9.3.bin.LINUXAMD64-CUDA8-OptiX4-OSPRay111p1.opengl.tar.gz
cd vmd-1.9.3
./configure && cd src
make install
sed -i 's/-b(){}\[\],\&\^%#;|\\\\//' /usr/local/bin/vmd

#VS Code
cd ${sourcedir}
wget https://vscode.download.prss.microsoft.com/dbazure/download/stable/91fbdddc47bc9c09064bf7acf133d22631cbf083/code_1.96.3-1736454372_amd64.deb -O vscode.deb
[[ -f vscode.deb ]] && dpkg -i vscode.deb

#Installing MGLTools we shall try this later, the site is down
cd ${sourcedir}
#wget https://ccsb.scripps.edu/mgltools/download/491/ -O mgltools.tar.gz
#[[ -f mgltools.tar.gz ]] && tar -zxvf mgltools.tar.gz
#mgltools_ver=`ls -d mgltools_x86_64Linux2*/ | tr -d /`
#cd ${mgltools_ver}
#./install.sh
#echo "#MGLTools setup">> /home/${username}/.bashrc
#echo ". ${sourcedir}/${mgltools_ver}/initMGLtools.sh" >> /home/${username}/.bashrc
#sed -i "/usr.bin.env python/ c \#\!/usr/bin/env ${sourcedir}/${mgltools_ver}/bin/pythonsh" ${sourcedir}/${mgltools_ver}/MGLToolsPckgs/AutoDockTools/Utilities24/prepare_receptor4.py
#sed -i "/usr.bin.env python/ c \#\!/usr/bin/env ${sourcedir}/${mgltools_ver}/bin/pythonsh" ${sourcedir}/${mgltools_ver}/MGLToolsPckgs/AutoDockTools/Utilities24/prepare_ligand4.py
#echo 'export PATH=$PATH:'"${sourcedir}/${mgltools_ver}/MGLToolsPckgs/AutoDockTools/Utilities24" >> /home/${username}/.bashrc

wait

echo ". /usr/local/gromacs/bin/GMXRC" >> /home/${username}/.bashrc
echo "export PATH=${bindir}:"'${PATH}' >> /home/${username}/.bashrc
echo "unset MANPATH" >> /home/${username}/.bashrc
echo "MANDATORY_MANPATH /usr/local/gromacs/share/man" >> /home/${username}/.manpath

echo "Installations done"

echo "Exit super use and run '/home/rehema/bin/conda/bin/conda init bash', then 'source .bashrc' to initialize conda and activate base environment"
#FOR ACYPYPE INCASE IT FILES TO INSTALL'conda create --name acpype python=3.11''conda activate acpype''conda install -y -c conda-forge acpype'
