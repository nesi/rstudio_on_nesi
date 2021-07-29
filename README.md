```
git clone https://github.com/nesi/dev_rstudio_on_nesi_centos.git
cd dev_rstudio_on_nesi_centos
```

### Build container

```
module unload XALT
module load Singularity
singularity build -r conf/rstudio.sif conf/tidyverse_nginx_4.0.1.def
```
 
### Test without jupyter

```
./conf/singularity_wrapper.sh run --writable-tmpfs ./conf/rstudio.sif 9999 localhost
```

### Install on jupyter

```
pip install .
```
