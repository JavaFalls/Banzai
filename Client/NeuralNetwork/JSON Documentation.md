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

### 3. Battle

   "{ "Message Type": "Train", "Message": "Game_state[]"}"

### 4. Train

   "{ "Message Type": "Train", "Message": "Game_state[]"}"


### 5. Kill 

   Requests will have the following format:

   "{ "Message Type": "Kill", "Message": [gamestate], "Arena": "Battle" | "Train" }"

