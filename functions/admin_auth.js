const jwt = require('jsonwebtoken');

async function admin_auth(req, res) {
  const token = req.cookies.admin_auth_token;
  try {
    const decoded = await jwt.verify(token, process.env.ADMIN_JWT);
    return { verified: true, decoded: decoded };
  } catch (err) {
    return { verified: false };
  }
}

module.exports = admin_auth;
