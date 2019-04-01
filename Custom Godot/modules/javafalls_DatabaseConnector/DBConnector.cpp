// DBConnector.cpp : Source code file for the DBConnector. Contains all function definitions.
// Please see corresponding header file ("DBConnector.h") for function declarations and documentation.

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

#define STRING_INT_SIZE        11                      // How long a string needs to be to hold an int that has been converted to a string, plus the null terminator
#define BLOB_MAX               2147483647              // Max size of a BLOB (binary large object) in SQL Server
#define FILENAME_GENERIC_MODEL "generic_model.h5"      // Filename to use when storing a brand new network in the DBs
#define FILEPATH_MODEL_FOLDER  "NeuralNetwork/models/" // Folder used to store models

// Values used in place of nulls when putting data in the database
# define NULL_COLOR 0
# define NULL_INT   -1

# define PLAYER_BOT_NAME "Sensei" // The name used by player bots (bots that never get trained)

// Constants to access arrays of arguments used when a function that needs to be usable by Godot exceeds 5 arguments
// Godot has a bug that prevents binding of functions with 6 or more arguments
#define NEW_BOT_ARGS_MODEL_ID 0
#define NEW_BOT_ARGS_PRIMARY_WEAPON 1
#define NEW_BOT_ARGS_SECONDARY_WEAPON 2
#define NEW_BOT_ARGS_UTILITY 3
#define NEW_BOT_ARGS_PRIMARY_COLOR 4
#define NEW_BOT_ARGS_SECONDARY_COLOR 5
#define NEW_BOT_ARGS_ACCENT_COLOR 6
#define NEW_BOT_ARGS_ANIMATION 7
#define NEW_BOT_ARGS_ARRAY_SIZE 8
#define UPDATE_BOT_ARGS_PLAYER_ID 0
#define UPDATE_BOT_ARGS_MODEL_ID 1
#define UPDATE_BOT_ARGS_RANKING 2
#define UPDATE_BOT_ARGS_PRIMARY_WEAPON 3
#define UPDATE_BOT_ARGS_SECONDARY_WEAPON 4
#define UPDATE_BOT_ARGS_UTILITY 5
#define UPDATE_BOT_ARGS_PRIMARY_COLOR 6
#define UPDATE_BOT_ARGS_SECONDARY_COLOR 7
#define UPDATE_BOT_ARGS_ACCENT_COLOR 8
#define UPDATE_BOT_ARGS_ANIMATION 9
#define UPDATE_BOT_ARGS_ARRAY_SIZE 10

/***********************************************************************************************************
/ Debug Control
/***********************************************************************************************************/
void DBConnector::set_debug_sql(Variant bool_print_sql) {
   debug_sql = bool_print_sql;
}

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
      rollback();
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
   const int PARAM_PLAYER_NAME = 1;

   int new_player_id = FALSE;
   std::string string_name = name.ascii().get_data();
   std::string sql_get_new_player_ID = "SELECT max(player.player_ID_PK)\n"
                        + (std::string)"  FROM javafalls.player player";
   std::string sql_insert = "INSERT INTO javafalls.player\n"
             + (std::string)"            (name)\n"
             + (std::string)"     VALUES (?)";

   SQLHSTMT sql_statement_get_player_ID = create_command(sql_get_new_player_ID);
   SQLHSTMT sql_statement_insert = create_command(sql_insert);
   bind_parameter(sql_statement_insert, PARAM_PLAYER_NAME, &string_name);//name.ascii().get_data());

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
   const int SQL_PARAM_PLAYER_NAME = 1;
   const int SQL_PARAM_PLAYER_ID = 2;

   int succeeded = FALSE;
   std::string string_name = name.ascii().get_data();
   std::string sql_code = "UPDATE javafalls.player\n"
           + (std::string)"   SET player.name = ?"//'" + name.ascii().get_data() + "'\n"
           + (std::string)" WHERE player.player_ID_PK = ?";//" + player_ID_string;
   SQLHSTMT sql_statement = create_command(sql_code);
   bind_parameter(sql_statement, SQL_PARAM_PLAYER_NAME, &string_name);
   bind_parameter(sql_statement, SQL_PARAM_PLAYER_ID, &player_ID);
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
   const int PARAM_PLAYER_ID = 1;

   String return_value;
   std::string sql_query = "SELECT player.name\n"
            + (std::string)"  FROM javafalls.player player\n"
            + (std::string)" WHERE player.player_ID_PK = ?";

   SQLHSTMT sql_statement = create_command(sql_query);
   bind_parameter(sql_statement, PARAM_PLAYER_ID, &player_ID);
   execute(sql_statement);
   return_value = get_results(sql_statement);
   destroy_command(sql_statement);

   return return_value;
}

