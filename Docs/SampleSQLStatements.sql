-- DML For player table:
INSERT INTO javafalls.player
            (player_ID_PK, network_ID, name)
     VALUES (2,
             0987654321,
             'Sammy');

-- DML for ai_model table:
INSERT INTO javafalls.ai_model
            (model_ID_PK, player_ID_FK, model)
     VALUES (1, 1, load_file('C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/my_model1.h5'));