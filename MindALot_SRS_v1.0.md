# Software Requirements Specification (SRS)
## MindALot — Mental Health & Wellness Mobile Application

---

| Document Title | Software Requirements Specification — MindALot |
|---------------|------------------------------------------------|
| Version | 1.0 |
| Date | April 3, 2026 |
| Prepared By | MIGS |
| Status | Draft — Awaiting Customer Sign-off |
| Customer | Zenit / Jagrati Education |

---

## Table of Contents

1. Introduction
2. Overall Description
3. User Types & Roles
4. Functional Requirements
   - 4.1 Authentication & Onboarding
   - 4.2 Home Screen
   - 4.3 Mood Tracker
   - 4.4 Mood-Responsive Theming
   - 4.5 Chat
   - 4.6 Call Booking
   - 4.7 Knowledge Hub
   - 4.8 Self Evaluation Tests
   - 4.9 Reminders
   - 4.10 Tracker
   - 4.11 Subscription & Payments
   - 4.12 Profile Management
   - 4.13 Settings
   - 4.14 SOS Feature
   - 4.15 Crisis Safety Net
   - 4.16 Hidden Admin / Counsellor Access
   - 4.17 Counsellor In-App View
   - 4.18 Admin Dashboard (Odoo)
5. Non-Functional Requirements
6. Technical Architecture
7. Design System
8. Delivery Milestones
9. Assumptions & Dependencies
10. Sign-off

---

## 1. Introduction

### 1.1 Purpose
This document defines the complete functional and non-functional requirements for the **MindALot** mobile application. It serves as the authoritative reference for design, development, testing, and customer sign-off.

### 1.2 Scope
MindALot is a mental health and wellness platform delivered as a mobile application (iOS and Android). It connects users — primarily students, youth, and individuals dealing with depression, anxiety, and related challenges — with certified counsellors for real-time support. The platform also provides self-help resources, mood tracking, guided exercises, and subscription-based premium services.

### 1.3 Intended Audience
- Customer / Product Owner (sign-off)
- Development Team
- Quality Assurance Team
- UI/UX Designers
- Backend/API Engineers

### 1.4 Current User Base
Approximately **15,000 active users** across institutional and individual customers, scaling to 50,000+.

### 1.5 References
- Zenit Features (2).xlsx — Customer-provided feature specification
- Existing MindALot App Screenshots (April 2026)
- Odoo Zenit Management Admin Panel Screenshots

---

## 2. Overall Description

### 2.1 Product Overview
MindALot delivers:
- Anonymous, judgment-free access to certified counsellors via chat and video/audio call
- Mood tracking with therapeutic visual and audio experiences
- A Knowledge Hub with curated mental wellness content
- Self-evaluation psychological tests
- Subscription-based premium tiers for individuals and institutions

### 2.2 Core Design Principles
1. **Anonymity First** — User identity is never logged, stored, or exposed. Users choose their own alias.
2. **Non-Clinical Tone** — The app uses warm, approachable language and visuals. It must never feel like a medical application.
3. **24/7 Availability** — Users must always feel supported. The system must never display "no counsellor available."
4. **Safety Net Always Present** — Crisis helpline information is accessible at all times, especially during subscription cutoffs or wait times.
5. **Privacy by Design** — No real names stored, no chat recordings beyond 24-hour counsellor summaries, no session data shared beyond authorised roles.

### 2.3 Business Model

#### B2B — Educational Institutions
- Institution purchases a subscription covering a fixed number of users.
- MindALot Admin generates anonymous usernames + passwords in bulk.
- Credentials are delivered to the institution's administrator who distributes them.
- Users never register themselves; they receive credentials from their institution.

#### B2B — Corporate
- Same model as Educational Institutions.
- Different profile fields and reporting structures.

#### B2C — Individual Users (Zenit Users)
- Users self-register using phone number + OTP.
- Free tier provides 5 minutes of chat per session.
- Paid subscription unlocks full access.
- Payment handled in-app via Razorpay or BillDesk.

---

## 3. User Types & Roles

### 3.1 End Users (Mobile App)

| User Type | How They Join | Subscription | Chat Free Limit |
|-----------|--------------|--------------|-----------------|
| B2B Educational | Admin bulk-creates credentials | Institution pays | 5 min (audio call free) |
| B2B Corporate | Admin bulk-creates credentials | Institution pays | 5 min |
| B2C Individual | Self-register (phone + OTP) | Self-purchases | 5 min |

