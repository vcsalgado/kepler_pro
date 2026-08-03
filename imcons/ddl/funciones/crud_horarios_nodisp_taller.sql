CREATE OR REPLACE FUNCTION keplersc.crud_horarios_nodisp_taller(dataxml xml)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
--Descripcion: Crud Horarios No Disponibles Taller
--Autor: Luis Leal
--Fecha: 10/06/2024
--Bitacora de cambios
declare
	--Variables de definicion de documento
    suc text = '';
	fcha text = '';
    horario_ini text = '';
   	horario_fin text = '';
   	mins text;
   	crud text = '';

    
   --Variables de retorno
	resultado text = '';
	mensaje text = '0';
    adicionales text = '';
	
begin 
	
    suc := (xpath('//document/sucursal_id/text()', dataxml))[1];
   	fcha := coalesce((xpath('//document/k_fecha/text()', dataxml))[1],'');
	horario_ini := coalesce((xpath('//document/k_horario_ini/text()', dataxml))[1],'');
   	horario_fin := coalesce((xpath('//document/k_horario_fin/text()', dataxml))[1],'');
    crud := (xpath('//document/input_crud/text()', dataxml))[1];

      
   	if fcha = ''  then 
		raise exception 'Debes ingresar la fecha';
	end if;
   
   	if horario_ini = '' or horario_fin = '' then 
		raise exception 'Debes ingresar horario inicial y final';
	end if;

	--valida minutos
	mins := right(left(horario_ini::text,5)::text,2);
	if mins <> '00' and mins <> '15' and mins <> '30' and mins <> '45' then 
		raise exception 'Horario Ini solo se permiten los siguientes minutos 00,15,30,45 '; 
	end if;

	--valida minutos
	mins := right(left(horario_fin::text,5)::text,2);
	if mins <> '00' and mins <> '15' and mins <> '30' and mins <> '45' then 
		raise exception 'Horario Fin solo se permiten los siguientes minutos 00,15,30,45 '; 
	end if;


	if crud = 'NUEVO' then
		insert into keplersc.horario_nodisp_taller values(suc,fcha::date,horario_ini,horario_fin);
	end if;

	if crud = 'ELIMINAR' then
			delete from keplersc.horario_nodisp_taller
			where sucursal=suc and fecha=fcha::date 
			and horario_nodisp_inicio=horario_ini 
			and horario_nodisp_fin=horario_fin ;
	end if;


	resultado := 1;
	mensaje := 'Registro agregado:' || fcha;
	adicionales := '';
	return query select resultado, mensaje, adicionales;	

exception
	when others then
		resultado := 0;
		mensaje := 'crud_horarios_nodisp_taller() ' || '['|| sqlstate || '] ' || sqlerrm ;		
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
	
end;
$function$
