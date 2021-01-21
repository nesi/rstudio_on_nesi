# Rsudio on NeSI using jupyter-server-proxy

1. Log in jupyter.nesi.org.nz and open a terminal (or log on NeSI using `ssh`).

2. Configure a password for RStudio server, adding a `.rstudio_server_password` file in your home directory:
   ```
   echo "my_secret_password" > ~/.rstudio_server_password
   chmod 600 ~/.rstudio_server_password
   ```
   Make sure to replace `my_secret_password` with your password :-).

3. Install the current package:
   ```
   module load JupyterLab
   pip install pip install git+ssh://git@git.hpcf.nesi.org.nz/riom/rstudio_on_nesi.git
   ```

4. Start a new instance on jupyter.nesi.org.nz and click on the RStudio icon to start it in a separate tab of your web browser.


## References

- https://jupyter-server-proxy.readthedocs.io
- https://github.com/jupyterhub/jupyter-rsession-proxy
