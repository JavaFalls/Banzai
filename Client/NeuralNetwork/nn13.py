# The godot well send to the nn an array via the client where the first element
# is the description of the job be done and the following elements are the
# parameters.
# The first element key words are as follows
# Save:    Saves a nn model to a file
# Load:    Loads a nn model from a file
# React: The game state will be sent/predicted on saved and a prediction is returned
# Train:   Train will train the nn on all currently saved game states
# Create:  Creates a new bot from the standard template with randomized weights

import sys
import tensorflow as tf
from tensorflow import keras
from tensorflow.keras.models import load_model
from tensorflow.keras.models import Sequential
from tensorflow.keras.layers import Dense
from tensorflow.keras.optimizers import Adam
import random
import numpy as np
from collections import deque

def save_bot(model):
   model.save('my_model.h5')

def load_bot():
   # model = load_model('C:/Users/vaugh/Desktop/wonderwoman/Banzai/Client/NeuralNetwork/my_model.h5')
   model = load_model('D:/Program Files/GitHub/Banzai/Client/NeuralNetwork/my_model.h5')
   return model

def build_model():
   model = keras.Sequential([keras.layers.Dense( 33, activation=tf.nn.relu, input_shape=(1,)),
   keras.layers.Dense(1)])

   model.compile(Adam(lr=.01), loss='mse',
                 metrics=['accuracy'])
   print(model.summary())
   return model


def train(model):
    # f = open('C:/Users/vaugh/Desktop/wonderwoman/Banzai/Client/NeuralNetwork/gamestates', 'r+')
    f = open('D:/Program Files/GitHub/Banzai/Client/NeuralNetwork/gamestates', 'r+')
    line_number = 1
    test  = []
    label = []
    
    for line in f:
        mylist = line.replace(" ","").replace("''","'0'").replace("[]", "0,0").replace("[","").replace("]","").replace("(","")\
   .replace(")","").replace("'","").replace("\n","").replace("False", "0").replace("True", "1").replace('"',"").replace("''","'0'").split(",") 
        mylist.pop(0)
        if line_number%2 == 0:
            label.append(mylist)
        else:
            test.append(mylist)
        line_number += 1
    f.close()
   #  print(test)

    for x in range(0, len(test) - 1):
       for y in range(0, len(test[x])):
          test[x][y] = float(test[x][y])
          label[x][y] = float(label[x][y])
    for z in range(0,len(test) - 1):
       model.fit(x=test[z], y=label[z],  epochs=10 , verbose=2, validation_split=0.7, shuffle = False)
    print("fitting done")
       
    


def main():

    # Recieve the request and figure out what godot is asking for.
    
    #bot = load_bot()
    bot = build_model()
    train(bot)
    save_bot(bot)
    #save_game_state(sys.argv)
    #react(sys.argv, bot)
    return()

main()

################################ new stuff #############################################

state_size  = 20
action_size = 11
batch_size  = 32
episodes    = 10   # the more episodes(matches) we play, the more data to train on. we dont actually use this that way, or at all

class DQN_agent:

    def __init__(self, state_size, action_size):
        self.state_size = state_size 
        self.action_size = action_size

        self.memory = deque(maxlen=2000)
        self.gamma         = 0.95 # discount future reward
        self.epsilon       = 1.0 # exploration rate; initial rate; skew 100% towards exploration
        self.epsilon_decay = 0.995 # rate at which epsilon decays; get multiplied to epsilon
        self.epsilon_min   = 0.01 # floor that epsilon will rest at after heavy training

        self.learning_rate = 0.001

        self.model = self._build_model()
    
    def _build_model(self): # defines the NN
        model = Sequential()
        model.add(Dense(33, input_dim = self.state_size, activation='relu'))
        model.add(Dense(33, activation='relu'))
        model.add(Dense(self.action_size, activation='linear'))

        model.compile(loss='binary_crossentropy', optimizer=Adam(lr = self.learning_rate))

        return model

    def remember(self, state, action, reward, next_state, done):
        self.memory.append((state, action, reward, next_state, done))

    def act(self, state):
        if np.random.rand() <= self.epsilon: # if we randomly select a number less than our epilson we will choose 1? random action
            return random.randrange(self.action_size)
        act_values = self.model.predict(state)
        return np.argmax(act_values(0)) # chooses the best choice; we probably want to choose all the best choices

    def replay(self, batch_size):
        minibatch = random.sample(self.memory, batch_size)

        for state, action, reward, next_state, done in minibatch:
            target = reward
            if not done:
                target = (reward + self.gamma * np.amax(self.model.predict(next_state)[0]))
            target_f = self.model.predict(state)
            target_f[0] [action] = target

            self.model.fit(state, target_f, epoch=1, verbosity=0)
        
        if self.epsilon > self.epsilon_min:
            self.epsilon *= self.epsilon_decay

    def load(self, name):
        self.model.load_weights(name)

    def save(self, name):
        self.model.save_weights(name)

agent = DQN_agent(state_size, action_size)

### his architeture
done = False # is the specific, current match done?
for e in range(n_episodes): # play a certain number of matches, we don't use

    state = env.reset() # start the match and get the first state
    state= np.reshape(state, {1, state_size}) # reformat the state 

    for time in range(5000): # so that the game doesn't go on forever, we don't use

        env.render() # renders the game, we dont use

        action = agent.act(state) # get which action to do based on the given state

        next_state, reward, done, _ = env.step(action) #send the action to the game,get back the next state, reward, and whether the match finished

        reward = reward if not done else -10 # do some calculation for the reward, we may not have to 

        next_state = np.reshape(next_state, {1, state_size}) # reformat the state

        agent.remember(state,action,reward,next_state,done) # store a collection of data that can be pulled as a unit for learning

        state = next_state # the state that we got to from the action becomes the state we must take action on

        if done: # after the game is done print how the game went, we dont need
            print("episode {}/{} socre {}, e: {:.2}".format(e, n_episodes,, time, agent.epsilon) # print post match stats
            break

    if len(agent.memory) > batch_size: # trains the model, automatically trains once a certain threshold of trainable memories has been reached
        agent.replay(batch_size) # sends the number of memories we would like to use for training

    if e % 50 == 0: # saves the model every 50 games
        agent.save(output_dir + "weights_" + '{:04d}'.format(e) + "hdf5") # gives the model an identifiable name


### end his 

