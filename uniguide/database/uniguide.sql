-- =====================================================================
-- UniGuide AI - Base de datos institucional
-- Universidad Politecnica de San Luis Potosi
-- Ingenieria de Software II
--
-- Cambios respecto a la version 1 (dump de phpMyAdmin):
--   * Motor MyISAM -> InnoDB (soporte de llaves foraneas y transacciones)
--   * Charset latin1 -> utf8mb4 (acentos y enies correctos desde Node/Python)
--   * Se agregan llaves foraneas e indices FULLTEXT (RNF2 Modulo 3: <1s)
--   * Se corrige la categoria de los registros de oferta academica
--   * Se agrega la tabla pregunta_frecuente (faltaba y la UI ya la pide)
--   * Se amplia el contenido para que la demo no se vea vacia
-- =====================================================================

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS `historial_chat`;
DROP TABLE IF EXISTS `sesion_chat`;
DROP TABLE IF EXISTS `pregunta_frecuente`;
DROP TABLE IF EXISTS `base_conocimiento`;
DROP TABLE IF EXISTS `horario`;
DROP TABLE IF EXISTS `servicio`;
DROP TABLE IF EXISTS `tramite`;
DROP TABLE IF EXISTS `lugar`;
DROP TABLE IF EXISTS `categoria`;
DROP TABLE IF EXISTS `usuario_admin`;

SET FOREIGN_KEY_CHECKS = 1;

