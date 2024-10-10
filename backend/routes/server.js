const express = require("express");
const router = express.Router();
require("dotenv").config()
const bodyParser = require("body-parser");
const cors = require("cors");
const db = require("../model/helper");
const { hashPassword, comparePassword } = require("../model/helper");
const { generateToken, verifyToken } = require("../model/tokens");
const cookieParser = require("cookie-parser");
// variables needed for bcrypt to do the encryption
const saltRounds = 10;
const supersecret = process.env.SUPER_SECRET;

/* GET home page. */
router.get("/", function (req, res, next) {
  res.send({ title: "Express" });
});

router.get("/test", (req, res) => {
  res.send("Test endpoint is working!");
});



// Middleware
router.use(cookieParser());
router.use(cors());
router.use(bodyParser.json());

// Rotta per la registrazione
router.post("/signup", async (req, res) => {
  const { name, email, password } = req.body;

  // Controllo dei dati di input
  if (!name || !email || !password) {
    console.log('Missing fields in signup request');
    return res.status(400).json({ message: 'All fields are required.' });
  }
  const existingUser = await db(`SELECT * FROM users WHERE email = ?`, [email]);
  if (existingUser.data.length > 0) {
    console.log('Email already exists:', email);
    return res.status(409).json({ message: 'Email already exists.' });
  }

  try {
    const hashedPassword = await hashPassword(password); // Cripta la password
    const results = await db(`INSERT INTO users (name, email, password) VALUES (?, ?, ?)`, [name, email, hashedPassword]);
    
    if (results.error) {
      console.error('Error creating user:', results.error);
      return res.status(500).json({ message: 'Error creating user.' });
    }
    console.log('User created successfully:', results.data.insertId);
    return res.status(201).json({ id: results.data.insertId, name, email });
  } catch (error) {
    console.error("Error in signup route:", error);
    return res.status(500).json({ message: "Error creating user." });
  }
});

// Rotta per il login
router.post("/signin", async (req, res) => {
  const { email, password } = req.body;

  // Controllo dei dati di input
  if (!email || !password) {
    console.log('Missing email or password in signin request');
    return res.status(400).json({ message: 'Email and password are required.' });
  }
  console.log('Signin request received for:', email);
  // Verifica dell'utente nel database
  const results = await db(`SELECT * FROM users WHERE email = ?`, [email]);

  if (results.error) {
    console.error("Error querying database:", results.error);
    return res.status(500).json({ message: "Error logging in." });
  }

  if (results.data.length > 0) {
    const user = results.data[0];
    const isPasswordValid = await comparePassword(password, user.password);
    
    if (isPasswordValid) {
      console.log('User authenticated successfully:', user.id);
      const token = generateToken(user);
      return res.status(200).json({ id: user.id, name: user.name, email: user.email, role: user.role, token });
    } else {
      return res.status(401).json({ message: "Invalid email or password." });
    }
  } else {
    return res.status(401).json({ message: "Invalid email or password." });
  }
});

//verifica user
router.get("/current_user", async (req, res) => {
  const token = req.headers.authorization?.split(" ")[1];

  if (!token) {
    console.log('No token provided');
    return res.status(401).json({ message: "Unauthorized" });
  }

  try {
    const decoded = await verifyToken(token);
    const results = await db(`SELECT id, name, email, role FROM users WHERE id = ?`, [decoded.id]);
    if (results.data.length > 0) {
      const user = results.data[0];
      console.log('User found:', user.id);
      res.status(200).json(user);
    } else {
      console.log('No user found with ID:', decoded.id);
      res.status(404).json({ message: "User not found" });
    }
  } catch (error) {
    console.error('Error verifying token:', error);
    res.status(401).json({ message: "Invalid token" });
  }
});


module.exports = router;