""" To use the pywin32 headers, run this command in a terminal
        pip install pywin32                                     """
import win32pipe, win32file, pywintypes
import sys

# Collect command line arguments and place them into an iterable list
request_string = sys.argv
def get_request_handle():
    successful = False
    while not successful:
        try:
            win32pipe.WaitNamedPipe(r'\\.\pipe\RequestFromClient', win32pipe.NMPWAIT_WAIT_FOREVER)
            request_handler = win32file.CreateFile(
                r'\\.\pipe\RequestFromClient',
                win32file.GENERIC_READ | win32file.GENERIC_WRITE,
                0,
                None,
                win32file.OPEN_EXISTING,
                0,
                None
            )

            if win32pipe.SetNamedPipeHandleState(request_handler, win32pipe.PIPE_READMODE_MESSAGE, None, None) == 0:
                print("pipe mode change failed")
                exit(4)
            
            return request_handler

        except pywintypes.error as e:
                if e.args[0] == 2:
                        print("Pipe not created.")
                        input('Execution paused in send_request()')
                elif e.args[0] == 109:
                        print("Closed Pipe")
                        successful = True

def get_response_handle():
    successful = False
    while not successful:
        try:
            win32pipe.WaitNamedPipe(r'\\.\pipe\ResponseToClient', win32pipe.NMPWAIT_WAIT_FOREVER)
            response_handler = win32file.CreateFile(
                r'\\.\pipe\ResponseToClient',
                win32file.GENERIC_READ | win32file.GENERIC_WRITE,
                0,
                None,
                win32file.OPEN_EXISTING,
                0,
                None
            )

            if win32pipe.SetNamedPipeHandleState(response_handler, win32pipe.PIPE_READMODE_MESSAGE, None, None) == 0:
                print("pipe mode change failed")
                exit(4)

            return response_handler

        except pywintypes.error as e:
                if e.args[0] == 2:
                        print("Pipe not created.")
                        input('Execution paused in get_response()')
                    #    exit()
                elif e.args[0] == 109:
                        print("Closed Pipe")
                        successful = True

def save_game_state(game_state):
   str_game_state = str(game_state)
   
   f = open('C:/Users/vaugh/Desktop/wonderwoman/Banzai/Client/NeuralNetwork/gamestates', 'a') #absolute path here
   f.write(str_game_state + "\n")
   f.close() 

# while True:

# save game state for later training
save_game_state(sys.argv)

# Connect to server
# print("Client Code\n\n")

# Send request to server
# print("sending request")
request_handle = get_request_handle()
win32file.WriteFile(request_handle, str.encode(f'{request_string}'))

# Get response from Server
# print("get response")
response_handle = get_response_handle()
response = win32file.ReadFile(response_handle, 64*1024)
response_list = []

x = str(response[1])
x = x.replace("(","").replace(")","").replace("[","").replace("]","").replace("b","").replace("'","")
print(x)


# Close handles and quit
win32file.CloseHandle(request_handle)
win32file.CloseHandle(response_handle)
