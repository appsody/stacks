import os
from flask import Flask, abort, session, request, redirect
from flask.json import jsonify

# app = Flask(__name__, template_folder="../public", static_folder="../public", static_url_path='')

from userapp import app
from server.routes import *
from server.services import *


initServices(app)

