------------------------- CREATE TABLES ------------------------
USE [SEI_JavaFalls]
CREATE SCHEMA [javafalls]
CREATE TABLE javafalls.player
   (player_ID_PK int IDENTITY(1,1) PRIMARY KEY NOT NULL,  
    network_ID   int NULL,  
    name         VARCHAR(90) NULL)

CREATE TABLE javafalls.ai_model
   (model_ID_PK  int IDENTITY(1,1) PRIMARY KEY NOT NULL,  
    player_ID_FK int NOT NULL,  
    model        varbinary(MAX) NOT NULL, -- varbinary(MAX) is SQL Server's equivalent to a BLOB
    CONSTRAINT FK_ai_model_player_ID FOREIGN KEY (player_ID_FK)     
    REFERENCES javafalls.player (player_ID_PK)     
    ON DELETE NO ACTION    
    ON UPDATE NO ACTION);
CREATE NONCLUSTERED INDEX INDEX_ai_model_player_ID_FK
    ON javafalls.ai_model (player_ID_FK);   

CREATE TABLE javafalls.bot
   (bot_ID_PK   int IDENTITY(1,1) PRIMARY KEY NOT NULL,  
    player_ID_FK int NOT NULL,  
    model_ID_FK  int NOT NULL,
    name         VARCHAR(90) NULL,
    primary_weapon INT NULL,
    secondary_weapon INT NULL,
    utility       INT NULL,
    ranking       INT NOT NULL DEFAULT 0,
    primary_color INT NULL,
    secondary_color INT NULL,
    CONSTRAINT FK_bot_player_ID FOREIGN KEY (player_ID_FK)     
    REFERENCES javafalls.player (player_ID_PK)     
    ON DELETE NO ACTION    
    ON UPDATE NO ACTION,
    CONSTRAINT FK_bot_model_ID FOREIGN KEY (model_ID_FK)
    REFERENCES javafalls.ai_model (model_ID_PK)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION);
CREATE NONCLUSTERED INDEX INDEX_bot_player_ID_FK
    ON javafalls.bot (player_ID_FK);  
CREATE NONCLUSTERED INDEX INDEX_bot_model_ID_FK
    ON javafalls.bot (model_ID_FK);

CREATE TABLE javafalls.player_name
   (player_name_PK int IDENTITY(1,1) PRIMARY KEY NOT NULL,
    section        int NOT NULL,
    name           VARCHAR(30) NOT NULL);
CREATE NONCLUSTERED INDEX INDEX_player_name_section
    ON javafalls.player_name (section);
GO

----------------------- CREATE USERS ------------------------------
CREATE LOGIN [sei_JavaFallsLogin] WITH PASSWORD = 'HnjMk,IkoRftOlpOlpTgy32',
                                       DEFAULT_DATABASE = [SEI_JavaFalls];
use [SEI_JavaFalls]
CREATE USER [sei_JavaFallsUser] FOR LOGIN [sei_JavaFallsLogin] WITH DEFAULT_SCHEMA=[javafalls]
GRANT INSERT ON [javafalls].[player] TO [sei_JavaFallsUser]
GRANT SELECT ON [javafalls].[player] TO [sei_JavaFallsUser]
GRANT UPDATE ON [javafalls].[player] TO [sei_JavaFallsUser]
GRANT INSERT ON [javafalls].[ai_model] TO [sei_JavaFallsUser]
GRANT SELECT ON [javafalls].[ai_model] TO [sei_JavaFallsUser]
GRANT UPDATE ON [javafalls].[ai_model] TO [sei_JavaFallsUser]
GRANT INSERT ON [javafalls].[bot] TO [sei_JavaFallsUser]
GRANT SELECT ON [javafalls].[bot] TO [sei_JavaFallsUser]
GRANT UPDATE ON [javafalls].[bot] TO [sei_JavaFallsUser]
GRANT SELECT ON [javafalls].[player_name] TO [sei_JavaFallsUser]
GO