from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import openai
import os
from dotenv import load_dotenv

load_dotenv()

# FastAPI initialization
app = FastAPI()

# Load OpenAI API key from environment variable
openai.api_key = os.getenv("OPENAI_API_KEY")

if not openai.api_key:
    print("⚠️ OpenAI API key is missing! Make sure to set it in the environment variables.")

# Add CORS middleware to allow iOS app requests
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Allow all origins for development
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Define request model
class TripRequest(BaseModel):
    destination: str
    interests: list
    days: int

@app.post("/generate-itinerary")
def generate_itinerary(request: TripRequest):
    print(f"Received request: {request}")  # Debugging line
    
    try:
        prompt = f"""Create a {request.days}-day travel itinerary for {request.destination} based on these interests: {', '.join(request.interests)}.

IMPORTANT: Follow this EXACT format for each day:

Day 1
Morning:
- First activity
- Second activity
- Third activity

Afternoon:
- First activity
- Second activity
- Third activity

Evening:
- First activity
- Second activity
- Third activity

Night:
- First activity
- Second activity
- Third activity

Rules:
1. Each day must start with "Day X" on its own line
2. Each time period (Morning/Afternoon/Evening/Night) must be on its own line followed by a colon
3. Each activity must start with a hyphen and a space
4. You don't need to include all time periods if not relevant
5. Include at least 2 activities per time period
6. No additional text or descriptions
7. Keep activities concise and specific
8. For single-day itineraries (1 day), focus on the most essential and iconic experiences that can be realistically completed in one day
9. For multi-day itineraries, ensure activities are spread out logically and consider travel time between locations"""

        response = openai.ChatCompletion.create(
            model="gpt-3.5-turbo",
            messages=[
                {"role": "system", "content": "You are a travel itinerary planner. Create detailed but concise daily schedules. For single-day itineraries, focus on the most iconic and essential experiences that can be realistically completed in one day."},
                {"role": "user", "content": prompt}
            ]
        )

        return {"itinerary": response["choices"][0]["message"]["content"]}
    except Exception as e:
        print(f"Error generating itinerary: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000) 