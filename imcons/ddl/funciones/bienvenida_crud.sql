CREATE OR REPLACE FUNCTION keplersc.bienvenida_crud(dataxml xml)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
--Descripcion: guarda o modifica informaci n del evento de bienvenida
--Autor: Miriam Santana
--Fecha: 18/10/2022
--Bitacora de cambios
declare

	sucursal_id text;
	kodawari text;
	fecha_cita date;
	hora_cita time;
	inventario text;
	inv_modificar text;
	vendedor text;
	clave_cliente text;
	usuario text;
	tipo_operacion int;
	observaciones text;
	medio_preferido text;
	num_preferido text;
	tipo_snack text;
	desc_snack text;
	tipo_bebida text;
	desc_bebida text;
	cte_propietario text;
	medio_preferido_prop text;
	num_preferido_prop text;
	tipo_snack_prop text;
	desc_snack_prop text;
	tipo_bebida_prop text;
	desc_bebida_prop text;

	kms text;
	vin text;
	serie text;
	placas text;
	marca text;
	modelo text;
	anio text;
	anioActual text;
	color text;
	concesionario text;
	codigo text;
	cve_asistir text;
	persona_evento text;
	asistio_evento text;
	message text;

	get_resultado text;
	get_mensaje text; 
	get_adicionales text;

	totReg integer=0;
	strValor text;
	resVal text;
	resultado text = '';
	mensaje text = '';
    adicionales text = '';
   
	
