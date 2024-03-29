/*
   Wednesday, April 3, 20192:30:09 PM
   User: 
   Server: ADAM-LAPTOP\JFTESTSERVER
   Database: SEI_JavaFalls
   Application: 
*/

/* To prevent any potential data loss issues, you should review this script in detail before running it outside the context of the database designer.*/
BEGIN TRANSACTION
GO
ALTER TABLE javafalls.player ADD
	datetime_login datetime NULL,
   datetime_logout datetime NULL
GO
ALTER TABLE javafalls.player ADD CONSTRAINT
	DF_player_date_created DEFAULT getdate() FOR datetime_login
GO
ALTER TABLE javafalls.player SET (LOCK_ESCALATION = TABLE)
GO
COMMIT
