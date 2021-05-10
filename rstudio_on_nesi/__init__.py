import os
import subprocess
import pkg_resources
from pathlib import Path


def get_singularity_path():
    """find the path for singularity executable on NeSI"""
    cmd_result = subprocess.run(
        "module load Singularity && which singularity",
        capture_output=True,
        shell=True,
        timeout=10,
    )
    return cmd_result.stdout.strip().decode()


def setup_rstudio():
    home_path = Path(os.environ["HOME"])
    account = os.environ["SLURM_JOB_ACCOUNT"]

    try:
        rstudio_password = (home_path / ".rstudio_server_password").read_text()
    except FileNotFoundError:
        rstudio_password = None

    icon_path = pkg_resources.resource_filename("rstudio_on_nesi", "rstudio_logo.svg")

    return {
        "command": [
            get_singularity_path(),
            "run",
            "--contain",
            "--writable-tmpfs",
            "-B",
            f'"{home_path}","/nesi/project/{account}","/nesi/nobackup/{account}"',
            "/opt/nesi/containers/rstudio-server/tidyverse_nginx_4.0.1__v0.9.sif",
            "{port}",
            "{base_url}/proxy/{port}",
        ],
        "timeout": 15,
        "environment": {"PASSWORD": rstudio_password},
        "absolute_url": False,
        "launcher_entry": {
            "icon_path": icon_path,
            "title": "RStudio",
            "enabled": rstudio_password is not None,
        },
    }
