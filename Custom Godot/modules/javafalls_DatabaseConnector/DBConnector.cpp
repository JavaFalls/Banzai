// Please see corresponding header file ("DBConnector.h") for function documentation.

#include "ustring.h"
#include "variant.h"
#include "array.h"
// Make sure that all includes from Godot files come before any other includes. Something in the compiler bombs out otherwise
#include "DBConnector.h"
#include "windows.h"
#include "sql.h"
#include "sqlext.h"
#include <string>
#include <iostream>
#include <fstream>

// How long a string needs to be to hold an int that has been converted to a string, plus the null terminator
#define STRING_INT_SIZE 11
#define BLOB_MAX 2147483647
// Filepath to use when storing a model to the database:
#define FILEPATH_IN_MODEL "NeuralNetwork/my_model.h5"
// Filepath to use when loading a model from the database:
#define FILEPATH_OUT_MODEL "NeuralNetwork/my_model_new.h5"

// Constants to access arrays of arguments used when a function that needs to be usable by Godot exceeds 5 arguments
// Godot has a bug that prevents binding of functions with 6 or more agruments
#define NEW_BOT_ARGS_MODEL_ID 0
#define NEW_BOT_ARGS_PRIMARY_WEAPON 1
#define NEW_BOT_ARGS_SECONDARY_WEAPON 2
#define NEW_BOT_ARGS_UTILITY 3
#define ARRAY_SIZE_NEW_BOT_ARGS 4
#define UPDATE_BOT_ARGS_PLAYER_ID 0
#define UPDATE_BOT_ARGS_MODEL_ID 1
#define UPDATE_BOT_ARGS_RANKING 2
#define UPDATE_BOT_ARGS_PRIMARY_WEAPON 3
#define UPDATE_BOT_ARGS_SECONDARY_WEAPON 4
#define UPDATE_BOT_ARGS_UTILITY 5
#define ARRAY_SIZE_UPDATE_BOT_ARGS 6

/***********************************************************************************************************
/ Connection Management Functions
/***********************************************************************************************************/
int DBConnector::open_connection() {
   SQLSMALLINT idc; // We don't care about this value
                    // Open a connection, but only if the environment handle is valid
   if (!connection_open) {
      if (env_handle != SQL_NULL_HANDLE && con_handle != SQL_NULL_HANDLE) {
         if (SQL_SUCCEEDED(last_return = SQLDriverConnect(con_handle,
                                                          SQL_NULL_HANDLE, // We are not providing a window handle
                                                          (SQLCHAR *)con_string.c_str(),
                                                          SQL_NTS,
                                                          NULL,
                                                          0,
                                                          &idc,
                                                          SQL_DRIVER_NOPROMPT))) {
            connection_open = TRUE;
            return TRUE;
         }
         else {
            print_error_diagnostics("open_connection()", SQL_HANDLE_DBC, con_handle);
         }
      }
   }
   else {
      // Connection is already open
      return TRUE;
   }
   return FALSE; // Return false to indicate that something didn't happen right
}
int DBConnector::close_connection() {
   int tries = 0;
   // Close the connection, unless of course the connection is already closed
   if (con_handle != SQL_NULL_HANDLE) {
      while (!SQL_SUCCEEDED(last_return = SQLDisconnect(con_handle)) && tries < 1000) tries++; // If this loop terminates due to hitting the max number of tries we have some serious problems
      if (SQL_SUCCEEDED(last_return)) {
         connection_open = FALSE;
         return TRUE;
      }
      else {
         print_error_diagnostics("close_connection()", SQL_HANDLE_DBC, con_handle);
      }
   }
   return FALSE; // Return false to indicate that something didn't happen right
}
int DBConnector::is_connection_open() {
   return connection_open;
}
void DBConnector::commit() {
   if (!SQL_SUCCEEDED(last_return = SQLEndTran(SQL_HANDLE_DBC,
                                               con_handle,
                                               SQL_COMMIT))) {
      print_error_diagnostics("commit()", SQL_HANDLE_DBC, con_handle);
   }
   return;
}
void DBConnector::rollback() {
   if (!SQL_SUCCEEDED(last_return = SQLEndTran(SQL_HANDLE_DBC,
                                               con_handle,
                                               SQL_ROLLBACK))) {
      print_error_diagnostics("rollback()", SQL_HANDLE_DBC, con_handle);
   }
   return;
}

