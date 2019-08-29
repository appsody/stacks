from flask import Blueprint,jsonify
from flasgger import Swagger

health_bp = Blueprint("health", __name__)

@health_bp.route("/health")
def Health():
    """Health of the service
    Return the status of the service.
    ---
    responses:
      200:
        description: The state of the service
        examples:
          status: UP
    """
    state = {"status": "UP"}
    return jsonify(state)
