CREATE OR REPLACE FUNCTION keplersc.srv_cuest_pre(dataxml xml)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
--Descripcion: Realiza crud del catalogo de encuesta servicio
--Autor: Gad Miranda
--Fecha: 23/08/2023
--Bitacora de cambios
declare
	--Variables de definicion de documento
	k_sucursal text = '';
	k_tipo_actividad text = '';
	k_tipo_orden text = '';
	k_folio_orden text = '';
	k_clave_actividad text = '';
	k_descripcion text = '';
	k_resultado text = '';
	k_comentario text = '';
	k_fecha date;
	k_hora time;
	k_contacto text = '';



	totReg numeric(3);
	
   --Variables de retorno
	resultado text = '';
	mensaje text = '0';
    adicionales text = '';
	
begin 
	
	k_sucursal := (xpath('//document/k_suc_crud/text()', dataxml))[1];
	k_tipo_actividad := (xpath('//document/k_tipo_actividad_crud/text()', dataxml))[1];
	k_tipo_orden := (xpath('//document/k_tipo_orden_crud/text()', dataxml))[1];
	k_folio_orden := (xpath('//document/k_orden_crud/text()', dataxml))[1];

	
	select count(*) into totReg from keplersc.kdordcuest where sucursal=k_sucursal
		and tipo_actividad=k_tipo_actividad and tipo_orden=k_tipo_orden and folio_orden=k_folio_orden;
	if totReg > 0 then
		DELETE FROM keplersc.kdordcuest WHERE sucursal=k_sucursal and tipo_actividad=k_tipo_actividad
		and tipo_orden=k_tipo_orden and folio_orden=k_folio_orden;
	end if;

	if k_tipo_actividad = 'PRE' then

		k_clave_actividad := (xpath('//document/tbl_cuestionario/r0/clave/text()', dataxml))[1];
		k_descripcion     := (xpath('//document/tbl_cuestionario/r0/pregunta/text()', dataxml))[1];
		k_resultado       := (xpath('//document/tbl_cuestionario/r0/respuesta/text()', dataxml))[1];
		k_comentario := COALESCE((xpath('//document/tbl_cuestionario/r0/comentario/text()', dataxml))[1], '');

		insert into keplersc.kdordcuest
			(sucursal, tipo_actividad, tipo_orden, folio_orden
			,clave_actividad, descripcion, resultado, comentario)
		values (k_sucursal, k_tipo_actividad, k_tipo_orden, k_folio_orden
				,k_clave_actividad, k_descripcion, k_resultado, k_comentario);

		k_clave_actividad := (xpath('//document/tbl_cuestionario/r1/clave/text()', dataxml))[1];
		k_descripcion     := (xpath('//document/tbl_cuestionario/r1/pregunta/text()', dataxml))[1];
		k_resultado       := (xpath('//document/tbl_cuestionario/r1/respuesta/text()', dataxml))[1];
		k_comentario := COALESCE((xpath('//document/tbl_cuestionario/r1/comentario/text()', dataxml))[1], '');

		insert into keplersc.kdordcuest
			(sucursal, tipo_actividad, tipo_orden, folio_orden
			,clave_actividad, descripcion, resultado, comentario)
		values (k_sucursal, k_tipo_actividad, k_tipo_orden, k_folio_orden
				,k_clave_actividad, k_descripcion, k_resultado, k_comentario);

		k_clave_actividad := (xpath('//document/tbl_cuestionario/r2/clave/text()', dataxml))[1];
		k_descripcion     := (xpath('//document/tbl_cuestionario/r2/pregunta/text()', dataxml))[1];
		k_resultado       := (xpath('//document/tbl_cuestionario/r2/respuesta/text()', dataxml))[1];
		k_comentario := COALESCE((xpath('//document/tbl_cuestionario/r2/comentario/text()', dataxml))[1], '');

		insert into keplersc.kdordcuest
			(sucursal, tipo_actividad, tipo_orden, folio_orden
			,clave_actividad, descripcion, resultado, comentario)
		values (k_sucursal, k_tipo_actividad, k_tipo_orden, k_folio_orden
				,k_clave_actividad, k_descripcion, k_resultado, k_comentario);

		k_clave_actividad := (xpath('//document/tbl_cuestionario/r3/clave/text()', dataxml))[1];
		k_descripcion     := (xpath('//document/tbl_cuestionario/r3/pregunta/text()', dataxml))[1];
		k_resultado       := (xpath('//document/tbl_cuestionario/r3/respuesta/text()', dataxml))[1];
		k_comentario := COALESCE((xpath('//document/tbl_cuestionario/r3/comentario/text()', dataxml))[1], '');

		insert into keplersc.kdordcuest
			(sucursal, tipo_actividad, tipo_orden, folio_orden
			,clave_actividad, descripcion, resultado, comentario)
		values (k_sucursal, k_tipo_actividad, k_tipo_orden, k_folio_orden
				,k_clave_actividad, k_descripcion, k_resultado, k_comentario);

		k_clave_actividad := (xpath('//document/tbl_cuestionario/r4/clave/text()', dataxml))[1];
		k_descripcion     := (xpath('//document/tbl_cuestionario/r4/pregunta/text()', dataxml))[1];
		k_resultado       := (xpath('//document/tbl_cuestionario/r4/respuesta/text()', dataxml))[1];
		k_comentario := COALESCE((xpath('//document/tbl_cuestionario/r4/comentario/text()', dataxml))[1], '');

		insert into keplersc.kdordcuest
			(sucursal, tipo_actividad, tipo_orden, folio_orden
			,clave_actividad, descripcion, resultado, comentario)
		values (k_sucursal, k_tipo_actividad, k_tipo_orden, k_folio_orden
				,k_clave_actividad, k_descripcion, k_resultado, k_comentario);

		k_clave_actividad := (xpath('//document/tbl_cuestionario/r5/clave/text()', dataxml))[1];
		k_descripcion     := (xpath('//document/tbl_cuestionario/r5/pregunta/text()', dataxml))[1];
		k_resultado       := (xpath('//document/tbl_cuestionario/r5/respuesta/text()', dataxml))[1];
		k_comentario := COALESCE((xpath('//document/tbl_cuestionario/r5/comentario/text()', dataxml))[1], '');

		insert into keplersc.kdordcuest
			(sucursal, tipo_actividad, tipo_orden, folio_orden
			,clave_actividad, descripcion, resultado, comentario)
		values (k_sucursal, k_tipo_actividad, k_tipo_orden, k_folio_orden
				,k_clave_actividad, k_descripcion, k_resultado, k_comentario);

		k_clave_actividad := (xpath('//document/tbl_cuestionario/r6/clave/text()', dataxml))[1];
		k_descripcion     := (xpath('//document/tbl_cuestionario/r6/pregunta/text()', dataxml))[1];
		k_resultado       := (xpath('//document/tbl_cuestionario/r6/respuesta/text()', dataxml))[1];
		k_comentario := COALESCE((xpath('//document/tbl_cuestionario/r6/comentario/text()', dataxml))[1], '');

		insert into keplersc.kdordcuest
			(sucursal, tipo_actividad, tipo_orden, folio_orden
			,clave_actividad, descripcion, resultado, comentario)
		values (k_sucursal, k_tipo_actividad, k_tipo_orden, k_folio_orden
				,k_clave_actividad, k_descripcion, k_resultado, k_comentario);

		k_clave_actividad := (xpath('//document/tbl_cuestionario/r7/clave/text()', dataxml))[1];
		k_descripcion     := (xpath('//document/tbl_cuestionario/r7/pregunta/text()', dataxml))[1];
		k_resultado       := (xpath('//document/tbl_cuestionario/r7/respuesta/text()', dataxml))[1];
		k_comentario := COALESCE((xpath('//document/tbl_cuestionario/r7/comentario/text()', dataxml))[1], '');

		insert into keplersc.kdordcuest
			(sucursal, tipo_actividad, tipo_orden, folio_orden
			,clave_actividad, descripcion, resultado, comentario)
		values (k_sucursal, k_tipo_actividad, k_tipo_orden, k_folio_orden
				,k_clave_actividad, k_descripcion, k_resultado, k_comentario);

		k_clave_actividad := (xpath('//document/tbl_cuestionario/r8/clave/text()', dataxml))[1];
		k_descripcion     := (xpath('//document/tbl_cuestionario/r8/pregunta/text()', dataxml))[1];
		k_resultado       := (xpath('//document/tbl_cuestionario/r8/respuesta/text()', dataxml))[1];
		k_comentario := COALESCE((xpath('//document/tbl_cuestionario/r8/comentario/text()', dataxml))[1], '');

		insert into keplersc.kdordcuest
			(sucursal, tipo_actividad, tipo_orden, folio_orden
			,clave_actividad, descripcion, resultado, comentario)
		values (k_sucursal, k_tipo_actividad, k_tipo_orden, k_folio_orden
				,k_clave_actividad, k_descripcion, k_resultado, k_comentario);

		k_clave_actividad := (xpath('//document/tbl_cuestionario/r9/clave/text()', dataxml))[1];
		k_descripcion     := (xpath('//document/tbl_cuestionario/r9/pregunta/text()', dataxml))[1];
		k_resultado       := (xpath('//document/tbl_cuestionario/r9/respuesta/text()', dataxml))[1];
		k_comentario := COALESCE((xpath('//document/tbl_cuestionario/r9/comentario/text()', dataxml))[1], '');

		insert into keplersc.kdordcuest
			(sucursal, tipo_actividad, tipo_orden, folio_orden
			,clave_actividad, descripcion, resultado, comentario)
		values (k_sucursal, k_tipo_actividad, k_tipo_orden, k_folio_orden
				,k_clave_actividad, k_descripcion, k_resultado, k_comentario);


		k_clave_actividad := (xpath('//document/tbl_cuestionario/r10/clave/text()', dataxml))[1];
		k_descripcion     := (xpath('//document/tbl_cuestionario/r10/pregunta/text()', dataxml))[1];
		k_resultado       := (xpath('//document/tbl_cuestionario/r10/respuesta/text()', dataxml))[1];
		k_comentario := COALESCE((xpath('//document/tbl_cuestionario/r10/comentario/text()', dataxml))[1], '');

		insert into keplersc.kdordcuest
			(sucursal, tipo_actividad, tipo_orden, folio_orden
			,clave_actividad, descripcion, resultado, comentario)
		values (k_sucursal, k_tipo_actividad, k_tipo_orden, k_folio_orden
				,k_clave_actividad, k_descripcion, k_resultado, k_comentario);

	end if;


	if k_tipo_actividad = 'ENT' then

		k_clave_actividad := (xpath('//document/tbl_cuestionario/r0/clave/text()', dataxml))[1];
		k_descripcion     := (xpath('//document/tbl_cuestionario/r0/pregunta/text()', dataxml))[1];
		k_resultado       := (xpath('//document/tbl_cuestionario/r0/respuesta/text()', dataxml))[1];
		k_comentario := COALESCE((xpath('//document/tbl_cuestionario/r0/comentario/text()', dataxml))[1], '');

		insert into keplersc.kdordcuest
			(sucursal, tipo_actividad, tipo_orden, folio_orden
			,clave_actividad, descripcion, resultado, comentario)
		values (k_sucursal, k_tipo_actividad, k_tipo_orden, k_folio_orden
				,k_clave_actividad, k_descripcion, k_resultado, k_comentario);

		k_clave_actividad := (xpath('//document/tbl_cuestionario/r1/clave/text()', dataxml))[1];
		k_descripcion     := (xpath('//document/tbl_cuestionario/r1/pregunta/text()', dataxml))[1];
		k_resultado       := (xpath('//document/tbl_cuestionario/r1/respuesta/text()', dataxml))[1];
		k_comentario := COALESCE((xpath('//document/tbl_cuestionario/r1/comentario/text()', dataxml))[1], '');

		insert into keplersc.kdordcuest
			(sucursal, tipo_actividad, tipo_orden, folio_orden
			,clave_actividad, descripcion, resultado, comentario)
		values (k_sucursal, k_tipo_actividad, k_tipo_orden, k_folio_orden
				,k_clave_actividad, k_descripcion, k_resultado, k_comentario);

		k_clave_actividad := (xpath('//document/tbl_cuestionario/r2/clave/text()', dataxml))[1];
		k_descripcion     := (xpath('//document/tbl_cuestionario/r2/pregunta/text()', dataxml))[1];
		k_resultado       := (xpath('//document/tbl_cuestionario/r2/respuesta/text()', dataxml))[1];
		k_comentario := COALESCE((xpath('//document/tbl_cuestionario/r2/comentario/text()', dataxml))[1], '');

		insert into keplersc.kdordcuest
			(sucursal, tipo_actividad, tipo_orden, folio_orden
			,clave_actividad, descripcion, resultado, comentario)
		values (k_sucursal, k_tipo_actividad, k_tipo_orden, k_folio_orden
				,k_clave_actividad, k_descripcion, k_resultado, k_comentario);

		k_clave_actividad := (xpath('//document/tbl_cuestionario/r3/clave/text()', dataxml))[1];
		k_descripcion     := (xpath('//document/tbl_cuestionario/r3/pregunta/text()', dataxml))[1];
		k_resultado       := (xpath('//document/tbl_cuestionario/r3/respuesta/text()', dataxml))[1];
		k_comentario := COALESCE((xpath('//document/tbl_cuestionario/r3/comentario/text()', dataxml))[1], '');

		insert into keplersc.kdordcuest
			(sucursal, tipo_actividad, tipo_orden, folio_orden
			,clave_actividad, descripcion, resultado, comentario)
		values (k_sucursal, k_tipo_actividad, k_tipo_orden, k_folio_orden
				,k_clave_actividad, k_descripcion, k_resultado, k_comentario);

		k_clave_actividad := (xpath('//document/tbl_cuestionario/r4/clave/text()', dataxml))[1];
		k_descripcion     := (xpath('//document/tbl_cuestionario/r4/pregunta/text()', dataxml))[1];
		k_resultado       := (xpath('//document/tbl_cuestionario/r4/respuesta/text()', dataxml))[1];
		k_comentario := COALESCE((xpath('//document/tbl_cuestionario/r4/comentario/text()', dataxml))[1], '');

		insert into keplersc.kdordcuest
			(sucursal, tipo_actividad, tipo_orden, folio_orden
			,clave_actividad, descripcion, resultado, comentario)
		values (k_sucursal, k_tipo_actividad, k_tipo_orden, k_folio_orden
				,k_clave_actividad, k_descripcion, k_resultado, k_comentario);

		k_clave_actividad := (xpath('//document/tbl_cuestionario/r5/clave/text()', dataxml))[1];
		k_descripcion     := (xpath('//document/tbl_cuestionario/r5/pregunta/text()', dataxml))[1];
		k_resultado       := (xpath('//document/tbl_cuestionario/r5/respuesta/text()', dataxml))[1];
		k_comentario := COALESCE((xpath('//document/tbl_cuestionario/r5/comentario/text()', dataxml))[1], '');

		insert into keplersc.kdordcuest
			(sucursal, tipo_actividad, tipo_orden, folio_orden
			,clave_actividad, descripcion, resultado, comentario)
		values (k_sucursal, k_tipo_actividad, k_tipo_orden, k_folio_orden
				,k_clave_actividad, k_descripcion, k_resultado, k_comentario);

		k_clave_actividad := (xpath('//document/tbl_cuestionario/r6/clave/text()', dataxml))[1];
		k_descripcion     := (xpath('//document/tbl_cuestionario/r6/pregunta/text()', dataxml))[1];
		k_resultado       := (xpath('//document/tbl_cuestionario/r6/respuesta/text()', dataxml))[1];
		k_comentario := COALESCE((xpath('//document/tbl_cuestionario/r6/comentario/text()', dataxml))[1], '');

		insert into keplersc.kdordcuest
			(sucursal, tipo_actividad, tipo_orden, folio_orden
			,clave_actividad, descripcion, resultado, comentario)
		values (k_sucursal, k_tipo_actividad, k_tipo_orden, k_folio_orden
				,k_clave_actividad, k_descripcion, k_resultado, k_comentario);

		k_clave_actividad := (xpath('//document/tbl_cuestionario/r7/clave/text()', dataxml))[1];
		k_descripcion     := (xpath('//document/tbl_cuestionario/r7/pregunta/text()', dataxml))[1];
		k_resultado       := (xpath('//document/tbl_cuestionario/r7/respuesta/text()', dataxml))[1];
		k_comentario := COALESCE((xpath('//document/tbl_cuestionario/r7/comentario/text()', dataxml))[1], '');

		insert into keplersc.kdordcuest
			(sucursal, tipo_actividad, tipo_orden, folio_orden
			,clave_actividad, descripcion, resultado, comentario)
		values (k_sucursal, k_tipo_actividad, k_tipo_orden, k_folio_orden
				,k_clave_actividad, k_descripcion, k_resultado, k_comentario);

		k_clave_actividad := (xpath('//document/tbl_cuestionario/r8/clave/text()', dataxml))[1];
		k_descripcion     := (xpath('//document/tbl_cuestionario/r8/pregunta/text()', dataxml))[1];
		k_resultado       := (xpath('//document/tbl_cuestionario/r8/respuesta/text()', dataxml))[1];
		k_comentario := COALESCE((xpath('//document/tbl_cuestionario/r8/comentario/text()', dataxml))[1], '');

		insert into keplersc.kdordcuest
			(sucursal, tipo_actividad, tipo_orden, folio_orden
			,clave_actividad, descripcion, resultado, comentario)
		values (k_sucursal, k_tipo_actividad, k_tipo_orden, k_folio_orden
				,k_clave_actividad, k_descripcion, k_resultado, k_comentario);

		k_clave_actividad := (xpath('//document/tbl_cuestionario/r9/clave/text()', dataxml))[1];
		k_descripcion     := (xpath('//document/tbl_cuestionario/r9/pregunta/text()', dataxml))[1];
		k_resultado       := (xpath('//document/tbl_cuestionario/r9/respuesta/text()', dataxml))[1];
		k_comentario := COALESCE((xpath('//document/tbl_cuestionario/r9/comentario/text()', dataxml))[1], '');

		insert into keplersc.kdordcuest
			(sucursal, tipo_actividad, tipo_orden, folio_orden
			,clave_actividad, descripcion, resultado, comentario)
		values (k_sucursal, k_tipo_actividad, k_tipo_orden, k_folio_orden
				,k_clave_actividad, k_descripcion, k_resultado, k_comentario);


		k_clave_actividad := (xpath('//document/tbl_cuestionario/r10/clave/text()', dataxml))[1];
		k_descripcion     := (xpath('//document/tbl_cuestionario/r10/pregunta/text()', dataxml))[1];
		k_resultado       := (xpath('//document/tbl_cuestionario/r10/respuesta/text()', dataxml))[1];
		k_comentario := COALESCE((xpath('//document/tbl_cuestionario/r10/comentario/text()', dataxml))[1], '');

		insert into keplersc.kdordcuest
			(sucursal, tipo_actividad, tipo_orden, folio_orden
			,clave_actividad, descripcion, resultado, comentario)
		values (k_sucursal, k_tipo_actividad, k_tipo_orden, k_folio_orden
				,k_clave_actividad, k_descripcion, k_resultado, k_comentario);

		k_clave_actividad := (xpath('//document/tbl_cuestionario/r11/clave/text()', dataxml))[1];
		k_descripcion     := (xpath('//document/tbl_cuestionario/r11/pregunta/text()', dataxml))[1];
		k_resultado       := (xpath('//document/tbl_cuestionario/r11/respuesta/text()', dataxml))[1];
		k_comentario := COALESCE((xpath('//document/tbl_cuestionario/r11/comentario/text()', dataxml))[1], '');

		insert into keplersc.kdordcuest
			(sucursal, tipo_actividad, tipo_orden, folio_orden
			,clave_actividad, descripcion, resultado, comentario)
		values (k_sucursal, k_tipo_actividad, k_tipo_orden, k_folio_orden
				,k_clave_actividad, k_descripcion, k_resultado, k_comentario);

		k_clave_actividad := (xpath('//document/tbl_cuestionario/r12/clave/text()', dataxml))[1];
		k_descripcion     := (xpath('//document/tbl_cuestionario/r12/pregunta/text()', dataxml))[1];
		k_resultado       := (xpath('//document/tbl_cuestionario/r12/respuesta/text()', dataxml))[1];
		k_comentario := COALESCE((xpath('//document/tbl_cuestionario/r12/comentario/text()', dataxml))[1], '');

		insert into keplersc.kdordcuest
			(sucursal, tipo_actividad, tipo_orden, folio_orden
			,clave_actividad, descripcion, resultado, comentario)
		values (k_sucursal, k_tipo_actividad, k_tipo_orden, k_folio_orden
				,k_clave_actividad, k_descripcion, k_resultado, k_comentario);

		k_clave_actividad := (xpath('//document/tbl_cuestionario/r13/clave/text()', dataxml))[1];
		k_descripcion     := (xpath('//document/tbl_cuestionario/r13/pregunta/text()', dataxml))[1];
		k_resultado       := (xpath('//document/tbl_cuestionario/r13/respuesta/text()', dataxml))[1];
		k_comentario := COALESCE((xpath('//document/tbl_cuestionario/r13/comentario/text()', dataxml))[1], '');

		insert into keplersc.kdordcuest
			(sucursal, tipo_actividad, tipo_orden, folio_orden
			,clave_actividad, descripcion, resultado, comentario)
		values (k_sucursal, k_tipo_actividad, k_tipo_orden, k_folio_orden
				,k_clave_actividad, k_descripcion, k_resultado, k_comentario);

	end if;

	if k_tipo_actividad = 'PSFU' then

		k_clave_actividad := (xpath('//document/tbl_cuestionario/r0/clave/text()', dataxml))[1];
		k_descripcion     := (xpath('//document/tbl_cuestionario/r0/pregunta/text()', dataxml))[1];
		k_resultado       := (xpath('//document/tbl_cuestionario/r0/respuesta/text()', dataxml))[1];
		k_comentario := COALESCE((xpath('//document/tbl_cuestionario/r0/comentario/text()', dataxml))[1], '');

		insert into keplersc.kdordcuest
			(sucursal, tipo_actividad, tipo_orden, folio_orden
			,clave_actividad, descripcion, resultado, comentario)
		values (k_sucursal, k_tipo_actividad, k_tipo_orden, k_folio_orden
				,k_clave_actividad, k_descripcion, k_resultado, k_comentario);

		k_clave_actividad := (xpath('//document/tbl_cuestionario/r1/clave/text()', dataxml))[1];
		k_descripcion     := (xpath('//document/tbl_cuestionario/r1/pregunta/text()', dataxml))[1];
		k_resultado       := (xpath('//document/tbl_cuestionario/r1/respuesta/text()', dataxml))[1];
		k_comentario := COALESCE((xpath('//document/tbl_cuestionario/r1/comentario/text()', dataxml))[1], '');

		insert into keplersc.kdordcuest
			(sucursal, tipo_actividad, tipo_orden, folio_orden
			,clave_actividad, descripcion, resultado, comentario)
		values (k_sucursal, k_tipo_actividad, k_tipo_orden, k_folio_orden
				,k_clave_actividad, k_descripcion, k_resultado, k_comentario);

		k_clave_actividad := (xpath('//document/tbl_cuestionario/r2/clave/text()', dataxml))[1];
		k_descripcion     := (xpath('//document/tbl_cuestionario/r2/pregunta/text()', dataxml))[1];
		k_resultado       := (xpath('//document/tbl_cuestionario/r2/respuesta/text()', dataxml))[1];
		k_comentario := COALESCE((xpath('//document/tbl_cuestionario/r2/comentario/text()', dataxml))[1], '');

		insert into keplersc.kdordcuest
			(sucursal, tipo_actividad, tipo_orden, folio_orden
			,clave_actividad, descripcion, resultado, comentario)
		values (k_sucursal, k_tipo_actividad, k_tipo_orden, k_folio_orden
				,k_clave_actividad, k_descripcion, k_resultado, k_comentario);

		k_clave_actividad := (xpath('//document/tbl_cuestionario/r3/clave/text()', dataxml))[1];
		k_descripcion     := (xpath('//document/tbl_cuestionario/r3/pregunta/text()', dataxml))[1];
		k_resultado       := (xpath('//document/tbl_cuestionario/r3/respuesta/text()', dataxml))[1];
		k_comentario := COALESCE((xpath('//document/tbl_cuestionario/r3/comentario/text()', dataxml))[1], '');

		insert into keplersc.kdordcuest
			(sucursal, tipo_actividad, tipo_orden, folio_orden
			,clave_actividad, descripcion, resultado, comentario)
		values (k_sucursal, k_tipo_actividad, k_tipo_orden, k_folio_orden
				,k_clave_actividad, k_descripcion, k_resultado, k_comentario);

	end if;

	resultado := 1;
	mensaje := 'Registro modificado: ';
	adicionales := '';
	return query select resultado, mensaje, adicionales;	

exception
	when others then
		resultado := 0;
		mensaje := 'srv_cuest_pre() ' || '['|| sqlstate || '] ' || sqlerrm ;		
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
	
end;
$function$
