 Here’s the shape of it.

 High level

 You now have:

 - Supabase Auth = identity provider
 - Go backend = verifies Supabase access tokens
 - Postgres app DB = stores your app’s local users/orgs

 So:

 - Supabase proves who the user is
 - your backend decides what local app record corresponds to that user

 ────────────────────────────────────────────────────────────────────────────────

 The request flow

 Frontend does:

 1. user logs in with Supabase
 2. frontend gets access_token
 3. frontend calls Go backend with:

 ```http
   Authorization: Bearer <access_token>
 ```

 Backend does:

 1. read bearer token
 2. verify JWT signature with Supabase JWKS
 3. validate issuer/audience/time claims
 4. extract user identity
 5. find or create local user in Postgres
 6. ensure they have a default org
 7. return /me

 ────────────────────────────────────────────────────────────────────────────────

 What changed

 1. New auth package

 ### internal/auth/claims.go

 Defines the auth identity shape we care about:

 ```go
   type Identity struct {
       Provider string
       Subject  string
       Email    string
       Name     string
   }
 ```

 This is the normalized user identity after JWT verification.

 Also defines Supabase JWT claim structure:

 - sub
 - email
 - user_metadata.name
 - plus standard JWT registered claims

 So this file is basically:
 - “what fields do we read from the token?”
 - “what shape do we pass around internally?”

 ────────────────────────────────────────────────────────────────────────────────

 ### internal/auth/context.go

 Stores the verified identity in request context.

 Why:
 - middleware verifies the token once
 - handlers can read the identity later without re-verifying

 Functions:
 - WithIdentity(ctx, identity)
 - IdentityFromContext(ctx)

 ────────────────────────────────────────────────────────────────────────────────

 ### internal/auth/verifier.go

 This is the core JWT verification logic.

 It creates:

 ```go
   type Verifier struct {
       provider string
       issuer   string
       audience string
       keyfunc  keyfunc.Keyfunc
   }
 ```

 This verifier:
 - knows your expected issuer
 - knows your expected audience
 - knows how to get signing keys from Supabase JWKS

 ────────────────────────────────────────────────────────────────────────────────

 ### internal/auth/middleware.go

 This is the auth middleware.

 It:
 1. reads Authorization
 2. checks Bearer ...
 3. sends token to verifier
 4. if valid, stores identity in context
 5. if invalid, returns 401

 This protects /me.

 ────────────────────────────────────────────────────────────────────────────────

 2. App now holds auth verifier

 ### internal/app/app.go

 Before:
 - config
 - db
 - queries

 Now also:
 - AuthVerifier *auth.Verifier

 So the app has DB + auth pieces available.

 ────────────────────────────────────────────────────────────────────────────────

 3. /me handler added

 ### internal/app/me.go

 This is the main app logic.

 It:
 1. reads verified identity from context
 2. starts DB transaction
 3. finds local user by:
     - auth_provider = "supabase"
     - auth_subject = token.sub
 4. creates user if missing
 5. loads organizations
 6. creates default org if none exist
 7. returns JSON

 This is the bridge between:
 - external identity (Supabase)
 - internal app user/org records

 ────────────────────────────────────────────────────────────────────────────────

 4. Routes changed

 ### internal/app/routes.go

 Now only:

 - GET /health public
 - GET /me protected

 Protected via:

 ```go
   protected.Use(auth.RequireAuth(a.AuthVerifier))
 ```

 So /me cannot run unless token verification succeeds first.

 ────────────────────────────────────────────────────────────────────────────────

 5. Config changed

 ### internal/config/config.go

 Added env config for auth:

 - AUTH_PROVIDER
 - SUPABASE_JWT_ISSUER
 - SUPABASE_JWKS_URL
 - SUPABASE_JWT_AUDIENCE

 These tell the verifier:
 - who issued tokens
 - where to fetch keys
 - what audience to expect

 ────────────────────────────────────────────────────────────────────────────────

 6. API startup changed

 ### cmd/api/main.go

 Before:
 - load config
 - connect DB
 - start app

 Now also:
 - build auth verifier from config

 So startup now wires in JWKS/JWT verification.

 ────────────────────────────────────────────────────────────────────────────────

 7. SQL change

 ### internal/db/queries/orgs.sql

 ListOrganizationsForUser now includes:

 - om.role

 So /me can return org role like:

 ```json
   {
     "id": "...",
     "name": "...",
     "role": "owner"
   }
 ```

 ────────────────────────────────────────────────────────────────────────────────

 How verification works

 Supabase gives you a JWT

 A JWT has 3 parts:

 ```text
   header.payload.signature
 ```

 The important idea:

 - header says which algorithm/key info to use
 - payload contains claims like sub, email, iss, aud, exp
 - signature proves token was signed by Supabase

 ────────────────────────────────────────────────────────────────────────────────

 Why JWKS exists

 Supabase signs tokens with private keys.

 Your backend must verify with the matching public keys.

 Those public keys are exposed at:

 ```text
   https://bxqpoqsaiznfwfmernyv.supabase.co/auth/v1/.well-known/jwks.json
 ```

 That JWKS endpoint is just a JSON document containing public signing keys.

 Your backend never gets the private key.

 That’s the correct model.

 ────────────────────────────────────────────────────────────────────────────────

 What keyfunc is doing

 Library used:

 - github.com/golang-jwt/jwt/v5
 - github.com/MicahParks/keyfunc/v3

 keyfunc:
 - fetches the JWKS
 - caches it
 - uses the right public key for token verification
 - refreshes keys in background

 So you are not manually downloading the key every request.

 Good:
 - minimal
 - correct
 - supports key rotation

 ────────────────────────────────────────────────────────────────────────────────

 How JWT validation works in this code

 Inside internal/auth/verifier.go:

 ```go
   jwt.ParseWithClaims(...)
 ```

 with options:

 - jwt.WithIssuer(v.issuer)
 - jwt.WithAudience(v.audience)
 - jwt.WithValidMethods([]string{jwt.SigningMethodES256.Alg()})

 That means:

 1. Signature validation

 The token signature must match one of the public keys from Supabase JWKS.

 If not:
 - reject

 2. Algorithm restriction

 Only ES256 is accepted.

 This is important because:
 - you explicitly do not want HS256 fallback
 - prevents bad/unsafe algorithm confusion

 3. Issuer validation

 Token iss must equal:

 ```text
   https://bxqpoqsaiznfwfmernyv.supabase.co/auth/v1
 ```

 If token says some other issuer:
 - reject

 4. Audience validation

 Token aud must contain:

 ```text
   authenticated
 ```

 If not:
 - reject

 5. Time validation

 The JWT lib validates standard registered claims like:
 - exp
 - nbf
 - iat

 So expired/not-yet-valid tokens fail automatically.

 6. Subject required

 After parsing, code checks:

 ```go
   if strings.TrimSpace(claims.Subject) == ""
 ```

 Because sub is the stable external user ID.
 Without it, you cannot map to a local user.

 ────────────────────────────────────────────────────────────────────────────────

 What identity we extract

 From the token we pull:

 - sub → stable Supabase user id
 - email
 - user_metadata.name

 Then convert that into:

 ```go
   Identity{
       Provider: "supabase",
       Subject:  <sub>,
       Email:    <email>,
       Name:     <name>,
   }
 ```

 That Identity is what the rest of the app uses.

 ────────────────────────────────────────────────────────────────────────────────

 How verification middleware works

 ### File:

 internal/auth/middleware.go

 Flow:

 Step 1: read Authorization

 Looks for header:

 ```http
   Authorization: Bearer ...
 ```

 If missing:
 - 401

 Step 2: require Bearer format

 If header doesn’t start with Bearer :
 - 401

 Step 3: extract token

 Takes the token string after Bearer

 If empty:
 - 401

 Step 4: verify token

 Calls:

 ```go
   identity, err := verifier.Verify(token)
 ```

 If invalid:
 - 401

 Step 5: put identity in context

 If valid:

 ```go
   WithIdentity(r.Context(), identity)
 ```

 Then passes request onward.

 So handlers never need to parse JWT themselves.

 ────────────────────────────────────────────────────────────────────────────────

 How users are stored

 Your app DB is separate from Supabase DB.

 That’s important.

 Supabase is not your app database here.
 It is only the auth system.

 ────────────────────────────────────────────────────────────────────────────────

 users table

 Schema:

 - id uuid primary key
 - auth_provider text
 - auth_subject text
 - email text
 - name text
 - created_at timestamptz
 - unique (auth_provider, auth_subject)

 Meaning:

 ### auth_provider

 For now always:

 ```text
   supabase
 ```

 Why keep it?
 - future-proofing
 - lets you support another provider later if needed

 ### auth_subject

 This is the external identity key.
 For Supabase it is:

 ```text
   JWT sub claim
 ```

 This is the real stable mapping key.

 Not email.

 That matters because:
 - emails can change
 - subject IDs are stable

 So local user lookup is:

 ```sql
   WHERE auth_provider = 'supabase'
     AND auth_subject = <jwt sub>
 ```

 That’s the core identity link.

 ────────────────────────────────────────────────────────────────────────────────

 Why we don’t use email as the lookup key

 Because email is not the strongest identity key.

 Good reasons:
 - user may change email in auth provider
 - auth subject is the stable canonical external ID

 So:
 - sub identifies the person
 - email and name are profile data

 ────────────────────────────────────────────────────────────────────────────────

 What happens on first /me

 In internal/app/me.go:

 1. Find user by provider + subject

 ```go
   GetUserByAuthSubject("supabase", identity.Subject)
 ```

 If found:
 - use existing local user

 If not found:
 - create local user with:
     - provider = supabase
     - subject = JWT sub
     - email = JWT email
     - name = JWT user_metadata.name

 ────────────────────────────────────────────────────────────────────────────────

 2. Load organizations

 Query all orgs for the local user.

 ────────────────────────────────────────────────────────────────────────────────

 3. If no orgs, create default workspace

 Name is:

 - "<name>'s Workspace" if name exists
 - otherwise "<email>'s Workspace"

 Then insert membership:

 - role = owner

 ────────────────────────────────────────────────────────────────────────────────

 4. Return response

 ```json
   {
     "user": {
       "id": "...",
       "email": "...",
       "name": "..."
     },
     "organizations": [
       {
         "id": "...",
         "name": "...",
         "role": "owner"
       }
     ]
   }
 ```

 ────────────────────────────────────────────────────────────────────────────────

 Why transaction is used in /me

 handleMe starts a DB transaction.

 Why:
 - if user creation happens
 - and org creation happens
 - and membership creation happens

 you want all of that to succeed together.

 Without a transaction, you could end up with:
 - user created
 - org not created
 - membership missing

 That’s half-broken state.

 With transaction:
 - all commit together
 - or all roll back

 Good boring safety.

 ────────────────────────────────────────────────────────────────────────────────

 How organizations are stored

 organizations

 Just the org row.

 organization_members

 Join table between users and orgs.

 Fields:
 - org_id
 - user_id
 - role

 This lets one user belong to many orgs later.

 For now first /me creates:
 - one default org
 - one membership with role = owner

 ────────────────────────────────────────────────────────────────────────────────

 Why /me is the only protected route right now

 Because current auth scope is intentionally tiny.

 You asked for:
 - Supabase JWT verification
 - local user mapping
 - default org creation
 - /me

 So there’s no extra architecture yet.

 Just:
 - public health
 - protected me

 That’s the right minimal base.

 ────────────────────────────────────────────────────────────────────────────────

 Important distinction: auth vs app user

 This is probably the biggest conceptual shift.

 Supabase auth user

 Exists in Supabase.
 Identified by:
 - JWT
 - sub

 Local app user

 Exists in your Postgres DB.
 Identified by:
 - local users.id
 - linked to Supabase by:
     - auth_provider
     - auth_subject

 So Supabase answers:
 - who is this?

 Your DB answers:
 - what app data belongs to this person?

 ────────────────────────────────────────────────────────────────────────────────

 Example end-to-end

 User logs in on frontend via Supabase.

 Frontend gets token.

 Frontend calls:

 ```bash
   curl http://localhost:8080/me \
     -H "Authorization: Bearer <token>"
 ```

 Backend:

 1. middleware reads token
 2. verifier checks signature against JWKS
 3. verifier checks issuer/audience/exp
 4. identity extracted:
     - provider = supabase
     - subject = abc-123
     - email = x@y.com
     - name = Alice
 5. handler looks up:
     - supabase + abc-123
 6. if none exists:
     - create local user
     - create Alice's Workspace
     - add owner membership
 7. return user + orgs

 Second /me call:
 - same token/user
 - finds existing local user
 - finds existing org
 - returns same result
 - no duplicate rows

 ────────────────────────────────────────────────────────────────────────────────

 Files to read first

 Best order:

 1. internal/auth/verifier.go
     - how JWT validation works
 2. internal/auth/middleware.go
     - how route protection works
 3. internal/auth/claims.go
     - what data we extract
 4. internal/app/me.go
     - how auth identity maps into DB records
 5. internal/app/routes.go
     - how middleware is attached
 6. internal/config/config.go
     - env wiring
 7. cmd/api/main.go
     - startup wiring

 ────────────────────────────────────────────────────────────────────────────────

 Mental model to keep

 Use this:

 - Supabase token = proof of identity
 - JWKS verification = proof token is real
 - Identity struct = normalized auth data
 - users table = local app user mapping
 - organization_members = app-level ownership/membership
 - /me = “sync auth identity into local app state, then return it”

 ────────────────────────────────────────────────────────────────────────────────

 If you want, next I can do one of these:

 - walk through internal/auth/verifier.go line by line
 - walk through internal/app/me.go line by line
 - draw the whole request lifecycle as a small ASCII diagram