### 3.2 Internal Roles (Admin Panel + Hidden In-App Login)

| Role | Access Level | Created By |
|------|-------------|------------|
| Counsellor | Assigned users only; chat + call support | Analyst or above |
| Admin | Clients, clubs, users, content, reports | Analyst or above |
| Analyst | All admin features + subscription + analytics | Super Admin only |
| Super Admin | Full access including deleted messages, all clients | System |

---

## 4. Functional Requirements

---

### 4.1 Authentication & Onboarding

#### 4.1.1 Splash Screen
- On app launch, display the MindALot brand mascot (cloud character) with an animated "Breathe in / Breathe out" cycle.
- No text beyond the animation — pure calming entry point.

#### 4.1.2 Onboarding Slides (First-Time Users Only)
Three skippable slides presented on first launch:
1. **"Understand your emotions"** — Reflect on your day, log your mood, discover what your mind needs.
2. **"Real people, Real conversations"** — Every message you send is read and responded to by certified professionals.
3. **"Inner Compass: Your Guide to Wellness"** — Access helpful blogs, daily tips, and guided activities — all in one place. → "Get Started" button.

#### 4.1.3 User Type Selection (Landing Page)
After onboarding, user selects their type:
- **Corporate User** (B2B Corporate — has credentials)
- **School / College User** (B2B Educational — has credentials)
- **New User** (B2C — self-registration)

Each option displays an appropriate illustration.

#### 4.1.4 B2B Login
- Fields: Username, Password (show/hide toggle)
- "Forgot Password" link → redirects to website for reset
- Terms & Conditions checkbox — login button disabled until checked
- Credentials pre-generated by admin; delivered through institution

#### 4.1.5 B2C Registration
- Field: Phone Number → OTP verification
- After OTP: user sets their preferred alias (how counsellors will refer to them)
- User sets password
- User ID auto-generated in format: alias@Zenit.com
- Auto-assigned to "Zenit Users" client / general club in backend
- Profile completion prompted after first subscription payment

#### 4.1.6 Forgot Password
- Show/hide password toggle while typing
- Forgot password → redirect to website
- Website requests mail ID → Admin resets password and sends to mail

#### 4.1.7 Multi-Device Login
- Same credentials allowed on max 2 devices
- Only one device can access chat at a time
- Second device attempting chat sees: *"You are already chatting from another device."*

---

### 4.2 Home Screen

**Layout:**
- Header: Hamburger menu icon (quick access drawer) | MindALot logo (centre) | Notification bell (right)
- Personalised greeting: "Hi [alias], Good Morning / Afternoon / Evening" (time-based auto-switch)
- Daily motivational quote (refreshes at 12:00 midnight; calendar-based, admin-managed)
- 3D cloud mascot (animated)
- Mood check-in section: 5 emoji icons
- Action buttons: **Call** | **Chat**
- Bottom navigation bar: Home | Knowledge Hub | Profile

**Quick Access Drawer (hamburger):**
Home → Profile → Knowledge Hub → Reminders → Tracker → Subscription → Settings → Log Out
Additional: History | Suicide Helpline (always visible, links to crisis resources)

---

### 4.3 Mood Tracker

#### 4.3.1 Daily Time Buckets
The day is divided into 4 time buckets:
| Bucket | Time Range |
|--------|-----------|
| 1 | 12:00 AM – 8:00 AM |
| 2 | 8:00 AM – 12:00 PM |
| 3 | 12:00 PM – 6:00 PM |
| 4 | 6:00 PM – 12:00 AM |

#### 4.3.2 Mood Selection Rules
- User may log their mood **once per bucket** — not changeable once submitted within that bucket.
- 5 mood options: Happy | Sad | Anxious | Frustrated/Angry | Confused
- Once selected, mood is **locked until the end of the current bucket** (server-side enforcement — cannot be bypassed by force-closing the app).
- Lock duration is admin-configurable.

#### 4.3.3 Backend Tracking
- Mood entries stored with: anonymous user alias, client/club, mood type, timestamp.
- Accessible to Analyst role and above.
- Classwise monthly data for Educational Institutions.
- Monthly trend graphs for Corporate clients.
- Individual mood history per B2C user.

---

### 4.4 Mood-Responsive Theming

Upon mood selection, the entire app UI transitions to a mood-specific theme:

