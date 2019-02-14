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

def save_game_state(game_state):
   str_game_state = str(game_state)
   
   # f = open('C:/Users/vaugh/Desktop/wonderwoman/Banzai/Client/NeuralNetwork/gamestates', 'a') #absolute path here
   f = open('D:/Program Files/GitHub/Banzai/Client/NeuralNetwork/gamestates', 'a') #absolute path here

   f.write(str_game_state + "\n")
   f.close()   
   
def react(game_state, model):
   my_list = []
   flat_list = []
   next_list = []
   actual_response_list = []
   flat_actual_response_list = []
   str_game_state = str(game_state)
   my_list.append(str_game_state.replace(" ","").replace("[","").replace("]","").replace("(","").replace(")","").replace("'","").replace("\n","").replace("False", "0").replace("True", "1").split(","))
   for sublist in my_list:
      for item in sublist:
         flat_list.append(item)
   flat_list.pop(0)
   next_list.append(flat_list)
   response_list = model.predict(next_list)
   actual_response_list.append(response_list[4])
   actual_response_list.append(response_list[5])
   actual_response_list.append(response_list[6])
   actual_response_list.append(response_list[7])
   actual_response_list.append(response_list[8])
   actual_response_list.append(response_list[9])
   actual_response_list.append(response_list[10])
   actual_response_list.append(response_list[11])
   for sublist in actual_response_list:
      for item in sublist:
         flat_actual_response_list.append(item)
   print(flat_actual_response_list)
   
   

def save_bot(model):
   model.save('my_model.h5')

def load_bot():
   # model = load_model('C:/Users/vaugh/Desktop/wonderwoman/Banzai/Client/NeuralNetwork/my_model.h5')
   model = load_model('D:/Program Files/GitHub/Banzai/Client/NeuralNetwork/my_model1.h5')
   return model

def build_model():
   model = keras.Sequential([keras.layers.Dense( 1, activation=tf.nn.relu, input_shape=(1,)),
   keras.layers.Dense(9, activation=tf.nn.relu),
   keras.layers.Dense(9, activation=tf.nn.relu),
   keras.layers.Dense(1)])


   model.compile(loss='mse',
                 optimizer='Adam',
                 metrics=['mae'])
      
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
    print(test)

    for x in range(0, len(test) - 1):
       for y in range(0, len(test[x])):
          test[x][y] = float(test[x][y])
          label[x][y] = float(label[x][y])
    for z in range(0,len(test) - 1):
       model.fit(x=test[z], y=label[z],  epochs=3 , verbose=1, validation_split=0.3)
       
    


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
