CREATE OR REPLACE FUNCTION keplersc.cat_comis_ven_esqveh_crud(dataxml xml)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
--Descripcion: CRUD de tabla kdvesqveh
--Autor: Victor Salgado
--Fecha: 22/01/2024
--Bitacora de cambios
declare
	--Variables de definicion de documento
	k_sucn text = '';
	k_esquema text = '';
	k_oper text = '';
	k_tipove text = '';
	k_tipo_comis text = '';
	crud text = '';
	totReg numeric(1);
	
   --Variables de retorno
	resultado text = '';
	mensaje text = '0';
    adicionales text = '';
	
begin 
	
	k_sucn := (xpath('//document/k_sucn/r1/text()', dataxml))[1];
	k_esquema := (xpath('//document/k_esquema/r1/text()', dataxml))[1];
	k_oper := (xpath('//document/k_oper/r1/text()', dataxml))[1];
	k_tipove := (xpath('//document/k_tipove/r1/text()', dataxml))[1];
	k_tipo_comis := (xpath('//document/k_tipo_comis/r1/text()', dataxml))[1];
	crud := (xpath('//document/input_crud/text()', dataxml))[1];
	if crud = 'NUEVO' or crud='MODIFICAR' then
		select count(*) into totReg from keplersc.kdvesqveh k  
			where c1=k_sucn and c2=k_esquema and c3=k_oper and c4=k_tipove and c5=k_tipo_comis ;
		if totReg > 0 then
   			raise exception 'Error, la configuración ya existe.';
		end if;
	end if;

	if crud = 'NUEVO' then
		select count(*) into totReg from keplersc.kdvesqveh k  
			where c1=k_sucn and c2=k_esquema and c3=k_oper and c4=k_tipove ;
			if totReg > 0 then
   				raise exception 'Error, la configuración ya existe.';
			end if;

		insert into keplersc.kdvesqveh
			(c1,c2,c3,c4,c5) 
		values(k_sucn,k_esquema,k_oper,k_tipove,k_tipo_comis);
		mensaje := 'Registro agregado.';	
	end if;

	if crud = 'MODIFICAR' then
		update keplersc.kdvesqveh set c5=k_tipo_comis
			where c1=k_sucn and c2=k_esquema and c3=k_oper and c4=k_tipove;
		mensaje := 'Registro modificado.';
--raise exception 'Modificado. 1:% 2:% 3:% 4:% 5:%',k_sucn,k_esquema,k_oper,k_tipove,k_tipo_comis;
	
	end if;

	if crud = 'ELIMINAR' then
		delete from keplersc.kdvesqveh 
			where c1=k_sucn and c2=k_esquema and c3=k_oper and c4=k_tipove and c5=k_tipo_comis ;
		mensaje := 'Registro eliminado.';
--raise exception 'Eliminado. 1:% 2:% 3:% 4:% 5:%',k_sucn,k_esquema,k_oper,k_tipove,k_tipo_comis;
	
	end if;

	resultado := 1;
	adicionales := '';
	return query select resultado, mensaje, adicionales;	

exception
	when others then
		resultado := 0;
		mensaje := 'cat_comis_ven_esqveh_crud() ' || '['|| sqlstate || '] ' || sqlerrm ;		
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
end;
$function$
