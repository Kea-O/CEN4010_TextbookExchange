# Mock Data Guide

## Overview
Mock data has been set up so you can continue developing your feature while Firebase permissions are being configured.

## What's Included

### Mock Users (6 users)
- **Alex Johnson** - `alex-johnson-001`
- **Sarah Chen** - `sarah-chen-001`
- **Michael Rodriguez** - `michael-rodriguez-001`
- **Emily Davis** - `emily-davis-001`
- **James Wilson** - `james-wilson-001`
- **Demo Seller** - `demo-user-001`

### Mock Posts (12 posts)
- Various textbooks across different subjects
- Different conditions (Good, Fair, Poor)
- Different prices ($55 - $120)
- Posts from different users
- Different timestamps (some recent, some older)

## How to Use

### Currently Enabled
Mock data is **currently enabled** in `ContentView.swift`. The app will automatically use mock data instead of trying to fetch from Firebase.

### To Switch Back to Firebase
When Firebase permissions are ready, open `ContentView.swift` and change:
```swift
let useMockData = true  // Change this to false
```
to:
```swift
let useMockData = false
```

## Accessing Mock Data in Code

### Get All Mock Posts
```swift
let posts = Post.mockPosts
```

### Get All Mock Users
```swift
let users = User.mockUsers
```

### Get Specific Mock User
```swift
let alex = User.alex
let sarah = User.sarah
// etc.
```

### Get User ID for Mock Users
```swift
let userId = user.mockUserID  // Returns "alex-johnson-001", etc.
```

## Testing Different Users

To test with different users, change the current user in `ContentView.swift`:
```swift
@State private var currentUser = User.alex  // or User.sarah, User.michael, etc.
```

## Notes
- Mock posts are automatically sorted by timestamp (newest first)
- All mock users have `id: nil` to avoid Firestore warnings
- The `demoID` property automatically maps mock user names to their IDs
- Mock data works seamlessly with existing views and filtering logic

