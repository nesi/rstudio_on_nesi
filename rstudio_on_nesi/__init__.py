import os
import subprocess
import secrets
from pkg_resources import resource_filename
from pathlib import Path


# default image if none configured in ~/.config/rstudio_on_nesi/singularity_image_path
DEFAULT_SIF_PATH = "/opt/nesi/containers/rstudio-server/rstudio_server_on_centos7__v0.22.0.sif"


def setup_rstudio():
    try:
        rstudio_config_folder = Path(os.environ["XDG_CONFIG_HOME"]) / "rstudio_on_nesi"
    except KeyError:
        rstudio_config_folder = Path(os.environ["HOME"]) / ".config" / "rstudio_on_nesi"

    password_file = rstudio_config_folder / "server_password"
    if not password_file.is_file():
        rstudio_config_folder.mkdir(parents=True, exist_ok=True)
        password_file.write_text(secrets.token_hex())

    rstudio_password = password_file.read_text().rstrip()

    pkg_path = "rstudio_on_nesi"
    icon_path = resource_filename(pkg_path, "rstudio_logo.svg")
    wrapper_path = resource_filename(pkg_path, "singularity_wrapper.bash")
    runscript_path = resource_filename(pkg_path, "singularity_runscript.bash")

    sif_path_conf = rstudio_config_folder / "singularity_image_path"
    try:
        sif_path = sif_path_conf.read_text().rstrip()
    except FileNotFoundError:
        sif_path = DEFAULT_SIF_PATH
    print(f"Using image at '{sif_path}'")

    return {
        "command": [
            wrapper_path,
            runscript_path,
            "{port}",
            "{base_url}rstudio",
        ],
        "timeout": 15,
        "environment": {"PASSWORD": rstudio_password, "SIFPATH": sif_path},
        "absolute_url": False,
        "launcher_entry": {
            "icon_path": icon_path,
            "title": "RStudio",
            "enabled": True,
        },
        "request_headers_override": {"Rstudio-password": rstudio_password},
    }
