CREATE OR REPLACE FUNCTION keplersc.cat_crud_porcentajes(dataxml xml)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
--Descripcion: Realiza crud del catalogo de porcentajes
--Autor: Gad Miranda
--Fecha: 06/07/2023
--Bitacora de cambios
declare
	--Variables de definicion de documento
	k_tipo_operacion_crud text = '';
	k_com_seguro_crud numeric(15,2);
	k_com_g_ext_crud numeric(15,2);
	k_com_uti_accs_crud numeric(15,2);
	k_com_uti_otros_crud numeric(15,2);

	crud text = '';
	totReg numeric(1);
	
   --Variables de retorno
	resultado text = '';
	mensaje text = '0';
    adicionales text = '';
	
begin 
	
	k_tipo_operacion_crud := (xpath('//document/k_tipo_operacion_crud/r1/text()', dataxml))[1];
	k_com_seguro_crud := (xpath('//document/k_com_seguro_crud/text()', dataxml))[1];
	k_com_g_ext_crud := (xpath('//document/k_com_g_ext_crud/text()', dataxml))[1];
	k_com_uti_accs_crud := (xpath('//document/k_com_uti_accs_crud/text()', dataxml))[1];
	k_com_uti_otros_crud := (xpath('//document/k_com_uti_otros_crud/text()', dataxml))[1];

	crud := (xpath('//document/input_crud/text()', dataxml))[1];


	if crud = 'NUEVO' then
		select count(*) into totReg from keplersc.kdvpor where c1=k_tipo_operacion_crud ;
			if totReg > 0 then
   				raise exception 'Error, La clave de tipo de operacion ya existe';
			end if;

		insert into keplersc.kdvpor
			(c1,c2,c3,c4,c5) 
		values(	k_tipo_operacion_crud,k_com_seguro_crud,k_com_g_ext_crud
		,k_com_uti_accs_crud,k_com_uti_otros_crud);
	end if;

	if crud = 'MODIFICAR' then
		update keplersc.kdvpor as n
			set c2=k_com_seguro_crud,
			c3=k_com_g_ext_crud,
			c4=k_com_uti_accs_crud,
			c5=k_com_uti_otros_crud
			where c1=k_tipo_operacion_crud;
	end if;

	if crud = 'ELIMINAR' then
		delete from keplersc.kdvpor
			where  c1=k_tipo_operacion_crud ;
	end if;

	resultado := 1;
	mensaje := 'Registro agregado: ' || k_tipo_operacion_crud ;
	adicionales := '';
	return query select resultado, mensaje, adicionales;	

exception
	when others then
		resultado := 0;
		mensaje := 'cat_crud_tisan() ' || '['|| sqlstate || '] ' || sqlerrm ;		
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
	
end;
$function$
