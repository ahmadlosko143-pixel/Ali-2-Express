# Firebase Integration Guide for AliExpress Clone

## Prerequisites Completed

- [x] Firebase dependencies added to `pubspec.yaml`
- [x] Firebase initialization code added to `main.dart`
- [x] Dependencies installed

---

## Steps You Need to Complete

### Step 1: Install Firebase CLI

Open Command Prompt or PowerShell and run:

```bash
npm install -g firebase-tools
```

**Verify installation:**
```bash
firebase --version
```

---

### Step 2: Install FlutterFire CLI

```bash
dart pub global activate flutterfire_cli
```

**Verify installation:**
```bash
flutterfire --version
```

**Note:** If you get "command not found", add Dart to your PATH:
- Add `C:\Users\<YourUsername>\AppData\Local\Pub\Cache\bin` to your system PATH

---

### Step 3: Login to Firebase

```bash
firebase login
```

This will open your browser. Sign in with your Google account.

---

### Step 4: Create Firebase Project

1. Go to: https://console.firebase.google.com/
2. Click **"Add project"** or **"Create a project"**
3. Enter project name: **aliexpress-clone** (or any name you prefer)
4. Click **Continue**
5. **Google Analytics:** Enable or disable (optional)
6. Click **Create project**
7. Wait for setup to complete
8. Click **Continue**

---

### Step 5: Configure Firebase for Your App

In your project directory, run:

```bash
cd "D:\University\7th Samaster\MAD\Mid_lab\me"
flutterfire configure
```

**During configuration:**
1. It will detect your Firebase projects - select the one you just created
2. Select platforms using spacebar:
   - [x] Android
   - [x] Windows
3. Press Enter to confirm

**This will:**
- Create `lib/firebase_options.dart` file
- Update Android configuration
- Update Windows configuration
- Register your app with Firebase

---

### Step 6: Enable Firebase Services (In Firebase Console)

#### 6.1 Enable Firebase Authentication

1. In Firebase Console, go to your project
2. Click **Build** → **Authentication**
3. Click **Get Started**
4. Enable sign-in methods you want:
   - **Email/Password** (recommended for e-commerce)
   - Google
   - Facebook
   - etc.
5. Click **Save**

#### 6.2 Enable Cloud Firestore

1. Click **Build** → **Firestore Database**
2. Click **Create database**
3. Select **Start in test mode** (for development)
4. Choose a location (closest to your users)
5. Click **Enable**

#### 6.3 Enable Firebase Storage

1. Click **Build** → **Storage**
2. Click **Get started**
3. Select **Start in test mode**
4. Choose same location as Firestore
5. Click **Done**

---

### Step 7: Update Firestore Security Rules (For Testing)

In Firestore Database → Rules tab:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Allow all reads and writes for testing
    // WARNING: Change these rules before production!
    match /{document=**} {
      allow read, write: if true;
    }
  }
}
```

Click **Publish**

---

### Step 8: Update Storage Security Rules (For Testing)

In Storage → Rules tab:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /{allPaths=**} {
      // Allow all reads and writes for testing
      // WARNING: Change these rules before production!
      allow read, write: if true;
    }
  }
}
```

Click **Publish**

---

### Step 9: Test Firebase Connection

Run your app:

```bash
flutter run -d windows
```

Or for Android:

```bash
flutter run -d <your-android-device>
```

**Check for errors:**
- If you see "Firebase initialized successfully" or no Firebase errors, you're good!
- If you see import errors for `firebase_options.dart`, make sure you ran `flutterfire configure`

---

## What's Been Added to Your Project

### 1. `pubspec.yaml` - Firebase Dependencies

```yaml
# Firebase Core (Required)
firebase_core: ^3.8.1

# Firebase Services
firebase_auth: ^5.3.4
cloud_firestore: ^5.5.2
firebase_storage: ^12.3.8
```

### 2. `lib/main.dart` - Firebase Initialization

```dart
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const AliExpressCloneApp());
}
```

---

## Using Firebase in Your App

### Example: Firebase Authentication

Create a new file: `lib/services/auth_service.dart`

```dart
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Sign up with email and password
  Future<UserCredential> signUp(String email, String password) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Sign in with email and password
  Future<UserCredential> signIn(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Listen to auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();
}
```

### Example: Firestore Database

Create a new file: `lib/services/firestore_service.dart`

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Add product to Firestore
  Future<void> addProduct(Product product) async {
    await _db.collection('products').doc(product.id).set(product.toJson());
  }

  // Get all products
  Stream<List<Product>> getProducts() {
    return _db.collection('products').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Product.fromJson(doc.data())).toList());
  }

  // Update product
  Future<void> updateProduct(Product product) async {
    await _db.collection('products').doc(product.id).update(product.toJson());
  }

  // Delete product
  Future<void> deleteProduct(String productId) async {
    await _db.collection('products').doc(productId).delete();
  }
}
```

### Example: Firebase Storage (Upload Images)

Create a new file: `lib/services/storage_service.dart`

```dart
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Upload image and get download URL
  Future<String> uploadImage(File imageFile, String path) async {
    final ref = _storage.ref().child(path);
    final uploadTask = await ref.putFile(imageFile);
    final downloadUrl = await uploadTask.ref.getDownloadURL();
    return downloadUrl;
  }

  // Upload product image
  Future<String> uploadProductImage(File imageFile, String productId) async {
    return await uploadImage(
      imageFile,
      'products/$productId/${DateTime.now().millisecondsSinceEpoch}.jpg',
    );
  }

  // Delete image
  Future<void> deleteImage(String imageUrl) async {
    final ref = _storage.refFromURL(imageUrl);
    await ref.delete();
  }
}
```

---

## Next Steps

1. **Run `flutterfire configure`** to generate `firebase_options.dart`
2. **Enable Firebase services** in the console (Auth, Firestore, Storage)
3. **Test the app** to ensure Firebase initializes correctly
4. **Start using Firebase services** in your app

---

## Troubleshooting

### Error: "firebase_options.dart not found"
**Solution:** Run `flutterfire configure` in your project directory

### Error: "Firebase not initialized"
**Solution:** Make sure `Firebase.initializeApp()` is called in `main()` before `runApp()`

### Error: "Permission denied" in Firestore/Storage
**Solution:** Update security rules in Firebase Console (see Step 7 & 8)

### Error: "Platform not supported"
**Solution:** Run `flutterfire configure` and select your target platforms

---

## Important Security Note

The security rules provided above are for **development/testing only**. Before deploying to production:

1. Implement proper authentication
2. Update Firestore rules to restrict access based on user authentication
3. Update Storage rules to validate file types and sizes
4. Enable App Check for additional security

---

## Resources

- Firebase Documentation: https://firebase.google.com/docs
- FlutterFire Documentation: https://firebase.flutter.dev/
- Firebase Console: https://console.firebase.google.com/

---

Good luck with your Firebase integration!
