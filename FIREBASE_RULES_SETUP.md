# Firebase Security Rules Setup

## Issue
The app is getting a permission error when trying to access the `TextbookPosts` collection:
```
Listen for query at TextbookPosts failed: Missing or insufficient permissions.
```

## Solution
The Firestore security rules need to be updated to allow read/write access to the `TextbookPosts` collection.

## Instructions for Team Manager

### Option 1: Using Firebase Console (Easiest)
1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select the project: `cen4010-textbookapp`
3. Navigate to **Firestore Database** → **Rules** tab
4. Replace the existing rules with the following:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Allow read/write access to TextbookPosts collection
    // For production, you should add authentication checks
    match /TextbookPosts/{postId} {
      allow read: if true;
      allow write: if true;
    }
    
    // Allow read/write access to Users collection (if you have one)
    match /Users/{userId} {
      allow read: if true;
      allow write: if true;
    }
  }
}
```

5. Click **Publish** to deploy the rules

### Option 2: Using Firebase CLI
If you have Firebase CLI set up:
```bash
firebase deploy --only firestore:rules
```

## Important Notes
- These rules allow **public read/write access** (anyone can read/write)
- For production, you should add authentication checks like:
  ```javascript
  allow read: if request.auth != null;
  allow write: if request.auth != null && request.auth.uid == resource.data.user_id;
  ```
- The rules file is also saved in the project root as `firestore.rules` for reference

## Testing
After deploying, the app should be able to:
- ✅ Read posts from `TextbookPosts` collection
- ✅ Create new posts
- ✅ Delete posts

The permission error should disappear once the rules are deployed.

