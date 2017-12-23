from setuptools import setup

setup(
    name='hello_lib',
    packages=['hello_lib'],
    test_suite='nose.collector',
    tests_require=[
        'nose',
        ],
    version='1.0',
)
