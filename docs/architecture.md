# NetworkHub — Architecture Overview (MVP v0.1)

## System Diagram

```
┌──────────────────────────────────────────────────────────────────────┐
│                          Mobile App (Flutter)                        │
│                                                                      │
│  ┌──────────┐  ┌───────────────┐  ┌──────────────┐  ┌───────────┐  │
│  │  Scan    │  │Contact Review │  │  History     │  │ Settings  │  │
│  │  Module  │  │   Module      │  │  Module      │  │  Module   │  │
│  └────┬─────┘  └──────┬────────┘  └──────┬───────┘  └─────┬─────┘  │
│       │               │                  │                 │        │
│  ┌────▼───────────────▼──────────────────▼─────────────────▼──────┐ │
│  │               Core Layer                                        │ │
│  │  ApiClient (Dio) │ OfflineQueue (Hive) │ LocalStorage           │ │
│  └────────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────┬────────────────────────────────┘
                                      │ HTTPS / JWT
                                      ▼
┌──────────────────────────────────────────────────────────────────────┐
│                       Backend (FastAPI + Python 3.12)                │
│                                                                      │
│  ┌─────────────────────────────────────────────────────────────┐    │
│  │                      API Layer (FastAPI)                     │    │
│  │  /auth  /contacts  /events  /templates  /jobs               │    │
│  └───────────────────────────┬─────────────────────────────────┘    │
│                              │                                       │
│  ┌───────────────────────────▼─────────────────────────────────┐    │
│  │                    Domain Services                           │    │
│  │  ContactService │ ConsentService │ TemplateService │ Auth   │    │
│  └───────────────────────────┬─────────────────────────────────┘    │
│                              │                                       │
│  ┌───────────────────────────▼─────────────────────────────────┐    │
│  │               Repository Layer (SQLAlchemy 2.0 async)       │    │
│  └───────────────────────────┬─────────────────────────────────┘    │
│                              │                                       │
│           ┌──────────────────┴──────────────────┐                   │
│           ▼                                     ▼                   │
│    ┌──────────────┐                    ┌──────────────────┐          │
│    │  PostgreSQL  │                    │  Redis           │          │
│    │  (data)      │                    │  (cache + queue) │          │
│    └──────────────┘                    └────────┬─────────┘          │
│                                                 │                   │
└─────────────────────────────────────────────────┼───────────────────┘
                                                  │ Celery broker
┌─────────────────────────────────────────────────▼───────────────────┐
│                       Worker (Celery)                                │
│                                                                      │
│  send_followup_email  │  enrich_contact  │  dedupe_suggest           │
│                                                                      │
│  ┌────────────────────────────────────────────────────────────┐     │
│  │                  Provider Abstractions                      │     │
│  │  EmailProvider: SendGrid | Mailgun | SES                   │     │
│  │  EnrichmentProvider: PythonNormalize | OpenClaw (MVP+)     │     │
│  │  ProfileDiscovery: Stub | Real (MVP+)                      │     │
│  └────────────────────────────────────────────────────────────┘     │
└──────────────────────────────────────────────────────────────────────┘
```

## Module Descriptions

### Mobile (Flutter)

| Module | Responsibility |
|--------|---------------|
| `scan` | Camera capture, gallery import, ML Kit OCR, QR/vCard parsing, field extraction |
| `contact_review` | Form UI, validation, tags, event picker, consent toggles |
| `device_contacts` | OS permissions, create/update device contacts, dedup by email/phone |
| `cloud_sync` | REST API calls, offline queue (Hive), sync pending drafts |
| `history` | Contact list, search/filter, contact detail, interaction timeline |
| `messaging` | Email preview, send toggle, job status polling |
| `settings` | User profile, signature, default template |
| `core` | API client (Dio + auth interceptor), local storage, connectivity, error handling |

### Backend (FastAPI)

| Module | Responsibility |
|--------|---------------|
| `api/routes` | HTTP endpoints, request validation, response serialization |
| `domain/services` | Business logic (rate limits, idempotency, template rendering) |
| `repositories` | Database access via SQLAlchemy async, query abstraction |
| `providers` | Pluggable integrations (email, enrichment, profile discovery) |
| `tasks` | Celery async tasks with retry/backoff |
| `observability` | Structured logging (structlog), Sentry error tracking |

## Key Design Decisions

### 1. Provider Pattern
All external integrations are behind abstract base classes. Swap providers without changing business logic:
```python
class EmailProvider(ABC):
    async def send(self, to: str, subject: str, body: str) -> str: ...
```

### 2. Consent-First
Two explicit consents stored in `consents` table:
- `consent_device`: Add to phone contacts (shown first, default ON if user initiates scan)
- `consent_email`: Send follow-up email (default **OFF**, user must opt in explicitly)

### 3. Idempotency
Email jobs use a composite idempotency key: `sha256(user_id + contact_id + template_id + date_bucket)`
Prevents duplicate emails if user retaps "send".

### 4. Offline-First Scan
When network unavailable: contact draft saved to Hive (local) with status `pending_sync`.
A background sync service checks connectivity and uploads when online.

### 5. Rate Limiting (Anti-spam)
`EmailService.check_daily_limit()` counts `email_jobs` with `status=sent` for the current day.
Returns 400 if limit exceeded (default: 20/day/user, configurable via env).

### 6. OCR Architecture
- **Primary**: Google ML Kit on-device (fast, private, no API cost)
- **Fallback**: Manual input if OCR quality is poor
- **Future**: Server-side OCR via `ocr_provider.py` abstraction (e.g. Google Vision API, AWS Textract)

## Data Flow: Scan → Save → Email

```
User taps Scan
    → Camera captures image
    → ML Kit OCR extracts text
    → BusinessCardExtractor structures fields (regex + heuristics)
    → Review screen shows editable DraftContact
    → User confirms + sets consent_email toggle
    → [if network] POST /contacts → Backend creates DB record
    → [if no network] Save to Hive OfflineQueue → sync later
    → [if consent_device] DeviceContactsService.createContact()
    → [if consent_email] POST /contacts/{id}/send_email
        → Backend checks daily limit
        → Creates EmailJob (status: queued)
        → Celery task: send_followup_email
            → Renders Jinja2 template
            → EmailProvider.send()
            → Updates job status → sent/failed
            → Creates Interaction record
    → History screen updates
```

## Roadmap (Post-MVP)

| Feature | Notes |
|---------|-------|
| Profile Discovery | POST /contacts/{id}/discover_profiles — best-effort LinkedIn/X/GitHub search |
| Matching | Graph: user ↔ tags ↔ events ↔ contacts. "You should meet" recommendations |
| CRM Export | HubSpot/Salesforce/Google Contacts sync. CSV/vCard export |
| OpenClaw Integration | Replace PythonNormalizeProvider with OpenClaw enrichment endpoint |
| Ads / Monetization | Separate monetization module, no mixing with core domain |
| Unsubscribe | Proper unsubscribe link in email footer with tracking |
