# 🐟 Vancouver Fishing Assistant (温哥华钓鱼助手)

## Overview
An iOS app for Vancouver Georgia Strait fishing, powered by AI agent trained by professional fishermen.

## Features
1. **AI Assistant** - Weather, tides, currents for Georgia Strait
2. **Fishing Spots** - Recommended spots by fish species
3. **Fuel Calculator** - Estimate fuel costs based on departure & fishing spot
4. **Route Planner** - Optimal routes for fishing, shrimp/crab (fuel efficient)
5. **License Guide** - Fish license website navigation
6. **DFO Regulations** - Restricted areas from DFO handbook
7. **Gear & Bait** - Fishing gear and bait recommendations
8. **Restaurants** - Local fish processing & restaurants
9. **Recipes** - Home cooking guides for your catch

## Architecture

```
┌─────────────────────────────────────────────────────┐
│                   iOS App (SwiftUI)                   │
├─────────────────────────────────────────────────────┤
│  Chat UI │ Map View │ Route Planner │ Info Pages     │
└─────────────┬───────────────────────────────────────┘
              │ HTTPS/WebSocket
              ▼
┌─────────────────────────────────────────────────────┐
│              Backend (Python FastAPI)                 │
├─────────────────────────────────────────────────────┤
│  AI Agent │ RAG Engine │ Route Optimizer │ Data APIs │
├─────────────────────────────────────────────────────┤
│  Vector DB (ChromaDB) │ PostgreSQL │ Redis Cache     │
└─────────────┬───────────────────────────────────────┘
              │
              ▼
┌─────────────────────────────────────────────────────┐
│              External APIs & Data Sources             │
├─────────────────────────────────────────────────────┤
│ • Gemini/Groq (Free LLM)                            │
│ • Environment Canada Weather API                     │
│ • DFO Tides & Currents API                          │
│ • Google Maps / Mapbox                              │
│ • DFO Fisheries Regulations                         │
└─────────────────────────────────────────────────────┘
```

## Tech Stack

| Layer | Technology |
|-------|-----------|
| iOS | SwiftUI, MapKit, Combine |
| Backend | Python 3.12, FastAPI, Uvicorn |
| AI/LLM | Google Gemini API (free) / Groq (Llama 3) |
| RAG | ChromaDB + Sentence Transformers |
| Database | PostgreSQL + Redis |
| Maps | MapKit (iOS) + custom overlay data |
| Deploy | Railway / Render (free tier) |

## Project Structure

```
vancouver-fishing-app/
├── ios/                    # SwiftUI iOS App
│   └── FishingAssistant/
├── backend/                # Python FastAPI Server
│   ├── app/
│   ├── knowledge_base/     # RAG training data
│   └── tests/
└── docs/                   # Documentation
```

## Getting Started

### Backend
```bash
cd backend
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
uvicorn app.main:app --reload
```

### iOS
Open `ios/FishingAssistant.xcodeproj` in Xcode and run.

## AI Training
Professional fishermen can contribute knowledge via:
1. Adding documents to `backend/knowledge_base/`
2. Using the admin panel to add Q&A pairs
3. Feedback loop from user conversations
