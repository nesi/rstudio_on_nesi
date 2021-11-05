import os
import subprocess
import pkg_resources
from pathlib import Path


def setup_rstudio():
    home_path = Path(os.environ["HOME"])
    account = os.environ["SLURM_JOB_ACCOUNT"]

    try:
        rstudio_password = (home_path / ".rstudio_server_password").read_text().rstrip()
    except FileNotFoundError:
        rstudio_password = None

    icon_path = pkg_resources.resource_filename("rstudio_on_nesi_dev", "rstudio_logo.svg")
    wrapper_path = pkg_resources.resource_filename("rstudio_on_nesi_dev", "singularity_wrapper.sh")
    runscript_path = pkg_resources.resource_filename("rstudio_on_nesi_dev", "singularity_runscript.sh")

    return {
        "command": [
            wrapper_path,
            runscript_path,
            "{port}",
            "{base_url}rstudio_dev",
        ],
        "timeout": 15,
        "environment": {"PASSWORD": rstudio_password},
        "absolute_url": False,
        "launcher_entry": {
            "icon_path": icon_path,
            "title": "_dev_RStudio",
            "enabled": rstudio_password is not None,
        },
        "request_headers_override": {
            "Rstudio-password": rstudio_password
        }
    }
