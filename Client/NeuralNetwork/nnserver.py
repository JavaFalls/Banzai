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
import matplotlib.pyplot as plt 

# Just disables the warning, doesn't enable AVX/FMA
import os
os.environ['TF_CPP_MIN_LOG_LEVEL'] = '2'

state_size  = 13
action_size = 108
batch_size  = 1

BOT_POSITION_X      = 0
BOT_POSITION_Y      = 1
BOT_AIM_ANGLE       = 2
BOT_HEALTH          = 3
BOT_IN_PERIL        = 4
BOT_OPPONENT_ANGLE  = 5 # the difference between the bot's aim angle and the angle of the opponent to the bot
OPPONENT_DISTANCE   = 6
OPPONENT_BOT_ANGLE  = 7 # the difference between the opponents's aim angle and the angle of the bot to the opponent
OPPONENT_IN_PERIL   = 8
OPPONENT_HEALTH     = 9
OPPONENT_AIM_ANGLE  = 10
OPPONENT_POSITION_Y = 11
OPPONENT_POSITION_X = 12

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
                print("=== Exiting...===")
                exit()

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
                print("=== Exiting...===")
                exit()

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
                print("=== Exiting...===")
                exit()
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
                print("=== Exiting...===")
                exit()
class DQN_agent:

    def __init__(self, state_size, action_size):
        self.state_size = state_size
        self.action_size = action_size

        self.memory = deque(maxlen=16)
        self.gamma         = 0.9 # discount future reward; used for Q which doesn't work for us
        self.epsilon       = 1 # exploration rate; initial rate; skew 100% towards exploration
        self.epsilon_decay = .995 # rate at which epsilon decays; get multiplied to epsilon
        self.epsilon_min   = 0.01 # floor that epsilon will rest at after heavy training

        self.learning_rate = .5

        self.reward        = 0
        self.state_counter = 0
        self.action        = 0
        self.player_action = 0      # the action performed by the human and not the neural network
        self.gamestate     = 0
        self.rewards       = [] 
        self.reward_total  = 0
        self.number_of_rewards = 0

        self.model = self._build_model()

    def _build_model(self): # defines the NN
        model = Sequential()
        model.add(Dense(216, input_dim = self.state_size, activation='relu'))
        model.add(Dense(self.action_size, activation='linear'))

        model.compile(loss='mean_absolute_error', optimizer=Adam(lr = self.learning_rate))

        return model

    def remember(self, state, action, reward, next_state):
        self.memory.append((state, action, reward, next_state))

    def predict(self, state):
        if np.random.rand() <= self.epsilon: # if we randomly select a number less than our epilson we will choose 1 random action
            print()
            print()
            print()
            return random.randrange(self.action_size)
        act_values = self.model.predict(state)
        print("act_value1")
        print(act_values[0,0:5],";")
        print("                                                " ,np.amax(act_values[0]))
        return np.argmax(act_values[0]) # chooses the best choice

    def replay(self, batch_size):
        minibatch = random.sample(self.memory, batch_size)

        for state, action, reward, next_state in self.memory: # use minibatch for a random smaller sample
        #     print(state)
        #     print(action)
        #     print(reward)
        #     print(next_state)
        #     print("action/reward: ",action,":",reward,"-------")
            target = (reward)# + self.gamma * np.amax(self.model.predict(next_state)[0]))
            target_f = self.model.predict(state)
            target_f[0] [action] = target

            self.model.fit(state, target_f, epochs=1, verbose=0)

        if self.epsilon > self.epsilon_min:
            self.epsilon *= self.epsilon_decay

    def load(self):
        self.model = load_model(__file__.replace('nnserver.py', 'my_model.h5'))
    def save(self):
        self.model = save_model(self.model, __file__.replace('nnserver.py', 'my_model.h5'))

    def reshape(self, gamestate):
        input_list = []
        output_list = []
        for item in gamestate:
            input_list.append(item)
        str_input_list = str(input_list)
        input_list = str_input_list.replace(" ","").replace("''","'0'").replace("[]", "0,0").replace("[","").replace("]","").replace("(","")\
        .replace(")","").replace("'","").replace("\n","").replace("False", "0").replace("True", "1").replace('"',"").replace("''","'0'").split(",")
        for item in input_list:
           output_list.append(float(item))
        # self.player_action = int(output_list[0])
        # output_list = output_list[1:self.state_size+1]
        output_list = np.reshape(output_list, (1, self.state_size))
        return output_list

    def get_state_size(self):
        return self.state_size

    def train(self, new_gamestate):
        if self.state_counter >= 1:
            next_gamestate = new_gamestate # get the gamestate
            #self.reward = self.get_reward(np.flip(self.gamestate,1)[0], np.flip(next_gamestate,1)[0]) # for train on player
            self.reward = self.get_reward(self.gamestate[0], next_gamestate[0])
            print("########################################")
            #self.remember(np.flip(self.gamestate,1),self.player_action,self.reward,np.flip(next_gamestate,1))# for train on player
            self.remember(self.gamestate,self.action,self.reward,next_gamestate)
            self.gamestate = next_gamestate
        else:
            self.gamestate = new_gamestate # get the gamestate

        self.state_counter +=1
        self.action = self.predict(self.gamestate)

        # if len(self.memory) % batch_size == 0 and len(self.memory) > batch_size: # trains the model, automatically trains once a certain threshold of trainable memories has been reached
        #         self.replay(batch_size)
        if len(self.memory) > 0: # trains the model, automatically trains once a certain threshold of trainable memories has been reached
                self.replay(batch_size)

        return self.action
    def graph_rewards(self):
        plt.title('Rewards Graph')
        plt.ylabel('Rewards')
        plt.xlabel('Epoch')
        plt.plot(self.rewards)
        plt.show()

        return
    def get_reward(self, gamestate, next_gamestate):
        negative_reward_count = 0
        reward_count = 0
        # if gamestate[OPPONENT_POSITION_X] < .3:
        #         self.epsilon = 0
        # elif gamestate[OPPONENT_POSITION_X] > .7:
        #         self.epsilon = 1
        # else:
        #         self.epsilon = .1
        # print(gamestate[OPPONENT_POSITION_X], "gamestate[OPPONENT_POSITION_X]")

        bot_aim_angle_diff      = abs(gamestate[BOT_AIM_ANGLE] - gamestate[BOT_OPPONENT_ANGLE])
        bot_aim_next_angle_diff = abs(next_gamestate[BOT_AIM_ANGLE] - next_gamestate[BOT_OPPONENT_ANGLE])
        if bot_aim_angle_diff > .5:
                bot_aim_angle_diff = 1 - bot_aim_angle_diff
        if bot_aim_next_angle_diff > .5:
                bot_aim_next_angle_diff = 1 - bot_aim_next_angle_diff
        opponent_aim_angle_diff      = abs(gamestate[OPPONENT_AIM_ANGLE] - gamestate[OPPONENT_BOT_ANGLE])
        opponent_aim_next_angle_diff = abs(next_gamestate[OPPONENT_AIM_ANGLE] - next_gamestate[OPPONENT_BOT_ANGLE])
        if opponent_aim_angle_diff > .5:
                opponent_aim_angle_diff = 1 - opponent_aim_angle_diff
        if opponent_aim_next_angle_diff > .5:
                opponent_aim_next_angle_diff = 1 - opponent_aim_next_angle_diff

        # print("player_aim angle diff", player_aim_angle_diff,"^^^^")
        # print("opponent aim angle: ",gamestate[10])

        new_reward = 0
        #new_reward += (gamestate[9] - next_gamestate[9]) * 20                    # reward for dealing damage
        # new_reward += (bot_aim_angle_diff - bot_aim_next_angle_diff) * -5000      # reward for good aim
        #new_reward += 1/(bot_aim_next_angle_diff + 0.0001)                        # reward for pointing at player
        # new_reward += (gamestate[8]+next_gamestate[8]) * 10000                    # reward for putting the player in peril

        # print("bot_aim_angle_diff - bot_aim_next_angle_diff ",bot_aim_angle_diff - bot_aim_next_angle_diff)
        # print("1-bot_aim_next_angle_diff                    ",1-bot_aim_next_angle_diff)
        # print("bot_aim_next_angle_diff                      ",bot_aim_next_angle_diff)

        # reward for good aim #################################################################################
        reward_count += 1
        accuracy_reward = 0
        if (bot_aim_angle_diff - bot_aim_next_angle_diff):
                if bot_aim_angle_diff < bot_aim_next_angle_diff:
                        accuracy_reward = -1
                else:
                        accuracy_reward = 1
        else:
                # accuracy_reward +=  (1-bot_aim_next_angle_diff)*50
                if bot_aim_next_angle_diff < .05:
                        accuracy_reward = 2
                else:
                        accuracy_reward = -1

        # Reward for being close to the opponent ##############################################################
        reward_count += 1
        distance_reward = 0
        if (gamestate[OPPONENT_DISTANCE] - next_gamestate[OPPONENT_DISTANCE]):
                if gamestate[OPPONENT_DISTANCE] < next_gamestate[OPPONENT_DISTANCE]:
                        distance_reward = -1
                else:
                        distance_reward = 1
        else:
                if gamestate[OPPONENT_DISTANCE] <= .15:
                     distance_reward = 2

        # reward for avoiding being targeted ##################################################################
        reward_count += 1
        avoidance_reward = 0
        if (opponent_aim_angle_diff - opponent_aim_next_angle_diff):
                if opponent_aim_angle_diff > opponent_aim_next_angle_diff:
                        avoidance_reward = -1 # should this be included; may overpower whole thing
                else:
                        avoidance_reward = 1
        else:
                # avoidance_reward +=  (opponent_aim_next_angle_diff)*50
                if opponent_aim_next_angle_diff < .1:
                        avoidance_reward = -1
                if opponent_aim_next_angle_diff > .3:
                        avoidance_reward = 2

        # Reward for running away from opponent ###############################################################
        reward_count += 1
        flee_reward   = 0
        if (gamestate[OPPONENT_DISTANCE] - next_gamestate[OPPONENT_DISTANCE]):
                if gamestate[OPPONENT_DISTANCE] > next_gamestate[OPPONENT_DISTANCE]:
                        flee_reward = -1
                else:
                        flee_reward = 1
        else:
                if gamestate[OPPONENT_DISTANCE] >= .35:
                     flee_reward = 2



        #new_reward -= (gamestate[3] - next_gamestate[3]) *  5                   # criticism for losing health

        # new_reward -= (player_aim_angle_diff - player_aim_next_angle_diff) * 5   # criticism for being targeted # dont use
        # new_reward -= (gamestate[4]+next_gamestate[4]) * 10                    # criticism for the bot being in peril # dont use

        # if (((gamestate[3] - next_gamestate[3]) == 0) and ((gamestate[4] - next_gamestate[4]) == 1)): # reward for dodging
        
        print("accuracy_reward:           ", accuracy_reward)
        print("avoidance_reward:          ", avoidance_reward)
        print("distance_reward:           ", distance_reward)
        print("flee_reward                ", flee_reward)

        # new_reward += accuracy_reward
        # new_reward += avoidance_reward
        # new_reward += distance_reward
        new_reward += flee_reward
        # if accuracy_reward < 0:
        #         negative_reward_count += 1
        # if avoidance_reward < 0:
        #         negative_reward_count += 1
        # if distance_reward < 0:
        #         negative_reward_count += 1
        if flee_reward < 0:
                negative_reward_count += 1

        if negative_reward_count >= reward_count-1:
                new_reward = -1
        if distance_reward < 0:
                new_reward = -1
        self.reward_total += new_reward
        self.number_of_rewards +=1
        self.rewards.append([(self.reward_total / self.number_of_rewards), self.epsilon])
        print("                                                                               *reward     ",new_reward)
        return new_reward


