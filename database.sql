CREATE TABLE IF NOT EXISTS hell_kart_players (
    id INT AUTO_INCREMENT PRIMARY KEY,
    player_id INT NOT NULL,
    kart_owned BOOLEAN NOT NULL DEFAULT FALSE,
    last_hell_entry DATETIME,
    UNIQUE KEY (player_id)
);

INSERT INTO hell_kart_players (player_id, kart_owned) SELECT player_id, FALSE FROM users WHERE player_id NOT IN (SELECT player_id FROM hell_kart_players);