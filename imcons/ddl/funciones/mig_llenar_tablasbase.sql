CREATE OR REPLACE FUNCTION keplersc.mig_llenar_tablasbase()
 RETURNS text
 LANGUAGE plpgsql
AS $function$
declare
	--Variables de uso general 
	strValor text = '';
	intValor int = 0;
	expSql text = '';


	--Variables de retorno
	resultado text;

begin
	--kdstatustabulacion
	truncate keplersc.kdstatustabulacion;
	INSERT INTO keplersc.kdstatustabulacion VALUES ('A', 'Abierto');
	INSERT INTO keplersc.kdstatustabulacion VALUES ('C', 'Cerrado');
	
	--catpuntos
	truncate keplersc.catpuntos;
	INSERT INTO keplersc.catpuntos VALUES ('L', 'Lavados');
	INSERT INTO keplersc.catpuntos VALUES ('P', 'Presupuestar');
	INSERT INTO keplersc.catpuntos VALUES ('Q', 'Previas');
	INSERT INTO keplersc.catpuntos VALUES ('I', 'Internas');
	INSERT INTO keplersc.catpuntos VALUES ('G', 'Garantias');
	INSERT INTO keplersc.catpuntos VALUES ('H', 'Hojalaterias');
	INSERT INTO keplersc.catpuntos VALUES ('S', 'Servicio');
	INSERT INTO keplersc.catpuntos VALUES ('F', 'Fallas');
	INSERT INTO keplersc.catpuntos VALUES ('R', 'Reclamaciones');


	--kdstatuspun
	truncate keplersc.kdstatuspun;
	INSERT INTO keplersc.kdstatuspun VALUES ('P', 'Pendiente');
	INSERT INTO keplersc.kdstatuspun VALUES ('A', 'Activo');
	INSERT INTO keplersc.kdstatuspun VALUES ('S', 'Suspendido');
	INSERT INTO keplersc.kdstatuspun VALUES ('T', 'Terminado');
	INSERT INTO keplersc.kdstatuspun VALUES ('N', 'No autorizado');

	--kdtoper
	truncate keplersc.kdtoper;
	INSERT INTO keplersc.kdtoper VALUES ('99', 'OPERARIO HYP', '0');
	INSERT INTO keplersc.kdtoper VALUES ('DT', 'DETALLADOR', '0');
	INSERT INTO keplersc.kdtoper VALUES ('FG', 'FALLAS Y GARANTIAS', '0');
	INSERT INTO keplersc.kdtoper VALUES ('H', 'HOJALATERIA', '0');
	INSERT INTO keplersc.kdtoper VALUES ('HYP', 'OPERARIO HYP INMOTION', '0');
	INSERT INTO keplersc.kdtoper VALUES ('L', 'LAVADO', '0');
	INSERT INTO keplersc.kdtoper VALUES ('M', 'MECANICA', '0');
	INSERT INTO keplersc.kdtoper VALUES ('PREV', 'PREVIAS', '0');
	INSERT INTO keplersc.kdtoper VALUES ('TEC', 'TECNICO', '0');

	
	--kdpuntop
	truncate keplersc.kdpuntop;
	INSERT INTO keplersc.kdpuntop VALUES ('F', 'FG');
	INSERT INTO keplersc.kdpuntop VALUES ('F', 'M');
	INSERT INTO keplersc.kdpuntop VALUES ('G', 'FG');
	INSERT INTO keplersc.kdpuntop VALUES ('G', 'M');
	INSERT INTO keplersc.kdpuntop VALUES ('H', 'FG');
	INSERT INTO keplersc.kdpuntop VALUES ('H', 'H');
	INSERT INTO keplersc.kdpuntop VALUES ('H', 'M');
	INSERT INTO keplersc.kdpuntop VALUES ('I', 'DT');
	INSERT INTO keplersc.kdpuntop VALUES ('I', 'L');
	INSERT INTO keplersc.kdpuntop VALUES ('I', 'M');
	INSERT INTO keplersc.kdpuntop VALUES ('L', 'L');
	INSERT INTO keplersc.kdpuntop VALUES ('P', 'FG');
	INSERT INTO keplersc.kdpuntop VALUES ('P', 'M');
	INSERT INTO keplersc.kdpuntop VALUES ('Q', 'PREV');
	INSERT INTO keplersc.kdpuntop VALUES ('R', 'DT');
	INSERT INTO keplersc.kdpuntop VALUES ('R', 'FG');
	INSERT INTO keplersc.kdpuntop VALUES ('R', 'L');
	INSERT INTO keplersc.kdpuntop VALUES ('R', 'M');
	INSERT INTO keplersc.kdpuntop VALUES ('R', 'PREV');
	INSERT INTO keplersc.kdpuntop VALUES ('S', 'M');

