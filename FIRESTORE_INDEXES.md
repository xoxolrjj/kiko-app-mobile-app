# Firestore Indexes Setup

## Current Issue
Getting `FAILED_PRECONDITION` error because Firestore queries require composite indexes.

## Quick Fix
**Click the link in the error message** to automatically create the required index:
```
https://console.firebase.google.com/v1/r/project/kiko-mobile-application/firestore/indexes?create_composite=...
```

## Manual Index Creation

### Required Indexes for Admin Panel:

#### 1. Seller Verification Requests
- **Collection**: `seller_verification_requests`
- **Fields**: 
  - `status` (Ascending)
  - `createdAt` (Descending)

#### 2. Deliveries 
- **Collection**: `deliveries`
- **Fields**:
  - `status` (Ascending) 
  - `createdAt` (Descending)

#### 3. Notifications (Type Filter)
- **Collection**: `notifications`
- **Fields**:
  - `type` (Ascending)
  - `createdAt` (Descending)

#### 4. Notifications (Read Status)
- **Collection**: `notifications` 
- **Fields**:
  - `isRead` (Ascending)
  - `createdAt` (Descending)

#### 5. Users by Role
- **Collection**: `users`
- **Fields**:
  - `role` (Ascending)
  - `createdAt` (Descending)

#### 6. Users by Status  
- **Collection**: `users`
- **Fields**:
  - `status` (Ascending)
  - `updatedAt` (Descending)

## How to Create Indexes Manually:

1. **Go to Firebase Console** → Firestore Database → Indexes
2. **Click "Create Index"** 
3. **Enter Collection ID** (e.g., `seller_verification_requests`)
4. **Add Fields** with correct order (Ascending/Descending)
5. **Click "Create"**
6. **Wait for index build** (can take a few minutes)

## Important Notes:

- **Indexes take time to build** - usually 1-5 minutes for small datasets
- **Create indexes as needed** - errors will tell you which ones are missing
- **Index building is automatic** when you click the error links
- **Check index status** in Firebase Console → Firestore → Indexes

## Troubleshooting:

- If queries still fail after creating indexes, wait a few more minutes
- Check index status shows "Enabled" not "Building"
- Restart your app after indexes are created
- Some queries work without indexes in small datasets, but fail as data grows

## Current Status:
✅ **Next Step**: Create the `seller_verification_requests` index first  
🔄 **In Progress**: Index creation and testing  
📋 **Future**: Create remaining indexes as needed 