# 🎯 Quick Start Guide - Community Focused (CF)

## ภาพรวมโปรเจกต์

คุณได้รับ **Social Media App ที่สมบูรณ์แบบ** พร้อมใช้งานทันทีด้วยฟีเจอร์:

✅ **Server-Driven UI** - เปลี่ยนธีมสี โลโก้ จาก Database  
✅ **Real-time Chat** - แชทแบบ Real-time ด้วย Supabase  
✅ **Social Features** - Like, Comment, Share, Follow  
✅ **Admin Panel** - จัดการแอปผ่านหน้า Admin  
✅ **Security First** - RLS, Bcrypt, ไม่มี Hardcoded Keys  
✅ **GitHub Ready** - Push ขึ้น GitHub ได้ทันที  

---

## 🚀 เริ่มต้นใช้งาน 3 ขั้นตอน

### ขั้นตอนที่ 1: Setup Environment (5 นาที)

```bash
# 1. เข้าไปในโฟลเดอร์โปรเจกต์
cd /path/to/community-focused

# 2. ติดตั้ง Dependencies
npm install

# 3. รัน Setup Script (macOS/Linux)
chmod +x setup.sh
./setup.sh

# หรือทำด้วยมือ:
cp .env.example .env
nano .env  # แก้ไขใส่ Supabase credentials
```

**ใน `.env` ให้ใส่:**
```bash
SUPABASE_URL=https://xxxxx.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI...
ADMIN_PASSWORD=K9#vP2!zR8$mL4q
```

### ขั้นตอนที่ 2: Setup Supabase (10 นาที)

#### 2.1 สร้าง Supabase Project
1. ไปที่ https://app.supabase.com
2. คลิก "New Project"
3. ตั้งชื่อ: `community-focused`
4. เลือก Region ที่ใกล้ที่สุด
5. รอ 2-3 นาทีให้สร้างเสร็จ

#### 2.2 รัน Database Schema
1. เปิด Supabase Dashboard > SQL Editor
2. คัดลอกทั้งหมดจากไฟล์ `supabase_schema.sql`
3. วางใน SQL Editor
4. คลิก "RUN" (รอ 10-20 วินาที)
5. ✅ จะเห็น "Success. No rows returned"

#### 2.3 สร้าง Storage Buckets
ไปที่ Storage > Create bucket:

**Bucket 1: avatars**
- Name: `avatars`
- Public: ✅ เปิด
- Allowed MIME types: `image/*`
- Max file size: 5MB

**Bucket 2: post_media**
- Name: `post_media`
- Public: ✅ เปิด
- Allowed MIME types: `image/*, video/*`
- Max file size: 50MB

**Bucket 3: chat_media**
- Name: `chat_media`
- Public: ❌ ปิด (Private)
- Allowed MIME types: `image/*, video/*`
- Max file size: 20MB

#### 2.4 คัดลอก API Keys
1. Settings > API
2. คัดลอก `Project URL` → ใส่ใน `.env` ที่ `SUPABASE_URL`
3. คัดลอก `anon public` → ใส่ใน `.env` ที่ `SUPABASE_ANON_KEY`

### ขั้นตอนที่ 3: Run App (2 นาที)

```bash
# เริ่ม Metro Bundler
npm start

# ใน Terminal ใหม่:
# สำหรับ iOS (ต้องมี macOS)
npm run ios

# สำหรับ Android
npm run android
```

**🎉 เสร็จแล้ว! แอปจะเปิดขึ้นมา**

---

## 📱 ทดสอบฟีเจอร์

### 1. ทดสอบการสมัครสมาชิก
1. เปิดแอป → คลิก "Sign Up"
2. กรอก Email, Username, Password
3. ✅ ควรสมัครสำเร็จและเข้าสู่แอปอัตโนมัติ

### 2. ทดสอบการโพสต์
1. หน้า Feed → กดปุ่ม ✏️ (ล่างขวา)
2. พิมพ์ข้อความ → กด "Post"
3. ✅ ควรเห็นโพสต์ปรากฏในฟีด

