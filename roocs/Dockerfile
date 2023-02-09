#============================================================================================
#
#  This Dockerfile can be used either in a dev container or with standalone docker.
#  
#  In standalone docker:
#
#     docker build -t roocs . [args]
#
#       where args includes:
#
#         --build-arg start=y     container will start rook automatically when started
#         --build-arg do_tests=y  run the tests when building the container, but they
#                                  are allowed to fail
#         --build-arg do_tests=Y  run the tests when building the container, and any
#                                  failures will abort the build               
#
#     docker run -it --name roocs_c -p 127.0.0.1:5000:5000 roocs
#
#     if container not built with start=y, then start by typing:  rook_start
#        [check http://localhost:5000/ in a browser]
#
#     For additional shells while running:
#         docker exec -it roocs_c /bin/bash -login           (for non-root)
#         docker exec -u root -it roocs_c /bin/bash -login   (for root)
#
#     docker stop roocs_c    (takes a few seconds to stop)
#     docker rm roocs_c
#
#
#  In dev container:
#
#    open current dir in vscode (note: the .devcontainer subdirectory contains
#    a symbolic link to this docker file in the parent directory. Just open the
#    parent directory rather than the .devcontainer subdirectory itself.)
#
#   ctrl-shift P ; Dev-containers: rebuild container
#
#     to start rook, type "rook_start" and then vscode detects the listening
#     service and puts up a dialogue box with a button to open port 5000 in browser
#
#============================================================================================

FROM mcr.microsoft.com/devcontainers/base:ubuntu

ARG conda_dir=/opt/conda
ARG roocs_dir=/workspaces
ARG conda_env=roocs
ARG dev_user=roocsdev
ARG dev_group=roocsdev
ARG dev_user_homedir=/home/$dev_user
ARG setup_env=/usr/local/bin/setup_roocs_env.sh
ARG auto_start=n
ARG run_tests=/usr/local/bin/run-tests
ARG start_script=/usr/local/bin/rook_start
ARG do_tests=n

ARG tmp_spec=/tmp/tmp_spec.txt

# # [Optional] Uncomment this section to install additional OS packages.
# # RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
# #     && apt-get -y install --no-install-recommends <your-package-list-here>

#-----------------------------------------------
# Use mamba-forge to create the base environment
#-----------------------------------------------

RUN curl -s -L -o mamba.sh -O https://github.com/conda-forge/miniforge/releases/latest/download/Mambaforge-pypy3-Linux-x86_64.sh \
    && bash mamba.sh -b -p $conda_dir && rm mamba.sh
ARG activate=$conda_dir/bin/activate

#----------------------------------
# Clone all the ROOCS related repos
#----------------------------------
RUN mkdir -p $roocs_dir \
       && cd $roocs_dir \
       && git clone https://github.com/roocs/rook.git \
       && git clone https://github.com/roocs/rooki.git \
       && git clone https://github.com/roocs/roocs-utils.git \
       && git clone https://github.com/roocs/clisops \
       && git clone https://github.com/roocs/daops

#------------------------------------------------------
# Create the roocs conda environment and a setup script
#------------------------------------------------------

# Create conda environment
# (use the list of URLs, but the token @EXPLICIT not understood by mamba)
RUN perl -p -e 'print "#" if /\@EXPLICIT/' $roocs_dir/rook/spec-list.txt > $tmp_spec \
      &&  . $activate && mamba env create -n $conda_env -f $tmp_spec \
      && rm -fr $tmp_spec

# Create setup script
RUN (echo ". $activate"; echo "conda activate $conda_env") > $setup_env

#--------------
# Install all the packages
#--------------

RUN cd $roocs_dir/rook \
       && perl -p -i -e 'print "#" if /(daops|clisops|roocs-utils)/' requirements.txt \
       && . $setup_env \
       && pip install -r requirements.txt -r requirements_dev.txt && pip install --no-deps -e .

RUN cd $roocs_dir/rooki \
       && . $setup_env \
       && pip install -r requirements.txt -r requirements_dev.txt && pip install --no-deps -e .

