CREATE OR REPLACE FUNCTION keplersc.conf_lealtad_crud(dataxml xml)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
--Descripcion: crud Configuracion Lealtad
--Autor: Luis Leal
--Fecha: 17/10/2024
--Bitacora de cambios
declare
	--Variables de definicion de documento
	ult_ident numeric;
	ident numeric;
	k_suc text = '';
	porcentaje_1 numeric;
	porcentaje_2 numeric;
	porcentaje_3 numeric;
	porcentaje_4 numeric;

	crud text = '';
	totReg int = 0;
	
   --Variables de retorno
	resultado text = '';
	mensaje text = '0';
    adicionales text = '';
	
begin 
	
	ident := (xpath('//document/ident/text()', dataxml))[1];
	k_suc := (xpath('//document/k_sucN/r1/text()', dataxml))[1];
	porcentaje_1 := coalesce((xpath('//document/porcentaje_1/text()', dataxml))[1], '0');
	porcentaje_2 := coalesce((xpath('//document/porcentaje_2/text()', dataxml))[1], '0');
	porcentaje_3 := coalesce((xpath('//document/porcentaje_3/text()', dataxml))[1], '0');
	porcentaje_4 := coalesce((xpath('//document/porcentaje_4/text()', dataxml))[1], '0');

	crud := (xpath('//document/input_crud/text()', dataxml))[1];

	if crud = 'NUEVO' then
		raise exception 'Accion no implementada';

/* --Solo se permite un registro por sucursal, el crud se maneja como modificacion 
		select c1 into ult_ident from keplersc.kdconflealtad order by c1 desc limit 1;
		if found then
			ult_ident = ult_ident + 1;
		else
			ult_ident = 1;
		end if;
		
		insert into keplersc.kdconflealtad
			(c1,c2,c3,c4,c5,c6) 
		values(ult_ident,k_suc,porcentaje_1,porcentaje_2,porcentaje_3,porcentaje_4);
*/
	end if;

	if crud = 'MODIFICAR' then
		select count(*)  into totReg from keplersc.kdconflealtad where c1=ident and c2=k_suc;
		if totReg=1 then
			update keplersc.kdconflealtad set 
				c3=porcentaje_1,
				c4=porcentaje_2,
				c5=porcentaje_3,
				c6=porcentaje_4
				where c1=ident and c2= k_suc;
		else
			insert into keplersc.kdconflealtad
				(c1,c2,c3,c4,c5,c6) 
			values(ident,k_suc,porcentaje_1,porcentaje_2,porcentaje_3,porcentaje_4);
			ult_ident = 1;
		end if;
		



	end if;

	if crud = 'ELIMINAR' then
		raise exception 'Accion no implementada';
		--delete from keplersc.kdconflealtad where  c1=ident and c2= k_suc;
	end if;

	resultado := 1;
	mensaje := 'Registro agregado: ' || ident ;
	adicionales := '';
	return query select resultado, mensaje, adicionales;	

exception
	when others then
		resultado := 0;
		mensaje := 'conf_lealtad_crud() ' || '['|| sqlstate || '] ' || sqlerrm ;		
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
	
end;
$function$
