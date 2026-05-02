# TARAsense Flutter API Guide

## ⚠️ Critical Finding: Mobile APIs Are Missing

Your TARAsense backend has **two separate API layers**:

1. **NestJS API** (`api/` — runs on port 4000) — Has auth, files, FIC availability, and jobs
2. **Next.js Server Actions** (`src/app/actions/`) — Handle 90% of business logic (studies, participants, responses, screening, etc.)

**The problem:** Next.js Server Actions CANNOT be called from Flutter. They only work inside the Next.js app. The mobile API routes documented in `MOBILE_API_LIVE_DEPLOY.md` were **planned but never implemented**.

---

## ✅ What Currently Works (Existing HTTP APIs)

### 1. NestJS API (Port 4000, prefix `/api`)

Base URL: `http://YOUR_SERVER:4000/api` or `https://tarasense.dostcaraga.ph/api`

#### Authentication Endpoints

| Method | Endpoint | Auth | Request Body | Response |
|--------|----------|------|--------------|----------|
| `POST` | `/auth/register` | No | `{"name":"...","email":"...","password":"...","organization?":"...","role?":"CONSUMER"}` | `{"user":{"id","email","name","role","organization","createdAt","updatedAt"},"accessToken":"...","refreshToken":"...","tokenType":"Bearer"}` |
| `POST` | `/auth/login` | No | `{"email":"...","password":"..."}` | Same as register |
| `POST` | `/auth/refresh` | No | `{"refreshToken":"..."}` | Same as register |
| `POST` | `/auth/logout` | Bearer JWT | `{"refreshToken?":"..."}` | `{"ok":true,"tokenRevoked?":true}` |
| `GET`  | `/auth/me` | Bearer JWT | — | `{"id","email","name","role","organization","createdAt","updatedAt"}` |
| `GET`  | `/auth/introspect` | Bearer JWT | — | `{"active":true,"user":{...}}` |
| `POST` | `/auth/admin/register` | Bearer JWT + ADMIN role | Same as register | Same as register |

**Important:** Self-registration forces role to `CONSUMER`. Only `ADMIN` can create users with other roles.

#### FIC Availability Endpoints

| Method | Endpoint | Auth | Query/Body | Response |
|--------|----------|------|------------|----------|
| `GET` | `/fic-availability/calendar/:ficUserId` | Bearer JWT | `?startDate=YYYY-MM-DD&endDate=YYYY-MM-DD` | Calendar array |
| `GET` | `/fic-availability/available-fics` | Bearer JWT | `?startDate&endDate&region?&facility?` | Available FICs array |
| `POST` | `/fic-availability/bulk` | Bearer JWT | Body: `{"dates":["2025-04-01",...]}` Query: `?ficUserId?` | Bulk update result |
| `PATCH` | `/fic-availability/:ficUserId/:date` | Bearer JWT | Body: `{"isAvailable?":true,"isLocked?":false}` | Updated availability |

**Roles required:** `ADMIN`, `FIC`, or `FIC_MANAGER` for calendar/bulk/patch. `ADMIN` or `MSME` for available-fics.

#### File Storage Endpoints

| Method | Endpoint | Auth | Request | Response |
|--------|----------|------|---------|----------|
| `POST` | `/files/upload` | Bearer JWT | `multipart/form-data` with `file` field (max 20MB) | `{"file":{"id","bucket","objectKey","uploaderId","createdAt"}}` |
| `POST` | `/files/signed-upload` | Bearer JWT | `{"filename":"...","contentType":"..."}` | `{"uploadUrl":"...","fileId":"..."}` |
| `GET` | `/files` | Bearer JWT | `?limit=50` | `{"files":[...]}` |
| `GET` | `/files/:fileId/signed-download` | Bearer JWT | — | `{"downloadUrl":"..."}` (10 min expiry) |

**Roles required:** `ADMIN`, `MSME`, or `FIC`.

#### Other NestJS Endpoints

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| `GET` | `/health` | No | DB + Redis health check |
| `GET` | `/audit/logs?limit=100` | Bearer JWT + ADMIN | Audit logs (max 500) |
| `POST` | `/jobs` | Bearer JWT | Enqueue background job |
| `GET` | `/jobs/:jobId` | Bearer JWT | Get job status |
| `GET` | `/api/sensory-analysis/study/:studyId` | No | Run sensory analysis (note double `/api`) |

---

### 2. Next.js API Routes (Same origin, `/api/*`)

These exist in the Next.js app but are mostly duplicates or web-specific:

| Method | Route | Description |
|--------|-------|-------------|
| `GET` | `/api/fic-availability/calendar/:ficUserId` | Same as NestJS |
| `GET` | `/api/fic-availability/available-fics` | Same as NestJS |
| `POST` | `/api/fic-availability/bulk` | Same as NestJS |
| `PATCH` | `/api/fic-availability/:ficUserId/:date` | Same as NestJS |
| `GET` | `/api/studies/:studyId/analysis?refresh=1` | Get study analysis |
| `GET` | `/api/studies/:studyId/master-list` | Download CSV |
| `POST` | `/api/jobs/session-reminders` | Cron job (needs `x-cron-secret`) |

---

## ❌ What Is MISSING for Flutter

The following features exist in the web app (via Server Actions) but have **NO HTTP API endpoints** for mobile:

### Consumer / Panelist APIs
- [ ] `GET /mobile/studies` — List available studies to join
- [ ] `GET /mobile/studies/:id` — Get study details
- [ ] `POST /mobile/studies/:id/screening` — Submit screening responses
- [ ] `POST /mobile/studies/:id/participate` — Join a study
- [ ] `POST /mobile/studies/:id/consent` — Submit consent
- [ ] `POST /mobile/studies/:id/responses` — Submit sensory test responses
- [ ] `GET /mobile/participant/sessions` — View my upcoming sessions
- [ ] `GET /mobile/notifications` — Get my notifications
- [ ] `PATCH /mobile/notifications/read` — Mark notifications as read
- [ ] `GET /mobile/profile` — Get full profile (including Panelist data)
- [ ] `PATCH /mobile/profile` — Update profile

