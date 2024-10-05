from flask import Flask, request, jsonify
import spacy
import torch
import cv2
import numpy as np

app = Flask(__name__)

# Load spaCy model (for NLP tasks)
nlp = spacy.load('en_core_web_sm')

# Mock memory data (could be fetched from a database)
user_data = {
    "appointment": "You have a doctor's appointment at 3 PM today.",
    "visitor": "Your daughter is visiting today at 2 PM.",
    "medication": "It's time to take your medication."
}

@app.route('/memory_prompt', methods=['POST'])
def memory_prompt():
    query = request.json.get('query')
    doc = nlp(query.lower())

    # Simple keyword-based NLP (could be expanded for intent detection)
    if 'appointment' in query:
        response = user_data['appointment']
    elif 'visitor' in query:
        response = user_data['visitor']
    elif 'medication' in query:
        response = user_data['medication']
    else:
        response = "I'm sorry, I don't have an answer for that."

    return jsonify({"response": response})model = torch.hub.load('ultralytics/yolov5', 'yolov5s')

@app.route('/detect', methods=['POST'])
def detect_object():
    file = request.files['image']
    img = cv2.imdecode(np.frombuffer(file.read(), np.uint8), cv2.IMREAD_UNCHANGED)

    # Perform detection using YOLOv5
    results = model(img)
    labels, coords = results.xyxyn[:, -1], results.xyxyn[:, :-1]

    # Format the response
    detected_objects = [results.names[int(label)] for label in labels]

    return jsonify({"detected_objects": detected_objects})

if __name__ == '__main__':
    app.run(debug=True)
