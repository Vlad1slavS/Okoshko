CREATE TABLE phone_otp_challenges (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    phone VARCHAR(20) NOT NULL,
    code_hash VARCHAR(64) NOT NULL,
    expires_at TIMESTAMPTZ NOT NULL,
    resend_available_at TIMESTAMPTZ NOT NULL,
    attempts_remaining SMALLINT NOT NULL DEFAULT 5,
    consumed_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT ck_phone_otp_phone_e164 CHECK (phone ~ '^\+[1-9][0-9]{7,14}$'),
    CONSTRAINT ck_phone_otp_attempts CHECK (attempts_remaining >= 0)
);

CREATE TABLE auth_refresh_sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    token_hash VARCHAR(64) NOT NULL,
    expires_at TIMESTAMPTZ NOT NULL,
    revoked_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    last_used_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT uq_auth_refresh_sessions_token_hash UNIQUE (token_hash)
);

CREATE INDEX ix_phone_otp_phone_created ON phone_otp_challenges (phone, created_at DESC);
CREATE INDEX ix_phone_otp_expiry ON phone_otp_challenges (expires_at);
CREATE INDEX ix_auth_refresh_sessions_user ON auth_refresh_sessions (user_id);
CREATE INDEX ix_auth_refresh_sessions_expiry ON auth_refresh_sessions (expires_at);
