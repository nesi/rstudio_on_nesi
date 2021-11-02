from setuptools import setup, find_packages
from setuptools.command.install import install

setup(
    name="jupyter-rstudio-on-nesi_dev",
    version="0.20.1",
    packages=find_packages(),
    package_data={"rstudio_on_nesi": ["rstudio_logo.svg", "singularity_wrapper.sh", "singularity_runscript.sh"]},
    entry_points={
        "jupyter_serverproxy_servers": ["rstudio_dev = rstudio_on_nesi_dev:setup_rstudio"]
    },
    install_requires=["jupyter-server-proxy"],
)
