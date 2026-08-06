CREATE TABLE client_favorite_professionals (
    client_user_id UUID NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    professional_id UUID NOT NULL REFERENCES professional_profiles (id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    PRIMARY KEY (client_user_id, professional_id)
);

CREATE INDEX ix_client_favorites_user_created_at
    ON client_favorite_professionals (client_user_id, created_at DESC);
