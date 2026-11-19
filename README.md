  # INSY7314 POE Part 3 (Final Submission)
## **HustleHub+ Secure Freelance Marketplace**
## Overview
HustleHub+ is a freelance marketplace platform that requires security to ensure the users of the system their data safety especially since this platform is associated with financial data. The platform will be using sensitive information such as user credentials, transactional records, and income related data as the platform will be helping record generated booking financial records as well as help users with indication of incomes earned and estimate tax obligations.
### The Intended User Base
- Clients
- Freelancers
- Administrators of the application

On the HustleHub+ platform freelancers use the platform to advertise their services to clients so that they can get their services booked and achieve financial gain. Clients can browse and gain information on possible services to ensure proper communication on provided services. Admins are there to ensure the proper running of the platform to ensure security and functionality for all users.

### Pipeline runs
<img width="1473" height="627" alt="image" src="https://github.com/user-attachments/assets/d4275e9f-a909-4ba9-8dad-8d3534b17618" />


### What Each Part Delivered
This README documents the complete application. Part 1 delivered a secure authentication API with users held in memory. Part 2 turned it into the full MERN application:

- **React frontend** - a single-page app built with Vite [1], with a separate dashboard for clients, freelancers and admins.
- **MongoDB database** - Mongoose models for users, gigs, bookings and transactions replace the in-memory store.
- **Domain services** - gigs, bookings with a status workflow and reviews, simulated transactions, and a freelancer income summary with a tax estimate.
- **Access control** - role checks and ownership checks on every protected route, plus admin user management.
- **More security controls** - NoSQL-injection and parameter-pollution protection, HTML stripping, per-endpoint rate limiters, two-factor authentication (required for admins), account lockout, and a browser idle-session timer.
- **Testing** - a 113-request Postman/Newman collection, backend self-checks, 60 frontend tests, `npm audit` and an OWASP ZAP scan.
- **DevOps** - Docker Compose for the whole stack and a GitHub Actions pipeline.

Part 3 completes it:

- **Tax and income dashboard** - an estimate of each freelancer's income tax using the SARS 2026/27 rates, with every step of the working shown, plus income charts by month and by gig (see [Tax and Income Dashboard](#tax-and-income-dashboard)).
- **CI/CD pipeline** - backend unit and Newman integration tests, frontend unit tests and Playwright end-to-end tests, builds, dependency audits and security scans. Any failure fails the build (see [CI Pipeline](#ci-pipeline)).
- **Static code analysis** - Semgrep and SonarQube Cloud run in the pipeline.
- **Docker in the pipeline** - the full Compose stack is built and started in CI, then scanned with OWASP ZAP and Trivy and tested with Playwright.
- **Cloud logging** - logins, bookings, transactions and errors are sent to Grafana Cloud Loki and shown on a dashboard (see [Logging](#logging)).
- **Security review and own security features** - a threat review with every threat matched to its control, and three extra security features chosen by the group: a breached-password check, session revocation so an idle sign-out ends the session on the server, and locked-down containers (see [Security Review](#security-review-threats-and-controls) and [Own Security Features](#own-security-features)).

### What Each Role Can Do

| Role | Features |
|------|----------|
| Client | Browse and view gigs, book a gig, cancel a pending booking, view receipts, review completed bookings, see spending |
| Freelancer | Create, edit, pause and delete own gigs, accept, decline and complete bookings, see earnings and estimated tax |
| Admin | List, search and view users and delete users; view every live gig and remove any of them; view every booking with its transaction reference (read-only) |

Every role can also change their display name and password in Settings.

## Project Structure

```
├── docker-compose.yml         # mongo + api + client containers
├── mongo-init.js              # creates the API's limited MongoDB user
├── zap.yaml                   # OWASP ZAP scan plan (report: zap-report.html)
├── .github/workflows/ci.yml   # CI pipeline
├── .github/zap-api-active.yaml # ZAP active scan plan for the API, run by CI
├── API/
│   ├── server.js              # HTTPS entry point, secret checks, connects to Mongo, boots the app
│   ├── app.js                 # Express app: middleware pipeline, routes, error handling
│   ├── Dockerfile
│   ├── config/
│   │   └── db.js              # MongoDB connection
│   ├── controllers/
│   │   ├── authController.js      # register, login, logout, profile, password change
│   │   ├── gigController.js       # gig CRUD with ownership checks
│   │   ├── bookingController.js   # bookings, status workflow, reviews, transactions
│   │   ├── incomeController.js    # freelancer income summary and tax estimate
│   │   ├── userController.js      # admin user management
│   │   └── *.check.js             # assert-based self-checks
│   ├── middleware/
│   │   ├── auth.js                # requireAuth (JWT from cookie or Bearer), requireRole (RBAC)
│   │   ├── validators.js          # Input validation for every write endpoint
│   │   ├── sanitize.js            # NoSQL injection, parameter pollution, HTML stripping
│   │   ├── rateLimiters.js        # Global, login, register, booking, password and MFA limiters
│   │   ├── securityHeaders.js     # Helmet, CSP, HSTS, no-store
│   │   ├── requestLogger.js       # Request id and one log line per finished request
│   │   └── errorHandler.js        # Centralised error responses (no internal leakage)
│   ├── models/
│   │   ├── User.js
│   │   ├── Gig.js
│   │   ├── Booking.js
│   │   └── Transaction.js
│   ├── routes/
│   │   ├── authRoutes.js          # /api/auth
│   │   ├── gigRoutes.js           # /api/gigs
│   │   ├── bookingRoutes.js       # /api/bookings
│   │   ├── incomeRoutes.js        # /api/income
│   │   └── userRoutes.js          # /api/users (admin only)
│   ├── utils/
│   │   ├── logger.js              # Structured JSON logs with secret redaction
│   │   ├── totp.js                # Two-factor codes, secret encryption, recovery codes
│   │   └── generateToken.js       # JWT signing
│   └── postman/                   # Part 1 and Part 2 collections, captured Newman run
└── frontend/
    ├── Dockerfile                 # Multi-stage build, served by nginx
    ├── nginx.conf.template        # HTTPS only, security headers
    ├── vite.config.js             # HTTPS dev server, CSP for the built app, Vitest config
    └── src/
        ├── App.jsx                # Session restore, login/register switch
        ├── services/api.js        # API client (cookie auth, safe error messages)
        ├── hooks/useIdleLogout.js # Inactivity timeout
        ├── components/            # Forms, dashboard shell, dialogs, charts
        └── screens/               # One screen per dashboard tab
```

The separation of routes, middleware, controllers and models within their respective folders allow the code solution to have isolated responsibilities to keep logic concise and easy to understand as well as easy to add to bolster the solution. The frontend follows the same idea: screens hold the pages, components hold the reusable parts, and all API calls go through one service file.

## Architecture Diagram

![HustleHub+ architecture](HustleHubArchitecture.png)

The diagram covers the full MERN design. Part 1 implemented the request pipeline and authentication. **Part 2 implements the boxes that were deferred to it:** the React SPA, MongoDB/Mongoose, `express-mongo-sanitize` + `hpp`, and the domain services (Gigs, Bookings, Transactions, Income/Tax). Part 3 adds the tax dashboard, the full CI/CD pipeline with static analysis, Docker in the pipeline and cloud logging to Grafana Cloud (see [Logging](#logging)). Deployment to a hosting provider was optional and was not done. The request flow (client → HTTPS → middleware pipeline → validation → auth → RBAC → controllers → services) is identical in every part.

### Request Pipeline
Every request passes through the same middleware, in this order ([app.js](API/app.js)):

```js
app.use(requestLogger);
app.use(securityHeaders);
app.use(cors({ origin: allowedOrigins, credentials: true }));
app.use(globalLimiter);
app.use(express.json({ limit: "10kb" }));
app.use(noSqlInjection);
app.use(parameterPollution);
```

Routes then add their own checks. Creating a booking, for example, runs authentication, the role check, a per-user rate limiter, HTML stripping and validation before the controller ([routes/bookingRoutes.js](API/routes/bookingRoutes.js)):

```js
router.use(requireAuth);
router.post("/", requireRole("client"), bookingLimiter, sanitizeInput(["note"]), validateBooking, createBooking);
```

## Data Model

Four Mongoose models ([API/models](API/models)):

| Model | Key fields | Security and integrity notes |
|-------|-----------|------------------------------|
| **User** | `name`, `email` (unique, lowercased), `passwordHash`, `role`, `tokenVersion`, `failedLogins`, `lockedUntil`, `mfaEnabled`, `mfaSecret`, `mfaLastStep`, `mfaRecoveryHashes` | `passwordHash` is `select: false`, so no query returns it unless it is asked for explicitly, and the lockout and two-factor fields are the same (except `mfaEnabled`). The two-factor secret is encrypted and the recovery codes are hashed. `role` is an enum of `client`, `freelancer`, `admin`. |
| **Gig** | `title`, `description`, `category`, `price`, `deliveryDays`, `active`, `freelancer` | Length and range limits in the schema. `freelancer` is the owner, taken from the JWT and checked on every edit and delete. |
| **Booking** | `gig`, `client`, `freelancer`, `gigTitle`, `price`, `date`, `note`, `status`, `review` | `gigTitle` and `price` are snapshotted at booking time, so a later gig edit or delete cannot change what was agreed. `status` is an enum. |
| **Transaction** | `reference`, `booking` (unique), `client`, `freelancer`, `amount`, `status` | One per booking, enforced by a unique index. `reference` is a random `TX-` code. Payment is simulated. |

A booking moves **Pending → Accepted → Completed**. A freelancer may decline a pending booking and a client may cancel one; either marks the transaction as refunded. A freelancer's income is the sum of their transactions whose booking is Accepted or Completed.

## Tax and Income Dashboard

A freelancer's **Earnings** tab shows what they have earned and an estimate of the income tax they owe on it. The API works out every figure ([controllers/incomeController.js](API/controllers/incomeController.js)), and the screen only displays it ([screens/Earnings.jsx](frontend/src/screens/Earnings.jsx)).

![Freelancer Earnings screen with income totals, estimated tax and charts](Screenshots/freelancer-earnings.png)

### What the Freelancer Sees

| Part of the screen | What it shows |
|--------------------|---------------|
| **Summary cards** | Total income, paid out (Completed bookings), in progress (Accepted bookings) and the estimated tax for the current tax year |
| **How your tax estimate works** | The tax worked out step by step: the income in each bracket, the tax on it, the rebate taken off and the result, plus the effective and marginal rates in plain words |
| **Income by month** | A bar chart of income per month, by the booking's start date |
| **Income by gig** | A donut chart of which gigs earn the most. The top four are shown and the rest are grouped as "Other" |
| **Transactions** | Every earning booking with its `TX-` reference, client and amount |

The charts are drawn with plain SVG ([components/Charts.jsx](frontend/src/components/Charts.jsx)), so no charting library was added. Each chart has an `aria-label` that reads out its values for screen readers.

### How South African Income Tax Works
We based the calculation on how SARS taxes individuals [47]:

- **The tax is progressive.** Income is split into brackets, and each rate applies only to the part of the income inside its bracket. Earning more never lowers what you keep, because only the extra rands are taxed at the higher rate.
- **Everyone gets a primary rebate.** It is subtracted from the tax, not from the income. For 2026/27 it is **R17,820**.
- **The tax threshold follows from the rebate.** Below **R99,000** a person under 65 owes nothing, because 18% of R99,000 is R17,820, exactly the rebate.
- **The tax year runs from 1 March to the end of February.** So January 2027 falls in the 2026/27 year.

SARS 2026/27 rates for individuals (1 March 2026 to 28 February 2027) [47]:

| Taxable income (R) | Rate |
|--------------------|------|
| 0 – 245,100 | 18% of taxable income |
| 245,101 – 383,100 | 44,118 + 26% of the amount above 245,100 |
| 383,101 – 530,200 | 79,998 + 31% of the amount above 383,100 |
| 530,201 – 695,800 | 125,599 + 36% of the amount above 530,200 |
| 695,801 – 887,000 | 185,215 + 39% of the amount above 695,800 |
| 887,001 – 1,878,600 | 259,783 + 41% of the amount above 887,000 |
| 1,878,601 and above | 666,339 + 45% of the amount above 1,878,600 |

### How the Estimate Is Calculated
1. **Choose the income.** Only bookings that are Accepted or Completed count. Pending bookings have not been agreed yet, and Declined or Cancelled ones were refunded. Only bookings dated in the **current tax year** count, because the brackets apply to one year's income.
2. **Tax each bracket.** The income is walked through the brackets from the bottom, and each part is taxed at its own rate. Each part is rounded to the cent, so the lines on screen add up exactly.
3. **Take off the rebate.** The primary rebate is subtracted. The result never goes below zero.
4. **Show the rates.** The *effective rate* is the share of all income that goes to tax. The *marginal rate* is the rate on the next rand earned.

**Worked example: R300,000 of income in 2026/27**

| Step | Amount |
|------|--------|
| First R245,100 at 18% | R44,118.00 |
| Next R54,900 (R245,101 – R300,000) at 26% | R14,274.00 |
| Tax before rebate | R58,392.00 |
| Less primary rebate | − R17,820.00 |
| **Estimated tax** | **R40,572.00** |
| Effective rate (40,572 ÷ 300,000) | 13.52% |
| Marginal rate | 26% |

This gives the same answer as SARS's own formula for the second bracket: R44,118 + 26% × (R300,000 − R245,100) − R17,820 = R40,572.

### What the Estimate Leaves Out
The screen says clearly that the figure is a guide and not tax advice. It treats booking income as taxable income, so it does not:

- subtract business expenses a freelancer can claim
- include income from outside HustleHub+
- apply the extra rebates for people aged 65 and over (R9,765) or 75 and over (R3,249) [47], because the app does not store a user's age

Freelancers earn income that is not a salary, so SARS treats them as provisional taxpayers. They pay tax in advance in two payments: by the end of August and by the last business day of February [48]. The estimate helps a freelancer plan for those payments, but the app does not file anything with SARS. The rates are held in one table in the controller, and the response names the rates year, so updating them for a new tax year means changing one table.

### Keeping the Income Data Secure
- **Only the freelancer can see their own income.** `GET /api/income` takes the freelancer's id from their verified sign-in, never from the request, so changing a number in the request cannot show someone else's figures (threat **T13**). Clients and admins get `403`.
- **The calculation happens on the server.** The browser cannot change the figures it is shown.
- **Prices cannot be changed after booking.** Each booking stores the price agreed at booking time, so editing or deleting a gig later does not change past income (threat **T6**).
- **The data is protected in transit and is not cached.** It is sent only over HTTPS, and `Cache-Control: no-store` stops the browser keeping a copy on a shared computer (threats **T11** and **T15**).
- **Every transaction is logged.** Each one is recorded with who made it, and the records are sent to Grafana Cloud (see [Logging](#logging)).

### How It Is Tested
`npm run test:income` ([controllers/income.check.js](API/controllers/income.check.js)) runs in CI and checks:

- the worked example above, to the cent
- the R99,000 threshold: R99,000 owes R0, and R100,000 owes R180
- the top bracket: R2,000,000 owes R703,149, with a marginal rate of 45%
- rounding to the cent
- the tax-year boundaries: 28 February and 1 March
- that only Accepted and Completed bookings count as income

The Newman collection's **04 Income** folder also checks over HTTP that only freelancers can reach the endpoint.

## Security Review: Threats and Controls

**In Plain Terms**
Before deciding how to protect HustleHub+, we asked one question: what could someone with bad intentions try to do to this app, and what stops them? This kind of exercise is called a threat review. Each "threat" is one realistic way of attacking the app, and each "control" is the protection we built against it.

HustleHub+ holds four kinds of information worth protecting:

- Login details: users' passwords and the digital "pass" (a token) that keeps them signed in
- Bookings and payments: who booked what, for how much, and the transaction records
- Income and tax figures: what each freelancer has earned and owes
- Personal details: names and email addresses

To make sure no type of attack was missed, we sorted the threats with STRIDE, a checklist used across the industry [45]. Each letter is one kind of attack:

| Letter | Type of attack | In everyday terms |
| :---: | :--- | :--- |
| **S** | Spoofing | Pretending to be someone else, e.g. logging in with a stolen password |
| **T** | Tampering | Secretly changing data, e.g. lowering the price of a booking |
| **R** | Repudiation | Doing something and then denying it, with no record to prove otherwise |
| **I** | Information disclosure | Seeing information you are not allowed to see |
| **D** | Denial of service | Overloading the app so real users cannot use it |
| **E** | Elevation of privilege | Giving yourself more power than you should have, e.g. becoming an admin |

We also matched each threat to the OWASP Top 10 [12], the best-known list of the ten most common security problems in web applications (A01 to A10). This shows the app covers every one of them.

### Threat → Control Table

Each row reads left to right. The first part of the "How we stop it" column explains the protection in plain language. The technical detail follows it for readers who want it. The "Where" column links to the code, and the Security Decisions section after this one explains each control in full.


| # | The threat, in plain words | Type | OWASP | How we stop it | Where | Ref |
| :--- | :--- | :---: | :---: | :--- | :--- | :---: |
| **T1** | Someone tries thousands of passwords until one works | S | A07 | Too many wrong guesses get blocked, and weak passwords are refused. Login is limited to 5 attempts per 15 minutes per address. An account locks for 15 minutes after 10 failures. Passwords known from past data breaches are rejected when an account is created | `rateLimiters.js`, `authController.js`, `breachedPassword.js` | \[8\], \[19\] |
| **T2** | Someone steals or fakes the digital pass that keeps a user signed in | S | A07 | The pass expires quickly, is checked on every request, and can be cancelled. JWT signed with HS256 and checked for issuer and audience. It expires after 1 hour. A tokenVersion cancels it on logout or password change | `auth.js`, `generateToken.js` | \[6\], \[7\] |
| **T3** | An admin's password is stolen | S, E | A07 | Admins also need a code from their phone. Admin features stay locked (403) until two-factor authentication is on. Each code works only once | `auth.js`, `totp.js` | \[7\] |
| **T4** | Someone walks away from a shared computer while still signed in | S | A07 | The app signs them out by itself after 15 minutes of no activity. The browser timer also cancels the session on the server | `useIdleLogout.js`, `Dashboard.jsx` | \[8\] |
| **T5** | A malicious website tricks a signed-in user's browser into making a booking or change | T | A01 | The browser only sends the user's sign-in to HustleHub+ itself, never to other sites. SameSite=Strict cookie, and CORS only allows the HustleHub+ frontend | `authController.js`, `app.js` | \[10\], \[13\] |
| **T6** | A client changes the price of a gig before booking, or claims to own someone else's gig | T | A04 | The app ignores prices and owners sent by the user and uses its own records. Validators keep only allowed fields. Price, owner, client and freelancer come from the database or the sign-in, and the price is fixed at booking time | `validators.js`, `bookingController.js` | \[22\] |
| **T7** | A booking is pushed to "completed" without being accepted, or charged twice | T | A04 | Bookings must follow the proper steps, and each one can only have one payment. Status changes are checked per role and refused with 409. A unique index allows one transaction per booking | `bookingController.js`, `Transaction.js` | \[11\] |
| **T8** | Someone types database commands into a form to trick the database | T | A03 | Anything that looks like a database command is stripped out before it gets near the database. express-mongo-sanitize and hpp run on every request, and validators accept only plain text and numbers | `sanitize.js`, `validators.js` | \[25\], \[26\], \[27\] |
| **T9** | Someone hides harmful code in a gig description or review so it runs in other users' browsers | T, I | A03 | Code is removed from text, and the browser is told not to run anything it did not load from HustleHub+. HTML is stripped from free text. React escapes output, and the Content-Security-Policy blocks inline scripts | `sanitize.js`, `nginx.conf.template` | \[15\], \[28\], \[29\] |
| **T10** | A fake website shows HustleHub+ in a hidden frame to trick users into clicking buttons | T | A05 | HustleHub+ refuses to be shown inside another website. X-Frame-Options: DENY and frame-ancestors 'none' | `securityHeaders.js`, `nginx.conf.template` | \[17\] |
| **T11** | Someone on the same Wi-Fi reads or changes data on its way between the user and the app | I, T | A02 | All traffic is encrypted, the same way online banking is. HTTPS only, with TLS 1.2 or newer, and HSTS tells browsers never to use an unencrypted connection | `server.js`, `nginx.conf.template` | \[16\], \[30\], \[31\] |
| **T12** | The database is stolen and the attacker reads the passwords | I | A02 | Passwords are stored scrambled so they cannot be turned back into the original. bcrypt at cost 12 with a unique salt. Two-factor secrets are encrypted (AES-256-GCM) and recovery codes are hashed | `authController.js`, `User.js`, `totp.js` | \[3\] |
| **T13** | A user changes a number in the web address to view someone else's booking or income | I | A01 | Every request checks that the record belongs to the person asking. Ownership is checked in each controller. Non-owners get "not found", so they cannot tell the record exists | `bookingController.js`, `gigController.js`, `incomeController.js` | \[11\] |
| **T14** | Error messages reveal how the system is built, or whether an email address has an account | I | A05, A07 | Users only ever see short, general messages. A central error handler hides internal details. Login gives the same message and takes the same time whether the email exists or not | `errorHandler.js`, `authController.js`, `api.js` | \[32\] |
| **T15** | Financial pages are saved on a shared computer and read by the next person | I | A05 | The browser is told never to keep a copy. Cache-Control: no-store on every API response | `securityHeaders.js` | \[17\] |
| **T16** | Someone floods the app with requests so real users cannot get in | D | A04 | Each user and address has a limit on how fast it can make requests, and oversized requests are refused. Global and per-endpoint rate limiters, and request bodies capped at 10 KB | `rateLimiters.js`, `app.js`, `validators.js` | \[19\], \[20\] |
| **T17** | Someone does damage and denies it, or an attack goes unnoticed | R | A09 | Every important action is recorded with who did it and when, and shown on a monitoring dashboard. Structured logs with requestId, ip and userId, sent to Grafana Cloud. Passwords and tokens are never written to the logs | `logger.js`, `requestLogger.js`, `hustlehub-dashboard.json` | \[43\], \[44\] |
| **T18** | A user makes themselves an admin | E | A01 | Nobody can sign up as an admin, and the app checks the user's role on every request. Registration only allows client or freelancer, and the role is read from the database each time | `validators.js`, `auth.js` | \[11\] |
| **T19** | An attacker who breaks into one part of the system uses it to reach the rest | E | A05 | Each part runs in its own locked-down box with as few permissions as possible, and the database is hidden from the internet. Read-only, non-root containers with all capabilities dropped. MongoDB is on an internal network | `docker-compose.yml`, `API/Dockerfile`, `mongo-init.js` | \[33\], \[34\], \[35\] |
| **T20** | A security flaw in a third-party building block the app uses | T, E | A06 | The building blocks are checked against a public list of known flaws, and the website's base image installs the latest security updates. npm audit reports 0 known vulnerabilities in the API (see Testing), and the frontend image runs apk upgrade when it is built | `npm-audit.png`, `frontend/Dockerfile` | \[38\] |
| **T21** | A different, tampered version of a building block ends up in the app | T | A08 | Every building block is locked to an exact, recorded version. package-lock.json records the exact version and checksum of each dependency, and the Docker images install from it with npm ci | `API/Dockerfile`, `frontend/Dockerfile` | \[35\] |
| **T22** | The app is started with a weak or missing secret key | S, I | A05 | The app refuses to start until it is set up safely. It needs a JWT_SECRET of at least 32 characters and a database address. Secret files are never uploaded to GitHub | `server.js`, `docker-compose.yml` | \[34\] |
| **T23** | The server is tricked into fetching a web address chosen by the attacker | I | A10 | The server never visits a web address supplied by a user. Its only outside calls go to two fixed services: the breached-password check and the log service | `breachedPassword.js`, `logger.js` | \[12\] |

### OWASP Top 10 Coverage

Every category on the OWASP Top 10, 2021 list is covered by at least one control above.

| OWASP Top 10:2021 | What it means | Threats above |
| :--- | :--- | :--- |
| **A01** Broken Access Control | Users reaching things they should not | **T5**, **T13**, **T18** |
| **A02** Cryptographic Failures | Sensitive data not properly encrypted | **T11**, **T12** |
| **A03** Injection | Harmful commands or code slipped in through input | **T8**, **T9** |
| **A04** Insecure Design | Weaknesses in how a feature was planned | **T6**, **T7**, **T16** |
| **A05** Security Misconfiguration | Unsafe settings | **T10**, **T14**, **T15**, **T19**, **T22** |
| **A06** Vulnerable and Outdated Components | Third-party parts with known flaws | **T20** |
| **A07** Identification and Authentication Failures | Weak login and sign-in handling | **T1**, **T2**, **T3**, **T4**, **T14** |
| **A08** Software and Data Integrity Failures | Trusting code or updates that could be tampered with | **T21** |
| **A09** Security Logging and Monitoring Failures | Attacks going unrecorded or unnoticed | **T17** |
| **A10** Server-Side Request Forgery | Tricking the server into contacting other systems | **T23** |

### Risks We Accept

No system is perfectly secure. These are the remaining gaps we know about, and why each is acceptable for this project:

- **Test security certificate**: The certificate that encrypts traffic is one we made ourselves for testing, so browsers show a warning. A live version would use a certificate from a trusted provider.
- **Request limits are counted per server**: Each copy of the API keeps its own count. Running several copies would need a shared counter such as Redis. Today there is only one copy.
- **The inactivity timer runs in the browser**: If someone had already stolen a user's sign-in pass, it would keep working until it expires (at most 1 hour) or the user logs out. Both of those cancel it.
- **The breached-password check is skipped if the outside service is down**: If Have I Been Pwned does not answer within 2 seconds, the password is allowed and a warning is recorded. We decided an outage at another company should not stop people signing up.
- **Changing the main secret key affects two-factor**: The key that protects two-factor codes is based on JWT_SECRET, so changing it would mean users have to set up two-factor again.
- **Payments are simulated**: No real money moves. Real payments would bring extra card-industry rules (PCI DSS) that are outside this project.

## Security Decisions
Every decision below is driven by the same fact: HustleHub+ handles user credentials, authentication tokens, and financial records (booking income, tax estimates), so the confidentiality and integrity of that data are the priority.

### Password Hashing
Password hashing converts a user's password into a fixed-length, jumbled string that cannot feasibly be reversed [2]. A secure platform never stores passwords in plain text, so that a database breach does not immediately expose every user's password to attackers.

HustleHub+ uses **bcrypt** with a cost factor of 12 ([controllers/authController.js](API/controllers/authController.js)):

`const bcrypt = require("bcryptjs");`

`const passwordHash = await bcrypt.hash(password, SALT_ROUNDS); // SALT_ROUNDS = 12`

**Why bcrypt, and why cost 12:**
- bcrypt is a deliberately slow, *adaptive* hash. The cost factor sets how many key-expansion rounds are run; it can be raised as hardware gets faster without any other code change.
- bcrypt generates and stores a unique random salt per hash, so two users with the same password get different hashes and precomputed "rainbow table" attacks do not work.
- Cost 12 is above the OWASP minimum of 10 [3]. It adds roughly a quarter of a second per hash - unnoticeable to a user logging in, but expensive for an attacker trying millions of guesses.
- `argon2id` (memory-hard, harder to attack with GPUs) remains a possible future upgrade; the app keeps bcrypt, the well-audited, dependency-light choice.

Password hashes are never logged and never returned in any API response. The `passwordHash` field is excluded from every database query by default (`select: false`), and is only loaded for login and password change.

### JWT Authentication
A JSON Web Token (JWT) is a signed, JSON-based token that lets two parties exchange verified claims [4][5]. After login, the API issues a JWT; the client returns it on later requests and the API verifies the signature, so no server-side session store is needed.

**Signing** ([utils/generateToken.js](API/utils/generateToken.js)):
```js
return jwt.sign(
  { sub: user.id, role: user.role },
  process.env.JWT_SECRET,
  {
    expiresIn: process.env.JWT_EXPIRES_IN || "1h",
    algorithm: "HS256",
    issuer: process.env.APP_NAME,
    audience: ["hustlehubClient"]
  }
);
```

**Verifying** ([middleware/auth.js](API/middleware/auth.js)):
```js
const payload = jwt.verify(token, process.env.JWT_SECRET, {
  algorithms: ["HS256"],
  issuer: [process.env.APP_NAME],
  audience: ["hustlehubClient"]
});
```

**Decisions and why:**
- **Minimal payload:** the token carries only `sub` (user id), `role` and `ver` (the token version, see Session Management). If a token is ever intercepted, no name, email, or other personal data leaks with it.
- **Short-lived:** a 1-hour expiry limits how long a stolen token stays usable.
- **HS256 (symmetric) signing:** the same Express API both issues and verifies tokens - one trusted party, and the secret never leaves the server. Asymmetric signing (RS256) exists so a *separate* service can verify tokens without being able to mint them; there is no such service here, so RS256 would only add key management for no benefit.
- **Algorithm pinned on verify:** `algorithms: ["HS256"]` is set explicitly so the API cannot be tricked into accepting a token signed with `alg: none` or a different algorithm [6].
- **Issuer and audience checked:** every request verifies `iss` and `aud`, not just the signature, so a token minted for a different application is rejected.
- **Mandatory secret:** the server refuses to start if `JWT_SECRET` is missing or shorter than 32 characters ([server.js](API/server.js)), so the signing key can never be weak or absent by accident.

### Session Management
A valid signature alone is not enough. On every request `requireAuth` also loads the user from the database ([middleware/auth.js](API/middleware/auth.js)) [7]:

- **Deleted users are locked out immediately.** If the account no longer exists the token is rejected, even though it has not expired.
- **The role is read from the database, not the token.** `req.user.role` comes from the user record, so a role change takes effect on the next request.
- **Tokens can be revoked.** The user record stores a `tokenVersion`, copied into each token as `ver`, and a token whose version no longer matches is rejected even though it has not expired.
- **Changing a password signs out every other session.** It raises `tokenVersion`, which rejects all existing tokens. The session that made the change receives a fresh token and stays signed in.
- **Logout revokes the session on the server.** It clears the cookie, which is `httpOnly` so only the API can remove it, and raises `tokenVersion`, so a stolen copy of the token stops working too (`POST /api/auth/logout`). Because the version is per user, logging out signs out all of that user's devices. Only a currently valid token can trigger this, so an old stolen one cannot be used to keep signing the user out.
- **Idle timeout in the browser.** The frontend signs the user out after 15 minutes without activity, with a one-minute warning and a "stay signed in" option [8] ([hooks/useIdleLogout.js](frontend/src/hooks/useIdleLogout.js)). The limit can be changed with `VITE_IDLE_MINUTES`.

### Two-Factor Authentication
Any user can turn on two-factor authentication in Settings, using an authenticator app (TOTP, RFC 6238). It is required for admins: until an admin turns it on they can sign in and use their own account, but every admin feature returns `403` ([middleware/auth.js](API/middleware/auth.js)). A single stolen admin password would otherwise give control over every user and booking.

- **Login takes two steps.** With the right password, the API answers `{ mfaRequired: true }` and issues no cookie or token. The frontend then sends the password again with the code, so the API holds no half-finished login state ([controllers/authController.js](API/controllers/authController.js)).
- **Codes can't be guessed or reused.** Wrong codes count towards the account lockout. The time step of each accepted code is stored, and a database condition refuses that step or an earlier one, so an intercepted code cannot be replayed, even by a request at the same moment.
- **The secret is encrypted at rest** with AES-256-GCM, so a database leak alone does not give away codes ([utils/totp.js](API/utils/totp.js)). The key is derived from `JWT_SECRET`, so **rotating `JWT_SECRET` makes existing two-factor secrets unreadable**. Those users could no longer log in until the field is cleared in the database.
- **Recovery codes.** Turning it on shows eight one-time codes once, and only their SHA-256 hashes are stored. A fast hash is fine here because the codes are random, unlike passwords. Using one is logged as a warning.
- **Changes need proof.** Starting setup needs the password, so someone with a stolen session cannot lock the owner out with their own app. Turning it off needs the password and a code. Turning it on or off also signs out every other session, and the `mfaLimiter` limits attempts per user.

### JWT Storage and Transport
On successful register or login the API sets the token in a cookie ([controllers/authController.js](API/controllers/authController.js)):
```js
res.cookie("token", token, {
  httpOnly: true,
  secure: true,
  sameSite: "strict",
  maxAge: 60 * 60 * 1000 // 1 hour, matches the JWT expiry
});
```

**Why an `httpOnly` cookie rather than `localStorage` or a JS variable** [9]**:**
- `httpOnly` means JavaScript cannot read the cookie (`document.cookie` does not see it), so a cross-site scripting (XSS) payload on the page cannot steal the token. A token kept in `localStorage` is readable by any script that runs on the page.
- `Secure` means the cookie is only ever sent over HTTPS, never plain HTTP.
- `SameSite=Strict` means the browser does not attach the cookie to requests that originate from other sites. This closes the CSRF hole that cookies would otherwise open [10], and it is backed up by the CORS allow-list (below).

`requireAuth` reads the token from the cookie first and falls back to an `Authorization: Bearer <token>` header ([middleware/auth.js](API/middleware/auth.js)). The React SPA uses the cookie exclusively: it sends `credentials: 'include'` on every request and never stores or reads the token itself ([services/api.js](frontend/src/services/api.js)). The token is returned in the login/register response body **only when `EXPOSE_TOKEN_IN_BODY=true`** - set for Postman/Newman runs, which have no browser cookie jar. It is off by default, so a normal deployment never puts the token in a response body.

### Access Control
Authentication proves who the user is; access control decides what they may do. HustleHub+ checks both the **role** and the **ownership** of the record, and denies by default [11]. Broken access control is the first item in the OWASP Top 10 [12].

**Role checks** are declared on the route with `requireRole` ([middleware/auth.js](API/middleware/auth.js)), and a wrong role receives `403`:

```js
router.post("/", requireRole("freelancer"), cleanGig, validateGig(false), createGig);   // gigs
router.post("/", requireRole("client"), bookingLimiter, ...);                            // bookings
router.use(requireAuth, requireRole("admin"));                                           // all of /api/users
```

**Ownership checks** are made in the controllers, against the user id from the verified token:
- A freelancer can only edit their own gigs. Only the owner or an admin can delete a gig ([controllers/gigController.js](API/controllers/gigController.js)).
- A booking can only be read or changed by its client or its freelancer; admins may read it. Anyone else receives `404` rather than `403`, so other users cannot probe which booking ids exist ([controllers/bookingController.js](API/controllers/bookingController.js)).
- Each status change is checked against the caller's role: only the freelancer can accept, decline or complete, and only the client can cancel. An invalid transition returns `409`.
- Only the client of a completed booking can review it, and only once.
- The income summary is filtered by the freelancer's id from the token, so a freelancer can never see another freelancer's income.
- An admin cannot delete their own account.

**Values that matter are never taken from the request body.** The owner of a gig, the client and freelancer of a booking, and the price of a booking all come from the token or the database:

```js
const gig = await Gig.create({ ...req.body, freelancer: req.user.id });  // owner from the JWT
price: gig.price, // from the database, never from the request
```

Nobody can register as an admin: registration only accepts `client` or `freelancer`, so an admin account can only be created directly in the database.

The frontend mirrors these rules by showing each role only its own tabs, with an access-denied screen for anything else. This is for usability only; the API is what enforces them.

### CORS
```js
app.use(cors({ origin: allowedOrigins, credentials: true }));
```
The API only accepts cross-origin requests from the configured frontend origin (`CORS_ORIGIN`), and only that origin is permitted to send credentials (the auth cookie) ([app.js](API/app.js)) [13]. Any other website that tries to call the API from a logged-in user's browser is blocked by the browser. Combined with `SameSite=Strict`, a malicious site cannot make authenticated calls on a user's behalf.

### Security Headers
**API** ([middleware/securityHeaders.js](API/middleware/securityHeaders.js)) - Helmet [14] sets the headers on every response:
- **Content-Security-Policy** `default-src 'none'; frame-ancestors 'none'; base-uri 'none'; form-action 'none'`. The API only returns JSON, so it is allowed to load nothing at all [15].
- **Strict-Transport-Security** for one year, including subdomains [16].
- **X-Frame-Options: DENY** and **Referrer-Policy: no-referrer**.
- **Cache-Control: no-store** on every response, so responses containing personal or financial data are never kept by a browser or proxy cache [17].
- Helmet also removes the `X-Powered-By` header, so the API does not advertise that it runs on Express.

**Frontend** ([nginx.conf.template](frontend/nginx.conf.template), and the same headers for `npm run preview` in [vite.config.js](frontend/vite.config.js)):
- **Content-Security-Policy** allowing scripts, styles, fonts and images from the app's own origin only, with `connect-src` limited to the app and the API. Inline scripts are not allowed, which blocks injected script even if markup were to reach the page. The dev server (`npm run dev`) sends the same policy with two relaxations that hot reload cannot work without: inline scripts and styles, and its websocket.
- **HSTS**, **X-Frame-Options: DENY**, **X-Content-Type-Options: nosniff**, **Referrer-Policy: no-referrer** and a **Permissions-Policy** that turns off the camera, microphone and geolocation.
- `server_tokens off`, so nginx does not reveal its version [18].

### Rate Limiting
Six limiters are defined in one place ([middleware/rateLimiters.js](API/middleware/rateLimiters.js)) [19][20]:

| Limiter | Applies to | Limit | Counted per |
|---------|-----------|-------|-------------|
| `globalLimiter` | Every request | 300 per 15 minutes | IP |
| `loginLimiter` | `POST /api/auth/login` | 5 per 15 minutes | IP |
| `registerLimiter` | `POST /api/auth/register` | 10 per 15 minutes | IP |
| `passwordLimiter` | `PATCH /api/auth/password` | 5 per 15 minutes | User |
| `mfaLimiter` | `POST /api/auth/mfa/*` | 10 per 15 minutes | User |
| `bookingLimiter` | `POST /api/bookings` | 10 per 10 minutes | User |

Login and registration are the endpoints targeted by password brute-forcing and account enumeration, so they get tight limits rather than relying on the global one. The password-change limiter is counted per user, which stops someone with a stolen session from guessing the current password. Booking creation has its own per-user limit because it writes financial records. Read endpoints are cheap and sit behind the looser global limiter.

A blocked request receives `429` with a clear message and the standard `RateLimit` headers. The frontend shows a friendly message and pauses the login button for a short time.

The login limiter counts per IP, so it cannot see guessing spread across many addresses. Accounts therefore have their own lockout: 10 wrong passwords locks the account for 15 minutes ([controllers/authController.js](API/controllers/authController.js)). A locked account gets the same `401` as any failed login, so the lock does not reveal that the account exists. The limit sits above the per-IP limit so that one person mistyping is stopped by the limiter, with a clear message, before they ever reach it. The lock is temporary because a permanent one would let an attacker shut anyone out of their account.

Registration and password changes also reject passwords found in known data breaches, using the Have I Been Pwned range API ([middleware/breachedPassword.js](API/middleware/breachedPassword.js)). Only the first 5 characters of the password's SHA-1 hash leave the server, and the match is made locally, so the service never sees the password or its full hash. If the service cannot be reached within 2 seconds the password is allowed and a warning is logged, so an outage elsewhere does not stop people signing up.

### Input Validation
Input is validated in three layers, so that no single missed check lets bad data through [21].

1. **Middleware** - a validator runs before every controller that accepts a body ([middleware/validators.js](API/middleware/validators.js)). Each one checks the type and content of every field, then **rebuilds `req.body` from the cleaned fields only**, which discards any extra properties an attacker adds. This allow-list approach is the recommended defence against mass assignment [22].

   | Validator | Rules |
   |-----------|-------|
   | `validateRegister` | name 2-50 letters (spaces, `'` and `-` allowed); email checked with `validator.isEmail`, lowercased, max 254; password 8-72 bytes (bcrypt ignores anything longer) with an uppercase, a lowercase and a number; `role` allow-listed to `client` or `freelancer` |
   | `validateLogin` | `email` and `password` only - **login does not take a `role`**; any `role` sent is dropped |
   | `validateProfile` | only the display name can change; email and role are dropped |
   | `validatePasswordChange` | current password required; new password meets the registration rule and must differ |
   | `validateGig` | title 5-80; description 20-500; category from a fixed list; price a number from 50 to 100000; delivery 1-60 whole days. `freelancer` is not on the allow-list, so the owner can never be set from the body |
   | `validateBooking` | a valid gig id; a real `YYYY-MM-DD` date that is not in the past and within a year; note up to 300 characters. Price, client and freelancer are never accepted |
   | `validateStatus` | status must be one of the allowed values |
   | `validateReview` | rating a whole number 1-5; comment up to 300 characters |
   | `validateId` | a malformed id in the URL returns `404` before any database query |

   Any error thrown during validation is caught and returned as `400`, never a `500`.
2. **Controller** - controllers repeat the critical checks as defence in depth. `register` and `login` re-check presence and type and reject non-string values before any lookup ([controllers/authController.js](API/controllers/authController.js)).
3. **Database schema** - the Mongoose schemas repeat the length limits, number ranges and enums ([API/models](API/models)), so invalid data is rejected at the last step even if an earlier check is missed [23].

Body size is capped at 10&nbsp;KB (`express.json({ limit: "10kb" })`, [app.js](API/app.js)) so an oversized payload cannot be used to exhaust memory.

The frontend applies the same rules to its forms and shows a password strength meter, so users get feedback before a request is sent. This is for usability; the API never relies on it.

The principle throughout is **reject by default**: only known-good input shapes are accepted; everything else is refused with a `400` and a specific message [24].

### Injection and XSS Protection
Three sanitisers sit in [middleware/sanitize.js](API/middleware/sanitize.js):

- **NoSQL injection** - `express-mongo-sanitize` runs on every request and removes any key beginning with `$` or containing `.`. A login body such as `{ "email": { "$gt": "" } }` therefore cannot become a MongoDB query operator [25][26]. The validators add a second barrier by rejecting any value that is not a plain string or number.
- **HTTP parameter pollution** - `hpp` runs on every request, so a repeated query parameter cannot be used to pass an array where a single value is expected [27].
- **HTML stripping** - free-text fields (gig title and description, booking note, review comment) have `<script>` and `<style>` blocks removed with their contents, and any other tag removed. The stripping repeats until nothing changes, so a nested payload such as `<scr<script>ipt>` cannot reassemble itself.

Stored text is protected again on the way out: React escapes everything it renders [28], and the Content-Security-Policy blocks inline scripts. A stored XSS payload would have to get past all three, which follows the layered defence OWASP recommends [12][29].

### HTTPS
The API is served **only** over HTTPS ([server.js](API/server.js)) - there is no plain-HTTP listener to downgrade to. `minVersion: "TLSv1.2"` refuses the older, broken TLS versions [30][31]. Helmet adds a `Strict-Transport-Security` (HSTS) header instructing browsers to refuse HTTP for this origin in future.

The frontend is also served only over HTTPS. The Vite dev server reuses the API's certificate, and in Docker nginx accepts TLS 1.2 and 1.3 only and redirects any plain-HTTP request to HTTPS [18].

Because every request carries either credentials (login) or the auth token (cookie), transport encryption is what prevents anyone on the network path - public Wi-Fi, an ISP, a compromised router - from reading or altering that data in transit. Locally the certificate is a self-signed certificate generated with OpenSSL; production would use a CA-issued certificate.

### Error Handling
All errors funnel through one central handler ([middleware/errorHandler.js](API/middleware/errorHandler.js)) [32]:
- the full error and stack trace are written to the **server log only**
- the client always receives a generic `{ "error": "An unexpected error occurred." }` with the correct status code - no stack traces, file paths, dependency names or versions, or configuration are ever returned, so an attacker cannot use error responses to fingerprint the system
- a small set of safe, specific messages is allowed: malformed JSON → `400`, body too large → `413`, unknown route → `404`, invalid identifier → `400`, invalid data → `400`, duplicate value → `409`. Database errors are translated into these messages, so no Mongoose or MongoDB error text reaches the client

Login errors are deliberately vague in the same way: login returns the identical `"Invalid email or password."` whether the email is unknown or the password is wrong ([controllers/authController.js](API/controllers/authController.js)), so the login endpoint cannot be used to discover which email addresses have accounts. An unknown email still goes through a full bcrypt comparison against a dummy hash, so response time does not give it away either.

The frontend adds a second layer ([services/api.js](frontend/src/services/api.js)). The API's own `4xx` messages are shown to the user, but any `5xx` response is replaced with a generic message, so server internals never reach the screen. A `401` on a protected request signs the user out with a "session expired" notice.

### Database and Container Security
- **The API will not start without a database.** `MONGO_URL` is required, and the HTTPS listener only opens once the connection succeeds ([server.js](API/server.js)).
- **The database is not reachable from outside.** In Docker, MongoDB sits on an internal-only network with no published port, so only the API container can connect to it ([docker-compose.yml](docker-compose.yml)) [33].
- **The database requires authentication**, with credentials supplied from an untracked `.env` file [34].
- **The API does not connect as the database administrator.** It logs in as `hustlehub_app`, which only has `readWrite` on the `hustlehub` database, so a compromised API cannot read other databases or manage users. The root login is only given to the `mongo` and `mongo-init` containers ([mongo-init.js](mongo-init.js)) [34].
- **Containers run with least privilege.** The API image installs production dependencies only, removes npm and runs as the non-root `node` user. The frontend image is a multi-stage build, so the final image holds only nginx and the built static files [35][36].
- **Containers are locked down at runtime.** Every container has a read-only filesystem, cannot gain new privileges and drops all Linux capabilities. The `client` container adds back only the four nginx needs to start (`NET_BIND_SERVICE`, `CHOWN`, `SETUID`, `SETGID`), and folders that must be written at start-up are in-memory `tmpfs` mounts ([docker-compose.yml](docker-compose.yml)).
- **Secrets are never baked into an image or committed.** Certificates are mounted read-only at run time, environment values come from `.env` files, and `.env` and `certs` are in `.gitignore` and `.dockerignore`.
- **Deleting a user removes their data.** Their gigs, bookings and transactions are deleted with the account, so nothing is left pointing at a user that no longer exists.

## Own Security Features

**In Plain Terms**
The POE brief lists the security every group must build, such as scrambled passwords, encrypted connections, checking what users type in, and limits on login attempts. These are covered in Security Decisions. Two-factor authentication is not counted here either, because it may fall under the brief.

The three features below are extra protections our group chose to add. The threat review above showed gaps that the required features did not fully close. All three were built or finished in Part 3: two are new, and the third turns a Part 2 screen timer into a real sign-out on the server.

| Feature | What it means for users | Threat it closes | New in Part 3 | Code | Evidence |
| :--- | :--- | :---: | :--- | :--- | :--- |
| **Breached-password check** | You cannot pick a password that criminals already have on their lists | **T1** | The whole feature | `breachedPassword.js` | Screenshot of a refused password |
| **Automatic sign-out when idle** | If you walk away, your account will not stay open for the next person | **T4** | Part 2 only hid the screen. Part 3 added token revocation (`tokenVersion`), so an idle sign-out now cancels the session on the server and a copied token stops working | `useIdleLogout.js`, `auth.js` | Screenshots of the warning and sign-out |
| **Locked-down containers** | If one part of the system were broken into, the attacker could do very little with it | **T19** | The whole feature: read-only filesystems, all capabilities dropped, no-new-privileges, non-root users | `docker-compose.yml` | `docker inspect` output and a refused write |

### 1. Breached-Password Check

**In plain terms**: Over the years, billions of passwords have been leaked in data breaches at other companies. Criminals collect these lists and try them on every site they can, so a password on one of those lists is unsafe even if it looks strong. When you sign up or change your password, HustleHub+ checks it against these lists, without ever revealing your password to anyone. If it is on a list, you are asked to choose another.

**How it works**: The API checks the password against the Have I Been Pwned "Pwned Passwords" database. It does not send the password itself. It turns the password into a code (a SHA-1 hash) and sends only the first 5 characters of that code. The service answers with every leaked code that starts with those characters, and HustleHub+ looks for a match on its own server. The service never learns the password or even the full code. This approach is called k-anonymity [46]. The Add-Padding header adds fake entries to each answer, so even the size of the reply gives nothing away. NIST, the US standards body, recommends this kind of check for new passwords [8].

A password like Password1 passes the usual rules (capital letter, small letters, number), but it is on the leaked lists, so it is refused with 400 and the message "This password has appeared in a data breach. Please choose a different one."

**Where the code is**: middleware/breachedPassword.js. It runs on registration and on password change in routes/authRoutes.js:
```js
router.post("/register", registerLimiter, validateRegister, rejectBreachedPassword, register);
router.patch("/password", requireAuth, passwordLimiter, validatePasswordChange, rejectBreachedPassword, changePassword);
```

If the service does not answer within 2 seconds, the password is allowed and a warning is recorded (see Risks We Accept).

**Evidence**:
![Registering with Password1 is refused because it appears in a data breach](Screenshots/Security/breached-password.png)

### 2. Automatic Sign-Out When Idle

**In plain terms**: If you forget to log out on a shared or public computer, the next person could see your bookings and earnings. HustleHub+ signs you out after 15 minutes without activity. A minute before that, it asks "Still there?" and counts down, so you can choose to stay signed in.

**How it works**: The app watches for mouse, keyboard, scroll and touch activity. Once the warning is showing, only the Stay signed in button resets the timer, so a mouse bumped by accident cannot cancel it. When time runs out, the app does more than hide the screen. It tells the server to cancel the session (POST /api/auth/logout raises the user's tokenVersion), so even a copy of the sign-in pass stops working. NIST recommends an inactivity timeout for exactly this situation [8].

**Where the code is**:

- [hooks/useIdleLogout.js](frontend/src/hooks/useIdleLogout.js): watches for activity and decides when to warn and when to sign out
- [components/IdleWarning.jsx](frontend/src/components/IdleWarning.jsx): the "Still there?" countdown window
- [components/Dashboard.jsx](frontend/src/components/Dashboard.jsx): signs out on the server and shows "You were signed out because of inactivity"
- [config.js](frontend/src/config.js): the time limit, changeable with `VITE_IDLE_MINUTES` (default 15)

**Evidence**. These were taken with the limit set to 1 minute (VITE_IDLE_MINUTES=1) so the sign-out could be shown quickly.

![The Still there? window counting down before the automatic sign-out](Screenshots/Security/idle-warning.png)

![The login screen after an automatic sign-out](Screenshots/Security/idle-sign-out.png)

### 3. Locked-Down Containers

**In plain terms**: HustleHub+ runs as three separate "containers": the website, the API and the database. Each is a sealed box with only what that part needs. We went further than just using containers and locked each box down. Think of it as giving each worker a key to only their own room, in a room where nothing can be moved. Even if an attacker got into one box, they could not change its files, could not give themselves more power, and could not reach the database from the internet.

**How it works**: Every container in docker-compose.yml uses the same strict settings:
```yaml
x-hardened: &hardened
  security_opt: ["no-new-privileges:true"]
  cap_drop: [ALL]
  read_only: true
  tmpfs: [/tmp]
```

- read_only: true. The container's files cannot be changed or added to. Only a temporary in-memory folder can be written to, and it is wiped when the container stops.
- cap_drop: [ALL]. All special system powers ("capabilities") are removed. Only the website container gets back the four it needs to start.
- no-new-privileges. A program inside cannot raise its own permissions later.
- Not running as the administrator. The API runs as the ordinary node user, with npm removed from the image (API/Dockerfile). The database runs as mongodb.
- A hidden database. MongoDB sits on an internal network that cannot be reached from outside, so only the API can talk to it.

This follows the OWASP Docker Security Cheat Sheet [35].

Evidence. With the app running, these commands show the settings Docker applied to each container, then try to write a file inside the API container:
```bash
docker inspect --format '{{.Name}} user={{.Config.User}} readonly={{.HostConfig.ReadonlyRootfs}} capdrop={{.HostConfig.CapDrop}} capadd={{.HostConfig.CapAdd}} secopt={{.HostConfig.SecurityOpt}}' $(docker compose ps -q)
docker compose exec api sh -c "id && touch /app/test"
```
![docker inspect showing every container is read-only, has all capabilities dropped and has no-new-privileges](Screenshots/Security/hardened-inspect.png)

![The API runs as node, not as the administrator, and the attempt to write a file is refused with Read-only file system](Screenshots/Security/hardened-read-only.png)

## API Endpoints

Authenticated requests are identified by the `token` cookie (set automatically on login/register) or, for API clients, an `Authorization: Bearer <token>` header.

### Health and Auth

| Method | Endpoint | Access | Description |
|--------|----------|--------|-------------|
| GET | `/health` | Public | Basic liveness check |
| POST | `/api/auth/register` | Public | Register - body: `name`, `email`, `password`, `role` (`client` or `freelancer`) |
| POST | `/api/auth/login` | Public | Log in - body: `email`, `password` only (no `role`) |
| POST | `/api/auth/logout` | Public | Clears the auth cookie |
| GET | `/api/auth/me` | Any signed-in user | Returns the signed-in user |
| PATCH | `/api/auth/me` | Any signed-in user | Change display name - body: `name` |
| PATCH | `/api/auth/password` | Any signed-in user | Change password - body: `currentPassword`, `newPassword` |
| POST | `/api/auth/mfa/setup` | Any signed-in user | Start two-factor setup, returns the secret and QR code - body: `password` |
| POST | `/api/auth/mfa/enable` | Any signed-in user | Confirm with a code, returns the recovery codes - body: `code` |
| POST | `/api/auth/mfa/disable` | Any signed-in user | Turn two-factor off - body: `password`, `code` |

### Gigs

| Method | Endpoint | Access | Description |
|--------|----------|--------|-------------|
| GET | `/api/gigs` | Any signed-in user | List active gigs |
| GET | `/api/gigs/mine` | Freelancer | Own gigs, including paused ones |
| GET | `/api/gigs/:id` | Any signed-in user | One gig (a paused gig is visible to its owner only) |
| POST | `/api/gigs` | Freelancer | Create a gig - body: `title`, `description`, `category`, `price`, `deliveryDays` |
| PATCH | `/api/gigs/:id` | Freelancer (owner) | Edit a gig, or pause it with `active` |
| DELETE | `/api/gigs/:id` | Freelancer (owner) or Admin | Delete a gig |

### Bookings

| Method | Endpoint | Access | Description |
|--------|----------|--------|-------------|
| POST | `/api/bookings` | Client | Book a gig - body: `gigId`, `date`, `note`. Creates the booking and its transaction |
| GET | `/api/bookings` | Admin | Every booking |
| GET | `/api/bookings/mine` | Client or Freelancer | Own bookings |
| GET | `/api/bookings/:id` | Its client or freelancer, or Admin | One booking |
| PATCH | `/api/bookings/:id/status` | Its client or freelancer | Change status - body: `status` |
| POST | `/api/bookings/:id/review` | Its client | Review a completed booking - body: `rating`, `text` |

### Income and Users

| Method | Endpoint | Access | Description |
|--------|----------|--------|-------------|
| GET | `/api/income` | Freelancer | Income total, paid out, in progress, estimated tax with its breakdown (SARS 2026/27 brackets less the primary rebate, on the current tax year's income), by month and by gig |
| GET | `/api/users` | Admin | List all users |
| GET | `/api/users/:id` | Admin | One user with their gig and booking counts |
| DELETE | `/api/users/:id` | Admin | Delete a user and their data (not your own account) |

## Setup
**Requirements:** Node.js 20+ (22+ for the frontend tests), MongoDB 7, and OpenSSL (for local cert generation). To run everything in containers instead, see [Docker](#docker).

### API
Begin with 
```bash
cd API
npm install
```
 
Then Generate a local self-signed certificate:
 
```bash
mkdir -p certs
openssl req -x509 -newkey rsa:2048 -nodes -days 365 \
  -keyout certs/key.pem -out certs/cert.pem -subj "/CN=localhost"
```
 
Then You Need to Create a `.env` file in `API/`:
 
```env
PORT=3443
JWT_SECRET=replace-with-a-long-random-string-min-32-chars
JWT_EXPIRES_IN=1h
APP_NAME=HustleHubPlusAPI
CORS_ORIGIN=https://localhost:5173
SSL_KEY_PATH=./certs/key.pem
SSL_CERT_PATH=./certs/cert.pem
MONGO_URL=mongodb://localhost:27017/hustlehub
```

`MONGO_URL` is the MongoDB connection string; the server refuses to start without it. `JWT_SECRET` must be at least 32 characters or the server will refuse to start. `APP_NAME` is the JWT issuer and is validated on every request. `CORS_ORIGIN` is the browser origin allowed to call the API (comma-separated for more than one). `EXPOSE_TOKEN_IN_BODY` is deliberately left out: by default the `httpOnly` cookie is the only token transport and no response body contains the JWT. Add `EXPOSE_TOKEN_IN_BODY=true` only for a Postman/Newman run (see [Testing](#testing)), which has no cookie jar, and remove it afterwards.
 
And Then Lastly Run the server:
 
```bash
npm start
```
The API will be available with the link: `https://localhost:3443`.

### Frontend
The frontend reuses the API's certificate, so complete the API steps first.

```bash
cd frontend
npm install
npm run dev
```

The app will be available with the link: `https://localhost:5173`. The browser will warn about the self-signed certificate; open `https://localhost:3443/health` once and accept it as well, otherwise the app's requests to the API are blocked.

An optional `.env` file in `frontend/` can set `VITE_API_URL` (default `https://localhost:3443`) and `VITE_IDLE_MINUTES` (default `15`).

### Creating an Admin Account
Registration never creates an admin. Register a normal account, then change its role in the database:

```bash
mongosh "mongodb://localhost:27017/hustlehub" --eval 'db.users.updateOne({ email: "admin@example.com" }, { $set: { role: "admin" } })'
```

Log in again and the admin dashboard is shown. Admin features stay locked until you turn on two-factor authentication under Settings. When running in Docker, use the steps under [Docker](#docker) instead.

### Docker
**Requirements:** Docker Desktop (running), plus the certificate and `API/.env` from the steps above.

[docker-compose.yml](docker-compose.yml) starts three containers: `mongo` (MongoDB 7, on an internal-only network with no published port), `api` (`https://localhost:3443`) and `client` (the frontend, `https://localhost:5173`).

Create a second `.env` file next to `docker-compose.yml` with the MongoDB root credentials and a separate password for the API's own database user. Use letters and digits only for `MONGO_APP_PASSWORD` - it is placed inside the connection string, so characters such as `@` or `/` break it:

```env
MONGO_USER=hustlehub
MONGO_PASSWORD=replace-with-a-long-random-string
MONGO_APP_PASSWORD=replace-with-a-different-long-random-string
```

On every start, the short-lived `mongo-init` container creates the `hustlehub_app` user (or updates its password), then exits. Seeing it as `Exited (0)` is normal.

Then build and start everything:

```bash
docker compose up -d --build
```

![The mongo, api and client containers in Docker Desktop](docker-containers.png)

Stop the containers with `docker compose down` (add `-v` to also delete the MongoDB data volume).

#### Creating an admin account in Docker
MongoDB has no published port in Docker, so the role is changed from inside the `mongo` container. Register a normal account at `https://localhost:5173`, then open a Mongo shell from the folder containing `docker-compose.yml`. Replace `hustlehub` after `-u` with your `MONGO_USER` if it differs; the shell prompts for `MONGO_PASSWORD`:

```bash
docker compose exec mongo mongosh -u hustlehub -p --authenticationDatabase admin hustlehub
```

At the `hustlehub>` prompt, change the role of the account you registered, then type `exit`:

```js
db.users.updateOne({ email: "admin@example.com" }, { $set: { role: "admin" } })
```

The result should show `modifiedCount: 1`. Emails are stored in lowercase, so `matchedCount: 0` means the email does not match. Log in again and the admin dashboard is shown. Admin features stay locked until you turn on two-factor authentication under Settings. The account is kept in the MongoDB data volume, so it survives `docker compose down` but not `docker compose down -v`.

## Testing

### Postman / Newman
The Part 2 collection ([API/postman/HustleHub+ Part2.postman_collection.json](API/postman/HustleHub+%20Part2.postman_collection.json)) holds **113 requests** across ten folders:

- **00 Health, 01 Auth, 05 Account** - register, login, `/me`, profile and password changes, with their `400`/`401`/`409` failure paths.
- **02 Gigs, 03 Bookings, 04 Income** - the domain flows, including validation failures, ownership checks, review rules and the freelancer-only income summary.
- **06 Error handling** - unknown route (`404`), malformed JSON (`400`), body over 10&nbsp;KB (`413`), each asserting the controlled error message so nothing internal leaks.
- **07 Users - access control, 08 Admin** - role checks (`403`); the admin folder is skipped unless `adminEmail`/`adminPassword`/`adminCode` are set (the account needs two-factor on, and `adminCode` is a current code from its app), which leaves 107 requests / 169 assertions (this is what CI runs).
- **09 Rate limiting** - runs last and asserts the `429` response, its message and the rate-limit headers on both the booking and the login endpoint.

The Part 1 collection (13 requests / 17 assertions) is kept beside it and runs with `npm run test:api:part1`.

Run it headless with Newman [37]:

```bash
cd API
npm run test:api
```

![Newman run summary: 107 requests and 169 assertions executed, 0 failed](newman-run.png)

The run above is without the admin credentials set, so the admin folder is skipped: **107/107 requests, 169/169 assertions, 0 failures**.

A captured run is committed at [API/postman/newman/newman-run.txt](API/postman/newman/newman-run.txt) (JSON export beside it): **109/109 requests, 168/168 assertions, 0 failures**, with the admin folder included. That run is from 12 October, before the 05 Account folder gained its two-factor requests, so it has fewer requests than the run above. Add `EXPOSE_TOKEN_IN_BODY=true` to `API/.env` and restart the API before the run so the tests can read the token from the response body, then remove it again. The rate limiters are counted per API process and the collection uses up part of their allowance, so restart the API before each run. Screenshots of the saved response examples are in [the accompanying PDF](Screenshots/HustleHub+%20Postman%20Part%202%20Collections.pdf).

### npm audit
`npm audit` checks every dependency against the public vulnerability database [38]. The API has **0 known vulnerabilities**:

![npm audit reporting 0 vulnerabilities](npm-audit.png)

The CI pipeline runs `npm audit --audit-level=high` on every push, so a dependency with a high-severity vulnerability fails the build.

### OWASP ZAP
The running API was scanned with the OWASP ZAP baseline scan, which crawls the target and passively checks every response for missing security headers, insecure cookies, information leaks and similar weaknesses [39]. The scan plan is [zap.yaml](zap.yaml) and the full report is [zap-report.html](zap-report.html).

```bash
docker run --rm -v "${PWD}:/zap/wrk/:rw" -t ghcr.io/zaproxy/zaproxy:stable zap-baseline.py -t https://host.docker.internal:3443 -r zap-report.html
```

**Result: 66 checks passed, 0 failed. No high, medium or low risk alerts.**

![ZAP baseline scan, passing checks](OWASP-1.png)
![ZAP baseline scan, passing checks continued](OWASP-2.png)
![ZAP baseline scan summary](OWASP-3.png)

The single informational notice, *Non-Storable Content*, is intended: it reports that responses carry `Cache-Control: no-store`, which is set on purpose so that personal and financial data is never cached. The spider warning about a `404` is also expected, because the API has no page at `/`.

The baseline scan is passive and unauthenticated, so it covers the public surface of the API. The authenticated routes are covered by the Postman collection above.

### Backend self-checks
The pure logic in the API has assert-based self-checks that need no server or database:

| Command | What it checks |
|---------|----------------|
| `npm run test:auth` | reading the token from the cookie or header; rejecting tokens issued before a password change |
| `npm run test:gigs` | gig ownership and delete rules; gig validation, including an injected owner or query operator |
| `npm run test:bookings` | allowed status changes per role; who counts as a party to a booking; booking, status and review validation |
| `npm run test:income` | income totals, tax brackets, rebate and tax-year boundaries |
| `npm run test:sanitize` | HTML stripping, including nested tags |
| `npm run test:logger` | log line format; secrets masked; forged log lines blocked; log level and error response for each status; Loki push format, basic auth and masking, checked against a local fake Loki |

```bash
cd API
npm run test:auth
```

### Frontend tests
The React app is tested with [Vitest](https://vitest.dev/) (the Vite-native test runner, using the same `describe` / `it` / `expect` / mock style as Jest) [40] and React Testing Library [41], which renders components in a simulated browser (jsdom) and interacts with them the way a user does. The API client is mocked, so no backend or database is needed.

```bash
cd frontend
npm install
npm run test:run
```

`npm test` runs the same tests in watch mode. A captured run is committed at [frontend/test-results/vitest-run.txt](frontend/test-results/vitest-run.txt): **12 test files, 69 tests, 0 failures**. The CI pipeline runs `npm run test:run` in the frontend job, so a failing test fails the build.

| Test file | What it checks |
|-----------|----------------|
| `LoginForm.test.jsx` | renders; trimmed credentials sent; API error shown and password cleared; cooldown after a `429`; switch to register |
| `RegisterForm.test.jsx` | renders; weak password, bad email and a script-like name are rejected before any API call; valid sign-up defaults to `client`; duplicate-email error shown |
| `PasswordStrength.test.jsx` | strength meter label for each level |
| `Dashboard.test.jsx` | role-based navigation: client, freelancer and admin each see only their own tabs, and nothing outside the role is requested |
| `AdminGigs.test.jsx` | admin removes a gig only after confirmation; a refused removal keeps the gig and shows the reason; the admin bookings list shows both parties and offers no status actions |
| `AdminUsers.test.jsx` | user list, role filter and search; detail page; delete only after confirmation; refused deletes shown; no delete option for your own account |
| `MfaPanel.test.jsx` | two-factor setup: admin warning while it is off; QR code and key after the password; wrong password and wrong code handled; recovery codes shown once; turning it off needs the password and a code |
| `BookingsList.test.jsx` | a status change without confirmation is applied at once; a confirmed one waits for the dialog; an API refusal is shown and the buttons are enabled again |
| `ReviewModal.test.jsx` | stars light up on hover and fall back to the chosen rating; a rating is required; the rating and trimmed comment are submitted |
| `password.test.js` | password rule: accepted case plus too short, missing upper/lower/number, too long |
| `months.test.js` | income chart window ends on the current or latest month with data; empty months are 0; totals per start month |
| `api.test.js` | `4xx` messages shown; `429` friendly message; `5xx` never leaks server internals; `401` on a protected route signs the user out |

### End-to-end tests (Playwright)
The unit tests mock the API. The [Playwright](https://playwright.dev/) [49] suite instead drives a real Chromium browser against the full Docker stack: the React client, the API and MongoDB. It checks that the parts work together the way a user would use them ([frontend/e2e](frontend/e2e)).

| Test | What it proves |
|------|----------------|
| **A client books a gig and both sides see the same transaction reference** | A freelancer and a client register; the freelancer creates a gig; the client books it and gets a `TX-` reference for R1,500; the client's bookings show it as Pending; the freelancer sees the same reference and accepts it; the client's receipt shows the same reference, client and amount. This covers authentication, gig creation, booking and transaction recording from start to finish |
| **A wrong password gets a generic error and stays on the login screen** | The error is the same "Invalid email or password." whether or not the account exists, the password box is cleared, and no dashboard is shown |
| **Logging out ends the session, even after a reload** | After logout, reloading shows the login screen and `/api/auth/me` returns `401`, so the session is cancelled on the server and not only hidden in the browser |

Every run creates new accounts with random emails and passwords, so it never depends on earlier data. To run it locally:

```bash
docker compose up -d --build
cd frontend
npm ci
npx playwright install chromium
npm run test:e2e
npx playwright show-report
```

The API's rate limits are counted per process, and one run uses 2 logins and 3 registrations, so run `docker compose restart api` before running the suite again. More detail is in [frontend/README.md](frontend/README.md).

![Playwright report: 3 of 3 tests passed](frontend/Playwright_Test_Report.png)

## CI Pipeline
[.github/workflows/ci.yml](.github/workflows/ci.yml) runs on every push and pull request using GitHub Actions [42].

| Job | Steps |
|-----|-------|
| **backend-test** | install from the lockfile; syntax check of every JavaScript file; `npm audit` at high severity; the seven self-checks (unit tests); then start the real API over HTTPS against a MongoDB service container and run the full Newman collection |
| **frontend-build** | install from the lockfile; `npm audit` at high severity; lint with Oxlint; run the Vitest tests; production build |
| **static-analysis** | scan the code, Dockerfiles and workflows with Semgrep; any finding fails the job; the report is uploaded as the `semgrep-report` artifact |
| **sonarcloud** | runs only on pushes to `main` and pull requests into it, because the free plan only analyses those; scan the code with SonarQube Cloud using the settings in `sonar-project.properties`; a failed quality gate fails the job |
| **docker-zap** | build the Docker images; start the full Compose stack with throwaway secrets; run an OWASP ZAP active scan against the API (signed in, with routes from the Postman collection) and the client; scan the images with Trivy; the reports are uploaded as the `security-scan-reports` artifact |
| **e2e** | build the Docker images; start the full Compose stack with throwaway secrets; install Chromium; run the Playwright end-to-end tests against it; the HTML report, screenshots and, for a failure, a trace are uploaded as the `playwright-report` artifact. It has its own stack, separate from **docker-zap**, because the ZAP active scan uses up the same per-IP rate limits |
| **deploy** | runs only on `main`, and only after all the other jobs pass. It is a placeholder: deployment to a hosting provider was optional for this POE and was not done |

A failing check, test, audit, Semgrep finding, SonarQube quality gate, Docker build or Playwright test in any job fails the build. So does a High ZAP alert, a ZAP scan that covers nothing, or a fixable HIGH or CRITICAL Trivy finding in the `api` or `client` image. Lower ZAP alerts do not fail the build, so they are reviewed in the report. `mongo:7` is an upstream image, so its Trivy results are report-only.

### Where the Pipeline Runs
The pipeline runs on the Classroom50 repository. For a while, though, GitHub Actions would not start any job there. Every run failed within seconds with this message: *"The job was not started because recent account payments have failed or your spending limit needs to be increased."* That was an insufficient-funds billing problem on the organisation, not a problem with the code or the workflow. It has since been fixed.

The Classroom50 repository also has the `autograde.yaml` workflow that GitHub Classroom added. Runs from the billing outage show as failed because they never started, so they ran no checks.

![CI/CD run on main with every job passing](Screenshots/CI/CI-run1.png)

![Run summary: Vitest report with 60 of 60 frontend tests passing (the suite has since grown to 69)](Screenshots/CI/CI-run2.png)

![Artifacts uploaded by the run: coverage, Playwright, security scan and Semgrep reports](Screenshots/CI/CI-run3.png)

## Static Code Analysis
Static analysis reads the source code without running it and looks for bugs, security flaws and code that is hard to maintain. It catches problems that tests miss, because tests only check the cases someone thought to write. Two tools run in the pipeline, and either one can fail the build.

| Tool | What it checks | When it runs | How it fails the build |
|------|----------------|--------------|------------------------|
| **Semgrep** [50] | Pattern-based rules for JavaScript, Node.js, Express and React, hardcoded secrets, Dockerfiles and GitHub Actions workflows (`p/javascript`, `p/nodejs`, `p/expressjs`, `p/react`, `p/secrets`, `p/dockerfile`, `p/github-actions`) | Every push and pull request, on every branch | `--error` makes any finding fail the `static-analysis` job. The text and SARIF reports are uploaded as the `semgrep-report` artifact |
| **SonarQube Cloud** [51] | Bugs, vulnerabilities, security hotspots, code smells, duplication and test coverage for `API/` and `frontend/src`. Coverage comes from the backend self-checks, the Newman run and the Vitest tests | Pushes to `main` and pull requests into it (the free plan only analyses those) | `sonar.qualitygate.wait=true` in [sonar-project.properties](sonar-project.properties) makes the job wait for the quality gate and fail if it does not pass |

Semgrep runs on every branch, so a problem is found before it reaches `main`. SonarQube then checks `main` more deeply, including coverage, which Semgrep does not measure. Test files, Postman collections and coverage reports are left out of the analysis, so only the application code is judged.

### Results
The latest run on `main` passed both tools: Semgrep reported no findings, and the SonarQube Cloud quality gate passed.

![SonarQube Cloud overview for main with the quality gate passed](Screenshots/CI/SonarQube.png)

### Findings and How They Were Fixed
Every SonarQube Cloud code finding was fixed in the code, and none was marked as a false positive or accepted. SonarQube Cloud also checks dependencies. It found two risks: one is fixed, and the other has no fixed release yet (see [Dependency Risks](#dependency-risks)).

| Rule | Finding | Fix | Commit |
|------|---------|-----|--------|
| S5145 (log injection) | User input reached `console.log`. `JSON.stringify` escapes CR and LF but not U+0085, U+2028 and U+2029, which some log viewers treat as new lines, so input could forge a log line | The logger now escapes every line-break character as `\uXXXX`. The line is still valid JSON and reads back as the original value. A self-check in `npm run test:logger` covers it | `412e0cb` |
| Unhandled promise | Start-up in [server.js](API/server.js) could fail (database down, port in use) as an unhandled rejection, with no log line | Start-up errors and the server's `error` event are caught, logged as `server.start_failed`, sent to Grafana, and the process exits with code 1. The two fire-and-forget `flush()` calls in the logger are marked with `void`, because `flush()` catches its own errors | `2cedccc` |
| S9379 (accessibility) | `autoFocus` on the MFA code field can disorient screen reader and keyboard users | Focus moves to the code field in an effect, only once the password step is done. A test checks the field receives focus | `8e66797` |
| Prefer `Number.parseInt` | The global `parseInt` was used in the TOTP base32 helpers | Replaced with `Number.parseInt`. The behaviour is the same | `37207ad` |
| S6470 (Docker build context) | Both Dockerfiles used `COPY . .`, which copies everything in the folder into the image. A new file such as a key or a `.env` would be added without anyone noticing | Each Dockerfile now copies only what the app needs: `server.js`, `app.js` and the six source folders for the API; `index.html`, `vite.config.js`, `public` and `src` for the client build. `.dockerignore` still applies as a second layer | `ed5db52` |
| Docker `npm` lifecycle scripts | `npm ci` runs every package's install scripts, so a compromised dependency could run code while the image is built | `npm ci --ignore-scripts` in both Dockerfiles. No package the app installs needs an install script (the only one in the lockfile, `fsevents`, is macOS-only and is never installed on Alpine), and both images still build | `43e12fc` |
| Sort without a compare function | The income chart found the latest month with a bare `.sort()` | Uses `localeCompare`. The month keys are zero-padded `YYYY-MM`, so the order is the same; `months.test.js` checks the chart window | `ed5db52` |
| Floating promises | Two booking status changes in `BookingsList.jsx` called an `async` function without handling its promise | Marked with `void`, because `apply` catches every error itself and shows it to the user. `BookingsList.test.jsx` checks the direct action, the confirmed action and the error message | `ad705a3` |
| Slow regular expression (ReDoS) | The sign-up email check `^\S+@\S+\.\S+$` backtracks, because `\S` also matches `.`. A long input of dots took 736&nbsp;ms | The pattern keeps `@` out of the local part and `.` out of each domain label, so it cannot backtrack: the same input now takes 1&nbsp;ms. It also rejects `a@b..c` and `a@b@c.d`, which the old one let through. The API still runs `validator.isEmail` | `cb3c74d` |
| Accessibility: radiogroup must be focusable | The star rating's `radiogroup` had a mouse handler but could not take focus | The handler moved onto each star, which are focusable buttons, so the group itself has none. The stars now touch, so the highlight does not flicker between them. `ReviewModal.test.jsx` checks hovering and leaving | `4b5764c` |
| Framework version disclosure | Express sends `X-Powered-By: Express` by default. Helmet already removed it, but in another file | `app.disable("x-powered-by")` in `app.js`, so the header stays off even if the Helmet settings change | `29e07b2` |
| Quality gate: coverage on new code | The fixes above added lines that no test ran, so new-code coverage was 42.9% against the required 80% | New Vitest files for `months.js`, `BookingsList.jsx` and `ReviewModal.jsx`. Coverage on new code is now 100% and the quality gate passes | `29e07b2` |

### Dependency Risks
SonarQube Cloud's dependency scan looks at all 319 packages the app installs, including packages pulled in by other packages, which is where both risks were found.

| Risk | Package | Where it runs | What we did |
|------|---------|---------------|-------------|
| CVE-2026-85625, prototype pollution (CVSS 8.1) | `sift` 17.1.3, used inside Mongoose | API, at runtime | **Fixed.** Mongoose pins `sift` to exactly 17.1.3, so an npm `overrides` entry in [API/package.json](API/package.json) forces 17.1.4. That release checks `hasOwnProperty` before it reads query keys, so a polluted `Object.prototype.$where` is no longer run. The backend self-checks and `npm audit` pass on the new version |
| CVE-2026-112366, slow regular expression (CVSS 8.7) | `picomatch` 4.0.7, used by Vite and Vitest | Frontend build and tests only | **No fix released yet**, because 4.0.7 is the latest version. It is a development dependency: it matches file paths while Vite builds and Vitest runs, and the patterns come from our own config, not from users. The production image only serves the built files through nginx and does not contain it. We will upgrade as soon as a fixed version is published |

The other scanners in the pipeline cover what static analysis cannot see: `npm audit` checks dependencies [38], Trivy checks the built images [52], and ZAP attacks the running application [39]. Their findings and fixes are in [CI Pipeline](#ci-pipeline) and [Security Review](#security-review-threats-and-controls).

## Logging
The API writes structured logs through [utils/logger.js](API/utils/logger.js): one JSON object per line on stdout. Docker captures stdout, so the logs can be read with `docker compose logs api`, and because each line is JSON a log platform can filter it by any field. No logging library is needed for this, so no dependency was added.

```json
{"timestamp":"2026-11-02T19:32:50.751Z","level":"info","event":"transaction.created","requestId":"664e447c-1b0f-4e90-9804-b5b070c6c50a","ip":"::1","userId":"64b000000000000000000001","reference":"TX-TEST","bookingId":"64b000000000000000000004","amount":100,"status":"Simulated"}
```

Every line from a request carries the same `requestId`, the client IP and, once signed in, the `userId`, so one request can be followed from start to finish.

### What Is Logged and Why

| Event | Level | Why it matters |
|-------|-------|----------------|
| `auth.login.success` | info | Shows when and from where an account was accessed, which helps to spot a stolen account |
| `auth.login.failed` | warn | Repeated failures point to password guessing or credential stuffing. `reason` tells the two failure types apart in the log, while the client still gets the same message for both |
| `auth.register.success` | info | Records new accounts and their role |
| `auth.password_change.success`, `auth.password_change.failed` | info, warn | Failures can mean someone with a stolen session is guessing the current password |
| `booking.created`, `booking.status_changed` | info | An audit trail of who booked what and who changed its status |
| `transaction.created`, `transaction.refunded` | info | A financial audit trail that can be matched against the database |
| `transaction.create_failed` | error | A booking was rolled back because its payment record failed, which is a data integrity problem |
| `admin.user_deleted`, `admin.gig_removed` | warn | Destructive admin actions must be traceable to the admin who did them |
| `rate_limit.exceeded` | warn | Shows automated abuse, and the path shows which endpoint was targeted |
| `http.request` | info, warn or error | One line per request with its method, path, status and duration. Spikes of `401`, `403` and `404` can show someone probing for access. `/health` is skipped because it is only noise |
| `http.error` | warn or error | `5xx` errors include the message and stack trace for debugging; these stay on the server and never reach the client |
| `server.started`, `server.config_invalid`, `db.connected`, `db.connect_failed` | info, error | Startup and availability problems |

### Keeping Logs Safe
Logs are a target too, so they follow the OWASP logging guidance [43]:

- **Secrets are never logged.** Controllers pass only chosen fields, and as a safety net the logger masks any field whose name contains `pass`, `token`, `secret`, `authorization` or `cookie`, at any depth.
- **Personal data is kept to a minimum.** Users are identified by id. A failed login does not record the submitted email, because people sometimes type a password into that box.
- **Query strings are left out** of logged paths, because they can hold user data.
- **Client errors have no message or stack trace**, because those can repeat what the user submitted.
- **Log injection is blocked.** JSON encoding escapes CR and LF in user input. It leaves the Unicode line breaks U+0085, U+2028 and U+2029 untouched, and some log viewers treat those as new lines, so the logger escapes them as well. SonarQube Cloud raised this as a finding (rule S5145), which is how the gap was found. Input therefore cannot forge an extra log line, and the escaped value still reads back exactly as it was logged.

`npm run test:logger` checks the masking and injection rules in CI.

### Cloud Logging with Grafana Cloud
The same log lines are also sent to Grafana Cloud Loki, where they can be searched and graphed from anywhere [44]. [utils/logger.js](API/utils/logger.js) still writes every line to stdout. It also buffers each line and pushes the buffer to Loki's HTTP push API every 5 seconds, or sooner once 100 lines are waiting. It uses Node's built-in `fetch`, so no extra dependency or container was needed. Each line is labelled with `service` (the `APP_NAME`) and `level`; every other field stays in the JSON line and can be read in Grafana with `| json`.

- **It is optional.** Without the three variables below nothing is sent, so local runs and CI are unchanged.
- **A Loki outage cannot take the API down.** A failed push is logged to stdout as `logging.loki_push_failed` and that batch is dropped (stdout still has it). The buffer holds at most 1,000 lines, so memory stays bounded.
- **Nothing extra leaves the server.** Lines are masked before they are buffered, so Loki receives exactly what stdout shows. The push goes over HTTPS with a token that can only write logs.
- **The last lines are not lost.** The buffer is sent before the API exits on `SIGTERM` (`docker compose stop`) or on a failed database connection.

**Setting it up**

1. In Grafana Cloud, open your stack, choose **Loki → Details**, and note the URL and the user (a number).
2. Under **Administration → Cloud access policies**, create a policy with only the `logs:write` scope, then create a token for it.
3. Add these lines to `API/.env`, which is not committed. Docker Compose reads the same file.

```env
LOKI_URL=https://logs-prod-XXX.grafana.net/loki/api/v1/push
LOKI_USER=123456
LOKI_TOKEN=glc_...
```

4. Restart the API, sign in a few times (including one wrong password), make a booking, then open **Explore → Loki** in Grafana.

**Useful queries**

| What | LogQL |
|------|-------|
| Everything from the API | `{service="HustleHubPlusAPI"}` |
| Failed logins | `{service="HustleHubPlusAPI"} \| json \| event="auth.login.failed"` |
| Bookings and transactions | `{service="HustleHubPlusAPI"} \| json \| event=~"(booking\|transaction).*"` |
| Errors | `{service="HustleHubPlusAPI", level="error"}` |
| Failed logins per 5 minutes (dashboard panel) | `sum(count_over_time({service="HustleHubPlusAPI"} \| json \| event="auth.login.failed" [5m]))` |

**Dashboard**

[grafana/hustlehub-dashboard.json](grafana/hustlehub-dashboard.json) is a ready-made dashboard. Import it in Grafana under **Dashboards → New → Import**, then pick the Loki data source when asked. It shows:

| Panel | Why it is there |
|-------|-----------------|
| Failed logins, Successful logins | Counts for the selected time range. Failed logins turn orange at 5 and red at 20, so password guessing stands out |
| Transactions | Simulated payments recorded |
| Errors | Any `level="error"` line turns the panel red |
| Login attempts per 5 minutes | Successes and failures over time, by event |
| Bookings and transactions per 5 minutes | Booking, status change, transaction and refund events over time |
| Warnings and errors | The raw `warn` and `error` lines, newest first, each with its `requestId`, `ip` and `userId` |

**Evidence from Grafana Cloud**

The dashboard with live data from the API:

![Grafana dashboard with login, transaction and error panels](Grafana_Screenshots/grafana-dashboard.png)

Every log line from the API in Explore:

![Grafana Explore showing all API log lines](Grafana_Screenshots/grafana-all-logs.png)

Failed login attempts:

![Grafana Explore filtered to failed logins](Grafana_Screenshots/grafana-failed-logins.png)

Bookings and transactions:

![Grafana Explore filtered to booking and transaction events](Grafana_Screenshots/grafana-bookings-transactions.png)

Errors:

![Grafana Explore filtered to error-level lines](Grafana_Screenshots/grafana-errors.png)

## Screenshots

The screenshots below follow one booking through the application, from sign-in to the freelancer's earnings. The image files are in [Screenshots](Screenshots).

### Sign in and registration
![Login screen](Screenshots/login.png)

![Registration screen with role selection](Screenshots/register.png)

### Freelancer - managing gigs
A freelancer creates, edits, pauses and deletes their own listings.

![Freelancer My gigs screen](Screenshots/freelancer-my-gigs.png)

### Client - browsing and booking
A client searches and filters the available gigs, then books one. The price shown comes from the gig and cannot be changed by the client.

![Client Browse gigs screen](Screenshots/client-browse-gigs.png)

![Booking a gig](Screenshots/client-booking.png)

Every booking creates a transaction record with its own `TX-` reference. The confirmation shows it straight away and states that the payment is simulated.

![Booking requested confirmation with the transaction reference](Screenshots/client-booking-confirmation.png)

The same reference is shown next to the booking.

![Client My bookings screen with the pending booking and its transaction reference](Screenshots/client-bookings.png)

### Freelancer - bookings and income
The freelancer accepts the booking and marks it complete. The same transaction reference appears on their side.

![Freelancer Bookings screen with the completed booking](Screenshots/freelancer-bookings.png)

Once the booking is complete the client can review it, and the rating and comment appear on the freelancer's booking.

![Freelancer Bookings screen showing the client's star rating and review](Screenshots/freelancer-booking-reviewed.png)

The income from that booking is added to the freelancer's earnings, with the estimated tax.

![Freelancer Earnings screen with income totals, estimated tax and charts](Screenshots/freelancer-earnings.png)

### Client - overview, spending and receipts
The client's overview summarises their bookings and total spent.

![Client Overview screen with booking counts, total spent and recent bookings](Screenshots/client-overview.png)

The Spending tab breaks the total down by month and by category and lists each transaction. Pending and cancelled bookings are not counted.

![Client Spending screen with totals, charts and the transaction list](Screenshots/client-spending.png)

Either party can open the receipt for a booking, which can be printed or saved as a PDF.

![Receipt for a completed booking with its transaction reference](Screenshots/receipt.png)

### Admin - user management
An admin lists every account, filters by role, searches by name or email, and opens a user to view or delete it.

![Admin Users screen with role filters, search and the user list](Screenshots/user-admin.png)

### Settings
Every role can change their display name and password. Email and role cannot be changed, and changing the password signs out every other session.

![Settings screen with appearance, profile, notifications and change password](Screenshots/settings.png)

## Demonstration Video

Youtube Video Link: https://youtu.be/VyvByO1Idyk

## References

- [1] 	Vite, "Getting Started," Vite Guide, 2026. [Online]. Available: https://vite.dev/guide/. [Accessed 11 October 2026].
- [2] 	Bitwarden, "What is password hashing?," 2026. [Online]. Available: https://bitwarden.com/resources/what-is-password-hashing/. [Accessed 3 September 2026].
- [3] 	OWASP Foundation, "Password Storage Cheat Sheet," OWASP Cheat Sheet Series, 2024. [Online]. Available: https://cheatsheetseries.owasp.org/cheatsheets/Password_Storage_Cheat_Sheet.html. [Accessed 5 September 2026].
- [4] 	S. Saha, "The JSON Web Token Handbook: Learn to Use JWTs for Web Authentication," Hashnode, 8 October 2025. [Online]. Available: https://www.freecodecamp.org/news/the-json-web-token-handbook-learn-to-use-jwts-for-web-authentication/. [Accessed 3 September 2026].
- [5] 	M. Jones, J. Bradley and N. Sakimura, "JSON Web Token (JWT)," RFC 7519, Internet Engineering Task Force, May 2015. [Online]. Available: https://www.rfc-editor.org/rfc/rfc7519. [Accessed 5 September 2026].
- [6] 	OWASP Foundation, "JSON Web Token for Java Cheat Sheet," OWASP Cheat Sheet Series, 2024. [Online]. Available: https://cheatsheetseries.owasp.org/cheatsheets/JSON_Web_Token_for_Java_Cheat_Sheet.html. [Accessed 5 September 2026].
- [7] 	OWASP Foundation, "Session Management Cheat Sheet," OWASP Cheat Sheet Series, 2024. [Online]. Available: https://cheatsheetseries.owasp.org/cheatsheets/Session_Management_Cheat_Sheet.html. [Accessed 5 September 2026].
- [8] 	P. A. Grassi, J. L. Fenton, E. M. Newton et al., "Digital Identity Guidelines: Authentication and Lifecycle Management," NIST Special Publication 800-63B, National Institute of Standards and Technology, June 2017. [Online]. Available: https://pages.nist.gov/800-63-3/sp800-63b.html. [Accessed 5 September 2026].
- [9] 	A. Barth, "HTTP State Management Mechanism," RFC 6265, Internet Engineering Task Force, April 2011. [Online]. Available: https://www.rfc-editor.org/rfc/rfc6265. [Accessed 5 September 2026].
- [10] 	OWASP Foundation, "Cross-Site Request Forgery Prevention Cheat Sheet," OWASP Cheat Sheet Series, 2024. [Online]. Available: https://cheatsheetseries.owasp.org/cheatsheets/Cross-Site_Request_Forgery_Prevention_Cheat_Sheet.html. [Accessed 5 September 2026].
- [11] 	OWASP Foundation, "Authorization Cheat Sheet," OWASP Cheat Sheet Series, 2024. [Online]. Available: https://cheatsheetseries.owasp.org/cheatsheets/Authorization_Cheat_Sheet.html. [Accessed 11 October 2026].
- [12] 	OWASP Foundation, "OWASP Top 10:2021," OWASP Foundation, 2021. [Online]. Available: https://owasp.org/Top10/. [Accessed 5 September 2026].
- [13] 	Mozilla, "Cross-Origin Resource Sharing (CORS)," MDN Web Docs, 2026. [Online]. Available: https://developer.mozilla.org/en-US/docs/Web/HTTP/CORS. [Accessed 5 September 2026].
- [14] 	Helmet.js, "Helmet — Help secure Express apps with various HTTP headers," 2025. [Online]. Available: https://helmetjs.github.io/. [Accessed 5 September 2026].
- [15] 	Mozilla, "Content-Security-Policy," MDN Web Docs, 2026. [Online]. Available: https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy. [Accessed 5 September 2026].
- [16] 	J. Hodges, C. Jackson and A. Barth, "HTTP Strict Transport Security (HSTS)," RFC 6797, Internet Engineering Task Force, November 2012. [Online]. Available: https://www.rfc-editor.org/rfc/rfc6797. [Accessed 5 September 2026].
- [17] 	OWASP Foundation, "HTTP Headers Cheat Sheet," OWASP Cheat Sheet Series, 2024. [Online]. Available: https://cheatsheetseries.owasp.org/cheatsheets/HTTP_Headers_Cheat_Sheet.html. [Accessed 11 October 2026].
- [18] 	nginx, "Configuring HTTPS servers," nginx Documentation, 2026. [Online]. Available: https://nginx.org/en/docs/http/configuring_https_servers.html. [Accessed 11 October 2026].
- [19] 	OWASP Foundation, "Blocking Brute Force Attacks," OWASP Foundation, 2023. [Online]. Available: https://owasp.org/www-community/controls/Blocking_Brute_Force_Attacks. [Accessed 5 September 2026].
- [20] 	express-rate-limit, "express-rate-limit — Basic rate-limiting middleware for Express," npm, 2025. [Online]. Available: https://www.npmjs.com/package/express-rate-limit. [Accessed 5 September 2026].
- [21] 	OWASP Foundation, "Input Validation Cheat Sheet," OWASP Cheat Sheet Series, 2024. [Online]. Available: https://cheatsheetseries.owasp.org/cheatsheets/Input_Validation_Cheat_Sheet.html. [Accessed 5 September 2026].
- [22] 	OWASP Foundation, "Mass Assignment Cheat Sheet," OWASP Cheat Sheet Series, 2024. [Online]. Available: https://cheatsheetseries.owasp.org/cheatsheets/Mass_Assignment_Cheat_Sheet.html. [Accessed 11 October 2026].
- [23] 	Mongoose, "Validation," Mongoose Documentation, 2026. [Online]. Available: https://mongoosejs.com/docs/validation.html. [Accessed 11 October 2026].
- [24] 	OWASP Foundation, "REST Security Cheat Sheet," OWASP Cheat Sheet Series, 2024. [Online]. Available: https://cheatsheetseries.owasp.org/cheatsheets/REST_Security_Cheat_Sheet.html. [Accessed 5 September 2026].
- [25] 	fiznool, "express-mongo-sanitize — Sanitize your express payload to prevent MongoDB operator injection," GitHub, 2026. [Online]. Available: https://github.com/fiznool/express-mongo-sanitize. [Accessed 11 October 2026].
- [26] 	OWASP Foundation, "Testing for NoSQL Injection," OWASP Web Security Testing Guide, 2026. [Online]. Available: https://owasp.org/www-project-web-security-testing-guide/latest/4-Web_Application_Security_Testing/07-Input_Validation_Testing/05.6-Testing_for_NoSQL_Injection. [Accessed 11 October 2026].
- [27] 	analog-nico, "hpp — Express middleware to protect against HTTP Parameter Pollution attacks," GitHub, 2026. [Online]. Available: https://github.com/analog-nico/hpp. [Accessed 11 October 2026].
- [28] 	React, "Common components," React Reference, 2026. [Online]. Available: https://react.dev/reference/react-dom/components/common. [Accessed 11 October 2026].
- [29] 	OWASP Foundation, "Cross Site Scripting Prevention Cheat Sheet," OWASP Cheat Sheet Series, 2024. [Online]. Available: https://cheatsheetseries.owasp.org/cheatsheets/Cross_Site_Scripting_Prevention_Cheat_Sheet.html. [Accessed 11 October 2026].
- [30] 	E. Rescorla, "The Transport Layer Security (TLS) Protocol Version 1.3," RFC 8446, Internet Engineering Task Force, August 2018. [Online]. Available: https://www.rfc-editor.org/rfc/rfc8446. [Accessed 5 September 2026].
- [31] 	OWASP Foundation, "Transport Layer Security Cheat Sheet," OWASP Cheat Sheet Series, 2024. [Online]. Available: https://cheatsheetseries.owasp.org/cheatsheets/Transport_Layer_Security_Cheat_Sheet.html. [Accessed 5 September 2026].
- [32] 	OWASP Foundation, "Error Handling Cheat Sheet," OWASP Cheat Sheet Series, 2024. [Online]. Available: https://cheatsheetseries.owasp.org/cheatsheets/Error_Handling_Cheat_Sheet.html. [Accessed 5 September 2026].
- [33] 	Docker, "Networking in Compose," Docker Docs, 2026. [Online]. Available: https://docs.docker.com/compose/how-tos/networking/. [Accessed 11 October 2026].
- [34] 	MongoDB, "Security Checklist for Self-Managed Deployments," MongoDB Database Manual, 2026. [Online]. Available: https://www.mongodb.com/docs/manual/administration/security-checklist/. [Accessed 11 October 2026].
- [35] 	OWASP Foundation, "Docker Security Cheat Sheet," OWASP Cheat Sheet Series, 2024. [Online]. Available: https://cheatsheetseries.owasp.org/cheatsheets/Docker_Security_Cheat_Sheet.html. [Accessed 11 October 2026].
- [36] 	Docker, "Multi-stage builds," Docker Docs, 2026. [Online]. Available: https://docs.docker.com/build/building/multi-stage/. [Accessed 11 October 2026].
- [37] 	Postman, "Run and test collections from the command line using Newman CLI," Postman Docs, 2026. [Online]. Available: https://learning.postman.com/docs/collections/using-newman-cli/command-line-integration-with-newman/. [Accessed 11 October 2026].
- [38] 	npm, "npm-audit," npm Docs, 2026. [Online]. Available: https://docs.npmjs.com/cli/v11/commands/npm-audit. [Accessed 11 October 2026].
- [39] 	ZAP, "ZAP - Baseline Scan," ZAP Documentation, 2026. [Online]. Available: https://www.zaproxy.org/docs/docker/baseline-scan/. [Accessed 11 October 2026].
- [40] 	Vitest, "Getting Started," Vitest Guide, 2026. [Online]. Available: https://vitest.dev/guide/. [Accessed 11 October 2026].
- [41] 	Testing Library, "React Testing Library," Testing Library Docs, 2026. [Online]. Available: https://testing-library.com/docs/react-testing-library/intro/. [Accessed 11 October 2026].
- [42] 	GitHub, "GitHub Actions documentation," GitHub Docs, 2026. [Online]. Available: https://docs.github.com/en/actions. [Accessed 11 October 2026].
- [43] 	OWASP, "Logging Cheat Sheet," OWASP Cheat Sheet Series, 2026. [Online]. Available: https://cheatsheetseries.owasp.org/cheatsheets/Logging_Cheat_Sheet.html. [Accessed 2 November 2026].
- [44] 	Grafana Labs, "Loki HTTP API," Grafana Loki Documentation, 2026. [Online]. Available: https://grafana.com/docs/loki/latest/reference/loki-http-api/. [Accessed 6 November 2026].
- [45] 	Microsoft, "Threats - Microsoft Threat Modeling Tool," Microsoft Learn, 2026. [Online]. Available: https://learn.microsoft.com/en-us/azure/security/develop/threat-modeling-tool-threats. [Accessed 8 November 2026].
- [46] 	T. Hunt, "Have I Been Pwned API v3: Pwned Passwords," Have I Been Pwned, 2026. [Online]. Available: https://haveibeenpwned.com/API/v3#PwnedPasswords. [Accessed 8 November 2026].
- [47] 	South African Revenue Service, "Rates of Tax for Individuals," SARS, 2026. [Online]. Available: https://www.sars.gov.za/tax-rates/income-tax/rates-of-tax-for-individuals/. [Accessed 8 November 2026].
- [48] 	South African Revenue Service, "Provisional Tax," SARS, 2026. [Online]. Available: https://www.sars.gov.za/types-of-tax/provisional-tax/. [Accessed 8 November 2026].
- [49] 	Microsoft, "Installation," Playwright Documentation, 2026. [Online]. Available: https://playwright.dev/docs/intro. [Accessed 8 November 2026].
- [50] 	Semgrep, "Semgrep CLI reference," Semgrep Docs, 2026. [Online]. Available: https://semgrep.dev/docs/cli-reference. [Accessed 8 November 2026].
- [51] 	SonarSource, "Quality gates," SonarQube Cloud Documentation, 2026. [Online]. Available: https://docs.sonarsource.com/sonarqube-cloud/standards/managing-quality-gates/introduction-to-quality-gates/. [Accessed 8 November 2026].
- [52] 	Aqua Security, "Trivy Documentation," Trivy, 2026. [Online]. Available: https://trivy.dev/latest/docs/. [Accessed 8 November 2026].
