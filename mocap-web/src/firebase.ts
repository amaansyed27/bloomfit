import { initializeApp } from 'firebase/app';
import { getFirestore, collection, doc, onSnapshot, setDoc, serverTimestamp } from 'firebase/firestore';

const firebaseConfig = {
  apiKey: "AIzaSyDKlh8r9g2gBYEAyEb18vvG_C0_hh2B8Nc", // Android key for testing, or Web Key if we had it
  authDomain: "bloomfit-levelup.firebaseapp.com",
  projectId: "bloomfit-levelup",
  storageBucket: "bloomfit-levelup.firebasestorage.app",
  messagingSenderId: "673238034109",
  appId: "1:673238034109:web:abcdef" // Using a dummy web app ID or we can just use the android one if it works
};

// Initialize Firebase
const app = initializeApp(firebaseConfig);
const db = getFirestore(app);

export { db, collection, doc, onSnapshot, setDoc, serverTimestamp };