### 3. ทดสอบ Admin Panel
1. ไปที่ Settings (⚙️)
2. **แตะโลโก้ 3 ครั้ง ภายใน 3 วินาที**
3. ใส่รหัส: `K9#vP2!zR8$mL4q`
4. ✅ เข้าสู่หน้า Admin Panel

**ในหน้า Admin:**
- แท็บ Theme: เปลี่ยนสี Primary Color → `#FF0000`
- บันทึก → กลับหน้า Feed → ✅ สีควรเปลี่ยนทันที!

### 4. ตั้งค่า Admin User ของคุณ

หลังจากสมัครสมาชิกแล้ว ให้ตั้งค่า Admin:

```javascript
// วิธีที่ 1: ใช้ Node.js
node -e "
const bcrypt = require('bcryptjs');
const hash = bcrypt.hashSync('K9#vP2!zR8$mL4q', 10);
console.log('Hash:', hash);
"
// คัดลอก Hash ที่ได้

// วิธีที่ 2: ใช้ Supabase SQL Editor
INSERT INTO admin_users (user_id, password_hash)
VALUES (
  'your-user-id-from-auth-users-table',
  'paste-hash-here'
);
```

**หา User ID:**
1. Supabase > Authentication > Users
2. คัดลอก UUID ของบัญชีคุณ

---

## 🎨 ปรับแต่งแอป

### เปลี่ยนชื่อแอป
```sql
UPDATE app_settings 
SET value = 'ชื่อแอปใหม่' 
WHERE key = 'app_name_full';

UPDATE app_settings 
SET value = 'CF' 
WHERE key = 'app_name_short';
```

### เปลี่ยนสีธีม
```sql
UPDATE app_settings 
SET value = '#FF6B6B'  -- สีแดง
WHERE key = 'primary_color';
```

### เพิ่มคำแปลภาษาลาว
```sql
INSERT INTO translations (key, language, value)
VALUES ('welcome_message', 'lo', 'ຍິນດີຕ້ອນຮັບສູ່ແອບຂອງພວກເຮົາ');
```

**ใช้ในโค้ด:**
```typescript
const { t } = useTranslation();
<Text>{t('welcome_message')}</Text>
```

---

## 🔐 Push ขึ้น GitHub (ปลอดภัย 100%)

```bash
# 1. สร้าง Repository ใหม่ใน GitHub
# ไปที่ https://github.com/new

# 2. Initialize Git
git init
git add .
git commit -m "Initial commit: CF Social Media App"

# 3. Connect to GitHub
git remote add origin https://github.com/YOUR-USERNAME/community-focused.git
git branch -M main
git push -u origin main
```

**✅ ปลอดภัย!** ไฟล์ `.env` อยู่ใน `.gitignore` แล้ว

---

## 📚 โครงสร้างโปรเจกต์

```
community-focused/
├── 📄 supabase_schema.sql      ← รัน SQL นี้ใน Supabase
├── 📄 .env.example              ← Template สำหรับ .env
├── 📄 .env                      ← ไฟล์จริง (ห้าม Commit!)
├── 📄 setup.sh                  ← Script Setup อัตโนมัติ
│
├── 📂 src/
│   ├── 📂 screens/             ← หน้าจอต่างๆ
│   │   ├── SplashScreen.tsx
│   │   ├── AuthScreen.tsx
│   │   ├── FeedScreen.tsx
│   │   ├── ChatScreen.tsx
│   │   ├── SettingsScreen.tsx
│   │   └── AdminPanelScreen.tsx
│   │
│   ├── 📂 contexts/            ← Theme & Translation
│   │   ├── ThemeContext.tsx
│   │   └── TranslationContext.tsx
│   │
│   ├── 📂 services/            ← API & Supabase
│   │   ├── supabase.ts
│   │   ├── queryClient.ts
│   │   └── post.service.ts
│   │
│   └── 📂 utils/               ← Helper Functions
│       ├── crypto.ts
│       └── constants.ts
│
└── 📂 .github/workflows/       ← CI/CD GitHub Actions
    └── ci.yml
```