-- ---------------------------------------------------------------------
-- categoria: tipos de intencion que el motor de IA debe distinguir
-- (RF1 Modulo 2: tramite / ubicacion / servicio / horario)
-- ---------------------------------------------------------------------
CREATE TABLE `categoria` (
  `id_categoria` INT(11) NOT NULL AUTO_INCREMENT,
  `clave`        VARCHAR(20)  NOT NULL,
  `nombre`       VARCHAR(50)  NOT NULL,
  `descripcion`  TEXT,
  PRIMARY KEY (`id_categoria`),
  UNIQUE KEY `uq_categoria_clave` (`clave`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `categoria` (`id_categoria`, `clave`, `nombre`, `descripcion`) VALUES
(1, 'UBICACION', 'Ubicación',  'Espacios físicos, edificios y laboratorios del campus'),
(2, 'TRAMITE',   'Trámite',    'Procedimientos académicos y administrativos'),
(3, 'SERVICIO',  'Servicio',   'Servicios complementarios para la comunidad universitaria'),
(4, 'HORARIO',   'Horario',    'Tiempos de atención de oficinas y espacios'),
(5, 'ACADEMICO', 'Académico',  'Oferta educativa, carreras y planes de estudio'),
(6, 'GENERAL',   'General',    'Preguntas frecuentes e información institucional');

-- ---------------------------------------------------------------------
-- lugar: coordenadas para el RF2 del Modulo 3 (mapas)
-- ---------------------------------------------------------------------
CREATE TABLE `lugar` (
  `id_lugar`    INT(11) NOT NULL AUTO_INCREMENT,
  `nombre`      VARCHAR(100)   NOT NULL,
  `latitud`     DECIMAL(10,8)  NOT NULL,
  `longitud`    DECIMAL(11,8)  NOT NULL,
  `url_mapa`    TEXT,
  `descripcion` TEXT,
  PRIMARY KEY (`id_lugar`),
  FULLTEXT KEY `ft_lugar` (`nombre`, `descripcion`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `lugar` (`id_lugar`, `nombre`, `latitud`, `longitud`, `url_mapa`, `descripcion`) VALUES
(1, 'Edificio A - Rectoría y Administración', 22.11894400, -100.94270000, 'https://maps.google.com/?q=22.118944,-100.942700', 'Oficinas administrativas, Rectoría y Servicios Escolares'),
(2, 'Edificio B - Aulas e Informática',       22.11920000, -100.94230000, 'https://maps.google.com/?q=22.119200,-100.942300', 'Aulas de clase y laboratorios de cómputo'),
(3, 'Biblioteca Central',                     22.11950000, -100.94250000, 'https://maps.google.com/?q=22.119500,-100.942500', 'Acervo bibliográfico, salas de estudio y consulta'),
(4, 'Centro de Nuevas Tecnologías (CENTI)',   22.11910000, -100.94300000, 'https://maps.google.com/?q=22.119100,-100.943000', 'Laboratorios especializados de ingeniería y desarrollo'),
(5, 'Laboratorio de Redes',                   22.11922000, -100.94225000, 'https://maps.google.com/?q=22.119220,-100.942250', 'Laboratorio de redes y telecomunicaciones, Edificio B, segundo piso'),
(6, 'Cafetería Universitaria',                22.11905000, -100.94255000, 'https://maps.google.com/?q=22.119050,-100.942550', 'Servicio de alimentos para la comunidad universitaria'),
(7, 'Canchas y Área Deportiva',               22.11880000, -100.94180000, 'https://maps.google.com/?q=22.118800,-100.941800', 'Canchas de fútbol, básquetbol y área de actividades deportivas'),
(8, 'Auditorio',                              22.11935000, -100.94285000, 'https://maps.google.com/?q=22.119350,-100.942850', 'Espacio para conferencias, ceremonias y eventos académicos');

-- ---------------------------------------------------------------------
-- tramite
-- ---------------------------------------------------------------------
CREATE TABLE `tramite` (
  `id_tramite`      INT(11) NOT NULL AUTO_INCREMENT,
  `titulo`          VARCHAR(150)  NOT NULL,
  `descripcion`     TEXT          NOT NULL,
  `requisitos`      TEXT,
  `costo`           DECIMAL(8,2)  DEFAULT 0.00,
  `area_responsable` VARCHAR(100) DEFAULT NULL,
  `id_lugar`        INT(11)       DEFAULT NULL,
  PRIMARY KEY (`id_tramite`),
  KEY `fk_tramite_lugar` (`id_lugar`),
  CONSTRAINT `fk_tramite_lugar` FOREIGN KEY (`id_lugar`) REFERENCES `lugar` (`id_lugar`) ON DELETE SET NULL,
  FULLTEXT KEY `ft_tramite` (`titulo`, `descripcion`, `requisitos`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `tramite` (`id_tramite`, `titulo`, `descripcion`, `requisitos`, `costo`, `area_responsable`, `id_lugar`) VALUES
(1, 'Constancia de Estudios', 'Expedición de documento oficial que acredita la inscripción del alumno en el ciclo escolar vigente.', 'Solicitud en módulo, Credencial de estudiante vigente, Comprobante de pago', 150.00, 'Servicios Escolares', 1),
(2, 'Inscripción y Reinscripción', 'Proceso de registro de asignaturas para el periodo lectivo.', 'Ficha de pago cubierta, Liberación de adeudos en biblioteca y laboratorios, Evaluaciones docentes completadas', 0.00, 'Servicios Escolares', 1),
(3, 'Credencial de Estudiante (Reposición)', 'Solicitud de nueva credencial por robo o extravío.', 'Pago de derechos, Identificación oficial, Fotografía infantil', 200.00, 'Servicios Escolares', 1),
(4, 'Kardex o Historial Académico', 'Documento que concentra las calificaciones obtenidas por el alumno a lo largo de su trayectoria.', 'Solicitud en ventanilla, Credencial vigente, Comprobante de pago', 120.00, 'Servicios Escolares', 1),
(5, 'Baja Temporal de Asignatura', 'Solicitud para darse de baja de una o varias materias dentro del periodo establecido.', 'Solicitud firmada por el tutor, Vo.Bo. del director de carrera, Estar dentro del plazo del calendario escolar', 0.00, 'Servicios Escolares', 1),
(6, 'Servicio Social', 'Registro y liberación del servicio social obligatorio.', 'Haber cubierto el 70% de créditos, Carta de aceptación de la institución receptora, Formato de registro', 0.00, 'Vinculación', 1);

-- ---------------------------------------------------------------------
-- servicio
-- ---------------------------------------------------------------------
CREATE TABLE `servicio` (
  `id_servicio`  INT(11) NOT NULL AUTO_INCREMENT,
  `nombre`       VARCHAR(100) NOT NULL,
  `descripcion`  TEXT,
  `id_lugar`     INT(11) DEFAULT NULL,
  PRIMARY KEY (`id_servicio`),
  KEY `fk_servicio_lugar` (`id_lugar`),
  CONSTRAINT `fk_servicio_lugar` FOREIGN KEY (`id_lugar`) REFERENCES `lugar` (`id_lugar`) ON DELETE SET NULL,
  FULLTEXT KEY `ft_servicio` (`nombre`, `descripcion`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `servicio` (`id_servicio`, `nombre`, `descripcion`, `id_lugar`) VALUES
(1, 'Préstamo de Libros y Material', 'Préstamo en sala y a domicilio de material bibliográfico.', 3),
(2, 'Atención de Servicios Escolares', 'Trámites de constancias, certificados, credenciales y kardex.', 1),
(3, 'Acceso a Laboratorios de Cómputo', 'Uso de equipos de cómputo para desarrollo de prácticas y tareas.', 2),
(4, 'Servicio de Cafetería', 'Venta de alimentos y bebidas para estudiantes y personal.', 6),
(5, 'Actividades Deportivas', 'Inscripción a equipos representativos y uso de canchas.', 7),
(6, 'Tutorías Académicas', 'Acompañamiento académico personalizado por parte de docentes tutores.', 2);

-- ---------------------------------------------------------------------
-- horario
-- ---------------------------------------------------------------------
CREATE TABLE `horario` (
  `id_horario`     INT(11) NOT NULL AUTO_INCREMENT,
  `dias`           VARCHAR(50) NOT NULL,
  `hora_apertura`  TIME NOT NULL,
  `hora_cierre`    TIME NOT NULL,
  `id_lugar`       INT(11) DEFAULT NULL,
  `id_servicio`    INT(11) DEFAULT NULL,
  PRIMARY KEY (`id_horario`),
  KEY `fk_horario_lugar` (`id_lugar`),
  KEY `fk_horario_servicio` (`id_servicio`),
  CONSTRAINT `fk_horario_lugar`    FOREIGN KEY (`id_lugar`)    REFERENCES `lugar` (`id_lugar`)       ON DELETE CASCADE,
  CONSTRAINT `fk_horario_servicio` FOREIGN KEY (`id_servicio`) REFERENCES `servicio` (`id_servicio`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `horario` (`id_horario`, `dias`, `hora_apertura`, `hora_cierre`, `id_lugar`, `id_servicio`) VALUES
(1, 'Lunes a Viernes', '08:00:00', '19:00:00', 3, 1),
(2, 'Lunes a Viernes', '08:00:00', '16:00:00', 1, 2),
(3, 'Lunes a Viernes', '07:00:00', '21:00:00', 2, 3),
(4, 'Lunes a Viernes', '07:30:00', '18:00:00', 6, 4),
(5, 'Lunes a Sábado',  '07:00:00', '20:00:00', 7, 5);

-- ---------------------------------------------------------------------
-- base_conocimiento: fuente unica de verdad para el grounding (RNF1 Mod.2)
-- ---------------------------------------------------------------------
CREATE TABLE `base_conocimiento` (
  `id_conocimiento`     INT(11) NOT NULL AUTO_INCREMENT,
  `id_categoria`        INT(11) NOT NULL,
  `titulo`              VARCHAR(200) NOT NULL,
  `contenido`           TEXT NOT NULL,
  `palabras_clave`      VARCHAR(255) DEFAULT NULL,
  `id_lugar`            INT(11) DEFAULT NULL,
  `id_tramite`          INT(11) DEFAULT NULL,
  `activo`              TINYINT(1) NOT NULL DEFAULT 1,
  `fecha_actualizacion` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_conocimiento`),
  KEY `fk_bc_categoria` (`id_categoria`),
  KEY `fk_bc_lugar` (`id_lugar`),
  KEY `fk_bc_tramite` (`id_tramite`),
  CONSTRAINT `fk_bc_categoria` FOREIGN KEY (`id_categoria`) REFERENCES `categoria` (`id_categoria`),
  CONSTRAINT `fk_bc_lugar`     FOREIGN KEY (`id_lugar`)     REFERENCES `lugar` (`id_lugar`)     ON DELETE SET NULL,
  CONSTRAINT `fk_bc_tramite`   FOREIGN KEY (`id_tramite`)   REFERENCES `tramite` (`id_tramite`) ON DELETE SET NULL,
  FULLTEXT KEY `ft_conocimiento` (`titulo`, `contenido`, `palabras_clave`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `base_conocimiento` (`id_categoria`, `titulo`, `contenido`, `palabras_clave`, `id_lugar`, `id_tramite`) VALUES
(5, 'Oferta Académica de Ingenierías', 'La UPSLP ofrece las carreras de Ingeniería en Tecnologías de la Información (ITI), Ingeniería Telemática (ITE), Ingeniería en Sistemas Tecnológicos Industriales (ISTI), Ingeniería Mecatrónica (IM) e Ingeniería Industrial (II).', 'carreras ingenierias oferta educativa ITI ITE mecatronica industrial telematica', NULL, NULL),
(5, 'Oferta Académica de Licenciaturas', 'La universidad cuenta con la Licenciatura en Administración y Gestión (LAG) y Licenciatura en Mercadotecnia Internacional (LMI).', 'licenciaturas carreras LAG LMI administracion mercadotecnia', NULL, NULL),
(1, 'Ubicación del Edificio de Servicios Escolares', 'El área de Servicios Escolares se encuentra en el Edificio A (Rectoría y Administración) de la UPSLP.', 'servicios escolares ubicacion edificio A ventanilla donde esta', 1, 1),
(4, 'Horario de la Biblioteca', 'La biblioteca de la UPSLP ofrece servicio de lunes a viernes en un horario continuo de 08:00 a 19:00 hrs.', 'horario biblioteca apertura cierre consultar libros', 3, NULL),
(1, 'Ubicación del Laboratorio de Redes', 'El Laboratorio de Redes se encuentra en el Edificio B (Aulas e Informática), en el segundo piso.', 'laboratorio redes ubicacion edificio B segundo piso telematica', 5, NULL),
(1, 'Ubicación de la Biblioteca', 'La Biblioteca Central de la UPSLP se ubica en el edificio de Biblioteca, con acceso desde el andador principal del campus.', 'biblioteca ubicacion donde esta acervo libros', 3, NULL),
(2, 'Requisitos para Constancia de Estudios', 'Para solicitar una constancia de estudios debes acudir a Servicios Escolares con tu credencial de estudiante vigente, llenar la solicitud en el módulo y presentar el comprobante de pago correspondiente.', 'constancia estudios requisitos tramite solicitar documento', 1, 1),
(2, 'Proceso de Reinscripción', 'Para reinscribirte debes tener cubierta la ficha de pago, no presentar adeudos en biblioteca ni laboratorios y haber completado las evaluaciones docentes del periodo anterior.', 'reinscripcion inscripcion materias registro asignaturas periodo', 1, 2),
(2, 'Reposición de Credencial', 'En caso de robo o extravío de la credencial de estudiante debes acudir a Servicios Escolares con identificación oficial, una fotografía infantil y el pago de derechos correspondiente.', 'credencial reposicion extravio robo estudiante', 1, 3),
(2, 'Registro de Servicio Social', 'El servicio social se registra en el área de Vinculación. Es necesario haber cubierto al menos el 70% de los créditos de la carrera y presentar la carta de aceptación de la institución receptora.', 'servicio social registro liberacion creditos vinculacion', 1, 6),
(3, 'Préstamo de Material Bibliográfico', 'La biblioteca ofrece préstamo en sala y préstamo a domicilio de material bibliográfico para la comunidad universitaria.', 'prestamo libros material bibliografico biblioteca domicilio sala', 3, NULL),
(3, 'Laboratorios de Cómputo', 'Los laboratorios de cómputo están disponibles para el desarrollo de prácticas y tareas de los estudiantes, ubicados en el Edificio B.', 'laboratorio computo equipos practicas tareas edificio B', 2, NULL),
(4, 'Horario de Servicios Escolares', 'Servicios Escolares atiende de lunes a viernes de 08:00 a 16:00 hrs en el Edificio A.', 'horario servicios escolares atencion ventanilla', 1, NULL),
(4, 'Horario de Laboratorios de Cómputo', 'Los laboratorios de cómputo están disponibles de lunes a viernes de 07:00 a 21:00 hrs.', 'horario laboratorio computo disponibilidad', 2, NULL),
(6, 'Contacto General de la Universidad', 'La Universidad Politécnica de San Luis Potosí se ubica en Urbano Villalón 500, La Ladrillera, San Luis Potosí. Para dudas específicas puedes acudir directamente al área correspondiente en el Edificio A.', 'contacto direccion telefono ubicacion universidad campus', 1, NULL);

-- ---------------------------------------------------------------------
-- pregunta_frecuente: la UI ya tiene la seccion "Preguntas frecuentes"
-- ---------------------------------------------------------------------
CREATE TABLE `pregunta_frecuente` (
  `id_faq`       INT(11) NOT NULL AUTO_INCREMENT,
  `pregunta`     VARCHAR(255) NOT NULL,
  `respuesta`    TEXT NOT NULL,
  `id_categoria` INT(11) DEFAULT NULL,
  `orden`        INT(11) DEFAULT 0,
  PRIMARY KEY (`id_faq`),
  KEY `fk_faq_categoria` (`id_categoria`),
  CONSTRAINT `fk_faq_categoria` FOREIGN KEY (`id_categoria`) REFERENCES `categoria` (`id_categoria`) ON DELETE SET NULL,
  FULLTEXT KEY `ft_faq` (`pregunta`, `respuesta`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `pregunta_frecuente` (`pregunta`, `respuesta`, `id_categoria`, `orden`) VALUES
('¿Cuánto cuesta una constancia de estudios?', 'La constancia de estudios tiene un costo de $150.00 MXN y se solicita en Servicios Escolares.', 2, 1),
('¿Dónde está Servicios Escolares?', 'Servicios Escolares se encuentra en el Edificio A (Rectoría y Administración).', 1, 2),
('¿Qué carreras ofrece la UPSLP?', 'La UPSLP ofrece cinco ingenierías (ITI, ITE, ISTI, Mecatrónica e Industrial) y dos licenciaturas (LAG y LMI).', 5, 3),
('¿A qué hora abre la biblioteca?', 'La biblioteca abre de lunes a viernes de 08:00 a 19:00 hrs.', 4, 4),
('¿Cómo repongo mi credencial?', 'Debes acudir a Servicios Escolares con identificación oficial, una fotografía infantil y el pago de derechos ($200.00 MXN).', 2, 5);

-- ---------------------------------------------------------------------
-- sesion_chat / historial_chat: RF3 Modulo 1 y auditoria de tokens
-- ---------------------------------------------------------------------
CREATE TABLE `sesion_chat` (
  `id_sesion`        INT(11) NOT NULL AUTO_INCREMENT,
  `origen`           ENUM('WEB','TELEGRAM','OPENCLAW','NANOCLAW') NOT NULL,
  `telegram_chat_id` BIGINT(20) DEFAULT NULL,
  `token_sesion`     VARCHAR(64) DEFAULT NULL,
  `fecha_inicio`     TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_sesion`),
  KEY `idx_token_sesion` (`token_sesion`),
  KEY `idx_telegram_chat` (`telegram_chat_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `historial_chat` (
  `id_mensaje`          BIGINT(20) NOT NULL AUTO_INCREMENT,
  `id_sesion`           INT(11) NOT NULL,
  `emisor`              ENUM('USUARIO','IA','SISTEMA') NOT NULL,
  `mensaje`             TEXT NOT NULL,
  `intencion_detectada` VARCHAR(50) DEFAULT NULL,
  `tokens_consumidos`   INT(11) DEFAULT 0,
  `ms_respuesta`        INT(11) DEFAULT NULL,
  `fecha_registro`      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_mensaje`),
  KEY `fk_hist_sesion` (`id_sesion`),
  CONSTRAINT `fk_hist_sesion` FOREIGN KEY (`id_sesion`) REFERENCES `sesion_chat` (`id_sesion`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------
-- usuario_admin: RF3 Modulo 3 (panel de administracion)
-- IMPORTANTE: el hash de abajo es un PLACEHOLDER y no corresponde a ninguna
-- contrasena util. Generen el suyo antes de entregar:
--    cd backend && node scripts/hash.js "suPasswordSegura"
-- y reemplacen el valor de password_hash con la salida.
-- ---------------------------------------------------------------------
CREATE TABLE `usuario_admin` (
  `id_admin`      INT(11) NOT NULL AUTO_INCREMENT,
  `nombre`        VARCHAR(100) NOT NULL,
  `email`         VARCHAR(100) NOT NULL,
  `password_hash` VARCHAR(255) NOT NULL,
  `rol`           VARCHAR(20) DEFAULT 'Editor',
  `fecha_alta`    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_admin`),
  UNIQUE KEY `uq_admin_email` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `usuario_admin` (`nombre`, `email`, `password_hash`, `rol`) VALUES
('Administrador UniGuide', 'admin@upslp.edu.mx', 'REEMPLAZAR_CON_HASH_BCRYPT', 'Admin');