| Mood | Background | Primary Colors | Music / Ambience | Psychological Basis |
|------|-----------|---------------|-----------------|-------------------|
| **Happy** | Golden sunrise over meadow, warm light rays | Gold #F5C842, amber, cream | Birdsong + gentle breeze + acoustic guitar | Fredrickson's Broaden-and-Build Theory — warm gold sustains positive affect |
| **Sad** | Cozy rain on window, candlelight glow indoors | Warm amber #D4845A, soft peach, terracotta | Soft piano + slow rain + cello undertones | Emotional Processing Theory (Foa & Kozak) — warm tones avoid blue which deepens low-arousal sadness |
| **Anxious** | Forest canopy — sunlight filtering through tall trees, gentle leaf movement | Soft green #7DBF8E, sage, earth tones | Forest ambience + distant stream + theta binaural beats (4–8 Hz) | Shinrin-yoku (forest bathing) — reduces cortisol by up to 16%; theta binaural beats reduce anxiety |
| **Frustrated / Angry** | Vast open ocean — slow rolling waves, wide horizon | Deep ocean blue #2E6E8E, teal, seafoam | Rhythmic ocean waves at ~6 breaths/min, low ambient tones | Blue Mind Theory (Nichols 2014) + HRV cardiac coherence breathing at 0.1Hz |
| **Confused** | Starry night sky / cosmos, slow zoom-out from Earth | Deep lavender #9B7FD4, violet, silver-white | Soft Bach/Mozart orchestral, slow tempo | Mozart Effect (Rauscher 1993) + cognitive perspective-taking via "overview effect" |

**Behaviour:**
- Theme transition is animated (smooth fade).
- Background is a Lottie animation loop (lightweight, vector-based).
- Music auto-plays on mood selection.
- User can **mute/unmute music** without changing the mood or theme.
- Theme persists until the current time bucket ends (matches mood lock period).
- Assets (Lottie files + audio) stored on Firebase Storage; downloaded once and cached locally on device.

---

### 4.5 Chat

#### 4.5.1 User Experience
- Empty chat window on every new session (no history visible to user).
- WhatsApp-like input: multi-line text, emoji support.
- No image attachment, no voice note, no file sharing.
- No delete option for users.
- "Typing..." indicator shown when counsellor is composing.
- End Chat button terminates and clears the session.
- Exiting the chat screen also ends the session.

#### 4.5.2 Freemium Chat Model
- **First 5 minutes are free for all users** (B2C free users, B2B users).
- A visible countdown timer is displayed in the chat UI (e.g., "Free session: 4:32 remaining").
- At 5 minutes:
  - **Paid subscriber:** session continues uninterrupted.
  - **Free / unsubscribed user:** session is terminated with an empathetic message:
    *"Your free session has ended. To continue speaking with your counsellor, please subscribe to a plan."*
    + Upgrade to subscription CTA
    + Crisis helpline numbers always shown alongside cutoff message.
- The 5-minute free window resets per chat session.

#### 4.5.3 Automated First-Message Response
- When user sends their first message in a session, an automated message is sent immediately:
  *"Thank you for reaching out. A counsellor will be with you shortly. You are not alone."*
- This triggers the counsellor notification system.

#### 4.5.4 Counsellor Notification & Assignment
- Notification (push + in-app chime) sent to **all counsellors who have fewer than 2 active chats**.
- First counsellor to accept the request claims the session.
- All other counsellors' notifications clear; they see which counsellor accepted.
- Chat timer starts from the moment counsellor accepts.
- If all counsellors are at capacity (2 chats each):
  - User sees: *"Connecting you to your counsellor, please hold on..."* (animated mascot).
  - If wait exceeds 5 minutes (admin-configurable), auto-send crisis helpline message.
  - User is never shown "no counsellor available."

#### 4.5.5 Message Deletion Rules
- Counsellors may delete their own messages **during an active session only**.
- After session ends: no deletion by anyone except Super Admin.
- Super Admin always has access to deleted messages via audit log.

#### 4.5.6 Chat Summary (Counsellor Responsibility)
- Counsellor must submit a session summary within 24 hours of session end.
- Counsellor has access to full chat transcript for 24 hours post-session.
- After 24 hours: counsellor can only view their submitted summary (not full transcript).
- Admin and above: always have access to full chat history.

