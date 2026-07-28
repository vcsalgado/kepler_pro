CREATE OR REPLACE FUNCTION keplersc.actualiza_estatus_campanas(dataxml xml)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
--Descripcion: Actualiza el estatus de las campanas en la tabla KDSERCAMPANA
--Autor: Miriam Santana
--Fecha: 11/11/2025
--Bitacora de cambios
declare
	--Variables de definicion de documento
	sucursal_id text = '';
	cve_serie text = '';
	cve_campana text = '';
	estatus text = '';
	fec_realiza text = '';
	otro_distribuidor text = '';
	totReg int = 0;

   --Variables de retorno
	resultado text = '';
	mensaje text = '0';
    adicionales text = '';
	
begin 
	sucursal_id := (xpath('//document/k_sucn/r1/text()', dataxml))[1];
	cve_serie := (xpath('//document/input_serie/text()', dataxml))[1];
	cve_campana := (xpath('//document/cve_campana/text()', dataxml))[1];
	estatus := (xpath('//document/estatus/text()', dataxml))[1];
	fec_realiza := (xpath('//document/fecha_realiza/text()', dataxml))[1];
	otro_distribuidor := coalesce((xpath('//document/otro_distribuidor/text()', dataxml))[1],'');

	if sucursal_id is null then 
		raise exception 'Debe seleccionar la sucursal';
	end if;
	if cve_serie is null then 
		raise exception 'Debe ingresar el no. de serie';
	end if;
	if cve_campana is null then 
		raise exception 'Debe seleccionar una campana';
	end if;
	if estatus is null then 
		raise exception 'Debe especificar el estatus';
	end if;
	if otro_distribuidor <> '' then
		if estatus <> 'OTRO DISTRIBUIDOR' then
			raise exception 'Si especifica el dato Otro distribuidor, el estatus debe ser OTRO DISTRIBUIDOR... Verifique';
		end if;
	end if;
	if estatus = 'REALIZADA' then
		if fec_realiza is null then
			raise exception 'Si el estatus es REALIZADA, debe especificar la fecha de realizacion... Verifique';
		end if;
	end if;
	if fec_realiza <> '' then
		if estatus <> 'REALIZADA' then
			raise exception 'Si especifica la fecha de realizacion, el estatus debe ser REALIZADA... Verifique';
		end if;
	end if;

	update keplersc.kdsercampana 
		set c4 = case 
			when estatus = 'PENDIENTE' then 0
			when estatus = 'REALIZADA' then 10
			when estatus = 'OTRO DISTRIBUIDOR' then 15 end,
			c5 = to_date(coalesce(fec_realiza,'1800-01-01'),'YYYY-MM-DD'),
			c6 = sucursal_id,
			c9 = otro_distribuidor
		where c2=cve_serie and c3=cve_campana;
	
	resultado := 1;
	mensaje := 'Registro actualizado:' || cve_campana;
	adicionales := '';
	return query select resultado, mensaje, adicionales;	

exception
	when others then
		resultado := 0;
		mensaje := 'actualiza_estatus_campanas() ' || '['|| sqlstate || '] ' || sqlerrm ;		
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
	
end;
$function$
