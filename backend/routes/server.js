const express = require("express");
require("dotenv").config()
const bodyParser = require("body-parser");
const cors = require("cors");
const db = require("../model/helper");
const { hashPassword, comparePassword } = require("../model/helper");
const { generateToken } = require("../model/tokens");
const { verifyToken } = require("../model/tokens");

const app = express();
const port = 3000;

// Middleware
app.use(cors());
app.use(bodyParser.json());

// Rotta per la registrazione
app.post("/signup", async (req, res) => {
  const existingUser = await db(`SELECT * FROM users WHERE email = ?`, [email]);
  if (existingUser.data.length > 0) {
    return res.status(409).json({ message: 'Email already exists.' });
  }
  
  const { name, email, password } = req.body;

  // Controllo dei dati di input
  if (!name || !email || !password) {
    return res.status(400).json({ message: 'All fields are required.' });
  }

  try {
    const hashedPassword = await hashPassword(password); // Cripta la password
    const results = await db(`INSERT INTO users (name, email, password) VALUES (?, ?, ?)`, [name, email, hashedPassword]);
    
    if (results.error) {
      return res.status(500).json({ message: 'Error creating user.' });
    }
    
    return res.status(201).json({ id: results.data.insertId, name, email });
  } catch (error) {
    console.error("Error creating user:", error);
    return res.status(500).json({ message: "Error creating user." });
  }
});

// Rotta per il login
app.post("/signin", async (req, res) => {
  const { email, password } = req.body;

  // Controllo dei dati di input
  if (!email || !password) {
    return res.status(400).json({ message: 'Email and password are required.' });
  }

  // Verifica dell'utente nel database
  const results = await db(`SELECT * FROM users WHERE email = ?`, [email]);

  if (results.error) {
    console.error("Error during login:", results.error);
    return res.status(500).json({ message: "Error logging in." });
  }

  if (results.data.length > 0) {
    const user = results.data[0];
    const isPasswordValid = await comparePassword(password, user.password);
    
    if (isPasswordValid) {
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
app.get("/current_user", async (req, res) => {
  const token = req.headers.authorization?.split(" ")[1];

  if (!token) {
    return res.status(401).json({ message: "Unauthorized" });
  }

  try {
    const decoded = verifyToken(token);
    const results = await db(`SELECT id, name, email, role FROM users WHERE id = ${decoded.id}`);
    if (results.data.length > 0) {
      const user = results.data[0];
      res.status(200).json(user);
    } else {
      res.status(404).json({ message: "User not found" });
    }
  } catch (error) {
    res.status(401).json({ message: "Invalid token" });
  }
});



// Avvio del server
app.listen(port, () => {
  console.log(`Server running at http://localhost:${port}`);
});