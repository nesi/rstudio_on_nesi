import os
import subprocess
import pkg_resources
from pathlib import Path


def setup_rstudio():
    home_path = Path(os.environ["HOME"])
    account = os.environ["SLURM_JOB_ACCOUNT"]
    
    repo_path = "/nesi/project/nesi99999/Callum/rstudio/rstudio_on_nesi"
    
    try:
        rstudio_password = (home_path / ".rstudio_server_password").read_text()
    except FileNotFoundError:
        rstudio_password = None

    icon_path = pkg_resources.resource_filename("rstudio_on_nesi", "rstudio_logo.svg")

    return {
        "command": [
            f"{repo_path}/conf/singularity_wrapper.sh",
            "run",
            "--writable-tmpfs",
            f"{repo_path}/conf/rstudio.sif",
            "{port}",
            "{base_url}/proxy/{port}",
        ],
        "timeout": 60,
        "environment": {"PASSWORD": rstudio_password},
        "absolute_url": False,
        "launcher_entry": {
            "icon_path": icon_path,
            "title": "RStudio",
            "enabled": rstudio_password is not None,
        },
    }
