ALTER TABLE client_profiles
    ADD COLUMN first_name VARCHAR(60),
    ADD COLUMN last_name VARCHAR(60);

UPDATE client_profiles
SET first_name = split_part(display_name, ' ', 1),
    last_name = CASE
        WHEN position(' ' IN display_name) > 0
            THEN NULLIF(btrim(substring(display_name FROM position(' ' IN display_name) + 1)), '')
        ELSE NULL
    END
WHERE first_name IS NULL;

ALTER TABLE client_profiles
    ALTER COLUMN first_name SET NOT NULL,
    ADD CONSTRAINT ck_client_profiles_first_name_not_blank CHECK (btrim(first_name) <> ''),
    ADD CONSTRAINT ck_client_profiles_last_name_not_blank CHECK (last_name IS NULL OR btrim(last_name) <> '');
