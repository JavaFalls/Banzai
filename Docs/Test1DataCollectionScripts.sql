-- Get data about weapons
SELECT bot.primary_weapon AS w_ID,
       CASE bot.primary_weapon
         WHEN 0 THEN 'W_PRI_ACID_BOW'
         WHEN 1 THEN 'W_PRI_EXPLODING_SHURIKEN'
         WHEN 2 THEN 'W_PRI_PRECISION_BOW'
         WHEN 3 THEN 'W_PRI_SWORD'
         WHEN 4 THEN 'W_PRI_SCATTER_BOW'
         WHEN 5 THEN 'W_PRI_RUBBER_BOW'
         WHEN 6 THEN 'W_PRI_ZORROS_GLARE'
         ELSE 'Unknown primary'
       END AS weapon,
       count(bot.bot_ID_PK) AS nbr_bots_using_weapon,
       max(bot.ranking) AS max_rank,
       min(bot.ranking) AS min_rank
  FROM SEI_JavaFalls.javafalls.bot
 GROUP BY bot.primary_weapon
 UNION
SELECT bot.secondary_weapon AS w_ID,
       CASE bot.secondary_weapon
         WHEN 7 THEN 'W_SEC_MINE'
         WHEN 8 THEN 'W_SEC_NUKE'
         WHEN 9 THEN 'W_SEC_SCYTHE'
         WHEN 10 THEN 'W_SEC_SNARE'
         WHEN 11 THEN 'W_SEC_ZORROS_WIT'
         ELSE 'Unknown secondary'
       END AS weapon,
       count(bot.bot_ID_PK) AS nbr_bots_using_weapon,
       max(bot.ranking) AS max_rank,
       min(bot.ranking) AS min_rank
  FROM SEI_JavaFalls.javafalls.bot
 GROUP BY bot.secondary_weapon
 UNION
SELECT bot.utility AS w_ID,
       CASE bot.utility
         WHEN 12 THEN 'W_ABI_CHARGE'
         WHEN 13 THEN 'W_ABI_CLONE'
         WHEN 14 THEN 'W_ABI_EVADE'
         WHEN 15 THEN 'W_ABI_FREEZE'
         WHEN 16 THEN 'W_ABI_REGENERATION'
         WHEN 17 THEN 'W_ABI_SHIELD'
         WHEN 18 THEN 'W_ABI_SUBSTITUTION'
         WHEN 19 THEN 'W_ABI_TELEPORT'
         WHEN 20 THEN 'W_ABI_ZORROS_HONOR'
         ELSE 'Unknown ability'
       END AS weapon,
       count(bot.bot_ID_PK) AS nbr_bots_using_weapon,
       max(bot.ranking) AS max_rank,
       min(bot.ranking) AS min_rank
  FROM SEI_JavaFalls.javafalls.bot
 GROUP BY bot.utility;

SELECT *
  FROM SEI_JavaFalls.javafalls.bot;