/***********************************************************************************************************
/ DB Interaction Commands
/***********************************************************************************************************/
// Basic Player Management
int DBConnector::new_player(String name) {
   int new_player_id = FALSE;
   std::string sql_get_new_player_ID = "SELECT max(player.player_ID_PK)\n"
                      + (std::string)"  FROM javafalls.player player";
   std::string sql_insert = "INSERT INTO javafalls.player\n"
             + (std::string)"            (name)\n"
             + (std::string)"     VALUES ('" + name.ascii().get_data() + "')";
   SQLHSTMT sql_statement_get_player_ID = create_command(sql_get_new_player_ID);
   SQLHSTMT sql_statement_insert = create_command(sql_insert);

   execute(sql_statement_insert);
   if (SQL_SUCCEEDED(last_return)) {
      execute(sql_statement_get_player_ID);
      if (get_row(sql_statement_get_player_ID)) {
         if (new_player_id = get_int_attribute(sql_statement_get_player_ID, 1)) {
            commit();
         }
         else {
            rollback();
         }
      }
      else {
         rollback();
      }
   }
   else {
      rollback();
   }
   return new_player_id;
}
int DBConnector::update_player(int player_ID, String name) {
   int succeeded = FALSE;
   char player_ID_string[STRING_INT_SIZE];
   sprintf(player_ID_string, "%d", player_ID);
   std::string sql_code = "UPDATE javafalls.player\n"
           + (std::string)"   SET player.name = '" + name.ascii().get_data() + "'\n"
           + (std::string)" WHERE player.player_ID_PK = " + player_ID_string;
   SQLHSTMT sql_statement = create_command(sql_code);
   execute(sql_statement);
   if (SQL_SUCCEEDED(last_return)) {
      commit();
      succeeded = TRUE;
   }
   else {
      rollback();
      succeeded = FALSE;
   }
   destroy_command(sql_statement);
   return succeeded;
}
String DBConnector::get_player(int player_ID) {
   String return_value;
   char  player_ID_string[STRING_INT_SIZE];
   sprintf(player_ID_string, "%d", player_ID);
   std::string sql_query = "SELECT player.name\n"
            + (std::string)"  FROM javafalls.player player\n"
            + (std::string)" WHERE player.player_ID_PK = " + player_ID_string;
   SQLHSTMT sql_statement = create_command(sql_query);
   execute(sql_statement);
   return_value = get_results(sql_statement);
   destroy_command(sql_statement);
   return return_value;
}

