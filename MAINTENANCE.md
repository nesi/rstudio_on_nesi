# Maintenance

Notes for the maintainers.


## Release a new version

- increase version number in `setup.py`,
- rebuild container, name it with same version number (see below),
- change default image name in `rstudio_on_nesi/__init__.py`,
- commit, tag the commit and push

  ```
  git commit -av -m "version <VERSION>"
  git tag v<VERSION>
  git push --all
  ```

  where `<VERSION>` is the new version number


## Rebuild the Singularity image on NeSI

Start from a clean working environment:
```
module purge && module unload XALT
module load Singularity/3.8.5
```

You may need to log in for singularity remote build with
```
singularity remote login
```
then
```
singularity build -r rstudio_server_on_centos7.sif rstudio_server_on_centos7.def
```

If this is an update to the default image you will need to `sudo` to admin then 
```
mv rstudio_server_on_centos7.sif /opt/nesi/containers/rstudio-server/rstudio_server_on_centos7__v<VERSION>.sif
chmod 766 /opt/nesi/containers/rstudio-server/rstudio_server_on_centos7__v<VERSION>.sif
```
where `<VERSION>` should match the Python package version number.

If you are not updating the default image, you can specify this image be used by running:
```
echo $PWD/rstudio_server_on_centos7.sif > ${XDG_CONFIG_HOME:=$HOME/.config}/rstudio_on_nesi/singularity_image_path
```


## Test without Jupyter

Create a ssh tunnel to rstudio directly, not nginx:
```
PASSWORD=your_secret_password rstudio_on_nesi_dev/singularity_wrapper.sh $(pwd)/rstudio_on_nesi_dev/singularity_runscript.sh 9999 localhost
```


## Install from the cloned repository

```
module purge && module load JupyterLab
pip install . --use-feature=in-tree-build
```