begin 
	
	sucursal_id := (xpath('//document/k_sucN/r1/text()', dataxml))[1]; 
	clave_cliente := (xpath('//document/cliente_id/text()', dataxml))[1]; 
	inventario := (xpath('//document/inventario/text()', dataxml))[1];
	fecha_cita := ((xpath('//document/fecha_cita/text()', dataxml))[1]::text)::date; 
	hora_cita :=  ((xpath('//document/hora_cita/text()', dataxml))[1]::text)::time; 
	vendedor := (xpath('//document/vendedor/text()', dataxml))[1]; 
	persona_evento := (xpath('//document/persona_evento/text()', dataxml))[1]; 
	cve_asistir  := (xpath('//document/cmb_asistira/r1/text()', dataxml))[1];
	vin := coalesce((xpath('//document/vin/text()', dataxml))[1]::text,'')::text; 
	placas := coalesce((xpath('//document/placas/text()', dataxml))[1]::text,'')::text; 
 	marca := (xpath('//document/marca/text()', dataxml))[1];
	modelo := (xpath('//document/modelo/text()', dataxml))[1];
	serie := coalesce((xpath('//document/serie/text()', dataxml))[1]::text,'')::text; 
	anio := coalesce((xpath('//document/anio/text()', dataxml))[1]::text,'')::text; 
	kms := coalesce((xpath('//document/kms/text()', dataxml))[1]::text,'0.00')::text; 
	codigo := coalesce((xpath('//document/codigo/text()', dataxml))[1]::text,'')::text;
	medio_preferido := coalesce((xpath('//document/medio_preferido/text()', dataxml))[1]::text,'')::text; 
	num_preferido := coalesce((xpath('//document/num_preferido/text()', dataxml))[1]::text,'')::text; 
	tipo_snack := coalesce((xpath('//document/tipo_snack/r1/text()', dataxml))[1]::text,'')::text; 
	desc_snack := coalesce((xpath('//document/desc_snack/text()', dataxml))[1]::text,'')::text; 
	tipo_bebida := coalesce((xpath('//document/tipo_bebida/r1/text()', dataxml))[1]::text,'')::text; 
	desc_bebida := coalesce((xpath('//document/desc_bebida/text()', dataxml))[1]::text,'')::text;
	cte_propietario := (xpath('//document/propietario_id/text()', dataxml))[1];
	medio_preferido_prop := coalesce((xpath('//document/medio_preferido_prop/text()', dataxml))[1]::text,'')::text; 
	num_preferido_prop := coalesce((xpath('//document/num_preferido_prop/text()', dataxml))[1]::text,'')::text; 
	tipo_snack_prop := coalesce((xpath('//document/tipo_snack_prop/r1/text()', dataxml))[1]::text,'')::text; 
	desc_snack_prop := coalesce((xpath('//document/desc_snack_prop/text()', dataxml))[1]::text,'')::text; 
	tipo_bebida_prop := coalesce((xpath('//document/tipo_bebida_prop/r1/text()', dataxml))[1]::text,'')::text; 
	desc_bebida_prop := coalesce((xpath('//document/desc_bebida_prop/text()', dataxml))[1]::text,'')::text;
	observaciones := coalesce((xpath('//document/observaciones/text()', dataxml))[1]::text,'')::text; 

	usuario := coalesce((xpath('//document/usuario/text()', dataxml))[1]::text,'')::text;
 	tipo_operacion := ((xpath('//document/tipo_operacion/text()', dataxml))[1]::text)::integer; 

 	anioActual = extract(year from now());
	--Si es un alta o modificacion
	if tipo_operacion <> 2 then
		if inventario is null then
			raise exception 'Es necesario especificar un No. de inventario';
		end if;
	
		if clave_cliente is null then
			raise exception 'Falta la clave del cliente';
		end if;
	
		if serie is null then
			raise exception 'Falta el No. serie';
		end if;
		if (substring(trim(inventario),8,1)='N') then
			if marca is null or modelo is null then
				raise exception 'Falta marca y modelo';
			end if;
		end if;
	
		if anio <> '' then
			if placas <> '' and anio <> anioActual then 
				--Valida que el formato de la placa sea correcto 
				select * into resVal from keplersc.valida_placa(Placas);
				if resVal = '0' then 
					raise exception 'El formato de las placas es incorrecto';
				end if;
			end if;
		end if;
		select c7 into concesionario from keplersc.kdcfdconfig where c1=sucursal_id;
		--guardar bienvenida 
		select count(*) into totReg from keplersc.kdctasbienvser where c15=inventario;
	--raise notice 'inv:% totReg:% foliocita:%', inventario,totReg,folio_cita;
		if totReg = 0 then
			insert into keplersc.kdctasbienvser(
				c1,c2,c3,c4,c5,
				c6,c7,c8,c9,c10,
				c11,c12,c13,c14,c15,
				c16,c17,c18,c19,c20,
				c21,c22,c23,c24,c25,
				c29,c30,c31,c32,c33,
				c34,c35,c36,c37,c38,
				c39,c40) 
				values(
				sucursal_id,folio_cita,Asesor_TMKT,clave_cliente,placas,
				right(serie,8),marca,modelo,serie,anio,
				kms::numeric,fecha_cita,LEFT(hora_cita::text,5),color,inventario,
				now(),vendedor,persona_evento,'N',0,
				tipo_snack,desc_snack,tipo_bebida,desc_bebida,cve_asistir,
				concesionario,observaciones,medio_preferido,num_preferido,cte_propietario,
				tipo_snack_prop,desc_snack_prop,tipo_bebida_prop,desc_bebida_prop,medio_preferido_prop,
				num_preferido_prop,codigo);
		else 
			update keplersc.kdctasbienvser 
				set
				c3=usuario,
				c5=placas,
				c11=kms::numeric,
				c12=fecha_cita,
				c13=LEFT(hora_cita::text,5),
				c16=now(),
				c18=persona_evento,
				c19='S',
				c20=10,
				c21=tipo_snack,
				c22=desc_snack,
				c23=tipo_bebida,
				c24=desc_bebida,
				c25=cve_asistir,
				c29=concesionario,
				c30=observaciones,
				c31=medio_preferido,
				c32=num_preferido,
				c33=cte_propietario,
				c34=tipo_snack_prop,
				c35=desc_snack_prop,
				c36=tipo_bebida_prop,
				c37=desc_bebida_prop,
				c38=medio_preferido_prop,
				c39=num_preferido_prop,
				c40=codigo
				where c1=sucursal_id and c15=inventario;
				mensaje := 'Registro Bienvenida actualizado correctamente';
		end if;	
	
	
	end if;
raise notice 'Termino de ins o up';

	resultado := 1;
	if mensaje = '' then
		mensaje := 'Registro guardado';
	end if;
	
	return query select resultado, mensaje, adicionales;	

exception
	when others then
		resultado := 0;
		mensaje := 'bienvenida_crud() ' || '['|| sqlstate || '] ' || sqlerrm ;		
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
	
end;
$function$