// Basic Bot Management
int DBConnector::new_bot(int player_ID, Array new_bot_args, String name) {
   SQLHSTMT sql_statement_new_bot;
   SQLHSTMT sql_statement_get_bot_ID;
   int new_bot_ID = FALSE;
   char player_ID_string[STRING_INT_SIZE];
   char model_ID_string[STRING_INT_SIZE];
   char primary_weapon_string[STRING_INT_SIZE];
   char secondary_weapon_string[STRING_INT_SIZE];
   char utility_string[STRING_INT_SIZE];
   sprintf(player_ID_string, "%d", player_ID);
   sprintf(model_ID_string, "%d", (int)new_bot_args[NEW_BOT_ARGS_MODEL_ID]);
   sprintf(primary_weapon_string, "%d", (int)new_bot_args[NEW_BOT_ARGS_PRIMARY_WEAPON]);
   sprintf(secondary_weapon_string, "%d", (int)new_bot_args[NEW_BOT_ARGS_SECONDARY_WEAPON]);
   sprintf(utility_string, "%d", (int)new_bot_args[NEW_BOT_ARGS_UTILITY]);
   std::string sql_get_new_bot_ID = "SELECT max(mech.mech_ID_PK)\n"
                  + (std::string)"  FROM javafalls.mech mech";
   std::string sql_code;
   if ((int)new_bot_args[NEW_BOT_ARGS_MODEL_ID] <= 0) {
      // Model ID not provided, attempt to insert the model into the database ourselves
      new_bot_args[NEW_BOT_ARGS_MODEL_ID] = (Variant)new_model(player_ID);
      if (new_bot_args[NEW_BOT_ARGS_MODEL_ID]) {
         sprintf(model_ID_string, "%d", (int)new_bot_args[NEW_BOT_ARGS_MODEL_ID]);
      }
      else {
         return FALSE;
      }
   }
   sql_code      = "INSERT INTO javafalls.mech\n"
    + (std::string)"            (player_ID_FK, model_ID_FK, ranking, name, primary_weapon, secondary_weapon, utility)\n"
    + (std::string)"     VALUES (" + player_ID_string + ", " + model_ID_string + ", 0,'" + name.ascii().get_data() + "', " + primary_weapon_string + ", " + secondary_weapon_string + ", " + utility_string + ")";

   sql_statement_new_bot = create_command(sql_code);
   sql_statement_get_bot_ID = create_command(sql_get_new_bot_ID);
   execute(sql_statement_new_bot);
   if (SQL_SUCCEEDED(last_return)) {
      execute(sql_statement_get_bot_ID);
      if (get_row(sql_statement_get_bot_ID)) {
         if (new_bot_ID = get_int_attribute(sql_statement_get_bot_ID, 1)) {
            commit();
         }
         else {
            rollback();
         }
      }
      else {
         rollback();
      }
   }
   else {
      rollback();
   }
   destroy_command(sql_statement_new_bot);
   destroy_command(sql_statement_get_bot_ID);
   return new_bot_ID;
}
int DBConnector::update_bot(int bot_ID, Array update_bot_args, String name, int update_model) {
   SQLHSTMT sql_statement;
   char bot_ID_string[STRING_INT_SIZE];
   char player_ID_string[STRING_INT_SIZE];
   char model_ID_string[STRING_INT_SIZE];
   char ranking_string[STRING_INT_SIZE];
   char primary_weapon_string[STRING_INT_SIZE];
   char secondary_weapon_string[STRING_INT_SIZE];
   char utility_string[STRING_INT_SIZE];
   sprintf(bot_ID_string, "%d", bot_ID);
   sprintf(player_ID_string, "%d", (int)update_bot_args[UPDATE_BOT_ARGS_PLAYER_ID]);
   sprintf(model_ID_string, "%d", (int)update_bot_args[UPDATE_BOT_ARGS_MODEL_ID]);
   sprintf(ranking_string, "%d", (int)update_bot_args[UPDATE_BOT_ARGS_RANKING]);
   sprintf(primary_weapon_string, "%d", (int)update_bot_args[UPDATE_BOT_ARGS_PRIMARY_WEAPON]);
   sprintf(secondary_weapon_string, "%d", (int)update_bot_args[UPDATE_BOT_ARGS_SECONDARY_WEAPON]);
   sprintf(utility_string, "%d", (int)update_bot_args[UPDATE_BOT_ARGS_UTILITY]);
   std::string sql_code = "UPDATE javafalls.mech\n"
           + (std::string)"   SET mech.player_ID_FK     = coalesce(nullif(" + player_ID_string + ", -1), mech.player_ID_FK)\n"
           + (std::string)"     , mech.model_ID_FK      = coalesce(nullif(" + bot_ID_string + ", -1), mech.model_ID_FK)\n"
           + (std::string)"     , mech.ranking          = coalesce(nullif(" + ranking_string + ", -1), mech.ranking)\n"
           + (std::string)"     , mech.name             = coalesce(trim('" + name.ascii().get_data() + "'), mech.name)\n"
           + (std::string)"     , mech.primary_weapon   = coalesce(nullif(" + primary_weapon_string + ", -1), mech.primary_weapon)\n"
           + (std::string)"     , mech.secondary_weapon = coalesce(nullif(" + secondary_weapon_string + ", -1), mech.secondary_weapon)\n"
           + (std::string)"     , mech.utility          = coalesce(nullif(" + utility_string + ", -1), mech.utility)\n"
           + (std::string)" WHERE mech.mech_ID_PK = " + bot_ID_string;

   sql_statement = create_command(sql_code);
   execute(sql_statement);
   if (SQL_SUCCEEDED(last_return)) {
      if (update_model) {
         update_model_by_bot_id(bot_ID); // Includes a commit or rollback
      }
   }
   else {
      rollback();
   }
   destroy_command(sql_statement);
   return SQL_SUCCEEDED(last_return);
}
String DBConnector::get_bot(int bot_ID, int get_model) {
   String return_value;
   char bot_ID_string[STRING_INT_SIZE];
   sprintf(bot_ID_string, "%d", bot_ID);
   std::string sqlQuery = "SELECT mech.player_ID_FK, mech.model_ID_FK, mech.ranking, mech.name, mech.primary_weapon, mech.secondary_weapon, mech.utility\n"
           + (std::string)"  FROM javafalls.mech mech\n"
           + (std::string)" WHERE mech.mech_ID_PK = " + bot_ID_string;
   SQLHSTMT sql_statement = create_command(sqlQuery);
   if (get_model) {
      get_model_by_bot_id(bot_ID);
   }
   execute(sql_statement);
   return_value = get_results(sql_statement);
   destroy_command(sql_statement);
   return return_value;
}