---

## 🛠️ คำสั่งที่ใช้บ่อย

```bash
# Development
npm start              # เริ่ม Metro bundler
npm run ios            # Run บน iOS
npm run android        # Run บน Android

# Testing
npm test               # Run tests
npm run lint           # Check code quality
npm run format         # Format code

# Build
cd android && ./gradlew assembleRelease  # Build Android APK
# Xcode > Product > Archive                # Build iOS

# Clean
npm start -- --reset-cache                # Reset Metro cache
rm -rf node_modules && npm install        # Reinstall dependencies
```

---

## 🐛 แก้ปัญหาที่พบบ่อย

### ❌ "Missing Supabase credentials"
```bash
# ตรวจสอบว่ามี .env ไหม
ls -la .env

# ถ้าไม่มี ให้สร้าง
cp .env.example .env
nano .env  # แก้ไขใส่ค่า

# Restart
npm start -- --reset-cache
```

### ❌ iOS Build Error (Pods)
```bash
cd ios
rm -rf Pods Podfile.lock
pod install
cd ..
npm run ios
```

### ❌ Android Build Error
```bash
cd android
./gradlew clean
cd ..
npm run android
```

### ❌ "Admin panel ไม่ขึ้น"
```sql
-- ตรวจสอบว่ามี admin_users หรือยัง
SELECT * FROM admin_users;

-- ถ้าไม่มี ให้เพิ่ม
INSERT INTO admin_users (user_id, password_hash)
VALUES ('your-user-id', 'hashed-password');
```

---

## 📖 เอกสารทั้งหมด

| ไฟล์ | คำอธิบาย |
|------|----------|
| `README.md` | คู่มือหลักของโปรเจกต์ |
| `SECURITY.md` | คู่มือด้านความปลอดภัย |
| `PROJECT_SUMMARY.md` | สรุปโปรเจกต์และฟีเจอร์ |
| `DEPLOYMENT.md` | คู่มือการ Deploy |
| `CONTRIBUTING.md` | คู่มือสำหรับผู้ร่วมพัฒนา |

---

## 🎓 เรียนรู้เพิ่มเติม

### React Native
- [React Native Docs](https://reactnative.dev/docs/getting-started)
- [React Navigation](https://reactnavigation.org/)

### Supabase
- [Supabase Docs](https://supabase.com/docs)
- [RLS Guide](https://supabase.com/docs/guides/auth/row-level-security)

### TypeScript
- [TypeScript Handbook](https://www.typescriptlang.org/docs/)

---

## 💡 Tips & Tricks

### 1. Dev Tools
```bash
# React Native Debugger (แนะนำ)
brew install --cask react-native-debugger

# Reactotron (Alternative)
npm install -g reactotron-cli
```

### 2. Hot Reload
- กด `r` ใน Metro bundler = Reload
- กด `d` = Open Dev Menu
- กด `i` = Open Inspector

### 3. Performance
```typescript
// ใช้ React.memo สำหรับ Component ที่ Render บ่อย
export default React.memo(PostCard);

// ใช้ useCallback สำหรับ Functions
const handleLike = useCallback(() => {
  likePost(postId);
}, [postId]);
```

---

## 🎯 Next Steps

หลังจากใช้งานได้แล้ว:

1. ✅ ทดสอบทุกฟีเจอร์
2. ✅ เปลี่ยนธีมสีให้เหมาะกับแบรนด์
3. ✅ เพิ่มคำแปลภาษาลาว
4. ✅ Upload โลโก้ไปที่ Supabase Storage
5. ✅ เชิญเพื่อนมาทดสอบ
6. ✅ Deploy ขึ้น App Store / Google Play

---

## 💬 ติดต่อ & Support

- 📧 Email: support@communityfocused.app
- 💬 Discord: [เข้าร่วมชุมชน](#)
- 🐛 Issues: [GitHub Issues](https://github.com/your-repo/issues)

---

**🎉 ขอให้สนุกกับการพัฒนาแอป!**

สร้างด้วย ❤️ สำหรับชุมชน
Version 1.0.0
