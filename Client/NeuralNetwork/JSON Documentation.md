# JSON Documentation

The Messages from Godot will be as follows:

## Message Type

### 1. Battle

### 2. Train

### 3. Load

   Load will be as follows:

   "{ "Message Type": "Load", "Game Mode": "Train" | "Battle" ...}"

   if train, "{ "File Name": "file_name" }" else,

   if battle, "{ "File Name": "file_name", "Opponent?": "Yes" | "No" }"

### 4. Request

   Requests will have the following format:

   "{ "Message Type": "Request", "Message": [gamestate], "Requestor": "Player" | "Opponent" }"

   if in train, Just use "Requestor": "Player" to tell the Server to run predictions on the Player's AI.