-- Proyecto final DIA-117 | Caso 7: Matrícula de una academia
-- Primera idea del modelo (Hito 1)

DROP DATABASE IF EXISTS academia_db;
CREATE DATABASE academia_db;
USE academia_db;

CREATE TABLE usuarios (
  id_usuario    INT AUTO_INCREMENT PRIMARY KEY,
  nombre        VARCHAR(100),
  correo        VARCHAR(100),
  password_hash VARCHAR(255)
);

CREATE TABLE cursos (
  id_curso INT AUTO_INCREMENT PRIMARY KEY,
  nombre   VARCHAR(100)
);

CREATE TABLE docentes (
  id_docente INT AUTO_INCREMENT PRIMARY KEY,
  nombre     VARCHAR(100)
);

CREATE TABLE estudiantes (
  id_estudiante INT AUTO_INCREMENT PRIMARY KEY,
  nombre        VARCHAR(100),
  identidad     VARCHAR(20)
);

CREATE TABLE asignaturas (
  id_asignatura INT AUTO_INCREMENT PRIMARY KEY,
  id_curso      INT,
  nombre        VARCHAR(100),
  FOREIGN KEY (id_curso) REFERENCES cursos (id_curso)
);

CREATE TABLE secciones (
  id_seccion    INT AUTO_INCREMENT PRIMARY KEY,
  id_asignatura INT,
  id_docente    INT,
  cupo_maximo   INT,
  cupo_ocupado  INT DEFAULT 0,
  FOREIGN KEY (id_asignatura) REFERENCES asignaturas (id_asignatura),
  FOREIGN KEY (id_docente) REFERENCES docentes (id_docente)
);

CREATE TABLE matriculas (
  id_matricula  INT AUTO_INCREMENT PRIMARY KEY,
  id_estudiante INT,
  fecha         TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (id_estudiante) REFERENCES estudiantes (id_estudiante)
);

CREATE TABLE detalle_matricula (
  id_detalle   INT AUTO_INCREMENT PRIMARY KEY,
  id_matricula INT,
  id_seccion   INT,
  FOREIGN KEY (id_matricula) REFERENCES matriculas (id_matricula),
  FOREIGN KEY (id_seccion) REFERENCES secciones (id_seccion)
);

-- Datos de ejemplo
INSERT INTO cursos (nombre) VALUES ('Informática');
INSERT INTO docentes (nombre) VALUES ('Marlon Reyes');
INSERT INTO estudiantes (nombre, identidad) VALUES ('Ana Pineda', '0801-2005-00123');
INSERT INTO asignaturas (id_curso, nombre) VALUES (1, 'Programación I');
INSERT INTO secciones (id_asignatura, id_docente, cupo_maximo) VALUES (1, 1, 30);

-- Regla de negocio: solo se matricula si la sección todavía tiene cupo.
-- Si esta consulta no modifica ninguna fila, la sección está llena y se rechaza.
-- UPDATE secciones SET cupo_ocupado = cupo_ocupado + 1
-- WHERE id_seccion = 1 AND cupo_ocupado < cupo_maximo;
