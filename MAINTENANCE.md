# Maintenance

Notes for the maintainers.


## Release a new version

- increase version number in `rstudio_on_nesi/__init__.py`,
- rebuild container or create a symlink, name it with same version number (see below),
- test the installation from the local repository (see below),
- commit, push, tag and push the tag
  ```
  git commit -av -m "version <VERSION>"
  git push
  git tag v<VERSION>
  git push --tags
  ```
  where `<VERSION>` is the new version number


## Update the Singularity image

Build the container using `singularity` on your workstation:
```
sudo singularity build rstudio_server_on_centos7.sif conf/rstudio_server_on_centos7.def
```

Then transfer the container image on NeSI and update to the default image (using `sudo` to switch to admin):
```
cp rstudio_server_on_centos7.sif /opt/nesi/containers/rstudio-server/rstudio_server_on_centos7__v<VERSION>.sif
```
where `<VERSION>` should match the Python package version number.

*Note that you can test a new image without updating the default image, using a configuration file:*
```
echo $PWD/rstudio_server_on_centos7.sif > ${XDG_CONFIG_HOME:=$HOME/.config}/rstudio_on_nesi/singularity_image_path
```

## Install from local repository

```
module purge && module load JupyterLab
pip install -e .
```


## Test without Jupyter

Start the container from the command line:
```
export SIFPATH=<PATH_TO_SIF_IMAGE>
PASSWORD=your_secret_password rstudio_on_nesi/singularity_wrapper.bash $(pwd)/rstudio_on_nesi/singularity_runscript.bash 9999 localhost
```
where `<PATH_TO_SIF_IMAGE>` is the path to the container image.

Note we will connect directly to the rstudio server, bypassing the Nginx reverse-proxy which is useless in this context without Jupyter.

Check the messages in the terminal to find out the rstudio server port, for example:
```
rserver cmd: /usr/lib/rstudio-server/bin/rserver --www-port 40074 --auth-none 0 [...]
```
would correspond to port `40074`.

Finally, start an ssh tunnel on this port and open your web browser at `http://localhost:<REDIRECTED_PORT>` to access rstudio.
