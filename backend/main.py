import os
import json
import math
from fastapi import FastAPI, UploadFile, File, Form
from dotenv import load_dotenv
import google.generativeai as genai
import firebase_admin
from firebase_admin import credentials, firestore

load_dotenv()
genai.configure(api_key=os.getenv("GEMINI_API_KEY"))
model = genai.GenerativeModel('gemini-1.5-flash')

# Firebase Initialize
cred = credentials.Certificate("firebase-key.json")
firebase_admin.initialize_app(cred)
db = firestore.client()

app = FastAPI()

def calculate_distance(lat1, lon1, lat2, lon2):
    R = 6371000  # Radius of earth in meters
    phi1, phi2 = math.radians(lat1), math.radians(lat2)
    d_phi = math.radians(lat2 - lat1)
    d_lam = math.radians(lon2 - lon1)
    a = math.sin(d_phi/2)**2 + math.cos(phi1)*math.cos(phi2)*math.sin(d_lam/2)**2
    return R * 2 * math.atan2(math.sqrt(a), math.sqrt(1-a))

@app.get("/")
def home():
    return {"message": "NagrikAI Agent is Awake & Connected to Database!"}


@app.post("/submit")
async def submit(lat: float = Form(...), long: float = Form(...), photo: UploadFile = File(...), audio: UploadFile = File(None)):
    # 1. Deduplication Logic (50 meters)
    docs = db.collection('complaints').stream()
    for doc in docs:
        d = doc.to_dict()
        if calculate_distance(lat, long, d['latitude'], d['longitude']) <= 50:
            new_votes = d.get('upvotes', 1) + 1
            db.collection('complaints').document(doc.id).update({'upvotes': new_votes})
            return {"status": "merged", "message": "Duplicate found, upvoted!"}

    # 2. Gemini AI Analysis
    photo_data = await photo.read()
    contents = [{"mime_type": photo.content_type, "data": photo_data}]
    if audio: contents.append({"mime_type": audio.content_type, "data": await audio.read()})
    
    prompt = "Analyze this civic issue. Return strict JSON: {'category','description','severity','sop'}"
    response = model.generate_content(contents + [prompt])
    ai_res = json.loads(response.text.strip('```json').strip('```'))

    # 3. Save to Firestore
    new_doc = {**ai_res, "latitude": lat, "longitude": long, "upvotes": 1, "status": "Pending"}
    db.collection('complaints').add(new_doc)
    return {"status": "success", "analysis": ai_res}