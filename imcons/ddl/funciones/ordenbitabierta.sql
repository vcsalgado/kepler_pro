CREATE OR REPLACE FUNCTION keplersc.ordenbitabierta(dataxml xml)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
--Descripcion: Realiza crud de la bitacora de servicio
--Autor: Gad Miranda
--Fecha: 18/10/2023
--Bitacora de cambios

declare
	--Variables de definicion de documento
	k_sucursal text = '';
	k_tipo text = '';
	k_orden text = '';
	k_usr text = '';
    k_fec_reg text = '';
    k_hora_reg text = '';
	k_fec_hora_reg timestamp;
	k_actividad text ;

	k_n_renglon int;
    usuario text;
	indice int;
	totReg numeric(3);
	
   --Variables de retorno
	resultado text = '';
	mensaje text = '0';
    adicionales text = '';
	
begin 
	k_n_renglon := (xpath('//document/k_n_renglon/text()', dataxml))[1];
    k_sucursal := (xpath('//document/k_sucN/r1/text()', dataxml))[1];
    k_tipo := (xpath('//document/tipo_orden_bus/r0/text()', dataxml))[1];
    k_orden := (xpath('//document/folio_orden_bus/text()', dataxml))[1];
    usuario := (xpath('//document/usuario/text()', dataxml))[1];

	select count(*) into totReg from keplersc.kdordenbitabierta where sucursal=k_sucursal
		and tipo=k_tipo and orden=k_orden;
	if totReg > 0 then
		DELETE FROM keplersc.kdordenbitabierta where sucursal=k_sucursal
		and tipo=k_tipo and orden=k_orden;
	end if;

    FOR indice IN 0.. k_n_renglon-1 LOOP

        k_usr := (xpath('//document/tabla/r' || indice || '/usr/text()', dataxml))[1];

        if k_usr is null then
            k_usr = usuario;
        end if;

        k_fec_reg := (xpath('//document/tabla/r' || indice || '/fec_reg/text()', dataxml))[1];

        if k_fec_reg = '1900-01-01' then
            k_fec_reg = null;
        end if;

        k_hora_reg := (xpath('//document/tabla/r' || indice || '/hora_reg/text()', dataxml))[1];

         if k_hora_reg = '' then
            k_hora_reg = null;
        end if;

        if k_fec_reg is null and k_hora_reg is null then 
            k_fec_hora_reg := now();         
        else 
            k_fec_hora_reg := to_timestamp (concat(k_fec_reg,' ',k_hora_reg),'yyyy-mm-dd HH24:MI');
        end if;

        k_actividad := COALESCE((xpath('//document/tabla/r' || indice || '/actividad/text()', dataxml))[1], '');
       
	       
        INSERT INTO keplersc.kdordenbitabierta
            (sucursal, tipo, orden, fec_hora_reg, usr, actividad)
        VALUES
            (k_sucursal, k_tipo, k_orden, k_fec_hora_reg, k_usr, k_actividad);
    END LOOP;

	resultado := 1;
	mensaje := 'Registro modificado: ';
	adicionales := '';
	return query select resultado, mensaje, adicionales;	

exception
	when others then
		resultado := 0;
		mensaje := 'kdordenbitabierta() ' || '['|| sqlstate || '] ' || sqlerrm ;		
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
	
end;
$function$
