CREATE OR REPLACE FUNCTION keplersc.com_datos_csi_crud(dataxml xml)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
--Descripcion: Realiza crud del los catalogos de datos CSI KDSCSI y KDVCSI
--Autor: Miriam Santana
--Fecha: 18/01/2023
--Bitacora de cambios
declare
	--Variables de definicion de documento
	anio text = '';
	mes text = '';
	sucursal_id text ='';
	csi_servicio text = '';
	csi_ventas text = '';
	crud text = '';

   --Variables de retorno
	resultado text = '';
	mensaje text = '0';
    adicionales text = '';
	
begin 
	
	anio := (xpath('//document/k_anio/text()', dataxml))[1];
	mes := (xpath('//document/k_mes/text()', dataxml))[1];
	csi_servicio := coalesce((xpath('//document/k_csi_servicio/text()', dataxml))[1],'0');
	csi_ventas := coalesce((xpath('//document/k_csi_ventas/text()', dataxml))[1],'0');
	sucursal_id := (xpath('//document/k_sucn/text()', dataxml))[1];
	crud := (xpath('//document/input_crud/text()', dataxml))[1];

	if crud <> 'Eliminar' then
		if anio is null then 
			raise exception 'Debe ingresar el año';
		end if;
		if mes is null then 
			raise exception 'Debe ingresar el mes';
		end if;
	end if; 

	if crud = 'Nuevo' then		
		insert into keplersc.kdscsi  
			(c1,c2,c3,c5) 
		values(
			sucursal_id,anio,mes,csi_servicio::decimal);
		insert into keplersc.kdvcsi 
			(c1,c2,c3,c5) 
		values(
			sucursal_id,anio,mes,csi_ventas::decimal);
	end if;

	if crud = 'Modificar' then
		update keplersc.kdscsi 
			set c5=csi_servicio::decimal
			where c1=sucursal_id and c2=anio and c3=mes;
		update keplersc.kdvcsi 
			set c5=csi_ventas::decimal 
			where c1=sucursal_id and c2=anio and c3=mes;
	end if;

	if crud = 'Eliminar' then
		delete from keplersc.kdscsi
			where c1=sucursal_id and c2=anio and c3=mes;
		delete from keplersc.kdvcsi 
			where c1=sucursal_id and c2=anio and c3=mes;
	end if;

	resultado := 1;
	mensaje := '';
	adicionales := '';
	return query select resultado, mensaje, adicionales;	

exception
	when others then
		resultado := 0;
		mensaje := 'com_datos_csi_crud() ' || '['|| sqlstate || '] ' || sqlerrm ;		
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
	
end;
$function$
