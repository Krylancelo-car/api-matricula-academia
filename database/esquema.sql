DROP DATABASE IF EXISTS academia_db;
CREATE DATABASE academia_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE academia_db;

-- Tabla: usuarios
CREATE TABLE usuarios (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    correo VARCHAR(100) NOT NULL UNIQUE,
    hash VARCHAR(60) NOT NULL,
    rol ENUM('admin', 'operador') NOT NULL DEFAULT 'operador',
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    creado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Tabla: cursos (Catálogo 1)
CREATE TABLE cursos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL UNIQUE,
    descripcion TEXT NULL,
    creado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Tabla: estudiantes (Catálogo 2)
CREATE TABLE estudiantes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    identificacion VARCHAR(20) NOT NULL UNIQUE,
    nombre VARCHAR(100) NOT NULL,
    correo VARCHAR(100) NOT NULL UNIQUE,
    telefono VARCHAR(15) NULL,
    creado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Tabla: secciones (Entidad Principal)
CREATE TABLE secciones (
    id INT AUTO_INCREMENT PRIMARY KEY,
    curso_id INT NOT NULL,
    docente VARCHAR(100) NOT NULL,
    cupo INT NOT NULL DEFAULT 20,
    estado ENUM('disponible', 'llena', 'cancelada') NOT NULL DEFAULT 'disponible',
    creado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_secciones_curso FOREIGN KEY (curso_id) 
        REFERENCES cursos(id) ON DELETE RESTRICT,
    INDEX idx_secciones_estado (estado)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Tabla: matriculas (Cabecera)
CREATE TABLE matriculas (
    id INT AUTO_INCREMENT PRIMARY KEY,
    estudiante_id INT NOT NULL,
    usuario_id INT NOT NULL,
    fecha_matricula DATETIME DEFAULT CURRENT_TIMESTAMP,
    periodo VARCHAR(20) NOT NULL,
    estado ENUM('activa', 'cancelada') NOT NULL DEFAULT 'activa',
    CONSTRAINT fk_matriculas_estudiante FOREIGN KEY (estudiante_id) 
        REFERENCES estudiantes(id) ON DELETE RESTRICT,
    CONSTRAINT fk_matriculas_usuario FOREIGN KEY (usuario_id) 
        REFERENCES usuarios(id) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Tabla: matricula_detalle (Detalle)
CREATE TABLE matricula_detalle (
    matricula_id INT NOT NULL,
    seccion_id INT NOT NULL,
    PRIMARY KEY (matricula_id, seccion_id),
    CONSTRAINT fk_detalle_matricula FOREIGN KEY (matricula_id) 
        REFERENCES matriculas(id) ON DELETE CASCADE,
    CONSTRAINT fk_detalle_seccion FOREIGN KEY (seccion_id) 
        REFERENCES secciones(id) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Datos Semilla Básicos
INSERT INTO cursos (nombre, descripcion) VALUES 
('Programación I', 'Introducción a la programación estructurada'),
('Bases de Datos I', 'Diseño relacional y SQL'),
('Redes de Computadoras', 'Fundamentos de redes e interfaces');

INSERT INTO estudiantes (identificacion, nombre, correo, telefono) VALUES
('0801200100123', 'Carlos Mendoza', 'carlos@estudiante.hn', '9988-7766'),
('0801200200456', 'María Fernández', 'maria@estudiante.hn', '8877-6655');

INSERT INTO secciones (curso_id, docente, cupo, estado) VALUES
(1, 'Ing. Jairo Martínez', 25, 'disponible'),
(2, 'Ing. Ana Rodríguez', 20, 'disponible');