from setuptools import setup, find_packages
from setuptools.command.install import install
import subprocess

# class InstallCommand(install):
#     user_options = install.user_options + [
#         ('setup=', None, "Additional setup steps")
#     ]

#     def initialize_options(self):
#         install.initialize_options(self)
#         self.setup = None

#     def finalize_options(self):
#         install.finalize_options(self)

#     def run(self):
#         if self.setup:
#             try:
#                 version_list = subprocess.check_output("module -t avail | grep \"^R/\" | tail -n +2", stderr=subprocess.STDOUT, shell=True).decode("utf-8").strip().split("\n")
#                 for version in version_list:
#                     if version.find(self.setup):
#                         version_with_toolchain = version.split("/")[1].strip()
#                         version_without_toolchain = version_with_toolchain.split("-")[0]
#                         break
#             except:
#                 pass
#         install.run(self)

setup(
   # name=f"jupyter-rstudio{version_without_toolchain}-on-nesi-test",
    name=f"jupyter-rstudio-on-nesi",
    version="0.10.0",
    packages=find_packages(),
    package_data={"rstudio_on_nesi": ["rstudio_logo.svg", "singularity_wrapper.sh"]},
    entry_points={
        "jupyter_serverproxy_servers": ["rstudio = rstudio_on_nesi:setup_rstudio"]
    },
    install_requires=["jupyter-server-proxy"],
)
