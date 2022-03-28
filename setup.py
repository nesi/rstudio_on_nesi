from setuptools import setup, find_packages

import rstudio_on_nesi

setup(
    name="rstudio_on_nesi",
    version=rstudio_on_nesi.__version__,
    packages=find_packages(),
    package_data={
        "rstudio_on_nesi":[
            "rstudio_logo.svg",
            "singularity_wrapper.bash",
            "singularity_runscript.bash",
        ]
    },
    entry_points={
        "jupyter_serverproxy_servers":[
            "rstudio=rstudio_on_nesi:setup_rstudio"
        ]
    },
    install_requires=["jupyter-server-proxy"],
)
