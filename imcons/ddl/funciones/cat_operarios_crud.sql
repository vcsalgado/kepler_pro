CREATE OR REPLACE FUNCTION keplersc.cat_operarios_crud(dataxml xml)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
--Descripcion: Realiza crud del catalogo de líneas KDOPER
--Autor: Jose Mendoza
--Fecha: 01/02/2023
--Bitacora de cambios
declare
	--Variables de definicion de documento
	cve_oper text = '';
	nombre text = '';

	k_activo text = '';
	k_usuario text = '';
	k_dir text = '';
	k_col text = '';
	k_pobl text = '';
	k_telcasa text = '';
	k_celpers text = '';
	k_comms1 text = '';
	k_comms2 text = '';
	k_comms3 text = '';

	k_tipo text = '';
	k_lava text = '';
	k_ayud text = '';
	k_jefe text = '';
	k_clasif text = '';
	k_nomina text = '';

	crud text = '';

   	--variables generales
	totReg int;
	val_activo text = '';
	val_tipo text = '';
	
   	--Variables de retorno
	resultado text = '';
	mensaje text = '0';
    adicionales text = '';
	
begin 
	
	cve_oper := (xpath('//document/k_clave/text()', dataxml))[1];
	nombre := coalesce((xpath('//document/k_nombre/text()', dataxml))[1],'');

	k_activo := coalesce((xpath('//document/k_activo/text()', dataxml))[1],'');
	k_usuario := coalesce((xpath('//document/k_usuario/text()', dataxml))[1],'');
	k_dir := coalesce((xpath('//document/k_dir/text()', dataxml))[1],'');
	k_col := coalesce((xpath('//document/k_col/text()', dataxml))[1],'');
	k_pobl := coalesce((xpath('//document/k_pobl/text()', dataxml))[1],'');
	k_telcasa := coalesce((xpath('//document/k_telcasa/text()', dataxml))[1],'');
	k_celpers := coalesce((xpath('//document/k_celpers/text()', dataxml))[1],'');
	k_comms1 := coalesce((xpath('//document/k_comms1/text()', dataxml))[1],'');
	k_comms2 := coalesce((xpath('//document/k_comms2/text()', dataxml))[1],'');
	k_comms3 := coalesce((xpath('//document/k_comms3/text()', dataxml))[1],'');

	k_tipo := coalesce((xpath('//document/k_tipo/text()', dataxml))[1],'');
	k_lava := coalesce((xpath('//document/k_lava/text()', dataxml))[1],'');
	k_ayud := coalesce((xpath('//document/k_ayud/text()', dataxml))[1],'');
	k_jefe := coalesce((xpath('//document/k_jefe/text()', dataxml))[1],'');
	k_clasif := coalesce((xpath('//document/k_clasif/text()', dataxml))[1],'');
	k_nomina := coalesce((xpath('//document/k_nomina/text()', dataxml))[1],'');

	crud := (xpath('//document/input_crud/text()', dataxml))[1];

	if crud <> 'ELIMINAR' then
		if cve_oper is null then 
			raise exception 'Debe seleccionar una clave de operario';
		end if;
		if nombre is null then 
			raise exception 'Debe ingresar el nombre del operario';
		end if;
	end if; 

	if crud = 'NUEVO' then
		insert into keplersc.kdoper  
			( c1,c3,c12,c20,c4,c5,c6,c9,c10,c11
			,c7,c8,c2,c19,c22,c21,c17,c18 ) 
		values( cve_oper,nombre,k_activo,k_usuario,k_dir,k_col,k_pobl,k_comms1,k_comms2,k_comms3
			,k_telcasa,k_celpers,k_tipo,k_lava,k_ayud,k_jefe,k_clasif,k_nomina );
	end if;

	if crud = 'MODIFICAR' then
	
		totReg := 0;
		select count(c1) into totReg from keplersc.kdoper where c1 = cve_oper;
		if totReg = 0 then
			mensaje := 'No se encontro Informacion en la Tabla Kdoper [Operarios], clave [' || cve_oper || ']';
			raise exception '%', mensaje;
		end if;	
	
		val_activo := '';
		val_tipo := '';
		select c12, c2 into val_activo, val_tipo from keplersc.kdoper where c1 = cve_oper;
		val_activo := coalesce(val_activo, '');
		val_tipo := coalesce(val_tipo, '');
		if length(val_activo) = 0 or length(val_tipo) = 0 then
			mensaje := 'No se encontro la INFO en la Tabla kdoper [Operarios], clave [' || cve_oper || ']';
			raise exception '%', mensaje;
		else 
			--mensaje := '4 Testing ... Info : Activo [' || val_activo || '], Tipo [' || val_tipo || ']' || '], Clave [' || cve_oper || ']';
			mensaje := '';
			if val_activo <> k_activo and k_activo = 'N' then
				--mensaje := 'Se borraran registros en TBL [kdtiemposnd] x Desactivacion ...';
				delete from keplersc.kdtiemposnd where c1 = cve_oper and c3 > current_date;
			end if;
			if val_tipo <> k_tipo then
				--mensaje := 'Se actualizaran registros en TBL [kdtiemposnd] x Cambio de Tipo ...';
				update keplersc.kdtiemposnd set c2 = k_tipo where c1 = cve_oper and c3 > current_date;
			end if;
			/*
			if length(mensaje) > 0 then
				raise exception '%', mensaje;
			end if;
			*/
		end if;
	
		update keplersc.kdoper
		set c3 = nombre, c12 = k_activo, c20 = k_usuario, c4 = k_dir, c5 = k_col, c6 = k_pobl 
		, c9 = k_comms1, c10 = k_comms2, c11 = k_comms3, c7 = k_telcasa, c8 = k_celpers
		, c2 = k_tipo, c19 = k_lava, c22 = k_ayud, c21 = k_jefe, c17 = k_clasif, c18 = k_nomina   
		where c1 = cve_oper;
	
	end if;

	if crud = 'ELIMINAR' then
		delete from keplersc.kdoper
			where c1 = cve_oper;
	end if;

	resultado := 1;
	mensaje := 'Registro agregado : ' || cve_oper;
	adicionales := '';
	return query select resultado, mensaje, adicionales;	

exception
	when others then
		resultado := 0;
		mensaje := 'cat_operarios_crud() ' || '['|| sqlstate || '] ' || sqlerrm ;		
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
	
end;
$function$
