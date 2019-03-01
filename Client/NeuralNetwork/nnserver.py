""" To use the pywin32 headers, run this command in a terminal
        pip install pywin32                                     """
import win32pipe, win32file, pywintypes
import sys, math, json
import tensorflow as tf
from tensorflow import keras
from tensorflow.keras.models import load_model
from tensorflow.keras.models import save_model
from tensorflow.keras.models import Sequential
from tensorflow.keras.layers import Dense
from tensorflow.keras.optimizers import Adam
import random
import numpy as np
from collections import deque
#import mss                                    # For taking screen shots
#from PIL import Image                         # For image stuff

# Just disables the warning, doesn't enable AVX/FMA
import os
os.environ['TF_CPP_MIN_LOG_LEVEL'] = '2'

state_size  = 13
action_size = 108
batch_size  = 16

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

class DQN_agent:

    def __init__(self, state_size, action_size):
        self.state_size = state_size 
        self.action_size = action_size

        self.memory = deque(maxlen=20000)
        self.gamma         = 0.95 # discount future reward
        self.epsilon       = 1.0 # exploration rate; initial rate; skew 100% towards exploration
        self.epsilon_decay = 0.995 # rate at which epsilon decays; get multiplied to epsilon
        self.epsilon_min   = 0.01 # floor that epsilon will rest at after heavy training

        self.learning_rate = 0.001

        self.reward        = 0
        self.state_counter = 0
        self.action        = 0
        self.gamestate     = 0

        self.model = self._build_model()
    
    def _build_model(self): # defines the NN
        model = Sequential() 
        model.add(Dense(140, input_dim = self.state_size, activation='linear', bias_initializer='zeros'))
        model.add(Dense(120, activation='linear'))
        model.add(Dense(self.action_size, activation='linear'))

        model.compile(loss='mean_squared_error', optimizer=Adam(lr = self.learning_rate))

        return model

    def remember(self, state, action, reward, next_state):
        self.memory.append((state, action, reward, next_state))

    def predict(self, state):
        if np.random.rand() <= self.epsilon: # if we randomly select a number less than our epilson we will choose 1 random action
            return random.randrange(self.action_size)
        act_values = self.model.predict(state)
        print("act_value1")
        print(act_values[0,0:5])
        return np.argmax(act_values[0]) # chooses the best choice

    def replay(self, batch_size):
        minibatch = random.sample(self.memory, batch_size)

        for state, action, reward, next_state in minibatch:
            print(state)
            print(action)
            print(reward)
            print(next_state)
            target = (reward) # + self.gamma * np.amax(self.model.predict(next_state)[0]))
            target_f = self.model.predict(state)
            target_f[0] [action] = target

            self.model.fit(state, target_f, epochs=1, verbose=0)
        
        if self.epsilon > self.epsilon_min:
            self.epsilon *= self.epsilon_decay

    def load(self):
        self.model = load_model(__file__.replace('nnserver.py', 'my_model.h5'))
    def save(self):
        self.model = save_model(__file__.replace('nnserver.py', 'my_model.h5'))

    def reshape(self, gamestate): # needs some stuff to remove the reward that gets sent with it
        input_list = []
        output_list = []
        for item in gamestate:
            input_list.append(item)
        str_input_list = str(input_list)
        input_list = str_input_list.replace(" ","").replace("''","'0'").replace("[]", "0,0").replace("[","").replace("]","").replace("(","")\
        .replace(")","").replace("'","").replace("\n","").replace("False", "0").replace("True", "1").replace('"',"").replace("''","'0'").split(",")
        for item in input_list:
           output_list.append(float(item))
        # self.reward = output_list[20]
        # output_list = output_list[0:20]
        output_list = np.reshape(output_list, (1, self.state_size))
        return output_list

    def train(self, new_gamestate):
        if self.state_counter >= 1:
            next_gamestate = new_gamestate # get the gamestate
            self.reward = self.get_reward(self.gamestate[0], next_gamestate[0])
            self.remember(self.gamestate,self.action,self.reward,next_gamestate)
            self.gamestate = next_gamestate   
        else:
            self.gamestate = new_gamestate # get the gamestate

        self.state_counter +=1
        self.action = self.predict(self.gamestate)

        if len(self.memory) % batch_size == 0 and len(self.memory) > batch_size: # trains the model, automatically trains once a certain threshold of trainable memories has been reached
                self.replay(batch_size)

        return self.action

    def get_reward(self, gamestate, next_gamestate):
        bot_aim_angle_diff      = abs(gamestate[2] - gamestate[5])
        bot_aim_next_angle_diff = abs(next_gamestate[2] - next_gamestate[5])
        if bot_aim_angle_diff > .5:
                bot_aim_angle_diff = 1 - bot_aim_angle_diff
        if bot_aim_next_angle_diff > .5:
                bot_aim_next_angle_diff = 1 - bot_aim_next_angle_diff
        player_aim_angle_diff      = abs(gamestate[2] - gamestate[5])
        player_aim_next_angle_diff = abs(next_gamestate[2] - next_gamestate[5])
        if player_aim_angle_diff > .5:
                player_aim_angle_diff = 1 - player_aim_angle_diff
        if player_aim_next_angle_diff > .5:
                player_aim_next_angle_diff = 1 - player_aim_next_angle_diff

        new_reward = 0
        new_reward += gamestate[9] - next_gamestate[9] * 10                    # reward for dealing damage
        new_reward += bot_aim_angle_diff - bot_aim_next_angle_diff * 10         # reward for not being targeted

        new_reward -= gamestate[3] - next_gamestate[3] * 10                    # criticism for losing health
        new_reward -= player_aim_angle_diff - player_aim_next_angle_diff * 10   # criticism for bad aim
        return new_reward


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
def load():
        #if we load and don't start fresh
       fighter1.load()
       fighter2.load()
#get_screenshot()
fighter1 = DQN_agent(state_size, action_size)
fighter2 = DQN_agent(state_size, action_size)

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
                        input('Press enter to reconnect to client process')
                elif e.args[0] == 109:
                        print("Closed Pipe")
                        successful = True

connect_request()
connect_response()
while True:
        print("Server Code\n\n")
        print("get request")
        gamestate = []
        next_gamestate = []
        # print("Server Code\n\n")
        # print("get request")

        request_completed = False
        try:
                request = get_client_request()[1].decode('unicode-escape').replace('(', '').replace(')', '').replace('\x00', '')
                request = json.loads(request)
                print(request)
                # print(request)
                # some kind of parsing with request then some if statements
                #packet_type = identify(request)
                #if packet_type == 'L':
                        #response = load()
                #elif packet_type == 'T':
                request_completed = True

                # Process a request for the appropriate bot
                #response = react(process_message(request), player_bot if request["Requestor"] == "Player" else opponent_bot)
        except UnboundLocalError as Null_Reference:
                print('Client Request failed! Retrying...')
                input("Do you want to retry?")

        ### Process Request ###
        if process_message(request) == 109:
                break
        request = fighter1.reshape(request["Message"])
        #print(request)
        response = fighter1.train(request)
        print(response)
        # response = request
        #elif packet_type == 'B':
                #response = battle(request, fighter1, fighter2)
        #print(f'{request}')

        print("sending response")
        # print("sending response")
 #       print(response)
        send_response(response) # send the action or actions or load successful message based on packet type

# Close pipes
print("Shutting Down...")
win32pipe.DisconnectNamedPipe(request_handle)
win32file.CloseHandle(request_handle)
win32pipe.DisconnectNamedPipe(response_handle)
win32file.CloseHandle(response_handle)