CREATE OR REPLACE FUNCTION keplersc.cli_crud(dataxml xml)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
--Descripcion: crud clientes
--Autor: Luis Leal
--Fecha: 26/12/2021
--Bitacora de cambios
--22/02/2023 Miriam Santana: Agregar datos cfdi(regimen fiscal) y grabe el caracater de &
--25/06/2024 Miriam Santana: Grabar los datos estatus y subestatus
--22/01/2026 Miriam Santana: Grabar datos nombre de referencia y parentesco con cliente
declare
	--Variables de definicion de documento
	clave text = '';
	nombre_razon text = '';
	nombre_impresion text = '';
	apellido_paterno text = '';
	apellido_materno text = '';
	nombres text = '';
	sucursal text = '';
    calle text = '';
   	No_exterior text = '';
   	No_interior text = '';
  	colonia text = '';
  	ciudad text = '';
 	municipio text = '';
	estado text = '';
	pais text = '';
	codigo_postal text = '';
	rfc text = '';
    correo text = '';
   	tel_casa text = '';
   	tel_oficina text = '';
  	tel_extension text = '';
  	tel_movil text = '';
  	tel_referencia text = '';
    metodo_de_pago text = '';
   	uso_cfdi text = '';
   	reg_fiscal text = '';
   	limite_credito decimal =0.00;
   	plazo text = '';
  	ult_modificacion text = '';
  	usuario text = '';
    rfc_repetido text;
  	cli_repetido text;
  	cve_estatus text = '';
  	cve_subestatus text = '';
  	nombre_refer text = '';
	parent_refer_cte text = '';
  	totReg int;
  
  	get_resultado text = '';
  	get_mensaje text = '';
  	get_adicionales text = '';
 

	crud text = '';

	iscorreo bool;
	isrfc bool;
	istel bool;
	isplazo bool;
	resultado text = '';
	mensaje text = '0';
    adicionales text = '';
	
