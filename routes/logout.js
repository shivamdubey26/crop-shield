const express = require("express");
const router = express.Router();
const app = express();
const bodyParser = require("body-parser");
const cors = require("cors");
const cookieParser = require("cookie-parser");

app.use(cors());
app.use(express.json());
app.use(express.static("public"));
app.use(bodyParser.urlencoded({ extended: true }));
app.set("view engine", "ejs");
app.use(cookieParser());

router.post("/", async (req, res) => {
  // clear the access_token cookie
  res.clearCookie("access_token", {
    httpOnly: true,
    sameSite: "strict",
  });

  // return a response indicating successful logout
  res.json({ success: true, msg: "Logout Successful" });
});

module.exports = router;
