import unittest
from flask import Flask

class FlaskAppTest(unittest.TestCase):

    def setUp(self):
        self.app = Flask(__name__)
        self.app.config['TESTING'] = True
        self.client = self.app.test_client()

        @self.app.route('/')
        def index():
            return 'Hostname: example.com'

    def test_get_hostname(self):
        response = self.client.get('/')
        self.assertEqual(response.status_code, 200)
        self.assertIn(b'Hostname:', response.data)

    def tearDown(self):
        pass

if __name__ == '__main__':
    unittest.main()
