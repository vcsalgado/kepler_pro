CREATE OR REPLACE FUNCTION keplersc.vin_crud(dataxml xml)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
--Descripcion: crud vin
--Autor: Luis Leal
--Fecha: 14/12/2021
--Bitacora de cambios
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
  	Ano text = '';
  	codeanio text = '';
  
  	kilometraje decimal =0.00;
  
 	Fecha_venta text = '';
	Concesionario text = '';
	Ultima_visita text = '';
	Codigo_planta text = '';
	isidentificadoralfanumeric bool;
	isidentificadornumeric bool;
	iskilometraje bool;


	crud text = '';

	resultado text = '';
	mensaje text = '0';
    adicionales text = '';
	
begin 
	
	Marca := upper((xpath('//document/input_marca/r1/text()', dataxml))[1]::text);
	Modelo := upper((xpath('//document/input_modelo/r1/text()', dataxml))[1]::text);
	Serie := upper((xpath('//document/input_serie/text()', dataxml))[1]::text);
	Motor := upper(coalesce((xpath('//document/input_motor/text()', dataxml))[1]::text,'')::text);
	Transmision := upper(coalesce((xpath('//document/input_transmision/text()', dataxml))[1]::text,'')::text);
	Eje_trasero := upper(coalesce((xpath('//document/input_eje_trasero/text()', dataxml))[1]::text,'')::text);
	Placas := upper(coalesce((xpath('//document/input_placas/text()', dataxml))[1]::text,'')::text);
	Contacto := upper(coalesce((xpath('//document/input_contacto/text()', dataxml))[1]::text,'')::text);
	Color := upper(coalesce((xpath('//document/input_color/text()', dataxml))[1]::text,'')::text);
	Ano := coalesce((xpath('//document/input_ano/r1/text()', dataxml))[1]::text,'')::text;
	kilometraje := coalesce((xpath('//document/input_kilometraje/text()', dataxml))[1]::text,'0.00')::decimal;
	Fecha_venta := coalesce((xpath('//document/input_fecha_venta/text()', dataxml))[1]::text,'0001-01-01')::text;
	Concesionario := coalesce((xpath('//document/input_concesionario/r1/text()', dataxml))[1]::text,'')::text;
	Ultima_visita := coalesce((xpath('//document/input_ult_visita/text()', dataxml))[1]::text,'0001-01-01')::text;
	Codigo_planta := upper(coalesce((xpath('//document/input_codigo_planta/text()', dataxml))[1]::text,'')::text);

	crud := (xpath('//document/input_crud/text()', dataxml))[1];

	
	if crud <> 'Eliminar' then
	
		if Marca is null then 
			raise exception 'Tiene que seleccionar una marca';
		end if;
	
		if Modelo is null then 
			raise exception 'Tiene que seleccionar una modelo';
		end if;
	
		if Serie is null then 
			raise exception 'Tiene que introducir una serie';
		end if;
	
		if length(Serie) <> '17' then 
			raise exception 'La serie debe ser de 17 digitos';
		end if;
	
		Identificador := right(Serie, 8);
	
		if substring(Serie,10,8) <> Identificador then
			raise exception 'El identificador no coincide con los últimos 8 carácteres de la serie';
		end if;
	
		select Identificador ~ '^(?=.*[a-zA-Z])(?=.*[0-9])[A-Za-z0-9]+$' into isidentificadoralfanumeric; 
		select Identificador ~ '^[0-9\.]+$' into isidentificadornumeric; 
		if not isidentificadoralfanumeric and not isidentificadornumeric then 
			raise exception 'Los ultimos debe ser numerico o Alfanumerico';
		end if;
		
	
		if Placas = '' then 
			raise exception 'Tiene que introducir Placas';
		end if;
	
		if Color = '' then 
			raise exception 'Debe ingresar el color del vehículo';
		end if;
		
		/*if Fecha_venta = '0001-01-01' then
			raise exception 'Debe ingresar la fecha de venta del vehículo';
		end if;*/
	
		if Contacto = '' then 
			raise exception 'Debe ingresar Contacto';
		end if;
	
		if Ano = '' then 
			raise exception 'Debe ingresar Año';
		end if;
	
		/*if Codigo_planta = '' then 
			raise exception 'Debe ingresar el Codigo de planta';
		end if;*/
	
		select c2 into codeanio from keplersc.kdyearcode where c1 = Ano;
		if codeanio <> substring(Serie,10,1) then
			raise exception 'El año no coincide con el indicado en la serie en su carácter 10';
		end if;
	

	
	end if; 


	if crud = 'Nuevo' then
					
		insert into keplersc.kdserie(c1,c2,c3,c4,c5,c6,c7,c8,c9,c10,c11,c12,c13,c14,c15 ,c17) 
		values(Identificador,Marca, Modelo, Serie, Motor, Transmision,Eje_trasero, Placas, Contacto, Color,
		Ano, kilometraje,to_date(Fecha_venta,'YYYY-MM-DD'), Concesionario,to_date(Ultima_visita,'YYYY-MM-DD'), 
		Codigo_planta);

	end if;

	if crud = 'Modificar' then
					
		update keplersc.kdserie set c1=Identificador,c2=Marca,c3=Modelo,c4=Serie,c5=Motor,c6=Transmision,
		c7=Eje_trasero,c8=Placas,c9=Contacto,c10=Color,c11=Ano,c12=kilometraje,c13=to_date(Fecha_venta,'YYYY-MM-DD'),
		c14=Concesionario,c15=to_date(Ultima_visita,'YYYY-MM-DD') ,c17=Codigo_planta where c1=Identificador;

	end if;

	if crud = 'Eliminar' then
	
		delete from keplersc.kdserie where c4=Serie;
					
	end if;


	resultado := 1;
	mensaje := 'Vin agregado:' || Identificador;
	adicionales := '';
	return query select resultado, mensaje, adicionales;	

exception
	when others then
		resultado := 0;
	
		mensaje := 'vin_crud() ' || '['|| sqlstate || '] ' || sqlerrm ;		

		adicionales := '';
		return query select resultado, mensaje, adicionales;	
	
end;
$function$
