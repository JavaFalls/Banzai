// Required by Godot so that it knows how to identify the DBConnector class
#include "register_types.h"
#include "class_db.h"
#include "DBConnector.h"

void register_javafalls_DatabaseConnector_types() {
   ClassDB::register_class<DBConnector>();
}
void unregister_javafalls_DatabaseConnector_types() {
   //nothing to do here
}
