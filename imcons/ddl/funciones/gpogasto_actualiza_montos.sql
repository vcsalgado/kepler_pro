CREATE OR REPLACE FUNCTION keplersc.gpogasto_actualiza_montos(dataxml xml)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
DECLARE 
	--Esta funcion procesa los tipos de documentos internos para operaciones de empleados (Depositos Internos, Contrarecibos Internos)
	--Esta Funcion solo es Accesible en el Modulo de Gastos 
	--Autor: Jose Mendoza 
	--Fecha: 2024-Oct-11
	
	--Variables para xml
	suc_id text;
	tipo_desc text;
	genero text;
	naturaleza text;
	grupo text;
	tipo text;
	tipo_clave text;
	uen text = '';

	referencia text = '';
	proveedor text = '';
	fecha_operacion text;
	strMonto text = '';

	rec1 record;

	--xml Movimiento
	xmlKDM1 xml;
	xmlKDMM xml; -- to get base on document of dataxml

	--Variables de uso general
	mensajeError text;
	expSql text;
	totalReg int;
	strValor text;
	folio_operacion text;

	paso text;
	xmlResultado xml;

	flag_gastos text = '';

	--Added by JMM 20241011
	ingresos numeric = 0;	
	gastos numeric = 0;	
		
	--Variables de retorno desde funciones externas
	resultado text; --retorno
	mensaje text; --retorno
	adicionales text; --retorno
	
	--Added by JMM 20240429
	get_resultado text = '';
	get_mensaje text = '';
	get_adicionales text = '';
	operacion_desc text = '';

	--Added 20240829 by JMM , Grupo de Gasto
	clave_gpogasto text = '';

	
