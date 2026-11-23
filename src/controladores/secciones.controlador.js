const pool = require('../db');

const LISTA_BLANCA_ORDEN = ['id', 'docente', 'cupo', 'estado', 'creado_en'];

const listarSecciones = async (req, res, next) => {
  try {
    const pagina = parseInt(req.query.pagina) || 1;
    const limite = parseInt(req.query.limite) || 10;
    const offset = (pagina - 1) * limite;
    const { curso_id, estado, buscar, orden, dir } = req.query;

    let condiciones = [];
    let params = [];

    if (curso_id) { condiciones.push('s.curso_id = ?'); params.push(parseInt(curso_id)); }
    if (estado) {
      if (!['disponible', 'llena', 'cancelada'].includes(estado)) {
        return res.status(400).json({ error: 'Estado de filtro inválido' });
      }
      condiciones.push('s.estado = ?'); params.push(estado);
    }
    if (buscar) { condiciones.push('(s.docente LIKE ? OR c.nombre LIKE ?)'); params.push(`%${buscar}%`, `%${buscar}%`); }

    const dondeClause = condiciones.length > 0 ? `WHERE ${condiciones.join(' AND ')}` : '';

    let ordenCampo = 's.id';
    let ordenDir = 'ASC';
    if (orden) {
      if (!LISTA_BLANCA_ORDEN.includes(orden)) {
        return res.status(400).json({ error: `El campo de ordenamiento '${orden}' no está permitido` });
      }
      ordenCampo = `s.${orden}`;
    }
    if (dir) { ordenDir = dir.toUpperCase() === 'DESC' ? 'DESC' : 'ASC'; }

    const sql = `
      SELECT s.id, s.docente, s.cupo, s.estado, s.creado_en,
             JSON_OBJECT('id', c.id, 'nombre', c.nombre) AS curso
      FROM secciones s
      INNER JOIN cursos c ON s.curso_id = c.id
      ${dondeClause}
      ORDER BY ${ordenCampo} ${ordenDir}
      LIMIT ? OFFSET ?
    `;

    const sqlCount = `SELECT COUNT(*) as total FROM secciones s INNER JOIN cursos c ON s.curso_id = c.id ${dondeClause}`;

    const [filas] = await pool.query(sql, [...params, limite, offset]);
    const [[{ total }]] = await pool.query(sqlCount, params);

    res.json({
      datos: filas,
      paginacion: { pagina, limite, total, paginas: Math.ceil(total / limite) || 1 }
    });
  } catch (error) { next(error); }
};

const obtenerSeccionPorId = async (req, res, next) => {
  try {
    const sql = `
      SELECT s.id, s.docente, s.cupo, s.estado, s.creado_en,
             JSON_OBJECT('id', c.id, 'nombre', c.nombre) AS curso
      FROM secciones s
      INNER JOIN cursos c ON s.curso_id = c.id
      WHERE s.id = ?
    `;
    const [filas] = await pool.query(sql, [req.params.id]);
    if (filas.length === 0) return res.status(404).json({ error: 'Sección no encontrada' });
    res.json(filas[0]);
  } catch (error) { next(error); }
};

const crearSeccion = async (req, res, next) => {
  try {
    const { curso_id, docente, cupo } = req.body;
    const [cursos] = await pool.query('SELECT id FROM cursos WHERE id = ?', [curso_id]);
    if (cursos.length === 0) return res.status(400).json({ error: 'El curso especificado no existe' });

    const [resultado] = await pool.execute(
      'INSERT INTO secciones (curso_id, docente, cupo, estado) VALUES (?, ?, ?, "disponible")',
      [curso_id, docente, cupo || 20]
    );

    res.status(201).json({ id: resultado.insertId, curso_id, docente, cupo: cupo || 20, estado: 'disponible' });
  } catch (error) { next(error); }
};

const actualizarSeccion = async (req, res, next) => {
  try {
    const { id } = req.params;
    const { curso_id, docente, cupo } = req.body;
    const [resultado] = await pool.execute(
      'UPDATE secciones SET curso_id = ?, docente = ?, cupo = ? WHERE id = ?',
      [curso_id, docente, cupo, id]
    );
    if (resultado.affectedRows === 0) return res.status(404).json({ error: 'Sección no encontrada' });
    res.json({ id: Number(id), curso_id, docente, cupo });
  } catch (error) { next(error); }
};

const cambiarEstadoSeccion = async (req, res, next) => {
  try {
    const { id } = req.params;
    const { estado } = req.body;
    const [resultado] = await pool.execute('UPDATE secciones SET estado = ? WHERE id = ?', [estado, id]);
    if (resultado.affectedRows === 0) return res.status(404).json({ error: 'Sección no encontrada' });
    res.json({ id: Number(id), estado });
  } catch (error) { next(error); }
};

const eliminarSeccion = async (req, res, next) => {
  try {
    const [resultado] = await pool.execute('DELETE FROM secciones WHERE id = ?', [req.params.id]);
    if (resultado.affectedRows === 0) return res.status(404).json({ error: 'Sección no encontrada' });
    res.status(204).send();
  } catch (error) { next(error); }
};

module.exports = { listarSecciones, obtenerSeccionPorId, crearSeccion, actualizarSeccion, cambiarEstadoSeccion, eliminarSeccion };