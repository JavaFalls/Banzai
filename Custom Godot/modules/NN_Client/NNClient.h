#ifndef NNCLIENT_H
#define CLIENT_H

#include "reference.h"
#include <Windows.h>
#include <stdbool.h>
#include <string>

class NNClient : public Reference {
   GDCLASS(NNClient, Reference);

   HANDLE request_handle;
   HANDLE response_handle;

protected:
   static void _bind_methods();

public:
   bool connect_request();
   bool connect_response();
   bool send_request(char* request);
   char* get_response();
   bool close_request_handle();
   bool close_response_handle();

   NNClient();
   ~NNClient();
};

#endif