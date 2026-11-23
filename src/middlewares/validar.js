const { validationResult } = require('express-validator');

const validar = (req, res, next) => {
  const resultado = validationResult(req);

  if (!resultado.isEmpty()) {
    return res.status(400).json({
      error: 'Datos invalidos',
      detalles: resultado.array().map(({ path, msg }) => ({ campo: path, mensaje: msg }))
    });
  }

  next();
};

module.exports = validar;
