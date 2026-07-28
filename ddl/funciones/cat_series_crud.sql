CREATE OR REPLACE FUNCTION keplersc.cat_series_crud(dataxml xml)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
--Descripcion: Realiza crud en la tabla KDSERIE, basado en vin_crud
--Autor: Miriam Santana
--Fecha: 31/Ene/2023
--Bitacora de cambios
--24/Oct/2023 Miriam Santana: En una alta precargar datos que se tengan registrados en otras tablas
--03/Nov/2023 Miriam Santana: Si hay cambio de contacto(perfil propietario) actualizar contactos en KDTMKTSER2 y citas pendientes en KDCTASSER
--13/Ene/2026 Miriam Santana: Grabar nuevos datos de notas, usuario y fecha de ultima modificacion
declare
	--Variables de definicion de documento
	Identificador text = '';
	Marca text = '';
	Modelo text = '';
	Motor text = '';
	Serie text = '';
	Transmision text = '';
	Eje_trasero text = '';
    Placas text = '';
   	Contacto text = '';
   	Color text = '';
  	Anio text = '';
  	codeanio text = '';
  	vanio integer;
  	id_codanio integer;
  	origen text ='';
  
  	kilometraje decimal =0.00;
  
 	Fecha_venta text = '';
	Concesionario text = '';
	Ultima_visita text = '';
	Codigo_planta text = '';
	
	nombre_contacto text ='';
	k_version text ='';
	fecha_dofu text ='';
	cond_unidad text ='';
	subcond_unidad text ='';
	garantia_ext text ='';
	fec_expgarantia text ='';
	aseg_garantext text ='';
	poliza_garantext text ='';
	segvehicular text ='';
	fec_vigseguro text ='';
	aseg_segvehicular text ='';
	poliza_segvehicular text ='';
	nombre_usuario text ='';
	ap_paterno_usuario text ='';
	ap_materno_usuario text ='';
	rfc_usuario text ='';
	tel_usuario text ='';
	correo_usuario text ='';
	medio_pref_usuario text ='';
	tel_mediopref_usuario text ='';
	nombre_autoriza text ='';
	ap_paterno_autoriza text ='';
	ap_materno_autoriza text ='';
	rfc_autoriza text ='';
	tel_autoriza text ='';
	correo_autoriza text ='';
	medio_pref_autoriza text ='';
	tel_mediopref_autoriza text ='';
	
	cliente_ant text ='';
	cliente_nvo text ='';
	sucursal_id text ='';
	valkodawari text = '';
	crud text = '';
	ValAnio int;
	resVal text;
	anioActual text;
	isidentificadoralfanumeric bool;
	isidentificadornumeric bool;
	valInt int;

	--MSS 13/01/2026 Grabar datos de notas, usuario y fecha de ultima modificacion  
	fec_ult_modificacion text = '';
  	usuario text = '';
  	notas_serie text = '';

	totReg integer = 0;
	resultado text = '';
	mensaje text = '0';
    adicionales text = '';
	
