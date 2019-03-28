/* To prevent any potential data loss issues, you should review this script in detail before running it outside the context of the database designer.*/
USE [SEI_JavaFalls]
BEGIN TRANSACTION
GO
ALTER TABLE javafalls.bot
	DROP COLUMN light_color
GO
ALTER TABLE javafalls.bot ADD
	animation varchar(30) NULL
GO
ALTER TABLE javafalls.bot SET (LOCK_ESCALATION = TABLE)
GO
COMMIT