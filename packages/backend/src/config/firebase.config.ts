import * as admin from 'firebase-admin';
import { Logger } from '@nestjs/common';

const logger = new Logger('FirebaseConfig');

export const initializeFirebase = () => {
  if (admin.apps.length > 0) return;

  const serviceAccountJson = process.env.FIREBASE_SERVICE_ACCOUNT_JSON;
  if (!serviceAccountJson || serviceAccountJson.includes('change-me')) {
    logger.warn('Firebase Admin SDK not configured — auth endpoints will fail until FIREBASE_SERVICE_ACCOUNT_JSON is set');
    return;
  }

  const serviceAccount = JSON.parse(serviceAccountJson);
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
  });
};

export const firebaseAuth = () => admin.auth();
