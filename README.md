# 🛡️ NagrikAI: Next-Gen AI-Powered Civic Grievance System
[![Team: NexGen Duo](https://img.shields.io/badge/Team-NexGen%20Duo-blueviolet.svg?style=for-the-badge)](https://github.com/pujakumari73567-ops/NagrikAI)
[![Stack: Flutter + FastAPI + Gemini](https://img.shields.io/badge/Tech--Stack-Full--AI--Integration-green.svg?style=for-the-badge)](https://google.ai/)

**NagrikAI** ek revolution hai civic reporting mein. Ye sirf ek app nahi, balki ek intelligent system hai jo common citizens aur authorities ke beech ke gap ko AI ke zariye khatam karta hai. 

---

## 🌟 Project Overview & Vision
Aksar kachre ya tooti sadkon ki shikayat karne mein log isliye hichkichate hain kyunki process lamba hota hai. **NagrikAI** ise "Snap & Speak" jitna aasaan banata hai.
- **Problem:** Manual reporting, slow identification, and no live tracking.
- **Solution:** AI-automated classification, multilingual voice processing, and real-time dashboard tracking.

---

## 🛠️ System Architecture & Workflow
NagrikAI ek robust 4-tier architecture par kaam karta hai:

1.  **Capture Layer (Flutter):** User photo leta hai, Hindi/Regional voice note record karta hai, aur GPS automatically fetch hota hai.
2.  **Intelligence Layer (FastAPI + Gemini 1.5 Flash):** - Image Vision se kachre ya damage ki severity pehchani jati hai.
    - Audio-to-Text se problem ki description nikali jati hai.
    - AI automatically ek SOP (Standard Operating Procedure) generate karta hai.
3.  **Persistence Layer (Firebase Firestore):** Saara data real-time mein store hota hai.
4.  **Admin Layer (Dashboard):** Authorities har case ko map par dekh sakti hain aur status "Solved" mark kar sakti hain.



---

## 💻 Tech Stack & Syntax Structure

### **Backend (FastAPI & Gemini Integration)**
```python
# Core AI Logic Structure
@app.post("/submit")
async def process_report(photo: UploadFile, lat: float, long: float, audio: UploadFile = None):
    # 1. Gemini Vision: Analyzes the Image
    # 2. Gemini Pro: Processes Voice & Location
    # 3. Firestore: Saves structured JSON
    return {"status": "Success", "analysis": ai_result}


// Real-time Status Tracking Syntax
StreamBuilder(
  stream: FirebaseFirestore.instance.collection('complaints').snapshots(),
  builder: (context, snapshot) {
    // Shows Live Update from Pending to Solved
  }
)


NagrikAI/
├── frontend/                # Flutter App Code
│   ├── lib/main.dart        # Camera, Audio & API logic
│   └── pubspec.yaml         # Dependencies (Dio, Record, Geolocator)
├── backend/                 # Python FastAPI Server
│   ├── main.py              # Gemini AI & Firestore Integration
│   └── requirements.txt     # Python Packages
├── .gitignore               # Security (Prevents leaking secret keys)
└── README.md                # 10/10 Documentation

📈 Future Benefits & Scalability
Smart City Integration: Direct connection with municipal waste management vehicles.

Predictive Maintenance: AI identify kar sakega ki kaunsa area "Heatmap" ban raha hai jahan bar-bar kachra fenka jata hai.

Automatic Reward System: Citizens ko "Nagrik Points" milenge har valid report par, jise wo rewards ke liye redeem kar sakein.

Edge AI: Processing ko aur fast karne ke liye on-device AI integration.


👥 Meet The Developers (NexGen Duo)
Pooja Kumari : Lead Frontend Dev, responsible for Flutter UI, Camera/Audio hardware integration, and Location API services.

Nidhi Khushal Gohil: Backend Architect, responsible for Gemini AI prompt engineering, FastAPI server, and Firebase Admin Dashboard.



🚀 How to Run
git clone https://github.com/pujakumari73567-ops/NagrikAI.git

Backend folder mein pip install -r requirements.txt chalayein.

Apni serviceAccountKey.json ko backend folder mein rakhein.

uvicorn main:app --reload se server on karein.

flutter run se app start karein.
