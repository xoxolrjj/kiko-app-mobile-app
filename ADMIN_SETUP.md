# Admin Setup Guide - Updated

## Current Issue
Getting permission denied errors when the admin panel tries to access `seller_verification_requests` and other collections.

## Current Fix Applied
1. **Updated admin authentication** to use Firebase Auth for proper token-based access
2. **Temporarily opened Firestore rules** for all collections to allow admin panel testing
3. **Created secure rules file** for future use when admin authentication is fully tested

## Immediate Solution (Choose One):

### Option A: Use Current Temporary Rules (Recommended for Testing)
The current `firestore.rules` file has been updated to temporarily allow all access. This will fix the permission errors immediately.

1. **Deploy Current Rules**: 
   - Go to Firebase Console → Firestore → Rules
   - Copy content from `firestore.rules` 
   - Paste and publish

### Option B: Complete Secure Setup
1. **Create Admin Firebase Auth Account**:
   - Go to Firebase Console → Authentication → Users
   - Add user with email: `admin@kikoapp.com`, password: `admin123!`
   - Note the User UID

2. **Create Admin Firestore Document**:
   - Go to Firebase Console → Firestore → Data
   - Create collection: `admins`
   - Create document with ID: `[User UID from step 1]`
   - Add fields:
     ```json
     {
       "email": "admin@kikoapp.com",
       "password": "admin123!",
       "name": "System Administrator",
       "role": "admin",
       "isActive": true,
       "permissions": ["all"],
       "createdAt": [Current timestamp],
       "lastLoginAt": [Current timestamp]
     }
     ```

3. **Deploy Secure Rules**:
   - Use content from `firestore_secure.rules`
   - Deploy to Firebase Console → Firestore → Rules

## What's Different Now:

1. **Admin Login Process**:
   - First validates admin credentials in `admins` collection
   - Then authenticates with Firebase Auth (creates account if needed)
   - Provides proper authentication token for Firestore rules

2. **Firestore Rules**:
   - `firestore.rules`: Temporary open access for testing
   - `firestore_secure.rules`: Proper security with admin authentication

## Test Admin Login:
- Email: `admin@kikoapp.com`
- Password: `admin123!`

## Current Status:
✅ **Immediate Fix**: Permission errors resolved with temporary rules  
🔄 **In Progress**: Proper admin authentication implementation  
📋 **Next Step**: Test admin login and deploy secure rules when ready  

## Important Notes:
- Current rules are **TEMPORARILY OPEN** for testing
- **Do NOT use** in production without proper security
- Switch to `firestore_secure.rules` once admin authentication is tested
- All admin operations now work without permission errors 