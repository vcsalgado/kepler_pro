CREATE OR REPLACE FUNCTION keplersc.srv_cuest_pre(dataxml xml)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
--Descripcion: Realiza crud del catalogo de encuesta servicio
--Autor: Gad Miranda
--Fecha: 23/08/2023
--Bitacora de cambios
	--Fecha: 06/09/2023
	-- Modificado metodo para realizar la rutina de estatico a dinamico 
	-- con un bucle for
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
	usuario text ;

	k_n_renglon int;
	indice int;
	totReg numeric(3);
	
   --Variables de retorno
	resultado text = '';
	mensaje text = '0';
    adicionales text = '';
	
begin 
	k_n_renglon := (xpath('//document/k_n_renglon/text()', dataxml))[1];
	k_sucursal := (xpath('//document/k_suc_crud/text()', dataxml))[1];
	k_tipo_actividad := (xpath('//document/k_tipo_actividad_crud/text()', dataxml))[1];
	k_tipo_orden := (xpath('//document/k_tipo_orden_crud/text()', dataxml))[1];
	k_folio_orden := (xpath('//document/k_orden_crud/text()', dataxml))[1];
	usuario := (xpath('//document/usuario/text()', dataxml))[1];


	select count(*) into totReg from keplersc.kdordcuest where col_sucursal=k_sucursal
		and col_tipo_actividad=k_tipo_actividad and col_tipo_orden=k_tipo_orden and col_folio_orden=k_folio_orden;
	if totReg > 0 then
		DELETE FROM keplersc.kdordcuest WHERE col_sucursal=k_sucursal and col_tipo_actividad=k_tipo_actividad
		and col_tipo_orden=k_tipo_orden and col_folio_orden=k_folio_orden;
	end if;

    FOR indice IN 0.. k_n_renglon LOOP
        k_clave_actividad := (xpath('//document/tbl_cuestionario/r' || indice || '/clave/text()', dataxml))[1];
        k_descripcion := (xpath('//document/tbl_cuestionario/r' || indice || '/pregunta/text()', dataxml))[1];
        k_resultado := (xpath('//document/tbl_cuestionario/r' || indice || '/respuesta/text()', dataxml))[1];
        k_comentario := COALESCE((xpath('//document/tbl_cuestionario/r' || indice || '/comentario/text()', dataxml))[1], '');
       
       if k_clave_actividad is null and k_descripcion is null then 
       	continue;
       end if;
		       
        INSERT INTO keplersc.kdordcuest
            (col_sucursal, col_tipo_actividad, col_tipo_orden, col_folio_orden, col_clave_actividad, col_descripcion, col_resultado, col_comentario)
        VALUES
            (k_sucursal, k_tipo_actividad, k_tipo_orden, k_folio_orden, k_clave_actividad, k_descripcion, k_resultado, k_comentario);
    END LOOP;
   
   
    if k_tipo_actividad = 'PSFU' then
      update keplersc.kdencprog set c6=20, c7=current_date, c8= left(current_time::text, 8) , c9=usuario 
      where c1=k_sucursal and c2=k_tipo_orden and c3=k_folio_orden;
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