### MSME APIs
- [ ] `GET /mobile/msme/dashboard` — Dashboard stats
- [ ] `GET /mobile/msme/studies` — List my studies
- [ ] `POST /mobile/msme/studies` — Create a study
- [ ] `GET /mobile/msme/studies/:id` — Study detail with participants
- [ ] `GET /mobile/msme/study-builder-options` — Dropdown options for study builder
- [ ] `GET /mobile/msme/studies/:id/participants` — List participants
- [ ] `POST /mobile/msme/studies/:id/invite` — Send invitations
- [ ] `POST /mobile/msme/studies/:id/confirm` — Confirm participant sessions

### FIC APIs
- [ ] `GET /mobile/fic/schedule` — View booked sessions
- [ ] `POST /mobile/fic/assign-sample-codes` — Assign sample codes

### Admin APIs
- [ ] `GET /mobile/admin/users` — User management
- [ ] `PATCH /mobile/admin/users/:id/role` — Reassign roles
- [ ] `GET /mobile/admin/role-requests` — Pending role upgrades

---

## 🔧 How to Fix This

You have **two options:**

### Option A: Create Mobile API Routes in Next.js (Recommended)

Create `src/app/api/mobile/*` routes that wrap the existing Prisma logic. The `MOBILE_API_LIVE_DEPLOY.md` already planned these files:

```
src/app/api/mobile/health/route.ts
src/app/api/mobile/auth/login/route.ts
src/app/api/mobile/auth/register/route.ts
src/app/api/mobile/auth/refresh/route.ts
src/app/api/mobile/auth/me/route.ts
src/app/api/mobile/auth/logout/route.ts
src/app/api/mobile/profile/route.ts
src/app/api/mobile/msme/dashboard/route.ts
src/app/api/mobile/msme/study-builder-options/route.ts
src/app/api/mobile/msme/studies/route.ts
```

**Pros:** Same database, same deployment, minimal infrastructure changes.
**Cons:** You need to build these routes.

### Option B: Expand the NestJS API

Add new controllers/modules to `api/src/` for studies, participants, responses, etc.

**Pros:** Clean separation, proper Swagger docs potential, dedicated auth system already works.
**Cons:** More work, duplicates some logic from Next.js.

---

## 📋 Flutter Integration Checklist

### Immediate (works today with NestJS)
- [ ] Use `/api/auth/login` for authentication
- [ ] Store `accessToken` and `refreshToken` securely (Flutter Secure Storage)
- [ ] Attach `Authorization: Bearer <accessToken>` to every request
- [ ] Implement token refresh using `/api/auth/refresh` when 401 occurs
- [ ] Call `/api/auth/me` to get user profile

### Required Backend Work
- [ ] Implement missing mobile API routes (see "What Is MISSING" above)
- [ ] Ensure CORS allows your Flutter app origin
- [ ] Add `SESSION_SECRET` env var if using Next.js mobile routes

### Data Models Your Flutter App Needs

Based on `prisma/schema.prisma`, your models should include:

```dart
// User
class User {
  String id;
  String email;
  String name;
  String role; // ADMIN, MSME, FIC, CONSUMER, RESEARCHER, FIC_MANAGER
  String? organization;
  DateTime createdAt;
  DateTime updatedAt;
}

// Study
class Study {
  String id;
  String title;
  String productName;
  String category; // BEVERAGE, SNACK, etc.
  String stage; // PROTOTYPE_CHECK, REFINEMENT, MARKET_READINESS
  String status; // DRAFT, RECRUITING, ACTIVE, ANALYZING, COMPLETED, ARCHIVED
  String? description;
  int sampleSize;
  String location;
  DateTime createdAt;
}

// StudyParticipant
class StudyParticipant {
  String id;
  String studyId;
  String status; // SELECTED, WAITLIST, CONFIRMED, COMPLETED, CANCELLED, DECLINED
  String? stratum;
  DateTime? sessionAt;
  DateTime? confirmedAt;
}

// Notification
class Notification {
  String id;
  String title;
  String message;
  String level; // INFO, SUCCESS, WARNING, ERROR
  String category; // AUTH, STUDY, ROLE, SURVEY, SYSTEM
  bool isRead;
  DateTime createdAt;
}

// Panelist (Consumer profile)
class Panelist {
  String id;
  String name;
  String email;
  String? phone;
  int age;
  String gender;
  String location;
  List<String> lifestyle;
  List<String> dietaryPrefs;
}
```

---

## 🔗 Environment Configuration for Flutter

```dart
class ApiConfig {
  // Production
  static const String baseUrl = 'https://tarasense.dostcaraga.ph/api';
  
  // If using NestJS API directly
  static const String nestJsBaseUrl = 'https://tarasense.dostcaraga.ph/api';
  
  // If using Next.js mobile routes (once deployed)
  static const String mobileBaseUrl = 'https://tarasense.dostcaraga.ph/api/mobile';
}
```

---

## 🚀 Recommended Next Steps

1. **Tell me which user roles your Flutter app needs** (Consumer only? MSME? FIC? All?)
2. **I can build the missing mobile API routes** in either Next.js (`src/app/api/mobile/*`) or NestJS (`api/src/*`)
3. **I can generate Dart model classes** for your Flutter app
4. **I can create a Flutter API service layer** (Dart code) with interceptors for auth, refresh, and error handling

Which role(s) does your Flutter app target, and which approach do you prefer for the backend?
