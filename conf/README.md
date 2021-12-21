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

If this is not replacing the default path, you can specify the image rstudio nesi uses in 
`~/.config/rstudio_nesi/singularity_image_path`

