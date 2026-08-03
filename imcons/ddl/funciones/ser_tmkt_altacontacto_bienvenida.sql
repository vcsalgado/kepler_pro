CREATE OR REPLACE FUNCTION keplersc.ser_tmkt_altacontacto_bienvenida(dataxml xml, xmlkdmm xml, folio_operacion text)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$

--Descripcion: Genera contacto y graba registro inicial de evento de bienvenida
--Autor: Miriam Santana
--Fecha: 10/10/2023

declare
	--Variables de definicion de documento
	sucursal_id text;
	genero text;
	naturaleza text;
	grupo text;
	fecha_vale text; --yyyy-mm-dd
	tipo text;
	
	cve_inventario text;
	cve_cteprov text;
	cve_vendedor text;
	medio_contacto integer;
	motivo_contacto integer;
	tipo_servicio_tmkt integer;
	folio_contacto_nvo text;
	fecha_programacion date;
	asesor_elegido text;

	vin text;
	marca text;
	modelo text;
	anio_modelo text;
	color text;
	num_motor text;
	concesionario text;
	tmpXml xml;
	xmltmkt text='';
	totReg int = 0;
	
	--Variables de retorno
	resultado text;
	mensaje text;
	adicionales text;

	get_resultado text;
	get_mensaje text;
	get_adicionales text;

begin
	sucursal_id := (xpath('//document/k_sucn/r1/text()', dataxml))[1];
	--Tipo de documento
	genero := (xpath('//document/k_tipon/r1/text()', dataxml))[1];
	naturaleza := (xpath('//document/k_tipon/r2/text()', dataxml))[1];
	grupo := (xpath('//document/k_tipon/r3/text()', dataxml))[1];
	tipo := (xpath('//document/k_tipon/r4/text()', dataxml))[1];

	fecha_vale := coalesce((xpath('//document/k_fecha/text()', dataxml))[1]::text,'1800-01-01 00:00:00')::text;

	cve_inventario := upper((xpath('//document/k_inventario/text()', dataxml))[1]::text);	
	cve_cteprov := coalesce((xpath('//document/k_clave/text()', dataxml))[1]::text,'0')::text;
	cve_vendedor := coalesce((xpath('//document/k_vendedor/text()', dataxml))[1]::text,'')::text;

	--Datos del vehiculo
	if (substring(trim(cve_inventario),8,1)='N') then
		select trim(inf.c5),inf.c17,inf.c4,inf.c15,inf.c34,
			inf.c6,inf.c2
			into vin,marca,modelo,anio_modelo,color,
			num_motor,cve_inventario
			from keplersc.kdinf inf
			where inf.c1=sucursal_id and inf.c2=cve_inventario;
	else 
		if substring(trim(cve_inventario),8,1)='U' then
			select trim(inf.c5),inf.c85,inf.c4,inf.c87,inf.c34,
				inf.c6,inf.c2
				into vin,marca,modelo,anio_modelo,color,
				num_motor,cve_inventario
				from keplersc.kdinf inf
				where inf.c1=sucursal_id and inf.c2=cve_inventario;
		end if;
	end if;
	select c7 into concesionario from keplersc.kdcfdconfig where c1=sucursal_id;
	--Registro inicial para evento bienvenida
	select count(*) into totReg
		from keplersc.kdctasbienvser
		where c1=sucursal_id and c15=cve_inventario;

	if totReg = 0 then
		insert into keplersc.kdctasbienvser (
			c1,c4,c6,c7,c8,
			c9,c10,c14,c15,c16,
			c17,c29)
			values(
			sucursal_id,cve_cteprov,right(vin,8),marca,modelo,
			vin,anio_modelo,color,cve_inventario,now(),
			cve_vendedor,concesionario);
	else
		update keplersc.kdctasbienvser
			set c4 = cve_cteprov,
				c6 = right(vin,8),
				c7 = marca,
				c8 = modelo,
				c9 = vin,
				c10 = anio_modelo,
				c14 = color,
				c16 = now(),
				c17 = cve_vendedor,
				c29 = concesionario
			where c1=sucursal_id and c15=cve_inventario;
	end if;

	--No asignar por el momento a ningun asesor de telemarketing 
/*		select c1 into asesor_elegido 
			from keplersc.kdsercattmkt 
			where c3='A'
			order by c1 desc limit 1;
*/
	asesor_elegido := '';
	fecha_programacion := to_date(fecha_vale,'YYYY-MM-DD') + interval '1 month';
	motivo_contacto := 80;			--Evento Bienvenida
	tipo_servicio_tmkt := 10;		--Ventas
	medio_contacto := 0;			--Llamada

	select count(*) into totReg from keplersc.kdtmktser2
		where c1=sucursal_id and c7=80 and c14=right(vin,8);
	if totReg = 0 then
	--Crear contacto 
		xmltmkt := '<document>
						<k_tipon>
							<r1/>
							<r2/>
							<r3/>
							<r4/>
						</k_tipon>
						<ambiente>
							<uen>VEN</uen>
						</ambiente>
					</document>';
		tmpXml := xmltmkt::xml;			        	
		select * into get_resultado, get_mensaje, get_adicionales from keplersc.obtener_folio_documento(concat('TMKT.', sucursal_id),0,0, tmpXml);
						
		if get_resultado = '0' then
			raise exception '%',get_mensaje;
		end if;
		folio_contacto_nvo := get_mensaje; 
		
		insert into keplersc.kdtmktser2(
			c1,c2,c3,c4,c5,
			c6,c7,c8,c9,c11,
			c14,c18,c19,c20,
			c23,c24,c25,c26,
			c28) 
			values(
			sucursal_id,folio_contacto_nvo,asesor_elegido,0,fecha_programacion,
			10,motivo_contacto,0,0,'Evento de Bienvenida',
			right(vin,8),tipo_servicio_tmkt, 'P', cve_cteprov, 
			medio_contacto,now(),'A',to_date(fecha_vale,'YYYY-MM-DD'),
			0);
	else 
		update keplersc.kdtmktser2 
			set c5 = fecha_programacion,
				c20 =cve_cteprov, 
				c24 =now(),
				c26 =to_date(fecha_vale,'YYYY-MM-DD')
			where c1=sucursal_id and c7=80 and c14=right(vin,8);
	end if;	
	resultado := 1;
	mensaje := '';
	adicionales := '';
	return query select resultado, mensaje, adicionales;	

exception
	when others then
		resultado := 0;
		mensaje := 'ser_tmkt_altacontacto_bienvenida ' || '['|| sqlstate || '] ' || sqlerrm;
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
	
end;
$function$
