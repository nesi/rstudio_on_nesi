import os
from pathlib import Path


def setup_rstudio():
    password_file = Path(os.getenv("HOME")) / ".rstudio_server_password"
    with password_file.open() as fd:
        rstudio_password = fd.read()

    return {
        "command": [
            os.getenv("HOME") + "/project/rstudio-server/start_rstudio.bash",
            "{port}",
            "{base_url}/proxy/{port}",
        ],
        "environment": {"PASSWORD": rstudio_password},
        "absolute_url": False,
        "launcher_entry": {
            "icon_path": os.getenv("HOME") + "/project/rstudio-server/rstudio.svg",
            "title": "RStudio",
        },
    }
