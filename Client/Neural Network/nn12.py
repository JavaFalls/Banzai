import sys
import tensorflow as tf
from tensorflow import keras
from tensorflow.keras.models import load_model

def save_game_state(game_state):
   str_game_state = str(game_state)
   
   f = open('gamestates.txt', 'a')
   f.write(str_game_state + "\n")
   #print("game_state")
   #print(str_game_state)
   f.close()   
   


def save_bot(model):
   model.save('my_model1.h5')

def load_bot():
   model = load_model('my_model1.h5')
   return model

def build_model():
   model = keras.Sequential([keras.layers.Dense( 6, activation=tf.nn.relu, input_shape=(1,)),
   keras.layers.Dense(9, activation=tf.nn.relu),
   keras.layers.Dense(9, activation=tf.nn.relu),
   keras.layers.Dense(1)])

   
   model.compile(loss='mse',
                 optimizer="Adam",
                 metrics=['mae'])
      
   return model


def train(model):
    f = open('gamestates', 'r+')
    line_number = 1
    test  = []
    label = []
    
    for line in f:
        mylist = line.replace(" ","").replace("[","").replace("]","").replace("(","").replace(")","").replace("'","").replace("\n","").split(",")
        mylist.pop(0)
        if line_number%2 == 0:
            label.append(mylist)
        else:
            test.append(mylist)
        line_number += 1
    f.close()

    for x in range(0, len(test)):
       for y in range(0, len(test[x])):
          test[x][y] = int(test[x][y])
          label[x][y] = int(label[x][y])
    for z in range(0,len(test) - 1):
       model.fit(x=test[z], y=label[z],  epochs=3, verbose=1, validation_split=0.3)
    print(model.predict(test[4]))


def main():
    
    save_game_state(sys.argv)
    #print(sys.argv)
    #bot = load_bot()
    #bot = build_model()
    #train(bot)
    #save_bot(bot)
    #save_game_state(sys.argv)
    #print(number_of_factors)
    return()

main()
