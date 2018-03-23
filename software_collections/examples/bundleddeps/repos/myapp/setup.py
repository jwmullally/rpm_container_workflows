from setuptools import find_packages, setup

setup(
    name='myapp',
    version='0.1',
    packages=find_packages(),
    include_package_data=True,
    scripts=['bin/myapp.sh']
)
