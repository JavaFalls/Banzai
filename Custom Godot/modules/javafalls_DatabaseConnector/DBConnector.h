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

#include "reference.h"
#include "ustring.h"
#include "variant.h"
#include "array.h"
// Make sure that all includes from Godot files come before any other includes. Something in the compiler bombs out otherwise
#include "windows.h"
#include "sql.h"
#include "sqlext.h"
#include <string>

#define CONNECTION_OVERRIDE_FILENAME "DBConnectionOverride.ODBCconString"
#define MAX_CONNECTION_OVERRIDE_FILE_SIZE 300

class DBConnector : public Reference {
private:
   GDCLASS(DBConnector, Reference);
   int connection_open;

   // It is important to note that the connection strings should NOT contain extra spaces. For example, use "DRIVER={value}" NOT "DRIVER = {value}"
   // DEPRECATED Connection String to be used to connect to the MySQL Test DB environment (a MySQL DB)
   const std::string my_sql_test_connection_string = "DRIVER={MySQL ODBC 8.0 ANSI Driver};"
                                  + (std::string)"SERVER=localhost;"
                                  + (std::string)"DATABASE=javafalls;"
                                  + (std::string)"USER=godotServer;"
                                  + (std::string)"PASSWORD=helpMe!IveRunOutOfTime32;" // In a real production this should probably be stored in an encrypted file and then decrypted by the program
                                  + (std::string)"OPTION=3;"; // I'm not sure what the OPTION attribute is for

   // DEPRECATED Connection String to be used to connect to the Test DB environment (a SQL Server DB)
   const std::string test_connection_string = "DRIVER={ODBC Driver 13 for SQL Server};"
                             + (std::string)"SERVER=ADAM-LAPTOP\\JFTESTSERVER;"//TCP:172.16.2.5,1433;"
                             + (std::string)"Trusted_Connection=Yes;"
                             + (std::string)"DATABASE=SEI_JavaFalls;"
                             + (std::string)"Language=us_english;"
                             + (std::string)"Encrypt=Yes;"
                             + (std::string)"TrustServerCertificate=Yes;";

   // Connection String to be used to connect to the Live DB environment (a SQL Server DB)
   const std::string live_connection_string = "DRIVER={ODBC Driver 13 for SQL Server};"
                             + (std::string)"SERVER=cssqlserver;"//TCP:172.16.2.5,1433;"
                             + (std::string)"UID=sei_JavaFallsUser;"
                             + (std::string)"PWD=HnjMk,IkoRftOlpOlpTgy32;"
                             //+ (std::string)"Trusted_Connection=Yes;" // this line, when uncommented, tells the connection to use windows authentication (if this line is included, don't include UID or PWD)
                             + (std::string)"DATABASE=SEI_JavaFalls;"
                             + (std::string)"Language=us_english;"
                             + (std::string)"Encrypt=Yes;"
                             + (std::string)"TrustServerCertificate=Yes;";
   // ^ see documentation at https://docs.microsoft.com/en-us/sql/relation-database/native-client/applications/using-connection-string-keywords-with-sql-server-native-client?view=sql-server-2017

   std::string con_string;

   SQLHENV env_handle;
   SQLHDBC con_handle;

   SQLRETURN last_return;

   const int COLUMN_DATA_BUFFER = 1048576; // (1 MB). Amount of space to allocate to store data for each column in a result set

   // Gets information about a column in a result set.
   // Params:
   //  - sqlStatementHandle = A valid SQLHSTMT that contains a SQL query
   //  - columnNumber = The column to get data about. Column numbers start at 1
   //  - p_ColumnName = Out parameter, returns the name of the column.
   //  - p_DataType   = Out parameter, returns the SQL_ data type of the column
   void get_column_information(SQLHSTMT sql_statement_handle, int column_number, std::string *p_column_name, SQLSMALLINT *p_data_type);

