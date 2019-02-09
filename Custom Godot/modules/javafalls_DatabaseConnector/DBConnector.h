// Programmers of JavaFalls, if you are looking for the documentation on
// the functions you use to interact with the database, please search for
// 'DB Interaction functions intended for use by Godot' (without the quotes) in this
// header file. For examples see below.

/*
   DBConnector.h
      c++ class used to connect to the JavaFalls database. Includes necessary connectors to work as a module for Godot.

   Example GDScript usage:
      In order to use the DB, a DBConnector object must be instantiated. This is done inside of the 'head' singleton and is instantiated as 'DB'.
      Thus to access it, you can simply use 'head.DB'. Thus code to get a player from the database for instance, would look something like this:
         var jsonString
         var player_ID = 1
         jsonString = head.DB.get_player(player_ID)
         # Manipulate jsonString to get desired data about the player.
   Example c++ usage:
      //--- Example using functions already included in the DBConnector ---
      int bot_ID = 1;
      String bot; // Godot String to store the returned row in
      DBConnector DB; // Instantiate DBConnector
      bot = DB.get_bot(bot_ID);
      DB.close_connection(); // Optional: This will go ahead and close the connection to the database. This also automatically happens when the DBConnector object is destructed (though closing it early will not interfere with the destruction process).
      // Further manipulation of the bot String to get desired information about the bot.
      //--- End example ---

   Other notes:
*/

/*
   TODO LIST:
   UNTESTED Create a table of names on the DB
   Create a thing to help users set up a DEV server
*/

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

#ifndef JAVAFALLSDBCONNECTOR_H
#define JAVAFALLSDBCONNECTOR_H

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
                               //+ (std::string)"Trusted_Connection=Yes;" // This line is needed if using windows authentication
                               + (std::string)"DATABASE=SEI_JavaFalls;"
                               + (std::string)"Language=us_english;"
                               + (std::string)"Encrypt=Yes;"
                               + (std::string)"TrustServerCertificate=Yes;";
   // ^ see documentation at https://docs.microsoft.com/en-us/sql/relation-database/native-client/applications/using-connection-string-keywords-with-sql-server-native-client?view=sql-server-2017

   std::string con_string; // The connection string that will actually be used to connect to the DB

   SQLHENV env_handle;
   SQLHDBC con_handle;

   SQLRETURN last_return; // Used to store the return value of the last ODBC call that was made

   short debug_sql; // If set to true, SQL code will get printed to the console prior to being executed

   const int COLUMN_DATA_BUFFER = 1048576; // (1 MB). Amount of space to allocate to store data for each column in a result set

   SQLLEN null_terminated_string = SQL_NTS; // Provides a single place to point to to tell the ODBC driver that input is a null terminated string.
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
   int store_model(SQLHSTMT sql_statement, int param_model); // Executes the given sql_statment and attempts to write the AI model file to the database. See further documentation at the declaration in DBConnector.cpp
   int get_model_by_sql(SQLHSTMT sql_statement); // Executes the given sql_statement and attempts to write the AI model to a file. Assumes that the AI Model is in the first row, first column of the result set returned by the sqlQuery. Destroys the sql_statement when it it finished
   int get_row(SQLHSTMT sql_statement_handle); // Gets the next row from a result set so it can be read. Assumes that the sql query has already been run.
   int get_int_attribute(SQLHSTMT sql_statement_handle, int column_number); // Returns the value of the specified column on the corrent row. Assumes that the sql query has already been run and a row fetched.
protected:
   // Required by Godot, used to bind c++ methods into things that can be seen by GDScript
   static void _bind_methods();

public:

   /******************************************************************************
   / Debug Control
   /*****************************************************************************/
   void set_debug_sql(Variant bool_print_sql); // Tells the DBConnector if it should print SQL commands prior to execution

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
   /*****************************************************************************/
   // new_ functions return the PK value of the newly inserted row
   // Update functions return 1 if they complete and commit successfully, 0 if the fail and rollback
   // get_ functions return a JSON string containing an array of arrays that represent the rows and columns returned by the query
   //  Sample json format:
   // {
   //    "data": [
   //       { "player_ID_FK": 2009, "model_ID_FK" : 2017, "ranking" : 0, "name" : "mech9000", "primary_weapon" : 1, "secondary_weapon" : 2, "utility" : 3}
   //    ]
   // }
   // Exceptions to the get_ rule are functions that only return one column, these functions typically return just the requested value instead of a JSON string.
   //

   //// Basic player management
   int new_player(String name);
   int update_player(int player_ID, String name);
   String get_player(int player_ID);

   //// Basic bot management
   int new_bot(int player_ID, Array new_bot_args, String name); // See NEW_BOT_ARGS_ constants to know better what to pass for the array
   int update_bot(int bot_ID, Array update_bot_args, String name, int update_model = TRUE); // See UPDATE_BOT_ARGS_ constants to know better what to pass for the array
   String get_bot(int bot_ID, int get_model = TRUE);

   //// Basic Model management
   int new_model(int player_ID); // Returns the model_ID (a positive integer) of the newly stored model. Returns 0 if the model could not be inserted.
   int update_model(int model_ID);
   int update_model_by_bot_id(int bot_id);
   // get_model and get_model_by_bot_id are exceptions to the normal behavior of a get_ function, instead of returning a JSON string, these return whether or not they completed succesfully.
   // The AI_Model itself is placed in a file in the NeuralNetwork folder
   int get_model(int model_ID);
   int get_model_by_bot_id(int bot_id);

   //// Score related functions
   // Returns a list of ids for the bots found in a certain score range (excludes bot id sent to the function)
   String get_bot_range(int bot_id, int min_score, int max_score);
   // Returns score of the bot with the highest score
   int get_max_score();
   // Returns score of the bot with the lowest score
   int get_min_score();
   // Returns scoreboard information for the current top 10 bots
   String get_scoreboard_top_ten();
   // Returns the position on the scoreboard of a specified bot
   int get_scoreboard_position(int bot_id);
   // Returns all of the robots in the specified range on the scoreboard
   String get_scoreboard_range(int min_position, int max_position);

   //// Other
   // Get name parts for username login screen
   String get_name_parts(int section);

   /******************************************************************************
   / SQL Command management
   /*****************************************************************************/
   // Create a statement handle to execute a command on the database.
   // Note that the connection must be open before running CreateCommand.
   // You MUST call destroy_command() when you are done with the SQLHSTMT created by create_command in order to free the memory.
   // Params:
   //  - sqlCommand = A SQL string to run on the DB (can be any valid SQL code)
   SQLHSTMT create_command(std::string sql_command);

   // Free the memory taken by a specific SQL command.
   // If you call create_command() do NOT forget to latter call destroy_command() on the SQLHSTMT provided by create_command()
   void destroy_command(SQLHSTMT sql_statement_handle);

   void bind_parameter(SQLHSTMT sql_statement_handle, int param_number, std::string *param_value, SQLSMALLINT param_input_output_type = SQL_PARAM_INPUT);
   void bind_parameter(SQLHSTMT sql_statement_handle, int param_number, int *param_value, SQLSMALLINT param_input_output_type = SQL_PARAM_INPUT);

   // Execute a statement on the database (don't forget to set up the statement handle first through create_command())
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