// Basic Model Management
// Returns the model ID (a positive integer) of the newly stored model. Returns 0 if the model could not be inserted.
int DBConnector::new_model(int player_ID) {
   int new_bot_ID = FALSE;
   char player_ID_string[STRING_INT_SIZE];
   char model_ID_string[STRING_INT_SIZE];
   SQLHSTMT sql_statement_get_model;
   sprintf(player_ID_string, "%d", player_ID);
   std::string sql_get_new_model_ID = "SELECT max(model.model_ID_PK)\n"
                       + (std::string)"  FROM javafalls.ai_model model";
   std::string sql_code = "INSERT INTO javafalls.ai_model\n"
           + (std::string)"            (player_ID_FK, model)\n"
           + (std::string)"     VALUES (" + player_ID_string + ", ?)\n";

   if (store_model(sql_code)) {
      sql_statement_get_model = create_command(sql_get_new_model_ID);
      execute(sql_statement_get_model);
      if (get_row(sql_statement_get_model)) {
         if (new_bot_ID = get_int_attribute(sql_statement_get_model, 1)) {
            commit();
         }
         else {
            rollback();
         }
      }
      else {
         rollback();
      }
      destroy_command(sql_statement_get_model);
   }
   else {
      rollback();
   }
   return new_bot_ID;
}
int DBConnector::update_model(int model_ID) {
   int return_value;
   char model_ID_string[STRING_INT_SIZE];
   sprintf(model_ID_string, "%d", model_ID);
   std::string sql_code = "UPDATE javafalls.ai_model\n"
          + (std::string)"   SET ai_model.model = ?\n"
          + (std::string)" WHERE ai_model.model_ID_PK = " + model_ID_string;

   if (return_value = store_model(sql_code)) {
      commit();
   }
   else {
      rollback();
   }
   return return_value;
}
int DBConnector::update_model_by_bot_id(int bot_id) {
   int return_value;
   char bot_ID_string[STRING_INT_SIZE];
   sprintf(bot_ID_string, "%d", bot_id);
   std::string sql_code = "UPDATE javafalls.ai_model\n"
           + (std::string)"   SET ai_model.model = ?\n"
           + (std::string)" WHERE ai_model.model_ID_PK = (SELECT mech.model_ID_FK\n"
           + (std::string)"                                 FROM javafalls.mech\n"
           + (std::string)"                                WHERE mech.mech_ID_PK = " + bot_ID_string + ")";
//   std::string   sqlOldMergeQuery = "MERGE INTO javafalls.ai_model AS target\n"
//      + (std::string)"     USING (SELECT " + model_ID_string + ") AS source (model_ID_FK)\n"
//      + (std::string)"        ON (target.model_ID_PK = source.model_ID_FK)\n"
//      + (std::string)" WHEN MATCHED THEN\n"
//      + (std::string)"      UPDATE SET target.model = ?\n"
//      + (std::string)" WHEN NOT MATCHED THEN\n"
//      + (std::string)"      INSERT (model_ID_PK, player_ID_FK, model)\n"
//      + (std::string)"      VALUES ((SELECT coalesce(max(model.model_ID_PK), 0) + 1\n"
//      + (std::string)"                 FROM javafalls.ai_model model),\n"
//      + (std::string)"              " + player_ID_string + ",\n"
//      + (std::string)"              ?);";

   if (return_value = store_model(sql_code)) {
      commit();
   }
   else {
      rollback();
   }
   return return_value;
}
int DBConnector::get_model(int model_ID) {
   char model_ID_string[STRING_INT_SIZE];
   sprintf(model_ID_string, "%d", model_ID);
   std::string sql_query = "SELECT model.model\n"
            + (std::string)"  FROM javafalls.ai_model model\n"
            + (std::string)" WHERE model.model_ID_PK = " + model_ID_string;
   return get_model_by_sql(sql_query);
}
int DBConnector::get_model_by_bot_id(int bot_id) {
   char bot_ID_string[STRING_INT_SIZE];
   sprintf(bot_ID_string, "%d", bot_id);
   std::string sql_query = "SELECT model.model\n"
            + (std::string)"  FROM javafalls.ai_model model\n"
            + (std::string)"  JOIN javafalls.mech mech\n"
            + (std::string)"    ON mech.model_ID_FK = model.model_ID_PK\n"
            + (std::string)" WHERE mech.mech_ID_PK = " + bot_ID_string;
   return get_model_by_sql(sql_query);
}

// Returns a list of ids for the bots found in a certain score range (excludes bot id sent to the function)
String DBConnector::get_bot_range(int bot_id, int min_score, int max_score) {
   return "";
}
// Returns score of the bot with the highest score
int DBConnector::get_max_score() {
   return 0;
}
// Returns score of the bot with the lowest score
int DBConnector::get_min_score() {
   return 0;
}

// Get name parts for username login screen
String DBConnector::get_name_parts(int section) {
   return "";
}