#### 4.5.7 Chat Feedback
- After chat ends, user is shown a feedback screen:
  - Star rating (1–5)
  - Optional comment field
  - Skip option
- Feedback stored against: anonymous user ID, club, counsellor ID, star rating, date, time, comment.

#### 4.5.8 Missed Chat Report
- System generates a report of all unattended chat requests under "Missed Chats."

---

### 4.6 Call Booking

#### 4.6.1 Booking Flow
1. User selects available date from calendar.
2. User selects available time slot.
3. User selects call type:
   - **Audio Call:** User enters phone number or checks "Use my profile number."
   - **Video Call:** System generates a video call link; shown in call history.
4. Booking confirmed; reminder sent 1 hour before.

#### 4.6.2 Subscription Rules for Calls
| User Type | Audio Call | Video Call |
|-----------|-----------|------------|
| B2B Educational | Free | Requires subscription |
| B2B Corporate | Per plan | Per plan |
| B2C Free | 5-min chat only | Not available |
| B2C Paid | Included in plan | Included in plan |

#### 4.6.3 Cancellation & Rescheduling
- Allowed up to **1 hour before** the scheduled call.
- Reschedule is disabled within 1 hour of call.
- **3 or more no-shows:** 30 minutes deducted from user's total call time balance.
- No-show credits: 5 minutes added to each counsellor's payment tracker.

#### 4.6.4 Call Notifications
- Reminder push notification 1 hour before call.
- Cancel/Reschedule option included in reminder.
- No reminder sent if call is within 30 minutes of booking.

#### 4.6.5 Call History
- Scheduled calls (upcoming)
- Completed calls (with duration)
- Missed / unattended calls (color-coded)
- Video call links: clickable + copyable

#### 4.6.6 Call Feedback
- Pop-up rating prompt on next app open after a completed call (Uber-style).
- Star rating recorded.

#### 4.6.7 Counsellor Call Dashboard
- Incoming call requests shown with: user alias, call type, scheduled time, phone/video link.
- Ringer is continuous until accepted.
- Highlighted on-screen when call time is imminent.
- After call: prompted to submit call summary; upload any relevant reference.

---

### 4.7 Knowledge Hub

**User View:**
- 5 content categories: Videos | Audios & Podcasts | Blogs | Images & Posts | Self Evaluation Tests
- Each category has subfolders and a search bar.
- Streaming only — no downloads permitted.
- Content is club-specific (user sees content assigned to their club).

**Admin View:**
- Upload content → select category → select folder → select clubs → set go-live date and time.
- View content analytics (view count per item).
- Edit or delete uploaded content.
- Instagram/Pupil Tube-like browsing interface.

---

### 4.8 Self Evaluation Tests

**User:**
- MCQ format psychological self-assessment.
- Results displayed based on score ranges with descriptive feedback.
- One test allowed per month per user.
- Access based on subscription plan.

**Admin:**
- Upload and update tests.
- View individual and aggregate results.
- Assign specific tests to specific users or clubs.
- Analyse population-level results.

---

### 4.9 Reminders

**User:**
- Bell icon (top right) with unread badge count.
- Latest reminders shown at the top.
- Mark as "Done" (tick box) — once marked, cannot be undone.
- Clickable links within reminders (open in-app or external browser).
- Track response history per reminder.

**Admin (Bulk Upload):**
- Upload via Excel template: ID | User ID | Date | Time | Text / Link
- Reminders auto-dispatched at specified date and time.
- Dashboard view: Total reminders sent | Total marked Done.

---

### 4.10 Tracker

Accessible from Quick Access Drawer:
- **Usage History:** Session dates and durations.
- **Chat Timings:** Auto-calculated from session start (counsellor accepts) to session end.
- **Call Timings:** Based on counsellor-submitted call summaries.
- **Subscription History:** Shows plan type only — no payment details, no financial data.

---

### 4.11 Subscription & Payments

#### 4.11.1 B2B Subscription
- Admin assigns subscription plan to a Club.
- All users under that Club automatically receive the plan.
- When institution's subscription expires, all users under it lose premium access.
- Expiry warning notification sent to institution admin before cutoff.

#### 4.11.2 B2C Subscription (In-App Purchase)
- User views available plans and selects one.
- Two payment gateways available:
  - **Razorpay** — UPI, cards, netbanking, wallets (primary for Indian users)
  - **BillDesk** — widely used in Indian institutions and banks (secondary)
