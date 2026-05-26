# 🔐 Security Guide - Community Focused (CF)

## ⚠️ CRITICAL: Read This Before Deploying

This guide covers essential security practices for the Community Focused app. **Failure to follow these guidelines can result in data breaches, account compromises, and security vulnerabilities.**

---

## 📋 Table of Contents

1. [Environment Variables Setup](#environment-variables-setup)
2. [Supabase Security Configuration](#supabase-security-configuration)
3. [Admin Password Management](#admin-password-management)
4. [GitHub Security](#github-security)
5. [API Key Rotation](#api-key-rotation)
6. [Production Checklist](#production-checklist)
7. [Incident Response](#incident-response)

---

## 1. Environment Variables Setup

### ✅ Correct Setup

```bash
# .env (NEVER commit this file!)
SUPABASE_URL=https://xxxxxxxxxxxxx.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
ADMIN_PASSWORD=YourSecurePassword123!@#
```

### ✅ Multiple Environments

Create separate `.env` files for each environment:

```bash
.env.development    # Local development
.env.staging        # Testing environment
.env.production     # Live production
```

**Load environment-specific file:**
```bash
# Development
cp .env.development .env

# Production
cp .env.production .env
```

### ❌ What NOT to Do

```javascript
// ❌ NEVER hardcode credentials
const SUPABASE_URL = "https://myproject.supabase.co";

// ❌ NEVER commit .env files
git add .env  // DON'T DO THIS!

// ❌ NEVER log sensitive data
console.log("API Key:", process.env.SUPABASE_ANON_KEY);
```

---

## 2. Supabase Security Configuration

### A. Enable Row Level Security (RLS)

**Critical: ALL tables must have RLS enabled!**

```sql
-- Verify RLS is enabled
SELECT tablename, rowsecurity 
FROM pg_tables 
WHERE schemaname = 'public';

-- If rowsecurity = false, enable it:
ALTER TABLE table_name ENABLE ROW LEVEL SECURITY;
```

### B. Service Role Key Protection

**🚨 NEVER use the Service Role key in your mobile app!**

The Service Role key bypasses all RLS policies and should only be used:
- In backend servers (not in React Native)
- For admin scripts run from secure environments
- For database migrations

```bash
# ✅ Safe in backend server
SUPABASE_SERVICE_ROLE_KEY=eyJhbGci...  # Server only!

# ❌ NEVER in mobile app
# Don't add this to your .env for React Native
```

### C. API Settings

In Supabase Dashboard > Settings > API:

1. **Enable Email Confirmations**: Require email verification
2. **Set JWT Expiry**: 1 hour (3600 seconds)
3. **Enable Refresh Tokens**: Yes
4. **CORS Allowed Origins**: Add your domains only

### D. Storage Security

In Supabase Dashboard > Storage:

**Public Buckets (avatars, post_media):**
```sql
-- Policy: Anyone can read
CREATE POLICY "Public Access" ON storage.objects
FOR SELECT USING (bucket_id = 'avatars');

-- Policy: Authenticated users can upload
CREATE POLICY "Authenticated Upload" ON storage.objects
FOR INSERT WITH CHECK (
  bucket_id = 'avatars' 
  AND auth.role() = 'authenticated'
);
```

**Private Buckets (chat_media):**
```sql
-- Policy: Only participants can access
CREATE POLICY "Participants Only" ON storage.objects
FOR SELECT USING (
  bucket_id = 'chat_media'
  AND (
    auth.uid()::text = (storage.foldername(name))[1]
    OR auth.uid()::text = (storage.foldername(name))[2]
  )
);
```

---

## 3. Admin Password Management

### A. Initial Setup

**Step 1: Hash the password**
```javascript
import { getAdminPasswordHash } from './src/utils/crypto';

const hash = await getAdminPasswordHash();
// Copy the output hash
```

**Step 2: Store in database**
```sql
INSERT INTO admin_users (user_id, password_hash)
VALUES (
  'your-user-id-from-auth-users',
  'bcrypt-hash-from-step-1'
);
```

### B. Password Requirements

**Minimum requirements:**
- At least 12 characters
- Uppercase letter
- Lowercase letter
- Number
- Special character
- Not in common password lists

**Good examples:**
```
✅ K9#vP2!zR8$mL4q
✅ Tr0pic@l_St0rm#2024
✅ Sec^re&P@ss*w0rd!99
```

**Bad examples:**
```
❌ password123
❌ admin
❌ 12345678
❌ companyname2024
```

### C. Password Rotation

**Rotate admin password every 90 days:**

```javascript
// 1. Generate new hash
const newHash = await hashPassword('NewSecurePassword123!');

// 2. Update database
UPDATE admin_users 
SET password_hash = 'new-hash-here'
WHERE user_id = 'your-user-id';

// 3. Update .env file
ADMIN_PASSWORD=NewSecurePassword123!

// 4. Restart app
```

---

## 4. GitHub Security

### A. .gitignore Verification

**Before your first commit:**

```bash
# Verify .env is ignored
git status

# Should NOT show .env
# If it does, immediately run:
git rm --cached .env
echo ".env" >> .gitignore
git add .gitignore
git commit -m "Add .env to gitignore"
```

### B. Scan for Leaked Secrets

**Install and run gitleaks:**

```bash
# Install
brew install gitleaks  # macOS
# or download from: https://github.com/gitleaks/gitleaks

# Scan repository
gitleaks detect --source . --verbose

# Scan git history
gitleaks detect --source . --log-opts="--all"
```

### C. GitHub Secrets Setup

**For GitHub Actions:**

1. Go to: Repository > Settings > Secrets and variables > Actions
2. Click "New repository secret"
3. Add:
   - `SUPABASE_URL`
   - `SUPABASE_ANON_KEY`
   - `ADMIN_PASSWORD`

**Never reference secrets in workflow files directly:**

```yaml
# ✅ Correct
env:
  SUPABASE_URL: ${{ secrets.SUPABASE_URL }}

# ❌ Wrong
env:
  SUPABASE_URL: "https://myproject.supabase.co"
```

### D. What to Do If Secrets Are Exposed

**If you accidentally commit secrets:**

```bash
# 1. Immediately rotate ALL exposed keys/passwords

# 2. Remove from Git history
git filter-branch --force --index-filter \
  "git rm --cached --ignore-unmatch .env" \
  --prune-empty --tag-name-filter cat -- --all

# 3. Force push (⚠️ coordinate with team first!)
git push origin --force --all

# 4. Notify team and users if necessary
```

**Or use BFG Repo-Cleaner (easier):**
```bash
# Install
brew install bfg  # macOS

# Remove .env from history
bfg --delete-files .env

# Cleanup
git reflog expire --expire=now --all
git gc --prune=now --aggressive

# Force push
git push origin --force --all
```

---

## 5. API Key Rotation

### When to Rotate Keys

- **Immediately** if keys are exposed publicly
- **Every 90 days** as standard practice
- **After team member leaves** who had access
- **After security incident**

### How to Rotate Supabase Keys

**Step 1: Generate new keys** (Supabase Dashboard > Settings > API)
1. Click "Generate new anon key"
2. Copy new key

**Step 2: Update all environments**
```bash
# Update .env files
SUPABASE_ANON_KEY=new-key-here

# Update GitHub Secrets
# Update CI/CD environments
# Update production servers
```

**Step 3: Deploy updates**
```bash
# Test in development first
npm start

# Deploy to production
# Monitor for errors
```

**Step 4: Revoke old keys** (in Supabase Dashboard)

---

## 6. Production Checklist

### Before Going Live

- [ ] All tables have RLS enabled
- [ ] Service role key NOT in mobile app
- [ ] .env file in .gitignore
- [ ] No secrets in git history
- [ ] Admin password is strong (12+ chars)
- [ ] Email confirmation enabled
- [ ] CORS configured correctly
- [ ] Storage policies tested
- [ ] SSL/HTTPS enforced
- [ ] Error messages don't leak info
- [ ] Logging doesn't include secrets
- [ ] Rate limiting enabled
- [ ] Backup strategy in place

### Production .env Template

```bash
# Production Environment Variables
SUPABASE_URL=https://prod-project.supabase.co
SUPABASE_ANON_KEY=production-anon-key
ADMIN_PASSWORD=VerySecureProductionPassword!2024#

# Optional: Error tracking
SENTRY_DSN=https://...

# Optional: Analytics
MIXPANEL_TOKEN=...
```

---

## 7. Incident Response

### If You Suspect a Security Breach

**Immediate Actions (First 15 minutes):**

1. **Rotate ALL credentials**
   - Supabase anon key
   - Admin password
   - Any other API keys

2. **Review Supabase logs**
   - Check for suspicious queries
   - Look for unusual access patterns
   - Note any unauthorized data access

3. **Disable compromised accounts**
   ```sql
   UPDATE profiles 
   SET is_banned = true 
   WHERE id = 'suspicious-user-id';
   ```

4. **Notify team and stakeholders**

**Investigation (Next 24 hours):**

1. Review git commit history
2. Check GitHub Actions logs
3. Review Supabase audit logs
4. Identify scope of compromise
5. Document timeline of events

**Recovery:**

1. Fix security vulnerabilities
2. Deploy security patches
3. Notify affected users (if required by law)
4. Implement additional monitoring
5. Post-mortem analysis

---

## 8. Security Monitoring

### Set Up Alerts

**Supabase Dashboard > Project Settings > Alerts:**

- Failed authentication attempts (> 10/hour)
- Unusual database queries
- Storage quota exceeded
- RLS policy violations

### Regular Audits

**Weekly:**
- Review new user signups
- Check admin panel access logs
- Monitor API usage patterns

**Monthly:**
- Review and update RLS policies
- Audit user permissions
- Test backup restoration
- Update dependencies (`npm audit`)

**Quarterly:**
- Rotate all credentials
- Security penetration testing
- Review and update security policies
- Team security training

---

## 9. Additional Resources

- [Supabase Security Best Practices](https://supabase.com/docs/guides/auth/security)
- [OWASP Mobile Security Guide](https://owasp.org/www-project-mobile-security/)
- [React Native Security](https://reactnative.dev/docs/security)
- [GitHub Secret Scanning](https://docs.github.com/en/code-security/secret-scanning)

---

## 🆘 Emergency Contacts

**Security Incident:**
- Email: security@communityfocused.app
- Phone: [Your emergency contact]

**Supabase Support:**
- Dashboard: https://app.supabase.com/support

---

**Remember: Security is not a one-time setup—it's an ongoing process!**

Last Updated: 2024
Version: 1.0
