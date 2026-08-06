CREATE TABLE professional_booking_settings (
    professional_id UUID PRIMARY KEY REFERENCES professional_profiles (id) ON DELETE CASCADE,
    slot_step_minutes INTEGER NOT NULL DEFAULT 30,
    minimum_notice_minutes INTEGER NOT NULL DEFAULT 120,
    booking_horizon_days INTEGER NOT NULL DEFAULT 60,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT ck_booking_settings_slot_step CHECK (slot_step_minutes BETWEEN 5 AND 240),
    CONSTRAINT ck_booking_settings_minimum_notice CHECK (minimum_notice_minutes BETWEEN 0 AND 43200),
    CONSTRAINT ck_booking_settings_horizon CHECK (booking_horizon_days BETWEEN 1 AND 365)
);

CREATE TABLE professional_availability_starts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    professional_id UUID NOT NULL REFERENCES professional_profiles (id) ON DELETE CASCADE,
    location_id UUID NOT NULL REFERENCES business_locations (id) ON DELETE CASCADE,
    restricted_service_id UUID REFERENCES services (id) ON DELETE RESTRICT,
    starts_at TIMESTAMPTZ NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT uq_professional_availability_start UNIQUE (professional_id, starts_at)
);

CREATE INDEX ix_professional_availability_starts_range
    ON professional_availability_starts (professional_id, starts_at);
CREATE INDEX ix_professional_availability_starts_service
    ON professional_availability_starts (restricted_service_id)
    WHERE restricted_service_id IS NOT NULL;
