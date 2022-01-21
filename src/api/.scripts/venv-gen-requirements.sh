set -euo pipefail

virtualenv venv
source venv/bin/activate
pip3 install \
    python-dotenv \
    psutil \
    flask-cors \
    Flask==2.0.2
pip3 freeze > requirements.txt