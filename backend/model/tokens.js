const jwt = require('jsonwebtoken');

const secretKey = process.env.JWT_SECRET;

if (!secretKey) {
    throw new Error("Missing JWT_SECRET in environment variables");
  }

// Funzione per generare un token JWT
const generateToken = (user) => {
  if (!user || !user.id || !user.email) {
    throw new Error("Invalid user object provided");
  }
  return jwt.sign({ id: user.id, email: user.email }, secretKey, { expiresIn: '1h' });
};

// Funzione per verificare un token JWT
const verifyToken = (token) => {
  if (!token) {
    throw new Error("No token provided");
  }
  try {
    return jwt.verify(token, secretKey);
  } catch (error) {
    throw new Error("Invalid token");
  }
};

module.exports = {
  generateToken,
  verifyToken,
};