// Basic Bot Management
int DBConnector::new_bot(int player_ID, Array new_bot_args, String name) {
   const int PARAM_INSERT_PLAYER_ID = 1;
   const int PARAM_INSERT_MODEL_ID = 2;
   const int PARAM_INSERT_RANKING = 3;
   const int PARAM_INSERT_NAME = 4;
   const int PARAM_INSERT_PRIMARY_WEAPON = 5;
   const int PARAM_INSERT_SECONDARY_WEAPON = 6;
   const int PARAM_INSERT_UTILITY = 7;
   const int PARAM_INSERT_PRIMARY_COLOR = 8;
   const int PARAM_INSERT_SECONDARY_COLOR = 9;
   const int PARAM_INSERT_ACCENT_COLOR = 10;
   const int PARAM_INSERT_ANIMATION = 11;

   SQLHSTMT sql_statement_new_bot;
   SQLHSTMT sql_statement_get_bot_ID;
   int new_bot_ID = FALSE;
   int ranking = 0;
   int primary_weapon = (int)new_bot_args[NEW_BOT_ARGS_PRIMARY_WEAPON];
   int secondary_weapon = (int)new_bot_args[NEW_BOT_ARGS_SECONDARY_WEAPON];
   int utility = (int)new_bot_args[NEW_BOT_ARGS_UTILITY];
   int model_ID = (int)new_bot_args[NEW_BOT_ARGS_MODEL_ID];
   unsigned int primary_color = (unsigned int)new_bot_args[NEW_BOT_ARGS_PRIMARY_COLOR];
   unsigned int secondary_color = (unsigned int)new_bot_args[NEW_BOT_ARGS_SECONDARY_COLOR];
   unsigned int accent_color = (unsigned int)new_bot_args[NEW_BOT_ARGS_ACCENT_COLOR];
   std::string animation = ((String)new_bot_args[NEW_BOT_ARGS_ANIMATION]).ascii().get_data();

   std::string string_name = name.ascii().get_data();
   std::string sql_get_new_bot_ID = "SELECT max(bot.bot_ID_PK)\n"
                     + (std::string)"  FROM javafalls.bot bot";
   std::string sql_code = "INSERT INTO javafalls.bot\n"
           + (std::string)"            (player_ID_FK, model_ID_FK, ranking, name, primary_weapon, secondary_weapon, utility, primary_color, secondary_color, accent_color, animation)\n"
           + (std::string)"     VALUES (           ?,           ?,       ?,    ?,              ?,                ?,       ?,             ?,               ?,            ?,         ?)";

   sql_statement_new_bot = create_command(sql_code);
   sql_statement_get_bot_ID = create_command(sql_get_new_bot_ID);

   bind_parameter(sql_statement_new_bot, PARAM_INSERT_PLAYER_ID, &player_ID);
   bind_parameter(sql_statement_new_bot, PARAM_INSERT_MODEL_ID, &model_ID);
   bind_parameter(sql_statement_new_bot, PARAM_INSERT_RANKING, &ranking);
   bind_parameter(sql_statement_new_bot, PARAM_INSERT_NAME, &string_name);
   bind_parameter(sql_statement_new_bot, PARAM_INSERT_PRIMARY_WEAPON, &primary_weapon);
   bind_parameter(sql_statement_new_bot, PARAM_INSERT_SECONDARY_WEAPON, &secondary_weapon);
   bind_parameter(sql_statement_new_bot, PARAM_INSERT_UTILITY, &utility);
   bind_parameter(sql_statement_new_bot, PARAM_INSERT_PRIMARY_COLOR, (int *)&primary_color); // SQL Server does not support unsigned integers, so trick it into thinking the int is signed
   bind_parameter(sql_statement_new_bot, PARAM_INSERT_SECONDARY_COLOR, (int *)&secondary_color);
   bind_parameter(sql_statement_new_bot, PARAM_INSERT_ACCENT_COLOR, (int *)&accent_color);
   bind_parameter(sql_statement_new_bot, PARAM_INSERT_ANIMATION, &animation);
   if (model_ID <= 0) {
      // Model ID not provided, attempt to insert the model into the database ourselves
      new_bot_args[NEW_BOT_ARGS_MODEL_ID] = (Variant)new_model(player_ID, String(FILENAME_GENERIC_MODEL));
      model_ID = (int)new_bot_args[NEW_BOT_ARGS_MODEL_ID];
      if (!model_ID) {
         // Insert of new model failed, return with an error
         return FALSE;
      }
   }

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
int DBConnector::update_bot(int bot_ID, Array update_bot_args, String name, String model_file_name) {
   const int PARAM_UPDATE_PLAYER_ID = 1;
   const int PARAM_UPDATE_MODEL_ID = 2;
   const int PARAM_UPDATE_RANKING = 3;
   const int PARAM_UPDATE_NAME = 4;
   const int PARAM_UPDATE_PRIMARY_WEAPON = 5;
   const int PARAM_UPDATE_SECONDARY_WEAPON = 6;
   const int PARAM_UPDATE_UTILITY = 7;
   const int PARAM_UPDATE_PRIMARY_COLOR = 8;
   const int PARAM_UPDATE_SECONDARY_COLOR = 9;
   const int PARAM_UPDATE_ACCENT_COLOR = 10;
   const int PARAM_UPDATE_ANIMATION = 11;
   const int PARAM_UPDATE_BOT_ID = 12;

   int player_ID = (int)update_bot_args[UPDATE_BOT_ARGS_PLAYER_ID];
   int model_ID = (int)update_bot_args[UPDATE_BOT_ARGS_MODEL_ID];
   int ranking = (int)update_bot_args[UPDATE_BOT_ARGS_RANKING];
   std::string string_name = name.ascii().get_data();
   int primary_weapon = (int)update_bot_args[UPDATE_BOT_ARGS_PRIMARY_WEAPON];
   int secondary_weapon = (int)update_bot_args[UPDATE_BOT_ARGS_SECONDARY_WEAPON];
   int utility = (int)update_bot_args[UPDATE_BOT_ARGS_UTILITY];
   unsigned int primary_color = (unsigned int)update_bot_args[UPDATE_BOT_ARGS_PRIMARY_COLOR];
   unsigned int secondary_color = (unsigned int)update_bot_args[UPDATE_BOT_ARGS_SECONDARY_COLOR];
   unsigned int accent_color = (unsigned int)update_bot_args[UPDATE_BOT_ARGS_ACCENT_COLOR];
   std::string animation = ((String)update_bot_args[UPDATE_BOT_ARGS_ANIMATION]).ascii().get_data();

   SQLHSTMT sql_statement;
   std::string sql_code = "UPDATE javafalls.bot\n"
           + (std::string)"   SET bot.player_ID_FK     = coalesce(nullif(?, -1),               bot.player_ID_FK)\n"
           + (std::string)"     , bot.model_ID_FK      = coalesce(nullif(?, -1),               bot.model_ID_FK)\n"
           + (std::string)"     , bot.ranking          = coalesce(nullif(?, -1),               bot.ranking)\n"
           + (std::string)"     , bot.name             = coalesce(nullif(rtrim(ltrim(?)),''), bot.name)\n"
           + (std::string)"     , bot.primary_weapon   = coalesce(nullif(?, -1),               bot.primary_weapon)\n"
           + (std::string)"     , bot.secondary_weapon = coalesce(nullif(?, -1),               bot.secondary_weapon)\n"
           + (std::string)"     , bot.utility          = coalesce(nullif(?, -1),               bot.utility)\n"
           + (std::string)"     , bot.primary_color    = coalesce(nullif(?, 0),                bot.primary_color)\n"
           + (std::string)"     , bot.secondary_color  = coalesce(nullif(?, 0),                bot.secondary_color)\n"
           + (std::string)"     , bot.accent_color     = coalesce(nullif(?, 0),                bot.accent_color)\n"
           + (std::string)"     , bot.animation        = coalesce(nullif(rtrim(ltrim(?)),''),  bot.animation)\n"
           + (std::string)" WHERE bot.bot_ID_PK = ?";

   sql_statement = create_command(sql_code);
   bind_parameter(sql_statement, PARAM_UPDATE_BOT_ID, &bot_ID);
   bind_parameter(sql_statement, PARAM_UPDATE_PLAYER_ID, &player_ID);
   bind_parameter(sql_statement, PARAM_UPDATE_MODEL_ID, &model_ID);
   bind_parameter(sql_statement, PARAM_UPDATE_RANKING, &ranking);
   bind_parameter(sql_statement, PARAM_UPDATE_NAME, &string_name);
   bind_parameter(sql_statement, PARAM_UPDATE_PRIMARY_WEAPON, &primary_weapon);
   bind_parameter(sql_statement, PARAM_UPDATE_SECONDARY_WEAPON, &secondary_weapon);
   bind_parameter(sql_statement, PARAM_UPDATE_UTILITY, &utility);
   bind_parameter(sql_statement, PARAM_UPDATE_PRIMARY_COLOR, (int *)&primary_color); // SQL Server does not support unsigned integers, so trick it into thinking the int is signed
   bind_parameter(sql_statement, PARAM_UPDATE_SECONDARY_COLOR, (int *)&secondary_color);
   bind_parameter(sql_statement, PARAM_UPDATE_ACCENT_COLOR, (int *)&accent_color);
   bind_parameter(sql_statement, PARAM_UPDATE_ANIMATION, &animation);
   execute(sql_statement);
   if (SQL_SUCCEEDED(last_return)) {
      if (model_file_name.length()) {
         update_model_by_bot_id(bot_ID, model_file_name); // Includes a commit or rollback
      }
      else {
         commit();
      }
   }
   else {
      rollback();
   }
   destroy_command(sql_statement);
   return SQL_SUCCEEDED(last_return);
}
String DBConnector::get_bot(int bot_ID, String model_file_name) {
   const int PARAM_QUERY_BOT_ID = 1;

   String return_value;
   char bot_ID_string[STRING_INT_SIZE];
   sprintf(bot_ID_string, "%d", bot_ID);
   std::string sqlQuery = "SELECT bot.player_ID_FK, bot.model_ID_FK, bot.ranking, bot.name\n"
           + (std::string)"     , bot.primary_weapon, bot.secondary_weapon, bot.utility\n"
           + (std::string)"     , bot.primary_color, bot.secondary_color, bot.accent_color\n"
           + (std::string)"     , bot.animation\n"
           + (std::string)"  FROM javafalls.bot\n"
           + (std::string)" WHERE bot.bot_ID_PK = ?";

   SQLHSTMT sql_statement = create_command(sqlQuery);
   bind_parameter(sql_statement, PARAM_QUERY_BOT_ID, &bot_ID);
   if (model_file_name.length()) {
      get_model_by_bot_id(bot_ID, model_file_name);
   }
   execute(sql_statement);
   return_value = get_results(sql_statement);
   destroy_command(sql_statement);
   return return_value;
}

// Basic Model Management
// Returns the model ID (a positive integer) of the newly stored model. Returns 0 if the model could not be inserted.
int DBConnector::new_model(int player_ID, String model_file_name) {
   const int PARAM_INSERT_PLAYER_ID = 1;
   const int PARAM_INSERT_MODEL = 2;

   int new_bot_ID = FALSE;
   SQLHSTMT sql_statement_get_model;
   SQLHSTMT sql_statement_insert_model;
   std::string sql_get_new_model_ID = "SELECT max(model.model_ID_PK)\n"
                       + (std::string)"  FROM javafalls.ai_model model";
   std::string sql_code = "INSERT INTO javafalls.ai_model\n"
           + (std::string)"            (player_ID_FK, model)\n"
           + (std::string)"     VALUES (           ?,     ?)\n";

   sql_statement_insert_model = create_command(sql_code);
   bind_parameter(sql_statement_insert_model, PARAM_INSERT_PLAYER_ID, &player_ID);
   if (store_model(sql_statement_insert_model, PARAM_INSERT_MODEL, model_file_name)) {
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
int DBConnector::update_model(int model_ID, String model_file_name) {
   const int PARAM_UPDATE_MODEL = 1;
   const int PARAM_UPDATE_MODEL_ID = 2;

   int return_value;
   std::string sql_code = "UPDATE javafalls.ai_model\n"
          + (std::string)"   SET ai_model.model = ?\n"
          + (std::string)" WHERE ai_model.model_ID_PK = ?";

   SQLHSTMT sql_statement = create_command(sql_code);
   bind_parameter(sql_statement, PARAM_UPDATE_MODEL_ID, &model_ID);
   if (return_value = store_model(sql_statement, PARAM_UPDATE_MODEL, model_file_name)) {
      commit();
   }
   else {
      rollback();
   }
   return return_value;
}
int DBConnector::update_model_by_bot_id(int bot_ID, String model_file_name) {
   const int PARAM_MODEL = 1;
   const int PARAM_BOT_ID = 2;

   int return_value;
   std::string sql_code = "UPDATE javafalls.ai_model\n"
           + (std::string)"   SET ai_model.model = ?\n"
           + (std::string)" WHERE ai_model.model_ID_PK = (SELECT bot.model_ID_FK\n"
           + (std::string)"                                 FROM javafalls.bot\n"
           + (std::string)"                                WHERE bot.bot_ID_PK = ?)";
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
   SQLHSTMT sql_statement = create_command(sql_code);
   bind_parameter(sql_statement, PARAM_BOT_ID, &bot_ID);

   if (return_value = store_model(sql_statement, PARAM_MODEL, model_file_name)) {
      commit();
   }
   else {
      rollback();
   }
   return return_value;
}
int DBConnector::get_model(int model_ID, String model_file_name) {
   const int PARAM_QUERY_MODEL_ID = 1;

   std::string sql_query = "SELECT model.model\n"
            + (std::string)"  FROM javafalls.ai_model model\n"
            + (std::string)" WHERE model.model_ID_PK = ?";

   SQLHSTMT sql_statement = create_command(sql_query);
   bind_parameter(sql_statement, PARAM_QUERY_MODEL_ID, &model_ID);
   return get_model_by_sql(sql_statement, model_file_name);
}
int DBConnector::get_model_by_bot_id(int bot_ID, String model_file_name) {
   const int PARAM_QUERY_BOT_ID = 1;

   std::string sql_query = "SELECT model.model\n"
            + (std::string)"  FROM javafalls.ai_model model\n"
            + (std::string)"  JOIN javafalls.bot bot\n"
            + (std::string)"    ON bot.model_ID_FK = model.model_ID_PK\n"
            + (std::string)" WHERE bot.bot_ID_PK = ?";

   SQLHSTMT sql_statement = create_command(sql_query);
   bind_parameter(sql_statement, PARAM_QUERY_BOT_ID, &bot_ID);
   return get_model_by_sql(sql_statement, model_file_name);
}

// Returns a list of ids for the bots found in a certain score range (excludes bot id sent to the function)
String DBConnector::get_bot_range(int bot_id, int min_score, int max_score) {
   const int PARAM_BOT_ID = 1;
   const int PARAM_MIN_SCORE = 2;
   const int PARAM_MAX_SCORE = 3;

   String return_value;
   std::string sql_query = "SELECT bot.bot_ID_PK, bot.ranking"
            + (std::string)"  FROM javafalls.bot"
            + (std::string)" WHERE bot.bot_ID_PK != ?"
            + (std::string)"   AND bot.name != " + PLAYER_BOT_NAME
            + (std::string)"   AND bot.ranking BETWEEN ? AND ?";
   SQLHSTMT sql_statement = create_command(sql_query);
   bind_parameter(sql_statement, PARAM_BOT_ID, &bot_id);
   bind_parameter(sql_statement, PARAM_MIN_SCORE, &min_score);
   bind_parameter(sql_statement, PARAM_MAX_SCORE, &max_score);
   execute(sql_statement);
   return_value = get_results(sql_statement);
   destroy_command(sql_statement);
   return return_value;
}
// Returns score of the bot with the highest score
int DBConnector::get_max_score() {
   int return_value;
   std::string sql_query = "SELECT max(bot.ranking)"
            + (std::string)"  FROM javafalls.bot";
   SQLHSTMT sql_statement = create_command(sql_query);
   execute(sql_statement);
   get_row(sql_statement);
   return_value = get_int_attribute(sql_statement, 1);
   destroy_command(sql_statement);
   return return_value;
}
// Returns score of the bot with the lowest score
int DBConnector::get_min_score() {
   int return_value;
   std::string sql_query = "SELECT min(bot.ranking)"
            + (std::string)"  FROM javafalls.bot";
   SQLHSTMT sql_statement = create_command(sql_query);
   execute(sql_statement);
   get_row(sql_statement);
   return_value = get_int_attribute(sql_statement, 1);
   destroy_command(sql_statement);
   return return_value;
}
// Returns scoreboard information for the current top 10 bots
String DBConnector::get_scoreboard_top_ten() {
   String return_value;
   std::string sql_query = "SELECT bot_info.position, player.name, bot_info.ranking, bot_info.bot_ID_PK"
            + (std::string)"  FROM (SELECT ROW_NUMBER() OVER(ORDER BY bot.ranking DESC) AS position,"
            + (std::string)"               bot.ranking,"
            + (std::string)"               bot.bot_ID_PK, bot.player_ID_FK"
            + (std::string)"          FROM javafalls.bot"
            + (std::string)"       ) bot_info"
            + (std::string)"  JOIN javafalls.player"
            + (std::string)"    ON player_ID_PK = bot_info.player_ID_FK"
            + (std::string)" WHERE bot_info.position <= 10"
            + (std::string)" ORDER BY bot_info.position";
   SQLHSTMT sql_statement = create_command(sql_query);
   execute(sql_statement);
   return_value = get_results(sql_statement);
   destroy_command(sql_statement);
   return return_value;
}
// Returns the position on the scoreboard of a specified bot
int DBConnector::get_scoreboard_position(int bot_id) {
   const int PARAM_BOT_ID = 1;

   int return_value;
   std::string sql_query = "SELECT bot_info.position"
            + (std::string)"  FROM (SELECT ROW_NUMBER() OVER(ORDER BY bot.ranking DESC) AS position,"
            + (std::string)"               bot.ranking,"
            + (std::string)"               bot.bot_ID_PK, bot.player_ID_FK"
            + (std::string)"          FROM javafalls.bot"
            + (std::string)"       ) bot_info"
            + (std::string)" WHERE bot_info.bot_ID_PK = ?";
   SQLHSTMT sql_statement = create_command(sql_query);
   bind_parameter(sql_statement, PARAM_BOT_ID, &bot_id);
   execute(sql_statement);
   get_row(sql_statement);
   return_value = get_int_attribute(sql_statement, 1);
   destroy_command(sql_statement);
   return return_value;
}
// Returns all of the robots in the specified range on the scoreboard
String DBConnector::get_scoreboard_range(int min_position, int max_position) {
   const int PARAM_MIN_POSITION = 1;
   const int PARAM_MAX_POSITION = 2;

   String return_value;
   std::string sql_query = "SELECT bot_info.position, player.name, bot_info.ranking, bot_info.bot_ID_PK"
            + (std::string)"  FROM (SELECT ROW_NUMBER() OVER(ORDER BY bot.ranking DESC) AS position,"
            + (std::string)"               bot.ranking,"
            + (std::string)"               bot.bot_ID_PK, bot.player_ID_FK"
            + (std::string)"          FROM javafalls.bot"
            + (std::string)"       ) bot_info"
            + (std::string)"  JOIN javafalls.player"
            + (std::string)"    ON player_ID_PK = bot_info.player_ID_FK"
            + (std::string)" WHERE bot_info.position BETWEEN ? AND ?"
            + (std::string)" ORDER BY bot_info.position";
   SQLHSTMT sql_statement = create_command(sql_query);
   bind_parameter(sql_statement, PARAM_MIN_POSITION, &min_position);
   bind_parameter(sql_statement, PARAM_MAX_POSITION, &max_position);
   execute(sql_statement);
   return_value = get_results(sql_statement);
   destroy_command(sql_statement);
   return return_value;
}

// Get all the bots that a player has
String DBConnector::get_player_bots(int player_ID) {
   const int PARAM_PLAYER_ID = 1;

   String return_value;
   std::string sql_query = "SELECT (STUFF((SELECT ',' + CONVERT(varchar, bot.bot_ID_PK)"
            + (std::string)"                 FROM javafalls.bot"
            + (std::string)"                WHERE bot.player_ID_FK = ?"
            + (std::string)"                ORDER BY bot.player_ID_FK"
            + (std::string)"                  FOR XML PATH('')), 1, LEN(','), '')) + ',' AS player_bots";
   SQLHSTMT sql_statement = create_command(sql_query);
   bind_parameter(sql_statement, PARAM_PLAYER_ID, &player_ID);
   execute(sql_statement);
   return_value = get_results(sql_statement);
   destroy_command(sql_statement);
   return return_value;
}

// Get name parts for username login screen
String DBConnector::get_name_parts(int section) {
   const int PARAM_SECTION = 1;

   String return_value;
   std::string sql_query = "SELECT player_name.name"
            + (std::string)"  FROM javafalls.player_name"
            + (std::string)" WHERE player_name.section = ?";
   SQLHSTMT sql_statement = create_command(sql_query);
   bind_parameter(sql_statement, PARAM_SECTION, &section);
   execute(sql_statement);
   return_value = get_results(sql_statement);
   destroy_command(sql_statement);
   return return_value;
}

/***********************************************************************************************************
/ DB Interaction Helpers
/***********************************************************************************************************/
// Stores into the database the ai model found at FILEPATH_IN_MODEL.
// Params:
//  sql_statement = A statement to insert the model into the database. Any and all bind parameters other then the model should already be bound.
//  param_model   = The parameter number in the sql_statement that tells the code where to place the ai model into the query
// Notes: store_model calls destory_command(sql_statement) when it is finished. So you do not need to (and should not) call destory_command yourself on the statement passed to store_model().
int DBConnector::store_model(SQLHSTMT sql_statement, int param_model, String model_file_name) {
   SQLCHAR       *file_data;
   SQLCHAR       *p_file_data; // Used to walk through the fileData
   SQLLEN        file_length = 0;
   char          data_byte;
   std::ifstream in_stream;
   std::string   filepath = FILEPATH_MODEL_FOLDER + std::string(model_file_name.ascii().get_data());
   // 1. Read the model file into memory
   // Allocate space to store the file in memory
   try {
      file_data = new SQLCHAR[COLUMN_DATA_BUFFER];
      p_file_data = file_data;
   }
   catch (std::bad_alloc exception) {
      std::cout << "store_model() - Could not allocate space to store file in memory.\n";
      destroy_command(sql_statement);
      return FALSE;
   }
   // Open the file and read its data
   in_stream.open(filepath, std::ios::in | std::ios::binary);
   if (!in_stream) {
      std::cout << "store_model() - Could not find " << filepath << "\n";
      delete[] file_data;
      destroy_command(sql_statement);
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
   in_stream.close();

   // 2. Store data in the database
   if(!SQL_SUCCEEDED(last_return = SQLBindParameter(sql_statement,
                                                    (SQLSMALLINT)param_model,
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
int DBConnector::get_model_by_sql(SQLHSTMT sql_statement, String model_file_name) {
   SQLLEN        indicator;  // Value returned by SQLGetData to tell us if the data is null or how many bytes the data is
   char          *model_data; // 1 MB buffer that will store in memory the model from the database
   std::ofstream out_stream;  // Output stream to write the model to the disk
   int           return_value = TRUE;
   std::string   filepath = FILEPATH_MODEL_FOLDER + std::string(model_file_name.ascii().get_data());
   // 1. Allocate space for the model in memory
   try {
      model_data = new char[COLUMN_DATA_BUFFER];
   }
   catch (std::bad_alloc exception) {
      std::cout << "get_model_by_sql() - Allocation failure for modelData, trying to allocate space for " << COLUMN_DATA_BUFFER << " characters\n";
      return FALSE;
   }
   // 2. Load the model from the database into memory
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
         out_stream.open(filepath, std::ios::out | std::ios::binary);
         if (out_stream) {
            for (int i = 0; i < indicator; i++) {
               out_stream.put(model_data[i]);
            }
            out_stream.close();
         }
         else {
            std::cout << "get_model_by_sql() - unable to open " << filepath << " to write model to.\n";
            return_value = FALSE;
         }
      }
      else if (last_return != SQL_NO_DATA) {
         print_error_diagnostics("get_model_by_sql()", SQL_HANDLE_STMT, sql_statement);
         return_value = FALSE;
      }
   }
   else if (last_return != SQL_NO_DATA) {
      print_error_diagnostics("get_model_by_sql()", SQL_HANDLE_STMT, sql_statement);
      return_value = FALSE;
   }
   destroy_command(sql_statement);

   delete[] model_data;
   return return_value;
}
int DBConnector::get_row(SQLHSTMT sql_statement_handle) {
   return SQL_SUCCEEDED(last_return = SQLFetch(sql_statement_handle));
}
int DBConnector::get_int_attribute(SQLHSTMT sql_statement_handle, int column_number) { // column_numbers start at 1
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
   if (debug_sql) {
      std::cout << sql_string << '\n';
   }
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
// Binds a value to a parameter. Overloaded to handle both character and integer values.
// sql_statement_handle = the already initialized handle to bind the parameter value to.
// param_number = parameter number, ordered sequentially in increasing parameter order, starting at 1.
// param_value = the value to bind to the parameter
void DBConnector::bind_parameter(SQLHSTMT sql_statement_handle, int param_number, std::string *param_value, SQLSMALLINT param_input_output_type) {
   if (SQL_SUCCEEDED(last_return = SQLBindParameter(sql_statement_handle,                //SQLHSTMT        StatementHandle,
                                                    (SQLSMALLINT)param_number,           //SQLUSMALLINT    ParameterNumber,
                                                    param_input_output_type,             //SQLSMALLINT     InputOutputType,
                                                    SQL_C_CHAR,                          //SQLSMALLINT     ValueType,
                                                    SQL_VARCHAR,                         //SQLSMALLINT     ParameterType,
                                                    90,                                  //SQLULEN         ColumnSize,
                                                    0, // Ignored for varchar parameters //SQLSMALLINT     DecimalDigits,
                                                    (SQLPOINTER)param_value->c_str(),    //SQLPOINTER      ParameterValuePtr,
                                                    param_value->length(),               //SQLLEN          BufferLength,
                                                    &null_terminated_string))) {         //SQLLEN *        StrLen_or_IndPtr)
      return;
   }
   else {
      print_error_diagnostics("bind_parameter(SQLHSTMT, int, std::string, int)", SQL_HANDLE_STMT, sql_statement_handle);
   }
   return;
}
void DBConnector::bind_parameter(SQLHSTMT sql_statement_handle, int param_number, int *param_value, SQLSMALLINT param_input_output_type) {
   if (SQL_SUCCEEDED(last_return = SQLBindParameter(sql_statement_handle,                //SQLHSTMT        StatementHandle,
                                                    (SQLSMALLINT)param_number,           //SQLUSMALLINT    ParameterNumber,
                                                    param_input_output_type,             //SQLSMALLINT     InputOutputType,
                                                    SQL_C_SLONG,                         //SQLSMALLINT     ValueType,
                                                    SQL_INTEGER,                         //SQLSMALLINT     ParameterType,
                                                    0, // Ignored for integer parameters //SQLULEN         ColumnSize,
                                                    0, // Ignored for integer parameters //SQLSMALLINT     DecimalDigits,
                                                    (SQLPOINTER)param_value,             //SQLPOINTER      ParameterValuePtr,
                                                    0, // Ignored for integer parameters //SQLLEN          BufferLength,
                                                    &null_terminated_string))) {         //SQLLEN *        StrLen_or_IndPtr)
      return;
   }
   else {
      print_error_diagnostics("bind_parameter(SQLHSTMT, int, int, int)", SQL_HANDLE_STMT, sql_statement_handle);
   }
   return;
}
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
         return "";
      }
      try {
         col_data_types = new SQLSMALLINT[number_of_columns + 1]; // Allocate 1 extra spot to account for the fact that array indices start at 0 while column numbers start at 1
      }
      catch (std::bad_alloc exception) {
         delete[] col_names;
         std::cout << "get_results() - Allocation failure for colDataTypes, trying to allocate space for " << number_of_columns << " SQLSMALLINTs\n";
         return "";
      }
      try {
         col_data = new char[COLUMN_DATA_BUFFER];
      }
      catch (std::bad_alloc exception) {
         delete[] col_names;
         delete[] col_data_types;
         std::cout << "get_results() - Allocation failure for colData, trying to allocate space for 1048576 characters\n";
         return "";
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
            else {
               return "";
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
   // See GODOT documentation for _bind_methods() at: http://docs.godotengine.org/en/3.0/development/cpp/object_class.html

   // Constants
   BIND_CONSTANT(NULL_COLOR);
   BIND_CONSTANT(NULL_INT);

   BIND_CONSTANT(NEW_BOT_ARGS_MODEL_ID);
   BIND_CONSTANT(NEW_BOT_ARGS_PRIMARY_WEAPON);
   BIND_CONSTANT(NEW_BOT_ARGS_SECONDARY_WEAPON);
   BIND_CONSTANT(NEW_BOT_ARGS_UTILITY);
   BIND_CONSTANT(NEW_BOT_ARGS_PRIMARY_COLOR);
   BIND_CONSTANT(NEW_BOT_ARGS_SECONDARY_COLOR);
   BIND_CONSTANT(NEW_BOT_ARGS_ACCENT_COLOR);
   BIND_CONSTANT(NEW_BOT_ARGS_ANIMATION);
   BIND_CONSTANT(NEW_BOT_ARGS_ARRAY_SIZE);

   BIND_CONSTANT(UPDATE_BOT_ARGS_PLAYER_ID);
   BIND_CONSTANT(UPDATE_BOT_ARGS_MODEL_ID);
   BIND_CONSTANT(UPDATE_BOT_ARGS_RANKING);
   BIND_CONSTANT(UPDATE_BOT_ARGS_PRIMARY_WEAPON);
   BIND_CONSTANT(UPDATE_BOT_ARGS_SECONDARY_WEAPON);
   BIND_CONSTANT(UPDATE_BOT_ARGS_UTILITY);
   BIND_CONSTANT(UPDATE_BOT_ARGS_PRIMARY_COLOR);
   BIND_CONSTANT(UPDATE_BOT_ARGS_SECONDARY_COLOR);
   BIND_CONSTANT(UPDATE_BOT_ARGS_ACCENT_COLOR);
   BIND_CONSTANT(UPDATE_BOT_ARGS_ANIMATION);
   BIND_CONSTANT(UPDATE_BOT_ARGS_ARRAY_SIZE);

   // Methods
   ClassDB::bind_method(D_METHOD("new_player", "name"), &DBConnector::new_player);
   ClassDB::bind_method(D_METHOD("update_player", "player_ID", "name"), &DBConnector::update_player);
   ClassDB::bind_method(D_METHOD("get_player", "player_ID"), &DBConnector::get_player);

   ClassDB::bind_method(D_METHOD("new_bot", "player_ID", "new_bot_args", "name"), &DBConnector::new_bot);
   ClassDB::bind_method(D_METHOD("update_bot", "bot_ID", "update_bot_args", "name", "model_file_name"), &DBConnector::update_bot, (Variant)DEFVAL(""));
   ClassDB::bind_method(D_METHOD("get_bot", "bot_ID", "model_file_name"), &DBConnector::get_bot, (Variant)DEFVAL(""));

   ClassDB::bind_method(D_METHOD("new_model", "player_ID", "model_file_name"), &DBConnector::new_model);
   ClassDB::bind_method(D_METHOD("update_model", "model_ID", "model_file_name"), &DBConnector::update_model);
   ClassDB::bind_method(D_METHOD("update_model_by_bot_id", "bot_ID", "model_file_name"), &DBConnector::update_model_by_bot_id);
   ClassDB::bind_method(D_METHOD("get_model", "model_ID", "model_file_name"), &DBConnector::get_model);
   ClassDB::bind_method(D_METHOD("get_model_by_bot_id", "bot_ID", "model_file_name"), &DBConnector::get_model_by_bot_id);

   ClassDB::bind_method(D_METHOD("get_bot_range", "bot_id", "min_score", "max_score"), &DBConnector::get_bot_range);
   ClassDB::bind_method(D_METHOD("get_max_score"), &DBConnector::get_max_score);
   ClassDB::bind_method(D_METHOD("get_min_score"), &DBConnector::get_min_score);
   ClassDB::bind_method(D_METHOD("get_scoreboard_top_ten"), &DBConnector::get_scoreboard_top_ten);
   ClassDB::bind_method(D_METHOD("get_scoreboard_position", "bot_id"), &DBConnector::get_scoreboard_position);
   ClassDB::bind_method(D_METHOD("get_scoreboard_range", "min_position", "max_position"), &DBConnector::get_scoreboard_range);

   ClassDB::bind_method(D_METHOD("get_player_bots", "player_ID"), &DBConnector::get_player_bots);
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
   debug_sql = FALSE;
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
   else {
      std::cout << "Connection override not found. Using default connection string\n";
   }
   in_stream.close();

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
