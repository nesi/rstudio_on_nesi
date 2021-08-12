from setuptools import setup, find_packages

setup(
    name="jupyter-rstudio-on-nesi",
    version="0.11.1",
    packages=find_packages(),
    package_data={"rstudio_on_nesi": ["rstudio_logo.svg"]},
    entry_points={
        "jupyter_serverproxy_servers": ["rstudio = rstudio_on_nesi:setup_rstudio"]
    },
    install_requires=["jupyter-server-proxy"],
)
