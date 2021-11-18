# RStudio on NeSI using jupyter-server-proxy

This repository contains a Python package that will help you run RStudio Server Open Source on [jupyter.nesi.org.nz](https://jupyter.nesi.org.nz).

Once intalled, it will add an option in the main interface of JupyterLab to start an instance of RStudio Server on the same computing node.
Note that the RStudio Server will not outlive the JupyterLab session.

**Note: this package is experimental, please note that breaking changes can and will happen.**


## Installation

1. Log in [jupyter.nesi.org.nz](https://jupyter.nesi.org.nz) and open a terminal (or log on NeSI using `ssh`).

2. Install the current package:
   ```
   pip install --user git+https://github.com/nesi/rstudio_on_nesi@refactor
   ```

3. Start a new instance on [jupyter.nesi.org.nz](https://jupyter.nesi.org.nz) and click on the RStudio icon to start it in a separate tab of your web browser.

Once installed, you should notice a new icon in the *launcher* interface.

![](launcher.png)

When starting RStudio Server, the username requested is your **NeSI** login and the password is the one you defined in the `~/.config/rstudio_on_nesi/server_password` file.


## References

- https://jupyter-server-proxy.readthedocs.io
- https://github.com/jupyterhub/jupyter-rsession-proxy


## Notes for maintainers

- clone the repository

```
git clone https://github.com/nesi/rstudio_on_nesi.git
cd rstudio_on_nesi
git checkout refactor
```

- build the container

```
module unload XALT
module load Singularity
singularity build -r /nesi/nobackup/nesi99999/rstudio_test_containers/rstudio_server_<RSERVER_VERSION>_on_centos7__v<PACKAGE_VERSION>.sif conf/rstudio_server_on_centos7.def
```

- test without jupyter (create a ssh tunnel to rstudio directly, not nginx)

```
PASSWORD=your_secret_password rstudio_on_nesi_dev/singularity_wrapper.sh $(pwd)/rstudio_on_nesi_dev/singularity_runscript.sh 9999 localhost
```

- install on jupyter

```
module purge && module load JupyterLab
pip install . --use-feature=in-tree-build
```