begin 
	crud:=dataxml::text;
	crud:=replace(crud,'\&quot;','"');

	dataxml:=crud::xml;
	
	clave := upper((xpath('//document/input_clave/text()', dataxml))[1]::text);
	nombre_razon := upper(coalesce((xpath('//document/input_nombre_razonsocial/text()', dataxml))[1]::text,'')::text);
	nombre_impresion := upper(coalesce((xpath('//document/input_nombre_impresion/text()', dataxml))[1]::text,'')::text);
	apellido_paterno := upper(coalesce((xpath('//document/input_apellido_p/text()', dataxml))[1]::text,'')::text);
	apellido_materno := upper(coalesce((xpath('//document/input_apellido_m/text()', dataxml))[1]::text,'')::text);
	nombres := upper(coalesce((xpath('//document/input_nombres/text()', dataxml))[1]::text,'')::text);
	sucursal :=	upper(coalesce((xpath('//document/k_sucN/r1/text()', dataxml))[1]::text,'')::text);
	calle := upper(coalesce((xpath('//document/input_calle/text()', dataxml))[1]::text,'')::text);
	No_exterior := upper(coalesce((xpath('//document/input_no_exterior/text()', dataxml))[1]::text,'')::text);
	No_interior := upper(coalesce((xpath('//document/input_no_interior/text()', dataxml))[1]::text,'')::text);
	colonia := upper(coalesce((xpath('//document/input_colonia/text()', dataxml))[1]::text,'')::text);
	ciudad := upper(coalesce((xpath('//document/input_ciudad/text()', dataxml))[1]::text,'')::text);
	municipio := upper(coalesce((xpath('//document/input_municipio/text()', dataxml))[1]::text,'')::text);
	estado := upper(trim(regexp_replace(coalesce((xpath('//document/input_estado/text()', dataxml))[1]::text,''), '[[:cntrl:]]', '', 'g') ));	--AM 27032026
	pais := upper(coalesce((xpath('//document/input_pais/text()', dataxml))[1]::text,'')::text);
	codigo_postal := upper(coalesce((xpath('//document/input_cp/text()', dataxml))[1]::text,'')::text);
	rfc := upper(coalesce((xpath('//document/input_rfc/text()', dataxml))[1]::text,'')::text);
	correo := upper(coalesce((xpath('//document/input_correo/text()', dataxml))[1]::text,'')::text);
	tel_casa := upper(coalesce((xpath('//document/input_tel_casa/text()', dataxml))[1]::text,'')::text);
 	tel_oficina := upper(coalesce((xpath('//document/input_tel_oficina/text()', dataxml))[1]::text,'')::text);
	tel_extension := upper(coalesce((xpath('//document/input_tel_ext/text()', dataxml))[1]::text,'')::text);
	tel_movil := upper(coalesce((xpath('//document/input_tel_movil/text()', dataxml))[1]::text,'')::text);
	tel_referencia := upper(coalesce((xpath('//document/input_tel_referencia/text()', dataxml))[1]::text,'')::text);
	metodo_de_pago := upper(coalesce((xpath('//document/cmb_metodo_pago/r1/text()', dataxml))[1]::text,'')::text);
	uso_cfdi := upper(coalesce((xpath('//document/cmb_uso_cfdi/r1/text()', dataxml))[1]::text,'')::text);
	reg_fiscal := upper(coalesce((xpath('//document/cmb_regfiscal/r1/text()', dataxml))[1]::text,'')::text);
	limite_credito := coalesce((xpath('//document/input_limite_credito/text()', dataxml))[1]::text,'0.00')::decimal;
	plazo := upper(coalesce((xpath('//document/input_plazo/text()', dataxml))[1]::text,'')::text);
	ult_modificacion := coalesce((xpath('//document/input_ult_modificacion/text()', dataxml))[1]::text,'0001-01-01')::text;
	usuario := upper(coalesce((xpath('//document/input_usuario/text()', dataxml))[1]::text,'')::text);

	cve_estatus := upper(coalesce((xpath('//document/estatus_cte/text()', dataxml))[1]::text,'')::text);
	cve_subestatus := upper(coalesce((xpath('//document/subestatus_cte/text()', dataxml))[1]::text,'')::text);
	--MSS 21012026 Agregar datos de referencia
	nombre_refer := upper(coalesce((xpath('//document/input_nombre_referencia/text()', dataxml))[1]::text,'')::text);				
	parent_refer_cte := upper(coalesce((xpath('//document/input_parentesco_refer_cte/text()', dataxml))[1]::text,'')::text);
	
	crud := (xpath('//document/input_crud/text()', dataxml))[1];

	--MSS 24/09/2024 Escapar & y '
	nombre_razon := regexp_replace(nombre_razon,'&AMP;','&','gi');
	nombre_impresion := regexp_replace(nombre_impresion,'&AMP;','&','gi');
	apellido_paterno := regexp_replace(apellido_paterno,'&AMP;','&','gi');
	apellido_materno := regexp_replace(apellido_materno,'&AMP;','&','gi');
	nombres := regexp_replace(nombres,'&AMP;','&','gi');
	rfc := regexp_replace(rfc,'&AMP;','&','gi');							--MSS 05/05/2025 Escapar &
	nombre_refer := regexp_replace(nombre_refer,'&AMP;','&','gi');

	nombre_razon:=regexp_replace(nombre_razon,'\\''','''','gi');
	nombre_impresion:=regexp_replace(nombre_impresion,'\\''','''','gi');
	apellido_paterno:=regexp_replace(apellido_paterno,'\\''','''','gi');
	apellido_materno:=regexp_replace(apellido_materno,'\\''','''','gi');
	nombres:=regexp_replace(nombres,'\\''','''','gi');
	nombre_refer:=regexp_replace(nombre_refer,'\\''','''','gi');

	if crud <> 'Eliminar' then
		
		if nombre_razon = ''  then 
			raise exception 'El Nombre o Razon Social no puede quedar en blanco';
		end if;
		
		if apellido_paterno = '' then 
			raise exception 'El Apellido Paterno no puede quedar en blanco';
		end if;
		
		if apellido_materno = '' then 
			raise exception 'El Apellido Materno no puede quedar en blanco';
		end if;
		
		if nombres = '' then 
			raise exception 'Los nombres no pueden quedar en blanco';
		end if;
		
		if correo <> '' then
			select correo ~ '^\S{1,}@\S{2,}\.\S{2,}$' into iscorreo; 
			if not iscorreo then
				raise exception 'El Formato del Correo no es valido' ;
			end if;
		end if;
		
		if codigo_postal <> '' and length(codigo_postal) <> '5' then 
			raise exception 'El Codigo Postal tiene que tener: 5 digitos';
		end if;
	
		if rfc <> '' then 
	
			if length(rfc) <> '12' and length(rfc) <> '13'  then
				raise exception 'El formato valido del RFC para Personas Morales es: XAX010101000 y para Personas Fisicas: XAXX010101000' ;
			end if;
			
			if length(rfc) = '13' then
			
				select substring(rfc,1,4) ~ '^[a-zA-Z]+$' into isrfc; 
				if not isrfc then
					raise exception 'El formato valido del RFC para Personas Morales es: XAX010101000 y para Personas Fisicas: XAXX010101000' ;
				end if;
				
				select substring(rfc,5,6) ~ '^[0-9]+$' into isrfc; 
				if not isrfc then
					raise exception 'El formato valido del RFC para Personas Morales es: XAX010101000 y para Personas Fisicas: XAXX010101000' ;
				end if;
			
				select substring(rfc,11,3) ~ '^[a-zA-Z0-9]+$' into isrfc; 
				if not isrfc then
					raise exception 'El formato valido del RFC para Personas Morales es: XAX010101000 y para Personas Fisicas: XAXX010101000' ;
				end if;
				
			end if;
			
			if length(rfc) = '12' then
			
				select substring(rfc,1,3) ~ '^[a-z&A-Z&]+$' into isrfc; 			--MSS 05/05/2025 Permitir &
				if not isrfc then
					raise exception 'El formato valido del RFC para Personas Morales es: XAX010101000 y para Personas Fisicas: XAXX010101000' ;
				end if;
				
				select substring(rfc,4,6) ~ '^[0-9]+$' into isrfc; 
				if not isrfc then
					raise exception 'El formato valido del RFC para Personas Morales es: XAX010101000 y para Personas Fisicas: XAXX010101000' ;
				end if;
			
				select substring(rfc,10,3) ~ '^[a-zA-Z0-9]+$' into isrfc; 
				if not isrfc then
					raise exception 'El formato valido del RFC para Personas Morales es: XAX010101000 y para Personas Fisicas: XAXX010101000' ;
				end if;
				
			end if;
		
		end if;
	
		select c2, c10 into cli_repetido, rfc_repetido from keplersc.kdud 
		where c10=rfc and c10 not like 'X%' and c10 not like 'x%' and c10 <> '' and c2 <> clave;
		if found then
			--raise exception 'El rfc % ya se encuentra registrado con la clave % ', rfc_repetido, cli_repetido;
		end if ;
	
		--LGLG 07/06/24
		if pais = '' then
			raise exception 'Debes seleccionar un pais';
		end if;
			
		if tel_casa <> '' and length(tel_casa) <> '10' then 
			raise exception 'El telefono de Casa tiene que tener: 10 digitos';
		end if;
		
		if tel_oficina <> '' and length(tel_oficina) <> '10' then 
			raise exception 'El telefono de Oficina tiene que tener: 10 digitos';
		end if;
		
		if tel_extension <> '' and length(tel_extension) <> '7' then 
			raise exception 'La Extension tiene que tener: 7 digitos';
		end if;
		
		if length(tel_movil) < '10' or length(tel_movil) > '15'  then 												--MSS 21012026 El tel_movil puede contener mas de 10 digitos en caso de ser un numero extranjero
			raise exception 'El Movil tiene que tener: entre 10 y 15 digitos';
		end if;
		
		if tel_referencia <> '' and length(tel_referencia) <> '10' then 											--MSS 21012026 Agregar datos de referencia
			raise exception 'El telefono de Referencia tiene que tener: 10 digitos';
		end if;
	
		select concat(tel_casa,tel_oficina,tel_extension,tel_movil,tel_referencia)  ~ '^[0-9]+$' into istel; 		--MSS 21012026 Agregar datos de referencia
		if not istel then
			raise exception 'Los telefonos tienen que tener solamente numeros' ;
		end if;
	
		if plazo <> '' then
			select plazo  ~ '^[0-9]+$' into isplazo; 
			if not isplazo then
				raise exception 'Plazo solo puede tener numeros' ;
			end if;
			
		end if;
		--MSS Validacion estatus y subestatus
		if cve_estatus = '0' then
			raise exception 'Debe ingresar el estatus del cliente';
		else 
			select count(*) into totReg
				from keplersc.kdconduni
				where c1=cve_estatus::integer;
			if totReg=0 then
				raise exception 'Verifique. El estatus del cliente no existe';	
			end if;	
			if cve_estatus = '2' and cve_subestatus = '0' then
				raise exception 'Debe ingresar el sub-estatus del cliente';
			end if;
			if cve_estatus = '2' and cve_subestatus <> '0' then
				select count(*) into totReg
					from keplersc.kdsubestatuscte
					where c1=cve_subestatus::integer and c2=cve_estatus::integer;
				if totReg=0 then
					raise exception 'Verifique. El sub-estatus del cliente no existe';	
				end if;
			end if;
		end if;
	
	end if;

	if crud = 'Nuevo' then

		select * into get_resultado, get_mensaje, get_adicionales from keplersc.obtener_folio_cli_prov('C');
		if get_resultado = '0' then
			raise exception '%',get_mensaje;
		end if;
		clave := get_mensaje; 
					
		insert into keplersc.kdud(
			c2,c3,c30,c33,c34,
			c35,c1,c4,c45,c46,
			c5,c6,c47,c48,c49,
			c27,c10,c11,c7,c8,
			c37,c9,c36,c52,c53,
			c54,c15,c16,c42,c43,
			estatus,subestatus,nombre_referencia,parentesco_refer_cte) 
		values(
			clave,nombre_razon,nombre_impresion,apellido_paterno,apellido_materno,
			nombres,sucursal ,calle ,No_exterior ,No_interior,
			colonia ,ciudad ,municipio,estado, pais ,
			codigo_postal ,rfc ,correo,tel_casa,tel_oficina ,
			tel_extension,tel_movil,tel_referencia,metodo_de_pago,uso_cfdi,
			reg_fiscal,limite_credito,plazo,to_date(ult_modificacion,'YYYY-MM-DD'),usuario,
			cve_estatus::integer,cve_subestatus::integer,nombre_refer,parent_refer_cte);				--MSS 21012026 Agregar datos de referencia

	end if;

	if crud = 'Modificar' then	
		update keplersc.kdud set 
			c3=nombre_razon,
			c30=nombre_impresion,
			c33=apellido_paterno,
			c34=apellido_materno,
			c35=nombres,
			c1=sucursal,
			c4=calle,
			c45=No_exterior,
			c46=No_interior,
			c5=colonia,
			c6=ciudad,
			c47=municipio,
			c48=estado,
			c49=pais,
			c27=codigo_postal,
			c10=rfc,
			c11=correo,
			c7=tel_casa,
			c8=tel_oficina,
			c37=tel_extension,
			c9=tel_movil,
			c36=tel_referencia,
			c52=metodo_de_pago,
			c53=uso_cfdi,
			c54=reg_fiscal,
			c15=limite_credito,
			c16=plazo,
			c42=to_date(ult_modificacion,'YYYY-MM-DD'),
			c43=usuario,
			estatus=cve_estatus::integer,
			subestatus=cve_subestatus::integer,
			nombre_referencia=nombre_refer,																--MSS 21012026 Agregar datos de referencia
			parentesco_refer_cte=parent_refer_cte														--MSS 21012026 Agregar datos de referencia
		where c2=clave;
	
	end if;

	if crud = 'Eliminar' then
	
		delete from keplersc.kdud where c2 = clave;
					
	end if;


	resultado := 1;
	mensaje := clave;
	adicionales := '';
	return query select resultado, mensaje, adicionales;	

exception
	when others then
		resultado := 0;
	
		mensaje := 'cli_crud() ' || '['|| sqlstate || '] ' || sqlerrm ;		

		adicionales := '';
		return query select resultado, mensaje, adicionales;	
	
end;
$function$
