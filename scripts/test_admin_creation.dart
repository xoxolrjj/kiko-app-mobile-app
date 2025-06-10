// Simple script to test admin document creation
// This is just for reference - you'll need to add the admin document manually in Firebase Console

/*
To fix the admin login issue, add this document to your Firestore:

Collection: admins
Document ID: admin-test-user
Data:
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

Steps:
1. Go to Firebase Console → Firestore Database → Data
2. Click "Start collection" and name it "admins"
3. Click "Add document"
4. Set Document ID to: admin-test-user
5. Add the fields above with their values
6. Save the document

After this, you should be able to log in with:
Email: admin@kikoapp.com
Password: admin123!
*/

// Alternative: Quick JSON for import
const adminDocumentData = {
  "email": "admin@kikoapp.com",
  "password": "admin123!",
  "name": "System Administrator",
  "role": "admin",
  "isActive": true,
  "permissions": ["all"],
  "createdAt": "2024-01-01T00:00:00.000Z", // Replace with current timestamp
  "lastLoginAt": "2024-01-01T00:00:00.000Z", // Replace with current timestamp
};