begin
	-- Inicializacion de variables
	folio_operacion := 0;
	resultado := '';
	adicionales := '';

	--Documento
	suc_id := (xpath('//document/k_sucn/r1/text()', dataxml))[1];
	/*
	genero := (xpath('//document/k_tipon/r1/text()', dataxml))[1];
	naturaleza := (xpath('//document/k_tipon/r2/text()', dataxml))[1];
	grupo := (xpath('//document/k_tipon/r3/text()', dataxml))[1];
	tipo := (xpath('//document/k_tipon/r4/text()', dataxml))[1];
	*/

	operacion_desc := coalesce((xpath('//document/operacion/text()', dataxml))[1],''); 

	fecha_operacion := coalesce((xpath('//document/k_fecha/text()', dataxml))[1]::text,'1800-01-01 00:00:00')::text;

	flag_gastos = '';
	if xpath_exists('//document/ambiente/schema/text()', dataxml) = true /*false*/ then 
		flag_gastos := coalesce((xpath('//document/ambiente/schema/text()',dataxml))[1]::text,'')::text;
	end if;

	if upper(flag_gastos) not in ('CXP_CONTR_REC_INTERNO','CXP_CONTR_REC_INTERNO_BAJA','CXP_DEPOSITO_INTERNO','CXP_DEPOSITO_INTERNO_BAJA') then
		raise exception '%', 'Se esta llamando a la funcion [ gpogasto_actualiza_montos ] desde una Operacion No Valida ...';
	end if;

	proveedor := coalesce((xpath('//document/k_clave/text()',dataxml))[1],'');

	if length(proveedor) = 0 then
		mensajeError := 'No se pudo obtener el Proveedor del Documento ...';
		raise exception '%',mensajeError;
	end if;

	--  * * * * *  Added 20240829 by JMM, Grupo de Gasto (Para CR)
	clave_gpogasto := '';
	if xpath_exists('//document/k_gpo_gasto/text()', dataxml) = true /*false*/ then 
		clave_gpogasto := coalesce((xpath('//document/k_gpo_gasto/text()',dataxml))[1]::text,'')::text;
	end if;
	--  * * * * *  End : Grupo de Gastos

	if length(clave_gpogasto) = 0 then
		mensajeError := 'No se pudo obtener el Grupo de Gasto del Documento ...';
		raise exception '%',mensajeError;
	end if;


	if upper(flag_gastos) in ('CXP_CONTR_REC_INTERNO','CXP_CONTR_REC_INTERNO_BAJA') then -- condition Added by JMM 20241015 
	
		totalReg := 0;
		select count(*) into totalReg from keplersc.kdgpcontra where sucursal_id = suc_id and grupo_id = clave_gpogasto::int ;
		if totalReg = 0 then
			mensajeError := 'El Grupo de Gasto No existe ...';
			raise exception '%',mensajeError;			
		end if;
		if totalReg > 1 then
			mensajeError := 'El Numero de Grupo debe ser unico ... Registros inconsistentes.';
			raise exception '%',mensajeError;			
		end if;
	
		select g.* into rec1 from keplersc.kdgpcontra g  
		inner join keplersc.kdxd k on g.proveedor_id = k.c2 and k.interno = 1 
		where g.sucursal_id = suc_id and g.grupo_id = clave_gpogasto::int /*and g.proveedor_id = proveedor*/;
	
	else

		select g.* into rec1 from keplersc.kdgpcontra g  
		inner join keplersc.kdxd k on g.proveedor_id = k.c2 and k.interno = 1 
		where g.sucursal_id = suc_id and g.grupo_id = clave_gpogasto::int and g.proveedor_id = proveedor;	
	
	end if;

	if not found then 
		mensajeError := 'El Grupo de Gasto No existe o No corresponde al Proveedor Interno ...';
		raise exception '%', mensajeError;
	else
		mensajeError := '';
		if upper(coalesce(rec1.estatus,'')) <> 'A' then
			mensajeError := /*mensajeError || ' | ' ||*/ 'El Grupo de Gasto No esta abierto o No esta disponible ...';
		end if;
			
		if length(mensajeError) > 0 then
			/*
			mensajeError := mensajeError || ' | ';
			mensajeError := trim(mensajeError);
			mensajeError := 'Se presentaron inconsistencias en KDM1 en los siguientes campos : ' || mensajeError; 
			*/
			raise exception '%', mensajeError;
		end if;
	end if;


	select sum(c16) into gastos from keplersc.kdm1 
	where c1 = suc_id and c2 = 'X' and c3 = 'A' and c4 = 12 
		and upper(coalesce(c43,'')) <> 'C' and grupo_id = clave_gpogasto::int;
	
	select sum(c16) into ingresos from keplersc.kdm1 
	where c1 = suc_id and c2 = 'X' and c3 = 'D' and c4 = 34 
		and upper(coalesce(c43,'')) <> 'C' and grupo_id = clave_gpogasto::int;	
	
	gastos := coalesce(gastos,0);

	ingresos := coalesce(ingresos,0);

	if gastos > ingresos and abs( (ingresos - gastos) ) > .10 then
		raise exception '%', 'El Importe del los Gastos No puede exceder al Importe Asignado al Gpo. de Gasto ...'	|| ' | ' || ' ' || ' | ' || ingresos || ' < ' || gastos;
	end if;

	if upper(flag_gastos) in ('CXP_CONTR_REC_INTERNO','CXP_CONTR_REC_INTERNO_BAJA') then -- condition Added by JMM 20241015 
	
		update keplersc.kdgpcontra 
		set importe_asignado = ingresos, importe_comprobado = gastos
		where sucursal_id = suc_id and grupo_id = clave_gpogasto::int /*and proveedor_id = proveedor*/;
	
	else

		update keplersc.kdgpcontra 
		set importe_asignado = ingresos, importe_comprobado = gastos
		where sucursal_id = suc_id and grupo_id = clave_gpogasto::int and proveedor_id = proveedor;
	
	end if;


	-- For Testing ...
	/*raise exception '%','El Gpo de Gasto fue Actualizado ...';*/

	resultado := 1;
	mensaje := '';
	adicionales := '';
	return query select resultado, mensaje, adicionales;

exception
	when others then
		resultado := 0;
		mensaje := 'gpogasto_actualiza_montos() ' || '['|| sqlstate || '] ' || sqlerrm;
		adicionales := '';
		return query select resultado, mensaje, adicionales;

END;
$function$
