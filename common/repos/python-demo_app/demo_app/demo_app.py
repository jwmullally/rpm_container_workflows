from flask import Flask
import hello_lib
app = Flask(__name__)

@app.route('/')
def hello_world():
    return hello_lib.hello_world()