/***********************************************************************************************************
/ DB Interaction Helpers
/***********************************************************************************************************/
// Assumes that the sql_code only contains one bind parameter, and that that parameter is the AI model
int DBConnector::store_model(std::string sql_code) {
   SQLHSTMT      sql_statement;
   SQLCHAR       *file_data;
   SQLCHAR       *p_file_data; // Used to walk through the fileData
   SQLLEN        file_length = 0;
   char          data_byte;
   std::ifstream in_stream;
   // 1. Read the model file into memory
   // Allocate space to store the file in memory
   try {
      file_data = new SQLCHAR[COLUMN_DATA_BUFFER];
      p_file_data = file_data;
   }
   catch (std::bad_alloc exception) {
      std::cout << "store_model() - Could not allocate space to store file in memory.\n";
      return FALSE;
   }
   // Open the file and read its data
   in_stream.open(FILEPATH_IN_MODEL, std::ios::in | std::ios::binary);
   if (!in_stream) {
      std::cout << "store_model() - Could not find file\n";
      delete[] file_data;
      return FALSE;
   }
   while (in_stream) {
      in_stream.get(data_byte);
      if (in_stream) {
         *p_file_data = data_byte;
         p_file_data++;
         file_length++;
      }
   }
   std::cout << "Bytes read: " << file_length << "\n";
   in_stream.close();

   // 2. Store data in the database
   sql_statement = create_command(sql_code);
   if(!SQL_SUCCEEDED(last_return = SQLBindParameter(sql_statement,
                                                    1,
                                                    SQL_PARAM_INPUT,
                                                    SQL_C_BINARY,
                                                    SQL_LONGVARBINARY,
                                                    BLOB_MAX,
                                                    0,
                                                    file_data,
                                                    file_length,
                                                    &file_length))) {
      print_error_diagnostics("store_model()", SQL_HANDLE_STMT, sql_statement);
   }
   execute(sql_statement);
   if (SQL_SUCCEEDED(last_return)) {
      commit();
   }
   else {
      rollback();
   }
   destroy_command(sql_statement);
   delete[] file_data;
   return SQL_SUCCEEDED(last_return);
}
int DBConnector::get_model_by_sql(std::string sql_query) {
   SQLHSTMT      sql_statement;
   SQLLEN        indicator;  // Value returned by SQLGetData to tell us if the data is null or how many bytes the data is
   char          *model_data; // 1 MB buffer that will store in memory the model from the database
   std::ofstream out_stream;  // Output stream to write the model to the disk
   // 1. Allocate space for the model in memory
   try {
      model_data = new char[COLUMN_DATA_BUFFER];
   }
   catch (std::bad_alloc exception) {
      std::cout << "get_model_by_sql() - Allocation failure for modelData, trying to allocate space for " << COLUMN_DATA_BUFFER << " characters\n";
      return FALSE;
   }
   // 2. Load the model from the database into memory
   sql_statement = create_command(sql_query);
   execute(sql_statement);
   // Get the row
   if (SQL_SUCCEEDED(last_return = SQLFetch(sql_statement))) {
      // Get the column
      if (SQL_SUCCEEDED(last_return = SQLGetData(sql_statement,
                                                 1,
                                                 SQL_C_BINARY,
                                                 model_data,
                                                 COLUMN_DATA_BUFFER,
                                                 &indicator))) {
         // 3. Write the model from memory to a file
         out_stream.open(FILEPATH_OUT_MODEL, std::ios::out | std::ios::binary);
         if (out_stream) {
            for (int i = 0; i < indicator; i++) {
               out_stream.put(model_data[i]);
            }
            out_stream.close();
         }
         else {
            std::cout << "get_model_by_sql() - unable to open file to write model to.\n";
            return FALSE;
         }
      }
      else if (last_return != SQL_NO_DATA) {
         print_error_diagnostics("get_model_by_sql()", SQL_HANDLE_STMT, sql_statement);
         return FALSE;
      }
   }
   else if (last_return != SQL_NO_DATA) {
      print_error_diagnostics("get_model_by_sql()", SQL_HANDLE_STMT, sql_statement);
      return FALSE;
   }
   destroy_command(sql_statement);

   delete[] model_data;
   return TRUE;
}
int DBConnector::get_row(SQLHSTMT sql_statement_handle) {
   return SQL_SUCCEEDED(last_return = SQLFetch(sql_statement_handle));
}
int DBConnector::get_int_attribute(SQLHSTMT sql_statement_handle, int column_number) {
   int col_value;
   SQLLEN indicator;
   if (SQL_SUCCEEDED(last_return = SQLGetData(sql_statement_handle,
                                              column_number,
                                              SQL_C_LONG,
                                              &col_value,
                                              COLUMN_DATA_BUFFER,
                                              &indicator))) {
      return col_value;
   }
   else {
      print_error_diagnostics("get_int_attribute()", SQL_HANDLE_STMT, sql_statement_handle);
   }
   return FALSE;
}


