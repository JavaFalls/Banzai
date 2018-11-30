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
#define INSERTMECH_ARGS_MODEL_ID 0
#define INSERTMECH_ARGS_PRIMARY_WEAPON 1
#define INSERTMECH_ARGS_SECONDARY_WEAPON 2
#define INSERTMECH_ARGS_UTILITY 3
#define ARRAY_SIZE_INSERTMECH_ARGS 4
#define UPDATEMECH_ARGS_PLAYER_ID 0
#define UPDATEMECH_ARGS_MODEL_ID 1
#define UPDATEMECH_ARGS_RANKING 2
#define UPDATEMECH_ARGS_PRIMARY_WEAPON 3
#define UPDATEMECH_ARGS_SECONDARY_WEAPON 4
#define UPDATEMECH_ARGS_UTILITY 5
#define ARRAY_SIZE_UPDATEMECH_ARGS 6

/***********************************************************************************************************
/ Connection Management Functions
/***********************************************************************************************************/
int DBConnector::OpenConnection() {
   SQLSMALLINT idc; // We don't care about this value
                    // Open a connection, but only if the environment handle is valid
   if (!connectionOpen) {
      if (envHandle != SQL_NULL_HANDLE && conHandle != SQL_NULL_HANDLE) {
         if (SQL_SUCCEEDED(lastReturn = SQLDriverConnect(conHandle,
                                                         SQL_NULL_HANDLE, // We are not providing a window handle
                                                         (SQLCHAR *)conString.c_str(),
                                                         SQL_NTS,
                                                         NULL,
                                                         0,
                                                         &idc,
                                                         SQL_DRIVER_NOPROMPT))) {
            connectionOpen = TRUE;
            return TRUE;
         }
         else {
            PrintErrorDiagnostics("OpenConnection()", SQL_HANDLE_DBC, conHandle);
         }
      }
   }
   else {
      // Connection is already open
      return TRUE;
   }
   return FALSE; // Return false to indicate that something didn't happen right
}
int DBConnector::CloseConnection() {
   int tries = 0;
   // Close the connection, unless of course the connection is already closed
   if (conHandle != SQL_NULL_HANDLE) {
      while (!SQL_SUCCEEDED(lastReturn = SQLDisconnect(conHandle)) && tries < 1000) tries++; // If this loop terminates due to hitting the max number of tries we have some serious problems
      if (SQL_SUCCEEDED(lastReturn)) {
         connectionOpen = FALSE;
         return TRUE;
      }
      else {
         PrintErrorDiagnostics("CloseConnection()", SQL_HANDLE_DBC, conHandle);
      }
   }
   return FALSE; // Return false to indicate that something didn't happen right
}
int DBConnector::IsConnectionOpen() {
   return connectionOpen;
}
void DBConnector::Commit() {
   if (!SQL_SUCCEEDED(lastReturn = SQLEndTran(SQL_HANDLE_DBC,
                                              conHandle,
                                              SQL_COMMIT))) {
      PrintErrorDiagnostics("Commit()", SQL_HANDLE_DBC, conHandle);
   }
   return;
}
void DBConnector::Rollback() {
   if (!SQL_SUCCEEDED(lastReturn = SQLEndTran(SQL_HANDLE_DBC,
                                              conHandle,
                                              SQL_ROLLBACK))) {
      PrintErrorDiagnostics("Rollback()", SQL_HANDLE_DBC, conHandle);
   }
   return;
}