/*
	--citas autorizacionpuntos
	truncate keplersc.citasautorizacionpuntos;
	INSERT INTO keplersc.citasautorizacionpuntos VALUES ('N', 'S');
	INSERT INTO keplersc.citasautorizacionpuntos VALUES ('N', 'F');
	INSERT INTO keplersc.citasautorizacionpuntos VALUES ('N', 'H');
	INSERT INTO keplersc.citasautorizacionpuntos VALUES ('N', 'P');
	INSERT INTO keplersc.citasautorizacionpuntos VALUES ('N', 'L');
	INSERT INTO keplersc.citasautorizacionpuntos VALUES ('G', 'G');
	INSERT INTO keplersc.citasautorizacionpuntos VALUES ('G', 'L');
	INSERT INTO keplersc.citasautorizacionpuntos VALUES ('I', 'I');
	INSERT INTO keplersc.citasautorizacionpuntos VALUES ('I', 'L');
	INSERT INTO keplersc.citasautorizacionpuntos VALUES ('Q', 'Q');
	INSERT INTO keplersc.citasautorizacionpuntos VALUES ('Q', 'L');
	INSERT INTO keplersc.citasautorizacionpuntos VALUES ('R', 'R');
	INSERT INTO keplersc.citasautorizacionpuntos VALUES ('R', 'L');
*/
	--kdtmktaccion
	truncate keplersc.kdtmktaccion;
	INSERT INTO keplersc.kdtmktaccion VALUES (0, 'Pendiente', 'N', NULL, 'N');
	INSERT INTO keplersc.kdtmktaccion VALUES (20, 'No contactar más', 'N', NULL, 'S');
	INSERT INTO keplersc.kdtmktaccion VALUES (40, 'Recontactar para confirmar cita', 'S', 30, 'N');
	INSERT INTO keplersc.kdtmktaccion VALUES (10, 'Recontactar', 'S', -1, 'S');
	INSERT INTO keplersc.kdtmktaccion VALUES (21, 'Finaliza asesorÃ­a', 'N', NULL, 'S');
	INSERT INTO keplersc.kdtmktaccion VALUES (30, 'N', 'N', NULL, 'S');	

	--kdtmktmotivo
	truncate keplersc.kdtmktmotivo;
	INSERT INTO keplersc.kdtmktmotivo VALUES (20, 'Cliente Inactivo');
	INSERT INTO keplersc.kdtmktmotivo VALUES (30, 'Confirmar Cita de Servicio');
	INSERT INTO keplersc.kdtmktmotivo VALUES (40, 'Seguimiento a Cita no asistida');
	INSERT INTO keplersc.kdtmktmotivo VALUES (0, 'Primer Servicio despuÃ©s de la Entrega');
	INSERT INTO keplersc.kdtmktmotivo VALUES (10, 'Recordatorio para su siguiente Servicio');
	INSERT INTO keplersc.kdtmktmotivo VALUES (50, 'El Cliente llamÃ³');	

	--kdtmktmotres
	truncate keplersc.kdtmktmotres;
	INSERT INTO keplersc.kdtmktmotres VALUES (20, 10);
	INSERT INTO keplersc.kdtmktmotres VALUES (20, 20);
	INSERT INTO keplersc.kdtmktmotres VALUES (20, 30);
	INSERT INTO keplersc.kdtmktmotres VALUES (20, 40);
	INSERT INTO keplersc.kdtmktmotres VALUES (20, 50);
	INSERT INTO keplersc.kdtmktmotres VALUES (20, 60);
	INSERT INTO keplersc.kdtmktmotres VALUES (30, 10);
	INSERT INTO keplersc.kdtmktmotres VALUES (40, 10);
	INSERT INTO keplersc.kdtmktmotres VALUES (40, 20);
	INSERT INTO keplersc.kdtmktmotres VALUES (40, 30);
	INSERT INTO keplersc.kdtmktmotres VALUES (40, 40);
	INSERT INTO keplersc.kdtmktmotres VALUES (10, 10);
	INSERT INTO keplersc.kdtmktmotres VALUES (10, 20);
	INSERT INTO keplersc.kdtmktmotres VALUES (10, 30);
	INSERT INTO keplersc.kdtmktmotres VALUES (10, 40);
	INSERT INTO keplersc.kdtmktmotres VALUES (50, 30);
	INSERT INTO keplersc.kdtmktmotres VALUES (50, 40);
	INSERT INTO keplersc.kdtmktmotres VALUES (0, 10);
	INSERT INTO keplersc.kdtmktmotres VALUES (0, 20);
	INSERT INTO keplersc.kdtmktmotres VALUES (0, 30);
	INSERT INTO keplersc.kdtmktmotres VALUES (0, 40);
	INSERT INTO keplersc.kdtmktmotres VALUES (30, 50);
	INSERT INTO keplersc.kdtmktmotres VALUES (50, 31);
	INSERT INTO keplersc.kdtmktmotres VALUES (20, 10);
	INSERT INTO keplersc.kdtmktmotres VALUES (20, 20);
	INSERT INTO keplersc.kdtmktmotres VALUES (20, 30);
	INSERT INTO keplersc.kdtmktmotres VALUES (20, 40);
	INSERT INTO keplersc.kdtmktmotres VALUES (20, 50);
	INSERT INTO keplersc.kdtmktmotres VALUES (20, 60);
	INSERT INTO keplersc.kdtmktmotres VALUES (30, 10);
	INSERT INTO keplersc.kdtmktmotres VALUES (40, 10);
	INSERT INTO keplersc.kdtmktmotres VALUES (40, 20);
	INSERT INTO keplersc.kdtmktmotres VALUES (40, 30);
	INSERT INTO keplersc.kdtmktmotres VALUES (40, 40);
	INSERT INTO keplersc.kdtmktmotres VALUES (10, 10);
	INSERT INTO keplersc.kdtmktmotres VALUES (10, 20);
	INSERT INTO keplersc.kdtmktmotres VALUES (10, 30);
	INSERT INTO keplersc.kdtmktmotres VALUES (10, 40);
	INSERT INTO keplersc.kdtmktmotres VALUES (50, 30);
	INSERT INTO keplersc.kdtmktmotres VALUES (50, 40);
	INSERT INTO keplersc.kdtmktmotres VALUES (0, 10);
	INSERT INTO keplersc.kdtmktmotres VALUES (0, 20);
	INSERT INTO keplersc.kdtmktmotres VALUES (0, 30);
	INSERT INTO keplersc.kdtmktmotres VALUES (0, 40);
	INSERT INTO keplersc.kdtmktmotres VALUES (30, 50);
	INSERT INTO keplersc.kdtmktmotres VALUES (50, 31);	
	
	--kdtmktresacc
	truncate keplersc.kdtmktresacc;
	INSERT INTO keplersc.kdtmktresacc VALUES (10, 10);
	INSERT INTO keplersc.kdtmktresacc VALUES (20, 20);
	INSERT INTO keplersc.kdtmktresacc VALUES (30, 10);
	INSERT INTO keplersc.kdtmktresacc VALUES (40, 40);
	INSERT INTO keplersc.kdtmktresacc VALUES (50, 30);
	INSERT INTO keplersc.kdtmktresacc VALUES (31, 21);
	INSERT INTO keplersc.kdtmktresacc VALUES (10, 10);
	INSERT INTO keplersc.kdtmktresacc VALUES (20, 20);
	INSERT INTO keplersc.kdtmktresacc VALUES (30, 10);
	INSERT INTO keplersc.kdtmktresacc VALUES (40, 40);
	INSERT INTO keplersc.kdtmktresacc VALUES (50, 30);
	INSERT INTO keplersc.kdtmktresacc VALUES (31, 21);	

	--kdtmktresult
	truncate keplersc.kdtmktresult;
	INSERT INTO keplersc.kdtmktresult VALUES (0, 'Pendiente', 'N');
	INSERT INTO keplersc.kdtmktresult VALUES (10, 'No se logro contactar', 'S');
	INSERT INTO keplersc.kdtmktresult VALUES (20, 'Cliente no quiere ser contactado', 'S');
	INSERT INTO keplersc.kdtmktresult VALUES (30, 'Cliente quiere ser contactado despuÃ©s', 'S');
	INSERT INTO keplersc.kdtmktresult VALUES (40, 'Se agendo cita de servicio', 'N');
	INSERT INTO keplersc.kdtmktresult VALUES (50, 'Se confirmÃ³ cita de servicio', 'S');
	INSERT INTO keplersc.kdtmktresult VALUES (60, 'Nunca se realizÃ³ contacto', 'N');
	INSERT INTO keplersc.kdtmktresult VALUES (31, 'El cliente fue asesorado', 'S');

	--kdcattipocitas
	truncate keplersc.kdcattipocitas;
	INSERT INTO keplersc.kdcattipocitas VALUES ('Q', 'PREVIA');
	INSERT INTO keplersc.kdcattipocitas VALUES ('N', 'NORMAL');
	INSERT INTO keplersc.kdcattipocitas VALUES ('F', 'FALLA');
	INSERT INTO keplersc.kdcattipocitas VALUES ('I', 'INTERNA');
	INSERT INTO keplersc.kdcattipocitas VALUES ('G', 'GARANTIA');
	INSERT INTO keplersc.kdcattipocitas VALUES ('R', 'RECLAMACION');

	--kdserconfctas
	truncate keplersc.kdserconfctas;
	INSERT INTO keplersc.kdserconfctas VALUES (1, 4, 1, 8, 5, 80, 0, 10, 10, 1.000, 1.000, 10, 15, 'S', '', '', 0, 0, 0, 0, 0, 0, 0, 0, 0, 1.000, 1.000, 1.000, 1.500, 1.000, 20, 14, 9, '1');

	--kdtipsin
	truncate keplersc.kdtipsin;
	INSERT INTO keplersc.kdtipsin VALUES ('CLIMA', 'CLIMA', 10);
	INSERT INTO keplersc.kdtipsin VALUES ('LA', 'LUZ ADVERTENCIA', 0);
	INSERT INTO keplersc.kdtipsin VALUES ('COND', 'CONDICION', 10);
	INSERT INTO keplersc.kdtipsin VALUES ('DC', 'DESDE CUANDO', 10);
	INSERT INTO keplersc.kdtipsin VALUES ('FREC', 'FRECUENCIA', 10);
	INSERT INTO keplersc.kdtipsin VALUES ('HUELE', 'HUELE A', 10);
	INSERT INTO keplersc.kdtipsin VALUES ('LUGAR', 'LUGAR', 10);
	INSERT INTO keplersc.kdtipsin VALUES ('RUIDO', 'SE ESCUCHA COMO', 0);
	INSERT INTO keplersc.kdtipsin VALUES ('SEVE', 'SE VE COMO', 10);
	INSERT INTO keplersc.kdtipsin VALUES ('SIENT', 'SE SIENTE COMO', 10);
	INSERT INTO keplersc.kdtipsin VALUES ('SUP', 'SUPERFICIE', 20);

	--kdvaltipsin
	truncate keplersc.kdvaltipsin;
	INSERT INTO keplersc.kdvaltipsin VALUES ('CLIMA', '', '');
	INSERT INTO keplersc.kdvaltipsin VALUES ('CLIMA', 'CALUR', 'CALUROSO');
	INSERT INTO keplersc.kdvaltipsin VALUES ('CLIMA', 'DESPE', 'DESPEJADO');
	INSERT INTO keplersc.kdvaltipsin VALUES ('CLIMA', 'FRIO', 'FRIO');
	INSERT INTO keplersc.kdvaltipsin VALUES ('CLIMA', 'LLUVI', 'LLUVIA');
	INSERT INTO keplersc.kdvaltipsin VALUES ('CLIMA', 'NUBLA', 'NUBLADO');
	INSERT INTO keplersc.kdvaltipsin VALUES ('COND', '', '');
	INSERT INTO keplersc.kdvaltipsin VALUES ('COND', 'ALTO', 'AL LLEGAR A UN ALTO (SE QUIERE APAGAR)');
	INSERT INTO keplersc.kdvaltipsin VALUES ('COND', 'ARR', 'AL ARRANQUE CUANDO EL AUTO COMIENZA A AVANZAR');
	INSERT INTO keplersc.kdvaltipsin VALUES ('COND', 'CDM', 'CAMBIANDO DE MARCHA');
	INSERT INTO keplersc.kdvaltipsin VALUES ('COND', 'ENCEN', 'AL ENCENDER EL MOTOR');
	INSERT INTO keplersc.kdvaltipsin VALUES ('COND', 'ENM', 'EN MOVIMIENTO');
	INSERT INTO keplersc.kdvaltipsin VALUES ('COND', 'FRE', 'AL FRENAR');
	INSERT INTO keplersc.kdvaltipsin VALUES ('COND', 'PAR', 'DETENIDO CON MOTOR ENCENDIDO O EN RALENTI');
	INSERT INTO keplersc.kdvaltipsin VALUES ('COND', 'REB', 'AL REVASAR ACELERANDO EL MOTOR');
	INSERT INTO keplersc.kdvaltipsin VALUES ('COND', 'REV', 'REVERSA');
	INSERT INTO keplersc.kdvaltipsin VALUES ('COND', 'VTA', 'AL DAR VUELTA');
	INSERT INTO keplersc.kdvaltipsin VALUES ('DC', '1A3D', 'DE 1 A 3 DIAS QUE PRESENTA LA CONDICION');
	INSERT INTO keplersc.kdvaltipsin VALUES ('DC', '1MES', 'HACE UN MES');
	INSERT INTO keplersc.kdvaltipsin VALUES ('DC', 'HACE1', 'HACE 1 SEMANA');
	INSERT INTO keplersc.kdvaltipsin VALUES ('DC', 'HACE2', 'HACE 2 SEMANAS');
	INSERT INTO keplersc.kdvaltipsin VALUES ('DC', 'MAS', 'MAS DE 1 MES');
	INSERT INTO keplersc.kdvaltipsin VALUES ('DC', 'ULTIM', 'DESDE EL ULTIMO SERVICIO');
	INSERT INTO keplersc.kdvaltipsin VALUES ('FREC', 'CONTI', 'CONTINUO');
	INSERT INTO keplersc.kdvaltipsin VALUES ('FREC', 'INTER', 'INTERMITENTE');
	INSERT INTO keplersc.kdvaltipsin VALUES ('FREC', 'MF', 'MUY FRENCUENTE');
	INSERT INTO keplersc.kdvaltipsin VALUES ('FREC', 'PF', 'POCO FRECUENTE');
	INSERT INTO keplersc.kdvaltipsin VALUES ('FREC', 'RF', 'RELATIVAMENTE FRECUENTE');
	INSERT INTO keplersc.kdvaltipsin VALUES ('FREC', 'SP', 'SIEMPRE');
	INSERT INTO keplersc.kdvaltipsin VALUES ('HUELE', 'AZUFR', 'AZUFRE');
	INSERT INTO keplersc.kdvaltipsin VALUES ('HUELE', 'GASOL', 'GASOLINA');
	INSERT INTO keplersc.kdvaltipsin VALUES ('HUELE', 'HUEVO', 'HUEVO PODRIDO');
	INSERT INTO keplersc.kdvaltipsin VALUES ('HUELE', 'HUMED', 'HUMEDAD');
	INSERT INTO keplersc.kdvaltipsin VALUES ('HUELE', 'HUMO', 'HUMO');
	INSERT INTO keplersc.kdvaltipsin VALUES ('HUELE', 'PERRO', 'PERRO MUERTO');
	INSERT INTO keplersc.kdvaltipsin VALUES ('HUELE', 'QUEMA', 'QUEMADO');
	INSERT INTO keplersc.kdvaltipsin VALUES ('LA', '1A3D', 'DE 1 A 3 DIAS QUE PRESENTA LA CONDICION');
	INSERT INTO keplersc.kdvaltipsin VALUES ('LA', '1MES', 'HACE UN MES');
	INSERT INTO keplersc.kdvaltipsin VALUES ('LA', 'HACE1', 'HACE 1 SEMANA');
	INSERT INTO keplersc.kdvaltipsin VALUES ('LA', 'HACE2', 'HACE 2 SEMANAS');
	INSERT INTO keplersc.kdvaltipsin VALUES ('LA', 'MAS', 'MAS DE 1 MES');
	INSERT INTO keplersc.kdvaltipsin VALUES ('LA', 'ULTIM', 'DESDE EL ULTIMO SERVICIO');
	INSERT INTO keplersc.kdvaltipsin VALUES ('LUGAR', 'BAJ', 'BAJADA');
	INSERT INTO keplersc.kdvaltipsin VALUES ('LUGAR', 'CARR', 'CARRETERA');
	INSERT INTO keplersc.kdvaltipsin VALUES ('LUGAR', 'CN', 'CALLE NORMAL');
	INSERT INTO keplersc.kdvaltipsin VALUES ('LUGAR', 'SUB', 'SUBIDA');
	INSERT INTO keplersc.kdvaltipsin VALUES ('LUGAR', 'TRAF', 'TRAFICO');
	INSERT INTO keplersc.kdvaltipsin VALUES ('RUIDO', 'CANIC', 'CANICAS');
	INSERT INTO keplersc.kdvaltipsin VALUES ('RUIDO', 'CASCA', 'CASCABEL');
	INSERT INTO keplersc.kdvaltipsin VALUES ('RUIDO', 'DEAGU', 'DE AGUA');
	INSERT INTO keplersc.kdvaltipsin VALUES ('RUIDO', 'EXPLO', 'EXPLOSION');
	INSERT INTO keplersc.kdvaltipsin VALUES ('RUIDO', 'GOLPE', 'GOLPETEO');
	INSERT INTO keplersc.kdvaltipsin VALUES ('RUIDO', 'LAMIN', 'LAMINA O LAMINAS');
	INSERT INTO keplersc.kdvaltipsin VALUES ('RUIDO', 'MATRA', 'MATRACA');
	INSERT INTO keplersc.kdvaltipsin VALUES ('RUIDO', 'RECHI', 'RECHINIDO');
	INSERT INTO keplersc.kdvaltipsin VALUES ('RUIDO', 'ROCEM', 'ROCE DE METAL');
	INSERT INTO keplersc.kdvaltipsin VALUES ('RUIDO', 'ROCEP', 'ROCE DE PLASTICO');
	INSERT INTO keplersc.kdvaltipsin VALUES ('RUIDO', 'RUMBI', 'RUMBIDO');
	INSERT INTO keplersc.kdvaltipsin VALUES ('RUIDO', 'SILBI', 'SILBIDO');
	INSERT INTO keplersc.kdvaltipsin VALUES ('RUIDO', 'TICTA', 'TIC TAC');
	INSERT INTO keplersc.kdvaltipsin VALUES ('RUIDO', 'TRONI', 'TRONIDO');
	INSERT INTO keplersc.kdvaltipsin VALUES ('RUIDO', 'VENTI', 'VENTILADOR');
	INSERT INTO keplersc.kdvaltipsin VALUES ('RUIDO', 'ZUMB', 'ZUMBIDO');
	INSERT INTO keplersc.kdvaltipsin VALUES ('SEVE', 'AGRIE', 'AGRIETADO');
	INSERT INTO keplersc.kdvaltipsin VALUES ('SEVE', 'ARRUG', 'ARRUGADO');
	INSERT INTO keplersc.kdvaltipsin VALUES ('SEVE', 'CHUEC', 'CHUECO');
	INSERT INTO keplersc.kdvaltipsin VALUES ('SEVE', 'CONFU', 'CON FUGA');
	INSERT INTO keplersc.kdvaltipsin VALUES ('SEVE', 'DESCO', 'DESCOSIDO');
	INSERT INTO keplersc.kdvaltipsin VALUES ('SEVE', 'DESGA', 'DESGASTADO');
	INSERT INTO keplersc.kdvaltipsin VALUES ('SEVE', 'DESPI', 'DESPINTADO');
	INSERT INTO keplersc.kdvaltipsin VALUES ('SEVE', 'DOBLA', 'DOBLADO');
	INSERT INTO keplersc.kdvaltipsin VALUES ('SEVE', 'ESTRE', 'ESTRELLADO');
	INSERT INTO keplersc.kdvaltipsin VALUES ('SEVE', 'FUERA', 'FUERA DE LUGAR');
	INSERT INTO keplersc.kdvaltipsin VALUES ('SEVE', 'JALAD', 'JALADO');
	INSERT INTO keplersc.kdvaltipsin VALUES ('SEVE', 'MARCA', 'MARCADO');
	INSERT INTO keplersc.kdvaltipsin VALUES ('SEVE', 'NOPRE', 'NO PRENDE LUZ');
	INSERT INTO keplersc.kdvaltipsin VALUES ('SEVE', 'RASGA', 'RASGADO');
	INSERT INTO keplersc.kdvaltipsin VALUES ('SEVE', 'RAYA', 'RAYADO');
	INSERT INTO keplersc.kdvaltipsin VALUES ('SEVE', 'ROIDO', 'ROIDO');
	INSERT INTO keplersc.kdvaltipsin VALUES ('SEVE', 'ROTO', 'ROTO');
	INSERT INTO keplersc.kdvaltipsin VALUES ('SIENT', '', '');
	INSERT INTO keplersc.kdvaltipsin VALUES ('SIENT', 'ACEL', 'ACELERADO');
	INSERT INTO keplersc.kdvaltipsin VALUES ('SIENT', 'AGUAD', 'AGUADO');
	INSERT INTO keplersc.kdvaltipsin VALUES ('SIENT', 'APAGA', 'SE APAGA');
	INSERT INTO keplersc.kdvaltipsin VALUES ('SIENT', 'ATORA', 'ATORADO');
	INSERT INTO keplersc.kdvaltipsin VALUES ('SIENT', 'BRINC', 'BRINCA MUCHO');
	INSERT INTO keplersc.kdvaltipsin VALUES ('SIENT', 'CALIE', 'CALIENTE');
	INSERT INTO keplersc.kdvaltipsin VALUES ('SIENT', 'CHUEC', 'CHUECO');
	INSERT INTO keplersc.kdvaltipsin VALUES ('SIENT', 'DESPE', 'DESPEGADO');
	INSERT INTO keplersc.kdvaltipsin VALUES ('SIENT', 'DURO', 'DURO');
	INSERT INTO keplersc.kdvaltipsin VALUES ('SIENT', 'FLOJO', 'FLOJO');
	INSERT INTO keplersc.kdvaltipsin VALUES ('SIENT', 'FRENA', 'NO FRENA');
	INSERT INTO keplersc.kdvaltipsin VALUES ('SIENT', 'FRIO', 'FRIO');
	INSERT INTO keplersc.kdvaltipsin VALUES ('SIENT', 'JALON', 'SE JALONEA');
	INSERT INTO keplersc.kdvaltipsin VALUES ('SIENT', 'MOJAD', 'MOJADO');
	INSERT INTO keplersc.kdvaltipsin VALUES ('SIENT', 'NOARR', 'NO ARRANCA');
	INSERT INTO keplersc.kdvaltipsin VALUES ('SIENT', 'NOVEN', 'NO ENCIENDE VENTILADOR');
	INSERT INTO keplersc.kdvaltipsin VALUES ('SIENT', 'PATIN', 'SE PATINA');
	INSERT INTO keplersc.kdvaltipsin VALUES ('SIENT', 'POTEN', 'SIN POTENCIA');
	INSERT INTO keplersc.kdvaltipsin VALUES ('SIENT', 'RESEC', 'RESECO');
	INSERT INTO keplersc.kdvaltipsin VALUES ('SIENT', 'SUBAJ', 'NO SUBE O NO BAJA');
	INSERT INTO keplersc.kdvaltipsin VALUES ('SIENT', 'SUELT', 'SUELTO');
	INSERT INTO keplersc.kdvaltipsin VALUES ('SIENT', 'TIRON', 'SE TIRONEA');
	INSERT INTO keplersc.kdvaltipsin VALUES ('SIENT', 'VIBRA', 'VIBRACION');
	INSERT INTO keplersc.kdvaltipsin VALUES ('SUP', 'ASPER', 'ASPERO');
	INSERT INTO keplersc.kdvaltipsin VALUES ('SUP', 'BACH', 'EN BACHES');
	INSERT INTO keplersc.kdvaltipsin VALUES ('SUP', 'EMP', 'EMPEDRADO');
	INSERT INTO keplersc.kdvaltipsin VALUES ('SUP', 'PLANA', 'PLANA');
	INSERT INTO keplersc.kdvaltipsin VALUES ('SUP', 'TOPE', 'EN TOPES');
	
	
	--kdcatcitasordenes
	truncate keplersc.kdcatcitasordenes;
	INSERT INTO keplersc.kdcatcitasordenes VALUES ('C', 'CampaÃ±as');
	INSERT INTO keplersc.kdcatcitasordenes VALUES ('D', 'DIAGNOSTICO');
	INSERT INTO keplersc.kdcatcitasordenes VALUES ('E', 'Garantia Plus');
	INSERT INTO keplersc.kdcatcitasordenes VALUES ('G', 'Garantia');
	INSERT INTO keplersc.kdcatcitasordenes VALUES ('H', 'Hojalateria');
	INSERT INTO keplersc.kdcatcitasordenes VALUES ('I', 'Interna');
	INSERT INTO keplersc.kdcatcitasordenes VALUES ('P', 'Previa');
	INSERT INTO keplersc.kdcatcitasordenes VALUES ('R', 'Reclamacion');
	INSERT INTO keplersc.kdcatcitasordenes VALUES ('S', 'PAQUETES');
	INSERT INTO keplersc.kdcatcitasordenes VALUES ('T', 'Normal');
	INSERT INTO keplersc.kdcatcitasordenes VALUES ('X', 'Servicio Express');

	--kdcattipocitas
	truncate keplersc.kdcattipocitas;	
	INSERT INTO keplersc.kdcattipocitas VALUES ('Q', 'PREVIA');
	INSERT INTO keplersc.kdcattipocitas VALUES ('N', 'NORMAL');
	INSERT INTO keplersc.kdcattipocitas VALUES ('F', 'FALLA');
	INSERT INTO keplersc.kdcattipocitas VALUES ('I', 'INTERNA');
	INSERT INTO keplersc.kdcattipocitas VALUES ('G', 'GARANTIA');
	INSERT INTO keplersc.kdcattipocitas VALUES ('R', 'RECLAMACION');

	truncate keplersc.kdcatestatusorden;
	insert into keplersc.kdcatestatusorden (c1,c2) values(0,'PENDIENTE');
	insert into keplersc.kdcatestatusorden (c1,c2) values(10,'ACTIVA');
	insert into keplersc.kdcatestatusorden (c1,c2) values(20,'SUSPENDIDA');
	insert into keplersc.kdcatestatusorden (c1,c2) values(30,'TERMINADA');
	insert into keplersc.kdcatestatusorden (c1,c2) values(40,'CERRADA');
	insert into keplersc.kdcatestatusorden (c1,c2) values(50,'FUERA TALLER');

	truncate keplersc.kdtoper;
	insert into keplersc.kdtoper (c1,c2,c3) values('AY','AYUDANTE', 0);

	truncate keplersc.kdtipoordentipopuntos;
	insert into keplersc.kdtipoordentipopuntos (c1,c2) values('G','G');
	insert into keplersc.kdtipoordentipopuntos (c1,c2) values('I','I');
	insert into keplersc.kdtipoordentipopuntos (c1,c2) values('I','L');
	insert into keplersc.kdtipoordentipopuntos (c1,c2) values('R','R');
	insert into keplersc.kdtipoordentipopuntos (c1,c2) values('R','L');
	insert into keplersc.kdtipoordentipopuntos (c1,c2) values('T','S');
	insert into keplersc.kdtipoordentipopuntos (c1,c2) values('T','F');
	insert into keplersc.kdtipoordentipopuntos (c1,c2) values('T','P');
	insert into keplersc.kdtipoordentipopuntos (c1,c2) values('T','G');
	insert into keplersc.kdtipoordentipopuntos (c1,c2) values('T','L');
	insert into keplersc.kdtipoordentipopuntos (c1,c2) values('T','H');
	insert into keplersc.kdtipoordentipopuntos (c1,c2) values('S','S');
	insert into keplersc.kdtipoordentipopuntos (c1,c2) values('S','L');
	insert into keplersc.kdtipoordentipopuntos (c1,c2) values('P','L');
	insert into keplersc.kdtipoordentipopuntos (c1,c2) values('H','H');
	insert into keplersc.kdtipoordentipopuntos (c1,c2) values('H','L');
	insert into keplersc.kdtipoordentipopuntos (c1,c2) values('P','Q');
	insert into keplersc.kdtipoordentipopuntos (c1,c2) values('C','G');
	insert into keplersc.kdtipoordentipopuntos (c1,c2) values('D','I');
	insert into keplersc.kdtipoordentipopuntos (c1,c2) values('D','L');
	insert into keplersc.kdtipoordentipopuntos (c1,c2) values('E','G');
	insert into keplersc.kdtipoordentipopuntos (c1,c2) values('E','L');
	insert into keplersc.kdtipoordentipopuntos (c1,c2) values('X','S');
	insert into keplersc.kdtipoordentipopuntos (c1,c2) values('X','L');
	insert into keplersc.kdtipoordentipopuntos (c1,c2) values('G','L');
	insert into keplersc.kdtipoordentipopuntos (c1,c2) values('S','F');

	truncate keplersc.kdcfdsersucdoc;
	INSERT INTO keplersc.kdcfdsersucdoc VALUES ('01', 'U', 'A', 3, 1, 'ZA', '');
	INSERT INTO keplersc.kdcfdsersucdoc VALUES ('01', 'U', 'A', 5, 1, 'KD', '');
	INSERT INTO keplersc.kdcfdsersucdoc VALUES ('01', 'U', 'A', 9, 1, 'ZR', '');
	INSERT INTO keplersc.kdcfdsersucdoc VALUES ('01', 'U', 'A', 9, 2, 'ZR', '');
	INSERT INTO keplersc.kdcfdsersucdoc VALUES ('01', 'U', 'A', 9, 5, 'ZR', '');
	INSERT INTO keplersc.kdcfdsersucdoc VALUES ('01', 'U', 'A', 14, 1, 'ZS', '');
	INSERT INTO keplersc.kdcfdsersucdoc VALUES ('01', 'U', 'A', 14, 2, 'ZS', '');
	INSERT INTO keplersc.kdcfdsersucdoc VALUES ('01', 'U', 'A', 14, 6, 'ZS', '');
	INSERT INTO keplersc.kdcfdsersucdoc VALUES ('01', 'U', 'A', 14, 14, 'ZS', '');
	INSERT INTO keplersc.kdcfdsersucdoc VALUES ('01', 'U', 'A', 19, 1, 'KR', '');
	INSERT INTO keplersc.kdcfdsersucdoc VALUES ('01', 'U', 'A', 19, 2, 'KR', '');
	INSERT INTO keplersc.kdcfdsersucdoc VALUES ('01', 'U', 'A', 19, 3, 'KR', '');
	INSERT INTO keplersc.kdcfdsersucdoc VALUES ('01', 'U', 'A', 21, 1, 'ZA', '');
	INSERT INTO keplersc.kdcfdsersucdoc VALUES ('01', 'U', 'A', 21, 2, 'ZA', '');
	INSERT INTO keplersc.kdcfdsersucdoc VALUES ('01', 'U', 'A', 22, 1, 'KA', '');
	INSERT INTO keplersc.kdcfdsersucdoc VALUES ('01', 'U', 'A', 24, 1, 'KS', '');
	INSERT INTO keplersc.kdcfdsersucdoc VALUES ('01', 'U', 'A', 24, 2, 'KS', '');
	INSERT INTO keplersc.kdcfdsersucdoc VALUES ('01', 'U', 'A', 24, 14, 'KS', '');
	INSERT INTO keplersc.kdcfdsersucdoc VALUES ('01', 'U', 'A', 29, 1, 'RC', '');
	INSERT INTO keplersc.kdcfdsersucdoc VALUES ('01', 'U', 'A', 29, 2, 'RC', '');
	INSERT INTO keplersc.kdcfdsersucdoc VALUES ('01', 'U', 'A', 29, 3, 'RC', '');
	INSERT INTO keplersc.kdcfdsersucdoc VALUES ('01', 'U', 'A', 29, 4, 'RC', '');
	INSERT INTO keplersc.kdcfdsersucdoc VALUES ('01', 'U', 'A', 29, 5, 'RC', '');
	INSERT INTO keplersc.kdcfdsersucdoc VALUES ('01', 'U', 'A', 29, 6, 'RC', '');
	INSERT INTO keplersc.kdcfdsersucdoc VALUES ('01', 'U', 'A', 29, 8, 'RC', '');
	INSERT INTO keplersc.kdcfdsersucdoc VALUES ('01', 'U', 'A', 32, 1, 'RC', '');
	INSERT INTO keplersc.kdcfdsersucdoc VALUES ('01', 'U', 'A', 32, 2, 'RC', '');
	INSERT INTO keplersc.kdcfdsersucdoc VALUES ('01', 'U', 'A', 32, 3, 'RC', '');
	INSERT INTO keplersc.kdcfdsersucdoc VALUES ('01', 'U', 'A', 32, 4, 'RC', '');
	INSERT INTO keplersc.kdcfdsersucdoc VALUES ('01', 'U', 'A', 32, 5, 'RC', '');
	INSERT INTO keplersc.kdcfdsersucdoc VALUES ('01', 'U', 'A', 32, 7, 'RC', '');
	INSERT INTO keplersc.kdcfdsersucdoc VALUES ('01', 'U', 'A', 32, 8, 'RC', '');
	INSERT INTO keplersc.kdcfdsersucdoc VALUES ('01', 'U', 'A', 52, 1, 'ZA', '');
	INSERT INTO keplersc.kdcfdsersucdoc VALUES ('01', 'U', 'A', 52, 2, 'ZA', '');
	INSERT INTO keplersc.kdcfdsersucdoc VALUES ('01', 'U', 'A', 60, 1, 'ZA', '');
	INSERT INTO keplersc.kdcfdsersucdoc VALUES ('01', 'U', 'A', 60, 2, 'ZA', '');
	INSERT INTO keplersc.kdcfdsersucdoc VALUES ('01', 'U', 'A', 60, 3, 'ZA', '');
	INSERT INTO keplersc.kdcfdsersucdoc VALUES ('01', 'U', 'A', 61, 1, 'ZA', '');
	INSERT INTO keplersc.kdcfdsersucdoc VALUES ('01', 'U', 'A', 61, 2, 'ZA', '');
	INSERT INTO keplersc.kdcfdsersucdoc VALUES ('01', 'U', 'A', 61, 3, 'ZA', '');
	INSERT INTO keplersc.kdcfdsersucdoc VALUES ('01', 'U', 'A', 62, 1, 'ZA', '');
	INSERT INTO keplersc.kdcfdsersucdoc VALUES ('01', 'U', 'A', 70, 1, 'KA', '');
	INSERT INTO keplersc.kdcfdsersucdoc VALUES ('01', 'U', 'A', 70, 2, 'KA', '');
	INSERT INTO keplersc.kdcfdsersucdoc VALUES ('01', 'U', 'A', 70, 3, 'ZB', '');
	INSERT INTO keplersc.kdcfdsersucdoc VALUES ('01', 'U', 'A', 71, 1, 'KA', '');
	INSERT INTO keplersc.kdcfdsersucdoc VALUES ('01', 'U', 'A', 71, 2, 'KA', '');
	INSERT INTO keplersc.kdcfdsersucdoc VALUES ('01', 'U', 'A', 78, 1, 'KW', '');
	INSERT INTO keplersc.kdcfdsersucdoc VALUES ('01', 'U', 'A', 78, 4, 'KW', '');
	INSERT INTO keplersc.kdcfdsersucdoc VALUES ('01', 'U', 'A', 78, 5, 'ZA', '');
	INSERT INTO keplersc.kdcfdsersucdoc VALUES ('01', 'U', 'A', 79, 1, 'ZC', '');
	INSERT INTO keplersc.kdcfdsersucdoc VALUES ('01', 'U', 'A', 79, 3, 'ZC', '');
	INSERT INTO keplersc.kdcfdsersucdoc VALUES ('01', 'U', 'A', 79, 4, 'ZA', '');
	INSERT INTO keplersc.kdcfdsersucdoc VALUES ('01', 'U', 'A', 80, 1, 'KC', '');
	INSERT INTO keplersc.kdcfdsersucdoc VALUES ('01', 'U', 'A', 80, 2, 'KC', '');
	INSERT INTO keplersc.kdcfdsersucdoc VALUES ('01', 'U', 'A', 80, 3, 'KC', '');
	INSERT INTO keplersc.kdcfdsersucdoc VALUES ('01', 'U', 'A', 80, 4, 'KC', '');
	INSERT INTO keplersc.kdcfdsersucdoc VALUES ('01', 'U', 'D', 3, 1, 'AN', '');
	INSERT INTO keplersc.kdcfdsersucdoc VALUES ('01', 'U', 'D', 3, 2, 'AN', '');
	INSERT INTO keplersc.kdcfdsersucdoc VALUES ('01', 'U', 'D', 6, 1, 'AA', '');
	INSERT INTO keplersc.kdcfdsersucdoc VALUES ('01', 'U', 'D', 6, 2, 'AA', '');
	INSERT INTO keplersc.kdcfdsersucdoc VALUES ('01', 'U', 'D', 10, 1, 'AS', '');
	INSERT INTO keplersc.kdcfdsersucdoc VALUES ('01', 'U', 'D', 10, 2, 'AS', '');
	INSERT INTO keplersc.kdcfdsersucdoc VALUES ('01', 'U', 'D', 10, 6, 'AS', '');
	INSERT INTO keplersc.kdcfdsersucdoc VALUES ('01', 'U', 'D', 10, 14, 'AS', '');
	INSERT INTO keplersc.kdcfdsersucdoc VALUES ('01', 'U', 'D', 21, 1, 'AA', '');
	INSERT INTO keplersc.kdcfdsersucdoc VALUES ('01', 'U', 'D', 21, 2, 'AA', '');
	INSERT INTO keplersc.kdcfdsersucdoc VALUES ('01', 'U', 'D', 22, 3, 'AR', '');
	INSERT INTO keplersc.kdcfdsersucdoc VALUES ('01', 'U', 'D', 22, 5, 'AR', '');
	INSERT INTO keplersc.kdcfdsersucdoc VALUES ('01', 'U', 'D', 50, 1, 'AN', '');
	INSERT INTO keplersc.kdcfdsersucdoc VALUES ('01', 'U', 'D', 50, 2, 'AN', '');
	INSERT INTO keplersc.kdcfdsersucdoc VALUES ('01', 'U', 'D', 50, 3, 'AN', '');
	INSERT INTO keplersc.kdcfdsersucdoc VALUES ('01', 'U', 'D', 54, 1, 'AN', '');
	INSERT INTO keplersc.kdcfdsersucdoc VALUES ('01', 'U', 'D', 61, 1, 'AP', '');
	INSERT INTO keplersc.kdcfdsersucdoc VALUES ('01', 'U', 'D', 79, 1, 'AC', '');
	INSERT INTO keplersc.kdcfdsersucdoc VALUES ('01', 'U', 'D', 79, 2, 'A', '');
	INSERT INTO keplersc.kdcfdsersucdoc VALUES ('01', 'U', 'D', 79, 3, 'AC', '');
	INSERT INTO keplersc.kdcfdsersucdoc VALUES ('02', 'U', 'A', 79, 1, 'ZA', '');
	INSERT INTO keplersc.kdcfdsersucdoc VALUES ('02', 'U', 'A', 79, 3, 'ZA', '');
	INSERT INTO keplersc.kdcfdsersucdoc VALUES ('01', 'U', 'A', 6, 1, 'ZR', '');
	INSERT INTO keplersc.kdcfdsersucdoc VALUES ('01', 'U', 'A', 6, 2, 'ZR', '');
	INSERT INTO keplersc.kdcfdsersucdoc VALUES ('01', 'U', 'A', 7, 1, 'ZR', '');
	INSERT INTO keplersc.kdcfdsersucdoc VALUES ('01', 'U', 'A', 7, 5, 'ZR', '');
	INSERT INTO keplersc.kdcfdsersucdoc VALUES ('01', 'U', 'A', 7, 6, 'ZR', '');
	INSERT INTO keplersc.kdcfdsersucdoc VALUES ('01', 'U', 'A', 7, 7, 'ZR', '');
	INSERT INTO keplersc.kdcfdsersucdoc VALUES ('01', 'U', 'A', 7, 8, 'ZR', '');
	INSERT INTO keplersc.kdcfdsersucdoc VALUES ('01', 'U', 'A', 8, 1, 'ZS', '');
	INSERT INTO keplersc.kdcfdsersucdoc VALUES ('01', 'U', 'A', 8, 2, 'ZS', '');
	INSERT INTO keplersc.kdcfdsersucdoc VALUES ('01', 'U', 'A', 8, 3, 'ZS', '');
	INSERT INTO keplersc.kdcfdsersucdoc VALUES ('01', 'U', 'A', 14, 3, 'ZS', '');
	INSERT INTO keplersc.kdcfdsersucdoc VALUES ('01', 'U', 'A', 14, 4, 'ZS', '');
	INSERT INTO keplersc.kdcfdsersucdoc VALUES ('01', 'U', 'A', 14, 5, 'ZS', '');
	INSERT INTO keplersc.kdcfdsersucdoc VALUES ('01', 'U', 'A', 14, 7, 'ZS', '');
	INSERT INTO keplersc.kdcfdsersucdoc VALUES ('01', 'U', 'A', 14, 8, 'ZS', '');
	INSERT INTO keplersc.kdcfdsersucdoc VALUES ('01', 'U', 'A', 14, 9, 'ZS', '');
	INSERT INTO keplersc.kdcfdsersucdoc VALUES ('01', 'U', 'A', 14, 10, 'ZS', '');
	INSERT INTO keplersc.kdcfdsersucdoc VALUES ('01', 'U', 'A', 14, 11, 'ZS', '');
	INSERT INTO keplersc.kdcfdsersucdoc VALUES ('01', 'U', 'A', 20, 1, 'ZR', '');
	INSERT INTO keplersc.kdcfdsersucdoc VALUES ('01', 'U', 'A', 20, 2, 'ZR', '');
	INSERT INTO keplersc.kdcfdsersucdoc VALUES ('01', 'U', 'A', 20, 3, 'ZR', '');
	INSERT INTO keplersc.kdcfdsersucdoc VALUES ('01', 'U', 'A', 20, 4, 'ZR', '');
	INSERT INTO keplersc.kdcfdsersucdoc VALUES ('01', 'U', 'A', 20, 5, 'ZR', '');
	INSERT INTO keplersc.kdcfdsersucdoc VALUES ('01', 'U', 'D', 7, 1, 'AR', '');
	INSERT INTO keplersc.kdcfdsersucdoc VALUES ('01', 'U', 'D', 7, 2, 'AR', '');
	INSERT INTO keplersc.kdcfdsersucdoc VALUES ('01', 'U', 'D', 7, 3, 'AR', '');
	INSERT INTO keplersc.kdcfdsersucdoc VALUES ('01', 'U', 'D', 7, 4, 'AR', '');
	INSERT INTO keplersc.kdcfdsersucdoc VALUES ('01', 'U', 'D', 7, 5, 'AR', '');
	INSERT INTO keplersc.kdcfdsersucdoc VALUES ('01', 'U', 'D', 7, 6, 'AR', '');
	INSERT INTO keplersc.kdcfdsersucdoc VALUES ('01', 'U', 'D', 7, 7, 'AR', '');
	INSERT INTO keplersc.kdcfdsersucdoc VALUES ('01', 'U', 'D', 7, 8, 'AR', '');
	INSERT INTO keplersc.kdcfdsersucdoc VALUES ('01', 'U', 'D', 10, 3, 'AS', '');
	INSERT INTO keplersc.kdcfdsersucdoc VALUES ('01', 'U', 'D', 10, 4, 'AS', '');
	INSERT INTO keplersc.kdcfdsersucdoc VALUES ('01', 'U', 'D', 10, 5, 'AS', '');
	INSERT INTO keplersc.kdcfdsersucdoc VALUES ('01', 'U', 'D', 10, 7, 'AS', '');
	INSERT INTO keplersc.kdcfdsersucdoc VALUES ('01', 'U', 'D', 10, 8, 'AS', '');
	INSERT INTO keplersc.kdcfdsersucdoc VALUES ('01', 'U', 'D', 10, 9, 'AS', '');
	INSERT INTO keplersc.kdcfdsersucdoc VALUES ('01', 'U', 'D', 10, 10, 'AS', '');
	INSERT INTO keplersc.kdcfdsersucdoc VALUES ('01', 'U', 'D', 10, 11, 'AS', '');
	INSERT INTO keplersc.kdcfdsersucdoc VALUES ('01', 'U', 'D', 22, 1, 'AR', 'FACTURA DIRECTA REFACCIONES');
	INSERT INTO keplersc.kdcfdsersucdoc VALUES ('01', 'U', 'D', 22, 2, 'AR', 'FACTURA MOSTRADOR CREDITO');
	INSERT INTO keplersc.kdcfdsersucdoc VALUES ('01', 'U', 'D', 28, 1, 'AC', '');
	INSERT INTO keplersc.kdcfdsersucdoc VALUES ('01', 'U', 'D', 28, 4, 'AC', '');
	INSERT INTO keplersc.kdcfdsersucdoc VALUES ('01', 'U', 'D', 28, 6, 'AC', '');
	INSERT INTO keplersc.kdcfdsersucdoc VALUES ('01', 'U', 'D', 28, 8, 'AC', '');


	truncate keplersc.kddinv;
	insert into keplersc.kddinv (c1,c2,c3,c4,c5,c6,c7) values('21',    'AUTOS NUEVOS 2021', '2021', 'IRN',    '21', 1, 'N');
	insert into keplersc.kddinv (c1,c2,c3,c4,c5,c6,c7) values('22',    'AUTOS NUEVOS 2022', '2022', 'IRN',    '22', 1, 'N');
	insert into keplersc.kddinv (c1,c2,c3,c4,c5,c6,c7) values('U21', 'AUTOS USADOS 2021', '2021', 'IRU', '21', 1, 'U');
	insert into keplersc.kddinv (c1,c2,c3,c4,c5,c6,c7) values('U22', 'AUTOS USADOS 2022', '2022', 'IRU', '22', 1, 'U');
	insert into keplersc.kddinv (c1,c2,c3,c4,c5,c6,c7) values('23',	'AUTOS NUEVOS 2023', '2023', 'IRN',	'23', 1, 'N');
	insert into keplersc.kddinv (c1,c2,c3,c4,c5,c6,c7) values('U23', 'AUTOS USADOS 2023', '2023', 'IRU', '23', 1, 'U');
	update keplersc.kdmm set c21 = '324-003' where c1 = 'X' and c2 = 'A' and c3 = 7 and c4 = 2;
	update keplersc.kdmm set c21 = '324-003' where c1 = 'X' and c2 = 'D' and c3 = 7 and c4 = 2;

	INSERT INTO keplersc.kdtallcont (c1,c2,c3,c4,c5,c6,c7,c8,c9,c10,c11,c12,c13,c14,c15,c16,c17,c18)
	VALUES ('T','01','22','','483-001-001','483-001-002','483-001-003','483-001-004','','683-001-001','683-001-002','683-001-003','683-001-004','','','683-013','683-014','');

	update keplersc.kdmargen set c4=550 where c1='S' and c2= 'N';
	update keplersc.kdmargen set c4=550 where c1='X' and c2= 'N';
	update keplersc.kdmargen set c4=550 where c1='T' and c2= 'N';

	delete from keplersc.kdud where c2='NUEVO';


	truncate keplersc.kdclaspag;
	INSERT INTO keplersc.kdclaspag
	(c1, c2, c3, c4, c5, c6, c7, c8, c9, c10, c11, c12, c13, c14, c15, c16)
	VALUES('A', 'OPERARIO A', 20.00000, 67.32000, 2593.05, 0.00000, 0.00000, 0.00000, 0.00000, 0.00000, 1000, 0.00000, 0, 0.00000, 0, 0.00000);
	INSERT INTO keplersc.kdclaspag
	(c1, c2, c3, c4, c5, c6, c7, c8, c9, c10, c11, c12, c13, c14, c15, c16)
	VALUES('AYN', 'AYUDANTE MECANICO (NUEVO)', 20.00000, 30.00000, 2593.05, 0.00000, 0.00000, 0.00000, 0.00000, 0.00000, 1000, 0.00000, 0, 0.00000, 0, 0.00000);
	INSERT INTO keplersc.kdclaspag
	(c1, c2, c3, c4, c5, c6, c7, c8, c9, c10, c11, c12, c13, c14, c15, c16)
	VALUES('B', 'OPERARIO B', 20.00000, 54.91000, 2593.05, 0.00000, 0.00000, 0.00000, 0.00000, 0.00000, 1000, 0.00000, 0, 0.00000, 0, 0.00000);
	INSERT INTO keplersc.kdclaspag
	(c1, c2, c3, c4, c5, c6, c7, c8, c9, c10, c11, c12, c13, c14, c15, c16)
	VALUES('C', 'OPERARIO C', 20.00000, 46.01000, 2593.05, 0.00000, 0.00000, 0.00000, 0.00000, 0.00000, 1000, 0.00000, 0, 0.00000, 0, 0.00000);
	INSERT INTO keplersc.kdclaspag
	(c1, c2, c3, c4, c5, c6, c7, c8, c9, c10, c11, c12, c13, c14, c15, c16)
	VALUES('D', 'OPERARIO D', 20.00000, 40.59000, 2125.50, 0.00000, 0.00000, 0.00000, 0.00000, 0.00000, 1000, 0.00000, 0, 0.00000, 0, 0.00000);
	INSERT INTO keplersc.kdclaspag
	(c1, c2, c3, c4, c5, c6, c7, c8, c9, c10, c11, c12, c13, c14, c15, c16)
	VALUES('L', 'LAVADOR', 24.00000, 30.00000, 2125.50, 0.00000, 0.00000, 0.00000, 0.00000, 0.00000, 1000, 0.00000, 0, 0.00000, 0, 0.00000);


	resultado := 'Proceso terminado';
	return resultado;

/*
 * Adicionales de analisis de tablas
 select c2,c3,c4,c5,c6, count(*) as total from keplersc.kdcfdsersucdoc k 
group by c2,c3,c4,c5,c6 order by c2,c3,c4,c5,c6

select * from keplersc.kdcfdsersucdoc order by c2,c3,c4,c5,c6


update keplersc.kdcfdsersucdoc set c1='01' where c1='02' 
and c2||c3||c4||c5 
not in( select c2||c3||c4||c5 from keplersc.kdcfdsersucdoc where c1='01')

delete from keplersc.kdcfdsersucdoc where c1='02'
 */

end;
$function$
