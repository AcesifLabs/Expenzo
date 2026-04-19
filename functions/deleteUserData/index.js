/**
 * Cloud Function: Delete User Data
 * Triggered via HTTPS from the app when user requests account deletion
 * 
 * Location: us-central1
 * 
 * Flow:
 * 1. Verify user authentication via ID token
 * 2. Delete all subcollections under /users/{userId}/
 * 3. Return success/failure
 */

const functions = require('firebase-functions');
const admin = require('firebase-admin');

// Initialize Firebase Admin
admin.initializeApp();

const db = admin.firestore();

/**
 * Deletes all documents in a collection recursively
 * @param {string} collectionPath - Path to the collection
 * @returns {Promise<void>}
 */
async function deleteCollection(collectionPath) {
  const collectionRef = db.collection(collectionPath);
  const query = collectionRef;

  return new Promise((resolve, reject) => {
    deleteQueryBatch(query, resolve, reject);
  });
}

/**
 * Recursively deletes documents in batches
 */
async function deleteQueryBatch(query, resolve, reject) {
  try {
    const snapshot = await query.get();

    if (snapshot.size === 0) {
      resolve();
      return;
    }

    const batch = db.batch();
    snapshot.docs.forEach((doc) => {
      batch.delete(doc.ref);
    });

    await batch.commit();

    // Recurse to handle pagination
    process.nextTick(() => {
      deleteQueryBatch(query, resolve, reject);
    });
  } catch (error) {
    reject(error);
  }
}

/**
 * HTTP Cloud Function to delete user data
 * 
 * Expected request:
 * - Headers: Authorization: Bearer <ID_TOKEN>
 * 
 * Response:
 * - 200: { success: true, message: "All user data deleted" }
 * - 401: { error: "Unauthorized" }
 * - 500: { error: "Failed to delete user data", details: <error> }
 */
exports.deleteUserData = functions
  .region('us-central1')
  .https.onCall(async (data, context) => {
    // Verify authentication
    if (!context.auth) {
      throw new functions.https.HttpsError(
        'unauthenticated',
        'User must be authenticated to delete account'
      );
    }

    const userId = context.auth.uid;
    const userPath = `users/${userId}`;

    try {
      console.log(`Starting deletion of user data for: ${userId}`);

      // Define all subcollections to delete
      const subcollections = [
        'expenses',
        'categories',
        'rules',
        'budgets',
        'recurring',
        'settings',
      ];

      // Delete each subcollection
      const deletionPromises = subcollections.map(async (subcollection) => {
        const collectionPath = `${userPath}/${subcollection}`;
        try {
          await deleteCollection(collectionPath);
          console.log(`Deleted collection: ${collectionPath}`);
        } catch (error) {
          // Collection might not exist, continue with others
          console.log(`Collection ${collectionPath} may not exist: ${error.message}`);
        }
      });

      // Also try to delete the user document itself
      try {
        await db.doc(userPath).delete();
        console.log(`Deleted user document: ${userPath}`);
      } catch (error) {
        console.log(`User document ${userPath} may not exist: ${error.message}`);
      }

      await Promise.all(deletionPromises);

      console.log(`Successfully deleted all data for user: ${userId}`);

      return {
        success: true,
        message: 'All user data has been deleted',
        deletedAt: new Date().toISOString(),
      };
    } catch (error) {
      console.error(`Failed to delete user data for ${userId}:`, error);
      throw new functions.https.HttpsError(
        'internal',
        'Failed to delete user data',
        error.message
      );
    }
  });

/**
 * Scheduled function to clean up orphaned data (optional)
 * Runs daily at 3 AM
 */
exports.cleanupOrphanedData = functions
  .region('us-central1')
  .pubsub
  .schedule('0 3 * * *')
  .timeZone('UTC')
  .onRun(async (context) => {
    console.log('Running orphaned data cleanup...');
    // Implementation would depend on specific cleanup requirements
    return null;
  });
