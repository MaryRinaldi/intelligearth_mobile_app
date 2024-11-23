require("dotenv").config();
const mysql = require("mysql");
const fs = require("fs");

const DB_HOST = process.env.DB_HOST;
const DB_USER = process.env.DB_USER;
const DB_PASS = process.env.DB_PASS;
const DB_NAME = process.env.DB_NAME;

const con = mysql.createConnection({
  host: DB_HOST,
  user: DB_USER,
  password: DB_PASS,
  database: DB_NAME,
  multipleStatements: true,
});

con.connect(function (err) {
  if (err) {
    console.error("Connection error:", err);
    return;
  }
  console.log("Connected!");
  

  // Inizializzazione del database
  const sql = fs.readFileSync(__dirname + "/init_db.sql").toString();
  con.query(sql, function (err, result) {
    if (err) {
      console.error("Error executing SQL:", err);
      return con.end(); 
    }
    console.log("Table creation `users` was successful!");
    
    console.log("Closing...");
    con.end();
  });
});
