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

INSERT INTO client_profiles (user_id, display_name, first_name, last_name)
VALUES ('10000000-0000-0000-0000-000000000001', 'Екатерина Смирнова', 'Екатерина', 'Смирнова')
ON CONFLICT (user_id) DO UPDATE SET
    display_name = EXCLUDED.display_name,
    first_name = EXCLUDED.first_name,
    last_name = EXCLUDED.last_name,
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
    'Чита',
    'улица Ленина, 97',
    'Asia/Chita',
    52.034012,
    113.499488,
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

INSERT INTO users (id, phone, email, status, phone_verified_at)
VALUES
    ('11000000-0000-0000-0000-000000000001', '+79990000001', 'client.anna@example.com', 'ACTIVE', now()),
    ('11000000-0000-0000-0000-000000000002', '+79990000002', 'client.maria@example.com', 'ACTIVE', now()),
    ('11000000-0000-0000-0000-000000000003', '+79990000003', 'client.olga@example.com', 'ACTIVE', now())
ON CONFLICT (id) DO UPDATE SET
    phone = EXCLUDED.phone,
    email = EXCLUDED.email,
    status = EXCLUDED.status,
    updated_at = now();

INSERT INTO client_profiles (user_id, display_name, first_name, last_name)
VALUES
    ('11000000-0000-0000-0000-000000000001', 'Анна Петрова', 'Анна', 'Петрова'),
    ('11000000-0000-0000-0000-000000000002', 'Мария Смирнова', 'Мария', 'Смирнова'),
    ('11000000-0000-0000-0000-000000000003', 'Ольга Иванова', 'Ольга', 'Иванова')
ON CONFLICT (user_id) DO UPDATE SET
    display_name = EXCLUDED.display_name,
    first_name = EXCLUDED.first_name,
    last_name = EXCLUDED.last_name,
    updated_at = now();

-- Appointment dates are relative to CURRENT_DATE. Replace the demo-owned rows
-- before inserting them so yesterday's relative dates cannot temporarily
-- overlap today's dates while ON CONFLICT updates are being evaluated.
DELETE FROM appointments
WHERE id IN (
    '70000000-0000-0000-0000-000000000001',
    '70000000-0000-0000-0000-000000000002',
    '70000000-0000-0000-0000-000000000003',
    '70000000-0000-0000-0000-000000000004'
);

INSERT INTO appointments (
    id, business_account_id, location_id, professional_id, client_user_id,
    service_id, status, starts_at, ends_at, client_name_snapshot,
    service_name_snapshot, price_minor, currency
)
VALUES
    (
        '70000000-0000-0000-0000-000000000001',
        '30000000-0000-0000-0000-000000000001',
        '40000000-0000-0000-0000-000000000001',
        '20000000-0000-0000-0000-000000000001',
        '11000000-0000-0000-0000-000000000001',
        '60000000-0000-0000-0000-000000000001',
        'CONFIRMED',
        (CURRENT_DATE + TIME '10:00') AT TIME ZONE 'Asia/Chita',
        (CURRENT_DATE + TIME '11:30') AT TIME ZONE 'Asia/Chita',
        'Анна Петрова', 'Маникюр с покрытием', 220000, 'RUB'
    ),
    (
        '70000000-0000-0000-0000-000000000002',
        '30000000-0000-0000-0000-000000000001',
        '40000000-0000-0000-0000-000000000001',
        '20000000-0000-0000-0000-000000000001',
        '11000000-0000-0000-0000-000000000002',
        '60000000-0000-0000-0000-000000000002',
        'CONFIRMED',
        (CURRENT_DATE + TIME '12:30') AT TIME ZONE 'Asia/Chita',
        (CURRENT_DATE + TIME '13:15') AT TIME ZONE 'Asia/Chita',
        'Мария Смирнова', 'Маникюр без покрытия', 120000, 'RUB'
    ),
    (
        '70000000-0000-0000-0000-000000000003',
        '30000000-0000-0000-0000-000000000001',
        '40000000-0000-0000-0000-000000000001',
        '20000000-0000-0000-0000-000000000001',
        '11000000-0000-0000-0000-000000000003',
        '60000000-0000-0000-0000-000000000003',
        'PENDING_CONFIRMATION',
        (CURRENT_DATE + TIME '15:00') AT TIME ZONE 'Asia/Chita',
        (CURRENT_DATE + TIME '16:30') AT TIME ZONE 'Asia/Chita',
        'Ольга Иванова', 'Укрепление гелем', 230000, 'RUB'
    ),
    (
        '70000000-0000-0000-0000-000000000004',
        '30000000-0000-0000-0000-000000000001',
        '40000000-0000-0000-0000-000000000001',
        '20000000-0000-0000-0000-000000000001',
        '11000000-0000-0000-0000-000000000001',
        '60000000-0000-0000-0000-000000000002',
        'CONFIRMED',
        ((CURRENT_DATE + 1) + TIME '11:00') AT TIME ZONE 'Asia/Chita',
        ((CURRENT_DATE + 1) + TIME '11:45') AT TIME ZONE 'Asia/Chita',
        'Анна Петрова', 'Маникюр без покрытия', 120000, 'RUB'
    )
