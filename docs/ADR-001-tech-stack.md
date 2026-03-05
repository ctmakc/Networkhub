# ADR-001: Technology Stack Selection

**Status**: Accepted
**Date**: 2026-03-05
**Context**: Selecting the technology stack for NetworkHub MVP

## Decision

### Mobile: Flutter (Dart)
**Why**: Single codebase for iOS + Android, fast iteration, excellent camera/contacts plugins, Google ML Kit available.
**Alternatives considered**: React Native (rejected: contacts APIs less mature), native (rejected: 2x development cost).

### Backend: FastAPI (Python 3.12)
**Why**: Fast development, async-first, auto OpenAPI docs, excellent ecosystem for data/AI work (future enrichment).
**Alternatives considered**: Node.js/Express (rejected: team prefers Python), Django (rejected: more opinionated, async harder).

### Database: PostgreSQL
**Why**: JSONB for flexible contact fields (emails[], phones[]), full ACID, excellent async driver (asyncpg).

### Queue: Redis + Celery
**Why**: Proven combination, simple retry/backoff, Flower monitoring UI, easy local dev with docker-compose.

### Email: SendGrid (primary)
**Why**: Reliable deliverability, template management, webhooks for status. Provider abstraction allows switching.

### OCR: Google ML Kit (on-device)
**Why**: Free, fast, offline, privacy-preserving. No API cost per scan. Accuracy ~95% for printed business cards in English.

## Consequences
- Python knowledge required for backend
- Flutter/Dart learning curve for mobile devs coming from native
- Provider pattern adds initial complexity but enables flexibility
