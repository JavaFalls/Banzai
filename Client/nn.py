import sys
import tensorflow as tf
from tensorflow import keras
import numpy as np
import copy
def build_model():
   model = keras.Sequential([keras.layers.Dense(6, activation=tf.nn.relu, input_shape=(1,1,1,1,1,1,)),
   keras.layers.Dense(6, activation=tf.nn.relu),
   keras.layers.Dense(6, activation=tf.nn.relu),
   keras.layers.Dense(1)
   ])

def main():
    
    number_of_factors = 0
    #for line in sys.argv:
        #print(line)
        #number_of_factors=+1
    #bot = build_model()
    #print(number_of_factors)
    return()

main()