/***********************************************************************************************************
/ DB Interaction Commands
/***********************************************************************************************************/
int DBConnector::InsertPlayer(String name) {
   int newPlayerID = FALSE;
   std::string sqlGetNewPlayerID = "SELECT max(player.player_ID_PK)\n"
                    + (std::string)"  FROM javafalls.player player";
   std::string sqlInsert = "INSERT INTO javafalls.player\n"
            + (std::string)"            (name)\n"
            + (std::string)"     VALUES ('" + name.ascii().get_data() + "')";
   SQLHSTMT sqlStatementGetPlayerID = CreateCommand(sqlGetNewPlayerID);
   SQLHSTMT sqlStatementInsert = CreateCommand(sqlInsert);

   Execute(sqlStatementInsert);
   if (SQL_SUCCEEDED(lastReturn)) {
      Execute(sqlStatementGetPlayerID);
      if (FetchRow(sqlStatementGetPlayerID)) {
         if (newPlayerID = FetchIntAttribute(sqlStatementGetPlayerID, 1)) {
            Commit();
         }
         else {
            Rollback();
         }
      }
      else {
         Rollback();
      }
   }
   else {
      Rollback();
   }
   return newPlayerID;
}
int DBConnector::UpdatePlayer(int player_ID, String name) {
   int succeeded = FALSE;
   char player_ID_string[STRING_INT_SIZE];
   sprintf(player_ID_string, "%d", player_ID);
   std::string sqlCode = "UPDATE javafalls.player\n"
          + (std::string)"   SET player.name = '" + name.ascii().get_data() + "'\n"
          + (std::string)" WHERE player.player_ID_PK = " + player_ID_string;
   SQLHSTMT sqlStatement = CreateCommand(sqlCode);
   Execute(sqlStatement);
   if (SQL_SUCCEEDED(lastReturn)) {
      Commit();
      succeeded = TRUE;
   }
   else {
      Rollback();
      succeeded = FALSE;
   }
   DestroyCommand(sqlStatement);
   return succeeded;
}
String DBConnector::FetchPlayer(int player_ID) {
   String returnValue;
   char  player_ID_string[STRING_INT_SIZE];
   sprintf(player_ID_string, "%d", player_ID);
   std::string sqlQuery = "SELECT player.name\n"
           + (std::string)"  FROM javafalls.player player\n"
           + (std::string)" WHERE player.player_ID_PK = " + player_ID_string;
   SQLHSTMT sqlStatement = CreateCommand(sqlQuery);
   Execute(sqlStatement);
   returnValue = GetResults(sqlStatement);
   DestroyCommand(sqlStatement);
   return returnValue;
}

