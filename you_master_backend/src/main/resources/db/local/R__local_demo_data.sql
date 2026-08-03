INSERT INTO users (id, phone, email, status, phone_verified_at)
VALUES (
    '10000000-0000-0000-0000-000000000001',
    '+79991234567',
    'ekaterina@example.com',
    'ACTIVE',
    now()
)
ON CONFLICT (id) DO UPDATE SET
    phone = EXCLUDED.phone,
    email = EXCLUDED.email,
    status = EXCLUDED.status,
    updated_at = now();

INSERT INTO client_profiles (user_id, display_name)
VALUES ('10000000-0000-0000-0000-000000000001', 'Екатерина Смирнова')
ON CONFLICT (user_id) DO UPDATE SET
    display_name = EXCLUDED.display_name,
    updated_at = now();

INSERT INTO professional_profiles (
    id,
    user_id,
    slug,
    display_name,
    description,
    experience_started_on,
    status,
    rating,
    reviews_count,
    completed_appointments_count
)
VALUES (
    '20000000-0000-0000-0000-000000000001',
    '10000000-0000-0000-0000-000000000001',
    'ekaterina-smirnova',
    'Екатерина Смирнова',
    'Мастер маникюра и педикюра. Работаю на премиальных материалах.',
    DATE '2020-05-01',
    'ACTIVE',
    4.90,
    128,
    312
)
ON CONFLICT (id) DO UPDATE SET
    slug = EXCLUDED.slug,
    display_name = EXCLUDED.display_name,
    description = EXCLUDED.description,
    experience_started_on = EXCLUDED.experience_started_on,
    status = EXCLUDED.status,
    rating = EXCLUDED.rating,
    reviews_count = EXCLUDED.reviews_count,
    completed_appointments_count = EXCLUDED.completed_appointments_count,
    updated_at = now();

INSERT INTO business_accounts (
    id,
    owner_user_id,
    solo_professional_id,
    type,
    status,
    slug,
    name,
    description
)
VALUES (
    '30000000-0000-0000-0000-000000000001',
    '10000000-0000-0000-0000-000000000001',
    '20000000-0000-0000-0000-000000000001',
    'SOLO',
    'ACTIVE',
    'nail-studio-by-ekaterina',
    'Nail Studio by Ekaterina',
    'Уютная студия маникюра в центре Москвы'
)
ON CONFLICT (id) DO UPDATE SET
    status = EXCLUDED.status,
    slug = EXCLUDED.slug,
    name = EXCLUDED.name,
    description = EXCLUDED.description,
    updated_at = now();

INSERT INTO business_members (
    id,
    business_account_id,
    professional_id,
    role,
    status
)
VALUES (
    '31000000-0000-0000-0000-000000000001',
    '30000000-0000-0000-0000-000000000001',
    '20000000-0000-0000-0000-000000000001',
    'OWNER',
    'ACTIVE'
)
ON CONFLICT (id) DO UPDATE SET
    role = EXCLUDED.role,
    status = EXCLUDED.status,
    updated_at = now();

INSERT INTO business_locations (
    id,
    business_account_id,
    name,
    city,
    address_line,
    timezone,
    latitude,
    longitude,
    phone,
    is_active
)
VALUES (
    '40000000-0000-0000-0000-000000000001',
    '30000000-0000-0000-0000-000000000001',
    'Основная студия',
    'Москва',
    'Чистопрудный бульвар, 12с1',
    'Europe/Moscow',
    55.763170,
    37.638620,
    '+79991234567',
    true
)
ON CONFLICT (id) DO UPDATE SET
    name = EXCLUDED.name,
    city = EXCLUDED.city,
    address_line = EXCLUDED.address_line,
    timezone = EXCLUDED.timezone,
    latitude = EXCLUDED.latitude,
    longitude = EXCLUDED.longitude,
    phone = EXCLUDED.phone,
    is_active = EXCLUDED.is_active,
    updated_at = now();

INSERT INTO service_categories (id, slug, name, sort_order, is_active)
VALUES (
    '50000000-0000-0000-0000-000000000001',
    'manicure',
    'Маникюр',
    10,
    true
)
ON CONFLICT (id) DO UPDATE SET
    slug = EXCLUDED.slug,
    name = EXCLUDED.name,
    sort_order = EXCLUDED.sort_order,
    is_active = EXCLUDED.is_active,
    updated_at = now();

INSERT INTO services (
    id,
    business_account_id,
    category_id,
    name,
    description,
    duration_minutes,
    buffer_before_minutes,
    buffer_after_minutes,
    price_minor,
    currency,
    is_active
)
VALUES
    (
        '60000000-0000-0000-0000-000000000001',
        '30000000-0000-0000-0000-000000000001',
        '50000000-0000-0000-0000-000000000001',
        'Маникюр с покрытием',
        'Маникюр, выравнивание и покрытие гель-лаком',
        90,
        0,
        15,
        220000,
        'RUB',
        true
    ),
    (
        '60000000-0000-0000-0000-000000000002',
        '30000000-0000-0000-0000-000000000001',
        '50000000-0000-0000-0000-000000000001',
        'Маникюр без покрытия',
        'Классический маникюр без покрытия',
        45,
        0,
        15,
        120000,
        'RUB',
        true
    ),
    (
        '60000000-0000-0000-0000-000000000003',
        '30000000-0000-0000-0000-000000000001',
        '50000000-0000-0000-0000-000000000001',
        'Укрепление гелем',
        'Маникюр и укрепление ногтевой пластины гелем',
        90,
        0,
        15,
        230000,
        'RUB',
        true
    )
ON CONFLICT (id) DO UPDATE SET
    name = EXCLUDED.name,
    description = EXCLUDED.description,
    duration_minutes = EXCLUDED.duration_minutes,
    buffer_before_minutes = EXCLUDED.buffer_before_minutes,
    buffer_after_minutes = EXCLUDED.buffer_after_minutes,
    price_minor = EXCLUDED.price_minor,
    currency = EXCLUDED.currency,
    is_active = EXCLUDED.is_active,
    updated_at = now();

INSERT INTO service_professionals (service_id, professional_id)
VALUES
    ('60000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000001'),
    ('60000000-0000-0000-0000-000000000002', '20000000-0000-0000-0000-000000000001'),
    ('60000000-0000-0000-0000-000000000003', '20000000-0000-0000-0000-000000000001')
ON CONFLICT (service_id, professional_id) DO UPDATE SET
    is_active = true,
    updated_at = now();