   /******************************************************************************
   / DB Interaction Helpers
   /*****************************************************************************/
   int store_model(std::string sql_code); // Executes the given SQLCode and attempts to write the AI model file to the database. Assumes that the AI model is the first SQL parameter in the sqlCode
   int get_model_by_sql(std::string sql_query); // Executes the given SQLCode and attempts to write the AI model to a file. Assumes that the AI Model is in the first row, first column of the result set returned by the sqlQuery.
   int get_row(SQLHSTMT sql_statement_handle);
   int get_int_attribute(SQLHSTMT sql_statement_handle, int column_number);
protected:
   // Required by Godot, used to bind c++ methods into things that can be seen by GDScript
   static void _bind_methods();

public:

   /******************************************************************************
   / Connection Management
   /*****************************************************************************/
   // Opens and closes the connection to the database
   int open_connection();  // Returns 1 if successful, 0 if not
   int close_connection(); // Returns 1 if successful, 0 if not
   int is_connection_open(); // Returns 1 if DBConnector thinks the connection is open, else returns 0
   void commit();
   void rollback();

   /******************************************************************************
   / DB Interaction functions intended for use by Godot
   /*****************************************************************************/   // Insert statements return the ID value of the newly inserted row
   // new_ functions return 1 if they complete successfully, if they fail they return 0
   // Update functions return 1 if they complete and commit successfully, 0 if the fail and rollback
   // get_ functions return a JSON string containing an array of arrays that represent the rows and columns returned by the query
   //  Sample json format: TODO
   //
   //
   //

   // Basic player management
   int new_player(String name);
   int update_player(int player_ID, String name);
   String get_player(int player_ID);

   // Basic bot management
   int new_bot(int player_ID, Array new_bot_args, String name);
   int update_bot(int bot_ID, Array update_bot_args, String name, int update_model = TRUE);
   String get_bot(int bot_ID, int get_model = TRUE);

   // Basic Model management
   int new_model(int player_ID); // Returns the model_ID (a positive integer) of the newly stored model. Returns 0 if the model could not be inserted.
   int update_model(int model_ID);
   int update_model_by_bot_id(int bot_id);
   // Exception to the normal behavior of a get_ function, instead of returning a JSON string, these return whether or not they completed succesfully.
   // The AI_Model itself is placed in a file in the NeuralNetwork folder
   int get_model(int model_ID);
   int get_model_by_bot_id(int bot_id);

   // Returns a list of ids for the bots found in a certain score range (excludes bot id sent to the function)
   String get_bot_range(int bot_id, int min_score, int max_score);
   // Returns score of the bot with the highest score
   int get_max_score();
   // Returns score of the bot with the lowest score
   int get_min_score();

   // Get name parts for username login screen
   String get_name_parts(int section);

   /******************************************************************************
   / SQL Command management
   /*****************************************************************************/
   // Create a statement handle to execute a command on the database.
   // Note that the connection must be open before running CreateCommand
   // Params:
   //  - sqlCommand = A SQL string to run on the DB (can be any valid SQL code)
   SQLHSTMT create_command(std::string sql_command);

   // Free the memory taken by a specific SQL command.
   // If you call CreateCommand do NOT forget to latter call DestroyCommand on the SQLHSTMT provided by CreateCommand
   void destroy_command(SQLHSTMT sql_statement_handle);

   // Execute a statement on the database (don't forget to set up the statement handle first through CreateCommand)
   void execute(SQLHSTMT sql_statement_handle);

   // Get results back from the database, returns a JSON string
   String get_results(SQLHSTMT sql_statement_handle);

   /******************************************************************************
   / Constructors/Destructors
   /*****************************************************************************/
   DBConnector();
   ~DBConnector();

   /******************************************************************************
   / Getters and setters
   /*****************************************************************************/
   SQLRETURN get_last_return_code();

   /******************************************************************************
   / Debugging functions
   /*****************************************************************************/
   // Print diagnostic records to the console.
   // Params:
   //  - functionName = The name of the function that experienced an error. Example: "exampleFunction()"
   //  - handleType = The type of handle being used when the error happened. Example: SQL_HANDLE_ENV
   //  - handle = The handle itself that was being used when the error happened.
   void print_error_diagnostics(std::string function_name, SQLSMALLINT handle_type, SQLHANDLE handle);
};

#endif
