# 🌟 Community Focused (CF)

[![React Native](https://img.shields.io/badge/React%20Native-0.73-blue.svg)](https://reactnative.dev/)
[![Supabase](https://img.shields.io/badge/Supabase-Backend-green.svg)](https://supabase.com/)
[![TypeScript](https://img.shields.io/badge/TypeScript-5.0-blue.svg)](https://www.typescriptlang.org/)

> A modern social media app with **Server-Driven UI**, real-time chat, and dynamic theming powered by Supabase.

## ✨ Features

### 🎨 Dynamic CMS (Server-Driven UI)
- **Live Theme Updates**: Colors, logo, and app name controlled from Supabase
- **No Code Deployments**: Change app appearance without rebuilding
- **Multi-language Support**: Lao translations stored in database

### 🔐 Security First
- **Row Level Security (RLS)**: Complete database protection
- **Encrypted Admin Access**: Bcrypt password hashing
- **No Hardcoded Secrets**: All credentials in environment variables
- **GitHub-Safe**: .gitignore prevents secret leaks

### 🚀 Core Features
- ✅ **Real-time Feed**: Posts with likes, comments, and shares
- ✅ **Instant Messaging**: Real-time 1-on-1 chat
- ✅ **Social Graph**: Follow/unfollow system
- ✅ **Notifications**: Real-time activity updates
- ✅ **Admin Panel**: Hidden trigger (tap logo 3x in 3 seconds)
- ✅ **Persistent Sessions**: Auto-login on app restart

### 🎯 Advanced Features
- Infinite scroll pagination
- Image/video support
- Threaded comments
- Read receipts (chat)
- Pull-to-refresh
- Optimized image caching (FastImage)

---

## 📋 Prerequisites

Before you begin, ensure you have:

- **Node.js** >= 18.0.0
- **npm** >= 9.0.0 or **Yarn**
- **React Native CLI**: `npm install -g react-native-cli`
- **Xcode** (for iOS) or **Android Studio** (for Android)
- **Supabase Account**: [Sign up here](https://supabase.com)

---

## 🚀 Quick Start

### 1. Clone the Repository

```bash
git clone https://github.com/your-username/community-focused.git
cd community-focused
```

### 2. Install Dependencies

```bash
npm install
# or
yarn install
```

### 3. Set Up Supabase

#### 3.1 Create Supabase Project
1. Go to [Supabase Dashboard](https://app.supabase.com)
2. Create a new project
3. Note your **Project URL** and **Anon Key**

#### 3.2 Run Database Schema
1. Open Supabase SQL Editor
2. Copy contents of `supabase_schema.sql`
3. Run the SQL script to create all tables, policies, and functions

#### 3.3 Set Up Storage Buckets
In Supabase Dashboard > Storage:

1. **Create Buckets**:
   - `avatars` (public)
   - `post_media` (public)
   - `chat_media` (private)

2. **Set Policies**:
   - Allow authenticated users to upload
   - Allow public read for public buckets

### 4. Configure Environment Variables

```bash
# Copy example file
cp .env.example .env

# Edit .env with your values
```

**`.env` file:**
```bash
SUPABASE_URL=https://your-project-id.supabase.co
SUPABASE_ANON_KEY=your-anon-key-here
ADMIN_PASSWORD=K9#vP2!zR8$mL4q
```

⚠️ **CRITICAL**: Never commit `.env` to Git!

### 5. Initialize Admin User

After creating your first account in the app:

```javascript
// Run this in a Node.js script or React Native debugger
import { initializeAdminUser } from './src/utils/crypto';

const userId = 'your-user-id'; // Get from Supabase auth.users
const hash = await initializeAdminUser(userId);

// Then insert into Supabase:
// INSERT INTO admin_users (user_id, password_hash) 
// VALUES ('your-user-id', 'generated-hash');
```

### 6. Run the App

#### iOS
```bash
cd ios && pod install && cd ..
npm run ios
```

#### Android
```bash
npm run android
```

---

## 📁 Project Structure

```
community-focused/
├── src/
│   ├── components/          # Reusable UI components
│   ├── contexts/            # React Context providers
│   │   ├── ThemeContext.tsx       # Dynamic theming
│   │   └── TranslationContext.tsx # i18n system
│   ├── screens/             # App screens
│   │   ├── SplashScreen.tsx
│   │   ├── AuthScreen.tsx
│   │   ├── FeedScreen.tsx
│   │   ├── ChatScreen.tsx
│   │   ├── ProfileScreen.tsx
│   │   ├── SettingsScreen.tsx
│   │   └── AdminPanelScreen.tsx
│   ├── services/            # API & business logic
│   │   └── supabase.ts
│   ├── navigation/          # Navigation setup
│   │   └── AppNavigator.tsx
│   ├── utils/               # Helper functions
│   │   └── crypto.ts              # Password hashing
│   └── types/               # TypeScript types
├── .env.example             # Environment template
├── .gitignore              # Git ignore rules
├── supabase_schema.sql     # Database schema
└── package.json            # Dependencies
```

---

## 🔐 Security Best Practices

### ✅ DO:
- ✅ Keep `.env` files local and never commit them
- ✅ Use different Supabase projects for dev/staging/production
- ✅ Rotate admin passwords regularly
- ✅ Enable RLS on all Supabase tables
- ✅ Use environment variables for all secrets
- ✅ Review Supabase logs for suspicious activity

### ❌ DON'T:
- ❌ Commit `.env` files to Git
- ❌ Share API keys in screenshots or issues
- ❌ Use the same password across environments
- ❌ Disable RLS policies for convenience
- ❌ Store secrets in code comments

---

## 🎨 Customizing Your App

### Change Theme from Admin Panel
1. Open the app
2. Go to **Settings**
3. Tap the **logo 3 times** within 3 seconds
4. Enter admin password: `K9#vP2!zR8$mL4q`
5. Navigate to **Theme** tab
6. Update colors, logo URL, or app name
7. Changes apply instantly to all users!

### Add New Translations
In Admin Panel > Translations:
1. Enter translation key (e.g., `welcome_message`)
2. Enter Lao text
3. Use in code: `t('welcome_message')`

### Update App Settings via SQL
```sql
-- Change primary color
UPDATE app_settings 
SET value = '#FF6B6B' 
WHERE key = 'primary_color';

-- Change app name
UPDATE app_settings 
SET value = 'My Community' 
WHERE key = 'app_name_full';
```

---

## 🚢 Deployment

### Prepare for Production

1. **Update Environment**:
```bash
# .env.production
SUPABASE_URL=https://prod-project.supabase.co
SUPABASE_ANON_KEY=prod-anon-key
ADMIN_PASSWORD=YourSecureProductionPassword123!
```

2. **Build Release**:

**Android (APK)**:
```bash
cd android
./gradlew assembleRelease
# Output: android/app/build/outputs/apk/release/app-release.apk
```

**iOS (Archive)**:
```bash
# Open Xcode
# Product > Archive
# Distribute App > App Store Connect
```

### Environment Variables in CI/CD

**GitHub Actions Example**:
```yaml
# .github/workflows/deploy.yml
env:
  SUPABASE_URL: ${{ secrets.SUPABASE_URL }}
  SUPABASE_ANON_KEY: ${{ secrets.SUPABASE_ANON_KEY }}
  ADMIN_PASSWORD: ${{ secrets.ADMIN_PASSWORD }}
```

Add secrets in: GitHub > Settings > Secrets and variables > Actions

---

## 🧪 Testing

```bash
# Run tests
npm test

# Run with coverage
npm test -- --coverage

# Run linter
npm run lint

# Format code
npm run format
```

---

## 🐛 Troubleshooting

### "Missing Supabase credentials" Error
- Ensure `.env` file exists in root directory
- Check that `SUPABASE_URL` and `SUPABASE_ANON_KEY` are set
- Restart Metro bundler: `npm start -- --reset-cache`

### Admin Panel Not Accessible
- Ensure your user_id is in `admin_users` table
- Verify password hash matches in database
- Check admin password in `.env` file

### Real-time Updates Not Working
- Verify Supabase Realtime is enabled for your project
- Check database triggers exist (see `supabase_schema.sql`)
- Ensure tables have `REPLICA IDENTITY FULL`

### Build Errors (iOS)
```bash
cd ios
pod deintegrate
pod install
cd ..
npm start -- --reset-cache
```

### Build Errors (Android)
```bash
cd android
./gradlew clean
cd ..
npm start -- --reset-cache
```

---

## 📚 Documentation

- [Supabase Documentation](https://supabase.com/docs)
- [React Native Documentation](https://reactnative.dev/docs/getting-started)
- [React Navigation](https://reactnavigation.org/docs/getting-started)
- [TypeScript Handbook](https://www.typescriptlang.org/docs/)

---

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/amazing-feature`
3. Commit changes: `git commit -m 'Add amazing feature'`
4. Push to branch: `git push origin feature/amazing-feature`
5. Open a Pull Request

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 👨‍💻 Author

**Your Name**
- GitHub: [@your-username](https://github.com/your-username)

---

## 🙏 Acknowledgments

- [Supabase](https://supabase.com) - Open source Firebase alternative
- [React Native](https://reactnative.dev) - Mobile app framework
- Lao community for translation support

---

## 📞 Support

Having issues? Contact us:
- 📧 Email: support@communityfocused.app
- 💬 Discord: [Join our community](#)
- 🐛 Issues: [GitHub Issues](https://github.com/your-username/community-focused/issues)

---

**Made with ❤️ for the community**
