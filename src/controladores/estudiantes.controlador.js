const pool = require('../db');

const listarEstudiantes = async (req, res, next) => {
  try {
    const pagina = parseInt(req.query.pagina) || 1;
    const limite = parseInt(req.query.limite) || 10;
    const offset = (pagina - 1) * limite;
    const buscar = req.query.buscar ? `%${req.query.buscar}%` : null;

    let sql = 'SELECT id, identificacion, nombre, correo, telefono FROM estudiantes';
    let sqlCount = 'SELECT COUNT(*) as total FROM estudiantes';
    let params = [];
    let paramsCount = [];

    if (buscar) {
      sql += ' WHERE nombre LIKE ? OR identificacion LIKE ?';
      sqlCount += ' WHERE nombre LIKE ? OR identificacion LIKE ?';
      params.push(buscar, buscar);
      paramsCount.push(buscar, buscar);
    }

    sql += ' LIMIT ? OFFSET ?';
    params.push(limite, offset);

    const [filas] = await pool.query(sql, params);
    const [[{ total }]] = await pool.query(sqlCount, paramsCount);

    res.json({
      datos: filas,
      paginacion: { pagina, limite, total, paginas: Math.ceil(total / limite) || 1 }
    });
  } catch (error) { next(error); }
};

const obtenerEstudiantePorId = async (req, res, next) => {
  try {
    const [filas] = await pool.query('SELECT id, identificacion, nombre, correo, telefono FROM estudiantes WHERE id = ?', [req.params.id]);
    if (filas.length === 0) return res.status(404).json({ error: 'Estudiante no encontrado' });
    res.json(filas[0]);
  } catch (error) { next(error); }
};

const crearEstudiante = async (req, res, next) => {
  try {
    const { identificacion, nombre, correo, telefono } = req.body;
    const [resultado] = await pool.execute(
      'INSERT INTO estudiantes (identificacion, nombre, correo, telefono) VALUES (?, ?, ?, ?)',
      [identificacion, nombre, correo, telefono || null]
    );
    res.status(201).json({ id: resultado.insertId, identificacion, nombre, correo, telefono });
  } catch (error) { next(error); }
};

const actualizarEstudiante = async (req, res, next) => {
  try {
    const { id } = req.params;
    const { identificacion, nombre, correo, telefono } = req.body;
    const [resultado] = await pool.execute(
      'UPDATE estudiantes SET identificacion = ?, nombre = ?, correo = ?, telefono = ? WHERE id = ?',
      [identificacion, nombre, correo, telefono || null, id]
    );
    if (resultado.affectedRows === 0) return res.status(404).json({ error: 'Estudiante no encontrado' });
    res.json({ id: Number(id), identificacion, nombre, correo, telefono });
  } catch (error) { next(error); }
};

const eliminarEstudiante = async (req, res, next) => {
  try {
    const [resultado] = await pool.execute('DELETE FROM estudiantes WHERE id = ?', [req.params.id]);
    if (resultado.affectedRows === 0) return res.status(404).json({ error: 'Estudiante no encontrado' });
    res.status(204).send();
  } catch (error) { next(error); }
};

module.exports = { listarEstudiantes, obtenerEstudiantePorId, crearEstudiante, actualizarEstudiante, eliminarEstudiante };