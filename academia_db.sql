-- =====================================================================
-- Proyecto final DIA-117 Programación Aplicada (sección 1100)
-- Caso 7: Matrícula de una academia
-- Base de datos: academia_db  |  Motor: MySQL 8
-- Equipo: Alejandro Arrazola, André Barahona, Kevin Carvajal
-- =====================================================================

DROP DATABASE IF EXISTS academia_db;
CREATE DATABASE academia_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE academia_db;

-- ---------------------------------------------------------------------
-- Usuarios (solo para la autenticación JWT)
-- ---------------------------------------------------------------------
CREATE TABLE usuarios (
  id_usuario    INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  nombre        VARCHAR(100) NOT NULL,
  correo        VARCHAR(120) NOT NULL UNIQUE,
  password_hash VARCHAR(255) NOT NULL,
  rol           ENUM('admin', 'secretaria') NOT NULL DEFAULT 'secretaria',
  creado_en     TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE = InnoDB;

-- ---------------------------------------------------------------------
-- Catálogos
-- ---------------------------------------------------------------------
CREATE TABLE cursos (
  id_curso    INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  nombre      VARCHAR(100) NOT NULL UNIQUE,
  descripcion VARCHAR(255),
  estado      ENUM('activo', 'inactivo') NOT NULL DEFAULT 'activo'
) ENGINE = InnoDB;

CREATE TABLE docentes (
  id_docente INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  nombre     VARCHAR(100) NOT NULL,
  correo     VARCHAR(120) NOT NULL UNIQUE,
  telefono   VARCHAR(20),
  estado     ENUM('activo', 'inactivo') NOT NULL DEFAULT 'activo'
) ENGINE = InnoDB;

-- ---------------------------------------------------------------------
-- Entidad principal
-- ---------------------------------------------------------------------
CREATE TABLE estudiantes (
  id_estudiante INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  nombre        VARCHAR(100) NOT NULL,
  identidad     VARCHAR(20)  NOT NULL UNIQUE,
  correo        VARCHAR(120) NOT NULL UNIQUE,
  telefono      VARCHAR(20),
  estado        ENUM('activo', 'inactivo') NOT NULL DEFAULT 'activo'
) ENGINE = InnoDB;

-- ---------------------------------------------------------------------
-- Asignaturas y secciones (con cupo)
-- ---------------------------------------------------------------------
CREATE TABLE asignaturas (
  id_asignatura INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  id_curso      INT UNSIGNED NOT NULL,
  nombre        VARCHAR(100) NOT NULL,
  creditos      TINYINT UNSIGNED NOT NULL,
  CONSTRAINT chk_creditos CHECK (creditos > 0),
  CONSTRAINT uq_asignatura_curso UNIQUE (id_curso, nombre),
  CONSTRAINT fk_asignatura_curso FOREIGN KEY (id_curso)
    REFERENCES cursos (id_curso)
) ENGINE = InnoDB;

CREATE TABLE secciones (
  id_seccion    INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  id_asignatura INT UNSIGNED NOT NULL,
  id_docente    INT UNSIGNED NOT NULL,
  codigo        VARCHAR(20) NOT NULL UNIQUE,
  horario       VARCHAR(60) NOT NULL,
  cupo_maximo   SMALLINT UNSIGNED NOT NULL,
  cupo_ocupado  SMALLINT UNSIGNED NOT NULL DEFAULT 0,
  CONSTRAINT chk_cupo_maximo CHECK (cupo_maximo > 0),
  -- Regla de negocio: nunca se puede pasar del cupo máximo
  CONSTRAINT chk_cupo CHECK (cupo_ocupado <= cupo_maximo),
  CONSTRAINT fk_seccion_asignatura FOREIGN KEY (id_asignatura)
    REFERENCES asignaturas (id_asignatura),
  CONSTRAINT fk_seccion_docente FOREIGN KEY (id_docente)
    REFERENCES docentes (id_docente)
) ENGINE = InnoDB;

-- ---------------------------------------------------------------------
-- Transacción: matrícula (encabezado) + detalle
-- ---------------------------------------------------------------------
CREATE TABLE matriculas (
  id_matricula  INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  id_estudiante INT UNSIGNED NOT NULL,
  periodo       VARCHAR(20) NOT NULL,
  fecha         TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  estado        ENUM('activa', 'cancelada') NOT NULL DEFAULT 'activa',
  -- Un estudiante solo tiene una matrícula por periodo
  CONSTRAINT uq_matricula_periodo UNIQUE (id_estudiante, periodo),
  CONSTRAINT fk_matricula_estudiante FOREIGN KEY (id_estudiante)
    REFERENCES estudiantes (id_estudiante)
) ENGINE = InnoDB;

CREATE TABLE detalle_matricula (
  id_detalle   INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  id_matricula INT UNSIGNED NOT NULL,
  id_seccion   INT UNSIGNED NOT NULL,
  -- No se puede repetir la misma sección en una matrícula
  CONSTRAINT uq_detalle UNIQUE (id_matricula, id_seccion),
  CONSTRAINT fk_detalle_matricula FOREIGN KEY (id_matricula)
    REFERENCES matriculas (id_matricula) ON DELETE CASCADE,
  CONSTRAINT fk_detalle_seccion FOREIGN KEY (id_seccion)
    REFERENCES secciones (id_seccion)
) ENGINE = InnoDB;

-- =====================================================================
-- DATOS DE PRUEBA
-- =====================================================================

-- La contraseña real se guarda cifrada con bcrypt desde la API.
-- Este hash es solo de ejemplo; se reemplaza al registrar usuarios por /auth/register.
INSERT INTO usuarios (nombre, correo, password_hash, rol) VALUES
  ('Administrador', 'admin@academia.hn', '$2b$10$ejemploDeHashBcryptSoloParaPruebasXXXXXXXXXXXXXXXXXXXX', 'admin');

INSERT INTO cursos (nombre, descripcion) VALUES
  ('Informática',  'Programa de computación y programación'),
  ('Inglés',       'Programa de idioma inglés por niveles'),
  ('Contabilidad', 'Programa de contabilidad básica');

INSERT INTO docentes (nombre, correo, telefono) VALUES
  ('Marlon Reyes',   'mreyes@academia.hn',   '9999-1111'),
  ('Sofía Mejía',    'smejia@academia.hn',   '9999-2222'),
  ('Carlos Funes',   'cfunes@academia.hn',   '9999-3333');

INSERT INTO estudiantes (nombre, identidad, correo, telefono) VALUES
  ('Ana Pineda',      '0801-2005-00123', 'ana.pineda@correo.com',   '8888-0001'),
  ('Luis Ordóñez',    '0703-2004-00456', 'luis.ordonez@correo.com', '8888-0002'),
  ('María Cruz',      '0801-2006-00789', 'maria.cruz@correo.com',   '8888-0003'),
  ('José Hernández',  '0501-2003-00321', 'jose.hernandez@correo.com','8888-0004'),
  ('Daniela Flores',  '0801-2005-00654', 'daniela.flores@correo.com','8888-0005');

INSERT INTO asignaturas (id_curso, nombre, creditos) VALUES
  (1, 'Programación I',          4),
  (1, 'Bases de Datos',          4),
  (2, 'Inglés Básico',           3),
  (2, 'Inglés Intermedio',       3),
  (3, 'Contabilidad General',    4),
  (3, 'Matemática Financiera',   3);

INSERT INTO secciones (id_asignatura, id_docente, codigo, horario, cupo_maximo) VALUES
  (1, 1, 'PROG1-A', 'Lun-Mié 08:00-10:00', 30),
  (2, 1, 'BD-A',    'Mar-Jue 08:00-10:00', 25),
  (3, 2, 'ING1-A',  'Lun-Mié 10:00-12:00', 20),
  (4, 2, 'ING2-A',  'Mar-Jue 10:00-12:00', 2),   -- cupo pequeño para probar el rechazo
  (5, 3, 'CONT-A',  'Lun-Vie 14:00-15:00', 30),
  (6, 3, 'MATF-A',  'Mar-Jue 14:00-16:00', 25);

INSERT INTO matriculas (id_estudiante, periodo) VALUES
  (1, '2026-III'),
  (2, '2026-III');

INSERT INTO detalle_matricula (id_matricula, id_seccion) VALUES
  (1, 1), (1, 2), (1, 3),
  (2, 1), (2, 4);

-- Se actualiza el cupo ocupado según lo matriculado
UPDATE secciones s
SET cupo_ocupado = (SELECT COUNT(*) FROM detalle_matricula d WHERE d.id_seccion = s.id_seccion);

-- =====================================================================
-- EJEMPLO DE LA REGLA DE NEGOCIO (cupo)
-- Así lo hará la API dentro de una transacción:
--   1) Se intenta ocupar un cupo solo si todavía hay espacio.
--   2) Si no se afectó ninguna fila, la sección está llena: ROLLBACK y se rechaza.
--
--   START TRANSACTION;
--   UPDATE secciones
--      SET cupo_ocupado = cupo_ocupado + 1
--    WHERE id_seccion = 4 AND cupo_ocupado < cupo_maximo;
--   -- filas afectadas = 0  ->  ROLLBACK;  (sección llena)
--   -- filas afectadas = 1  ->  INSERT INTO detalle_matricula ...; COMMIT;
-- =====================================================================
