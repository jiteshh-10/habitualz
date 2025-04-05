// Import the functions you need from the SDKs you need
import { initializeApp } from "firebase/app";
import { getAnalytics } from "firebase/analytics";
// TODO: Add SDKs for Firebase products that you want to use
// https://firebase.google.com/docs/web/setup#available-libraries

// Your web app's Firebase configuration
// For Firebase JS SDK v7.20.0 and later, measurementId is optional
const firebaseConfig = {
  apiKey: "AIzaSyAuLs9fsAmSUPMKwkL0JglTajlLrdXWXCk",
  authDomain: "habitualz-531f2.firebaseapp.com",
  projectId: "habitualz-531f2",
  storageBucket: "habitualz-531f2.firebasestorage.app",
  messagingSenderId: "1011121683672",
  appId: "1:1011121683672:web:4043b496f999ba98056bad",
  measurementId: "G-6N74F01JTH"
};

// Initialize Firebase
const app = initializeApp(firebaseConfig);
const analytics = getAnalytics(app);