- Payment flow:
  1. User selects plan.
  2. User selects payment gateway.
  3. Payment processed via selected gateway SDK.
  4. Gateway sends webhook to backend.
  5. **Backend confirms payment server-side before unlocking access** (client-side confirmation is never trusted).
  6. Subscription activated immediately upon confirmed payment.
- Auto-renewal available with explicit user consent.
- Payment receipt stored against anonymous user ID only — never real name.
- Graceful payment failure screen with retry option.

#### 4.11.3 International Payments (Future)
- Multiple currency packages (INR / USD) based on geographical location.
- International payment gateways to be added in a later version.

#### 4.11.4 Subscription Expiry
- Expired subscription screen always displays crisis helpline numbers alongside the renewal prompt.

---

### 4.12 Profile Management

#### 4.12.1 B2B Educational Institution User Profile
| Field | Editable | Mandatory |
|-------|---------|-----------|
| Name | No (pre-filled) | Yes |
| Date of Birth | Yes | Yes |
| Phone | Yes | Yes |
| Email | Yes | Yes |
| Gender | Yes | Yes |
| Organisation Name | No (pre-filled) | Yes |
| Nationality | Yes | No |
| City | Yes | No |
| Language | Yes | Yes |
| Class | No (pre-filled) | Yes |
| Section | No (pre-filled) | Yes |
| Father's Name | Yes | No |
| Father's Occupation | Yes | No |
| Mother's Name | Yes | No |
| Mother's Occupation | Yes | No |
| Goal | Yes | No |
| Photo | Yes | No |
| Emergency Contact | Yes | Yes |

#### 4.12.2 B2B Corporate User Profile
| Field | Editable | Mandatory |
|-------|---------|-----------|
| Name | No (pre-filled) | Yes |
| Date of Birth | Yes | Yes |
| Phone | Yes | Yes |
| Email | Yes | Yes |
| Gender | Yes | Yes |
| Year | Yes | No |
| Organisation Name | No (pre-filled) | Yes |
| Language | Yes | Yes |
| Nationality | Yes | No |
| City | Yes | No |
| Marital Status | Yes | No |
| Goal | Yes | No |
| Photo | Yes | No |
| Emergency Contact | Yes | Yes |

#### 4.12.3 B2C User Profile
| Field | Editable | Mandatory |
|-------|---------|-----------|
| Alias / Display Name | Yes | Yes |
| Date of Birth | Yes | No |
| Phone | No (from OTP) | Yes |
| Email | Yes | No |
| Gender | Yes | No |
| User Type | Yes | No |
| Marital Status | Yes | No |
| Language | Yes | Yes |
| Nationality | Yes | No |
| City | Yes | No |
| Emergency Contact | Yes | Yes |
| Goal | Yes | No |
| Photo | Yes | No |

Unanswered optional fields display "—" (dash), not blank.

---

### 4.13 Settings

- **Change Password** — done in-app (NOT redirected to website)
- **Choose Language** — dropdown for available languages
- **Privacy Policy** — in-app view

---

### 4.14 SOS Feature *(Priority 5 — Planned for Later Version)*

- Dedicated SOS button (accessible from drawer or home screen).
- On tap: sends an automated emergency message including the user's live GPS location to a pre-set emergency contact number.
- Target use cases: Government mental health programmes, corporate women safety initiatives.
- Emergency contact configured during profile setup.

---

### 4.15 Crisis Safety Net

The following crisis helpline information is shown in ALL of these situations:
1. Free user's 5-minute chat session is cut off.
2. User has been waiting for a counsellor for more than 5 minutes (admin-configurable).
3. Subscription expired screen.
4. Quick Access Drawer: "Suicide Helpline" link permanently visible.

**Standard message:**
> *"If you are in immediate distress or crisis, please reach out to these free, confidential helplines:"*
> - **iCall:** 9152987821 (Monday–Saturday, 8:00 AM – 10:00 PM)
> - **Vandrevala Foundation Helpline:** 1860-2662-345 (24/7)
> - **iCall Online Chat:** icallhelpline.org

Helpline numbers and message are admin-configurable from Odoo.

---

### 4.16 Hidden Admin / Counsellor Access

