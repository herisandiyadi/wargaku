import { initializeApp } from "firebase-admin/app";
import { getFirestore } from "firebase-admin/firestore";
import { getMessaging } from "firebase-admin/messaging";
import { getAuth } from "firebase-admin/auth";
import { onDocumentCreated } from "firebase-functions/v2/firestore";
import { onCall, HttpsError } from "firebase-functions/v2/https";

initializeApp();
const db = getFirestore();

// ============================================================
// BKD-02: FCM Multicast Trigger on panic_logs creation
// ============================================================
export const onPanicCreated = onDocumentCreated(
  "panic_logs/{panicId}",
  async (event) => {
    const snap = event.data;
    if (!snap) return;

    const panicData = snap.data();
    const rtId = panicData.rt_id;
    const senderId = panicData.user_id;

    // Get all users in the same RT (except sender)
    const usersSnap = await db
      .collection("users")
      .where("rt_id", "==", rtId)
      .get();

    const tokens = [];
    usersSnap.forEach((doc) => {
      if (doc.id !== senderId && doc.data().fcm_token) {
        tokens.push(doc.data().fcm_token);
      }
    });

    if (tokens.length === 0) return;

    // Send high-priority multicast via FCM
    const message = {
      tokens,
      data: {
        type: "panic_alert",
        panic_id: event.params.panicId,
        sender_name: panicData.sender_name || "Warga",
        lat: String(panicData.lat),
        lng: String(panicData.lng),
      },
      android: {
        priority: "high",
        notification: {
          channelId: "panic_alert_channel",
          title: "🚨 DARURAT WARGA RT",
          body: `${panicData.sender_name || "Warga"} membutuhkan bantuan!`,
          sound: "siren_alert",
          priority: "max",
        },
      },
    };

    const response = await getMessaging().sendEachForMulticast(message);

    // Clean stale tokens
    const failedTokens = [];
    response.responses.forEach((resp, idx) => {
      if (!resp.success && resp.error?.code === "messaging/registration-token-not-registered") {
        failedTokens.push(tokens[idx]);
      }
    });

    if (failedTokens.length > 0) {
      const batch = db.batch();
      const staleSnap = await db
        .collection("users")
        .where("fcm_token", "in", failedTokens)
        .get();
      staleSnap.forEach((doc) => {
        batch.update(doc.ref, { fcm_token: null });
      });
      await batch.commit();
    }
  }
);

// ============================================================
// BKD-03: Create User Account (Admin Only - Callable)
// ============================================================
export const createUserAccount = onCall(async (request) => {
  // Verify caller is ADMIN
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Login required");
  }

  const callerDoc = await db.collection("users").doc(request.auth.uid).get();
  if (!callerDoc.exists || callerDoc.data().role !== "ADMIN") {
    throw new HttpsError("permission-denied", "Only ADMIN can create users");
  }

  const { phone, password, name, alamat, family_role, parent_kk_id, rt_id } = request.data;

  if (!phone || !password || !name) {
    throw new HttpsError("invalid-argument", "Missing required fields");
  }

  // Create Firebase Auth user
  const userRecord = await getAuth().createUser({
    phoneNumber: phone.startsWith("+") ? phone : `+62${phone.replace(/^0/, "")}`,
    password,
    displayName: name,
  });

  // Determine family_id
  let familyId;
  if (family_role === "KEPALA_KELUARGA") {
    familyId = userRecord.uid; // KK is their own family root
  } else if (parent_kk_id) {
    // Anggota inherits KK's family_id
    const kkDoc = await db.collection("users").doc(parent_kk_id).get();
    familyId = kkDoc.exists ? kkDoc.data().family_id : parent_kk_id;
  } else {
    throw new HttpsError("invalid-argument", "Anggota must have parent_kk_id");
  }

  // Create user document
  await db.collection("users").doc(userRecord.uid).set({
    uid: userRecord.uid,
    phone,
    name,
    alamat: alamat || "",
    role: "WARGA",
    family_role,
    family_id: familyId,
    parent_kk_id: parent_kk_id || null,
    rt_id: rt_id || "rt03_rw01",
    fcm_token: null,
    avatar_url: null,
    created_at: new Date().toISOString(),
  });

  return { uid: userRecord.uid, family_id: familyId };
});