int DBConnector::InsertMech(int player_ID, Array insertMechArgs, String name) {
   SQLHSTMT sqlStatementInsertMech;
   SQLHSTMT sqlStatementGetMechID;
   int newMechID = FALSE;
   char player_ID_string[STRING_INT_SIZE];
   char model_ID_string[STRING_INT_SIZE];
   char primary_weapon_string[STRING_INT_SIZE];
   char secondary_weapon_string[STRING_INT_SIZE];
   char utility_string[STRING_INT_SIZE];
   sprintf(player_ID_string, "%d", player_ID);
   sprintf(model_ID_string, "%d", (int)insertMechArgs[INSERTMECH_ARGS_MODEL_ID]);
   sprintf(primary_weapon_string, "%d", (int)insertMechArgs[INSERTMECH_ARGS_PRIMARY_WEAPON]);
   sprintf(secondary_weapon_string, "%d", (int)insertMechArgs[INSERTMECH_ARGS_SECONDARY_WEAPON]);
   sprintf(utility_string, "%d", (int)insertMechArgs[INSERTMECH_ARGS_UTILITY]);
   std::string sqlGetNewMechID = "SELECT max(mech.mech_ID_PK)\n"
                  + (std::string)"  FROM javafalls.mech mech";
   std::string sqlCode;
   if ((int)insertMechArgs[INSERTMECH_ARGS_MODEL_ID] <= 0) {
      // Model ID not provided, attempt to insert the model into the database ourselves
      insertMechArgs[INSERTMECH_ARGS_MODEL_ID] = (Variant)InsertAIModel(player_ID);
      if (insertMechArgs[INSERTMECH_ARGS_MODEL_ID]) {
         sprintf(model_ID_string, "%d", (int)insertMechArgs[INSERTMECH_ARGS_MODEL_ID]);
      }
      else {
         return FALSE;
      }
   }
   sqlCode      = "INSERT INTO javafalls.mech\n"
   + (std::string)"            (player_ID_FK, model_ID_FK, ranking, name, primary_weapon, secondary_weapon, utility)\n"
   + (std::string)"     VALUES (" + player_ID_string + ", " + model_ID_string + ", 0,'" + name.ascii().get_data() + "', " + primary_weapon_string + ", " + secondary_weapon_string + ", " + utility_string + ")";

   sqlStatementInsertMech = CreateCommand(sqlCode);
   sqlStatementGetMechID  = CreateCommand(sqlGetNewMechID);
   Execute(sqlStatementInsertMech);
   if (SQL_SUCCEEDED(lastReturn)) {
      Execute(sqlStatementGetMechID);
      if (FetchRow(sqlStatementGetMechID)) {
         if (newMechID = FetchIntAttribute(sqlStatementGetMechID, 1)) {
            Commit();
         }
         else {
            Rollback();
         }
      }
      else {
         Rollback();
      }
   }
   else {
      Rollback();
   }
   DestroyCommand(sqlStatementInsertMech);
   DestroyCommand(sqlStatementGetMechID);
   return newMechID;
}
int DBConnector::UpdateMech(int mech_ID, Array updateMechArgs, String name, int updateAIModel) {
   SQLHSTMT sqlStatement;
   char mech_ID_string[STRING_INT_SIZE];
   char player_ID_string[STRING_INT_SIZE];
   char model_ID_string[STRING_INT_SIZE];
   char ranking_string[STRING_INT_SIZE];
   char primary_weapon_string[STRING_INT_SIZE];
   char secondary_weapon_string[STRING_INT_SIZE];
   char utility_string[STRING_INT_SIZE];
   sprintf(mech_ID_string, "%d", mech_ID);
   sprintf(player_ID_string, "%d", (int)updateMechArgs[UPDATEMECH_ARGS_PLAYER_ID]);
   sprintf(model_ID_string, "%d", (int)updateMechArgs[UPDATEMECH_ARGS_MODEL_ID]);
   sprintf(ranking_string, "%d", (int)updateMechArgs[UPDATEMECH_ARGS_RANKING]);
   sprintf(primary_weapon_string, "%d", (int)updateMechArgs[UPDATEMECH_ARGS_PRIMARY_WEAPON]);
   sprintf(secondary_weapon_string, "%d", (int)updateMechArgs[UPDATEMECH_ARGS_SECONDARY_WEAPON]);
   sprintf(utility_string, "%d", (int)updateMechArgs[UPDATEMECH_ARGS_UTILITY]);
   std::string sqlCode = "UPDATE javafalls.mech\n"
          + (std::string)"   SET mech.player_ID_FK     = coalesce(nullif(" + mech_ID_string + ", -1), mech.player_ID_FK)\n"
          + (std::string)"     , mech.model_ID_FK      = coalesce(nullif(" + model_ID_string + ", -1), mech.model_ID_FK)\n"
          + (std::string)"     , mech.ranking          = coalesce(nullif(" + ranking_string + ", -1), mech.ranking)\n"
          + (std::string)"     , mech.name             = coalesce(trim('" + name.ascii().get_data() + "'), mech.name)\n"
          + (std::string)"     , mech.primary_weapon   = coalesce(nullif(" + primary_weapon_string + ", -1), mech.primary_weapon)\n"
          + (std::string)"     , mech.secondary_weapon = coalesce(nullif(" + secondary_weapon_string + ", -1), mech.secondary_weapon)\n"
          + (std::string)"     , mech.utility          = coalesce(nullif(" + utility_string + ", -1), mech.utility)\n"
          + (std::string)" WHERE mech.mech_ID_PK = " + mech_ID_string;

   sqlStatement = CreateCommand(sqlCode);
   Execute(sqlStatement);
   if (SQL_SUCCEEDED(lastReturn)) {
      if (updateAIModel) {
         UpdateAIModelUsingMechID(mech_ID); // Includes a commit or rollback
      }
   }
   else {
      Rollback();
   }
   DestroyCommand(sqlStatement);
   return SQL_SUCCEEDED(lastReturn);
}
String DBConnector::FetchMech(int mech_ID, int fetchModelFile) {
   String returnValue;
   char mech_ID_string[STRING_INT_SIZE];
   sprintf(mech_ID_string, "%d", mech_ID);
   std::string sqlQuery = "SELECT mech.player_ID_FK, mech.model_ID_FK, mech.ranking, mech.name, mech.primary_weapon, mech.secondary_weapon, mech.utility\n"
           + (std::string)"  FROM javafalls.mech mech\n"
           + (std::string)" WHERE mech.mech_ID_PK = " + mech_ID_string;
   SQLHSTMT sqlStatement = CreateCommand(sqlQuery);
   if (fetchModelFile) {
      FetchAIModelUsingMechID(mech_ID);
   }
   Execute(sqlStatement);
   returnValue = GetResults(sqlStatement);
   DestroyCommand(sqlStatement);
   return returnValue;
}

