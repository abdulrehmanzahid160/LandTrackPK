from flask import Flask
from flask_cors import CORS

from routes.auth import auth_bp
from routes.land import land_bp
from routes.citizen import citizen_bp
from routes.transfers import transfers_bp

app = Flask(__name__)
CORS(app)

# Register blueprints with /api prefix
app.register_blueprint(auth_bp, url_prefix='/api')
app.register_blueprint(land_bp, url_prefix='/api')
app.register_blueprint(citizen_bp, url_prefix='/api')
app.register_blueprint(transfers_bp, url_prefix='/api')

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
