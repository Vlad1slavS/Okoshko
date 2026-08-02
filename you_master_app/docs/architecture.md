# YouMaster: architecture decisions

## Product boundaries

The application supports separate client and professional experiences.

- Client: discovery, search, favorites, booking, appointments, profile.
- Professional: dashboard, schedule, services, customers, promotions,
  portfolio, messages, analytics, profile.
- A studio with multiple employees is a future capability. It must not be
  represented as an individual professional in the domain model.
- One account may eventually own multiple roles. Navigation is selected from
  the active profile rather than scattered role checks in widgets.

## Flutter application

The project uses a feature-first structure. Each feature owns its presentation,
data, and optional domain code.

- Presentation contains pages, widgets, state, and controllers/view models.
- Data contains API services, DTOs, mappers, and repository implementations.
- Domain is introduced only for reusable or complex business rules.
- Repositories are the source of truth for application data.
- Widgets do not call HTTP services directly.
- Platform-specific integrations are isolated behind conditional adapters.
- Client and professional areas use separate navigation shells.

## State and navigation

- Riverpod provides state management and dependency injection.
- GoRouter provides declarative routing, deep links, and browser URL support.
- Feature state is immutable.
- Remote loading, empty, error, and success states are designed explicitly.

## Backend direction

The initial backend should be a modular Spring Boot monolith backed by
PostgreSQL. Booking and availability are distinct modules.

Booking must support:

- transactional prevention of overlapping appointments;
- idempotent create and payment requests;
- explicit time zones;
- schedule exceptions, breaks, cancellation, and rescheduling;
- audit fields and lifecycle statuses.

Object storage, notifications, background jobs, Redis, and payments are added
behind interfaces when their features are implemented.

## Quality gates

Every change should pass:

1. `dart format --output=none --set-exit-if-changed .`
2. `flutter analyze`
3. `flutter test`

Critical domain rules receive unit tests. Main navigation and high-value user
flows receive widget or integration tests.