begin 
	
	Marca := upper((xpath('//document/input_marca/text()', dataxml))[1]::text);
	Modelo := upper((xpath('//document/input_modelo/text()', dataxml))[1]::text);
	Serie := upper((xpath('//document/input_serie/text()', dataxml))[1]::text);
	Motor := upper(coalesce((xpath('//document/input_motor/text()', dataxml))[1]::text,'')::text);
	Transmision := upper(coalesce((xpath('//document/input_transmision/text()', dataxml))[1]::text,'')::text);
	Eje_trasero := upper(coalesce((xpath('//document/input_eje_trasero/text()', dataxml))[1]::text,'')::text);
	Placas := upper(coalesce((xpath('//document/input_placas/text()', dataxml))[1]::text,'')::text);
	Contacto := upper(coalesce((xpath('//document/input_contacto/text()', dataxml))[1]::text,'')::text);
	nombre_contacto := upper(coalesce((xpath('//document/k_nombre_contacto/text()', dataxml))[1]::text,'')::text);
	Color := upper(coalesce((xpath('//document/input_color/text()', dataxml))[1]::text,'')::text);
	Anio := coalesce((xpath('//document/input_anio/text()', dataxml))[1]::text,'')::text;
	Fecha_venta := coalesce((xpath('//document/input_fecha_venta/text()', dataxml))[1]::text,'1800-01-01 00:00:00')::text;
	Concesionario := coalesce((xpath('//document/input_concesionario/text()', dataxml))[1]::text,'')::text;
	Ultima_visita := coalesce((xpath('//document/input_ult_visita/text()', dataxml))[1]::text,'1800-01-01 00:00:00')::text;
	kilometraje := coalesce((xpath('//document/input_kilometraje/text()', dataxml))[1]::text,'0.00')::decimal;
	Codigo_planta := upper(coalesce((xpath('//document/input_codigo_planta/text()', dataxml))[1]::text,'')::text);
	k_version := upper(coalesce((xpath('//document/input_version/text()', dataxml))[1]::text,'')::text);
	fecha_dofu := coalesce((xpath('//document/input_fec_dofu/text()', dataxml))[1]::text,'1800-01-01 00:00:00')::text;

	cond_unidad := upper(coalesce((xpath('//document/cond_unidad/text()', dataxml))[1]::text,'')::text);
	subcond_unidad := upper(coalesce((xpath('//document/subcond_unidad/text()', dataxml))[1]::text,'')::text);
	garantia_ext := upper(coalesce((xpath('//document/garantia_ext/text()', dataxml))[1]::text,'')::text);
	fec_expgarantia := coalesce((xpath('//document/fec_expgarantia/text()', dataxml))[1]::text,'1800-01-01 00:00:00')::text;
	aseg_garantext := upper(coalesce((xpath('//document/aseg_garantext/text()', dataxml))[1]::text,'')::text);
	poliza_garantext := upper(coalesce((xpath('//document/poliza_garantext/text()', dataxml))[1]::text,'')::text);
	segvehicular := upper(coalesce((xpath('//document/segvehicular/text()', dataxml))[1]::text,'')::text);
	fec_vigseguro := coalesce((xpath('//document/fec_vigseguro/text()', dataxml))[1]::text,'1800-01-01 00:00:00')::text;
	aseg_segvehicular := upper(coalesce((xpath('//document/aseg_segvehicular/text()', dataxml))[1]::text,'')::text);
	poliza_segvehicular := upper(coalesce((xpath('//document/poliza_segvehicular/text()', dataxml))[1]::text,'')::text);
	nombre_usuario := upper(coalesce((xpath('//document/nombre_usuario/text()', dataxml))[1]::text,'')::text);
	ap_paterno_usuario := upper(coalesce((xpath('//document/ap_paterno_usuario/text()', dataxml))[1]::text,'')::text);
	ap_materno_usuario := upper(coalesce((xpath('//document/ap_materno_usuario/text()', dataxml))[1]::text,'')::text);
	rfc_usuario := upper(coalesce((xpath('//document/rfc_usuario/text()', dataxml))[1]::text,'')::text);
	tel_usuario := upper(coalesce((xpath('//document/tel_usuario/text()', dataxml))[1]::text,'')::text);
	correo_usuario := upper(coalesce((xpath('//document/correo_usuario/text()', dataxml))[1]::text,'')::text);
	medio_pref_usuario := upper(coalesce((xpath('//document/medio_pref_usuario/text()', dataxml))[1]::text,'')::text);
	tel_mediopref_usuario := upper(coalesce((xpath('//document/tel_mediopref_usuario/text()', dataxml))[1]::text,'')::text);
	nombre_autoriza := upper(coalesce((xpath('//document/nombre_autoriza/text()', dataxml))[1]::text,'')::text);
	ap_paterno_autoriza := upper(coalesce((xpath('//document/ap_paterno_autoriza/text()', dataxml))[1]::text,'')::text);
	ap_materno_autoriza := upper(coalesce((xpath('//document/ap_materno_autoriza/text()', dataxml))[1]::text,'')::text);
	rfc_autoriza := upper(coalesce((xpath('//document/rfc_autoriza/text()', dataxml))[1]::text,'')::text);
	tel_autoriza := upper(coalesce((xpath('//document/tel_autoriza/text()', dataxml))[1]::text,'')::text);
	correo_autoriza := upper(coalesce((xpath('//document/correo_autoriza/text()', dataxml))[1]::text,'')::text);
	medio_pref_autoriza := upper(coalesce((xpath('//document/medio_pref_autoriza/text()', dataxml))[1]::text,'')::text);
	tel_mediopref_autoriza := upper(coalesce((xpath('//document/tel_mediopref_autoriza/text()', dataxml))[1]::text,'')::text);
	crud := (xpath('//document/input_crud/text()', dataxml))[1];
	origen := coalesce((xpath('//document/origen/text()', dataxml))[1]::text,'')::text;
	anioActual = extract(year from now());
	fec_ult_modificacion := coalesce((xpath('//document/fec_ult_modif/text()', dataxml))[1]::text,'1800-01-01')::text;
	usuario := upper(coalesce((xpath('//document/usuario_ult_modif/text()', dataxml))[1]::text,'')::text);
	notas_serie := upper(coalesce((xpath('//document/notas/text()', dataxml))[1]::text,'')::text);


	if origen <> 'Bienvenida' then
		if crud <> 'ELIMINAR' then
			if Marca is null then 
				raise exception 'Tiene que seleccionar una marca';
			else 
				select count(*) into totReg
					from keplersc.kdmarcas
					where c1=Marca;
				if totReg=0 then
					raise exception 'Verifique. La marca no existe';	
				end if;
			end if;
		
			if Modelo is null then 
				raise exception 'Tiene que seleccionar un modelo';
			else 
				select count(*) into totReg
					from keplersc.kdmodelos
					where c1=Marca and c2=Modelo;
				if totReg=0 then
					raise exception 'Verifique. El modelo no existe';	
				end if;
			end if;
		
			if Serie is null then 
				raise exception 'Tiene que introducir una serie';
			end if;
		
			if length(trim(Serie)) <> '17' then 
				raise exception 'La serie debe ser de 17 digitos';
			end if;
			Identificador := right(Serie, 8);
			if substring(Serie,10,8) <> Identificador then
				raise exception 'El identificador no coincide con los ultimos 8 caracteres de la serie';
			end if;
			select Identificador ~ '^(?=.*[a-zA-Z])(?=.*[0-9])[A-Za-z0-9]+$' into isidentificadoralfanumeric; 
			select Identificador ~ '^[0-9]+$' into isidentificadornumeric; 
			if not isidentificadoralfanumeric and not isidentificadornumeric then 
				raise exception 'Los ultimos digitos deben ser numerico o alfanumerico';
			end if;
			
			if substring(Serie,10,1) = 'I' or substring(Serie,10,1) = 'O' 
				or substring(Serie,10,1) = 'Z' or substring(Serie,10,1) = 'Q' or substring(Serie,10,1) = '0' then
				raise exception 'La serie no debe llevar letra: %', substring(Serie,10,1);
			end if;	
	
			if Placas <> '' and anio <> anioActual then 
				--Valida que el formato de la placa sea correcto 
				select * into resVal from keplersc.valida_placa(Placas);
				if resVal::int = 0 then 
					raise exception 'El formato de las placas es incorrecto';
				end if;
			end if;
	
			if Color = '' then 
				raise exception 'Debe ingresar el color del vehiculo';
			end if;
			/*	
			if Fecha_venta = '1800-01-01' or Fecha_venta = '1900-01-01' then
				raise exception 'Debe ingresar la fecha de venta del vehiculo';
			end if;
			*/
			if Contacto = '' then 
				raise exception 'Debe ingresar Contacto';
			else 
				select count(*) into totReg
					from keplersc.kdud
					where c2=Contacto;
				if totReg=0 then
					raise exception 'Verifique. El contacto no existe';	
				end if;
			end if;
			
			if Anio = '' then 
				raise exception 'Debe ingresar Anio';
			else 
				select count(*) into totReg
					from keplersc.kdanio
					where c1=Anio;
				if totReg=0 then
					raise exception 'Verifique. El anio no existe';	
				end if;
			end if;
		
			--Valida caracter 10 de la serie corresponda al anio capturado
			codeanio := '';
			vanio := Anio::integer-1980;
			id_codanio := div(vanio,30);
			id_codanio := vanio-id_codanio*30;
			select c2 into codeanio from keplersc.kdyearcode where c1 = id_codanio::text;
			if codeanio <> substring(Serie,10,1) then
				raise exception 'El anio no coincide con el indicado en la serie en su caracter 10';
			end if;
		
	 		select c9 into valkodawari from keplersc.kdconftaller;
			if found then
				if valkodawari ='S' and Marca = 'TOY' then
					if Codigo_planta = '' then
						raise exception 'Debe ingresar el codigo Katashiki del vehiculo';
					else 
						select Codigo_planta ~ '^(?=.*[a-zA-Z])(?=.*[0-9])[A-Za-z0-9-]+$' into isidentificadoralfanumeric; 
						if not isidentificadoralfanumeric then 
							raise exception 'El codigo Katashiki debe ser alfanumerico';
						end if;
					end if;
				
					if fecha_dofu = '' or fecha_dofu ='1800-01-01' or fecha_dofu ='1990-01-01' then
						raise exception 'Debe ingresar la fecha DOFU del vehiculo';
					end if;
					if cond_unidad = '0' then
						raise exception 'Debe ingresar la condicion del vehiculo';
					else 
						select count(*) into totReg
							from keplersc.kdconduni
							where c1=cond_unidad::integer;
						if totReg=0 then
							raise exception 'Verifique. La condicion de unidad no existe';	
						end if;	
						if cond_unidad = '2' and subcond_unidad = '0' then
							raise exception 'Debe ingresar la sub-condicion del vehiculo';
						end if;
						if cond_unidad = '2' and subcond_unidad <> '0' then
							select count(*) into totReg
								from keplersc.kdsubconduni
								where c1=subcond_unidad::integer and c2=cond_unidad::integer;
							if totReg=0 then
								raise exception 'Verifique. La sub-condicion de unidad no existe';	
							end if;
						end if;
					end if;
					if garantia_ext = '' then
						raise exception 'Debe ingresar el estado de la Garantia extendida S/N';
					end if;
					if segvehicular = '' then
						raise exception 'Debe ingresar el estado del Seguro Vehicular S/N';
					end if;
					if length(tel_usuario) <> 10 then
						raise exception 'El telefono del usuario debe ser de 10 digitos';
					else
						select tel_usuario ~ '^[0-9]+$' into isidentificadornumeric; 
						if not isidentificadornumeric then 
							raise exception 'El telefono del usuario debe ser numerico';
						end if;
					end if;
					
					if length(tel_autoriza) <> 10 then
						raise exception 'El telefono del resp. mantto. debe ser de 10 digitos';
					else
						select tel_autoriza ~ '^[0-9]+$' into isidentificadornumeric; 
						if not isidentificadornumeric then 
							raise exception 'El telefono del resp. mantto. debe ser numerico';
						end if;
					end if;
								
					if medio_pref_usuario <> '' then
						select count(*) into totReg
							from keplersc.kdsercontpref
							where c1=medio_pref_usuario;
						if totReg=0 then
							raise exception 'Verifique. El medio de contacto del usuario no existe';	
						end if;
					end if;
					if medio_pref_autoriza <> '' then
						select count(*) into totReg
							from keplersc.kdsercontpref
							where c1=medio_pref_autoriza;
						if totReg=0 then
							raise exception 'Verifique. El medio de contacto del resp. mantto no existe';	
						end if;
					end if;
					if medio_pref_usuario <> 'EMAIL' and medio_pref_usuario <> '' then
						if length(tel_mediopref_usuario) <> 10 then
							raise exception 'El num. medio preferido de contacto del usuario debe ser de 10 digitos';
						else
							select tel_mediopref_autoriza ~ '^[0-9]+$' into isidentificadornumeric; 
							if not isidentificadornumeric then 
								raise exception 'El num. medio preferido de contacto del usuario debe ser numerico';
							end if;
						end if;	
					end if;
					if medio_pref_autoriza <> 'EMAIL' and medio_pref_autoriza <> '' then
						if length(tel_mediopref_autoriza) <> 10 then
							raise exception 'El num. medio preferido de contacto del resp. mantto. debe ser de 10 digitos';
						else
							select tel_mediopref_autoriza ~ '^[0-9]+$' into isidentificadornumeric; 
							if not isidentificadornumeric then 
								raise exception 'El num. medio preferido de contacto del resp. mantto. debe ser numerico';
							end if;
						end if;
					end if; 	
				end if;	
			end if;
		end if;
	end if;

	if crud = 'NUEVO' then
		select count(*) into totReg from keplersc.kdserie where c4=	Serie;
		if totReg > 0 then
			raise exception 'No es posible realizar el Alta. El no. de serie ya existe.';
		else
			insert into keplersc.kdserie(
				c1,c2,c3,c4,c5,
				c6,c7,c8,c9,c10,
				c11,c12,c13,c14,c15,
				c16,c17,c18,c19,c20,
				c21,c22,c23,c24,c25,
				c26,c27,c28,c29,c30,
				c31,c32,c33,c34,c35,
				c36,c37,c38,c39,c40,
				c41,c42,c43,c44,c45,
				fec_ultima_modif,usuario_ultima_modif,notas) 
			values(
				Identificador,Marca, Modelo, Serie, Motor, 
				Transmision,Eje_trasero, Placas, Contacto, Color,
				Anio, kilometraje,to_date(Fecha_venta,'YYYY-MM-DD'), Concesionario,to_date(Ultima_visita,'YYYY-MM-DD'), 
				nombre_contacto,Codigo_planta,k_version,to_date(fecha_dofu,'YYYY-MM-DD'),nombre_usuario,
				tel_usuario,nombre_autoriza,tel_autoriza,ap_paterno_usuario,ap_materno_usuario,
				correo_usuario,ap_paterno_autoriza,ap_materno_autoriza,correo_autoriza,rfc_usuario,
				rfc_autoriza,medio_pref_usuario,tel_mediopref_usuario,medio_pref_autoriza,tel_mediopref_autoriza,
				cond_unidad::integer,subcond_unidad::integer,garantia_ext,to_date(fec_expgarantia,'YYYY-MM-DD'),segvehicular,
				to_date(fec_vigseguro,'YYYY-MM-DD'),aseg_garantext,poliza_garantext,aseg_segvehicular,poliza_segvehicular,
				to_date(fec_ult_modificacion,'YYYY-MM-DD'),usuario,notas_serie);
		end if;
	end if;

	if crud = 'MODIFICAR' then
		--TO DO: Por el momento se extrae la sucursal del cliente anterior, KDSERIE no tiene sucursal
		select ser.c9,ud.c1 into cliente_ant,sucursal_id
		from keplersc.kdserie ser
		inner join keplersc.kdud ud on ud.c2=ser.c9 
		where ser.c1=Identificador;
		
		cliente_nvo := Contacto;			
		update keplersc.kdserie 
			set c1=Identificador,c2=Marca,c3=Modelo,c4=Serie,c5=Motor,
				c6=Transmision,c7=Eje_trasero,c8=Placas,c9=Contacto,c10=Color,
				c11=Anio,c12=kilometraje,c13=to_date(Fecha_venta,'YYYY-MM-DD'),c14=Concesionario,c15=to_date(Ultima_visita,'YYYY-MM-DD'),
				c16=nombre_contacto,c17=Codigo_planta,c18=k_version,c19=to_date(fecha_dofu,'YYYY-MM-DD'),c20=nombre_usuario,
				c21=tel_usuario,c22=nombre_autoriza,c23=tel_autoriza,c24=ap_paterno_usuario,c25=ap_materno_usuario,
				c26=correo_usuario,c27=ap_paterno_autoriza,c28=ap_materno_autoriza,c29=correo_autoriza,c30=rfc_usuario,
				c31=rfc_autoriza,c32=medio_pref_usuario,c33=tel_mediopref_usuario,c34=medio_pref_autoriza,c35=tel_mediopref_autoriza,
				c36=cond_unidad::integer,c37=subcond_unidad::integer,c38=garantia_ext,c39=to_date(fec_expgarantia,'YYYY-MM-DD'),c40=segvehicular,
				c41=to_date(fec_vigseguro,'YYYY-MM-DD'),c42=aseg_garantext,c43=poliza_garantext,c44=aseg_segvehicular,c45=poliza_segvehicular,
				fec_ultima_modif=to_date(fec_ult_modificacion,'YYYY-MM-DD'),usuario_ultima_modif=usuario,notas=notas_serie
		where c1=Identificador;
		if cliente_ant <> cliente_nvo then
			--Actualiza contactos tmkt pendientes
			update keplersc.kdtmktser2 
				set c20=cliente_nvo,
				c21=nombre_contacto
			where c1=sucursal_id and c14=Identificador and c8=0;
			
			--Actualiza cita pendiente
			update keplersc.kdctasser  
				set c4=cliente_nvo
			where c1=sucursal_id and c6=Identificador and c20=0;
		end if;

	end if;

	if crud = 'ELIMINAR' then
	
		delete from keplersc.kdserie where c4=Serie;
					
	end if;

	resultado := '1';
	mensaje := 'Vin agregado:' || Identificador;
	adicionales := '';
	return query select resultado, mensaje, adicionales;	

exception
	when others then
		resultado := '0';
	
		mensaje := 'cat_series_crud() ' || '['|| sqlstate || '] ' || sqlerrm ;		

		adicionales := '';
		return query select resultado, mensaje, adicionales;	
	
end;
$function$
