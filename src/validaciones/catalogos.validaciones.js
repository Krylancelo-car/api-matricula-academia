const { body, param, query } = require('express-validator');

const validarId = [
  param('id').isInt({ min: 1 }).withMessage('El ID debe ser un número entero positivo').toInt()
];

const validarQueryListado = [
  query('pagina').optional().isInt({ min: 1 }).withMessage('La página debe ser mayor o igual a 1').toInt(),
  query('limite').optional().isInt({ min: 1, max: 50 }).withMessage('El límite debe ser entre 1 y 50').toInt(),
  query('dir').optional().isIn(['asc', 'desc', 'ASC', 'DESC']).withMessage('La dirección debe ser asc o desc')
];

const validarCurso = [
  body('nombre').trim().isLength({ min: 3, max: 60 }).withMessage('El nombre debe tener entre 3 y 60 caracteres'),
  body('descripcion').optional({ nullable: true }).trim().isLength({ max: 255 }).withMessage('La descripción no puede exceder los 255 caracteres')
];

const validarEstudiante = [
  body('identificacion').trim().matches(/^[A-Za-z0-9\-]{4,20}$/).withMessage('La identificación debe tener entre 4 y 20 caracteres'),
  body('nombre').trim().isLength({ min: 3, max: 100 }).withMessage('El nombre debe tener entre 3 y 100 caracteres'),
  body('correo').trim().isEmail().withMessage('Debe proporcionar un correo electrónico válido'),
  body('telefono').optional({ nullable: true }).trim().matches(/^\d{4}-\d{4}$/).withMessage('El teléfono debe tener el formato 9999-9999')
];

const validarSeccion = [
  body('curso_id').isInt({ min: 1 }).withMessage('El curso_id debe ser un entero válido'),
  body('docente').trim().isLength({ min: 3, max: 100 }).withMessage('El docente debe tener entre 3 y 100 caracteres'),
  body('cupo').optional().isInt({ min: 1, max: 100 }).withMessage('El cupo debe ser entre 1 y 100')
];

const validarEstadoSeccion = [
  body('estado').isIn(['disponible', 'llena', 'cancelada']).withMessage('Estado no válido')
];

module.exports = {
  validarId,
  validarQueryListado,
  validarCurso,
  validarEstudiante,
  validarSeccion,
  validarEstadoSeccion
};