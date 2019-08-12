
from server import app
from flask import Blueprint, Response, request
from prometheus_client import generate_latest, Counter
from functools import wraps

metrics_bp = Blueprint("metrics", __name__)

# route to display configured Prometheus metrics
# note that you will need to set up custom metric observers for your app
@metrics_bp.route('/metrics')
def prometheus_metrics():
    """Metrics for the service
    Return the metrics of the service.
    ---
    responses:
      200:
        description: The metrics of the service
        examples:
          text/plain: requests_for_routes_total{endpoint="/hello",method="GET"} 3.0
    """
    MIMETYPE = 'text/plain; version=0.0.4; charset=utf-8'
    return Response(generate_latest(), mimetype=MIMETYPE)

# creates a Prometheus Counter to track requests for specified routes
# usage:
# @app.route('/example')
# @prometheus.track_requests
# def example():
#    pass
route_counter = Counter('requests_for_routes', 'Number of requests for specififed routes', ['method', 'endpoint'])

def track_requests(route):
    @wraps(route)
    def wrapper(*args, **kwargs):
        route_labels = {
            "method": request.method,
            "endpoint": str(request.path)
        }
        route_counter.labels(**route_labels).inc()
        return route(*args, **kwargs)
    return wrapper
