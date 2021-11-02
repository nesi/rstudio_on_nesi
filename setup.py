from setuptools import setup, find_packages

setup(
    name="jupyter-rstudio-on-nesi_dev",
    version="0.20.0",
    packages=find_packages(),
    package_data={"rstudio_on_nesi_dev": ["rstudio_logo.svg"]},
    entry_points={
        "jupyter_serverproxy_servers": ["rstudio_dev = rstudio_on_nesi_dev:setup_rstudio"]
    },
    install_requires=["jupyter-server-proxy"],
)
