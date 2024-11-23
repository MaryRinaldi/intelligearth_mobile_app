const express = require("express");
require("dotenv").config()
var path = require("path");
var cookieParser = require("cookie-parser");
var logger = require("morgan");
const cors = require("cors");
var serverRouter = require("./routes/server");

const app = express();
const port = 3306; 

app.use(cors());
app.use(logger("dev"));
app.use(express.json());
app.use(express.urlencoded({ extended: false }));
app.use(cookieParser());

app.use("/api", serverRouter);

app.use((err, req, res, next) => {
  console.error("Middleware error handler:", err.message);
  res.status(500).json({ message: "Something went wrong", error: err.message });
  });

  app.listen(port, () => {
    console.log(`Server running at http://localhost:${port}`);
});

module.exports = app;
