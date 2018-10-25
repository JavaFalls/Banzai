import sys
import tensorflow as tf
from tensorflow import keras
from tensorflow.keras.models import load_model

def save_game_state(game_state):
   str_game_state = str(game_state)
   f = open('gamestates', 'a')
   f.write(str_game_state + "\n")


def save_bot(model):
   model.save('my_model1.h5')

def load_bot():
   model = load_model('my_model1.h5')
   return model

def build_model():
   model = keras.Sequential([keras.layers.Dense(6, activation=tf.nn.relu, input_shape=(1,1,1,1,1,1,)),
   keras.layers.Dense(6, activation=tf.nn.relu),
   keras.layers.Dense(6, activation=tf.nn.relu),
   keras.layers.Dense(1)])

   
   model.compile(loss='mse',
                 optimizer="Adam",
                 metrics=['mae'])
      
   return model

def main():
    
    #number_of_factors = 0
    #for line in sys.argv:
     #   print(line)
      #  number_of_factors=+1
    bot = load_bot()
    bot = build_model()
    save_bot(bot)
    save_game_state(sys.argv)
    #print(number_of_factors)
    return()

main()
