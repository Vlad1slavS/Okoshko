CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    phone VARCHAR(20) NOT NULL,
    email VARCHAR(320),
    status VARCHAR(32) NOT NULL DEFAULT 'ACTIVE',
    phone_verified_at TIMESTAMPTZ,
    email_verified_at TIMESTAMPTZ,
    last_login_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT uq_users_phone UNIQUE (phone),
    CONSTRAINT ck_users_phone_e164 CHECK (phone ~ '^\+[1-9][0-9]{7,14}$'),
    CONSTRAINT ck_users_status CHECK (status IN ('ACTIVE', 'BLOCKED', 'DELETED'))
);

CREATE TABLE client_profiles (
    user_id UUID PRIMARY KEY REFERENCES users (id) ON DELETE CASCADE,
    display_name VARCHAR(120) NOT NULL,
    avatar_url TEXT,
    birth_date DATE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT ck_client_profiles_display_name_not_blank CHECK (btrim(display_name) <> '')
);

CREATE TABLE professional_profiles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users (id) ON DELETE RESTRICT,
    slug VARCHAR(120) NOT NULL,
    display_name VARCHAR(120) NOT NULL,
    description TEXT,
    avatar_url TEXT,
    experience_started_on DATE,
    status VARCHAR(32) NOT NULL DEFAULT 'DRAFT',
    rating NUMERIC(3, 2) NOT NULL DEFAULT 0,
    reviews_count INTEGER NOT NULL DEFAULT 0,
    completed_appointments_count INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT uq_professional_profiles_user UNIQUE (user_id),
    CONSTRAINT ck_professional_profiles_display_name_not_blank CHECK (btrim(display_name) <> ''),
    CONSTRAINT ck_professional_profiles_status CHECK (status IN ('DRAFT', 'PENDING_MODERATION', 'ACTIVE', 'SUSPENDED', 'ARCHIVED')),
    CONSTRAINT ck_professional_profiles_rating CHECK (rating >= 0 AND rating <= 5),
    CONSTRAINT ck_professional_profiles_reviews_count CHECK (reviews_count >= 0),
    CONSTRAINT ck_professional_profiles_appointments_count CHECK (completed_appointments_count >= 0)
);

CREATE TABLE business_accounts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    owner_user_id UUID NOT NULL REFERENCES users (id) ON DELETE RESTRICT,
    solo_professional_id UUID REFERENCES professional_profiles (id) ON DELETE RESTRICT,
    type VARCHAR(16) NOT NULL,
    status VARCHAR(24) NOT NULL DEFAULT 'ACTIVE',
    slug VARCHAR(120) NOT NULL,
    name VARCHAR(160) NOT NULL,
    description TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT uq_business_accounts_solo_professional UNIQUE (solo_professional_id),
    CONSTRAINT ck_business_accounts_type CHECK (type IN ('SOLO', 'STUDIO')),
    CONSTRAINT ck_business_accounts_status CHECK (status IN ('ACTIVE', 'SUSPENDED', 'ARCHIVED')),
    CONSTRAINT ck_business_accounts_name_not_blank CHECK (btrim(name) <> ''),
    CONSTRAINT ck_business_accounts_owner CHECK (
        (type = 'SOLO' AND solo_professional_id IS NOT NULL)
        OR (type = 'STUDIO' AND solo_professional_id IS NULL)
    )
);

CREATE TABLE business_members (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    business_account_id UUID NOT NULL REFERENCES business_accounts (id) ON DELETE CASCADE,
    professional_id UUID NOT NULL REFERENCES professional_profiles (id) ON DELETE RESTRICT,
    role VARCHAR(24) NOT NULL,
    status VARCHAR(24) NOT NULL DEFAULT 'ACTIVE',
    joined_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT uq_business_members_business_professional UNIQUE (business_account_id, professional_id),
    CONSTRAINT ck_business_members_role CHECK (role IN ('OWNER', 'ADMIN', 'PROFESSIONAL')),
    CONSTRAINT ck_business_members_status CHECK (status IN ('INVITED', 'ACTIVE', 'SUSPENDED', 'LEFT'))
);

