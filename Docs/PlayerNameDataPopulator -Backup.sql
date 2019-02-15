INSERT INTO SEI_JavaFalls.javafalls.player_name
            (section, name)
            (
             -- Section 1 (adjectives)
             SELECT 1, 'Iron' UNION ALL
             SELECT 1, 'Zer0' UNION ALL
             SELECT 1, 'Sloth' UNION ALL
             SELECT 1, 'Doomsday' UNION ALL
             SELECT 1, 'Wreaker' UNION ALL
             SELECT 1, '' UNION ALL
             SELECT 1, 'Decimator' UNION ALL
             SELECT 1, 'Awesome' UNION ALL
             SELECT 1, 'Accura' UNION ALL
             SELECT 1, 'while' UNION ALL
             -- Section 2 (prepositions, articles, and more adjectives)
             SELECT 2, 'the' UNION ALL
             SELECT 2, 'of' UNION ALL
             SELECT 2, 'of the' UNION ALL
             SELECT 2, '' UNION ALL
             SELECT 2, '' UNION ALL
             SELECT 2, '' UNION ALL
             SELECT 2, '' UNION ALL
             SELECT 2, 'Code' UNION ALL
             SELECT 2, '(true)' UNION ALL
             SELECT 2, '(false)' UNION ALL
             -- Section 3 (names)
             SELECT 3, 'Aristotle' UNION ALL
             SELECT 3, 'Turing Machine' UNION ALL
             SELECT 3, 'Campanile' UNION ALL
             SELECT 3, 'Mr. Invincible' UNION ALL
             SELECT 3, 'ez24/7' UNION ALL
             SELECT 3, 'Sloth' UNION ALL
             SELECT 3, 'Accura' UNION ALL
             SELECT 3, '{win();}' UNION ALL
             SELECT 3, '{dominate();}' UNION ALL
             SELECT 3, '{lose();}'
            )
GO