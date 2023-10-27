from flask import Flask


app = Flask(__name__)

@app.route('/')
def root():
    """This is URL root of this app

    Returns:
        str: Root message
    """
    return 'This is root URL'

@app.route('/healthz')
def healthz():
    """Endpoint for health check

    Returns:
        str: status (ok | ng)
    """
    return 'ok'


if __name__ == '__main__':
    app.run()
