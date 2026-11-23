const router = require('express').Router();
const c = require('../controladores/estudiantes.controlador');
const v = require('../validaciones/catalogos.validaciones');
const validar = require('../middlewares/validar');

router.get('/', v.validarQueryListado, validar, c.listarEstudiantes);
router.get('/:id', v.validarId, validar, c.obtenerEstudiantePorId);
router.post('/', v.validarEstudiante, validar, c.crearEstudiante);
router.put('/:id', [...v.validarId, ...v.validarEstudiante], validar, c.actualizarEstudiante);
router.delete('/:id', v.validarId, validar, c.eliminarEstudiante);

module.exports = router;