import os
import subprocess
import pkg_resources
from pathlib import Path


def setup_rstudio():
    # home_path = Path(os.environ["HOME"])
    # account = os.environ["SLURM_JOB_ACCOUNT"]

    # try:
    #     rstudio_password = (home_path / ".rstudio_server_password").read_text()
    # except FileNotFoundError:
    #     rstudio_password = None

    icon_path = pkg_resources.resource_filename("rstudio_on_nesi", "rstudio_logo.svg")
    wrapper_path = pkg_resources.resource_filename("rstudio_on_nesi", "singularity_wrapper.sh")
    runscript_path = pkg_resources.resource_filename("rstudio_on_nesi", "singularity_runscript.sh")


    return {
        "command": [
            wrapper_path,
            runscript_path,
            "{port}",
            "{base_url}rstudio",
        ],
        "timeout": 60,
        "absolute_url": False,
        "launcher_entry": {
            "icon_path": icon_path,
            "title": "RStudio",
        },
    }
