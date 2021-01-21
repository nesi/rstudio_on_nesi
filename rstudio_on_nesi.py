import os


def setup_rstudio():
    return {
        "command": [
            os.getenv("HOME") + "/project/rstudio-server/start_rstudio.bash",
            "{port}",
            "{base_url}/proxy/{port}",
        ],
        "absolute_url": False,
        "launcher_entry": {
            "icon_path": os.getenv("HOME") + "/project/rstudio-server/rstudio.svg",
            "title": "RStudio",
        },
    }
