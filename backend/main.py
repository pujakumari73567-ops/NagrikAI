from fastapi import FastAPI, UploadFile, File, Form

app = FastAPI()

@app.get("/")
def home():
    return {"message": "NagrikAI Backend is Live!"}

@app.post("/submit")
async def submit(lat: float = Form(...), long: float = Form(...), photo: UploadFile = File(...)):
    return {
        "status": "success",
        "data": {"latitude": lat, "longitude": long, "filename": photo.filename}
    }