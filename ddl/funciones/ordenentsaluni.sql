CREATE OR REPLACE FUNCTION keplersc.ordenentsaluni(dataxml xml)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
--Descripcion: Realiza crud de entradas y salidas de unidades se servicio
--Autor: Gad Miranda
--Fecha: 13/10/2023
--Bitacora de cambios

declare
	--Variables de definicion de documento
	k_sucursal text = '';
	k_tipo text = '';
	k_orden text = '';
    k_fecha_sal text ='';
    k_hora_sal text = '';
	k_fecha_hora_sal timestamp;
	k_km_sal numeric(6);
	k_usr_salida text = '';
    k_fec_reg_sal text = '';
    k_hora_reg_sal text = '';
	k_fec_hora_reg_sal timestamp;
	k_motivo_sal text = '';
    k_fecha_ent text = '';
    k_hora_ent text = '';
	k_fecha_hora_ent timestamp;
	k_km_ent numeric(6);
	k_usr_ent text = '';
    k_fec_reg_ent text = '';
    k_hora_reg_ent text = '';
    k_fec_hora_reg_ent timestamp;
	k_comentarios text ;

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

	select count(*) into totReg from keplersc.kdordentsaluni where sucursal=k_sucursal
		and tipo=k_tipo and orden=k_orden;
	if totReg > 0 then
		DELETE FROM keplersc.kdordentsaluni where sucursal=k_sucursal
		and tipo=k_tipo and orden=k_orden;
	end if;

    FOR indice IN 0.. k_n_renglon-1 LOOP
        k_fecha_sal := (xpath('//document/tabla/r' || indice || '/fecha_sal/text()', dataxml))[1];
        k_hora_sal := (xpath('//document/tabla/r' || indice || '/hora_sal/text()', dataxml))[1];

        k_fecha_hora_sal := to_timestamp(k_fecha_sal || ' ' || k_hora_sal, 'YYYY-MM-DD HH24:MI:SS');

        k_km_sal := (xpath('//document/tabla/r' || indice || '/km_sal/text()', dataxml))[1];
        k_usr_salida := (xpath('//document/tabla/r' || indice || '/usr_salida/text()', dataxml))[1];

        if k_usr_salida is null then
            k_usr_salida = usuario;
        end if;

        k_fec_reg_sal := (xpath('//document/tabla/r' || indice || '/fec_reg_sal/text()', dataxml))[1];

        if k_fec_reg_sal = '1900-01-01' then
            k_fec_reg_sal = null;
        end if;

        k_hora_reg_sal := (xpath('//document/tabla/r' || indice || '/hora_reg_sal/text()', dataxml))[1];

         if k_hora_reg_sal = '' then
            k_hora_reg_sal = null;
        end if;

        if k_fec_reg_sal is null and k_hora_reg_sal is null then 
            k_fec_hora_reg_sal := now();         
        else 
            k_fec_hora_reg_sal := to_timestamp (concat(k_fec_reg_sal,' ',k_hora_reg_sal),'yyyy-mm-dd HH24:MI');
        end if;

        k_motivo_sal := (xpath('//document/tabla/r' || indice || '/motivo_sal/text()', dataxml))[1];

        k_fecha_ent := (xpath('//document/tabla/r' || indice || '/fecha_ent/text()', dataxml))[1];
        if k_fecha_ent = '1900-01-01' then
            k_fecha_ent = null;
        end if;

        k_hora_ent := (xpath('//document/tabla/r' || indice || '/hora_ent/text()', dataxml))[1];

        k_fecha_hora_ent := to_timestamp(k_fecha_ent || ' ' || k_hora_ent, 'YYYY-MM-DD HH24:MI:SS');

        k_km_ent := (xpath('//document/tabla/r' || indice || '/km_ent/text()', dataxml))[1];
        k_usr_ent := (xpath('//document/tabla/r' || indice || '/usr_ent/text()', dataxml))[1];

        if k_usr_ent is null and k_fecha_ent is not null then
            k_usr_ent = usuario;
        end if;

        k_fec_reg_ent := (xpath('//document/tabla/r' || indice || '/fec_reg_ent/text()', dataxml))[1];

         if k_fec_reg_ent = '1900-01-01' then
            k_fec_reg_ent = null;
        end if;

        k_hora_reg_ent := (xpath('//document/tabla/r' || indice || '/hora_reg_ent/text()', dataxml))[1];


         if k_fec_reg_ent is null and k_hora_reg_ent is null and k_fecha_ent is not null and k_hora_ent is not null then 
            k_fec_hora_reg_ent := now();
        elsif k_fec_reg_ent is null and k_hora_reg_ent is null and k_fecha_ent is null then
            k_fec_hora_reg_ent := null;
        else 
            k_fec_hora_reg_ent := to_timestamp (concat(k_fec_reg_ent,' ',k_hora_reg_ent),'yyyy-mm-dd HH24:MI');
        end if;

        k_comentarios := COALESCE((xpath('//document/tabla/r' || indice || '/comentarios/text()', dataxml))[1], '');
       
	       
        INSERT INTO keplersc.kdordentsaluni
            (sucursal, tipo, orden, fecha_sal, km_sal, usr_salida, fec_reg_sal, motivo_sal, fecha_ent, km_ent, usr_ent, fec_reg_ent, comentarios)
        VALUES
            (k_sucursal, k_tipo, k_orden, k_fecha_hora_sal, k_km_sal, k_usr_salida, k_fec_hora_reg_sal
            , k_motivo_sal, k_fecha_hora_ent, k_km_ent, k_usr_ent, k_fec_hora_reg_ent, k_comentarios);
    END LOOP;

	resultado := 1;
	mensaje := 'Registro modificado: ';
	adicionales := '';
	return query select resultado, mensaje, adicionales;	

exception
	when others then
		resultado := 0;
		mensaje := 'ordenentsaluni() ' || '['|| sqlstate || '] ' || sqlerrm ;		
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
	
end;
$function$
