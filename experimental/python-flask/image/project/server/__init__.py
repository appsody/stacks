from flask import Flask

app = Flask(__name__)

from userapp import *

from server.routes.health import health_bp
app.register_blueprint(health_bp)
from server.routes.prometheus import metrics_bp
app.register_blueprint(metrics_bp)

