from flask import Flask, render_template_string, make_response
import requests

WEB_SERVER_BIND_ADDRESS = '0.0.0.0'
WEB_SERVER_PORT = 8000

LOCAL_AGENT_URL = 'http://localhost:8081/service'

app = Flask('node-ui')

template = """
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <title>Service List</title>
</head>
<body>
    <h1>Open Horizon Service List</h1>
    <p>Running Services:</p>
    <pre>{{ services }}</pre>
</body>
</html>
"""

def get_services_status():
    try:
        response = requests.get(LOCAL_AGENT_URL)
        response.raise_for_status()  # raise an HTTPError for 4xx or 5xx
        services = response.json()  # Assuming the response is in JSON format
        return services
    except requests.RequestException as e:  # network error, server down, non-2xx status code
        return {"error": str(e)}

@app.route("/", methods=['GET'])
def index():
    status = get_services_status()
    response = make_response(render_template_string(template, services=status))
    response.headers["Access-Control-Allow-Credentials"] = "true"
    response.headers["Access-Control-Allow-Origin"] = "*"
    return response

if __name__ == '__main__':
    app.run(host=WEB_SERVER_BIND_ADDRESS, port=WEB_SERVER_PORT)