/***********************************************************************************************************
/ Database Query Functions
/***********************************************************************************************************/
SQLHSTMT DBConnector::create_command(std::string sql_string) {
   std::cout << sql_string << '\n';
   SQLHSTMT sql_statement_handle;
   // If the connection is currently closed, try to open it
   if (!connection_open) {
      open_connection();
   }
   if (connection_open) {
      // Allocate the statement handle
      if (SQL_SUCCEEDED(last_return = SQLAllocHandle(SQL_HANDLE_STMT, con_handle, &sql_statement_handle))) {
         // Attach the SQL code to the statement handle
         if (SQL_SUCCEEDED(last_return = SQLPrepare(sql_statement_handle,
                                                    (SQLCHAR *)sql_string.c_str(),
                                                    SQL_NTS))) {
            return sql_statement_handle;
         }
         else {
            print_error_diagnostics("create_command()", SQL_HANDLE_STMT, sql_statement_handle);
         }
      }
      else {
         print_error_diagnostics("create_command()", SQL_HANDLE_STMT, sql_statement_handle);
      }
   }
   return SQL_NULL_HANDLE;
}
void DBConnector::destroy_command(SQLHSTMT sql_statement_handle) {
   int tries = 0;
   while (!SQL_SUCCEEDED(last_return = SQLFreeHandle(SQL_HANDLE_STMT, sql_statement_handle)) && tries < 1000) tries++;
}
// Note: SQLDescribeParam could come in handy here to get some/most of the data required for SQLBindParameter
//void DBConnector::BindParameter(SQLHSTMT sqlStatementHandle, int paramNumber, std::string paramValue, int paramType) {
//   if (SQL_SUCCEEDED(lastReturn = SQLBindParameter(sqlStatementHandle,
//                                                   (SQLSMALLINT)paramNumber,
//                                                   (SQLSMALLINT)paramType,
//                                                   SQL_C_DEFAULT,
//      SQLHSTMT        StatementHandle,
//      SQLUSMALLINT    ParameterNumber,
//      SQLSMALLINT     InputOutputType,
//      SQLSMALLINT     ValueType,
//      SQLSMALLINT     ParameterType,
//      SQLULEN         ColumnSize,
//      SQLSMALLINT     DecimalDigits,
//      SQLPOINTER      ParameterValuePtr,
//      SQLLEN          BufferLength,
//      SQLLEN *        StrLen_or_IndPtr))) {
//      // Success
//   }
//   else {
//      PrintErrorDiagnostics("BindParameter()", SQL_HANDLE_STMT, p_SQLStatementHandle);
//   }
//}
void DBConnector::execute(SQLHSTMT sql_statement_handle) {
   if (connection_open) {
      if (!SQL_SUCCEEDED(last_return = SQLExecute(sql_statement_handle))) {
         print_error_diagnostics("execute()", SQL_HANDLE_STMT, sql_statement_handle);
      }
   }
   return;
}
String DBConnector::get_results(SQLHSTMT sql_statement_handle) {
   std::string json_result = "";  // Used to store the JSON string that will be returned
   int         row_number = 1;    // Number of the row we are currently fetching
   int         i;                 // Number of the column we are currently getting
   SQLLEN      indicator;         // Value returned by SQLGetData to tell us if the data is null or how many bytes the data is
   char        *col_data;         // 1 MB Buffer to an individual column's data. Allocated on the heap to avoid a stack overflow
   SQLSMALLINT number_of_columns; // How many columns are returned by the fetch
   std::string *col_names;        // An array to the names of each column
   SQLSMALLINT *col_data_types;   // An array to the data types of each column
   if (connection_open) {
      // Get number of columns in the result set
      SQLNumResultCols(sql_statement_handle, &number_of_columns);
      // Allocate space to store information about those columns
      try {
         col_names = new std::string[number_of_columns + 1]; // Allocate 1 extra spot to account for the fact that array indices start at 0 while column numbers start at 1
      }
      catch (std::bad_alloc exception) {
         std::cout << "get_results() - Allocation failure for colNames, trying to allocate space for " << number_of_columns << " objects\n";
         return json_result.c_str();
      }
      try {
         col_data_types = new SQLSMALLINT[number_of_columns + 1]; // Allocate 1 extra spot to account for the fact that array indices start at 0 while column numbers start at 1
      }
      catch (std::bad_alloc exception) {
         delete[] col_names;
         std::cout << "get_results() - Allocation failure for colDataTypes, trying to allocate space for " << number_of_columns << " SQLSMALLINTs\n";
         return json_result.c_str();
      }
      try {
         col_data = new char[COLUMN_DATA_BUFFER];
      }
      catch (std::bad_alloc exception) {
         delete[] col_names;
         delete[] col_data_types;
         std::cout << "get_results() - Allocation failure for colData, trying to allocate space for 1048576 characters\n";
         return json_result.c_str();
      }
      // Get column names and data types
      for (i = 1; i <= number_of_columns; i++) {
         get_column_information(sql_statement_handle, i, &col_names[i], &col_data_types[i]);
      }

      // Build JSON result string
      json_result = "{\n   \"data\": [\n";
      // Loop through all rows
      while (SQL_SUCCEEDED(last_return = SQLFetch(sql_statement_handle))) {
         if (row_number > 1) {
            json_result.append(",\n");
         }
         json_result.append("       {");
         // Loop through all columns
         for (i = 1; i <= number_of_columns; i++) {
            if (SQL_SUCCEEDED(last_return = SQLGetData(sql_statement_handle,
                                                       i,
                                                       SQL_C_CHAR,
                                                       col_data,
                                                       COLUMN_DATA_BUFFER,
                                                       &indicator))) {
               if (i > 1) { json_result.append(","); }
               json_result.append(" \"").append(col_names[i]).append("\": ");
               if (indicator == SQL_NULL_DATA) {
                  json_result.append("null");
               }
               else {
                  switch (col_data_types[i]) {
                  case SQL_SMALLINT:
                  case SQL_INTEGER:
                  case SQL_BIT:
                  case SQL_TINYINT:
                  case SQL_BIGINT:
                     // Integers
                     json_result.append(col_data);
                     break;
                  case SQL_DECIMAL:
                  case SQL_NUMERIC:
                  case SQL_REAL:
                  case SQL_FLOAT:
                  case SQL_DOUBLE:
                     // Doubles
                     json_result.append(col_data);
                     break;
                  default:
                     // Treat everything else as string data
                     json_result.append("\"").append(col_data).append("\"");
                     break;
                  }
               }
            }
         }
         json_result.append("}");
         row_number++;
      }
      json_result.append("\n   ]\n}");
      // Free allocated memory
      delete[] col_names;
      delete[] col_data_types;
      delete[] col_data;
   }
   return json_result.c_str();
}

