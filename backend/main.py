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
        prompt = f"""Create a itinerary for {request.destination} for {request.days} days based on interests: {', '.join(request.interests)}.

Format each day as:
Day X
Morning:
- Activity 1
- Activity 2
- Activity 3

Afternoon:
- Activity 1
- Activity 2
- Activity 3

Evening:
- Activity 1
- Activity 2
- Activity 3

Night:
- Activity 1
- Activity 2
- Activity 3

Rules:
1. Start each day with "Day X"
2. Each time period (Morning/Afternoon/Evening/Night) on its own line with colon
3. Each activity starts with hyphen and space
4. Include 2+ activities per time period
5. Keep activities concise
6. For 1-day trips, focus on essential experiences
7. For multi-day trips, consider travel time between locations"""

        response = openai.ChatCompletion.create(
            model="gpt-3.5-turbo",
            messages=[
                {"role": "system", "content": "You are a travel planner. Create concise daily schedules. For 1-day trips, focus on essential experiences. For multi-day trips, make sure to generate all the days and their plans without skipping any days"},
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