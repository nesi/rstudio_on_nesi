### Instructions to rebuild singularity image on NeSI.

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
If this is an update to the default image you will need to sudo to admin then 

```
mv rstudio_server_on_centos7.sif /opt/nesi/containers/rstudio-server/rstudio_server_on_centos7.sif
chmod 766 /opt/nesi/containers/rstudio-server/rstudio_server_on_centos7.sif
```

If you are not updating the default image, you can specify this image be used by runnin.
`echo $PWD/rstudio_server_on_centos7.sif > ${XDG_CONFIG_HOME:=$HOME/.config}/rstudio_on_nesi/singularity_image_path`