def load_bot(file_name = 'my_model.h5'):
   model = load_model(__file__.replace('nnserver.py', file_name))
   return model
def reshape(gamestate, state_size):
        input_list = []
        output_list = []
        for item in gamestate:
            input_list.append(item)
        str_input_list = str(input_list)
        input_list = str_input_list.replace(" ","").replace("''","'0'").replace("[]", "0,0").replace("[","").replace("]","").replace("(","")\
        .replace(")","").replace("'","").replace("\n","").replace("False", "0").replace("True", "1").replace('"',"").replace("''","'0'").split(",")
        for item in input_list:
           output_list.append(float(item))
        # self.player_action = int(output_list[0])
        # output_list = output_list[1:self.state_size+1]
        output_list = np.reshape(output_list, (1, state_size))
        return output_list

# Godot Message Processor. See JSON Documentation to find out how we use this module
def process_message(message):
        output = []


        if message["Message Type"] == "Train"  :
                output = fighter1.train(   reshape(message["Message"] , fighter1.get_state_size()) )
        elif message["Message Type"] == "Battle"  :
                output = fighter1.predict(   reshape(message["Message"] , fighter1.get_state_size()) ),  fighter2.predict(   reshape(message["Message"] , fighter2.get_state_size()) )
        elif message["Message Type"] == "Battle"  :
                output = fighter1.predict(   reshape(message["Message"] , fighter1.get_state_size()) ),  fighter2.predict(   reshape(message["Message"] , fighter1.get_state_size()) )
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
        elif message["Message Type"] == "save"   :
                player_bot = save_bot(message["File Name"])
        elif message["Message Type"] == "Kill"   :
                output = 109
        else:
                print("Message not recognized")
        return output


# Loaded Bot files
player_bot = None
opponent_bot = None
def load():
        #if we load and don't start fresh
       fighter1.load()
       fighter2.load()

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
count = 1
while True:

        print("Server Code\n\n")
        #print("get request")
        gamestate = []
        next_gamestate = []
        # print("Server Code\n\n")
        # print("get request")

        request_completed = False
        try:
                request = get_client_request()[1].decode('unicode-escape').replace('(', '').replace(')', '').replace('\x00', '')
                #print(request)
                request = json.loads(request)
                request_completed = True

        except UnboundLocalError as Null_Reference:
                print('Client Request failed! Retrying...')
                input("Do you want to retry?")

        ### Process Request ###
        response = process_message(request)
        if response == 109:
                break
        #print(request)
        #response = fighter1.train(request)
        if(count % 1009 == 0):
            fighter1.graph_rewards()
        count+=1
        send_response(response) # send the action or actions or load successful message based on packet type
        print("response: ", response)

# Close pipes
print("Shutting Down...")
win32pipe.DisconnectNamedPipe(request_handle)
win32file.CloseHandle(request_handle)
win32pipe.DisconnectNamedPipe(response_handle)
win32file.CloseHandle(response_handle)
