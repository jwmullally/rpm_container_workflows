from setuptools import setup

setup(
    name='demo_app',
    packages=['demo_app'],
    install_requires=[
        'flask',
        'hello_lib',
        ],
    test_suite='nose.collector',
    tests_require=[
        'nose',
        ],
    version='1.0',
)
