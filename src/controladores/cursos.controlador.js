const pool = require('../db');

const listarCursos = async (req, res, next) => {
  try {
    const pagina = parseInt(req.query.pagina) || 1;
    const limite = parseInt(req.query.limite) || 10;
    const offset = (pagina - 1) * limite;

    const [filas] = await pool.query('SELECT id, nombre, descripcion FROM cursos LIMIT ? OFFSET ?', [limite, offset]);
    const [[{ total }]] = await pool.query('SELECT COUNT(*) as total FROM cursos');

    res.json({
      datos: filas,
      paginacion: { pagina, limite, total, paginas: Math.ceil(total / limite) || 1 }
    });
  } catch (error) { next(error); }
};

const obtenerCursoPorId = async (req, res, next) => {
  try {
    const [filas] = await pool.query('SELECT id, nombre, descripcion FROM cursos WHERE id = ?', [req.params.id]);
    if (filas.length === 0) return res.status(404).json({ error: 'Curso no encontrado' });
    res.json(filas[0]);
  } catch (error) { next(error); }
};

const crearCurso = async (req, res, next) => {
  try {
    const { nombre, descripcion } = req.body;
    const [resultado] = await pool.execute('INSERT INTO cursos (nombre, descripcion) VALUES (?, ?)', [nombre, descripcion || null]);
    res.status(201).json({ id: resultado.insertId, nombre, descripcion });
  } catch (error) { next(error); }
};

const actualizarCurso = async (req, res, next) => {
  try {
    const { id } = req.params;
    const { nombre, descripcion } = req.body;
    const [resultado] = await pool.execute('UPDATE cursos SET nombre = ?, descripcion = ? WHERE id = ?', [nombre, descripcion || null, id]);
    if (resultado.affectedRows === 0) return res.status(404).json({ error: 'Curso no encontrado' });
    res.json({ id: Number(id), nombre, descripcion });
  } catch (error) { next(error); }
};

const eliminarCurso = async (req, res, next) => {
  try {
    const [resultado] = await pool.execute('DELETE FROM cursos WHERE id = ?', [req.params.id]);
    if (resultado.affectedRows === 0) return res.status(404).json({ error: 'Curso no encontrado' });
    res.status(204).send();
  } catch (error) { next(error); }
};

module.exports = { listarCursos, obtenerCursoPorId, crearCurso, actualizarCurso, eliminarCurso };