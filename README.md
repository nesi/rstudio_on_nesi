# RStudio on NeSI using jupyter-server-proxy

This repository contains a Python package that will help you run RStudio Server Open Source on [jupyter.nesi.org.nz](https://jupyter.nesi.org.nz).

Once intalled, it will add an option in the main interface of JupyterLab to start an instance of RStudio Server on the same computing node.
Note that the RStudio Server will not outlive the JupyterLab session.

**Note: this package is experimental, please note that breaking changes can and will happen.**


## Installation

1. Log in [jupyter.nesi.org.nz](https://jupyter.nesi.org.nz) and open a terminal (or log on NeSI using `ssh`).

2. Configure a password for RStudio server, adding a `.rstudio_server_password` file in your home directory:
   ```
   echo "my_secret_password" > ~/.rstudio_server_password
   chmod 600 ~/.rstudio_server_password
   ```
   Make sure to replace `my_secret_password` with your password :-).

3. Install the current package:
   ```
   module purge && module load JupyterLab
   pip install --user git+https://github.com/nesi/rstudio_on_nesi
   ```

4. Start a new instance on [jupyter.nesi.org.nz](https://jupyter.nesi.org.nz) and click on the RStudio icon to start it in a separate tab of your web browser.

Once installed, you should notice a new icon in the *launcher* interface.

![](launcher.png)

When starting RStudio Server, the username requested is your **NeSI** login and the password is the one you defined in the `~/.rstudio_server_password` file.


## References

- https://jupyter-server-proxy.readthedocs.io
- https://github.com/jupyterhub/jupyter-rsession-proxy