ON CONFLICT (id) DO UPDATE SET
    status = EXCLUDED.status,
    starts_at = EXCLUDED.starts_at,
    ends_at = EXCLUDED.ends_at,
    client_name_snapshot = EXCLUDED.client_name_snapshot,
    service_name_snapshot = EXCLUDED.service_name_snapshot,
    price_minor = EXCLUDED.price_minor,
    currency = EXCLUDED.currency,
    updated_at = now();

INSERT INTO users (id, phone, email, status, phone_verified_at)
VALUES
    ('10000000-0000-0000-0000-000000000002', '+79991234568', 'anna@example.com', 'ACTIVE', now()),
    ('10000000-0000-0000-0000-000000000003', '+79991234569', 'marina@example.com', 'ACTIVE', now()),
    ('10000000-0000-0000-0000-000000000004', '+79991234570', 'olga@example.com', 'ACTIVE', now()),
    ('10000000-0000-0000-0000-000000000005', '+79991234571', 'alina@example.com', 'ACTIVE', now())
ON CONFLICT (id) DO UPDATE SET
    phone = EXCLUDED.phone,
    email = EXCLUDED.email,
    status = EXCLUDED.status,
    updated_at = now();

INSERT INTO professional_profiles (
    id, user_id, slug, display_name, description, experience_started_on,
    status, rating, reviews_count, completed_appointments_count
)
VALUES
    ('20000000-0000-0000-0000-000000000002', '10000000-0000-0000-0000-000000000002',
     'anna-ivanova', 'Анна Иванова', 'Брови, ламинирование ресниц и макияж.', DATE '2019-03-10',
     'ACTIVE', 4.70, 645, 428),
    ('20000000-0000-0000-0000-000000000003', '10000000-0000-0000-0000-000000000003',
     'marina-petrova', 'Марина Петрова', 'Архитектура и долговременная укладка бровей.', DATE '2021-06-15',
     'ACTIVE', 4.85, 214, 190),
    ('20000000-0000-0000-0000-000000000004', '10000000-0000-0000-0000-000000000004',
     'olga-sokolova', 'Ольга Соколова', 'Визажист и lash-мастер.', DATE '2018-09-01',
     'ACTIVE', 4.92, 337, 506),
    ('20000000-0000-0000-0000-000000000005', '10000000-0000-0000-0000-000000000005',
     'alina-volkova', 'Алина Волкова', 'Маникюр, покрытие и укрепление ногтей.', DATE '2022-01-20',
     'ACTIVE', 4.65, 98, 121)
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
    id, owner_user_id, solo_professional_id, type, status, slug, name, description
)
VALUES
    ('30000000-0000-0000-0000-000000000002', '10000000-0000-0000-0000-000000000002',
     '20000000-0000-0000-0000-000000000002', 'SOLO', 'ACTIVE', 'anna-beauty', 'Anna Beauty', 'Студия Анны'),
    ('30000000-0000-0000-0000-000000000003', '10000000-0000-0000-0000-000000000003',
     '20000000-0000-0000-0000-000000000003', 'SOLO', 'ACTIVE', 'marina-brows', 'Marina Brows', 'Студия бровей'),
    ('30000000-0000-0000-0000-000000000004', '10000000-0000-0000-0000-000000000004',
     '20000000-0000-0000-0000-000000000004', 'SOLO', 'ACTIVE', 'olga-makeup', 'Olga Makeup', 'Макияж и ресницы'),
    ('30000000-0000-0000-0000-000000000005', '10000000-0000-0000-0000-000000000005',
     '20000000-0000-0000-0000-000000000005', 'SOLO', 'ACTIVE', 'alina-nails', 'Alina Nails', 'Ногтевая студия')
ON CONFLICT (id) DO UPDATE SET
    status = EXCLUDED.status,
    slug = EXCLUDED.slug,
    name = EXCLUDED.name,
    description = EXCLUDED.description,
    updated_at = now();

