const manejador404 = (req, res) => {
  res.status(404).json({ error: 'Ruta no encontrada' });
};

const manejadorErrores = (err, req, res, next) => {
  if (err.type === 'entity.parse.failed') {
    return res.status(400).json({ error: 'JSON mal formado' });
  }
  if (err.code === 'ER_DUP_ENTRY') {
    return res.status(409).json({ error: 'El registro ya existe' });
  }
  if (err.code === 'ER_ROW_IS_REFERENCED_2') {
    return res.status(409).json({ error: 'No se puede eliminar: tiene registros asociados' });
  }
  if (err.status) {
    return res.status(err.status).json({ error: err.message, detalles: err.detalles });
  }
  console.error(err);
  res.status(500).json({ error: 'Error interno del servidor' });
};

module.exports = { manejador404, manejadorErrores };