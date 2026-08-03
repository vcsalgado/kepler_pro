CREATE OR REPLACE FUNCTION keplersc.verify_facturacion_orden(dataxml xml, xmlkdmm xml)
 RETURNS TABLE(resultado text)
 LANGUAGE plpgsql
AS $function$
declare 
--Descripcion: Realiza validacion de permisos de usuario para elaborar facturas o notas de crÃ©dito de Ã³rdenes.
--			   Resuelve VERIFY_FACTURACION_ORDEN
--Autor: Miriam Santana
--Fecha: 12/14/2022

	--Variables de definicion de documento
	sucursal_id text = '';
	genero text = '';
	naturaleza text = '';
	grupo text = '';
	tipo text = '';
	cve_usuario text = '';
	uen text ='';

	--varibales de uso general
	tipo_trabajo text;
	tipo_orden text;
	privilegios_conta text;

	resultado text;

begin

	sucursal_id := (xpath('//document/k_sucn/r1/text()', dataxml))[1];
	genero := (xpath('//document/k_tipon/r1/text()', dataxml))[1];
	naturaleza := (xpath('//document/k_tipon/r2/text()', dataxml))[1];
	grupo := (xpath('//document/k_tipon/r3/text()', dataxml))[1];
	tipo := (xpath('//document/k_tipon/r4/text()', dataxml))[1];
	cve_usuario := (xpath('//document/movimiento/usuario/text()', dataxml))[1];	
	tipo_orden := (xpath('//document/k_tipo_orden/r1/text()',dataxml))[1];
	uen := coalesce((xpath('//document/ambiente/uen/text()',dataxml))[1],'');
	--raise notice 'VERIFY FACTURACION';	
	resultado = '0';
	if uen='SER' and genero='U' and (xpath('//row/c11/text()', xmlKDMM))[1]::text = 'S' then	
		select c2 into tipo_trabajo from keplersc.kdmargen
			where c1=tipo_orden;
		if found then
			 if tipo_trabajo='I' or tipo_trabajo='Q' then
			 	select c6 into privilegios_conta from keplersc.kdusrinfo
			 		where c1=cve_usuario;
	
			 	if found then
			 		if privilegios_conta <>'S' then 
	                    if naturaleza = 'D' then 
	                    	raise exception 'Su usuario No tiene privilegios para Facturar Ordenes internas o previas. Contacte a Contabilidad';
	                    else
	                   	raise exception 'Su usuario No tiene privilegios para hacer Notas de Crédito de Ordenes internas o previas. Contacte a Contabilidad';
	                    end if;   
                	end if; 
			 	end if;
			 end if;
		end if;
	end if;

	resultado ='1';

	return query select resultado;	
			
	
end;
$function$
