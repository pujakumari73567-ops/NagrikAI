import os
import json
from fastapi import FastAPI, UploadFile, File, Form
from dotenv import load_dotenv
import google.generativeai as genai

load_dotenv()
genai.configure(api_key=os.getenv("GEMINI_API_KEY"))

model = genai.GenerativeModel('gemini-1.5-flash')

app = FastAPI()

@app.get("/")
def home():
    return {"message": "NagrikAI Agent is Awake!"}

@app.post("/submit")
async def submit(
    lat: float = Form(...), 
    long: float = Form(...), 
    photo: UploadFile = File(...),
    audio: UploadFile = File(None) #optional
):
    print("🚨 Received complaint, analyzing...")
    
    # 1. Prepare data for Gemini
    photo_bytes = await photo.read()
    contents = [
        {"mime_type": photo.content_type, "data": photo_bytes}
    ]
    
    # Audio to content
    if audio:
        audio_bytes = await audio.read()
        contents.append({"mime_type": audio.content_type, "data": audio_bytes})

    # 2. The Orchestrator Prompt
    prompt = """
    You are an AI assistant for a civic issue reporting app in India.
    Analyze the provided image (and audio if present). 
    If audio is present (likely in Hindi), translate the context to English.
    
    Return a strict JSON object with exactly these keys:
    - "category": (e.g., "Roads", "Sanitation", "Electricity", "Water")
    - "description": (Detailed English description of the problem based on visual and audio context)
    - "severity": ("Low", "Medium", "High", "Critical")
    - "sop": (A 3-step Standard Operating Procedure for the government authority to fix this issue)

    Do NOT wrap the output in ```json blocks. Return ONLY the raw JSON format.
    """
    contents.append(prompt)

    try:
        # 3. Calling Gemini API
        response = model.generate_content(contents)
        
        # 4. Converting AI text to strict JSON
        ai_result = json.loads(response.text)
        
        print("✅ AI Analysis Complete!")
        return {
            "status": "success",
            "location": {"latitude": lat, "longitude": long},
            "analysis": ai_result
        }
        
    except Exception as e:
        print(f"❌ Error in AI processing: {e}")
        return {"status": "error", "message": str(e), "raw_response": response.text}