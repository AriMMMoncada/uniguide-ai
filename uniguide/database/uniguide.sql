-- Adminer 6.1.0 MySQL 9.4.0 dump

SET NAMES utf8;
SET time_zone = '+00:00';
SET foreign_key_checks = 0;
SET sql_mode = 'NO_AUTO_VALUE_ON_ZERO';

SET NAMES utf8mb4;

DROP TABLE IF EXISTS `base_conocimiento`;
CREATE TABLE `base_conocimiento` (
  `id_conocimiento` int NOT NULL AUTO_INCREMENT,
  `id_categoria` int NOT NULL,
  `titulo` varchar(200) COLLATE utf8mb4_unicode_ci NOT NULL,
  `contenido` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `palabras_clave` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `id_lugar` int DEFAULT NULL,
  `id_tramite` int DEFAULT NULL,
  `activo` tinyint(1) NOT NULL DEFAULT '1',
  `fecha_actualizacion` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_conocimiento`),
  KEY `fk_bc_categoria` (`id_categoria`),
  KEY `fk_bc_lugar` (`id_lugar`),
  KEY `fk_bc_tramite` (`id_tramite`),
  FULLTEXT KEY `ft_conocimiento` (`titulo`,`contenido`,`palabras_clave`),
  CONSTRAINT `fk_bc_categoria` FOREIGN KEY (`id_categoria`) REFERENCES `categoria` (`id_categoria`),
  CONSTRAINT `fk_bc_lugar` FOREIGN KEY (`id_lugar`) REFERENCES `lugar` (`id_lugar`) ON DELETE SET NULL,
  CONSTRAINT `fk_bc_tramite` FOREIGN KEY (`id_tramite`) REFERENCES `tramite` (`id_tramite`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `base_conocimiento` (`id_conocimiento`, `id_categoria`, `titulo`, `contenido`, `palabras_clave`, `id_lugar`, `id_tramite`, `activo`, `fecha_actualizacion`) VALUES
(1,	5,	'Oferta Académica de Ingenierías',	'La UPSLP ofrece las carreras de Ingeniería en Tecnologías de la Información (ITI), Ingeniería en Telecomunicaciones (ITEM), Ingeniería en Sistemas y Tecnologías Industriales (ISTI) y Ingeniería en Tecnologías de Manufactura (ITMA).',	'carreras ingenierias oferta educativa ITI ITEM ISTI ITMA',	NULL,	NULL,	1,	'2026-09-16 09:33:32'),
(2,	5,	'Oferta Académica de Licenciaturas',	'La universidad cuenta con la Licenciatura en Administración y Gestión (LAG) y Licenciatura en Mercadotecnia Internacional (LMI).',	'licenciaturas carreras LAG LMI administracion mercadotecnia',	NULL,	NULL,	1,	'2026-09-16 08:45:15'),
(3,	1,	'Ubicación del Edificio de Servicios Escolares',	'El área de Servicios Escolares se encuentra cerca de rectoría y administración de la UPSLP.',	'servicios escolares ubicacion edificio A ventanilla donde esta',	1,	1,	1,	'2026-09-16 09:37:30'),
(4,	4,	'Horario de la Biblioteca',	'La biblioteca de la UPSLP ofrece servicio de lunes a viernes en un horario continuo de 08:00 a 19:00 hrs.',	'horario biblioteca apertura cierre consultar libros',	3,	NULL,	1,	'2026-09-16 08:45:15'),
(5,	1,	'Ubicación del Laboratorio de Redes',	'El Laboratorio de Redes se encuentra en el Edificio de CNT, en el segundo piso.',	'laboratorio redes ubicacion edificio B segundo piso telematica',	5,	NULL,	1,	'2026-09-16 09:39:04'),
(6,	1,	'Ubicación de la Biblioteca',	'La Biblioteca Central de la UPSLP se ubica en el edificio de Biblioteca, con acceso desde el andador principal del campus.',	'biblioteca ubicacion donde esta acervo libros',	3,	NULL,	1,	'2026-09-16 08:45:15'),
(7,	2,	'Requisitos para Constancia de Estudios',	'Para solicitar una constancia de estudios debes acudir a Servicios Escolares con tu credencial de estudiante vigente, llenar la solicitud en el módulo y presentar el comprobante de pago correspondiente.',	'constancia estudios requisitos tramite solicitar documento',	1,	1,	1,	'2026-09-16 08:45:15'),
(8,	2,	'Proceso de Reinscripción',	'Para reinscribirte debes tener cubierta la ficha de pago, no presentar adeudos en biblioteca ni laboratorios y haber completado las evaluaciones docentes del periodo anterior.',	'reinscripcion inscripcion materias registro asignaturas periodo',	1,	2,	1,	'2026-09-16 08:45:15'),
(9,	2,	'Reposición de Credencial',	'En caso de robo o extravío de la credencial de estudiante debes acudir a Servicios Escolares con identificación oficial, una fotografía infantil y el pago de derechos correspondiente.',	'credencial reposicion extravio robo estudiante',	1,	3,	1,	'2026-09-16 08:45:15'),
(10,	2,	'Registro de Servicio Social',	'El servicio social se registra en el área de Vinculación. Es necesario haber cubierto al menos el 70% de los créditos de la carrera y presentar la carta de aceptación de la institución receptora.',	'servicio social registro liberacion creditos vinculacion',	1,	6,	1,	'2026-09-16 08:45:15'),
(11,	3,	'Préstamo de Material Bibliográfico',	'La biblioteca ofrece préstamo en sala y préstamo a domicilio de material bibliográfico para la comunidad universitaria.',	'prestamo libros material bibliografico biblioteca domicilio sala',	3,	NULL,	1,	'2026-09-16 08:45:15'),
(12,	3,	'Laboratorios de Cómputo',	'Los laboratorios de cómputo están disponibles para el desarrollo de prácticas y tareas de los estudiantes, ubicados en el Edificio CC.',	'laboratorio computo equipos practicas tareas centro computo',	2,	NULL,	1,	'2026-09-16 21:48:33'),
(13,	4,	'Horario de Servicios Escolares',	'Servicios Escolares atiende de lunes a viernes de 08:00 a 18:00 hrs en el Edificio A.',	'horario servicios escolares atencion ventanilla',	1,	NULL,	1,	'2026-09-16 09:52:38'),
(14,	4,	'Horario de Laboratorios de Cómputo',	'Los laboratorios de cómputo están disponibles de lunes a viernes de 07:00 a 21:00 hrs.',	'horario laboratorio computo disponibilidad',	2,	NULL,	1,	'2026-09-16 08:45:15'),
(15,	6,	'Contacto General de la Universidad',	'La Universidad Politécnica de San Luis Potosí se ubica en Urbano Villalón 500, La Ladrillera, San Luis Potosí. Para dudas específicas puedes acudir directamente al área correspondiente en el Edificio A.',	'contacto direccion telefono ubicacion universidad campus',	1,	NULL,	1,	'2026-09-16 08:45:15'),
(16,	1,	'Ubicación del Centro de Nuevas Tecnologías (CNT)',	'El Centro de Nuevas Tecnologías (CNT) alberga los laboratorios especializados de ingeniería y desarrollo, incluido el Laboratorio de Redes.',	'CNT centro nuevas tecnologias tecnologia edificio ubicacion donde esta ingenieria desarrollo laboratorios',	4,	NULL,	1,	'2026-09-16 21:48:31'),
(17,	1,	'Ubicación de la Cafetería',	'La Cafetería Up ofrece servicio de alimentos y bebidas para la comunidad universitaria.',	'cafeteria comida alimentos bebidas ubicacion donde esta up comedor',	6,	NULL,	1,	'2026-09-16 21:48:31'),
(18,	1,	'Ubicación de Canchas y Área Deportiva',	'Las Canchas y Área Deportiva cuentan con espacios para fútbol, básquetbol y otras actividades deportivas.',	'canchas deportivo deportes futbol basquetbol area ubicacion donde esta cancha',	7,	NULL,	1,	'2026-09-16 21:48:32'),
(19,	1,	'Ubicación del Auditorio',	'El Auditorio es el espacio destinado a conferencias, ceremonias y eventos académicos de la universidad.',	'auditorio eventos conferencias ceremonias ubicacion donde esta',	8,	NULL,	1,	'2026-09-16 21:48:32'),
(20,	1,	'Ubicación del Edificio ASA',	'El edificio ASA es el espacio donde se realizan conferencias y actividades de promoción dentro de la universidad.',	'asa edificio asa conferencias promociones eventos ubicacion donde esta',	9,	NULL,	1,	'2026-09-16 21:50:18'),
(21,	1,	'Ubicación del CNI (Centro de Negocios Internacionales)',	'El CNI (Centro de Negocios Internacionales) es el edificio donde se simulan tratos de negocios, propuestas de trabajo y entrevistas. También cuenta con cajeros automáticos de BBVA y Banorte.',	'cni centro negocios internacionales ubicacion donde esta cajero automatico bbva banorte entrevistas',	10,	NULL,	1,	'2026-09-16 21:50:18'),
(22,	1,	'Ubicación del CADI (Centro de Autoaprendizaje del Idioma Inglés)',	'El CADI es el edificio donde los alumnos pueden fortalecer y aprender habilidades del idioma inglés de forma autodidacta.',	'cadi centro autoaprendizaje idioma ingles ubicacion donde esta aprender ingles',	11,	NULL,	1,	'2026-09-16 21:50:18'),
(23,	1,	'Ubicación del CMA (Centro de Manufactura Avanzada)',	'El CMA es el edificio donde los estudiantes de manufactura realizan actividades y cursos extracurriculares.',	'cma centro manufactura avanzada ubicacion donde esta manufactura cursos',	12,	NULL,	1,	'2026-09-16 21:50:18'),
(24,	1,	'Ubicación de UAM1 (Unidad Académica de Maestros 1)',	'El UAM1 es el edificio donde los maestros administran sus labores de investigación, gestión curricular y atención al alumno. Aquí se encuentra la coordinación de ITI/ITEM.',	'uam1 unidad academica maestros 1 coordinacion iti item ubicacion donde esta',	13,	NULL,	1,	'2026-09-16 21:50:18'),
(25,	1,	'Ubicación de UAM2 (Unidad Académica de Maestros 2)',	'El UAM2 es el edificio donde los maestros administran sus labores de investigación, gestión curricular y atención al alumno.',	'uam2 unidad academica maestros 2 ubicacion donde esta',	14,	NULL,	1,	'2026-09-16 21:50:18'),
(26,	1,	'Ubicación de UAE1 (Unidad Académica de Estudiantes 1)',	'El UAE1 es un edificio con salones donde los estudiantes realizan sus actividades escolares diarias.',	'uae1 unidad academica estudiantes 1 salones clases ubicacion donde esta',	15,	NULL,	1,	'2026-09-16 21:50:18'),
(27,	1,	'Ubicación de UAE2 (Unidad Académica de Estudiantes 2)',	'El UAE2 es un edificio con salones donde los estudiantes realizan sus actividades escolares diarias.',	'uae2 unidad academica estudiantes 2 salones clases ubicacion donde esta',	16,	NULL,	1,	'2026-09-16 21:50:18'),
(28,	1,	'Ubicación de UAE3 (Unidad Académica de Estudiantes 3)',	'El UAE3 es un edificio con salones donde los estudiantes realizan sus actividades escolares diarias.',	'uae3 unidad academica estudiantes 3 salones clases ubicacion donde esta',	17,	NULL,	1,	'2026-09-16 21:50:18'),
(29,	1,	'Ubicación de UAE4 (Unidad Académica de Estudiantes 4)',	'El UAE4 es un edificio con salones donde los estudiantes realizan sus actividades escolares diarias.',	'uae4 unidad academica estudiantes 4 salones clases ubicacion donde esta',	18,	NULL,	1,	'2026-09-16 21:50:18'),
(30,	1,	'Ubicación del Gimnasio (GYM)',	'El GYM es el área deportiva donde los estudiantes pueden practicar baloncesto, voleibol, kárate, box y otras actividades físicas.',	'gym gimnasio deportes baloncesto voleibol karate box ejercicio actividad fisica ubicacion donde esta',	19,	NULL,	1,	'2026-09-16 21:50:18');

DROP TABLE IF EXISTS `categoria`;
CREATE TABLE `categoria` (
  `id_categoria` int NOT NULL AUTO_INCREMENT,
  `clave` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `nombre` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `descripcion` text COLLATE utf8mb4_unicode_ci,
  PRIMARY KEY (`id_categoria`),
  UNIQUE KEY `uq_categoria_clave` (`clave`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `categoria` (`id_categoria`, `clave`, `nombre`, `descripcion`) VALUES
(1,	'UBICACION',	'Ubicación',	'Espacios físicos, edificios y laboratorios del campus'),
(2,	'TRAMITE',	'Trámite',	'Procedimientos académicos y administrativos'),
(3,	'SERVICIO',	'Servicio',	'Servicios complementarios para la comunidad universitaria'),
(4,	'HORARIO',	'Horario',	'Tiempos de atención de oficinas y espacios'),
(5,	'ACADEMICO',	'Académico',	'Oferta educativa, carreras y planes de estudio'),
(6,	'GENERAL',	'General',	'Preguntas frecuentes e información institucional');

DROP TABLE IF EXISTS `historial_chat`;
CREATE TABLE `historial_chat` (
  `id_mensaje` bigint NOT NULL AUTO_INCREMENT,
  `id_sesion` int NOT NULL,
  `emisor` enum('USUARIO','IA','SISTEMA') COLLATE utf8mb4_unicode_ci NOT NULL,
  `mensaje` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `intencion_detectada` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `tokens_consumidos` int DEFAULT '0',
  `ms_respuesta` int DEFAULT NULL,
  `fecha_registro` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_mensaje`),
  KEY `fk_hist_sesion` (`id_sesion`),
  CONSTRAINT `fk_hist_sesion` FOREIGN KEY (`id_sesion`) REFERENCES `sesion_chat` (`id_sesion`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `historial_chat` (`id_mensaje`, `id_sesion`, `emisor`, `mensaje`, `intencion_detectada`, `tokens_consumidos`, `ms_respuesta`, `fecha_registro`) VALUES
(1,	1,	'USUARIO',	'¿qué necesito para una constancia?',	'TRAMITE',	0,	NULL,	'2026-09-16 08:55:37'),
(2,	1,	'IA',	'Sobre ese trámite: Para solicitar una constancia de estudios debes acudir a Servicios Escolares con tu credencial de estudiante vigente, llenar la solicitud en el módulo y presentar el comprobante de pago correspondiente. Requisitos: Solicitud en módulo, Credencial de estudiante vigente, Comprobante de pago Costo: $150.00 MXN Área responsable: Servicios Escolares Lugar: Edificio A - Rectoría y Administración',	'TRAMITE',	0,	537,	'2026-09-16 08:55:37'),
(3,	1,	'USUARIO',	'¿dónde está el laboratorio de redes?',	'UBICACION',	0,	NULL,	'2026-09-16 08:56:13'),
(4,	1,	'IA',	'Con gusto te ubico: El Laboratorio de Redes se encuentra en el Edificio B (Aulas e Informática), en el segundo piso. Lugar: Laboratorio de Redes',	'UBICACION',	0,	401,	'2026-09-16 08:56:13'),
(5,	1,	'USUARIO',	'edifico cnt',	'UBICACION',	0,	NULL,	'2026-09-16 08:59:36'),
(6,	1,	'SISTEMA',	'No cuento con información suficiente, te sugiero consultar directamente con el área correspondiente.',	'UBICACION',	0,	536,	'2026-09-16 08:59:36'),
(7,	1,	'USUARIO',	'¿a qué hora abre la biblioteca?',	'HORARIO',	0,	NULL,	'2026-09-16 09:01:31'),
(8,	1,	'IA',	'Este es el horario que tengo registrado: La Biblioteca Central de la UPSLP se ubica en el edificio de Biblioteca, con acceso desde el andador principal del campus. Lugar: Biblioteca Central',	'HORARIO',	0,	421,	'2026-09-16 09:01:32'),
(9,	1,	'USUARIO',	'¿qué necesito para una constancia?',	'TRAMITE',	0,	NULL,	'2026-09-16 09:02:01'),
(10,	1,	'IA',	'Sobre ese trámite: Para solicitar una constancia de estudios debes acudir a Servicios Escolares con tu credencial de estudiante vigente, llenar la solicitud en el módulo y presentar el comprobante de pago correspondiente. Requisitos: Solicitud en módulo, Credencial de estudiante vigente, Comprobante de pago Costo: $150.00 MXN Área responsable: Servicios Escolares Lugar: Edificio A - Rectoría y Administración',	'TRAMITE',	0,	400,	'2026-09-16 09:02:01'),
(11,	2,	'USUARIO',	'¿Dónde está la biblioteca?',	'UBICACION',	0,	NULL,	'2026-09-16 09:02:43'),
(12,	2,	'IA',	'Con gusto te ubico: La Biblioteca Central de la UPSLP se ubica en el edificio de Biblioteca, con acceso desde el andador principal del campus. Lugar: Biblioteca Central',	'UBICACION',	0,	532,	'2026-09-16 09:02:43'),
(13,	2,	'USUARIO',	'¿Dónde está Servicios Escolares?',	'UBICACION',	0,	NULL,	'2026-09-16 09:03:00'),
(14,	2,	'IA',	'Con gusto te ubico: El área de Servicios Escolares se encuentra en el Edificio A (Rectoría y Administración) de la UPSLP. Requisitos: Solicitud en módulo, Credencial de estudiante vigente, Comprobante de pago Costo: $150.00 MXN Área responsable: Servicios Escolares Lugar: Edificio A - Rectoría y Administración',	'UBICACION',	0,	399,	'2026-09-16 09:03:00'),
(15,	2,	'USUARIO',	'Edificio A - Rectoría y Administración',	'UBICACION',	0,	NULL,	'2026-09-16 09:09:28'),
(16,	2,	'IA',	'Con gusto te ubico: El área de Servicios Escolares se encuentra en el Edificio A (Rectoría y Administración) de la UPSLP. Requisitos: Solicitud en módulo, Credencial de estudiante vigente, Comprobante de pago Costo: $150.00 MXN Área responsable: Servicios Escolares Lugar: Edificio A - Rectoría y Administración',	'UBICACION',	0,	404,	'2026-09-16 09:09:28'),
(17,	2,	'USUARIO',	'Centro de Computo',	'SERVICIO',	0,	NULL,	'2026-09-16 09:11:11'),
(18,	2,	'IA',	'Sobre ese servicio: Los laboratorios de cómputo están disponibles para el desarrollo de prácticas y tareas de los estudiantes, ubicados en el Edificio B. Lugar: Centro de Computo',	'SERVICIO',	0,	404,	'2026-09-16 09:11:11'),
(19,	2,	'USUARIO',	'¿Dónde esta el Edificio B?',	'UBICACION',	0,	NULL,	'2026-09-16 09:11:52'),
(20,	2,	'IA',	'Con gusto te ubico: El área de Servicios Escolares se encuentra en el Edificio A (Rectoría y Administración) de la UPSLP. Requisitos: Solicitud en módulo, Credencial de estudiante vigente, Comprobante de pago Costo: $150.00 MXN Área responsable: Servicios Escolares Lugar: Edificio A - Rectoría y Administración',	'UBICACION',	0,	396,	'2026-09-16 09:11:53'),
(21,	2,	'USUARIO',	'¿Dónde está la biblioteca?',	'UBICACION',	0,	NULL,	'2026-09-16 09:13:31'),
(22,	2,	'IA',	'Con gusto te ubico: La Biblioteca Central de la UPSLP se ubica en el edificio de Biblioteca, con acceso desde el andador principal del campus. Lugar: Biblioteca CID',	'UBICACION',	0,	395,	'2026-09-16 09:13:31'),
(23,	2,	'USUARIO',	'Centro de Nuevas Tecnologías (CENTI',	'GENERAL',	0,	NULL,	'2026-09-16 09:13:49'),
(24,	2,	'IA',	'La UPSLP ofrece las carreras de Ingeniería en Tecnologías de la Información (ITI), Ingeniería Telemática (ITE), Ingeniería en Sistemas Tecnológicos Industriales (ISTI), Ingeniería Mecatrónica (IM) e Ingeniería Industrial (II).',	'GENERAL',	0,	396,	'2026-09-16 09:13:50'),
(25,	2,	'USUARIO',	'Donde esta Centro de Nuevas Tecnologías (CENTI',	'UBICACION',	0,	NULL,	'2026-09-16 09:14:00'),
(26,	2,	'IA',	'Con gusto te ubico: La UPSLP ofrece las carreras de Ingeniería en Tecnologías de la Información (ITI), Ingeniería Telemática (ITE), Ingeniería en Sistemas Tecnológicos Industriales (ISTI), Ingeniería Mecatrónica (IM) e Ingeniería Industrial (II).',	'UBICACION',	0,	396,	'2026-09-16 09:14:00'),
(27,	3,	'USUARIO',	'canchas y area deportiva',	'GENERAL',	0,	NULL,	'2026-09-16 09:19:43'),
(28,	3,	'IA',	'El área de Servicios Escolares se encuentra en el Edificio A (Rectoría y Administración) de la UPSLP. Requisitos: Solicitud en módulo, Credencial de estudiante vigente, Comprobante de pago Costo: $150.00 MXN Área responsable: Servicios Escolares Lugar: Edificio A - Rectoría y Administración',	'GENERAL',	0,	530,	'2026-09-16 09:19:43'),
(29,	3,	'USUARIO',	'¿Dónde está la biblioteca?',	'UBICACION',	0,	NULL,	'2026-09-16 09:26:15'),
(30,	3,	'IA',	'Con gusto te ubico: La Biblioteca Central de la UPSLP se ubica en el edificio de Biblioteca, con acceso desde el andador principal del campus. Lugar: Biblioteca CID',	'UBICACION',	0,	397,	'2026-09-16 09:26:15'),
(31,	3,	'USUARIO',	'Canchas deportivas',	'GENERAL',	0,	NULL,	'2026-09-16 09:26:34'),
(32,	3,	'SISTEMA',	'No cuento con información suficiente, te sugiero consultar directamente con el área correspondiente.',	'GENERAL',	0,	531,	'2026-09-16 09:26:34'),
(33,	3,	'USUARIO',	'Laboratorios de Computo',	'UBICACION',	0,	NULL,	'2026-09-16 09:28:26'),
(34,	3,	'IA',	'Con gusto te ubico: Los laboratorios de cómputo están disponibles para el desarrollo de prácticas y tareas de los estudiantes, ubicados en el Edificio B. Lugar: Centro de Computo',	'UBICACION',	0,	418,	'2026-09-16 09:28:27'),
(35,	3,	'USUARIO',	'Laboratorios de Computo',	'UBICACION',	0,	NULL,	'2026-09-16 09:29:13'),
(36,	3,	'IA',	'Con gusto te ubico: Los laboratorios de cómputo están disponibles de lunes a viernes de 07:00 a 21:00 hrs. Lugar: Centro de Computo',	'UBICACION',	0,	406,	'2026-09-16 09:29:13'),
(37,	3,	'USUARIO',	'Oferta Académica de Ingenierías',	'ACADEMICO',	0,	NULL,	'2026-09-16 09:30:09'),
(38,	3,	'IA',	'Sobre la oferta académica: La UPSLP ofrece las carreras de Ingeniería en Tecnologías de la Información (ITI), Ingeniería Telemática (ITE), Ingeniería en Sistemas Tecnológicos Industriales (ISTI), Ingeniería Mecatrónica (IM) e Ingeniería Industrial (II).',	'ACADEMICO',	0,	397,	'2026-09-16 09:30:09'),
(39,	3,	'USUARIO',	'carreras',	'ACADEMICO',	0,	NULL,	'2026-09-16 09:33:41'),
(40,	3,	'IA',	'Sobre la oferta académica: La UPSLP ofrece las carreras de Ingeniería en Tecnologías de la Información (ITI), Ingeniería en Telecomunicaciones (ITEM), Ingeniería en Sistemas y Tecnologías Industriales (ISTI) y Ingeniería en Tecnologías de Manufactura (ITMA).',	'ACADEMICO',	0,	397,	'2026-09-16 09:33:41'),
(41,	3,	'USUARIO',	'Rectoría y Administración',	'GENERAL',	0,	NULL,	'2026-09-16 09:35:50'),
(42,	3,	'IA',	'El área de Servicios Escolares se encuentra en el Edificio A (Rectoría y Administración) de la UPSLP. Requisitos: Solicitud en módulo, Credencial de estudiante vigente, Comprobante de pago Costo: $150.00 MXN Área responsable: Servicios Escolares Lugar: Rectoría y Administración',	'GENERAL',	0,	396,	'2026-09-16 09:35:51'),
(43,	3,	'USUARIO',	'¿Dónde está servicios escolares?',	'UBICACION',	0,	NULL,	'2026-09-16 09:37:55'),
(44,	3,	'IA',	'Con gusto te ubico: Servicios Escolares atiende de lunes a viernes de 08:00 a 16:00 hrs en el Edificio A. Lugar: Rectoría y Administración',	'UBICACION',	0,	400,	'2026-09-16 09:37:56'),
(45,	3,	'USUARIO',	'¿Dónde está el Centro de computo?',	'UBICACION',	0,	NULL,	'2026-09-16 09:38:20'),
(46,	3,	'IA',	'Con gusto te ubico: Los laboratorios de cómputo están disponibles de lunes a viernes de 07:00 a 21:00 hrs. Lugar: Centro de Computo',	'UBICACION',	0,	399,	'2026-09-16 09:38:20'),
(47,	3,	'USUARIO',	'¿Dónde está CNT?',	'UBICACION',	0,	NULL,	'2026-09-16 09:39:39'),
(48,	3,	'IA',	'Con gusto te ubico: El Laboratorio de Redes se encuentra en el Edificio de CNT, en el segundo piso. Lugar: Laboratorio de Redes',	'UBICACION',	0,	400,	'2026-09-16 09:39:39'),
(49,	3,	'USUARIO',	'¿Dónde está Servicios Escolares?',	'UBICACION',	0,	NULL,	'2026-09-16 09:42:08'),
(50,	3,	'IA',	'Con gusto te ubico: Servicios Escolares atiende de lunes a viernes de 08:00 a 16:00 hrs en el Edificio A. Lugar: Rectoría y Administración',	'UBICACION',	0,	398,	'2026-09-16 09:42:08'),
(51,	3,	'USUARIO',	'¿Qué necesito para solicitar una constancia de estudios?',	'TRAMITE',	0,	NULL,	'2026-09-16 09:42:22'),
(52,	3,	'IA',	'Sobre ese trámite: Para solicitar una constancia de estudios debes acudir a Servicios Escolares con tu credencial de estudiante vigente, llenar la solicitud en el módulo y presentar el comprobante de pago correspondiente. Requisitos: Solicitud en módulo, Credencial de estudiante vigente, Comprobante de pago Costo: $150.00 MXN Área responsable: Servicios Escolares Lugar: Rectoría y Administración',	'TRAMITE',	0,	399,	'2026-09-16 09:42:22'),
(53,	3,	'USUARIO',	'¿Cuánto cuesta una constancia de estudios?',	'TRAMITE',	0,	NULL,	'2026-09-16 09:44:59'),
(54,	3,	'IA',	'Sobre ese trámite: Para solicitar una constancia de estudios debes acudir a Servicios Escolares con tu credencial de estudiante vigente, llenar la solicitud en el módulo y presentar el comprobante de pago correspondiente. Requisitos: Solicitud en módulo, Credencial de estudiante vigente, Comprobante de pago Costo: $150.00 MXN Área responsable: Servicios Escolares Lugar: Rectoría y Administración',	'TRAMITE',	0,	396,	'2026-09-16 09:44:59'),
(55,	4,	'USUARIO',	'¿Dónde puedo encontrar el departamento de servicios escolares?',	'UBICACION',	0,	NULL,	'2026-09-16 09:47:55'),
(56,	4,	'IA',	'Con gusto te ubico: Servicios Escolares atiende de lunes a viernes de 08:00 a 16:00 hrs en el Edificio A. Lugar: Rectoría y Administración',	'UBICACION',	0,	537,	'2026-09-16 09:47:55'),
(57,	4,	'USUARIO',	'¿Cuántos salones de computo hay en la universidad?',	'SERVICIO',	0,	NULL,	'2026-09-16 09:48:43'),
(58,	4,	'IA',	'Sobre ese servicio: La Universidad Politécnica de San Luis Potosí se ubica en Urbano Villalón 500, La Ladrillera, San Luis Potosí. Para dudas específicas puedes acudir directamente al área correspondiente en el Edificio A. Lugar: Rectoría y Administración',	'SERVICIO',	0,	400,	'2026-09-16 09:48:43'),
(59,	4,	'USUARIO',	'¿Qué necesito para solicitar una constancia de estudios?',	'TRAMITE',	0,	NULL,	'2026-09-16 09:49:54'),
(60,	4,	'IA',	'Sobre ese trámite: Para solicitar una constancia de estudios debes acudir a Servicios Escolares con tu credencial de estudiante vigente, llenar la solicitud en el módulo y presentar el comprobante de pago correspondiente. Requisitos: Solicitud en módulo, Credencial de estudiante vigente, Comprobante de pago Costo: $70.00 MXN Área responsable: Servicios Escolares Lugar: Rectoría y Administración',	'TRAMITE',	0,	399,	'2026-09-16 09:49:54'),
(61,	3,	'USUARIO',	'¿Qué necesito para solicitar una constancia de estudios?',	'TRAMITE',	0,	NULL,	'2026-09-16 09:50:03'),
(62,	3,	'IA',	'Sobre ese trámite: Para solicitar una constancia de estudios debes acudir a Servicios Escolares con tu credencial de estudiante vigente, llenar la solicitud en el módulo y presentar el comprobante de pago correspondiente. Requisitos: Solicitud en módulo, Credencial de estudiante vigente, Comprobante de pago Costo: $70.00 MXN Área responsable: Servicios Escolares Lugar: Rectoría y Administración',	'TRAMITE',	0,	398,	'2026-09-16 09:50:03'),
(63,	3,	'USUARIO',	'horario servicios',	'SERVICIO',	0,	NULL,	'2026-09-16 09:51:54'),
(64,	3,	'IA',	'Sobre ese servicio: Servicios Escolares atiende de lunes a viernes de 08:00 a 16:00 hrs en el Edificio A. Lugar: Rectoría y Administración',	'SERVICIO',	0,	396,	'2026-09-16 09:51:54'),
(65,	4,	'USUARIO',	'¿La universidad cuenta con biblioteca?',	'TRAMITE',	0,	NULL,	'2026-09-16 09:52:45'),
(66,	4,	'IA',	'Sobre ese trámite: La Universidad Politécnica de San Luis Potosí se ubica en Urbano Villalón 500, La Ladrillera, San Luis Potosí. Para dudas específicas puedes acudir directamente al área correspondiente en el Edificio A. Lugar: Rectoría y Administración',	'TRAMITE',	0,	398,	'2026-09-16 09:52:45'),
(67,	3,	'USUARIO',	'horario servicios',	'SERVICIO',	0,	NULL,	'2026-09-16 09:52:48'),
(68,	3,	'IA',	'Sobre ese servicio: Servicios Escolares atiende de lunes a viernes de 08:00 a 18:00 hrs en el Edificio A. Lugar: Rectoría y Administración',	'SERVICIO',	0,	395,	'2026-09-16 09:52:48'),
(69,	4,	'USUARIO',	'¿Dónde se encuentra la cafetería de la universidad?',	'UBICACION',	0,	NULL,	'2026-09-16 09:53:34'),
(70,	4,	'IA',	'Con gusto te ubico: La Universidad Politécnica de San Luis Potosí se ubica en Urbano Villalón 500, La Ladrillera, San Luis Potosí. Para dudas específicas puedes acudir directamente al área correspondiente en el Edificio A. Lugar: Rectoría y Administración',	'UBICACION',	0,	395,	'2026-09-16 09:53:34'),
(71,	4,	'USUARIO',	'¿Dónde se encuentra CADI?',	'UBICACION',	0,	NULL,	'2026-09-16 09:57:51'),
(72,	4,	'IA',	'Con gusto te ubico: El área de Servicios Escolares se encuentra cerca de rectoría y administración de la UPSLP. Requisitos: Solicitud en módulo, Credencial de estudiante vigente, Comprobante de pago Costo: $70.00 MXN Área responsable: Servicios Escolares y Tesoreria Lugar: Rectoría y Administración',	'UBICACION',	0,	399,	'2026-09-16 09:57:52'),
(73,	5,	'USUARIO',	'¿Qué necesito para solicitar una constancia de estudios?',	'TRAMITE',	0,	NULL,	'2026-09-16 15:09:29'),
(74,	5,	'IA',	'Sobre ese trámite: Para solicitar una constancia de estudios debes acudir a Servicios Escolares con tu credencial de estudiante vigente, llenar la solicitud en el módulo y presentar el comprobante de pago correspondiente. Requisitos: Solicitud en módulo, Credencial de estudiante vigente, Comprobante de pago Costo: $70.00 MXN Área responsable: Servicios Escolares y Tesoreria Lugar: Rectoría y Administración',	'TRAMITE',	0,	524,	'2026-09-16 15:09:29'),
(75,	6,	'USUARIO',	'¿Dónde está la biblioteca?',	'UBICACION',	0,	NULL,	'2026-09-16 18:11:48'),
(76,	6,	'IA',	'Con gusto te ubico: La Biblioteca Central de la UPSLP se ubica en el edificio de Biblioteca, con acceso desde el andador principal del campus. Lugar: Biblioteca CID',	'UBICACION',	0,	530,	'2026-09-16 18:11:48'),
(77,	7,	'USUARIO',	'¿dónde está el CNT?',	'UBICACION',	0,	NULL,	'2026-09-16 21:49:05'),
(78,	7,	'IA',	'Con gusto te ubico: El Centro de Nuevas Tecnologías (CNT) alberga los laboratorios especializados de ingeniería y desarrollo, incluido el Laboratorio de Redes. Lugar: Centro de Nuevas Tecnolgias (CNT)',	'UBICACION',	0,	545,	'2026-09-16 21:49:05'),
(79,	7,	'USUARIO',	'¿Donde esta CADI?',	'UBICACION',	0,	NULL,	'2026-09-16 21:50:43'),
(80,	7,	'IA',	'Con gusto te ubico: El CADI es el edificio donde los alumnos pueden fortalecer y aprender habilidades del idioma inglés de forma autodidacta. Lugar: CADI - Centro de Autoaprendizaje del Idioma Inglés',	'UBICACION',	0,	408,	'2026-09-16 21:50:43'),
(81,	7,	'USUARIO',	'donde esta el gym',	'UBICACION',	0,	NULL,	'2026-09-16 21:51:06'),
(82,	7,	'IA',	'Con gusto te ubico: El GYM es el área deportiva donde los estudiantes pueden practicar baloncesto, voleibol, kárate, box y otras actividades físicas. Lugar: GYM - Gimnasio',	'UBICACION',	0,	413,	'2026-09-16 21:51:06'),
(83,	7,	'USUARIO',	'donde esta el uae2',	'UBICACION',	0,	NULL,	'2026-09-16 21:51:36'),
(84,	7,	'IA',	'Con gusto te ubico: El UAE2 es un edificio con salones donde los estudiantes realizan sus actividades escolares diarias. Lugar: UAE2 - Unidad Académica de Estudiantes 2',	'UBICACION',	0,	408,	'2026-09-16 21:51:36'),
(85,	8,	'USUARIO',	'¿Qué carreras ofrece la UPSLP?',	'ACADEMICO',	0,	NULL,	'2026-09-16 22:18:50'),
(86,	8,	'IA',	'Sobre la oferta académica: La UPSLP ofrece las carreras de Ingeniería en Tecnologías de la Información (ITI), Ingeniería en Telecomunicaciones (ITEM), Ingeniería en Sistemas y Tecnologías Industriales (ISTI) y Ingeniería en Tecnologías de Manufactura (ITMA).',	'ACADEMICO',	0,	66,	'2026-09-16 22:18:50'),
(87,	8,	'USUARIO',	'¿Dónde está la biblioteca?',	'UBICACION',	0,	NULL,	'2026-09-16 22:19:03'),
(88,	8,	'IA',	'Con gusto te ubico: La Biblioteca Central de la UPSLP se ubica en el edificio de Biblioteca, con acceso desde el andador principal del campus. Lugar: Biblioteca CID',	'UBICACION',	0,	20,	'2026-09-16 22:19:03'),
(89,	8,	'USUARIO',	'donde esta el gym',	'UBICACION',	0,	NULL,	'2026-09-16 22:21:29'),
(90,	8,	'IA',	'Con gusto te ubico: El GYM es el área deportiva donde los estudiantes pueden practicar baloncesto, voleibol, kárate, box y otras actividades físicas. Lugar: GYM - Gimnasio',	'UBICACION',	0,	10,	'2026-09-16 22:21:29'),
(91,	9,	'USUARIO',	'donde esta cnt',	'UBICACION',	0,	NULL,	'2026-09-16 22:21:49'),
(92,	9,	'IA',	'Con gusto te ubico: El Centro de Nuevas Tecnologías (CNT) alberga los laboratorios especializados de ingeniería y desarrollo, incluido el Laboratorio de Redes. Lugar: Centro de Nuevas Tecnolgias (CNT)',	'UBICACION',	0,	15,	'2026-09-16 22:21:49'),
(93,	9,	'USUARIO',	'donde esta servicios escolares',	'UBICACION',	0,	NULL,	'2026-09-16 22:23:43'),
(94,	9,	'IA',	'Con gusto te ubico: El área de Servicios Escolares se encuentra cerca de rectoría y administración de la UPSLP. Requisitos: Solicitud en módulo, Credencial de estudiante vigente, Comprobante de pago Costo: $70.00 MXN Área responsable: Servicios Escolares y Tesoreria Lugar: Rectoría y Administración',	'UBICACION',	0,	17,	'2026-09-16 22:23:43'),
(95,	9,	'USUARIO',	'constancia de estudios',	'TRAMITE',	0,	NULL,	'2026-09-16 22:24:01'),
(96,	9,	'IA',	'Sobre ese trámite: Para solicitar una constancia de estudios debes acudir a Servicios Escolares con tu credencial de estudiante vigente, llenar la solicitud en el módulo y presentar el comprobante de pago correspondiente. Requisitos: Solicitud en módulo, Credencial de estudiante vigente, Comprobante de pago Costo: $70.00 MXN Área responsable: Servicios Escolares y Tesoreria Lugar: Rectoría y Administración',	'TRAMITE',	0,	21,	'2026-09-16 22:24:01'),
(97,	9,	'USUARIO',	'kardex',	'TRAMITE',	0,	NULL,	'2026-09-16 22:24:15'),
(98,	9,	'SISTEMA',	'No cuento con información suficiente, te sugiero consultar directamente con el área correspondiente.',	'TRAMITE',	0,	27,	'2026-09-16 22:24:15'),
(99,	10,	'USUARIO',	'donde esta el uae1',	'UBICACION',	0,	NULL,	'2026-09-17 02:11:26'),
(100,	10,	'IA',	'Con gusto te ubico: El UAE1 es un edificio con salones donde los estudiantes realizan sus actividades escolares diarias. Lugar: UAE1 - Unidad Académica de Estudiantes 1',	'UBICACION',	0,	550,	'2026-09-17 02:11:26'),
(101,	10,	'USUARIO',	'¿Qué necesito para solicitar una constancia de estudios?',	'TRAMITE',	0,	NULL,	'2026-09-17 02:11:38'),
(102,	10,	'IA',	'Sobre ese trámite: Para solicitar una constancia de estudios debes acudir a Servicios Escolares con tu credencial de estudiante vigente, llenar la solicitud en el módulo y presentar el comprobante de pago correspondiente. Requisitos: Solicitud en módulo, Credencial de estudiante vigente, Comprobante de pago Costo: $70.00 MXN Área responsable: Servicios Escolares y Tesoreria Lugar: Rectoría y Administración',	'TRAMITE',	0,	414,	'2026-09-17 02:11:38'),
(103,	10,	'USUARIO',	'¿Cuál es el horario de la biblioteca?',	'SERVICIO',	0,	NULL,	'2026-09-17 02:11:45'),
(104,	10,	'IA',	'Sobre ese servicio: La biblioteca de la UPSLP ofrece servicio de lunes a viernes en un horario continuo de 08:00 a 19:00 hrs. Lugar: Biblioteca CID',	'SERVICIO',	0,	413,	'2026-09-17 02:11:45'),
(105,	10,	'USUARIO',	'¿Qué servicios ofrece la universidad?',	'SERVICIO',	0,	NULL,	'2026-09-17 02:11:53'),
(106,	10,	'IA',	'Sobre ese servicio: La Universidad Politécnica de San Luis Potosí se ubica en Urbano Villalón 500, La Ladrillera, San Luis Potosí. Para dudas específicas puedes acudir directamente al área correspondiente en el Edificio A. Lugar: Rectoría y Administración',	'SERVICIO',	0,	413,	'2026-09-17 02:11:54'),
(107,	10,	'USUARIO',	'hola',	'GENERAL',	0,	NULL,	'2026-09-17 02:24:05'),
(108,	10,	'SISTEMA',	'No cuento con información suficiente, te sugiero consultar directamente con el área correspondiente.',	'GENERAL',	0,	275,	'2026-09-17 02:24:05'),
(109,	10,	'USUARIO',	'donde esta el edificio de cnt',	'UBICACION',	0,	NULL,	'2026-09-17 02:24:23'),
(110,	10,	'IA',	'Con gusto te ubico: El Centro de Nuevas Tecnologías (CNT) alberga los laboratorios especializados de ingeniería y desarrollo, incluido el Laboratorio de Redes. Lugar: Centro de Nuevas Tecnolgias (CNT)',	'UBICACION',	0,	592,	'2026-09-17 02:24:23'),
(111,	10,	'USUARIO',	'¿dónde está la biblioteca?',	'UBICACION',	0,	NULL,	'2026-09-17 02:25:47'),
(112,	10,	'IA',	'Con gusto te ubico: La Biblioteca Central de la UPSLP se ubica en el edificio de Biblioteca, con acceso desde el andador principal del campus. Lugar: Biblioteca CID',	'UBICACION',	0,	553,	'2026-09-17 02:25:47'),
(113,	10,	'USUARIO',	'donde esta el uae3',	'UBICACION',	0,	NULL,	'2026-09-17 02:31:54'),
(114,	10,	'IA',	'Con gusto te ubico: El UAE3 es un edificio con salones donde los estudiantes realizan sus actividades escolares diarias. Lugar: UAE3 - Unidad Académica de Estudiantes 3',	'UBICACION',	0,	194,	'2026-09-17 02:31:54'),
(115,	10,	'USUARIO',	'donde esta el gym',	'UBICACION',	0,	NULL,	'2026-09-17 02:38:36'),
(116,	10,	'IA',	'El gimnasio se encuentra en la ubicación',	'UBICACION',	543,	2283,	'2026-09-17 02:38:39'),
(117,	10,	'USUARIO',	'donde esta cadi',	'UBICACION',	0,	NULL,	'2026-09-17 02:39:51'),
(118,	10,	'IA',	'El CADI (Centro de Autoaprendizaje',	'UBICACION',	553,	2384,	'2026-09-17 02:39:54'),
(119,	10,	'USUARIO',	'donde esta el cajero bbva',	'UBICACION',	0,	NULL,	'2026-09-17 02:43:27'),
(120,	10,	'IA',	'El cajero automático de BBVA se encuentra ubicado dentro del CNI (Centro de Negocios Internacionales).',	'UBICACION',	536,	2479,	'2026-09-17 02:43:29'),
(121,	10,	'USUARIO',	'donde se encuentra el gym',	'UBICACION',	0,	NULL,	'2026-09-17 02:43:45'),
(122,	10,	'IA',	'El gimnasio se ubica en el área designada como GYM - Gimnasio. Es el espacio deportivo de la universidad donde los estudiantes pueden practicar actividades físicas como baloncesto, voleibol, kárate y box.',	'UBICACION',	690,	2265,	'2026-09-17 02:43:47'),
(123,	10,	'USUARIO',	'como saco una constancia de estudios',	'TRAMITE',	0,	NULL,	'2026-09-17 02:44:14'),
(124,	10,	'IA',	'Para solicitar una constancia de estudios debes acudir al área de Rectoría y Administración con tu credencial de estudiante vigente. Ahí deberás llenar la solicitud en el módulo de Servicios Escolares y presentar el comprobante de pago correspondiente. El costo del trámite es de $70.00 MXN y es gestionado por Servicios Escolares y Tesorería.',	'TRAMITE',	648,	2704,	'2026-09-17 02:44:16'),
(125,	11,	'USUARIO',	'constancia',	'TRAMITE',	0,	NULL,	'2026-09-17 05:02:54'),
(126,	11,	'IA',	'Sobre ese trámite: Para solicitar una constancia de estudios debes acudir a Servicios Escolares con tu credencial de estudiante vigente, llenar la solicitud en el módulo y presentar el comprobante de pago correspondiente. Requisitos: Solicitud en módulo, Credencial de estudiante vigente, Comprobante de pago Costo: $70.00 MXN Área responsable: Servicios Escolares y Tesoreria Lugar: Rectoría y Administración',	'TRAMITE',	0,	912,	'2026-09-17 05:02:54'),
(127,	11,	'USUARIO',	'¿Dónde está la biblioteca?',	'UBICACION',	0,	NULL,	'2026-09-17 05:03:08'),
(128,	11,	'IA',	'La Biblioteca Central de la UPSLP se ubica en el edificio de Biblioteca (Biblioteca CID). Puedes acceder a ella directamente desde el andador principal del campus.',	'UBICACION',	696,	2127,	'2026-09-17 05:03:10'),
(129,	12,	'USUARIO',	'¿Dónde está la biblioteca?',	'UBICACION',	0,	NULL,	'2026-09-17 05:10:55'),
(130,	12,	'IA',	'La Biblioteca Central de la UPSLP se ubica en el edificio de Biblioteca (Biblioteca CID), con acceso desde el andador principal del campus.',	'UBICACION',	696,	2821,	'2026-09-17 05:10:57');

DROP TABLE IF EXISTS `horario`;
CREATE TABLE `horario` (
  `id_horario` int NOT NULL AUTO_INCREMENT,
  `dias` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `hora_apertura` time NOT NULL,
  `hora_cierre` time NOT NULL,
  `id_lugar` int DEFAULT NULL,
  `id_servicio` int DEFAULT NULL,
  PRIMARY KEY (`id_horario`),
  KEY `fk_horario_lugar` (`id_lugar`),
  KEY `fk_horario_servicio` (`id_servicio`),
  CONSTRAINT `fk_horario_lugar` FOREIGN KEY (`id_lugar`) REFERENCES `lugar` (`id_lugar`) ON DELETE CASCADE,
  CONSTRAINT `fk_horario_servicio` FOREIGN KEY (`id_servicio`) REFERENCES `servicio` (`id_servicio`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `horario` (`id_horario`, `dias`, `hora_apertura`, `hora_cierre`, `id_lugar`, `id_servicio`) VALUES
(1,	'Lunes a Viernes',	'08:00:00',	'19:00:00',	3,	1),
(2,	'Lunes a Viernes',	'08:00:00',	'16:00:00',	1,	2),
(3,	'Lunes a Viernes',	'07:00:00',	'21:00:00',	2,	3),
(4,	'Lunes a Viernes',	'07:30:00',	'18:00:00',	6,	4),
(5,	'Lunes a Sábado',	'07:00:00',	'20:00:00',	7,	5);

DROP TABLE IF EXISTS `lugar`;
CREATE TABLE `lugar` (
  `id_lugar` int NOT NULL AUTO_INCREMENT,
  `nombre` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `latitud` decimal(10,8) NOT NULL,
  `longitud` decimal(11,8) NOT NULL,
  `url_mapa` text COLLATE utf8mb4_unicode_ci,
  `descripcion` text COLLATE utf8mb4_unicode_ci,
  PRIMARY KEY (`id_lugar`),
  FULLTEXT KEY `ft_lugar` (`nombre`,`descripcion`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `lugar` (`id_lugar`, `nombre`, `latitud`, `longitud`, `url_mapa`, `descripcion`) VALUES
(1,	'Rectoría y Administración',	22.12406297,	-100.98377309,	'https://maps.google.com/?q=22.12406297,-100.98377309',	'Oficinas administrativas, Rectoría y Servicios Escolares'),
(2,	'Centro de Computo',	22.12246497,	-100.98419085,	'https://maps.google.com/?q=22.12246497306251, -100.98419085444233\r\n',	'Aulas de clase y laboratorios de cómputo'),
(3,	'Biblioteca CID',	22.12293557,	-100.98432416,	'https://maps.google.com/?q=22.122935574741206, -100.98432415965344\r\n',	'Acervo bibliográfico, salas de estudio y consulta'),
(4,	'Centro de Nuevas Tecnolgias (CNT)',	22.12203442,	-100.98420527,	'https://maps.google.com/?q=22.122034421209637, -100.9842052657722\r\n',	'Laboratorios especializados de ingeniería y desarrollo'),
(5,	'Laboratorio de Redes',	22.12203442,	-100.98420527,	'https://maps.google.com/?q=22.122034421209637, -100.9842052657722\r\n',	'Laboratorio de redes y telecomunicaciones, Edificio B, segundo piso'),
(6,	'Cafetería Up',	22.12303904,	-100.98409718,	'https://maps.google.com/?q=22.123039040168145, -100.98409718044938\r\n',	'Servicio de alimentos para la comunidad universitaria'),
(7,	'Canchas y Área Deportiva',	22.12192912,	-100.98350416,	'https://maps.google.com/?q=22.12192912427621, -100.98350415978462\r\n',	'Canchas de fútbol, básquetbol y área de actividades deportivas'),
(8,	'Auditorio',	22.12054137,	-100.98407962,	'https://maps.google.com/?q=22.120541369949272, -100.98407961927285',	'Espacio para conferencias, ceremonias y eventos académicos'),
(9,	'ASA',	22.12337632,	-100.98351031,	'https://maps.google.com/?q=22.12337632,-100.98351031',	'Edificio donde se realizan conferencias y promociones'),
(10,	'CNI - Centro de Negocios Internacionales',	22.12352676,	-100.98298102,	'https://maps.google.com/?q=22.12352676,-100.98298102',	'Edificio donde se simulan tratos de negocios, propuestas de trabajo, entrevistas, etc.'),
(11,	'CADI - Centro de Autoaprendizaje del Idioma Inglés',	22.12337304,	-100.98275115,	'https://maps.google.com/?q=22.12337304,-100.98275115',	'Edificio donde los alumnos pueden fortalecer y aprender habilidades del idioma inglés'),
(12,	'CMA - Centro de Manufactura Avanzada',	22.12353099,	-100.98227619,	'https://maps.google.com/?q=22.12353099,-100.98227619',	'Edificio donde los estudiantes de manufactura realizan actividades y cursos extracurriculares'),
(13,	'UAM1 - Unidad Académica de Maestros 1',	22.12340314,	-100.98490255,	'https://maps.google.com/?q=22.12340314,-100.98490255',	'Edificio donde los maestros administran investigación, gestión curricular y atención al alumno. Aquí se encuentra la coordinación de ITI/ITEM'),
(14,	'UAM2 - Unidad Académica de Maestros 2',	22.12275865,	-100.98478046,	'https://maps.google.com/?q=22.12275865,-100.98478046',	'Edificio donde los maestros administran investigación, gestión curricular y atención al alumno'),
(15,	'UAE1 - Unidad Académica de Estudiantes 1',	22.12319211,	-100.98525385,	'https://maps.google.com/?q=22.12319211,-100.98525385',	'Edificio con salones donde los estudiantes realizan sus actividades escolares diarias'),
(16,	'UAE2 - Unidad Académica de Estudiantes 2',	22.12281195,	-100.98528603,	'https://maps.google.com/?q=22.12281195,-100.98528603',	'Edificio con salones donde los estudiantes realizan sus actividades escolares diarias'),
(17,	'UAE3 - Unidad Académica de Estudiantes 3',	22.12206653,	-100.98504464,	'https://maps.google.com/?q=22.12206653,-100.98504464',	'Edificio con salones donde los estudiantes realizan sus actividades escolares diarias'),
(18,	'UAE4 - Unidad Académica de Estudiantes 4',	22.12169878,	-100.98504732,	'https://maps.google.com/?q=22.12169878,-100.98504732',	'Edificio con salones donde los estudiantes realizan sus actividades escolares diarias'),
(19,	'GYM - Gimnasio',	22.12048373,	-100.98391274,	'https://maps.google.com/?q=22.12048373,-100.98391274',	'Área deportiva donde los estudiantes pueden realizar baloncesto, voleibol, kárate, box y otras actividades físicas');

DROP TABLE IF EXISTS `pregunta_frecuente`;
CREATE TABLE `pregunta_frecuente` (
  `id_faq` int NOT NULL AUTO_INCREMENT,
  `pregunta` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `respuesta` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `id_categoria` int DEFAULT NULL,
  `orden` int DEFAULT '0',
  PRIMARY KEY (`id_faq`),
  KEY `fk_faq_categoria` (`id_categoria`),
  FULLTEXT KEY `ft_faq` (`pregunta`,`respuesta`),
  CONSTRAINT `fk_faq_categoria` FOREIGN KEY (`id_categoria`) REFERENCES `categoria` (`id_categoria`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `pregunta_frecuente` (`id_faq`, `pregunta`, `respuesta`, `id_categoria`, `orden`) VALUES
(1,	'¿Cuánto cuesta una constancia de estudios?',	'La constancia de estudios tiene un costo de $70.00 MXN y se solicita en el área de tesorería y después en ventanilla de Servicios Escolares.',	2,	1),
(2,	'¿Dónde está Servicios Escolares?',	'Servicios Escolares se encuentra en el Edificio A (Rectoría y Administración).',	1,	2),
(3,	'¿Qué carreras ofrece la UPSLP?',	'La UPSLP ofrece cuatro ingenierías (ITI, ITEM, ISTI e ITMA) y dos licenciaturas (LAG y LMI).',	5,	3),
(4,	'¿A qué hora abre la biblioteca?',	'La biblioteca abre de lunes a viernes de 08:00 a 19:00 hrs.',	4,	4),
(5,	'¿Cómo repongo mi credencial?',	'Debes acudir a Servicios Escolares con identificación oficial, una fotografía infantil y el pago de derechos ($200.00 MXN).',	2,	5);

DROP TABLE IF EXISTS `servicio`;
CREATE TABLE `servicio` (
  `id_servicio` int NOT NULL AUTO_INCREMENT,
  `nombre` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `descripcion` text COLLATE utf8mb4_unicode_ci,
  `id_lugar` int DEFAULT NULL,
  PRIMARY KEY (`id_servicio`),
  KEY `fk_servicio_lugar` (`id_lugar`),
  FULLTEXT KEY `ft_servicio` (`nombre`,`descripcion`),
  CONSTRAINT `fk_servicio_lugar` FOREIGN KEY (`id_lugar`) REFERENCES `lugar` (`id_lugar`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `servicio` (`id_servicio`, `nombre`, `descripcion`, `id_lugar`) VALUES
(1,	'Préstamo de Libros y Material',	'Préstamo en sala y a domicilio de material bibliográfico.',	3),
(2,	'Atención de Servicios Escolares',	'Trámites de constancias, certificados, credenciales y kardex.',	1),
(3,	'Acceso a Laboratorios de Cómputo',	'Uso de equipos de cómputo para desarrollo de prácticas y tareas.',	2),
(4,	'Servicio de Cafetería',	'Venta de alimentos y bebidas para estudiantes y personal.',	6),
(5,	'Actividades Deportivas',	'Inscripción a equipos representativos y uso de canchas.',	7),
(6,	'Tutorías Académicas',	'Acompañamiento académico personalizado por parte de docentes tutores.',	2);

DROP TABLE IF EXISTS `sesion_chat`;
CREATE TABLE `sesion_chat` (
  `id_sesion` int NOT NULL AUTO_INCREMENT,
  `origen` enum('WEB','TELEGRAM','OPENCLAW','NANOCLAW') COLLATE utf8mb4_unicode_ci NOT NULL,
  `telegram_chat_id` bigint DEFAULT NULL,
  `token_sesion` varchar(64) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `fecha_inicio` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_sesion`),
  KEY `idx_token_sesion` (`token_sesion`),
  KEY `idx_telegram_chat` (`telegram_chat_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `sesion_chat` (`id_sesion`, `origen`, `telegram_chat_id`, `token_sesion`, `fecha_inicio`) VALUES
(1,	'WEB',	NULL,	'web-1789548936927-370z2rpm',	'2026-09-16 08:55:37'),
(2,	'WEB',	NULL,	'web-1789549362403-o44on8o3',	'2026-09-16 09:02:42'),
(3,	'WEB',	NULL,	'web-1789550382823-ull1g46h',	'2026-09-16 09:19:43'),
(4,	'WEB',	NULL,	'web-1789552074920-g3yyuvdg',	'2026-09-16 09:47:55'),
(5,	'WEB',	NULL,	'web-1789571369275-sff7b8lx',	'2026-09-16 15:09:29'),
(6,	'WEB',	NULL,	'web-1789582306661-k3ws50a8',	'2026-09-16 18:11:47'),
(7,	'WEB',	NULL,	'web-1789595343409-trxwabpo',	'2026-09-16 21:49:04'),
(8,	'WEB',	NULL,	'web-1789597128634-51oorkem',	'2026-09-16 22:18:49'),
(9,	'WEB',	NULL,	'web-1789597308506-po65yuvc',	'2026-09-16 22:21:49'),
(10,	'WEB',	NULL,	'web-1789611084453-m620w1g2',	'2026-09-17 02:11:25'),
(11,	'WEB',	NULL,	'web-1789621373587-bdv91bjx',	'2026-09-17 05:02:53'),
(12,	'WEB',	NULL,	'web-1789621854494-lib03u3s',	'2026-09-17 05:10:54');

DROP TABLE IF EXISTS `tramite`;
CREATE TABLE `tramite` (
  `id_tramite` int NOT NULL AUTO_INCREMENT,
  `titulo` varchar(150) COLLATE utf8mb4_unicode_ci NOT NULL,
  `descripcion` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `requisitos` text COLLATE utf8mb4_unicode_ci,
  `costo` decimal(8,2) DEFAULT '0.00',
  `area_responsable` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `id_lugar` int DEFAULT NULL,
  PRIMARY KEY (`id_tramite`),
  KEY `fk_tramite_lugar` (`id_lugar`),
  FULLTEXT KEY `ft_tramite` (`titulo`,`descripcion`,`requisitos`),
  CONSTRAINT `fk_tramite_lugar` FOREIGN KEY (`id_lugar`) REFERENCES `lugar` (`id_lugar`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `tramite` (`id_tramite`, `titulo`, `descripcion`, `requisitos`, `costo`, `area_responsable`, `id_lugar`) VALUES
(1,	'Constancia de Estudios',	'Expedición de documento oficial que acredita la inscripción del alumno en el ciclo escolar vigente.',	'Solicitud en módulo, Credencial de estudiante vigente, Comprobante de pago',	70.00,	'Servicios Escolares y Tesoreria',	1),
(2,	'Inscripción y Reinscripción',	'Proceso de registro de asignaturas para el periodo lectivo.',	'Ficha de pago cubierta, Liberación de adeudos en biblioteca y laboratorios, Evaluaciones docentes completadas',	0.00,	'Servicios Escolares',	1),
(3,	'Credencial de Estudiante (Reposición)',	'Solicitud de nueva credencial por robo o extravío.',	'Pago de derechos, Identificación oficial, Fotografía infantil',	120.00,	'Servicios Escolares',	1),
(4,	'Kardex o Historial Académico',	'Documento que concentra las calificaciones obtenidas por el alumno a lo largo de su trayectoria.',	'Solicitud en ventanilla, Credencial vigente, Comprobante de pago',	120.00,	'Servicios Escolares',	1),
(5,	'Baja Temporal de Asignatura',	'Solicitud para darse de baja de una o varias materias dentro del periodo establecido.',	'Solicitud firmada por el tutor, Vo.Bo. del director de carrera, Estar dentro del plazo del calendario escolar',	0.00,	'Servicios Escolares',	1),
(6,	'Servicio Social',	'Registro y liberación del servicio social obligatorio.',	'Haber cubierto el 70% de créditos, Carta de aceptación de la institución receptora, Formato de registro',	0.00,	'Vinculación',	1);

DROP TABLE IF EXISTS `usuario_admin`;
CREATE TABLE `usuario_admin` (
  `id_admin` int NOT NULL AUTO_INCREMENT,
  `nombre` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `password_hash` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `rol` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT 'Editor',
  `fecha_alta` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_admin`),
  UNIQUE KEY `uq_admin_email` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `usuario_admin` (`id_admin`, `nombre`, `email`, `password_hash`, `rol`, `fecha_alta`) VALUES
(1,	'Administrador UniGuide',	'admin@upslp.edu.mx',	'REEMPLAZAR_CON_HASH_BCRYPT',	'Admin',	'2026-09-16 08:45:16');

-- 2026-09-17 05:20:47 UTC
