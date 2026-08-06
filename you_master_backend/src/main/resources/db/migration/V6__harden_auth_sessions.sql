ALTER TABLE phone_otp_challenges
    ADD COLUMN request_ip VARCHAR(45);

ALTER TABLE auth_refresh_sessions
    ADD COLUMN family_id UUID,
    ADD COLUMN replaced_by_session_id UUID,
    ADD COLUMN ip_address VARCHAR(45),
    ADD COLUMN user_agent VARCHAR(300);

UPDATE auth_refresh_sessions SET family_id = id WHERE family_id IS NULL;
ALTER TABLE auth_refresh_sessions ALTER COLUMN family_id SET NOT NULL;
ALTER TABLE auth_refresh_sessions
    ADD CONSTRAINT fk_auth_refresh_replacement
        FOREIGN KEY (replaced_by_session_id) REFERENCES auth_refresh_sessions (id) ON DELETE SET NULL;

CREATE INDEX ix_phone_otp_ip_created ON phone_otp_challenges (request_ip, created_at DESC)
    WHERE request_ip IS NOT NULL;
CREATE INDEX ix_auth_refresh_sessions_family ON auth_refresh_sessions (family_id);
