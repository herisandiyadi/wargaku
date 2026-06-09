/**
 * Seed script: Create admin user in Firebase Auth + Firestore.
 *
 * Usage:
 *   1. Set GOOGLE_APPLICATION_CREDENTIALS env to your service account key JSON
 *   2. Run: node seed_admin.js
 *
 * Admin credentials created:
 *   Email: admin@wargajatiasih.com
 *   Password: Admin@Jatiasih2024
 */
import { initializeApp, cert } from "firebase-admin/app";
import { getAuth } from "firebase-admin/auth";
import { getFirestore } from "firebase-admin/firestore";
import { readFileSync } from "fs";

// Initialize with service account if available, else default credentials
const serviceAccountPath = process.env.GOOGLE_APPLICATION_CREDENTIALS;
const appConfig = serviceAccountPath
  ? { credential: cert(JSON.parse(readFileSync(serviceAccountPath, "utf8"))) }
  : {};

initializeApp(appConfig);
const auth = getAuth();
const db = getFirestore();

const ADMIN_EMAIL = "admin@wargajatiasih.com";
const ADMIN_PASSWORD = "Admin@Jatiasih2024";
const ADMIN_NAME = "Admin RT03";

async function seedAdmin() {
  let userRecord;

  try {
    userRecord = await auth.getUserByEmail(ADMIN_EMAIL);
    console.log("✅ Admin user already exists:", userRecord.uid);
  } catch (e) {
    if (e.code === "auth/user-not-found") {
      userRecord = await auth.createUser({
        email: ADMIN_EMAIL,
        password: ADMIN_PASSWORD,
        displayName: ADMIN_NAME,
      });
      console.log("✅ Admin user created:", userRecord.uid);
    } else {
      throw e;
    }
  }

  // Upsert Firestore user document
  await db.collection("users").doc(userRecord.uid).set(
    {
      uid: userRecord.uid,
      email: ADMIN_EMAIL,
      name: ADMIN_NAME,
      role: "ADMIN",
      rt_id: "rt03_rw01",
      family_role: "KEPALA_KELUARGA",
      family_id: userRecord.uid,
      phone: null,
      fcm_token: null,
      avatar_url: null,
      created_at: new Date().toISOString(),
    },
    { merge: true }
  );

  console.log("✅ Firestore user document written");
  console.log("\n📋 Login credentials:");
  console.log(`   Email: ${ADMIN_EMAIL}`);
  console.log(`   Password: ${ADMIN_PASSWORD}`);
}

seedAdmin().catch((err) => {
  console.error("❌ Error:", err.message);
  process.exit(1);
});
