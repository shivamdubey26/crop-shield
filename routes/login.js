const express = require("express");
const router = express.Router();
const app = express();
const bodyParser = require("body-parser");
const cors = require("cors");
const User = require("../models/Users.model");
const argon2 = require("argon2");
const jwt = require("jsonwebtoken");
const cookieParser = require("cookie-parser");
const rateLimit = require("express-rate-limit");
const csurf = require("csurf");
const auth = require('../functions/auth');
require('dotenv').config();

const limiter = rateLimit({
  windowMs: 1 * 60 * 1000, // 1 minute
  max: 5, // limit each IP to 5 requests per windowMs
});

app.use(cors());
app.use(express.json());
app.use(express.static("public"));
app.use(bodyParser.urlencoded({ extended: true }));
app.set("view engine", "ejs");
app.use(cookieParser());
app.use(limiter);
app.use(csurf());

function validateEmail(email) {
  const re = /\S+@\S+\.\S+/;
  return re.test(email);
}


router.post("/", async (req, res) => {
  setTimeout(async () => {
  try {
    let user;
    const isEmail = validateEmail(req.body.emailorphone);
    if (isEmail) {
      user = await User.findOne({ email: req.body.emailorphone });
    } else {
      user = await User.findOne({ phone: req.body.emailorphone });
    }
    if (!user) {
      return res.status(401).json({ success: false, msg: "Login failed. Please check your email/phone number and password" });
    }
    // const user = await User.findOne({ email: req.body.email });
    // if (!user) {
    //   return res.status(401).json({ success: false, msg: "Incorrect Email or Password" });
    // }

    const validPassword = await argon2.verify(user.password, req.body.password);
    if (!validPassword) {
      return res.status(401).json({ success: false, msg: "Login failed. Please check your email/phone number and password" });
    }

    const token = jwt.sign({ _id: user._id }, process.env.JWT_SECRET, { expiresIn: "1h" });
    return res
      .cookie("access_token", token, {
        httpOnly: true,
        sameSite: "strict",
      })
      .json({ success: true, msg: "Login Authenticated & Token Generated" });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ success: false, msg: "Internal Server Error" });
  }
}, 2500);
});

module.exports = router;
