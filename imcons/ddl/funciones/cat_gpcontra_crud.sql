CREATE OR REPLACE FUNCTION keplersc.cat_gpcontra_crud(dataxml xml)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
--Descripcion: Realiza crud del catalogo de grupos de contrarecibos KDGPCONTRA
--Autor: Miriam Santana
--Fecha: 20/08/2024
--Bitacora de cambios
--Fecha: 20241104 - Adapted by JMM (New TBL Struct)

declare
	--Variables de definicion de documento
	clave text = '';
	desc_grupo text = '';
	fecha text = '';
	importe text = ''; 
	sucursal text = '';
	gpo_gasto text = '';
	crud text = '';

	--Added by JMM 20241104
	comprobado text = '';
	estatus_val text = '';
	
	intValor int;
	totReg int;
   --Variables de retorno
	resultado text = '';
	mensaje text = '0';
    adicionales text = '';
	
begin 
	
	clave := (xpath('//document/k_clave/text()', dataxml))[1];
	fecha := coalesce((xpath('//document/fec_registro/text()', dataxml))[1],'');
	desc_grupo := coalesce((xpath('//document/descripcion/text()', dataxml))[1],'');
	importe := coalesce((xpath('//document/importe/text()', dataxml))[1],'');
	sucursal := (xpath('//document/k_sucn/r1/text()', dataxml))[1];
	gpo_gasto := coalesce((xpath('//document/gpo_gasto/text()', dataxml))[1],'');

	--Added by JMM 20241104
	comprobado := coalesce((xpath('//document/comprobado/text()', dataxml))[1],'');
	estatus_val := coalesce((xpath('//document/estatus/text()', dataxml))[1],'');

	crud := (xpath('//document/input_crud/text()', dataxml))[1];

	if crud <> 'ELIMINAR' then
		if /*sucursal = ''*/ length(trim(sucursal)) = 0 then -- UPD by JMM 20241104
			raise exception 'Debe seleccionar la Sucursal ...';
		end if;
		if /*desc_grupo is null or*/ length(trim(desc_grupo)) = 0 then -- UPD by JMM 20241104
			raise exception 'Debe ingresar la Descripcion del Grupo de Gasto ...';
		end if;
	
		-- Commented by JMM 20241104
		/*
		if importe is null or importe = '0' then 
			raise exception 'Debe ingresar el importe asignado';
		end if;
		*/
	
		if /*gpo_gasto is null*/ length(trim(gpo_gasto)) = 0 then  -- UPD by JMM 20241104
			raise exception 'Debe seleccionar un Proveedor Interno ...';
		else
		
			-- Adapted by JMM 20241104
			/*
			select count(*) into totReg from keplersc.kdgpgastos where idgpo=gpo_gasto::integer;
			if totReg=0 then
				raise exception 'El grupo de gastos especificado no existe';
			end if;
			*/
		
			select count(*) into totReg from keplersc.kdxd where c2 = gpo_gasto and interno = 1;
			if totReg=0 then
				raise exception 'El Proveedor Interno {Gpo de Gasto} especificado No existe ...';
			end if;
		
		end if;
	
	-- Added by JMM 20241105 {else condition and its context}
	else
	
		if importe::numeric > 0 then 
			raise exception 'El Gpo. de Gasto cuenta con Importe Asignado ...';
		end if;
		
		if comprobado::numeric > 0 then 
			raise exception 'El Gpo. de Gasto cuenta con Importe Comprobado ...';
		end if;
	
		select count(*) into totReg from keplersc.kdm1 where c1 = sucursal and grupo_id = clave::integer;
			if totReg > 0 then
				raise exception 'El Gpo. de Gasto cuenta con registros historicos en la tabla de documentos ...';
		end if;
	
	end if; 
	
	if crud = 'NUEVO' then
		if fecha = '' or fecha ='1800-01-01' or fecha ='1990-01-01' then
			fecha := current_date;
		end if;
		select max(grupo_id) into intValor from keplersc.kdgpcontra where sucursal_id = sucursal;
		if intValor is null then
			intValor := 1;
		else
			intValor := intValor + 1;
		end if;
		
		-- Adapted by JMM 20241104
		insert into keplersc.kdgpcontra 
			(sucursal_id,grupo_id,fecha_registro,descripcion,importe_asignado ,importe_comprobado , estatus , proveedor_id) 
		values(
			sucursal,intValor,to_date(fecha,'YYYY-MM-DD'),desc_grupo,/*importe::decimal*/ 0, 0 , 'A' , gpo_gasto/*::integer*/);
	end if;

	if crud = 'MODIFICAR' then
		update keplersc.kdgpcontra
			set descripcion = desc_grupo
			/*, importe_asignado =importe::decimal*/ -- Commented by JMM 20241104
			, estatus = estatus_val -- Added by JMM 20241105 
		where sucursal_id = sucursal and grupo_id = clave::integer;
	end if;

	if crud = 'ELIMINAR' then
		delete from keplersc.kdgpcontra
			where sucursal_id = sucursal and grupo_id = clave::integer;
	end if;

	resultado := 1;
	mensaje := 'Registro agregado:' || clave;
	adicionales := intValor;
	return query select resultado, mensaje, adicionales;	

exception
	when others then
		resultado := 0;
		mensaje := 'cat_gpcontra_crud() ' || '['|| sqlstate || '] ' || sqlerrm ;		
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
	
end;
$function$
