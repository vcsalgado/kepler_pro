CREATE OR REPLACE FUNCTION keplersc.cat_vpaquetes_crud(dataxml xml)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$

--Descripcion: Realiza crud en el catálogo de paquetes de vehículos KDPAQ
--Autor: Miriam Santana
--Fecha: 02/08/2023
--Bitacora de cambios
declare
	--Variables de definicion de documento
	cve_vehiculo text;
	pq01 text = '';
	pq02 text = '';
	pq03 text = '';
	pq04 text = '';
	pq05 text = '';
	pq06 text = '';
	pq07 text = '';
	pq08 text = '';
	pq09 text = '';
	pq10 text = '';
	pq11 text = '';
	pq12 text = '';
	pq13 text = '';
	pq14 text = '';
	pq15 text = '';
	pq16 text = '';
	pq17 text = '';
	pq18 text = '';
	pq19 text = '';
	crud text = '';

begin
	cve_vehiculo := (xpath('//document/k_clave/text()', dataxml))[1];
	pq01 := coalesce((xpath('//document/tabla/r0/c2/text()', dataxml))[1]::text,'');
	pq02 := coalesce((xpath('//document/tabla/r0/c3/text()', dataxml))[1]::text,'');
	pq03 := coalesce((xpath('//document/tabla/r0/c4/text()', dataxml))[1]::text,'');
	pq04 := coalesce((xpath('//document/tabla/r0/c5/text()', dataxml))[1]::text,'');
	pq05 := coalesce((xpath('//document/tabla/r0/c6/text()', dataxml))[1]::text,'');
	pq06 := coalesce((xpath('//document/tabla/r0/c7/text()', dataxml))[1]::text,'');
	pq07 := coalesce((xpath('//document/tabla/r0/c8/text()', dataxml))[1]::text,'');
	pq08 := coalesce((xpath('//document/tabla/r0/c9/text()', dataxml))[1]::text,'');
	pq09 := coalesce((xpath('//document/tabla/r0/c10/text()', dataxml))[1]::text,'');
	pq10 := coalesce((xpath('//document/tabla/r0/c11/text()', dataxml))[1]::text,'');
	pq11 := coalesce((xpath('//document/tabla/r0/c12/text()', dataxml))[1]::text,'');
	pq12 := coalesce((xpath('//document/tabla/r0/c13/text()', dataxml))[1]::text,'');
	pq13 := coalesce((xpath('//document/tabla/r0/c14/text()', dataxml))[1]::text,'');
	pq14 := coalesce((xpath('//document/tabla/r0/c15/text()', dataxml))[1]::text,'');
	pq15 := coalesce((xpath('//document/tabla/r0/c16/text()', dataxml))[1]::text,'');
	pq16 := coalesce((xpath('//document/tabla/r0/c17/text()', dataxml))[1]::text,'');
	pq17 := coalesce((xpath('//document/tabla/r0/c18/text()', dataxml))[1]::text,'');
	pq18 := coalesce((xpath('//document/tabla/r0/c19/text()', dataxml))[1]::text,'');
	pq19 := coalesce((xpath('//document/tabla/r0/c20/text()', dataxml))[1]::text,'');
	crud := (xpath('//document/input_crud/text()', dataxml))[1];
		
	if cve_vehiculo is null then
		raise exception 'Debe especificar una clave de vehículo';
	else
		if crud = 'NUEVO' then
			--Elimina registros de KDPAQ
			delete from keplersc.kdpaq 
				where c1=cve_vehiculo;
					
			--Insertar registros en KDPAQ
			insert into keplersc.kdpaq 
				(c1,c2,c3,c4,c5,
				c6,c7,c8,c9,c10,
				c11,c12,c13,c14,c15,
				c16,c17,c18,c19,c20)
				values
				(cve_vehiculo,pq01,pq02,pq03,pq04,
				pq05,pq06,pq07,pq08,pq09,
				pq10,pq11,pq12,pq13,pq14,
				pq15,pq16,pq17,pq18,pq19);
		end if;	
		if crud = 'MODIFICAR' then		
			--Modifica registros en KDPAQ
			update keplersc.kdpaq set 
				c2=pq01,
				c3=pq02,
				c4=pq03,
				c5=pq04,
				c6=pq05,
				c7=pq06,
				c8=pq07,
				c9=pq08,
				c10=pq09,
				c11=pq10,
				c12=pq11,
				c13=pq12,
				c14=pq13,
				c15=pq14,
				c16=pq15,
				c17=pq16,
				c18=pq17,
				c19=pq18,
				c20=pq19
			where c1=cve_vehiculo;
		end if;	
	end if;
		
	resultado := 1;
	mensaje := 'Registro agregado:' || cve_vehiculo;
	adicionales := '';
	return query select resultado, mensaje, adicionales;	

exception
	when others then
		resultado := 0;
		mensaje := 'cat_vpaquetes_crud() ' || '['|| sqlstate || '] ' || sqlerrm ;
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
		
end;
$function$