INSERT INTO business_locations (
    id, business_account_id, name, city, address_line, timezone,
    latitude, longitude, phone, is_active
)
VALUES
    ('40000000-0000-0000-0000-000000000002', '30000000-0000-0000-0000-000000000002',
     'Основная студия', 'Чита', 'улица Бутина, 28', 'Asia/Chita', 52.035500, 113.501300, '+79991234568', true),
    ('40000000-0000-0000-0000-000000000003', '30000000-0000-0000-0000-000000000003',
     'Основная студия', 'Чита', 'улица Чкалова, 120', 'Asia/Chita', 52.031900, 113.497000, '+79991234569', true),
    ('40000000-0000-0000-0000-000000000004', '30000000-0000-0000-0000-000000000004',
     'Основная студия', 'Чита', 'Амурская улица, 69', 'Asia/Chita', 52.037100, 113.506200, '+79991234570', true),
    ('40000000-0000-0000-0000-000000000005', '30000000-0000-0000-0000-000000000005',
     'Основная студия', 'Чита', 'улица Анохина, 67', 'Asia/Chita', 52.032800, 113.493900, '+79991234571', true)
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
VALUES
    ('50000000-0000-0000-0000-000000000002', 'brows', 'Брови', 20, true),
    ('50000000-0000-0000-0000-000000000003', 'lashes', 'Ресницы', 30, true),
    ('50000000-0000-0000-0000-000000000004', 'makeup', 'Макияж', 40, true)
ON CONFLICT (id) DO UPDATE SET
    slug = EXCLUDED.slug,
    name = EXCLUDED.name,
    sort_order = EXCLUDED.sort_order,
    is_active = EXCLUDED.is_active,
    updated_at = now();

INSERT INTO services (
    id, business_account_id, category_id, name, description,
    duration_minutes, buffer_before_minutes, buffer_after_minutes,
    price_minor, currency, is_active
)
VALUES
    ('60000000-0000-0000-0000-000000000004', '30000000-0000-0000-0000-000000000002',
     '50000000-0000-0000-0000-000000000002', 'Архитектура бровей', 'Коррекция и окрашивание', 60, 0, 10, 140000, 'RUB', true),
    ('60000000-0000-0000-0000-000000000005', '30000000-0000-0000-0000-000000000002',
     '50000000-0000-0000-0000-000000000003', 'Ламинирование ресниц', 'Ламинирование и уход', 75, 0, 15, 220000, 'RUB', true),
    ('60000000-0000-0000-0000-000000000006', '30000000-0000-0000-0000-000000000002',
     '50000000-0000-0000-0000-000000000004', 'Дневной макияж', 'Лёгкий дневной образ', 60, 0, 15, 250000, 'RUB', true),
    ('60000000-0000-0000-0000-000000000007', '30000000-0000-0000-0000-000000000003',
     '50000000-0000-0000-0000-000000000002', 'Долговременная укладка бровей', 'Укладка, коррекция и уход', 70, 0, 10, 180000, 'RUB', true),
    ('60000000-0000-0000-0000-000000000008', '30000000-0000-0000-0000-000000000004',
     '50000000-0000-0000-0000-000000000004', 'Вечерний макияж', 'Стойкий вечерний образ', 90, 0, 15, 350000, 'RUB', true),
    ('60000000-0000-0000-0000-000000000009', '30000000-0000-0000-0000-000000000004',
     '50000000-0000-0000-0000-000000000003', 'Наращивание ресниц', 'Классический объём', 120, 0, 15, 280000, 'RUB', true),
    ('60000000-0000-0000-0000-000000000010', '30000000-0000-0000-0000-000000000005',
     '50000000-0000-0000-0000-000000000001', 'Маникюр с покрытием', 'Маникюр и однотонное покрытие', 90, 0, 15, 170000, 'RUB', true)
ON CONFLICT (id) DO UPDATE SET
    name = EXCLUDED.name,
    description = EXCLUDED.description,
    duration_minutes = EXCLUDED.duration_minutes,
    price_minor = EXCLUDED.price_minor,
    is_active = EXCLUDED.is_active,
    updated_at = now();

INSERT INTO service_professionals (service_id, professional_id)
VALUES
    ('60000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000002'),
    ('60000000-0000-0000-0000-000000000005', '20000000-0000-0000-0000-000000000002'),
    ('60000000-0000-0000-0000-000000000006', '20000000-0000-0000-0000-000000000002'),
    ('60000000-0000-0000-0000-000000000007', '20000000-0000-0000-0000-000000000003'),
    ('60000000-0000-0000-0000-000000000008', '20000000-0000-0000-0000-000000000004'),
    ('60000000-0000-0000-0000-000000000009', '20000000-0000-0000-0000-000000000004'),
    ('60000000-0000-0000-0000-000000000010', '20000000-0000-0000-0000-000000000005')
ON CONFLICT (service_id, professional_id) DO UPDATE SET
    is_active = true,
    updated_at = now();
