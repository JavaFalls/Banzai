#include "NNClient.h"
#include <Windows.h>
#include <iostream>

using namespace std;
//***********************************************************************************************
//               Try to connect to the client request pipe. Wait if it is in use                *
//***********************************************************************************************
int NNClient::connect_request() {
   DWORD dwMode = PIPE_READMODE_MESSAGE;
   while (1)
   {
      // Connect to the pipe
      request_handle = CreateFile(
         TEXT("\\\\.\\pipe\\RequestFromClient"), GENERIC_READ | GENERIC_WRITE,
         0, NULL, OPEN_EXISTING, 0, NULL
         );

      // If Pipe is successful, break.
      if ((int) request_handle == (int) INVALID_HANDLE_VALUE)
      {
         cout << "\nNo pipe created";
         if (GetLastError() != ERROR_PIPE_BUSY)
         {
            wprintf((LPCWSTR)"\nConnect_request(): %lu", GetLastError());
            return 0;
         }

         if(!WaitNamedPipe(TEXT("\\\\.\\pipe\\RequestFromClient"), 3000000))
         {
            cout <<"\nCould not open Pipe: 5 Second wait timed out\n";
            return 0;
         }
         cout << "\nNo pipe created --------- SERIOUSLY";
      }
      else
         break;
   }

   // Change connected pipe mode
   if(!(SetNamedPipeHandleState(
      request_handle, &dwMode, NULL, NULL)))
   {
      cout <<"\nSet Named Pipe Handle State Failed";
   }
   return 1;
}

//***********************************************************************************************
//               Try to connect to the client response pipe. Wait if it is in use               *
//**********************************************************************************************
int NNClient::connect_response()
{
   DWORD dwMode = PIPE_READMODE_MESSAGE;
   while (1)
   {
      // Connect to the pipe
      response_handle = CreateFile(
         TEXT("\\\\.\\pipe\\ResponseToClient"), GENERIC_READ | GENERIC_WRITE,
         0, NULL, OPEN_EXISTING, 0, NULL
         );

      // If Pipe is successful, break.
      if ((int) response_handle == (int) INVALID_HANDLE_VALUE)
      {
         if (GetLastError() != ERROR_PIPE_BUSY)
         {
            wprintf((LPCWSTR)"\nConnect_response(): %lu", GetLastError());
            return 0;
         }

         if(!WaitNamedPipe(TEXT("\\\\.\\pipe\\ResponseToClient"), 3000000))
         {
            cout <<"\nCould not open Pipe: 5 Second wait timed out\n";
            return 0;
         }
      }
      else
         break;
   }
   // Change connected pipe mode
   if(!(SetNamedPipeHandleState(
      response_handle, &dwMode, NULL, NULL)))
   {
      cout <<"\nSet Named Pipe Handle State Failed";
   }
   return 1;
}

//***********************************************************************************************
//                                 Send a request to the server                                 *
//***********************************************************************************************
int NNClient::send_request(String message_request)
{
   //char* message_cstr = new char[strlen(message_request.c_str()) + 1];
   DWORD message_length = (message_request.length() + 1) * sizeof(CharType);
   DWORD bytes_written;
   
   //strncpy(message_cstr, (char*) message_request.c_str(), message_request.length() + 1);
   int successful = WriteFile(request_handle, message_request.c_str(), message_length, &bytes_written, NULL);
   //delete [] message_cstr;
   return successful;
}

//***********************************************************************************************
//                                Get a response from the server                                *
//***********************************************************************************************
String NNClient::get_response()
{
   char chBuf[64*1024];
   bool successful;
   DWORD bytes_read;

   do {
      successful = ReadFile(response_handle, chBuf, 64*1024, &bytes_read, NULL);
   } while(!successful);
   String server_response = chBuf;

   return server_response;
}

//***********************************************************************************************
//                                  Close Request pipe handle                                   *
//***********************************************************************************************
int NNClient::close_request_handle()
{
   return CloseHandle(request_handle);
}

//***********************************************************************************************
//                                  Close Response pipe handle                                  *
//***********************************************************************************************
int NNClient::close_response_handle()
{
   return CloseHandle(response_handle);
}

//***********************************************************************************************
//
//***********************************************************************************************
NNClient::NNClient()
{
   HANDLE server_ready = CreateNamedPipe(TEXT("\\\\.\\pipe\\ServerReady"), 
                                         PIPE_ACCESS_DUPLEX,       // read/write access 
                                         PIPE_TYPE_MESSAGE | PIPE_READMODE_MESSAGE | PIPE_WAIT, 
                                         1, 64*1024, 64*1024, 0, NULL);
   
   ConnectNamedPipe(server_ready, NULL);
   DisconnectNamedPipe(server_ready);
   CloseHandle(server_ready);
   if(!connect_request())
      cout <<"\nConnecting Request Pipe Failed";
   if(!connect_response())
      cout <<"\nConnecting Response Pipe Failed";
}

//***********************************************************************************************
//
//***********************************************************************************************
NNClient::~NNClient()
{
   send_request("{\"Message Type\": \"Exit\"}");
	close_request_handle();
	close_response_handle();
}

//***********************************************************************************************
// BIND METHODS & PARAMETERS                                                                    *
//***********************************************************************************************
void NNClient::_bind_methods()
{
   ClassDB::bind_method(D_METHOD("connect_request"), &NNClient::connect_request);
   ClassDB::bind_method(D_METHOD("connect_response"), &NNClient::connect_response);
   ClassDB::bind_method(D_METHOD("send_request", "message_request"), &NNClient::send_request);
   ClassDB::bind_method(D_METHOD("get_response"), &NNClient::get_response);
   ClassDB::bind_method(D_METHOD("close_request_handle"), &NNClient::close_request_handle);
   ClassDB::bind_method(D_METHOD("close_response_handle"), &NNClient::close_response_handle); 
}