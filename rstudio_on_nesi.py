import os
import subprocess
from pathlib import Path


def get_singularity_path():
    cmd_result = subprocess.run(
        "module load Singularity && which singularity",
        capture_output=True,
        shell=True,
        timeout=10,
    )
    return cmd_result.stdout.strip().decode()


def setup_rstudio():
    home_path = os.environ["HOME"]
    account = os.environ["SLURM_JOB_ACCOUNT"]

    password_file = Path(home_path) / ".rstudio_server_password"
    with password_file.open() as fd:
        rstudio_password = fd.read()

    return {
        "command": [
            get_singularity_path(),
            "run",
            "--contain",
            "-B",
            f'"{home_path}","/nesi/project/{account}","/nesi/nobackup/{account}"',
            "/opt/nesi/containers/rstudio-server/tidyverse_nginx_3.6.1.sif",
            "{port}",
            "{base_url}/proxy/{port}",
        ],
        "environment": {"PASSWORD": rstudio_password},
        "absolute_url": False,
        "launcher_entry": {
            "icon_path": home_path + "/project/rstudio-server/rstudio.svg",
            "title": "RStudio",
        },
    }
