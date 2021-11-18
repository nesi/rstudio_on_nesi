import os
import subprocess
import pkg_resources
import secrets
from pathlib import Path


def setup_rstudio():
    account = os.environ["SLURM_JOB_ACCOUNT"]

    try:
        config_folder = Path(os.environ["XDG_CONFIG_HOME"])
    except KeyError:
        config_folder = Path(os.environ["HOME"]) / ".config"

    password_file = config_folder / "rstudio_on_nesi" / "server_password"
    if not password_file.is_file():
        config_folder.mkdir(parents=True, exist_ok=True)
        password_file.write_text(secrets.token_hex())
    rstudio_password = password_file.read_text().rstrip()

    icon_path = pkg_resources.resource_filename(
        "rstudio_on_nesi_dev", "rstudio_logo.svg"
    )
    wrapper_path = pkg_resources.resource_filename(
        "rstudio_on_nesi_dev", "singularity_wrapper.sh"
    )
    runscript_path = pkg_resources.resource_filename(
        "rstudio_on_nesi_dev", "singularity_runscript.sh"
    )

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
            "enabled": True,
        },
        "request_headers_override": {"Rstudio-password": rstudio_password},
    }
