import unittest
import demo_app

class DemoAppTestCase(unittest.TestCase):

    def setUp(self):
        demo_app.app.testing = True
        self.app = demo_app.app.test_client()

    def test_basic(self):
        rv = self.app.get('/')
        assert rv.data == 'Hello, World!'

if __name__ == '__main__':
    unittest.main()
