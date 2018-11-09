/*
   TODO LIST:
*/

#ifndef JAVAFALLSDBCONNECTOR_H
#define JAVAFALLSDBCONNECTOR_H

/*
   JavaFallsDBConnector.h
      c++ class used to connect to the JavaFalls database. Includes necessary connectors to work as a module for Godot

   Example GDScript usage:

   Example c++ usage:


   Other notes:
*/

#include "reference.h" // Needed to compile with Godot
#include "windows.h"
#include "sql.h"
#include "sqlext.h"
#include <string>

using namespace std;

class DBConnector : public Reference {
private:
   GDCLASS(DBConnector, Reference);
   int connectionOpen;

   // It is important to note that the connection strings should NOT contain extra spaces. For example, use "DRIVER={value}" NOT "DRIVER = {value}"
   // Connection String to be used to connect to the Test DB environment (a MySQL Server DB)
   const string TESTConnectionString = "DRIVER={MySQL ODBC 8.0 ANSI Driver};"
                             + (string)"SERVER=localhost;"
                             + (string)"DATABASE=javafalls;"
                             + (string)"USER=godotServer;"
                             + (string)"PASSWORD=helpMe!IveRunOutOfTime32;" // In a real production this should probably be stored in an encrypted file and then decrypted by the program
                             + (string)"OPTION=3;"; // I'm not sure what the OPTION attribute is for

   // Connection String to be used to connect to the Live DB environment (a SQL Server DB)
   const string LIVEConnectionString = "DRIVER={ODBC Driver 13 for SQL Server};"
                             + (string)"SERVER=cssqlserver;"//TCP:172.16.2.5,1433;"
                             + (string)"Trusted_Connection=Yes;"
                             + (string)"DATABASE=SEI_JavaFalls;"
                             + (string)"Language=us_english;"
                             + (string)"Encrypt=Yes;"
                             + (string)"TrustServerCertificate=Yes;";
   // ^ see documentation at https://docs.microsoft.com/en-us/sql/relation-database/native-client/applications/using-connection-string-keywords-with-sql-server-native-client?view=sql-server-2017

   string conString;

   SQLHENV envHandle;
   SQLHDBC conHandle;

   SQLRETURN lastReturn;

   const int COLUMN_DATA_BUFFER = 1048576; // (1 MB). Amount of space to allocate to store data for each column in a result set

   // Gets information about a column in a result set.
   // Params:
   //  - sqlStatementHandle = A valid SQLHSTMT that contains a SQL query
   //  - columnNumber = The column to get data about. Column numbers start at 1
   //  - p_ColumnName = Out parameter, returns the name of the column.
   //  - p_DataType   = Out parameter, returns the SQL_ data type of the column
   void GetColumnInformation(SQLHSTMT sqlStatementHandle, int columnNumber, string *p_columnName, SQLSMALLINT *p_DataType);

protected:
   // Required by Godot, used to bind c++ methods into things that can be seen by GDScript
   static void _bind_methods();

public:

   /******************************************************************************
   / Connection Management
   /*****************************************************************************/
   // Opens and closes the connection to the database
   int OpenConnection();  // Returns 1 if successful, 0 if not
   int CloseConnection(); // Returns 1 if successful, 0 if not
   void Commit();
   void Rollback();

   /******************************************************************************
   / SQL Command management
   /*****************************************************************************/
   // Create a statement handle to execute a command on the database.
   // Note that the connection must be open before running CreateCommand
   // Params:
   //  - sqlCommand = A SQL string to run on the DB (can be any valid SQL code)
   SQLHSTMT CreateCommand(string sqlCommand);
   // Free the memory taken by a specific SQL command.
   // If you call CreateCommand do NOT forget to latter call DestroyCommand on the SQLHSTMT provided by CreateCommand
   void DestroyCommand(SQLHSTMT sqlStatementHandle);

   //void BindParameter(SQLHSTMT sqlStatementHandle, int paramNumber, string paramValue);
   //void BindParameter(SQLHSTMT sqlStatementHandle, int paramNumber, string paramValue, int paramType);

   // Execute a statement on the database (don't forget to set up the statement handle first through CreateCommand)
   void Execute(SQLHSTMT sqlStatementHandle);
   // Get results back from the database, returns an linked list of DBRows, or something like that
   string GetResults(SQLHSTMT sqlStatementHandle);

   /******************************************************************************
   / Constructors/Destructors
   /*****************************************************************************/
   DBConnector();
   ~DBConnector();

   /******************************************************************************
   / Getters and setters
   /*****************************************************************************/
   SQLRETURN getLastReturnCode();

   // Print diagnostic records to the console.
   // Params:
   //  - functionName = The name of the function that experienced an error. Example: "exampleFunction()"
   //  - handleType = The type of handle being used when the error happened. Example: SQL_HANDLE_ENV
   //  - handle = The handle itself that was being used when the error happened.
   void PrintErrorDiagnostics(string functionName, SQLSMALLINT handleType, SQLHANDLE handle);
};

#endif
