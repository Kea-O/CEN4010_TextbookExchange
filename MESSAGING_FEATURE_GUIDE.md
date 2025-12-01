# Messaging Feature Guide

## Overview
A complete messaging system has been added to allow buyers and sellers to communicate about textbook listings.

## Key Features

### 1. **Message Model** (`Message.swift`)
- Stores individual messages between users
- Includes: sender, receiver, text, timestamp, read status
- Links to conversations via `conversationId`

### 2. **Conversation Model** (`Message.swift`)
- Groups messages between two users
- Tracks last message and timestamp
- Can optionally link to a post

### 3. **MessageManager** (`MessageManager.swift`)
- Handles all Firebase operations for messages
- Functions:
  - `getOrCreateConversation()` - Creates or retrieves a conversation
  - `sendMessage()` - Sends a new message
  - `fetchMessages()` - Gets all messages for a conversation
  - `fetchConversations()` - Gets all conversations for a user
  - `markMessagesAsRead()` - Marks messages as read

### 4. **MessageBetweenView** (`MessageBetweenView.swift`)
- View model for managing messages (similar to `PostBetweenView`)
- Supports mock data mode
- Manages conversations and messages state

### 5. **Views**

#### **ConversationListView** (`ConversationListView.swift`)
- Shows all conversations for the current user
- Displays last message preview
- Accessible via the "Messages" tab

#### **ChatView** (`ChatView.swift`)
- Individual chat interface
- Message bubbles (blue for sent, gray for received)
- Message input with send button
- Auto-scrolls to latest message

## How It Works

### Getting Seller Info from a Post

Since the `Post` model only has `user_id`, you need to look up the seller:

```swift
// Example from PostDetailView
private var seller: User? {
    User.mockUsers.first { user in
        (user.demoID ?? user.id) == post.user_id
    }
}
```

For Firebase, you'd fetch the user from Firestore:
```swift
// In a real Firebase implementation:
func getSeller(userId: String) async throws -> User? {
    let doc = try await db.collection("Users").document(userId).getDocument()
    return try? doc.data(as: User.self)
}
```

### Starting a Conversation

1. **From PostDetailView**: Click "Message Seller" button
2. **Creates/gets conversation** between current user and seller
3. **Opens ChatView** in a sheet

### Message Flow

1. User taps "Message Seller" on a post
2. System gets or creates a conversation between buyer and seller
3. ChatView opens with the conversation
4. Messages are sent/received in real-time (when Firebase is connected)
5. Conversations list updates with latest message

## Integration Points

### PostDetailView
- Added "Message Seller" button
- Looks up seller from `post.user_id`
- Opens chat when clicked

### ContentView
- Added "Messages" tab
- Shows `ConversationListView`
- Uses `MessageBetweenView` as environment object

## Mock Data

Mock conversations and messages are included in `MockData.swift`:
- 2 sample conversations
- 5 sample messages
- Ready for testing without Firebase

## Firebase Collections Needed

When deploying to Firebase, you'll need these collections:

1. **Messages** - Individual messages
   - Fields: conversationId, senderId, receiverId, text, timestamp, isRead

2. **Conversations** - Conversation metadata
   - Fields: participant1Id, participant2Id, lastMessage, lastMessageTimestamp, postId

3. **Users** (if not already exists) - User information
   - Fields: name, email

## Security Rules

Add to `firestore.rules`:

```javascript
match /Messages/{messageId} {
  allow read: if request.auth != null && 
    (request.auth.uid == resource.data.senderId || 
     request.auth.uid == resource.data.receiverId);
  allow create: if request.auth != null && 
    request.auth.uid == request.resource.data.senderId;
}

match /Conversations/{conversationId} {
  allow read: if request.auth != null && 
    (request.auth.uid == resource.data.participant1Id || 
     request.auth.uid == resource.data.participant2Id);
  allow create, update: if request.auth != null;
}
```

## Usage Example

```swift
// In your view
@StateObject private var messageBetween = MessageBetweenView()

// Get or create conversation
let conversation = await messageBetween.getOrCreateConversation(
    participant1Id: currentUserId,
    participant2Id: sellerId,
    postId: post.id
)

// Send a message
await messageBetween.sendMessage(
    conversationId: conversation.id ?? "",
    senderId: currentUserId,
    receiverId: sellerId,
    text: "Hello!"
)
```

## Notes

- The Post model is **not modified** - seller info is looked up separately
- Mock data mode works seamlessly for development
- All views follow the existing app patterns
- Ready to connect to Firebase when permissions are set up

