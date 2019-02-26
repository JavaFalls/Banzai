USE [SEI_JavaFalls]
BEGIN TRANSACTION
GO
ALTER TABLE javafalls.bot ADD
            accent_color int NULL,
            light_color int NULL
COMMIT
GO