from setuptools import setup, find_packages
from setuptools.command.install import install
import subprocess
import pkg_resources

# class InstallCommand(install):
#     user_options = install.user_options + [
#         ('module=', None, "R module to use"),
#     ]
#     #"R/4.1.0-gimkl-2020a"
#     def initialize_options(self):
#         install.initialize_options(self)
#         self.module = None

#     def finalize_options(self):
#         install.finalize_options(self)

#     def run(self):
#         if subprocess.run(f"module load {self.module}", shell=True).returncode:
#             raise Exception(f"'{self.module}' is not a valid module." )
#         with open(pkg_resources.resource_filename("rstudio_on_nesi", ".r_module"), 'w') as f:
#             print()
#             f.write(self.module)
                
#         install.run(self)

setup(
    name=f"jupyter-rstudio-on-nesi",
    version="0.10.0",
    packages=find_packages(),
    package_data={"rstudio_on_nesi": ["rstudio_logo.svg", "singularity_wrapper.sh", "singularity_runscript.sh"]},
    entry_points={
        "jupyter_serverproxy_servers": ["rstudio = rstudio_on_nesi:setup_rstudio"]
    },
    install_requires=["jupyter-server-proxy"],
    # cmdclass={
    #     'install': InstallCommand,
    # }
)
