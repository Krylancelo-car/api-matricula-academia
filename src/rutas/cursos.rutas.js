const router = require('express').Router();
const c = require('../controladores/cursos.controlador');
const v = require('../validaciones/catalogos.validaciones');
const validar = require('../middlewares/validar');

router.get('/', v.validarQueryListado, validar, c.listarCursos);
router.get('/:id', v.validarId, validar, c.obtenerCursoPorId);
router.post('/', v.validarCurso, validar, c.crearCurso);
router.put('/:id', [...v.validarId, ...v.validarCurso], validar, c.actualizarCurso);
router.delete('/:id', v.validarId, validar, c.eliminarCurso);

module.exports = router;