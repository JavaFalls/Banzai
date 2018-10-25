/*
   This is to allow me (Adam Baldwin) to become fimilar with the c++ connector for MySql.
   It is not intended to be used in production, though some of it's code might get copied
   into actual production code.

   For information on how the C++ connector provided by the MySQL team works, please see: https://dev.mysql.com/doc/dev/connector-cpp/8.0/
*/

// TODO: Invesitgate ways to include the OpenSSL librarys with installation so that the c++ linker doesn't have to find them on the PC it runs on
// Note: Maybe just link it statically, so that the system it is installed on doesn't have to find stuff. See https://dev.mysql.com/doc/dev/connector-cpp/8.0/usage.html

// Remember to use "-I $MYSQL_CPPCONN_DIR/include", "-L $MYSQL_CPPCONN_DIR/lib64", and "-lmysqlcppconn8" when compiling!
// $MYSQL_CPPCONN_DIR must be defined in windows and point to a valid installation of the C++ connector for it to work.
#include <mysqlx/xapi.h> // MySQL C++ connector header file.