// Returns the model ID (a positive integer) of the newly stored model. Returns 0 if the model could not be inserted.
int DBConnector::InsertAIModel(int player_ID) {
   int newModelID = FALSE;
   char player_ID_string[STRING_INT_SIZE];
   char model_ID_string[STRING_INT_SIZE];
   SQLHSTMT sqlStatementGetModel;
   sprintf(player_ID_string, "%d", player_ID);
   std::string sqlGetNewModelID = "SELECT max(model.model_ID_PK)\n"
                   + (std::string)"  FROM javafalls.ai_model model";
   std::string sqlCode = "INSERT INTO javafalls.ai_model\n"
          + (std::string)"            (player_ID_FK, model)\n"
          + (std::string)"     VALUES (" + player_ID_string + ", ?)\n";

   if (StoreModel(sqlCode)) {
      sqlStatementGetModel = CreateCommand(sqlGetNewModelID);
      Execute(sqlStatementGetModel);
      if (FetchRow(sqlStatementGetModel)) {
         if (newModelID = FetchIntAttribute(sqlStatementGetModel, 1)) {
            Commit();
         }
         else {
            Rollback();
         }
      }
      else {
         Rollback();
      }
      DestroyCommand(sqlStatementGetModel);
   }
   else {
      Rollback();
   }
   return newModelID;
}
int DBConnector::UpdateAIModelUsingModelID(int model_ID) {
   int returnValue;
   char model_ID_string[STRING_INT_SIZE];
   sprintf(model_ID_string, "%d", model_ID);
   std::string sqlCode = "UPDATE javafalls.ai_model\n"
          + (std::string)"   SET ai_model.model = ?\n"
          + (std::string)" WHERE ai_model.model_ID_PK = " + model_ID_string;

   if (returnValue = StoreModel(sqlCode)) {
      Commit();
   }
   else {
      Rollback();
   }
   return returnValue;
}
int DBConnector::UpdateAIModelUsingMechID(int mech_ID) {
   int returnValue;
   char mech_ID_string[STRING_INT_SIZE];
   sprintf(mech_ID_string, "%d", mech_ID);
   std::string sqlCode = "UPDATE javafalls.ai_model\n"
          + (std::string)"   SET ai_model.model = ?\n"
          + (std::string)" WHERE ai_model.model_ID_PK = (SELECT mech.model_ID_FK\n"
          + (std::string)"                                 FROM javafalls.mech\n"
          + (std::string)"                                WHERE mech.mech_ID_PK = " + mech_ID_string + ")";
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

   if (returnValue = StoreModel(sqlCode)) {
      Commit();
   }
   else {
      Rollback();
   }
   return returnValue;
}
int DBConnector::FetchAIModelUsingModelID(int model_ID) {
   char model_ID_string[STRING_INT_SIZE];
   sprintf(model_ID_string, "%d", model_ID);
   std::string sqlQuery = "SELECT model.model\n"
           + (std::string)"  FROM javafalls.ai_model model\n"
           + (std::string)" WHERE model.model_ID_PK = " + model_ID_string;
   return FetchModel(sqlQuery);
}
int DBConnector::FetchAIModelUsingMechID(int mech_ID) {
   char mech_ID_string[STRING_INT_SIZE];
   sprintf(mech_ID_string, "%d", mech_ID);
   std::string sqlQuery = "SELECT model.model\n"
           + (std::string)"  FROM javafalls.ai_model model\n"
           + (std::string)"  JOIN javafalls.mech mech\n"
           + (std::string)"    ON mech.model_ID_FK = model.model_ID_PK\n"
           + (std::string)" WHERE mech.mech_ID_PK = " + mech_ID_string;
   return FetchModel(sqlQuery);
}

