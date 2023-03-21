const jwt = require('jsonwebtoken');

async function auth(req, res) {
  const token = req.cookies.access_token;
  try {
    const decoded = await jwt.verify(token, process.env.JWT_SECRET);
    return { verified: true, decoded: decoded };
  } catch (err) {
    return { verified: false };
  }
}

module.exports = auth;
