import setuptools

setuptools.setup(
    name="jupyter-rstudio-on-nesi",
    version="0.2",
    py_modules=["rstudio_on_nesi"],
    entry_points={
        "jupyter_serverproxy_servers": [
            "rstudio = rstudio_on_nesi:setup_rstudio",
        ]
    },
    install_requires=["jupyter-server-proxy"],
)
