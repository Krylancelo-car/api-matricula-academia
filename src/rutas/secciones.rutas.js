const router = require('express').Router();
const c = require('../controladores/secciones.controlador');
const v = require('../validaciones/catalogos.validaciones');
const validar = require('../middlewares/validar');

router.get('/', v.validarQueryListado, validar, c.listarSecciones);
router.get('/:id', v.validarId, validar, c.obtenerSeccionPorId);
router.post('/', v.validarSeccion, validar, c.crearSeccion);
router.put('/:id', [...v.validarId, ...v.validarSeccion], validar, c.actualizarSeccion);
router.patch('/:id/estado', [...v.validarId, ...v.validarEstadoSeccion], validar, c.cambiarEstadoSeccion);
router.delete('/:id', v.validarId, validar, c.eliminarSeccion);

module.exports = router;