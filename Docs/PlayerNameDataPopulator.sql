INSERT INTO SEI_JavaFalls.javafalls.player_name
            (section, name)
            (
             -- Section 1 (adjectives)
             SELECT 1, 'Iron' UNION ALL
             SELECT 1, 'Zilch' UNION ALL
             SELECT 1, '' UNION ALL
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

INSERT INTO SEI_JavaFalls.javafalls.player_name
            (section, name)
            (
             -- Section 1 (front adjectives)
             SELECT 1, 'Invincible' UNION ALL
             SELECT 1, 'Victorious' UNION ALL
             SELECT 1, 'Blessed' UNION ALL
             SELECT 1, 'Speedy' UNION ALL
             SELECT 1, 'Warrior' UNION ALL
             SELECT 1, 'Guardian' UNION ALL
             SELECT 1, 'Fantastic' UNION ALL
             SELECT 1, 'Awesome' UNION ALL
             SELECT 1, 'Stomper' UNION ALL
             SELECT 1, 'while' UNION ALL
             -- Section 2 (names)
             SELECT 2, 'Zilch' UNION ALL
             SELECT 2, 'Accura' UNION ALL
             SELECT 2, 'ez24/7' UNION ALL
             SELECT 2, 'Mr. Invincible' UNION ALL
             SELECT 2, 'Aristotle' UNION ALL
             SELECT 2, 'Turing Machine' UNION ALL
             SELECT 2, 'Campanile' UNION ALL
             SELECT 2, 'Doomsday' UNION ALL
             SELECT 2, '(true)' UNION ALL
             SELECT 2, '(false)' UNION ALL
             -- Section 3 (back adjectives)
             SELECT 3, 'the Bold' UNION ALL
             SELECT 3, 'the Defeater' UNION ALL
             SELECT 3, 'the Decimator' UNION ALL
             SELECT 3, 'the Wreaker' UNION ALL
             SELECT 3, '9000' UNION ALL
             SELECT 3, 'the Great' UNION ALL
             SELECT 3, 'the Automated' UNION ALL
             SELECT 3, '{win();}' UNION ALL
             SELECT 3, '{dominate();}' UNION ALL
             SELECT 3, '{lose();}'
            )
GO