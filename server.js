require('dotenv').config();
const path = require('path');
const express = require('express');
const session = require('express-session');
const cors = require('cors');
const apiRoutes = require('./routes/apiRoutes');

const app = express();
if (!process.env.DB_HOST || !process.env.DB_USER || !process.env.DB_NAME) {
	console.warn('Database environment is incomplete. Copy .env.example to .env and configure MySQL before signing in.');
}
app.use(cors({ origin: true, credentials: true }));
app.use(express.json({ limit: '1mb' }));
app.use(session({ secret: process.env.SESSION_SECRET || 'educare-development-secret', resave: false, saveUninitialized: false, cookie: { httpOnly: true, sameSite: 'lax', maxAge: 8 * 60 * 60 * 1000 } }));
app.use('/api', apiRoutes);
app.use(express.static(path.join(__dirname, 'public')));
app.get('*', (req,res) => res.sendFile(path.join(__dirname, 'public', 'index.html')));
app.use((error, req, res, next) => { console.error(error); const duplicate = error.code === 'ER_DUP_ENTRY'; const databaseUnavailable = ['ECONNREFUSED','ER_BAD_DB_ERROR','ER_ACCESS_DENIED_ERROR'].includes(error.code) || error.code === 'ENOTFOUND'; res.status(duplicate ? 409 : 500).json({ success:false, message: duplicate ? 'A record with those details already exists' : databaseUnavailable ? 'Database is unavailable. Configure .env and start MySQL.' : 'Something went wrong', error: process.env.NODE_ENV === 'production' ? undefined : error.message }); });
const port = Number(process.env.PORT || 3000);
app.listen(port, () => console.log(`EDUCARE running at http://localhost:${port}`));