/***********************************************************************************************************
/ DB Interaction Helpers
/***********************************************************************************************************/
// Assumes that the sqlCode only contains one bind parameter, and that that parameter is the AI model
int DBConnector::StoreModel(std::string sqlCode) {
   SQLHSTMT      sqlStatement;
   SQLCHAR       *fileData;
   SQLCHAR       *p_FileData; // Used to walk through the fileData
   SQLLEN        fileLength = 0;
   char          dataByte;
   std::ifstream inStream;
   // 1. Read the model file into memory
   // Allocate space to store the file in memory
   try {
      fileData = new SQLCHAR[COLUMN_DATA_BUFFER];
      p_FileData = fileData;
   }
   catch (std::bad_alloc exception) {
      std::cout << "StoreModel() - Could not allocate space to store file in memory.\n";
      return FALSE;
   }
   // Open the file and read its data
   inStream.open(FILEPATH_IN_MODEL, std::ios::in | std::ios::binary);
   if (!inStream) {
      std::cout << "StoreModel() - Could not find file\n";
      delete[] fileData;
      return FALSE;
   }
   while (inStream) {
      inStream.get(dataByte);
      if (inStream) {
         *p_FileData = dataByte;
         p_FileData++;
         fileLength++;
      }
   }
   std::cout << "Bytes read: " << fileLength << "\n";
   inStream.close();

   // 2. Store data in the database
   sqlStatement = CreateCommand(sqlCode);
   if(!SQL_SUCCEEDED(lastReturn = SQLBindParameter(sqlStatement,
                                                   1,
                                                   SQL_PARAM_INPUT,
                                                   SQL_C_BINARY,
                                                   SQL_LONGVARBINARY,
                                                   BLOB_MAX,
                                                   0,
                                                   fileData,
                                                   fileLength,
                                                   &fileLength))) {
      PrintErrorDiagnostics("StoreModel()", SQL_HANDLE_STMT, sqlStatement);
   }
   Execute(sqlStatement);
   if (SQL_SUCCEEDED(lastReturn)) {
      Commit();
   }
   else {
      Rollback();
   }
   DestroyCommand(sqlStatement);
   delete[] fileData;
   return SQL_SUCCEEDED(lastReturn);
}
int DBConnector::FetchModel(std::string sqlQuery) {
   SQLHSTMT      sqlStatement;
   SQLLEN        indicator;  // Value returned by SQLGetData to tell us if the data is null or how many bytes the data is
   char          *modelData; // 1 MB buffer that will store in memory the model from the database
   std::ofstream outStream;  // Output stream to write the model to the disk
   // 1. Allocate space for the model in memory
   try {
      modelData = new char[COLUMN_DATA_BUFFER];
   }
   catch (std::bad_alloc exception) {
      std::cout << "FetchModel() - Allocation failure for modelData, trying to allocate space for " << COLUMN_DATA_BUFFER << " characters\n";
      return FALSE;
   }
   // 2. Load the model from the database into memory
   sqlStatement = CreateCommand(sqlQuery);
   Execute(sqlStatement);
   // Get the row
   if (SQL_SUCCEEDED(lastReturn = SQLFetch(sqlStatement))) {
      // Get the column
      if (SQL_SUCCEEDED(lastReturn = SQLGetData(sqlStatement,
                                                1,
                                                SQL_C_BINARY,
                                                modelData,
                                                COLUMN_DATA_BUFFER,
                                                &indicator))) {
         // 3. Write the model from memory to a file
         outStream.open(FILEPATH_OUT_MODEL, std::ios::out | std::ios::binary);
         if (outStream) {
            for (int i = 0; i < indicator; i++) {
               outStream.put(modelData[i]);
            }
         }
         else {
            std::cout << "FetchModel() - unable to open file to write model to.\n";
            return FALSE;
         }
      }
      else if (lastReturn != SQL_NO_DATA) {
         PrintErrorDiagnostics("FetchModel()", SQL_HANDLE_STMT, sqlStatement);
         return FALSE;
      }
   }
   else if (lastReturn != SQL_NO_DATA) {
      PrintErrorDiagnostics("FetchModel()", SQL_HANDLE_STMT, sqlStatement);
      return FALSE;
   }
   DestroyCommand(sqlStatement);

   delete[] modelData;
   return TRUE;
}
int DBConnector::FetchRow(SQLHSTMT sqlStatementHandle) {
   return SQL_SUCCEEDED(lastReturn = SQLFetch(sqlStatementHandle));
}
int DBConnector::FetchIntAttribute(SQLHSTMT sqlStatementHandle, int columnNumber) {
   int colValue;
   SQLLEN indicator;
   if (SQL_SUCCEEDED(lastReturn = SQLGetData(sqlStatementHandle,
                                             columnNumber,
                                             SQL_C_LONG,
                                             &colValue,
                                             COLUMN_DATA_BUFFER,
                                             &indicator))) {
      return colValue;
   }
   else {
      PrintErrorDiagnostics("FetchIntAttribute()", SQL_HANDLE_STMT, sqlStatementHandle);
   }
   return FALSE;
}