/***********************************************************************************************************
/ GDScript Connector Functions
/***********************************************************************************************************/
// Required by Godot, use to bind c++ methods into things that can be seen by GDScript
void DBConnector::_bind_methods() {
   ClassDB::bind_method(D_METHOD("new_player", "name"), &DBConnector::new_player);
   ClassDB::bind_method(D_METHOD("update_player", "player_ID", "name"), &DBConnector::update_player);
   ClassDB::bind_method(D_METHOD("get_player", "player_ID"), &DBConnector::get_player);

   ClassDB::bind_method(D_METHOD("new_bot", "player_ID", "new_bot_args", "name"), &DBConnector::new_bot);
   ClassDB::bind_method(D_METHOD("update_bot", "bot_ID", "update_bot_args", "name", "update_model"), &DBConnector::update_bot);
   ClassDB::bind_method(D_METHOD("get_bot", "bot_ID", "get_model"), &DBConnector::get_bot);

   ClassDB::bind_method(D_METHOD("new_model", "player_ID"), &DBConnector::new_model);
   ClassDB::bind_method(D_METHOD("update_model", "model_ID"), &DBConnector::update_model);
   ClassDB::bind_method(D_METHOD("update_model_by_bot_id", "bot_ID"), &DBConnector::update_model_by_bot_id);
   ClassDB::bind_method(D_METHOD("get_model", "model_ID"), &DBConnector::get_model);
   ClassDB::bind_method(D_METHOD("get_model_by_bot_id", "bot_ID"), &DBConnector::get_model_by_bot_id);

   ClassDB::bind_method(D_METHOD("get_bot_range", "bot_id", "min_score", "max_score"), &DBConnector::get_bot_range);
   ClassDB::bind_method(D_METHOD("get_max_score"), &DBConnector::get_max_score);
   ClassDB::bind_method(D_METHOD("get_min_score"), &DBConnector::get_min_score);

   ClassDB::bind_method(D_METHOD("get_name_parts", "section"), &DBConnector::get_name_parts);

   ClassDB::bind_method(D_METHOD("open_connection"), &DBConnector::open_connection);
   ClassDB::bind_method(D_METHOD("close_connection"), &DBConnector::close_connection);
   ClassDB::bind_method(D_METHOD("is_connection_open"), &DBConnector::is_connection_open);
}

