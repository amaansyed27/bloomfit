const admin = require('firebase-admin');

// Since we're in the project dir and have application default credentials or we can just initialize app.
admin.initializeApp({
  projectId: "bloomfit-levelup"
});

const db = admin.firestore();

async function checkExercises() {
  const snapshot = await db.collection('exercises').limit(1).get();
  if (snapshot.empty) {
    console.log("NO_EXERCISES");
  } else {
    console.log("HAS_EXERCISES");
  }
}

checkExercises();
