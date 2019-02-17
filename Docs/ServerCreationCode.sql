CREATE SCHEMA `javafalls` DEFAULT CHARACTER SET ascii ;

CREATE TABLE `javafalls`.`player` (
  `player_ID_PK` INT UNSIGNED NOT NULL,
  `network_ID` INT NOT NULL,
  `name` VARCHAR(45) NULL,
  PRIMARY KEY (`player_ID_PK`),
  UNIQUE INDEX `model_ID_PK_UNIQUE` (`player_ID_PK` ASC) VISIBLE);
ALTER TABLE `javafalls`.`player` 
CHANGE COLUMN `network_ID` `network_ID` INT(11) NOT NULL COMMENT 'The network_ID used by Godot to distinguish between different clients.' ,
CHANGE COLUMN `name` `name` VARCHAR(45) NULL DEFAULT NULL COMMENT 'The gamer name that the player chooses to go by' , COMMENT = 'Stores players that have played the game. Essentially these are more like session IDs since we do not actually store a username and password for a player. But make sure that at least each client is kept distinct from each other. Ideally it will also distinguish between individual users at a client.' ;

CREATE TABLE `javafalls`.`ai_model` (
  `model_ID_PK` INT UNSIGNED NOT NULL,
  `player_ID_FK` INT UNSIGNED NOT NULL COMMENT 'The player that initially created the model',
  `model` BLOB NOT NULL COMMENT 'The model itself. Consult with the AI experts for information on how to read the file stored in the BLOB.',
  `preferred_primary_weapon` INT NULL COMMENT 'The primary weapon that this model is most comfortable using (the one it was trained on presumably).',
  `preferred_secondary_weapon` INT NULL COMMENT 'The secondary weapon that this model is most comfortable using (the one it was trained on presumably).',
  `preferred_utility` INT NULL COMMENT 'The utility that this model is most comfortable using (the one it was trained on presumably).',
  PRIMARY KEY (`model_ID_PK`),
  UNIQUE INDEX `model_ID_PK_UNIQUE` (`model_ID_PK` ASC) VISIBLE)
COMMENT = 'Stores all of the different AI models used by the bots';

ALTER TABLE `javafalls`.`ai_model` 
ADD INDEX `AI_MODEL_player_ID_FK_INDEX` (`player_ID_FK` ASC) COMMENT 'Search by player' INVISIBLE;
;
ALTER TABLE `javafalls`.`ai_model` 
ADD CONSTRAINT `CONSTRAINT_AI_MODEL_player_id_FK`
  FOREIGN KEY (`player_ID_FK`)
  REFERENCES `javafalls`.`player` (`player_ID_PK`)
  ON DELETE NO ACTION
  ON UPDATE NO ACTION;

CREATE TABLE `javafalls`.`bot` (
  `bot_ID_PK` INT UNSIGNED NOT NULL,
  `player_ID_FK` INT UNSIGNED NOT NULL COMMENT 'The player that owns this bot',
  `model_ID_FK` INT UNSIGNED NULL COMMENT 'The ID of the AI that controls this bot.',
  `primary_weapon` INT NULL COMMENT 'The ID# of the primary weapon this bot uses.',
  `secondary_weapon` INT NULL COMMENT 'The ID# of the secondary weapon this bot uses.',
  `utility` INT NULL COMMENT 'The ID# of the utility or special ability that this bot uses.',
  `ranking` INT NOT NULL DEFAULT 0 COMMENT 'The bots current score in the ranking system.',
  PRIMARY KEY (`bot_ID_PK`),
  UNIQUE INDEX `bot_ID_PK_UNIQUE` (`bot_ID_PK` ASC) VISIBLE,
  INDEX `BOT_player_ID_FK_INDEX` (`player_ID_FK` ASC) COMMENT 'Search bots owned by player.' VISIBLE,
  INDEX `CONSTRAINT_model_ID_FK_idx` (`model_ID_FK` ASC) VISIBLE,
  CONSTRAINT `CONSTRAINT_BOT_player_ID_FK`
    FOREIGN KEY (`player_ID_FK`)
    REFERENCES `javafalls`.`player` (`player_ID_PK`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `CONSTRAINT_BOT_model_ID_FK`
    FOREIGN KEY (`model_ID_FK`)
    REFERENCES `javafalls`.`ai_model` (`model_ID_PK`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
COMMENT = 'Information about a bots current standing in the ranking system, the weapons it uses, and the AI that controls it.';
