const express = require("express");
const router = express.Router();
const app = express();
const bodyParser = require("body-parser");
const cors = require("cors");
const User = require("../models/Users.model");
const argon2 = require("argon2");
const cookieParser = require("cookie-parser");
const rateLimit = require("express-rate-limit");
const { check, validationResult } = require("express-validator");

app.use(cors()); 
app.use(express.json());
app.use(express.static("public"));
app.use(bodyParser.urlencoded({ extended: true }));
app.set("view engine", "ejs");
app.use(cookieParser());

const limiter = rateLimit({
  windowMs: 60 * 1000, // 1 minute
  max: 5, // limit each IP to 5 requests per windowMs
});

router.post(
  "/",
  limiter,
  [
    check("name").notEmpty().withMessage("Name is required"),
    check("email").isEmail().withMessage("Invalid email"),
    check("phone").isLength({ min: 10, max: 10 }).withMessage("Invalid phone number"),
    check("password")
      .isLength({ min: 8 })
      .withMessage("Password must be at least 8 characters long"),
  ],
  async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      const error = errors.array()[0].msg;
      return res.status(400).json({ success: false, msg: error });
    }

    try {
      const userByEmail = await User.findOne({ email: req.body.email });
      const userByPhone = await User.findOne({ phone: req.body.phone });
      if (userByEmail || userByPhone) {
        return res
          .status(400)
          .json({ success: false, msg: "This email or phone number is already registered" });
      }

      const hashedPassword = await argon2.hash(req.body.password);
      const newUser = new User({
        name: req.body.name,
        email: req.body.email,
        phone: req.body.phone,
        password: hashedPassword,
      });

      await newUser.save();
      res.json({ success: true, msg: "Congrats! Account has been created.." });
    } catch (err) {
      console.error(err);
      res.status(500).json({ success: false, msg: "Server error" });
    }
  }
);

module.exports = router;
