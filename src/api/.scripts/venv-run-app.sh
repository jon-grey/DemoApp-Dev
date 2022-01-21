set -euo pipefail

(   
source venv/bin/activate
source .env

cd src
FLASK_ENV=${FLASK_ENV} python3 -m flask run --host=localhost
)