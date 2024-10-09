const express = require("express");
require("dotenv").config()
var path = require("path");
var cookieParser = require("cookie-parser");
var logger = require("morgan");
const cors = require("cors");
var indexRouter = require("./routes/index");

const app = express();

app.use(cors());
app.use(logger("dev"));
app.use(express.json());
app.use(express.urlencoded({ extended: false }));
app.use(cookieParser());

app.use("/api", indexRouter);

app.use((err, req, res, next) => {
    res.status(500).json({ message: err.message, code: err.code });
  });

module.exports = app;
