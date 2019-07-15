from flask import Flask

app = Flask(__name__)

@app.route("/")
def hello():
    """Hello Appsody"""
    return "Hello from Appsody!"


