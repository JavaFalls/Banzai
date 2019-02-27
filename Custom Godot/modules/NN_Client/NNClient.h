#ifndef NNCLIENT_H
#define NNCLIENT_H

#include "reference.h"
#include <Windows.h>
#include <string>

class NNClient : public Reference {
   GDCLASS(NNClient, Reference);

   HANDLE request_handle;
   HANDLE response_handle;

protected:
   static void _bind_methods();

public:
   int connect_request();
   int connect_response();
   int send_request(char* message_request);
   char* get_response();
   int close_request_handle();
   int close_response_handle();

   NNClient();
   ~NNClient();
};

#endif