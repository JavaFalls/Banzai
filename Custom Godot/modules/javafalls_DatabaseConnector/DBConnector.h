/*
   TODO LIST:
   Register constants with Godot
   Register default argument values with Godot
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
#include "C:\Users\Adam\Documents\Word\Class PCC\Current Classes\CS451 Software Eng Project\Project Neitherlord\Banzai\Custom Godot\core\ustring.h"
#include <string>

using namespace std;

class DBConnector : public Reference {
//class DBConnector {
private:
   GDCLASS(DBConnector, Reference);
   int connectionOpen;

   // It is important to note that the connection strings should NOT contain extra spaces. For example, use "DRIVER={value}" NOT "DRIVER = {value}"
   // Connection String to be used to connect to the MySQL Test DB environment (a MySQL DB) DEPRECATED
   const std::string MySQLTESTConnectionString = "DRIVER={MySQL ODBC 8.0 ANSI Driver};"
                                  + (std::string)"SERVER=localhost;"
                                  + (std::string)"DATABASE=javafalls;"
                                  + (std::string)"USER=godotServer;"
                                  + (std::string)"PASSWORD=helpMe!IveRunOutOfTime32;" // In a real production this should probably be stored in an encrypted file and then decrypted by the program
                                  + (std::string)"OPTION=3;"; // I'm not sure what the OPTION attribute is for

   // Connection String to be used to connect to the Test DB environment (a SQL Server DB)
   const std::string TESTConnectionString = "DRIVER={ODBC Driver 13 for SQL Server};"
                             + (std::string)"SERVER=ADAM-LAPTOP\\JFTESTSERVER;"//TCP:172.16.2.5,1433;"
                             + (std::string)"Trusted_Connection=Yes;"
                             + (std::string)"DATABASE=SEI_JavaFalls;"
                             + (std::string)"Language=us_english;"
                             + (std::string)"Encrypt=Yes;"
                             + (std::string)"TrustServerCertificate=Yes;";

   // Connection String to be used to connect to the Live DB environment (a SQL Server DB)
   const std::string LIVEConnectionString = "DRIVER={ODBC Driver 13 for SQL Server};"
                             + (std::string)"SERVER=cssqlserver;"//TCP:172.16.2.5,1433;"
                             + (std::string)"UID=sei_JavaFallsUser;"
                             + (std::string)"PWD=HnjMk,IkoRftOlpOlpTgy32;"
                             //+ (std::string)"Trusted_Connection=Yes;" // use windows authentication
                             + (std::string)"DATABASE=SEI_JavaFalls;"
                             + (std::string)"Language=us_english;"
                             + (std::string)"Encrypt=Yes;"
                             + (std::string)"TrustServerCertificate=Yes;";
   // ^ see documentation at https://docs.microsoft.com/en-us/sql/relation-database/native-client/applications/using-connection-string-keywords-with-sql-server-native-client?view=sql-server-2017

   std::string conString;

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
   void GetColumnInformation(SQLHSTMT sqlStatementHandle, int columnNumber, std::string *p_columnName, SQLSMALLINT *p_DataType);

   /******************************************************************************
   / DB Interaction Helpers
   /*****************************************************************************/
   int StoreModel(std::string sqlCode); // Executes the given SQLCode and attempts to write the AI model file to the database. Assumes that the AI model is the first SQL parameter in the sqlCode
   int FetchModel(std::string sqlQuery); // Executes the given SQLCode and attempts to write the AI model to a file. Assumes that the AI Model is in the first row, first column of the result set returned by the sqlQuery.
   int FetchRow(SQLHSTMT sqlStatementHandle);
   int FetchIntAttribute(SQLHSTMT sqlStatementHandle, int columnNumber);
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
   int IsConnectionOpen(); // Returns 1 if DBConnector thinks the connection is open, else returns 0
   void BeginTransaction(); // Starts a transaction on the DB, required to run a COMMIT or ROLLBACK latter when  using a SQL Server DB.
   void Commit();
   void Rollback();

   /******************************************************************************
   / DB Interaction Commands
   /*****************************************************************************/
   // Insert statements return the ID value of the newly inserted row
   // Update statements return 1 if they complete successfully, if they fail they return 0
   // Fetch statements return a JSON string containing an array of arrays that represent the rows and columns returned by the query
   //  Sample json format: TODO
   //
   //
   //

   int InsertPlayer(String name);
   int UpdatePlayer(int player_ID, String name);
   String FetchPlayer(int player_ID);
   //int InsertMech(int player_ID, int model_ID, String name, int primary_weapon, int secondary_weapon, int utility);
   int InsertMech(int player_ID, int insertMechArgs[], String name);
   //int UpdateMech(int mech_ID, int player_ID, int model_ID, int ranking, String name, int primary_weapon, int secondary_weapon, int utility, int updateAIModel = TRUE);
   int UpdateMech(int mech_ID, int updateMechArgs[], String name, int updateAIModel = TRUE);
   String FetchMech(int mech_ID, int fetchModelFile = TRUE);

   int InsertAIModel(int player_ID); // Returns the model ID (a positive integer) of the newly stored model. Returns 0 if the model could not be inserted.
   int UpdateAIModelUsingModelID(int model_ID);
   int UpdateAIModelUsingMechID(int mech_ID);
   // Exception to the normal behavior of a fetch command, instead of returning a JSON string, these return whether or not they completed succesfully.
   // The AI_Model itself is placed in a file in the NeuralNetwork folder
   int FetchAIModelUsingModelID(int model_ID);
   int FetchAIModelUsingMechID(int mech_ID);

   /******************************************************************************
   / SQL Command management
   /*****************************************************************************/
   // Create a statement handle to execute a command on the database.
   // Note that the connection must be open before running CreateCommand
   // Params:
   //  - sqlCommand = A SQL string to run on the DB (can be any valid SQL code)
   SQLHSTMT CreateCommand(std::string sqlCommand);

   // Free the memory taken by a specific SQL command.
   // If you call CreateCommand do NOT forget to latter call DestroyCommand on the SQLHSTMT provided by CreateCommand
   void DestroyCommand(SQLHSTMT sqlStatementHandle);

   // Execute a statement on the database (don't forget to set up the statement handle first through CreateCommand)
   void Execute(SQLHSTMT sqlStatementHandle);

   // Get results back from the database, returns a JSON string
   String GetResults(SQLHSTMT sqlStatementHandle);

   /******************************************************************************
   / Constructors/Destructors
   /*****************************************************************************/
   DBConnector();
   ~DBConnector();

   /******************************************************************************
   / Getters and setters
   /*****************************************************************************/
   SQLRETURN getLastReturnCode();

   /******************************************************************************
   / Debugging functions
   /*****************************************************************************/
   // Print diagnostic records to the console.
   // Params:
   //  - functionName = The name of the function that experienced an error. Example: "exampleFunction()"
   //  - handleType = The type of handle being used when the error happened. Example: SQL_HANDLE_ENV
   //  - handle = The handle itself that was being used when the error happened.
   void PrintErrorDiagnostics(std::string functionName, SQLSMALLINT handleType, SQLHANDLE handle);
};

#endif
