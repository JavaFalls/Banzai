import tensorflow as tf
from tensorflow import keras
import numpy as np
import copy

class DataEntry(object):
    def __init__(self):
        self.user_choice = 0
        self.ai_choice   = 0

def test():
    print("Enter your choice: ", end='')
    choice = int(input())
    return choice

def parse_single_result(result):
    x = result.item(0)
    return int(x)

def response(choice):
    response = 0
    response = (choice % 3) + 1
#    if choice == 1:
#        response = 2
#    elif choice == 2:
#        response = 3
#    elif choice == 3:
#        response = 1
#    else:
#        response = 0
    return response


def parse_result(result):
    answer = DataEntry()
    data = []
    entry = DataEntry()
    num = 1

    for x in np.nditer(result):
        entry = DataEntry()
        entry.user_choice = num
        entry.ai_choice = x
        data.append(entry)
        if (num > 1) and (data[num-2].ai_choice < data[num-1].ai_choice):
            print(str(data[num-2].ai_choice) + " is less than " + str(data[num-1].ai_choice))
            answer = entry
        elif num == 1:
            answer = entry
        num +=1
        print("Choice: " + str(entry.user_choice) + ", Probable answer: " + str(entry.ai_choice))
        print("Most probable: " + str(answer.user_choice))
    return answer.user_choice

def process_choice(model, curr_round, entries):
    choice = [[entry.user_choice]]
    decision = model.predict(choice, batch_size=1, verbose=1)
    decision = parse_single_result(decision)
    start_from = curr_round-6
    if (start_from < 0):
       start_from = 0
    if curr_round > 0:
        for x in range(start_from,curr_round):
           model.fit([[entries[x-1].user_choice]], [[entries[x].user_choice]], epochs=100, verbose=0)
    return decision

def build_model():
   model = keras.Sequential([keras.layers.Dense(1, activation=tf.nn.relu, input_shape=(1,)),
   keras.layers.Dense(6, activation=tf.nn.relu),
   keras.layers.Dense(6, activation=tf.nn.relu),
   keras.layers.Dense(1)
   ])

   optimizer = tf.train.RMSPropOptimizer(0.01)
   model.compile(loss='mse',
                 optimizer=optimizer,
                 metrics=['mae'])
   return model

data_entries = [] # list containing each data entry
user_input = 0 # current number input by user
data_input = 0 # number of inputs from user
data_model = build_model()

print("****************************************************************")
print("*                     Rock, Paper, Scissors                    *")
print("*       1 = rock; 2 = paper; 3 = scissors; 4 = NEVER QUIT!!!   *")
print("****************************************************************")
wins = 0
ties = 0
losses = 0
entry = DataEntry()
entry.user_choice = test()
data_entries.append(entry)
entry.ai_choice = process_choice(data_model, data_input, data_entries)
entry.ai_choice = response(entry.ai_choice)
print("You chose " + str(entry.user_choice) + " vs. " + str(entry.ai_choice) + "\n")

while data_entries[data_input].user_choice != 4:
   entry = DataEntry()
   entry.user_choice = test()
   data_entries.append(entry)
   entry.ai_choice = process_choice(data_model, data_input, data_entries)
   entry.ai_choice = response(entry.ai_choice)
   print("You chose " + str(entry.user_choice) + " vs. " + str(entry.ai_choice) + "\n")
   if (entry.user_choice == 2 and entry.ai_choice == 1):
      print("you win")
      wins +=1
   elif (entry.user_choice == 3 and entry.ai_choice == 2):
      print("you win")
      wins +=1
   elif (entry.user_choice == 1 and entry.ai_choice == 3):
      print("you win")
      wins +=1
   elif (entry.user_choice == entry.ai_choice):
      print("you tie")
      ties +=1
   else:
      print("you you lose")
      losses += 1
   data_entries.append(entry)
   data_input += 1
   print("Ties: ", ties ,"Wins: ",wins, "Losses: ",losses)