RUN cd $roocs_dir/roocs-utils \
       && . $setup_env \
       && pip install -r requirements.txt -r requirements_dev.txt && pip install --no-deps -e .

RUN cd $roocs_dir/clisops \
       && perl -p -i -e 'print "#" if /roocs-utils/' requirements.txt \
       && . $setup_env \
       && pip install -r requirements.txt -r requirements_dev.txt && pip install --no-deps -e .

RUN cd $roocs_dir/daops \
       && perl -p -i -e 'print "#" if /(clisops|roocs-utils)/' requirements.txt \
       && . $setup_env \
       && pip install -r requirements.txt -r requirements_dev.txt && pip install --no-deps -e .

#-------------------------------------------------------------
# Copy the test-runner script and optionally run all the tests
#-------------------------------------------------------------

# if do_tests = y (lower-case) then tests are run but failures do not abort the build
# if do_tests = Y (upper-case) then tests are run and any failures abort the build

COPY run_tests.sh $run_tests
RUN chmod 755 $run_tests

RUN if [ "$do_tests" = "y" ]; then . $setup_env \
                                        ; $run_tests rook \
                                        ; $run_tests rooki \
                                        ; $run_tests roocs-utils \
                                        ; $run_tests clisops \
                                        ; $run_tests daops \
					; true \
    ; elif [ "$do_tests" = "Y" ] ; then . $setup_env \
                                        && $run_tests rook \
                                        && $run_tests rooki \
                                        && $run_tests roocs-utils \
                                        && $run_tests clisops \
                                        && $run_tests daops \
    ; fi


#-----------------------------
# Create a simple start script
#-----------------------------

RUN (echo "#!/bin/bash"; echo "cd $roocs_dir" ; echo ". $setup_env"; echo "rook start -b 0.0.0.0 > rook.out 2>&1 &") > /usr/local/bin/rook_start \
    && chmod 755 $start_script

#---------------------------------------------------------------------------
# Set up the dev user and group and give it ownership of things we installed
#---------------------------------------------------------------------------

# create if they don't already exist (for groupadd, this is the "-f" option,
# but for useradd we must test explicitly)

RUN groupadd -f $dev_group \
       && if ! grep -q "^$dev_user:" /etc/passwd ; then useradd -g $dev_group -d $dev_user_homedir -m $dev_user -s /bin/bash ; fi

# source the setup env script in the user's login script
RUN echo ". $setup_env" >> $dev_user_homedir/.bashrc \
   && echo '. $HOME/.bashrc' >> $dev_user_homedir/.bash_profile \
   && echo "cd $roocs_dir" >> $dev_user_homedir/.bash_profile

# Give the user ownership of the repos that we cloned (which will be used at
# run time because they were installed with "-e").  Also the home dir in case
# we created .bashrc.

RUN chown -R $dev_user:$dev_group $roocs_dir $dev_user_homedir

# Uncomment the following line to also give ownership of the conda
# installation.  However, this contains a lot of files, and from experience,
# the docker build may be slow or even fall over.  Only necessary if the
# non-root user will need to reinstall the dependencies.

# RUN chown -R $dev_user:$dev_group $conda_dir


# For when running with devcontainers, create a directory to be used for the bind mount.
# The name of this should match what is used in the "target" part of the "workspaceMount"
# option in .devcontainer/devcontainer.json in this repo.  This directory will be created
# with the wrong permissions because of the updateRemoteUserUID=false setting, because the
# priority is to ensure that the repositories which we cloned elsewhere have the correct
# permissions, so the directory will probably not be used, so we make it a dot directory
# to hide it a bit.  (I've not found an obvious way to suppress the mount entirely.)

RUN mkdir /workspaces/.vscode_mount

ENV auto_start=$auto_start
ENV dev_user=$dev_user
ENV setup_env=$setup_env


USER $dev_user
CMD ["sh", "-c", \
    "cd; if [ \"$auto_start\" = y ]; then $start_script; fi ; exec /bin/bash -login"]
