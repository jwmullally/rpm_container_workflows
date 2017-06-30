import unittest
import hello_lib

class HelloLibTestCase(unittest.TestCase):

    def test_hello(self):
        assert hello_lib.hello_world() == 'Hello, World!'
