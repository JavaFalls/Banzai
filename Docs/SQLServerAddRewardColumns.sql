-- Updates the DB to store reward modifiers on the model
USE [SEI_Javafalls]
BEGIN TRANSACTION
GO
ALTER TABLE javafalls.ai_model ADD
   reward_accuracy int NOT NULL DEFAULT 10,
   reward_avoidence int NOT NULL DEFAULT 10,
   reward_approach int NOT NULL DEFAULT 0,
   reward_flee int NOT NULL DEFAULT 0,
   reward_damage_dealt int NOT NULL DEFAULT 10,
   reward_damage_received int NOT NULL DEFAULT 10,
   reward_health_received int NOT NULL DEFAULT 10,
   reward_melee_damage int NOT NULL DEFAULT 10
GO
COMMIT
