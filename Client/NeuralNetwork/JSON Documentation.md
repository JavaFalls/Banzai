# JSON Documentation

The Messages from Godot will be as follows:

## Message Type





### 1. Load

   Load will be as follows:

   "{ "Message Type": "Load", "Game Mode": "Train" | "Battle" ...}"

   if train, "{ "File Name": "file_name" }" else,

   if battle, "{ "File Name": "file_name", "Opponent?": "Yes" | "No" }"

### 2. Save

   "{ "Message Type": "save", .}"

### 3. Request

   Requests will have the following format:

   "{ "Message Type": "Request", "Message": [gamestate], "Arena": "Battle" | "Train" }"

