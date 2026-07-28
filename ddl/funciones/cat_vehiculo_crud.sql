CREATE OR REPLACE FUNCTION keplersc.cat_vehiculo_crud(dataxml xml)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
--Descripcion: Realiza crud del catalogo de vehiculos en  KDIV
--Autor: Miriam Santana
--Fecha: 02/08/2023
--Bitacora de cambios
declare
	--Variables de definicion de documento
	cve_vehiculo text = '';
	descripcion text = '';
	clase text = '';
	marca text = '';
	cisan text = '';
	linea text = '';
	nou text = '';
	mesesprom text = '';
	produce text = '';
	precio text = '';
	cilindros text = '';
	ocupantes text = '';
	procedencia text = '';
	combustible text = '';
	puertas text = '';
	finivta text = '';
	reemplaza text = '';
	regla3 text = '';
	codsat text = '';
	unidad_medida text = '';
	crud text = '';
	linea_actual text ='';

   --Variables de retorno
	resultado text = '';
	mensaje text = '0';
    adicionales text = '';
	
begin 
	
	cve_vehiculo := (xpath('//document/k_clave/text()', dataxml))[1];
	descripcion := (xpath('//document/k_descripcion/text()', dataxml))[1];
	clase := (xpath('//document/k_clase/text()', dataxml))[1];
	marca := (xpath('//document/k_marca/text()', dataxml))[1];
	cisan := (xpath('//document/k_calc_isan/text()', dataxml))[1];
	linea := (xpath('//document/k_linea/text()', dataxml))[1];
	nou := (xpath('//document/k_nou/text()', dataxml))[1];
	mesesprom := coalesce((xpath('//document/k_mesesprom/text()', dataxml))[1],'0');
	produce := coalesce((xpath('//document/k_produce/text()', dataxml))[1],'');
	precio := coalesce((xpath('//document/k_precio/text()', dataxml))[1],'0');
	cilindros := coalesce((xpath('//document/k_cilindros/text()', dataxml))[1],'0');
	ocupantes := coalesce((xpath('//document/k_ocupantes/text()', dataxml))[1],'0');
	procedencia := coalesce((xpath('//document/k_procedencia/text()', dataxml))[1],'');
	combustible := coalesce((xpath('//document/k_combustible/text()', dataxml))[1],'');
	puertas := coalesce((xpath('//document/k_puertas/text()', dataxml))[1],'0');
	finivta := coalesce((xpath('//document/k_inivta/text()', dataxml))[1],'1800-01-01 00:00:00');
	reemplaza := coalesce((xpath('//document/k_reemplaza/text()', dataxml))[1],'');
	regla3 := coalesce((xpath('//document/k_regla3/text()', dataxml))[1],'');
	codsat := coalesce((xpath('//document/k_codsat/text()', dataxml))[1],'');
	unidad_medida :='XVN'; -- := (xpath('//document/k_unidad_medida/text()', dataxml))[1];
	crud := (xpath('//document/input_crud/text()', dataxml))[1];

	if crud <> 'ELIMINAR' then
		if cve_vehiculo is null then 
			raise exception 'Debe seleccionar una clave de vehículo';
		end if;
		if descripcion is null then 
			raise exception 'Debe especificar la descripción';
		end if;
		if clase is null then 
			raise exception 'Debe especificar la clase';
		end if;
		if marca is null then 
			raise exception 'Debe especificar la marca';
		end if;
		if cisan is null then 
			raise exception 'Debe especificar el tipo de cálculo de ISAN';
		end if;
		if linea is null then 
			raise exception 'Debe especificar la linea';
		end if;
		if nou is null then 
			raise exception 'Debe especificar N-Nuevo U-Usado';
		end if;
		if unidad_medida is null then 
			raise exception 'Debe especificar la unidad de medida';
		end if;
		
	end if; 

	if crud = 'NUEVO' then		
		insert into keplersc.kdiv 
			(c1,c2,c4,c5,
			c6,c7,c8,c10,
			c11,c14,
			c26,c27,c28,c30,
			c31,
			c50,
			c51,c52,c53,c54) 
		values(
			cve_vehiculo,descripcion,clase,marca,
			cisan,linea,nou,mesesprom::decimal,
			produce,precio::decimal,
			to_date(finivta,'YYYY-MM-DD'),reemplaza,regla3,codsat,
			unidad_medida,
			cilindros::integer,
			ocupantes::integer,procedencia,combustible,puertas::integer);
	end if;

	if crud = 'MODIFICAR' then
		select c7 into linea_actual
			from keplersc.kdiv
			where c1=cve_vehiculo;
		update keplersc.kdiv set 
			c2=descripcion,
			c4=clase,
			c5=marca,
			c6=cisan,
			c7=linea,
			c8=nou,
			c10=mesesprom::decimal,
			c11=produce,
			c14=precio::decimal,
			c26=to_date(finivta,'YYYY-MM-DD'),
			c27=reemplaza,
			c28=regla3,
			c30=codsat,
			c31=unidad_medida,
			c50=cilindros::integer,
			c51=ocupantes::integer,
			c52=procedencia,
			c53=combustible,
			c54=puertas::integer
		where c1=cve_vehiculo;
		if linea_actual <> linea then
			update keplersc.kdventas set
				c21=linea
			where c14=cve_vehiculo;
			
		end if;
	
	end if;
	--Realiza crud de paquetes en KDPAQ
	select * into resultado, mensaje, adicionales from keplersc.cat_vpaquetes_crud(dataxml);
	if resultado = '0' then
		raise exception '%',mensaje;
	end if;

	if crud = 'ELIMINAR' then
		delete from keplersc.kdiv 
			where c1=cve_vehiculo;
	end if;

	resultado := 1;
	mensaje := 'Registro agregado:' || cve_vehiculo;
	adicionales := '';
	return query select resultado, mensaje, adicionales;	

exception
	when others then
		resultado := 0;
		mensaje := 'cat_vehiculo_crud() ' || '['|| sqlstate || '] ' || sqlerrm ;		
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
	
end;
$function$
