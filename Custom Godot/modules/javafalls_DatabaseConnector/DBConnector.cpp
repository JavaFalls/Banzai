// Please see corresponding header file ("DBConnector.h") for function documentation.

#include "DBConnector.h"
#include "windows.h"
#include "sql.h"
#include "sqlext.h"
#include <string>
#include <iostream>

using namespace std;

#define TRUE 1
#define FALSE 0

/***********************************************************************************************************
/ Connection Management Functions
/***********************************************************************************************************/
int DBConnector::OpenConnection() {
   SQLSMALLINT idc; // We don't care about this value
   // Open a connection, but only if the environment handle is valid
   if(!connectionOpen){
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

void DBConnector::Commit() {
   if (connectionOpen) {
      if (!SQL_SUCCEEDED(lastReturn = SQLEndTran(SQL_HANDLE_DBC,
                                                 conHandle,
                                                 SQL_COMMIT))) {
         PrintErrorDiagnostics("Commit()", SQL_HANDLE_DBC, conHandle);
      }
   }
   return;
}

void DBConnector::Rollback() {
   if (connectionOpen) {
      if (!SQL_SUCCEEDED(lastReturn = SQLEndTran(SQL_HANDLE_DBC,
                                                 conHandle,
                                                 SQL_ROLLBACK))) {
         PrintErrorDiagnostics("Rollback()", SQL_HANDLE_DBC, conHandle);
      }
   }
   return;
}

/***********************************************************************************************************
/ Database Query Functions
/***********************************************************************************************************/
SQLHSTMT DBConnector::CreateCommand(string sqlString) {
   SQLHSTMT sqlStatmentHandle;
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
   while(!SQL_SUCCEEDED(lastReturn = SQLFreeHandle(SQL_HANDLE_STMT, sqlStatementHandle)) && tries < 1000) tries++;
}

// Note: SQLDescribeParam could come in handy here to get some/most of the data required for SQLBindParameter
//void DBConnector::BindParameter(SQLHSTMT sqlStatementHandle, int paramNumber, string paramValue, int paramType) {
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

string DBConnector::GetResults(SQLHSTMT sqlStatementHandle) {
   string      jsonResult = ""; // Used to store the JSON string that will be returned
   int         rowNumber = 1;   // Number of the row we are currently fetching
   int         i;               // Number of the column we are currently getting
   SQLLEN      indicator;       // Value returned by SQLGetData to tell us if the data is null or how many bytes the data is
   char        *colData;        // 1 MB Buffer to an individual column's data. Allocated on the heap to avoid a stack overflow
   SQLSMALLINT numberOfColumns; // How many columns are returned by the fetch
   string      *colNames;       // An array to the names of each column
   SQLSMALLINT *colDataTypes;   // An array to the data types of each column
   if (connectionOpen) {
      // Get number of columns in the result set
      SQLNumResultCols(sqlStatementHandle, &numberOfColumns);
      // Allocate space to store information about those columns
      try {
         colNames = new string[numberOfColumns+1]; // Allocate 1 extra spot to account for the fact that array indices start at 0 while column numbers start at 1
      }
      catch (bad_alloc exception) {
         cout << "GetResults() - Allocation failure for colNames, trying to allocate space for " << numberOfColumns << " objects\n";
         return jsonResult;
      }
      try {
         colDataTypes = new SQLSMALLINT[numberOfColumns+1]; // Allocate 1 extra spot to account for the fact that array indices start at 0 while column numbers start at 1
      }
      catch (bad_alloc exception) {
         delete[] colNames;
         cout << "GetResults() - Allocation failure for colDataTypes, trying to allocate space for " << numberOfColumns << " SQLSMALLINTs\n";
         return jsonResult;
      }
      try {
         colData = new char[COLUMN_DATA_BUFFER];
      }
      catch (bad_alloc exception) {
         delete[] colNames;
         delete[] colDataTypes;
         cout << "GetResults() - Allocation failure for colData, trying to allocate space for 1048576 characters\n";
         return jsonResult;
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
   return jsonResult;
}

/***********************************************************************************************************
/ GDScript Connector Functions
/***********************************************************************************************************/
// Required by Godot, use to bind c++ methods into things that can be seen by GDScript
void DBConnector::_bind_methods() {
   ClassDB::bind_method(D_METHOD("OpenConnection"), &DBConnector::OpenConnection);
   ClassDB::bind_method(D_METHOD("CloseConnection"), &DBConnector::CloseConnection);
   ClassDB::bind_method(D_METHOD("Commit"), &DBConnector::Commit);
   ClassDB::bind_method(D_METHOD("Rollback"), &DBConnector::Rollback);
//   ClassDB::bind_method(D_METHOD("CreateCommand", "sqlString"), &DBConnector::CreateCommand);
//   ClassDB::bind_method(D_METHOD("DestroyCommand", "sqlStatmentHandle"), &DBConnector::DestroyCommand);
//   ClassDB::bind_method(D_METHOD("Execute", "sqlStatementHandle"), &DBConnector::Execute);
//   ClassDB::bind_method(D_METHOD("GetResults", "sqlStatementHandle"), &DBConnector::GetResults);
//   ClassDB::bind_method(D_METHOD("PrintErrorDiagnostics", "functionName", "handleType", "handle"), &DBConnector::PrintErrorDiagnostics);
}

/***********************************************************************************************************
/ Constructors and Destructors
/***********************************************************************************************************/
DBConnector::DBConnector() {
   // Initialize basic values
   conString = TESTConnectionString;
   connectionOpen = FALSE;
   lastReturn = SQL_ERROR;
   envHandle = SQL_NULL_HANDLE;
   conHandle = SQL_NULL_HANDLE;

   // Allocate an environment handle
   if (SQL_SUCCEEDED(lastReturn = SQLAllocHandle(SQL_HANDLE_ENV, SQL_NULL_HANDLE, &envHandle))) {
      // Set up the environment attributes
      lastReturn = SQLSetEnvAttr(envHandle, SQL_ATTR_ODBC_VERSION, (void *)SQL_OV_ODBC3, 0);
      lastReturn = SQLAllocHandle(SQL_HANDLE_DBC, envHandle, &conHandle); // TODO: Possible crash and burn spot
   } else {
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
void DBConnector::PrintErrorDiagnostics(string functionName, SQLSMALLINT handleType, SQLHANDLE handle) {
   const SQLSMALLINT BUFFER_LENGTH = 1024;
   SQLSMALLINT recordNumber = 1;

   SQLCHAR state[6];
   SQLINTEGER p_Error;
   SQLCHAR message[BUFFER_LENGTH];
   SQLSMALLINT actualMessageLength;

   cout << "--------------------------------------------------------\n";
   cout << functionName << " failed. Printing diagnostic information\n";
   if (handle == SQL_NULL_HANDLE) { cout << "NULL HANDLE DETECTED\n"; }
   while(SQL_SUCCEEDED(SQLGetDiagRec(handleType,
                                     handle,
                                     recordNumber,
                                     state,
                                     &p_Error,
                                     message,
                                     BUFFER_LENGTH,
                                     &actualMessageLength))) {
      cout << "#" << recordNumber << ": " << state << " - " << message << "\n";
      recordNumber++;
   }
   cout << functionName << " end diagonstic information\n";
   cout << "--------------------------------------------------------\n";

   //SQLRETURN SQLGetDiagRec(HandleType, Handle,
   //   SQLSMALLINT     HandleType,
   //   SQLHANDLE       Handle,
   //   SQLSMALLINT     RecNumber,
   //   SQLCHAR *       SQLState,
   //   SQLINTEGER *    NativeErrorPtr,
   //   SQLCHAR *       MessageText,
   //   SQLSMALLINT     BufferLength,
   //   SQLSMALLINT *   TextLengthPtr);
   return;
}

void DBConnector::GetColumnInformation(SQLHSTMT sqlStatementHandle, int columnNumber, string *p_columnName, SQLSMALLINT *p_DataType) {
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
