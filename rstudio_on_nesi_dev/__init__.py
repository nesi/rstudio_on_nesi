import os
import subprocess
import pkg_resources
import secrets
from pathlib import Path


# TODO Document this. v
# If .config/rstudio_on_nesi/singularity_image_path exists, the path specified in here will be used over default image.

def setup_rstudio():
    default_sif_path="/opt/nesi/containers/rstudio-server/rstudio_server_on_centos7.sif"

    try:
        rstudio_config_folder = Path(os.environ["XDG_CONFIG_HOME"]) / "rstudio_on_nesi"
    except KeyError:
        rstudio_config_folder = Path(os.environ["HOME"]) / ".config" / "rstudio_on_nesi"

    password_file = rstudio_config_folder / "server_password"
    if not password_file.is_file():
        rstudio_config_folder.mkdir(parents=True, exist_ok=True)
        password_file.write_text(secrets.token_hex())

    rstudio_password = password_file.read_text().rstrip()

    # Get absoulte path of resources.
    pkg_path = "rstudio_on_nesi_dev"
    icon_path = pkg_resources.resource_filename(
        pkg_path, "rstudio_logo.svg"
    )
    wrapper_path = pkg_resources.resource_filename(
        pkg_path, "singularity_wrapper.bash"
    )
    runscript_path = pkg_resources.resource_filename(
        pkg_path, "singularity_runscript.bash"
    )

    # May want to add aditional logic to make more failproof.
    def get_sif_path():
        
        try:
            with open(rstudio_config_folder / "singularity_image_path", "r") as f:
                result =  f.readline()
        except:
            result =  default_sif_path

        print(f"Using image at '{result}'")
        return result

    return {
        "command": [
            wrapper_path,
            runscript_path,
            "{port}",
            "{base_url}rstudio_dev",
        ],
        "timeout": 15,
        "environment": {"PASSWORD": rstudio_password, "SIFPATH":get_sif_path()},
        "absolute_url": False,
        "launcher_entry": {
            "icon_path": icon_path,
            "title": "_dev_RStudio",
            "enabled": True,
        },
        "request_headers_override": {"Rstudio-password": rstudio_password},
    }