/***********************************************************************************************************
/ Constructors and Destructors
/***********************************************************************************************************/
DBConnector::DBConnector() {
   // Initialize basic values
   con_string = live_connection_string;
   connection_open = FALSE;
   last_return = SQL_ERROR;
   env_handle = SQL_NULL_HANDLE;
   con_handle = SQL_NULL_HANDLE;

   // Override the default connection string if a DSN file was provided
   std::ifstream in_stream;
   std::cout << "Searching for: " << CONNECTION_OVERRIDE_FILENAME << "\n";
   in_stream.open(CONNECTION_OVERRIDE_FILENAME, std::ios::in);
   if (in_stream) {
      std::cout << CONNECTION_OVERRIDE_FILENAME << " found, overriding default connection string\n";
      char override_connection_string[MAX_CONNECTION_OVERRIDE_FILE_SIZE];
      char *p_override_string = override_connection_string;
      char in_char;
      in_stream.get(in_char);
      while (in_stream) {
         *p_override_string = in_char;
         p_override_string++;
         in_stream.get(in_char);
      }
      con_string = override_connection_string;
   }
   in_stream.close();
   std::cout << "Connection string being used is: \n" << con_string << "\n";

   // Allocate an environment handle
   if (SQL_SUCCEEDED(last_return = SQLAllocHandle(SQL_HANDLE_ENV, SQL_NULL_HANDLE, &env_handle))) {
      // Set up the environment attributes
      if (!SQL_SUCCEEDED(last_return = SQLSetEnvAttr(env_handle, SQL_ATTR_ODBC_VERSION, (void *)SQL_OV_ODBC3, 0))) {
         print_error_diagnostics("DBConnector()", SQL_HANDLE_ENV, env_handle);
      }
      if (!SQL_SUCCEEDED(last_return = SQLAllocHandle(SQL_HANDLE_DBC, env_handle, &con_handle))) {
         print_error_diagnostics("DBConnector()", SQL_HANDLE_DBC, con_handle);
      }
      if (!SQL_SUCCEEDED(last_return = SQLSetConnectAttr(con_handle, SQL_ATTR_AUTOCOMMIT, FALSE, 0))) {
         print_error_diagnostics("DBConnector()", SQL_HANDLE_DBC, con_handle);
      }
   }
   else {
      // Crash and burn, but do it gracefully.
      print_error_diagnostics("DBConnector()", SQL_HANDLE_ENV, env_handle);
   }
   return;
}
DBConnector::~DBConnector() {
   int tries = 0;
   // Check if the connection is open, if it is, close it. Ideally we should also notify someone that they failed to close their connection...
   if (connection_open == TRUE) {
      close_connection();
   }
   // Make sure all of the handles are free
   // Free environment handles
   while (!SQL_SUCCEEDED(last_return = SQLFreeHandle(SQL_HANDLE_DBC, con_handle)) && tries < 1000) tries++; // If this loop terminates due to hitting the max number of tries we have some serious problems
   if (!SQL_SUCCEEDED(last_return)) {
      print_error_diagnostics("~DBConnector()", SQL_HANDLE_DBC, con_handle);
   }
   tries = 0;
   while (!SQL_SUCCEEDED(last_return = SQLFreeHandle(SQL_HANDLE_ENV, env_handle)) && tries < 1000) tries++; // If this loop terminates due to hitting the max number of tries we have some serious problems
   if (!SQL_SUCCEEDED(last_return)) {
      print_error_diagnostics("~DBConnector()", SQL_HANDLE_ENV, env_handle);
   }
   return;
}

/***********************************************************************************************************
/ Getters and setters
/***********************************************************************************************************/
SQLRETURN DBConnector::get_last_return_code() {
   return last_return;
}

/***********************************************************************************************************
/ Private Functions
/***********************************************************************************************************/
// Prints to the console and diagnostic records for that handle.
void DBConnector::print_error_diagnostics(std::string function_name, SQLSMALLINT handle_type, SQLHANDLE handle) {
   const SQLSMALLINT BUFFER_LENGTH = 1024;
   SQLSMALLINT record_number = 1;

   SQLCHAR state[6];
   SQLINTEGER p_error;
   SQLCHAR message[BUFFER_LENGTH];
   SQLSMALLINT actual_message_length;

   std::cout << "--------------------------------------------------------\n";
   std::cout << function_name << " failed. Printing diagnostic information\n";
   if (handle == SQL_NULL_HANDLE) { std::cout << "NULL HANDLE DETECTED\n"; }
   while (SQL_SUCCEEDED(SQLGetDiagRec(handle_type,
                                      handle,
                                      record_number,
                                      state,
                                      &p_error,
                                      message,
                                      BUFFER_LENGTH,
                                      &actual_message_length))) {
      std::cout << "#" << record_number << ": " << state << " - " << message << "\n";
      record_number++;
   }
   std::cout << function_name << " end diagonstic information\n";
   std::cout << "--------------------------------------------------------\n";
   return;
}

void DBConnector::get_column_information(SQLHSTMT sql_statement_handle, int column_number, std::string *p_column_name, SQLSMALLINT *p_data_type) {
   SQLCHAR column_name[256];

   SQLSMALLINT name_length; // we don't care about this value
   SQLULEN     column_size; // we don't care about this value
   SQLSMALLINT decimal_digits; // we don't care about this value
   SQLSMALLINT nullable; // we don't care about this value
   if (SQL_SUCCEEDED(last_return = SQLDescribeCol(sql_statement_handle,
                                                  column_number,
                                                  column_name,
                                                  256,
                                                  &name_length,
                                                  p_data_type,
                                                  &column_size,
                                                  &decimal_digits,
                                                  &nullable
                                                  ))) {
      p_column_name->assign((char*)column_name);
   }
   else {
      print_error_diagnostics("get_column_information()", SQL_HANDLE_STMT, sql_statement_handle);
   }
   return;
}
