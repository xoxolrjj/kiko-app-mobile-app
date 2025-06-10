// Firebase Admin SDK script to create admin user
// Run this script using Node.js after installing firebase-admin

const admin = require('firebase-admin');

// Initialize Firebase Admin SDK
// Replace with your service account key path
const serviceAccount = require('./path-to-your-service-account-key.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  databaseURL: 'https://your-project-id-default-rtdb.firebaseio.com' // Replace with your project
});

const db = admin.firestore();

async function createAdmin() {
  try {
    // Create admin document
    const adminData = {
      email: 'admin@kikoapp.com',
      password: 'admin123!', // In production, this should be hashed
      name: 'System Administrator',
      role: 'admin',
      isActive: true,
      permissions: ['all'],
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp()
    };

    // Add admin document with a specific ID
    await db.collection('admins').doc('admin-user-id').set(adminData);
    
    console.log('Admin user created successfully!');
    console.log('Admin ID: admin-user-id');
    console.log('Email: admin@kikoapp.com');
    console.log('Password: admin123!');
    
  } catch (error) {
    console.error('Error creating admin:', error);
  }
}

createAdmin(); 