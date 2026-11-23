const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const { manejador404, manejadorErrores } = require('./middlewares/errores');

const app = express();

app.use(helmet());
app.use(cors({ origin: process.env.CORS_ORIGEN || 'http://localhost:5500' }));
app.use(express.json());

// Montar Rutas del CRUD
app.use('/api/cursos', require('./rutas/cursos.rutas'));
app.use('/api/estudiantes', require('./rutas/estudiantes.rutas'));
app.use('/api/secciones', require('./rutas/secciones.rutas'));

// Endpoint de Salud (RF-20)
app.get('/api/salud', async (req, res, next) => {
  try {
    const pool = require('./db');
    await pool.query('SELECT 1');
    res.json({ estado: 'ok', base_datos: 'conectada' });
  } catch (error) { next(error); }
});

// Middlewares finales
app.use(manejador404);
app.use(manejadorErrores);

module.exports = app;