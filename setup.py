from setuptools import setup, find_packages

setup(
    name="rstudio_on_nesi",
    version="0.22.1",
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
