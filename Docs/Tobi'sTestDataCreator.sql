INSERT INTO SEI_JavaFalls.javafalls.player
            (name)
            (SELECT 'Superplayer'
              UNION ALL
             SELECT 'Happy'
              UNION ALL
             SELECT 'Mechanizer2000'
              UNION ALL
             SELECT 'Meganizer2'
              UNION ALL
             SELECT 'Youth2v'
              UNION ALL
             SELECT 'HAppFish'
              UNION ALL
             SELECT 'CoffeeLake'
              UNION ALL
             SELECT 'HaCk3rz'
              UNION ALL
             SELECT 'Chipmunks'
              UNION ALL
             SELECT 'Sloth');

INSERT INTO SEI_JavaFalls.javafalls.bot
            (player_ID_FK, model_ID_FK, name, ranking)
            (SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Happy'), 1, 'StarterBot1', 0
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Mechanizer2000'), 1, 'StarterBot2', 0
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Meganizer2'), 1, 'StarterBot3', 0
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Youth2v'), 1, 'StarterBot4', 0
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'HAppFish'), 1, 'StarterBot5', 0
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'CoffeeLake'), 1, 'StarterBot6', 0
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'HaCk3rz'), 1, 'StarterBot7', 0
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Chipmunks'), 1, 'StarterBot8', 0
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Sloth'), 1, 'StarterBot9', 0
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Superplayer'), 1, 'StarterBot10', 0
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Happy'), 1, 'StarterBot11', 0
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Mechanizer2000'), 1, 'StarterBot12', 0
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Meganizer2'), 1, 'StarterBot13', 0
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Youth2v'), 1, 'StarterBot14', 0
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'HAppFish'), 1, 'StarterBot15', 0
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'CoffeeLake'), 1, 'StarterBot16', 0
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'HaCk3rz'), 1, 'StarterBot17', 0
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Chipmunks'), 1, 'StarterBot18', 0
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Sloth'), 1, 'StarterBot19', 0
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Superplayer'), 1, 'StarterBot20', 0
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Happy'), 1, 'StarterBot21', 0
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Mechanizer2000'), 1, 'StarterBot23', 0
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Meganizer2'), 1, 'StarterBot24', 0
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Youth2v'), 1, 'StarterBot25', 0
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'HAppFish'), 1, 'StarterBot26', 0
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'CoffeeLake'), 1, 'StarterBot27', 0
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'HaCk3rz'), 1, 'StarterBot28', 0
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Chipmunks'), 1, 'StarterBot29', 0
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Sloth'), 1, 'StarterBot30', 0
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Superplayer'), 1, 'StarterBot31', 0
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Happy'), 1, 'StarterBot32', 0
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Mechanizer2000'), 1, 'StarterBot33', 0
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Meganizer2'), 1, 'StarterBot34', 0
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Youth2v'), 1, 'StarterBot35', 0
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'HAppFish'), 1, 'StarterBot36', 0
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'CoffeeLake'), 1, 'StarterBot37', 0
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'HaCk3rz'), 1, 'StarterBot38', 0
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Chipmunks'), 1, 'StarterBot39', 0
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Sloth'), 1, 'StarterBot40', 0
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Superplayer'), 1, 'StarterBot41', 0
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Happy'), 1, 'StarterBot42', 0
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Mechanizer2000'), 1, 'StarterBot43', 0
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Meganizer2'), 1, 'StarterBot44', 0
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Youth2v'), 1, 'StarterBot45', 0
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'HAppFish'), 1, 'StarterBot46', 0
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'CoffeeLake'), 1, 'StarterBot47', 0
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'HaCk3rz'), 1, 'StarterBot48', 0
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Chipmunks'), 1, 'StarterBot49', 0
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Sloth'), 1, 'StarterBot50', 0
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Superplayer'), 1, 'StarterBot51', 0
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Happy'), 1, 'StarterBot52', 0
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Mechanizer2000'), 1, 'StarterBot53', 0
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Meganizer2'), 1, 'StarterBot54', 0
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Youth2v'), 1, 'StarterBot55', 0
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'HAppFish'), 1, 'StarterBot56', 0
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'CoffeeLake'), 1, 'StarterBot57', 0
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'HaCk3rz'), 1, 'StarterBot58', 0
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Chipmunks'), 1, 'StarterBot59', 0
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Sloth'), 1, 'StarterBot60', 0
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Superplayer'), 1, 'StarterBot61', 0
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Happy'), 1, 'StarterBot62', 0
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Mechanizer2000'), 1, 'StarterBot63', 0
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Meganizer2'), 1, 'StarterBot64', 0
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Youth2v'), 1, 'StarterBot65', 0
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'HAppFish'), 1, 'StarterBot66', 0
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'CoffeeLake'), 1, 'StarterBot67', 0
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'HaCk3rz'), 1, 'StarterBot68', 0
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Chipmunks'), 1, 'StarterBot69', 0
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Sloth'), 1, 'StarterBot70', 0
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Superplayer'), 1, 'StarterBot71', 0
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Happy'), 1, 'StarterBot72', 0
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Mechanizer2000'), 1, 'StarterBot73', 0
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Meganizer2'), 1, 'StarterBot74', 0
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Youth2v'), 1, 'StarterBot75', 0
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'HAppFish'), 1, 'StarterBot76', 0
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'CoffeeLake'), 1, 'StarterBot77', 0
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'HaCk3rz'), 1, 'StarterBot78', 0
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Chipmunks'), 1, 'StarterBot79', 0
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Sloth'), 1, 'StarterBot80', 0
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Superplayer'), 1, 'StarterBot81', 0
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Happy'), 1, 'StarterBot82', 0
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Mechanizer2000'), 1, 'StarterBot83', 0
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Meganizer2'), 1, 'StarterBot84', 0
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Youth2v'), 1, 'StarterBot85', 0
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'HAppFish'), 1, 'StarterBot86', 0
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'CoffeeLake'), 1, 'StarterBot87', 0
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'HaCk3rz'), 1, 'StarterBot88', 0
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Chipmunks'), 1, 'StarterBot89', 0
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Sloth'), 1, 'StarterBot90', 0
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Superplayer'), 1, 'StarterBot91', 0
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Happy'), 1, 'StarterBot92', 0
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Mechanizer2000'), 1, 'StarterBot93', 0
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Meganizer2'), 1, 'StarterBot94', 0
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Youth2v'), 1, 'StarterBot95', 0
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'HAppFish'), 1, 'StarterBot96', 0
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'CoffeeLake'), 1, 'StarterBot97', 0
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'HaCk3rz'), 1, 'StarterBot98', 0
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Chipmunks'), 1, 'StarterBot99', 0
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Sloth'), 1, 'StarterBot100', 0
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Happy'), 1, 'AverageBot1', 250
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Mechanizer2000'), 1, 'AverageBot2', 250
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Meganizer2'), 1, 'AverageBot3', 250
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Youth2v'), 1, 'AverageBot4', 250
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'HAppFish'), 1, 'AverageBot5', 250
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'CoffeeLake'), 1, 'AverageBot6', 250
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'HaCk3rz'), 1, 'AverageBot7', 250
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Chipmunks'), 1, 'AverageBot8', 250
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Sloth'), 1, 'AverageBot9', 250
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Superplayer'), 1, 'AverageBot10', 250
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Happy'), 1, 'AverageBot11', 250
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Mechanizer2000'), 1, 'AverageBot12', 250
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Meganizer2'), 1, 'AverageBot13', 250
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Youth2v'), 1, 'AverageBot14', 250
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'HAppFish'), 1, 'AverageBot15', 250
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'CoffeeLake'), 1, 'AverageBot16', 250
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'HaCk3rz'), 1, 'AverageBot17', 250
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Chipmunks'), 1, 'AverageBot18', 250
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Sloth'), 1, 'AverageBot19', 250
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Superplayer'), 1, 'AverageBot20', 250
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Happy'), 1, 'AverageBot21', 250
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Mechanizer2000'), 1, 'AverageBot23', 250
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Meganizer2'), 1, 'AverageBot24', 250
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Youth2v'), 1, 'AverageBot25', 250
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'HAppFish'), 1, 'AverageBot26', 250
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'CoffeeLake'), 1, 'AverageBot27', 250
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'HaCk3rz'), 1, 'AverageBot28', 250
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Chipmunks'), 1, 'AverageBot29', 250
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Sloth'), 1, 'AverageBot30', 250
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Superplayer'), 1, 'AverageBot31', 250
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Happy'), 1, 'AverageBot32', 250
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Mechanizer2000'), 1, 'AverageBot33', 250
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Meganizer2'), 1, 'AverageBot34', 250
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Youth2v'), 1, 'AverageBot35', 250
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'HAppFish'), 1, 'AverageBot36', 250
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'CoffeeLake'), 1, 'AverageBot37', 250
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'HaCk3rz'), 1, 'AverageBot38', 250
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Chipmunks'), 1, 'AverageBot39', 250
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Sloth'), 1, 'AverageBot40', 250
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Superplayer'), 1, 'AverageBot41', 250
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Happy'), 1, 'AverageBot42', 250
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Mechanizer2000'), 1, 'AverageBot43', 250
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Meganizer2'), 1, 'AverageBot44', 250
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Youth2v'), 1, 'AverageBot45', 250
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'HAppFish'), 1, 'AverageBot46', 250
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'CoffeeLake'), 1, 'AverageBot47', 250
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'HaCk3rz'), 1, 'AverageBot48', 250
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Chipmunks'), 1, 'AverageBot49', 250
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Sloth'), 1, 'AverageBot50', 250
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Superplayer'), 1, 'AverageBot51', 250
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Happy'), 1, 'AverageBot52', 250
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Mechanizer2000'), 1, 'AverageBot53', 250
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Meganizer2'), 1, 'AverageBot54', 250
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Youth2v'), 1, 'AverageBot55', 250
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'HAppFish'), 1, 'AverageBot56', 250
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'CoffeeLake'), 1, 'AverageBot57', 250
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'HaCk3rz'), 1, 'AverageBot58', 250
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Chipmunks'), 1, 'AverageBot59', 250
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Sloth'), 1, 'AverageBot60', 250
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Superplayer'), 1, 'AverageBot61', 250
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Happy'), 1, 'AverageBot62', 250
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Mechanizer2000'), 1, 'AverageBot63', 250
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Meganizer2'), 1, 'AverageBot64', 250
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Youth2v'), 1, 'AverageBot65', 250
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'HAppFish'), 1, 'AverageBot66', 250
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'CoffeeLake'), 1, 'AverageBot67', 250
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'HaCk3rz'), 1, 'AverageBot68', 250
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Chipmunks'), 1, 'AverageBot69', 250
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Sloth'), 1, 'AverageBot70', 250
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Superplayer'), 1, 'AverageBot71', 250
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Happy'), 1, 'AverageBot72', 250
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Mechanizer2000'), 1, 'AverageBot73', 250
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Meganizer2'), 1, 'AverageBot74', 250
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Youth2v'), 1, 'AverageBot75', 250
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'HAppFish'), 1, 'AverageBot76', 250
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'CoffeeLake'), 1, 'AverageBot77', 250
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'HaCk3rz'), 1, 'AverageBot78', 250
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Chipmunks'), 1, 'AverageBot79', 250
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Sloth'), 1, 'AverageBot80', 250
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Superplayer'), 1, 'AverageBot81', 250
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Happy'), 1, 'AverageBot82', 250
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Mechanizer2000'), 1, 'AverageBot83', 250
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Meganizer2'), 1, 'AverageBot84', 250
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Youth2v'), 1, 'AverageBot85', 250
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'HAppFish'), 1, 'AverageBot86', 250
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'CoffeeLake'), 1, 'AverageBot87', 250
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'HaCk3rz'), 1, 'AverageBot88', 250
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Chipmunks'), 1, 'AverageBot89', 250
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Sloth'), 1, 'AverageBot90', 250
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Superplayer'), 1, 'AverageBot91', 250
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Happy'), 1, 'AverageBot92', 250
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Mechanizer2000'), 1, 'AverageBot93', 250
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Meganizer2'), 1, 'AverageBot94', 250
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Youth2v'), 1, 'AverageBot95', 250
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'HAppFish'), 1, 'AverageBot96', 250
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'CoffeeLake'), 1, 'AverageBot97', 250
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'HaCk3rz'), 1, 'AverageBot98', 250
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Chipmunks'), 1, 'AverageBot99', 250
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Sloth'), 1, 'AverageBot100', 250
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Happy'), 1, 'ExcellentBot1', 500
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Mechanizer2000'), 1, 'ExcellentBot2', 500
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Meganizer2'), 1, 'ExcellentBot3', 500
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Youth2v'), 1, 'ExcellentBot4', 500
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'HAppFish'), 1, 'ExcellentBot5', 500
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'CoffeeLake'), 1, 'ExcellentBot6', 500
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'HaCk3rz'), 1, 'ExcellentBot7', 500
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Chipmunks'), 1, 'ExcellentBot8', 500
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Sloth'), 1, 'ExcellentBot9', 500
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Superplayer'), 1, 'ExcellentBot10', 500
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Happy'), 1, 'ExcellentBot11', 500
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Mechanizer2000'), 1, 'ExcellentBot12', 500
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Meganizer2'), 1, 'ExcellentBot13', 500
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Youth2v'), 1, 'ExcellentBot14', 500
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'HAppFish'), 1, 'ExcellentBot15', 500
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'CoffeeLake'), 1, 'ExcellentBot16', 500
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'HaCk3rz'), 1, 'ExcellentBot17', 500
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Chipmunks'), 1, 'ExcellentBot18', 500
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Sloth'), 1, 'ExcellentBot19', 500
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Superplayer'), 1, 'ExcellentBot20', 500
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Happy'), 1, 'ExcellentBot21', 500
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Mechanizer2000'), 1, 'ExcellentBot23', 500
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Meganizer2'), 1, 'ExcellentBot24', 500
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Youth2v'), 1, 'ExcellentBot25', 500
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'HAppFish'), 1, 'ExcellentBot26', 500
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'CoffeeLake'), 1, 'ExcellentBot27', 500
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'HaCk3rz'), 1, 'ExcellentBot28', 500
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Chipmunks'), 1, 'ExcellentBot29', 500
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Sloth'), 1, 'ExcellentBot30', 500
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Superplayer'), 1, 'ExcellentBot31', 500
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Happy'), 1, 'ExcellentBot32', 500
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Mechanizer2000'), 1, 'ExcellentBot33', 500
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Meganizer2'), 1, 'ExcellentBot34', 500
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Youth2v'), 1, 'ExcellentBot35', 500
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'HAppFish'), 1, 'ExcellentBot36', 500
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'CoffeeLake'), 1, 'ExcellentBot37', 500
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'HaCk3rz'), 1, 'ExcellentBot38', 500
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Chipmunks'), 1, 'ExcellentBot39', 500
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Sloth'), 1, 'ExcellentBot40', 500
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Superplayer'), 1, 'ExcellentBot41', 500
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Happy'), 1, 'ExcellentBot42', 500
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Mechanizer2000'), 1, 'ExcellentBot43', 500
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Meganizer2'), 1, 'ExcellentBot44', 500
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Youth2v'), 1, 'ExcellentBot45', 500
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'HAppFish'), 1, 'ExcellentBot46', 500
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'CoffeeLake'), 1, 'ExcellentBot47', 500
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'HaCk3rz'), 1, 'ExcellentBot48', 500
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Chipmunks'), 1, 'ExcellentBot49', 500
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Sloth'), 1, 'ExcellentBot50', 500
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Superplayer'), 1, 'ExcellentBot51', 500
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Happy'), 1, 'ExcellentBot52', 500
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Mechanizer2000'), 1, 'ExcellentBot53', 500
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Meganizer2'), 1, 'ExcellentBot54', 500
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Youth2v'), 1, 'ExcellentBot55', 500
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'HAppFish'), 1, 'ExcellentBot56', 500
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'CoffeeLake'), 1, 'ExcellentBot57', 500
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'HaCk3rz'), 1, 'ExcellentBot58', 500
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Chipmunks'), 1, 'ExcellentBot59', 500
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Sloth'), 1, 'ExcellentBot60', 500
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Superplayer'), 1, 'ExcellentBot61', 500
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Happy'), 1, 'ExcellentBot62', 500
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Mechanizer2000'), 1, 'ExcellentBot63', 500
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Meganizer2'), 1, 'ExcellentBot64', 500
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Youth2v'), 1, 'ExcellentBot65', 500
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'HAppFish'), 1, 'ExcellentBot66', 500
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'CoffeeLake'), 1, 'ExcellentBot67', 500
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'HaCk3rz'), 1, 'ExcellentBot68', 500
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Chipmunks'), 1, 'ExcellentBot69', 500
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Sloth'), 1, 'ExcellentBot70', 500
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Superplayer'), 1, 'ExcellentBot71', 500
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Happy'), 1, 'ExcellentBot72', 500
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Mechanizer2000'), 1, 'ExcellentBot73', 500
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Meganizer2'), 1, 'ExcellentBot74', 500
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Youth2v'), 1, 'ExcellentBot75', 500
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'HAppFish'), 1, 'ExcellentBot76', 500
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'CoffeeLake'), 1, 'ExcellentBot77', 500
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'HaCk3rz'), 1, 'ExcellentBot78', 500
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Chipmunks'), 1, 'ExcellentBot79', 500
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Sloth'), 1, 'ExcellentBot80', 500
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Superplayer'), 1, 'ExcellentBot81', 500
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Happy'), 1, 'ExcellentBot82', 500
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Mechanizer2000'), 1, 'ExcellentBot83', 500
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Meganizer2'), 1, 'ExcellentBot84', 500
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Youth2v'), 1, 'ExcellentBot85', 500
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'HAppFish'), 1, 'ExcellentBot86', 500
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'CoffeeLake'), 1, 'ExcellentBot87', 500
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'HaCk3rz'), 1, 'ExcellentBot88', 500
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Chipmunks'), 1, 'ExcellentBot89', 500
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Sloth'), 1, 'ExcellentBot90', 500
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Superplayer'), 1, 'ExcellentBot91', 500
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Happy'), 1, 'ExcellentBot92', 500
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Mechanizer2000'), 1, 'ExcellentBot93', 500
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Meganizer2'), 1, 'ExcellentBot94', 500
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Youth2v'), 1, 'ExcellentBot95', 500
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'HAppFish'), 1, 'ExcellentBot96', 500
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'CoffeeLake'), 1, 'ExcellentBot97', 500
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'HaCk3rz'), 1, 'ExcellentBot98', 500
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Chipmunks'), 1, 'ExcellentBot99', 500
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Sloth'), 1, 'ExcellentBot100', 500
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Happy'), 1, 'ExpertBot1', 750
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Mechanizer2000'), 1, 'ExpertBot2', 750
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Meganizer2'), 1, 'ExpertBot3', 750
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Youth2v'), 1, 'ExpertBot4', 750
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'HAppFish'), 1, 'ExpertBot5', 750
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'CoffeeLake'), 1, 'ExpertBot6', 750
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'HaCk3rz'), 1, 'ExpertBot7', 750
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Chipmunks'), 1, 'ExpertBot8', 750
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Sloth'), 1, 'ExpertBot9', 750
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Superplayer'), 1, 'ExpertBot10', 750
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Happy'), 1, 'ExpertBot11', 750
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Mechanizer2000'), 1, 'ExpertBot12', 750
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Meganizer2'), 1, 'ExpertBot13', 750
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Youth2v'), 1, 'ExpertBot14', 750
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'HAppFish'), 1, 'ExpertBot15', 750
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'CoffeeLake'), 1, 'ExpertBot16', 750
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'HaCk3rz'), 1, 'ExpertBot17', 750
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Chipmunks'), 1, 'ExpertBot18', 750
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Sloth'), 1, 'ExpertBot19', 750
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Superplayer'), 1, 'ExpertBot20', 750
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Happy'), 1, 'ExpertBot21', 750
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Mechanizer2000'), 1, 'ExpertBot23', 750
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Meganizer2'), 1, 'ExpertBot24', 750
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Youth2v'), 1, 'ExpertBot25', 750
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'HAppFish'), 1, 'ExpertBot26', 750
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'CoffeeLake'), 1, 'ExpertBot27', 750
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'HaCk3rz'), 1, 'ExpertBot28', 750
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Chipmunks'), 1, 'ExpertBot29', 750
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Sloth'), 1, 'ExpertBot30', 750
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Superplayer'), 1, 'ExpertBot31', 750
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Happy'), 1, 'ExpertBot32', 750
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Mechanizer2000'), 1, 'ExpertBot33', 750
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Meganizer2'), 1, 'ExpertBot34', 750
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Youth2v'), 1, 'ExpertBot35', 750
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'HAppFish'), 1, 'ExpertBot36', 750
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'CoffeeLake'), 1, 'ExpertBot37', 750
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'HaCk3rz'), 1, 'ExpertBot38', 750
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Chipmunks'), 1, 'ExpertBot39', 750
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Sloth'), 1, 'ExpertBot40', 750
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Superplayer'), 1, 'ExpertBot41', 750
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Happy'), 1, 'ExpertBot42', 750
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Mechanizer2000'), 1, 'ExpertBot43', 750
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Meganizer2'), 1, 'ExpertBot44', 750
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Youth2v'), 1, 'ExpertBot45', 750
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'HAppFish'), 1, 'ExpertBot46', 750
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'CoffeeLake'), 1, 'ExpertBot47', 750
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'HaCk3rz'), 1, 'ExpertBot48', 750
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Chipmunks'), 1, 'ExpertBot49', 750
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Sloth'), 1, 'ExpertBot50', 750
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Superplayer'), 1, 'ExpertBot51', 750
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Happy'), 1, 'ExpertBot52', 750
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Mechanizer2000'), 1, 'ExpertBot53', 750
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Meganizer2'), 1, 'ExpertBot54', 750
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Youth2v'), 1, 'ExpertBot55', 750
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'HAppFish'), 1, 'ExpertBot56', 750
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'CoffeeLake'), 1, 'ExpertBot57', 750
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'HaCk3rz'), 1, 'ExpertBot58', 750
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Chipmunks'), 1, 'ExpertBot59', 750
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Sloth'), 1, 'ExpertBot60', 750
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Superplayer'), 1, 'ExpertBot61', 750
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Happy'), 1, 'ExpertBot62', 750
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Mechanizer2000'), 1, 'ExpertBot63', 750
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Meganizer2'), 1, 'ExpertBot64', 750
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Youth2v'), 1, 'ExpertBot65', 750
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'HAppFish'), 1, 'ExpertBot66', 750
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'CoffeeLake'), 1, 'ExpertBot67', 750
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'HaCk3rz'), 1, 'ExpertBot68', 750
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Chipmunks'), 1, 'ExpertBot69', 750
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Sloth'), 1, 'ExpertBot70', 750
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Superplayer'), 1, 'ExpertBot71', 750
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Happy'), 1, 'ExpertBot72', 750
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Mechanizer2000'), 1, 'ExpertBot73', 750
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Meganizer2'), 1, 'ExpertBot74', 750
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Youth2v'), 1, 'ExpertBot75', 750
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'HAppFish'), 1, 'ExpertBot76', 750
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'CoffeeLake'), 1, 'ExpertBot77', 750
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'HaCk3rz'), 1, 'ExpertBot78', 750
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Chipmunks'), 1, 'ExpertBot79', 750
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Sloth'), 1, 'ExpertBot80', 750
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Superplayer'), 1, 'ExpertBot81', 750
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Happy'), 1, 'ExpertBot82', 750
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Mechanizer2000'), 1, 'ExpertBot83', 750
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Meganizer2'), 1, 'ExpertBot84', 750
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Youth2v'), 1, 'ExpertBot85', 750
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'HAppFish'), 1, 'ExpertBot86', 750
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'CoffeeLake'), 1, 'ExpertBot87', 750
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'HaCk3rz'), 1, 'ExpertBot88', 750
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Chipmunks'), 1, 'ExpertBot89', 750
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Sloth'), 1, 'ExpertBot90', 750
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Superplayer'), 1, 'ExpertBot91', 750
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Happy'), 1, 'ExpertBot92', 750
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Mechanizer2000'), 1, 'ExpertBot93', 750
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Meganizer2'), 1, 'ExpertBot94', 750
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Youth2v'), 1, 'ExpertBot95', 750
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'HAppFish'), 1, 'ExpertBot96', 750
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'CoffeeLake'), 1, 'ExpertBot97', 750
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'HaCk3rz'), 1, 'ExpertBot98', 750
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Chipmunks'), 1, 'ExpertBot99', 750
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Sloth'), 1, 'ExpertBot100', 750
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Happy'), 1, 'MasterBot1', 1000
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Mechanizer2000'), 1, 'MasterBot2', 1000
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Meganizer2'), 1, 'MasterBot3', 1000
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Youth2v'), 1, 'MasterBot4', 1000
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'HAppFish'), 1, 'MasterBot5', 1000
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'CoffeeLake'), 1, 'MasterBot6', 1000
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'HaCk3rz'), 1, 'MasterBot7', 1000
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Chipmunks'), 1, 'MasterBot8', 1000
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Sloth'), 1, 'MasterBot9', 1000
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Superplayer'), 1, 'MasterBot10', 1000
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Happy'), 1, 'MasterBot11', 1000
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Mechanizer2000'), 1, 'MasterBot12', 1000
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Meganizer2'), 1, 'MasterBot13', 1000
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Youth2v'), 1, 'MasterBot14', 1000
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'HAppFish'), 1, 'MasterBot15', 1000
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'CoffeeLake'), 1, 'MasterBot16', 1000
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'HaCk3rz'), 1, 'MasterBot17', 1000
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Chipmunks'), 1, 'MasterBot18', 1000
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Sloth'), 1, 'MasterBot19', 1000
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Superplayer'), 1, 'MasterBot20', 1000
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Happy'), 1, 'MasterBot21', 1000
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Mechanizer2000'), 1, 'MasterBot23', 1000
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Meganizer2'), 1, 'MasterBot24', 1000
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Youth2v'), 1, 'MasterBot25', 1000
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'HAppFish'), 1, 'MasterBot26', 1000
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'CoffeeLake'), 1, 'MasterBot27', 1000
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'HaCk3rz'), 1, 'MasterBot28', 1000
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Chipmunks'), 1, 'MasterBot29', 1000
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Sloth'), 1, 'MasterBot30', 1000
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Superplayer'), 1, 'MasterBot31', 1000
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Happy'), 1, 'MasterBot32', 1000
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Mechanizer2000'), 1, 'MasterBot33', 1000
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Meganizer2'), 1, 'MasterBot34', 1000
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Youth2v'), 1, 'MasterBot35', 1000
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'HAppFish'), 1, 'MasterBot36', 1000
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'CoffeeLake'), 1, 'MasterBot37', 1000
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'HaCk3rz'), 1, 'MasterBot38', 1000
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Chipmunks'), 1, 'MasterBot39', 1000
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Sloth'), 1, 'MasterBot40', 1000
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Superplayer'), 1, 'MasterBot41', 1000
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Happy'), 1, 'MasterBot42', 1000
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Mechanizer2000'), 1, 'MasterBot43', 1000
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Meganizer2'), 1, 'MasterBot44', 1000
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Youth2v'), 1, 'MasterBot45', 1000
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'HAppFish'), 1, 'MasterBot46', 1000
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'CoffeeLake'), 1, 'MasterBot47', 1000
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'HaCk3rz'), 1, 'MasterBot48', 1000
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Chipmunks'), 1, 'MasterBot49', 1000
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Sloth'), 1, 'MasterBot50', 1000
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Superplayer'), 1, 'MasterBot51', 1000
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Happy'), 1, 'MasterBot52', 1000
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Mechanizer2000'), 1, 'MasterBot53', 1000
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Meganizer2'), 1, 'MasterBot54', 1000
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Youth2v'), 1, 'MasterBot55', 1000
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'HAppFish'), 1, 'MasterBot56', 1000
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'CoffeeLake'), 1, 'MasterBot57', 1000
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'HaCk3rz'), 1, 'MasterBot58', 1000
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Chipmunks'), 1, 'MasterBot59', 1000
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Sloth'), 1, 'MasterBot60', 1000
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Superplayer'), 1, 'MasterBot61', 1000
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Happy'), 1, 'MasterBot62', 1000
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Mechanizer2000'), 1, 'MasterBot63', 1000
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Meganizer2'), 1, 'MasterBot64', 1000
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Youth2v'), 1, 'MasterBot65', 1000
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'HAppFish'), 1, 'MasterBot66', 1000
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'CoffeeLake'), 1, 'MasterBot67', 1000
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'HaCk3rz'), 1, 'MasterBot68', 1000
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Chipmunks'), 1, 'MasterBot69', 1000
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Sloth'), 1, 'MasterBot70', 1000
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Superplayer'), 1, 'MasterBot71', 1000
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Happy'), 1, 'MasterBot72', 1000
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Mechanizer2000'), 1, 'MasterBot73', 1000
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Meganizer2'), 1, 'MasterBot74', 1000
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Youth2v'), 1, 'MasterBot75', 1000
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'HAppFish'), 1, 'MasterBot76', 1000
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'CoffeeLake'), 1, 'MasterBot77', 1000
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'HaCk3rz'), 1, 'MasterBot78', 1000
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Chipmunks'), 1, 'MasterBot79', 1000
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Sloth'), 1, 'MasterBot80', 1000
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Superplayer'), 1, 'MasterBot81', 1000
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Happy'), 1, 'MasterBot82', 1000
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Mechanizer2000'), 1, 'MasterBot83', 1000
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Meganizer2'), 1, 'MasterBot84', 1000
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Youth2v'), 1, 'MasterBot85', 1000
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'HAppFish'), 1, 'MasterBot86', 1000
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'CoffeeLake'), 1, 'MasterBot87', 1000
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'HaCk3rz'), 1, 'MasterBot88', 1000
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Chipmunks'), 1, 'MasterBot89', 1000
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Sloth'), 1, 'MasterBot90', 1000
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Superplayer'), 1, 'MasterBot91', 1000
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Happy'), 1, 'MasterBot92', 1000
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Mechanizer2000'), 1, 'MasterBot93', 1000
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Meganizer2'), 1, 'MasterBot94', 1000
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Youth2v'), 1, 'MasterBot95', 1000
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'HAppFish'), 1, 'MasterBot96', 1000
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'CoffeeLake'), 1, 'MasterBot97', 1000
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'HaCk3rz'), 1, 'MasterBot98', 1000
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Chipmunks'), 1, 'MasterBot99', 1000
              UNION ALL
             SELECT (SELECT player.player_ID_PK
                       FROM SEI_JavaFalls.javafalls.player
                      WHERE player.name = 'Sloth'), 1, 'MasterBot100', 1000);
GO