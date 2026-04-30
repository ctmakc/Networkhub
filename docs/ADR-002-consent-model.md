# ADR-002: Consent Model for Contact & Email Actions

**Status**: Accepted
**Date**: 2026-03-05

## Context
We need explicit user consent before:
1. Saving a contact to the device phone book (involves OS permission)
2. Sending an email to the contact (external communication, anti-spam compliance)

## Decision
Two separate consent flags, tracked in the `consents` table per (user, contact) pair:

| Flag | Default | Description |
|------|---------|-------------|
| `consent_device` | ON | Add to device contacts (user initiates scan, so implied intent) |
| `consent_email` | **OFF** | Send follow-up email. Must be explicitly toggled ON by user. |

### UI Enforcement
- Review screen shows two labeled toggles, clearly distinct
- Email toggle is visually de-emphasized (secondary position, disabled appearance)
- Preview screen is shown before sending (user sees exact email content)

### Backend Enforcement
- `POST /contacts/{id}/send_email` checks `consents.consent_email = true`
- Returns HTTP 400 with `"consent_not_given"` code if not consented
- Consent timestamp recorded for audit

### Anti-Spam Rules (MVP)
- No bulk selection (one contact at a time in MVP)
- Daily limit: 20 emails/user/day (configurable)
- Unsubscribe footer text included in all emails
- No auto-send: always requires explicit user action

## Consequences
- Slightly more friction in send flow (intended)
- Clear audit trail for compliance
- Email default OFF may reduce send rate, but protects brand and users
