# NetworkHub MVP

> Scan → Save to Contacts → Follow-up Email → (Optional) Profile Discovery

A mobile app for networking at events: scan business cards, save contacts, send follow-up emails.

## Quick Start (Development)

### Prerequisites
- Docker & Docker Compose
- Flutter SDK 3.x
- Python 3.12+ (for local backend dev)

### 1. Start Backend Services

```bash
cd infra
cp .env.example .env
# Edit .env: set SENDGRID_API_KEY, SECRET_KEY
docker compose up -d
```

### 2. Run Migrations

```bash
docker compose exec backend alembic upgrade head
```

### 3. Run Mobile App

```bash
cd mobile
cp .env.example .env
# Edit .env: set BASE_URL (e.g. http://localhost:8000/api/v1)
flutter pub get
flutter run
```

## Repository Structure

```
Networkhub/
├── mobile/          # Flutter app (iOS + Android)
│   └── lib/
│       ├── core/            # Shared utilities, networking, storage
│       ├── features/
│       │   ├── auth/        # Magic link auth, onboarding
│       │   ├── scan/        # Camera, OCR, vCard parsing
│       │   ├── contact_review/ # Review & confirm scanned data
│       │   ├── device_contacts/ # OS contacts integration
│       │   ├── cloud_sync/  # API calls + offline queue
│       │   ├── history/     # Contact list & detail
│       │   ├── messaging/   # Email preview & send
│       │   └── settings/    # User preferences
│       └── shared/          # Shared widgets
├── backend/         # FastAPI + Celery (Python 3.12)
│   ├── app/
│   │   ├── api/routes/      # HTTP endpoints
│   │   ├── domain/services/ # Business logic
│   │   ├── repositories/    # Data access (SQLAlchemy async)
│   │   ├── providers/       # Email, OCR, enrichment (pluggable)
│   │   ├── tasks/           # Celery async tasks
│   │   └── observability/   # Logging, Sentry
│   ├── alembic/             # DB migrations
│   └── tests/
├── infra/           # Docker Compose, Dockerfiles, env templates
└── docs/            # Architecture, OpenAPI spec, ADRs
```

## API Documentation

- OpenAPI spec: `docs/openapi.yaml`
- Interactive docs (when running): http://localhost:8000/docs

## Architecture

See `docs/architecture.md` for the full system diagram and design decisions.

## Key Design Principles

1. **Consent-first**: Explicit opt-in for both device save AND email send. Email default is OFF.
2. **No auto-posting**: Only "suggest profiles" and "copy message" — user acts manually in social apps.
3. **Offline-first scan**: Drafts saved locally when offline, synced when back online.
4. **Provider pattern**: Email/OCR/enrichment providers are swappable without changing business logic.
5. **Anti-spam**: 20 emails/day limit, single-contact-at-a-time, unsubscribe footer.

## Environment Variables

Copy `infra/.env.example` to `infra/.env` and configure:

| Variable | Description | Required |
|----------|-------------|----------|
| `SECRET_KEY` | JWT signing key (32+ chars random) | Yes |
| `SENDGRID_API_KEY` | SendGrid API key for email | Yes (or Mailgun/SES) |
| `POSTGRES_PASSWORD` | DB password | Yes |
| `SENTRY_DSN` | Sentry DSN for error tracking | No |
| `EMAIL_DAILY_LIMIT` | Max emails per user per day | No (default: 20) |

## MVP Acceptance Criteria

- [x] 95%+ of Latin-script business cards correctly parsed (after manual confirmation)
- [x] Contact added to device phone book reliably
- [x] Follow-up email sent via reliable provider with logs and retries
- [x] Contact history with basic tags in app
