""" To use the pywin32 headers, run this command in a terminal
        pip install pywin32                                     """
import win32pipe, win32file, pywintypes
import sys, math
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

def get_client_request():
        # Create a named pipe to receive requests from the client
        try:
                # Block until client connects
                print("Waiting for client {request}")
                win32pipe.ConnectNamedPipe(request_handle, None)
                print("Client Connected :)")

                # Get request from Godot Client
                # Request is a tuple with the structure (ERROR_CODE, MESSAGE)
                request = win32file.ReadFile(request_handle, 64*1024)

                win32pipe.DisconnectNamedPipe(request_handle)
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
                # Block until client connects
                print("Waiting for client {response}")
                win32pipe.ConnectNamedPipe(response_handle, None)
                print("Client Connected :)")

                # Send response to Godot client
                win32file.WriteFile(response_handle, str.encode(f"{response}"))

                win32pipe.DisconnectNamedPipe(response_handle)
                # win32file.CloseHandle(response_handle)

        except pywintypes.error as e:
                if e.args[0] == 2:
                        print("Pipe not created.")

                elif e.args[0] == 109:
                        print("Closed Pipe")
                input('what do you want me to do?')



def react(game_state, model):
   #print(type(game_state))
   input_list = []
   output_list = []
   response_list = []
   for item in game_state:
      input_list.append(item)
   str_input_list = str(input_list)
   input_list = str_input_list.replace(" ","").replace("[","").replace("]","").replace("(","")\
   .replace(")","").replace("'","").replace("\n","").replace("False", "0").replace("-", "").replace("True", "1").replace('"',"").replace('','0').split(",")         
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


def save_bot(model):
   model.save('my_model1.h5')

def load_bot():
   model = load_model('C:/Users/vaugh/Desktop/wonderwoman/Banzai/Client/NeuralNetwork/my_model1.h5')
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
        mylist = line.replace(" ","").replace("[","").replace("]","").replace("(","").replace(")","").replace("'","").replace("\n","").replace("False", "0").replace("True", "1").split(",")
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
       print(test[z], "\n", label[z])
       print(test[z], "\n", label[z])
    print(model.predict(test[4]))

   
bot = load_bot()
response = []
while True:
        print("Server Code\n\n")
        print("get request")

        request_completed = False
        while not request_completed:
                try:
                        request = get_client_request()
                        response = react(request, bot)
                        #print(f'{request}')
                        request_completed = True
                except UnboundLocalError as Null_Reference:
                        print('Client Request failed! Retrying...')
                        input("Do you want to retry?")

        ### Process Request ###
        print("sending response")
        print(response)
        send_response(response)

# Close pipes
