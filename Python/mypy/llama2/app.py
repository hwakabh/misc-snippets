from flask import Flask, request, jsonify
from llama_cpp import Llama

app = Flask(__name__)

llm = Llama(model_path='./models/llama-2-7b-chat.ggmlv3.q8_0.bin')


@app.route('/ask', methods=["POST"])
def index():
    if request.headers['Content-Type'] != 'application/json':
        return jsonify(res='Bad Request, provide Content-Type header'), 400

    payload = request.json
    prompt = payload.get('Q', None)
    if prompt is None:
        return jsonify(res='Bad Request, payload should be {"Q": "your promot"}'), 400
    
    output = llm(
        f'Q: {prompt} A: ',
        max_tokens=512,
        stop=["Q:", "\n"],
        echo=True
    )
    return jsonify(res=output.get('choices')[0]), 200


if __name__ == '__main__':
    app.run(host='localhost', port=8080, debug=True)

