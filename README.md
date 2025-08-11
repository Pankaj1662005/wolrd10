# Project Summary: wolrd10

## Overview

This repository contains a Flutter application named "world7" (or "wolrd10" as per the repo name), which provides a platform for users to interact with various AI-powered productivity features. The app integrates speech recognition, text transcription, AI summarization, and user profile management, leveraging Firebase for authentication and data storage.

---

## Core Features

### 1. **Authentication & Theming**
- Users authenticate via Firebase Auth.
- Theme switching (Light/Dark) is managed via a `ThemeProvider`.
- The app uses a bottom navigation bar to switch between its main screens.

### 2. **Speech Recognition & Transcription**
- The main screen includes a speech recognition feature (details in `SpeechRecognitionScreen`).
- Recognized speech is transcribed and stored in a Firestore collection (`recognized_texts`) with a timestamp and user ID.
- The "Transcription" tab lists these recognized texts for the authenticated user in chronological order.

### 3. **AI Summarization Chat (AURA)**
- The "AURA" tab allows users to:
  - Enter a prompt or question.
  - Optionally select a date to pull all transcribed texts for that day.
  - The app then combines the user prompt and the day's recognized texts and sends them to a HuggingFace text summarization/model inference API.
  - The AI's response is shown in a chat-like interface.
- Supports different models for general prompts and date-specific summaries.
- UI shows a chat history and a typing indicator ("Typing...") for AI responses.

### 4. **Mind-map (Coming Soon)**
- The "Mind-map" tab is a placeholder for future functionality.

### 5. **Profile & Resume**
- Includes profile management screens, including the ability to fetch and display user resume details from Firestore.

---

## Technical Stack

- **Flutter** (cross-platform mobile/web framework)
- **Firebase**:
  - Auth (user management)
  - Firestore (data storage for recognized texts, users, etc.)
- **Provider** (state management, for theming)
- **HuggingFace API** (for AI summarization and LLM inference)
- **Material Design** for UI

---

## Code Structure

- `lib/main.dart`: App entry point, sets up Firebase, theming, authentication gate, and bottom navigation.
- `lib/screens/`: Contains the major UI screens:
  - `home_screen.dart`
  - `profile_screen.dart`
  - `time_screen.dart` (with tabs for Transcription, AURA, and Mind-map)
  - `time_screen/TranscriptionScreen.dart`: Lists recognized texts.
  - `time_screen/SummaryScreen.dart`: Implements the AI chat/summarizer.
  - `time_screen/MindMapScreen.dart`: Mind-map placeholder.
- `lib/0 theme/`: Theming logic and colors.

---

## Detailed Flow Example: AI Summarization

1. **User Login:** Required for all features.
2. **Transcription:** User's speech is converted to text and stored with a timestamp.
3. **AURA Tab:**
   - User enters a prompt and (optionally) selects a date.
   - The app fetches all recognized texts for that user and date.
   - It sends the combined prompt and texts to a HuggingFace inference API.
   - Displays the AI-generated summary or chat response.
   - Supports conversation history and dynamic UI updates.
4. **Profile Tab:** Lets users manage their profile and view resume data.

---

## Intended Use

The app is designed as a personal productivity tool, helping users:
- Transcribe spoken content and keep a daily log.
- Interact with an AI assistant to summarize or answer questions about their transcriptions.
- (Planned) Visually organize information using mind maps.
- Manage their profile and resume data.

---

## Notes

- The app is a starting point and contains placeholders for future features (e.g., Mind-map).
- The README in the repo is generic (boilerplate from new Flutter projects) and does not describe these features, but the code reveals the above functionalities.
- The HuggingFace API key must be set for AI features to work.

---

## Summary

**wolrd10/world7** is a cross-platform Flutter app offering speech-to-text transcription, AI-powered summarization (via HuggingFace), and profile management, with Firebase as its backend. It is an extensible productivity tool with future plans for mind-mapping and enhanced AI features.
