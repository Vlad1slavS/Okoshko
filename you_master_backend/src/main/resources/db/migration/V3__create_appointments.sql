CREATE TABLE appointments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    business_account_id UUID NOT NULL REFERENCES business_accounts (id) ON DELETE RESTRICT,
    location_id UUID NOT NULL REFERENCES business_locations (id) ON DELETE RESTRICT,
    professional_id UUID NOT NULL REFERENCES professional_profiles (id) ON DELETE RESTRICT,
    client_user_id UUID NOT NULL REFERENCES users (id) ON DELETE RESTRICT,
    service_id UUID NOT NULL REFERENCES services (id) ON DELETE RESTRICT,
    status VARCHAR(32) NOT NULL DEFAULT 'PENDING_CONFIRMATION',
    starts_at TIMESTAMPTZ NOT NULL,
    ends_at TIMESTAMPTZ NOT NULL,
    client_name_snapshot VARCHAR(120) NOT NULL,
    service_name_snapshot VARCHAR(160) NOT NULL,
    price_minor BIGINT NOT NULL,
    currency VARCHAR(3) NOT NULL DEFAULT 'RUB',
    client_comment TEXT,
    professional_comment TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT ck_appointments_status CHECK (status IN (
        'PENDING_CONFIRMATION', 'CONFIRMED', 'COMPLETED',
        'CANCELLED_BY_CLIENT', 'CANCELLED_BY_PROFESSIONAL', 'NO_SHOW'
    )),
    CONSTRAINT ck_appointments_time_range CHECK (ends_at > starts_at),
    CONSTRAINT ck_appointments_client_name_not_blank CHECK (btrim(client_name_snapshot) <> ''),
    CONSTRAINT ck_appointments_service_name_not_blank CHECK (btrim(service_name_snapshot) <> ''),
    CONSTRAINT ck_appointments_price CHECK (price_minor >= 0),
    CONSTRAINT ck_appointments_currency CHECK (currency = upper(currency) AND length(currency) = 3),
    CONSTRAINT ex_appointments_professional_overlap EXCLUDE USING gist (
        professional_id WITH =,
        tstzrange(starts_at, ends_at, '[)') WITH &&
    ) WHERE (status IN ('PENDING_CONFIRMATION', 'CONFIRMED'))
);

CREATE INDEX ix_appointments_professional_starts_at
    ON appointments (professional_id, starts_at);
CREATE INDEX ix_appointments_client_starts_at
    ON appointments (client_user_id, starts_at DESC);
CREATE INDEX ix_appointments_business_starts_at
    ON appointments (business_account_id, starts_at);
