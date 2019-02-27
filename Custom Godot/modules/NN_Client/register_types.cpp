// Required by Godot so that it knows how to identify the DBConnector class
#include "register_types.h"
#include "class_db.h"
#include "NNClient.h"

void register_NN_Client_types() {
   ClassDB::register_class<NNClient>();
}
void unregister_NN_Client_types() {
   //nothing to do here
}
