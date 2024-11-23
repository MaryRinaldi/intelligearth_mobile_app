require("dotenv").config();
const mysql = require("mysql");
const bcrypt = require("bcrypt");

const saltRounds = 10;

// Funzione per hashare la password
const hashPassword = async (password) => {
  return await bcrypt.hash(password, saltRounds);
};

// Funzione per confrontare la password
const comparePassword = async (password, hash) => {
  return await bcrypt.compare(password, hash);
};

// Funzione per gestire le query al database
module.exports = async function db(query, params = []) {
  const results = {
    data: [],
    error: null,
  };

  const con = mysql.createConnection({
    host: process.env.DB_HOST || "0.0.0.0",
    user: process.env.DB_USER || "root",
    password: process.env.DB_PASS,
    database: process.env.DB_NAME || "intelligearth_db",
    multipleStatements: true,
  });

  return new Promise((resolve, reject) => {
    con.connect(function (err) {
      if (err) return reject(err);

      console.log("Connected!");

      // Usa i parametri per le query
      con.query(query, params, function (err, result) {
        if (err) {
          results.error = err;
          reject(err);
          con.end();
          return;
        }

        if (Array.isArray(result) && result.length > 0) {
          results.data = result; // Assegna direttamente il risultato se è un array
        } else if (result.affectedRows) {
          results.data.push(result); // In caso di operazioni che modificano righe
        }

        con.end();
        resolve(results);
      });
    });
  });
};

// Esportiamo anche le funzioni per hashare e confrontare le password
module.exports.hashPassword = hashPassword;
module.exports.comparePassword = comparePassword;