- A hidden, unlabelled tap zone exists on the app (exact location: TBD — options include logo, mascot, or blank corner of welcome screen).
- **Tapping the hidden zone 3 times** reveals the Admin/Counsellor login screen.
- This screen is completely invisible in normal user navigation — no link, no menu entry, no hint.
- Login page has: Role selector (Admin / Counsellor) | Username | Password
- Failed login attempts are silent — no error message that reveals the page's existence to an unauthorised user.
- Separate credentials for Admin and Counsellor roles.

---

### 4.17 Counsellor In-App View

Accessed via hidden triple-tap login.

**Dashboard:**
- Incoming chat request notifications (push + chime) — only received if currently handling fewer than 2 active chats.
- Accept or dismiss incoming request.
- Maximum 2 active chat sessions simultaneously.
- Each chat window shows: user alias + current mood + active mood theme.

**Chat Rules for Counsellor:**
- Cannot initiate chat — response only.
- Can delete own messages during active session only.
- Must submit session summary within 24 hours.
- Access to full transcript for 24 hours; summary only thereafter.

**Users Tab:**
- Lists only users assigned to counsellor's clubs.
- View-only; clicking a user shows limited profile + engagement history.

**Clubs Tab:**
- Lists clubs where counsellor is assigned.
- Click club to see counsellors and users within it.

**Reports Tab:**
- Today's sessions: time, user alias, engagement type, summary, actions.
- Personal tracker: select date range; view total chat time and call time.

**Knowledge Hub:**
- View-only access to content library.
- Can see which clubs have access to each piece of content.

**Availability:**
- Counsellor status is never shown as "offline" or "unavailable" to end users.
- The 24/7 promise is always maintained on the user-facing interface.

---

### 4.18 Admin Dashboard (Odoo — Zenit Management)

The admin panel runs on Odoo (existing Zenit Management module). The mobile app **never directly calls Odoo** — all mobile API requests go through a lightweight Node.js middleware layer.

**Admin Navigation (Quick Drawer):**
Dashboard → Team → Clients [Edu Inst | Corporate | Zenit Users] → Users → Clubs → Reports → Knowledge Hub → Analytics → Bulk Upload Management

**Key Admin Capabilities:**
- Create and manage Clients (Educational / Corporate / B2C)
- Create Clubs under Clients; assign counsellors to clubs
- Bulk create users (Excel upload) with auto-generated anonymous credentials
- Manage subscriptions: create plans, assign to clubs
- Upload and schedule Knowledge Hub content
- Upload daily motivational quotes
- Send bulk reminders via Excel template
- Monitor all chat requests, call bookings, mood tracker data
- View analytics: User Analytics | Counseling Analytics | Subscription Analytics | Mood Tracker Analytics
- Configure: mood lock duration, wait-time threshold for crisis message, helpline numbers
- Super Admin: access to all deleted message audit logs, all client data

**Role-Based Access Summary:**
| Feature | Counsellor | Admin | Analyst | Super Admin |
|---------|-----------|-------|---------|-------------|
| View assigned users | Yes | Yes | Yes | Yes |
| Create/edit clients | No | Yes | Yes | Yes |
| Create counsellors/admins | No | No | Yes | Yes |
| View all clients | No | Assigned only | All | All |
| Subscription management | No | Assigned clubs | Yes | Yes |
| Analytics | No | Assigned clubs | All | All |
| Full chat history | No | Yes | Yes | Yes |
| Deleted messages audit | No | No | No | Yes |
| System configuration | No | No | No | Yes |

---

## 5. Non-Functional Requirements

### 5.1 Privacy & Security
- No real names stored in application logs or analytics.
- User identity linked only to their alias/anonymous ID.
- Chat transcripts accessible only to authorised roles; auto-purged beyond defined retention period (TBD).
- Payment data handled entirely by Razorpay/BillDesk — never stored on MindALot servers.
- HTTPS for all API communication.
- All passwords hashed (bcrypt or equivalent).
- Webhook signature verification for payment callbacks.

### 5.2 Performance
- App launch to home screen: under 3 seconds on a standard 4G connection.
- Chat message delivery: under 1 second in normal network conditions.
- Mood theme transition animation: smooth, no frame drops on mid-range devices (2018+).
- Support 15,000 concurrent users at launch; architecture to scale to 50,000+.

### 5.3 Availability
- Target uptime: 99.5% (excluding scheduled maintenance).
- Push notifications for counsellors must deliver even when app is in background or closed.

### 5.4 Platform Support
- iOS: version 13 and above.
- Android: version 8.0 (Oreo) and above.
- Both phone and tablet layouts.

