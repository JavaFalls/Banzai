import sys
import tensorflow as tf
import keras
def build_model():
   model = keras.Sequential([keras.layers.Dense(1, activation=tf.nn.relu, input_shape=([1,1],[1,1],1,1,)),
   keras.layers.Dense(6, activation=tf.nn.relu),
   keras.layers.Dense(6, activation=tf.nn.relu),
   keras.layers.Dense(1)
   ])

def main():
   
    print(sys.argv)
    bot = build_model()
    return()

main()
