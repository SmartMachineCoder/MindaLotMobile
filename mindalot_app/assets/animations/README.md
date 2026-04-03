# Mood Animation Assets

Place Lottie JSON files here for each mood background animation.

## Required files:
- mood_happy.json     — Golden sunrise meadow
- mood_sad.json       — Cozy rain + candlelight
- mood_anxious.json   — Forest canopy + sunlight
- mood_angry.json     — Ocean waves
- mood_confused.json  — Starry cosmos
- mood_default.json   — Default calm background

## Sources for free Lottie animations:
- https://lottiefiles.com (search: "ocean waves", "forest", "stars", "sunrise", "rain")
- https://lottiereact.com

## Upload to Firebase Storage:
Once you have the files, upload them to your Firebase Storage bucket
under the path: /mood_assets/animations/
The app will download and cache them on first use.
