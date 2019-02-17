------------- Add Colors Fields to Bot Table -------------
USE [SEI_JavaFalls]
BEGIN TRANSACTION
GO
ALTER TABLE javafalls.bot ADD
            primary_color int NULL,
            secondary_color int NULL
COMMIT
GO