CREATE TABLE business_locations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    business_account_id UUID NOT NULL REFERENCES business_accounts (id) ON DELETE CASCADE,
    name VARCHAR(160) NOT NULL,
    city VARCHAR(120) NOT NULL,
    address_line VARCHAR(300) NOT NULL,
    timezone VARCHAR(64) NOT NULL,
    latitude NUMERIC(9, 6),
    longitude NUMERIC(9, 6),
    phone VARCHAR(20),
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT ck_business_locations_name_not_blank CHECK (btrim(name) <> ''),
    CONSTRAINT ck_business_locations_city_not_blank CHECK (btrim(city) <> ''),
    CONSTRAINT ck_business_locations_address_not_blank CHECK (btrim(address_line) <> ''),
    CONSTRAINT ck_business_locations_latitude CHECK (latitude IS NULL OR latitude BETWEEN -90 AND 90),
    CONSTRAINT ck_business_locations_longitude CHECK (longitude IS NULL OR longitude BETWEEN -180 AND 180)
);

CREATE TABLE service_categories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    parent_id UUID REFERENCES service_categories (id) ON DELETE RESTRICT,
    slug VARCHAR(120) NOT NULL,
    name VARCHAR(120) NOT NULL,
    sort_order INTEGER NOT NULL DEFAULT 0,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT ck_service_categories_name_not_blank CHECK (btrim(name) <> ''),
    CONSTRAINT ck_service_categories_sort_order CHECK (sort_order >= 0),
    CONSTRAINT ck_service_categories_not_self_parent CHECK (parent_id IS NULL OR parent_id <> id)
);

CREATE TABLE services (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    business_account_id UUID NOT NULL REFERENCES business_accounts (id) ON DELETE CASCADE,
    category_id UUID NOT NULL REFERENCES service_categories (id) ON DELETE RESTRICT,
    name VARCHAR(160) NOT NULL,
    description TEXT,
    duration_minutes INTEGER NOT NULL,
    buffer_before_minutes INTEGER NOT NULL DEFAULT 0,
    buffer_after_minutes INTEGER NOT NULL DEFAULT 0,
    price_minor BIGINT NOT NULL,
    currency VARCHAR(3) NOT NULL DEFAULT 'RUB',
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT ck_services_name_not_blank CHECK (btrim(name) <> ''),
    CONSTRAINT ck_services_duration CHECK (duration_minutes > 0),
    CONSTRAINT ck_services_buffer_before CHECK (buffer_before_minutes >= 0),
    CONSTRAINT ck_services_buffer_after CHECK (buffer_after_minutes >= 0),
    CONSTRAINT ck_services_price CHECK (price_minor >= 0),
    CONSTRAINT ck_services_currency_length CHECK (length(currency) = 3),
    CONSTRAINT ck_services_currency_uppercase CHECK (currency = upper(currency))
);

CREATE TABLE service_professionals (
    service_id UUID NOT NULL REFERENCES services (id) ON DELETE CASCADE,
    professional_id UUID NOT NULL REFERENCES professional_profiles (id) ON DELETE CASCADE,
    custom_duration_minutes INTEGER,
    custom_price_minor BIGINT,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    PRIMARY KEY (service_id, professional_id),
    CONSTRAINT ck_service_professionals_duration CHECK (custom_duration_minutes IS NULL OR custom_duration_minutes > 0),
    CONSTRAINT ck_service_professionals_price CHECK (custom_price_minor IS NULL OR custom_price_minor >= 0)
);

CREATE INDEX ix_professional_profiles_status ON professional_profiles (status);
CREATE UNIQUE INDEX uq_users_email_lower ON users (lower(email)) WHERE email IS NOT NULL;
CREATE UNIQUE INDEX uq_professional_profiles_slug_lower ON professional_profiles (lower(slug));
CREATE UNIQUE INDEX uq_business_accounts_slug_lower ON business_accounts (lower(slug));
CREATE UNIQUE INDEX uq_service_categories_slug_lower ON service_categories (lower(slug));
CREATE INDEX ix_business_accounts_owner ON business_accounts (owner_user_id);
CREATE INDEX ix_business_accounts_type_status ON business_accounts (type, status);
CREATE INDEX ix_business_members_professional ON business_members (professional_id);
CREATE INDEX ix_business_locations_business_active ON business_locations (business_account_id, is_active);
CREATE INDEX ix_business_locations_city_active ON business_locations (city, is_active);
CREATE INDEX ix_service_categories_parent ON service_categories (parent_id);
CREATE INDEX ix_services_business_active ON services (business_account_id, is_active);
CREATE INDEX ix_services_category_active ON services (category_id, is_active);
CREATE INDEX ix_service_professionals_professional_active ON service_professionals (professional_id, is_active);