### 5.5 Offline Behaviour
- Mood theme assets (Lottie animations + audio) cached locally after first download.
- Mood themes function fully offline after initial cache.
- Chat and call require active internet connection.

### 5.6 Accessibility
- Font sizes: minimum 14sp body text.
- All interactive elements have appropriate touch targets (minimum 44x44pt).
- Colour contrast meets WCAG AA standard.

---

## 6. Technical Architecture

```
┌─────────────────────────────────────────────┐
│             Flutter Mobile App               │
│         (iOS + Android — single codebase)    │
└────────────┬────────────────────────────────┘
             │
     ┌───────▼────────┐      ┌──────────────────┐
     │  Node.js REST  │◄────►│  Odoo (Zenit Mgmt │
     │  API Layer     │      │  Admin Panel only) │
     └───────┬────────┘      └──────────────────┘
             │
     ┌───────▼────────┐
     │  PostgreSQL     │  Main data store
     │  (users, moods, │  (subscriptions,
     │  sessions, logs) │  sessions, audit)
     └───────┬────────┘
             │
     ┌───────▼────────┐
     │  Redis          │  Chat queues
     │                 │  Mood lock timers
     │                 │  Counsellor capacity
     └────────────────┘

┌──────────────────────────────────────────────┐
│  Additional Services                          │
│  ├── Socket.IO          Real-time chat        │
│  ├── FCM                Push notifications    │
│  ├── Firebase Storage   Mood assets (cached)  │
│  ├── Razorpay SDK       B2C payments          │
│  └── BillDesk SDK       B2C payments          │
└──────────────────────────────────────────────┘
```

**Key principle:** The mobile app never calls Odoo directly. All requests go through the Node.js API layer, which syncs with Odoo in the background for admin panel data consistency.

---

## 7. Design System

| Element | Specification |
|---------|--------------|
| Primary background | Soft mint / teal — #E8F4F4 |
| Primary CTA | Warm dark brown — #5C3D2E |
| Card background | White |
| Typography | Clean sans-serif; bold headings, light body |
| Mascot | Cloud character — changes pose per screen context |
| Tone | Soft, warm, non-clinical |
| Animations | Lottie (vector-based, lightweight) |
| Icons | Outlined, rounded — consistent set |

---

## 8. Delivery Milestones

| Version | Target Date | Scope |
|---------|------------|-------|
| **V1** | April 2026 end | Core: login, home, mood tracker (basic), chat (basic), call booking, reminders, profile, subscription UI |
| **V2** | July 2026 end | Mood themes + music, freemium chat timer, counsellor in-app view, Knowledge Hub, self-evaluation tests, Razorpay + BillDesk payments |
| **V3** | October 2026 end | Analytics dashboard, bulk upload management, advanced counsellor tools, chat feedback, call feedback, tracker |
| **V4** | December 2026 end | SOS feature, international payments, multi-language support |
| **V5** | 2027 | AI chatbot integration, AI translation, advanced mood theming (Spotify, Swiggy integration) |
| **V6** | Future | Separate counsellor app, full AI pipeline |

---

## 9. Assumptions & Dependencies

1. Odoo (Zenit Management) backend remains operational and accessible via API.
2. Customer provides Razorpay and BillDesk merchant accounts and API keys.
3. Customer provides Firebase project credentials (for FCM and Storage).
4. Lottie animation assets and audio files for all 5 mood themes will be sourced/created by the design team.
5. Counsellors are available and actively monitoring the app during service hours.
6. Customer's legal team reviews and approves the crisis helpline content and cutoff message wording.
7. Customer is responsible for DPDP Act (India) and applicable data privacy compliance review.
8. B2B institutional admins are responsible for distributing credentials to end users.
9. All third-party SDKs (Razorpay, BillDesk) are subject to their own terms of service.

---

## 10. Sign-off

By signing below, the Customer confirms that this document accurately represents the agreed requirements for the MindALot application.

---

**Customer Representative**

Name: ___________________________

Designation: ___________________________

Organisation: ___________________________

Signature: ___________________________

Date: ___________________________

---

**MIGS Representative**

Name: ___________________________

Designation: ___________________________

Signature: ___________________________

Date: ___________________________

---

*This document is version 1.0. Any changes to requirements after sign-off must be submitted as a formal Change Request and may impact timeline and cost.*
