# Rsudio on NeSI using jupyter-server-proxy

1. Log in jupyter.nesi.org.nz and open a terminal (or log on NeSI using `ssh`).

2. Save the RStudio server password in a `.rstudio_server_password` file in your
   home directory:
   ```
   echo "my_secret_password" > ~/.rstudio_server_password
   chmod 600 ~/.rstudio_server_password
   ```
   replacing `my_secret_password` with your password :-).

3. Install the current package:
   ```
   module load JupyterLab
   pip install GIT_REPO_PATH_TO_ADD
   ```

4. Start a new instance on jupyter.nesi.org.nz and click on the RStudio icon to
   start it in a separate tab of your web browser.
