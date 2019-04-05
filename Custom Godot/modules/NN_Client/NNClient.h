/*
   This file is a product of:
        {        {  {     {  {
         }     }  }  }     }  }
        {     {  {  {  {  {  {
         }  }  }  }  }  }  }  }
        {  {  {  {  {  {  {  {                JJJJJJJJJJJJ              FFFFFFFFF  LL LL
     |   }  }  }  }  }  }  }  }  |                JJJ                   FFFFFFFF   LL LL
     |\_________________________/|                JJJ                   FFF        LL LL
     |\_________________________/|==\\            JJJ                   FFFFFF     LL LL
     |\_____ _ ______ _ ________/|==\\\           JJJ                   FFFFF      LL LL
     |\_____ _ ______ _ ________/|   ||     JJJJ  JJJ  AAAA V   V  AAAA FFF   AAAA LL LL SSSSS
     |\__________ ______________/|   ||      JJ   JJJ AAAAA VV VV AAAAA FFF  AAAAA LL LL SSS
     |\__________ ______________/|==///      JJJJJJJ  AA AA  V V  AA AA FFF  AA AA LL LL    SS
     |\___ ______________ ______/|==//        JJJJJ   AAAAA   V   AAAAA FFF  AAAAA LL LL SSSSS
     \\________ _ _ ___________//
      \_______________________//

*/

#ifndef NNCLIENT_H
#define NNCLIENT_H

#include "reference.h"
#include <Windows.h>
#include <ustring.h>
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
   int send_request(String message_request);
   String get_response();
   int close_request_handle();
   int close_response_handle();

   NNClient();
   ~NNClient();
};

#endif