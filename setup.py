import setuptools

setuptools.setup(
    name="jupyter-rstudio-on-nesi",
    version="0.1",
    py_modules=["rstudio_on_nesi"],
    entry_points={
        "jupyter_serverproxy_servers": [
            "openrefine = rstudio_on_nesi:setup_rstudio",
        ]
    },
    install_requires=["jupyter-server-proxy"],
)