/***********************************************************************************************************
/ Database Query Functions
/***********************************************************************************************************/
SQLHSTMT DBConnector::CreateCommand(std::string sqlString) {
   std::cout << sqlString << '\n';
   SQLHSTMT sqlStatmentHandle;
   // If the connection is currently closed, try to open it
   if (!connectionOpen) {
      OpenConnection();
   }
   if (connectionOpen) {
      // Allocate the statement handle
      if (SQL_SUCCEEDED(lastReturn = SQLAllocHandle(SQL_HANDLE_STMT, conHandle, &sqlStatmentHandle))) {
         // Attach the SQL code to the statement handle
         if (SQL_SUCCEEDED(lastReturn = SQLPrepare(sqlStatmentHandle,
                                                   (SQLCHAR *)sqlString.c_str(),
                                                   SQL_NTS))) {
                                                   return sqlStatmentHandle;
         }
         else {
            PrintErrorDiagnostics("CreateCommand()", SQL_HANDLE_STMT, sqlStatmentHandle);
         }
      }
      else {
         PrintErrorDiagnostics("CreateCommand()", SQL_HANDLE_STMT, sqlStatmentHandle);
      }
   }
   return SQL_NULL_HANDLE;
}
void DBConnector::DestroyCommand(SQLHSTMT sqlStatementHandle) {
   int tries = 0;
   while (!SQL_SUCCEEDED(lastReturn = SQLFreeHandle(SQL_HANDLE_STMT, sqlStatementHandle)) && tries < 1000) tries++;
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
void DBConnector::Execute(SQLHSTMT sqlStatementHandle) {
   if (connectionOpen) {
      if (!SQL_SUCCEEDED(lastReturn = SQLExecute(sqlStatementHandle))) {
         PrintErrorDiagnostics("Execute()", SQL_HANDLE_STMT, sqlStatementHandle);
      }
   }
   return;
}
String DBConnector::GetResults(SQLHSTMT sqlStatementHandle) {
   std::string jsonResult = ""; // Used to store the JSON string that will be returned
   int         rowNumber = 1;   // Number of the row we are currently fetching
   int         i;               // Number of the column we are currently getting
   SQLLEN      indicator;       // Value returned by SQLGetData to tell us if the data is null or how many bytes the data is
   char        *colData;        // 1 MB Buffer to an individual column's data. Allocated on the heap to avoid a stack overflow
   SQLSMALLINT numberOfColumns; // How many columns are returned by the fetch
   std::string *colNames;       // An array to the names of each column
   SQLSMALLINT *colDataTypes;   // An array to the data types of each column
   if (connectionOpen) {
      // Get number of columns in the result set
      SQLNumResultCols(sqlStatementHandle, &numberOfColumns);
      // Allocate space to store information about those columns
      try {
         colNames = new std::string[numberOfColumns + 1]; // Allocate 1 extra spot to account for the fact that array indices start at 0 while column numbers start at 1
      }
      catch (std::bad_alloc exception) {
         std::cout << "GetResults() - Allocation failure for colNames, trying to allocate space for " << numberOfColumns << " objects\n";
         return jsonResult.c_str();
      }
      try {
         colDataTypes = new SQLSMALLINT[numberOfColumns + 1]; // Allocate 1 extra spot to account for the fact that array indices start at 0 while column numbers start at 1
      }
      catch (std::bad_alloc exception) {
         delete[] colNames;
         std::cout << "GetResults() - Allocation failure for colDataTypes, trying to allocate space for " << numberOfColumns << " SQLSMALLINTs\n";
         return jsonResult.c_str();
      }
      try {
         colData = new char[COLUMN_DATA_BUFFER];
      }
      catch (std::bad_alloc exception) {
         delete[] colNames;
         delete[] colDataTypes;
         std::cout << "GetResults() - Allocation failure for colData, trying to allocate space for 1048576 characters\n";
         return jsonResult.c_str();
      }
      // Get column names and data types
      for (i = 1; i <= numberOfColumns; i++) {
         GetColumnInformation(sqlStatementHandle, i, &colNames[i], &colDataTypes[i]);
      }

      // Build JSON result string
      jsonResult = "{\n   \"data\": [\n";
      // Loop through all rows
      while (SQL_SUCCEEDED(lastReturn = SQLFetch(sqlStatementHandle))) {
         if (rowNumber > 1) {
            jsonResult.append(",\n");
         }
         jsonResult.append("       {");
         // Loop through all columns
         for (i = 1; i <= numberOfColumns; i++) {
            if (SQL_SUCCEEDED(lastReturn = SQLGetData(sqlStatementHandle,
                                                      i,
                                                      SQL_C_CHAR,
                                                      colData,
                                                      COLUMN_DATA_BUFFER,
                                                      &indicator))) {
               if (i > 1) { jsonResult.append(","); }
               jsonResult.append(" \"").append(colNames[i]).append("\": ");
               if (indicator == SQL_NULL_DATA) {
                  jsonResult.append("null");
               }
               else {
                  switch (colDataTypes[i]) {
                  case SQL_SMALLINT:
                  case SQL_INTEGER:
                  case SQL_BIT:
                  case SQL_TINYINT:
                  case SQL_BIGINT:
                     // Integers
                     jsonResult.append(colData);
                     break;
                  case SQL_DECIMAL:
                  case SQL_NUMERIC:
                  case SQL_REAL:
                  case SQL_FLOAT:
                  case SQL_DOUBLE:
                     // Doubles
                     jsonResult.append(colData);
                     break;
                  default:
                     // Treat everything else as string data
                     jsonResult.append("\"").append(colData).append("\"");
                     break;
                  }
               }
            }
         }
         jsonResult.append("}");
         rowNumber++;
      }
      jsonResult.append("\n   ]\n}");
      // Free allocated memory
      delete[] colNames;
      delete[] colDataTypes;
      delete[] colData;
   }
   return jsonResult.c_str();
}

/***********************************************************************************************************
/ GDScript Connector Functions
/***********************************************************************************************************/
// Required by Godot, use to bind c++ methods into things that can be seen by GDScript
void DBConnector::_bind_methods() {
   ClassDB::bind_method(D_METHOD("InsertPlayer", "name"), &DBConnector::InsertPlayer);
   ClassDB::bind_method(D_METHOD("UpdatePlayer", "player_ID", "name"), &DBConnector::UpdatePlayer);
   ClassDB::bind_method(D_METHOD("FetchPlayer", "player_ID"), &DBConnector::FetchPlayer);

   ClassDB::bind_method(D_METHOD("InsertMech", "player_ID", "insertMechArgs", "name"), &DBConnector::InsertMech);
   ClassDB::bind_method(D_METHOD("UpdateMech", "mech_ID", "updateMechArgs", "name", "updateAIModel"), &DBConnector::UpdateMech);
   ClassDB::bind_method(D_METHOD("FetchMech", "mech_ID", "fetchModelFile"), &DBConnector::FetchMech);

   ClassDB::bind_method(D_METHOD("InsertAIModel", "player_ID"), &DBConnector::InsertAIModel);
   ClassDB::bind_method(D_METHOD("UpdateAIModelUsingModelID", "model_ID"), &DBConnector::UpdateAIModelUsingModelID);
   ClassDB::bind_method(D_METHOD("UpdateAIModelUsingMechID", "mech_ID"), &DBConnector::UpdateAIModelUsingMechID);
   ClassDB::bind_method(D_METHOD("FetchAIModelUsingModelID", "model_ID"), &DBConnector::FetchAIModelUsingModelID);
   ClassDB::bind_method(D_METHOD("FetchAIModelUsingMechID", "mech_ID"), &DBConnector::FetchAIModelUsingMechID);

   ClassDB::bind_method(D_METHOD("OpenConnection"), &DBConnector::OpenConnection);
   ClassDB::bind_method(D_METHOD("CloseConnection"), &DBConnector::CloseConnection);
   ClassDB::bind_method(D_METHOD("IsConnectionOpen"), &DBConnector::IsConnectionOpen);
}

/***********************************************************************************************************
/ Constructors and Destructors
/***********************************************************************************************************/
DBConnector::DBConnector() {
   // Initialize basic values
   conString = LIVEConnectionString;
   connectionOpen = FALSE;
   lastReturn = SQL_ERROR;
   envHandle = SQL_NULL_HANDLE;
   conHandle = SQL_NULL_HANDLE;

   // Override the default connection string if a DSN file was provided
   std::ifstream inStream;
   std::cout << "Searching for: " << CONNECTION_OVERRIDE_FILENAME << "\n";
   inStream.open(CONNECTION_OVERRIDE_FILENAME, std::ios::in);
   if (inStream) {
      std::cout << CONNECTION_OVERRIDE_FILENAME << " found, overriding default connection string\n";
      char OverrideConnectionString[MAX_CONNECTION_OVERRIDE_FILE_SIZE];
      char *p_OverrideString = OverrideConnectionString;
      char inChar;
      inStream.get(inChar);
      while (inStream) {
         *p_OverrideString = inChar;
         p_OverrideString++;
         inStream.get(inChar);
      }
      conString = OverrideConnectionString;
   }
   inStream.close();
   std::cout << "Connection string being used is: |" << conString << "|\n";

   // Allocate an environment handle
   if (SQL_SUCCEEDED(lastReturn = SQLAllocHandle(SQL_HANDLE_ENV, SQL_NULL_HANDLE, &envHandle))) {
      // Set up the environment attributes
      if (!SQL_SUCCEEDED(lastReturn = SQLSetEnvAttr(envHandle, SQL_ATTR_ODBC_VERSION, (void *)SQL_OV_ODBC3, 0))) {
         PrintErrorDiagnostics("DBConnector()", SQL_HANDLE_ENV, envHandle);
      }
      if (!SQL_SUCCEEDED(lastReturn = SQLAllocHandle(SQL_HANDLE_DBC, envHandle, &conHandle))) {
         PrintErrorDiagnostics("DBConnector()", SQL_HANDLE_DBC, conHandle);
      }
      if (!SQL_SUCCEEDED(lastReturn = SQLSetConnectAttr(conHandle, SQL_ATTR_AUTOCOMMIT, FALSE, 0))) {
         PrintErrorDiagnostics("DBConnector()", SQL_HANDLE_DBC, conHandle);
      }
   }
   else {
      // Crash and burn, but do it gracefully.
      PrintErrorDiagnostics("DBConnector()", SQL_HANDLE_ENV, envHandle);
   }
   return;
}
DBConnector::~DBConnector() {
   int tries = 0;
   // Check if the connection is open, if it is, close it. Ideally we should also notify someone that they failed to close their connection...
   if (connectionOpen == TRUE) {
      CloseConnection();
   }
   // Make sure all of the handles are free
   // Free environment handles
   while (!SQL_SUCCEEDED(lastReturn = SQLFreeHandle(SQL_HANDLE_DBC, conHandle)) && tries < 1000) tries++; // If this loop terminates due to hitting the max number of tries we have some serious problems
   if (!SQL_SUCCEEDED(lastReturn)) {
      PrintErrorDiagnostics("~DBConnector()", SQL_HANDLE_DBC, conHandle);
   }
   tries = 0;
   while (!SQL_SUCCEEDED(lastReturn = SQLFreeHandle(SQL_HANDLE_ENV, envHandle)) && tries < 1000) tries++; // If this loop terminates due to hitting the max number of tries we have some serious problems
   if (!SQL_SUCCEEDED(lastReturn)) {
      PrintErrorDiagnostics("~DBConnector()", SQL_HANDLE_ENV, envHandle);
   }
   return;
}

/***********************************************************************************************************
/ Getters and setters
/***********************************************************************************************************/
SQLRETURN DBConnector::getLastReturnCode() {
   return lastReturn;
}

/***********************************************************************************************************
/ Private Functions
/***********************************************************************************************************/
// Prints to the console and diagnostic records for that handle.
void DBConnector::PrintErrorDiagnostics(std::string functionName, SQLSMALLINT handleType, SQLHANDLE handle) {
   const SQLSMALLINT BUFFER_LENGTH = 1024;
   SQLSMALLINT recordNumber = 1;

   SQLCHAR state[6];
   SQLINTEGER p_Error;
   SQLCHAR message[BUFFER_LENGTH];
   SQLSMALLINT actualMessageLength;

   std::cout << "--------------------------------------------------------\n";
   std::cout << functionName << " failed. Printing diagnostic information\n";
   if (handle == SQL_NULL_HANDLE) { std::cout << "NULL HANDLE DETECTED\n"; }
   while (SQL_SUCCEEDED(SQLGetDiagRec(handleType,
                                      handle,
                                      recordNumber,
                                      state,
                                      &p_Error,
                                      message,
                                      BUFFER_LENGTH,
                                      &actualMessageLength))) {
      std::cout << "#" << recordNumber << ": " << state << " - " << message << "\n";
      recordNumber++;
   }
   std::cout << functionName << " end diagonstic information\n";
   std::cout << "--------------------------------------------------------\n";
   return;
}

void DBConnector::GetColumnInformation(SQLHSTMT sqlStatementHandle, int columnNumber, std::string *p_columnName, SQLSMALLINT *p_DataType) {
   SQLCHAR columnName[256];

   SQLSMALLINT nameLength; // we don't care about this value
   SQLULEN     columnSize; // we don't care about this value
   SQLSMALLINT decimalDigits; // we don't care about this value
   SQLSMALLINT nullable; // we don't care about this value
   if (SQL_SUCCEEDED(lastReturn = SQLDescribeCol(sqlStatementHandle,
                                                 columnNumber,
                                                 columnName,
                                                 256,
                                                 &nameLength,
                                                 p_DataType,
                                                 &columnSize,
                                                 &decimalDigits,
                                                 &nullable
                                                 ))) {
      p_columnName->assign((char*)columnName);
   }
   else {
      PrintErrorDiagnostics("GetColumnInformation()", SQL_HANDLE_STMT, sqlStatementHandle);
   }
   return;
}
