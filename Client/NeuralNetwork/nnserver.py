""" To use the pywin32 headers, run this command in a terminal
        pip install pywin32                                     """
import win32pipe, win32file, pywintypes
import sys, math, json
import tensorflow as tf
from tensorflow import keras
from tensorflow.keras.models import load_model

# Create pipes
request_handle = win32pipe.CreateNamedPipe(
        r'\\.\pipe\RequestFromClient',
        win32pipe.PIPE_ACCESS_DUPLEX,
        win32pipe.PIPE_TYPE_MESSAGE | win32pipe.PIPE_READMODE_MESSAGE | win32pipe.PIPE_WAIT,
        1, 65536, 65536,
        0,
        None)

response_handle = win32pipe.CreateNamedPipe(
        r'\\.\pipe\ResponseToClient',
        win32pipe.PIPE_ACCESS_DUPLEX,
        win32pipe.PIPE_TYPE_MESSAGE | win32pipe.PIPE_READMODE_MESSAGE | win32pipe.PIPE_WAIT,
        1, 65536, 65536,
        0,
        None)

def connect_request():
         # Create a named pipe to receive requests from the client
        try:
                # Block until client connects
                print("Waiting for client {request}")
                win32pipe.ConnectNamedPipe(request_handle, None)
                print("Client Connected :)")

        except pywintypes.error as e:
                if e.args[0] == 2:
                        print("Pipe not created.")
                elif e.args[0] == 109:
                        print("Closed Pipe")
                input('what do you want me to do?')

def connect_response():
        try:
                # Block until client connects
                print("Waiting for client {response}")
                win32pipe.ConnectNamedPipe(response_handle, None)
                print("Client Connected :)")

        except pywintypes.error as e:
                if e.args[0] == 2:
                        print("Pipe not created.")

                elif e.args[0] == 109:
                        print("Closed Pipe")
                input('what do you want me to do?')

def get_client_request():
        # Create a named pipe to receive requests from the client
        try:
                # Get request from Godot Client
                # Request is a tuple with the structure (ERROR_CODE, MESSAGE)
                request = win32file.ReadFile(request_handle, 64*1024)
                # win32pipe.DisconnectNamedPipe(request_handle)
                # win32file.CloseHandle(request_handle)

        except pywintypes.error as e:
                if e.args[0] == 2:
                        print("Pipe not created.")
                elif e.args[0] == 109:
                        print("Closed Pipe")
                input('what do you want me to do?')
        return request

def send_response(response):
        try:
                # Send response to Godot client
                win32file.WriteFile(response_handle, str.encode(f"{response}"))

                # win32pipe.DisconnectNamedPipe(response_handle)
                # win32file.CloseHandle(response_handle)

        except pywintypes.error as e:
                if e.args[0] == 2:
                        print("Pipe not created.")

                elif e.args[0] == 109:
                        print("Closed Pipe")
                input('what do you want me to do?')

def react(game_state, model):
   input_list = []
   output_list = []
   response_list = []
   for item in game_state:
      input_list.append(item)
   str_input_list = str(input_list)
   input_list = str_input_list.replace(" ","").replace("''","'0'").replace("[]", "0,0").replace("[","").replace("]","").replace("(","")\
   .replace(")","").replace("'","").replace("\n","").replace("False", "0").replace("True", "1").replace('"',"").replace("''","'0'").split(",")
   input_list.pop(0)
   input_list.pop(0)
   print("input_;ist=====================")
   print(input_list)
   for item in input_list:
           output_list.append(float(item))
   response_list = model.predict(output_list)
   output_list = []
   for item in response_list:
           for x in item:
                   output_list.append(x)
   return(output_list)

def load_bot(file_name = 'my_model.h5'):
   model = load_model(__file__.replace('nnserver.py', file_name))
   return model


# Godot Message Processor. See JSON Documentation to find out how we use this module
def process_message(message):
        if   message["Message Type"] == "Battle" :
                pass
        elif message["Message Type"] == "Train"  :
                pass
        elif message["Message Type"] == "Load"   :
                if   message["Game Mode"] == "Train":
                        player_bot = load_bot(message["File Name"])
                        return
                elif message["Game Mode"] == "Battle":
                        if   message["Opponent?"] == "Yes":
                                opponent_bot = load_bot(message["File Name"])
                        elif message["Opponent?"] == "No":
                                player_bot = load_bot(message["File Name"])
                        else:
                                return print("Invalid Opponent")
                else:
                        return print("Invalid Game Mode")
                pass
        elif message["Message Type"] == "Request":
                return message["Message"]
        elif message["Message Type"] == "Exit":
                return 109
        else:
                return print("Message not recognized")

# Loaded Bot files
player_bot = None
opponent_bot = None

bot = load_bot()
response = []

# Tell Godot I'm ready to connect
successful = False
while not successful:
        try:
                server_ready = win32file.CreateFile(r'\\.\pipe\ServerReady',
                        win32file.GENERIC_READ | win32file.GENERIC_WRITE,
                        0,
                        None,
                        win32file.OPEN_EXISTING,
                        0,
                        None)
                
                successful = True
                win32file.CloseHandle(server_ready)
        except pywintypes.error as e:
                if e.args[0] == 2:
                        print("Pipe not created.")
                        input('Execution paused in send_request()')
                elif e.args[0] == 109:
                        print("Closed Pipe")
                        successful = True

connect_request()
connect_response()
while True:
        print("Server Code\n\n")
        print("get request")

        request_completed = False
        while not request_completed:
                try:
                        request = get_client_request()[1].decode('unicode-escape').replace('(', '').replace(')', '').replace('\x00', '')
                        request = json.loads(request)

                        # Process a request for the appropriate bot
                        #response = react(process_message(request), player_bot if request["Requestor"] == "Player" else opponent_bot)
                        print(request)
                        request_completed = True
                except UnboundLocalError as Null_Reference:
                        print('Client Request failed! Retrying...')
                        input("Do you want to retry?")

        ### Process Request ###
        if process_message(request) == 109:
                break
        print("sending response")
        response = "We Did IT!!!!!"
        print(response)
        send_response(response)


# Close pipes
print("Shutting Down...")
win32pipe.DisconnectNamedPipe(request_handle)
win32file.CloseHandle(request_handle)
win32pipe.DisconnectNamedPipe(response_handle)
win32file.CloseHandle(response_handle)