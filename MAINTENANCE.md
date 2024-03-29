# Maintenance

Notes for the maintainers.


## Test locally

Go to your local clone of the repository and install it as a regular Python package

```
module purge && module load JupyterLab
pip install -e .
```

Also fetch the corresponding build of the container.
If you used a feature branch on the repo (you should ;-)), the CI would have built your container so you only need to fetch it:

```
module purge && module load Apptainer
apptainer pull <SIFPATH> oras://ghcr.io/nesi/rstudio_on_nesi:<BRANCHNAME>
```

where

- `<BRANCHNAME>` is the name of your git branch,
- `<SIFPATH>` is the path where to save the .sif image file.

Make sure to configure RStudio-on-NeSI to use this container instead of the default one.

```
mkdir -p ~/.config/rstudio_on_nesi/
echo <SIFPATH> > ~/.config/rstudio_on_nesi/singularity_image_path
```

Then start a new JupyterLab session on [NeSI JupyterHub](https://jupyter.nesi.org.nz), start RStudio and check that everything works as intended ;-).

Once your test is done, make sure to cleanup your environment:

- uninstall the Python package

```
module purge && module load JupyterLab
pip uninstall rstudio-on-nesi
```

- remove the file indicating the alternative container

```
rm ~/.config/rstudio_on_nesi/singularity_image_path
```


## Release a new version

### Variable for convenience

Setup variables for your local git repo and the new version, repeatedly used in the workflow.

```
WKDIR=<PATH_TO_SIF_IMAGE> (The cloned git repo direcotry)
VER=<VERSION_NUMBER> (eg v0.25.0)
```

**Always test locally the package and associated container first.**

Go to your local clone of the repository and make sure to be in the `main` branch with all the latest changes:

```
cd $WKDIR
git checkout main
git pull
```

Increase the version number in `rstudio_on_nesi/__init__.py`, using the semantic versioning scheme.

Then commit, push, tag and push the tag

```
git commit -av -m "version $VER"
git push
git tag $VER
git push --tags
```

where `$VER` is the new version number

Check that the corresponding CI build job runs to completion without any error.

Then fetch the corresponding container image:

```
module purge && module load Apptainer
apptainer pull rstudio_server_on_centos7__$VER.sif oras://ghcr.io/nesi/rstudio_on_nesi:$VER
```

Move the sif image to a readable place for nesi-apps-admin` and update the permissions. 
```
cp $WKDIR/rstudio_server_on_centos7__$VER.sif /nesi/project/nesi99999/
chmod 775 /nesi/project/nesi99999/rstudio_server_on_centos7__$VER.sif
```

Switch to nesi-apps-admin to update to the default image: `sudo -iu nesi-apps-admin`, <VERSION> variable is not passed to nesi-apps-admin and needs to be manually included. Once copied the .sif can be removed as it still resides in your local repo.

```
cp /nesi/rstudio_server_on_centos7__<VERSION>.sif /opt/nesi/containers/rstudio-server/rstudio_server_on_centos7__<VERSION>.sif
rm /nesi/rstudio_server_on_centos7__<VERSION>.sif
```
TEST TEST TEST

Finally, request an update of the JupyterLab environment module to install the new version of the Python package.


## Test without Jupyter

*This is an alternative way to test the container if you really don't want to use JupyterLab integrated launcher.*

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
