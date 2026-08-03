CREATE OR REPLACE FUNCTION keplersc.rep_horas_operarios(dataxml xml)
 RETURNS text
 LANGUAGE plpgsql
AS $function$
--Descripcion: Reporte horas por operario
--Autor: Luis Leal
--Fecha: 27/01/2023
--Bitacora de cambios
declare
	--Variables principales
	sucursal_id text = '';
	fecha_inicial text;
	fecha_final text;
	operario_inicial text;
	operario_final text;
	ope text;
	nombre_ope text;
	horas_total_ope numeric;
	orden text;
	punto text;
	cliente text;
	serie text;
	horas numeric;
	modelo text;
	placas text;

	--contadores--
	contador_opes int = 0;
 	contador_horas int = 0;

	--Variables de uso general 
	xmlResultado text = '';

begin

	sucursal_id := (xpath('//document/sucursal_id/text()', dataxml))[1];
	fecha_inicial := coalesce((xpath('//document/fecha_inicial/text()', dataxml))[1]::text,'')::text;
	fecha_final := coalesce((xpath('//document/fecha_final/text()', dataxml))[1]::text,'')::text;
	operario_inicial := coalesce((xpath('//document/operario_inicial/text()', dataxml))[1]::text,'')::text;
	operario_final := coalesce((xpath('//document/operario_final/text()', dataxml))[1]::text,'')::text;

	for ope, nombre_ope in select c1, c3 from keplersc.kdoper where c1 between operario_inicial and operario_final
	loop
			
		contador_opes := contador_opes + 1;

		xmlResultado := concat(xmlResultado, format('<r%1$s><operario>%2$s</operario><horas>',contador_opes, nombre_ope));
	
		horas_total_ope := 0; contador_horas = 0;
		for orden,punto, cliente, serie, horas in select hr.c2 || '-' || hr.c3, hr.c4, ord.c11, ord.c6, hr.c14  
		from keplersc.kdhorpag as hr inner join keplersc.kdord as ord on hr.c1=ord.c1 and hr.c2=ord.c2 and hr.c3=ord.c3
		where hr.c1=sucursal_id and hr.c5=0 and hr.c13=ope and hr.c11 between fecha_inicial::date and fecha_final::date
		loop 
						
			select c3,c8 into modelo, placas from keplersc.kdserie where c1=serie;			
			horas_total_ope := horas_total_ope + horas;			
	
			contador_horas := contador_horas + 1;

			xmlResultado := concat(xmlResultado, format('<r%1$s><orden>%2$s</orden><punto>%3$s</punto>
			<cliente>%4$s</cliente><vehiculo>%5$s</vehiculo><placas>%6$s</placas><horas>%7$s</horas></r%1$s>',
			contador_horas, orden, punto, cliente, modelo, placas, horas));
	
		end loop;
	
		xmlResultado := concat(xmlResultado, format('</horas><totales>%1$s</totales></r%2$s>',horas_total_ope ,contador_opes ));
	
	end loop;
		
	return xmlResultado::xml;

exception
	when others then
		--raise exception '%', 'Sin Resultados';	
		raise exception '%,%', sqlstate, sqlerrm;	
	
	
end;
$function$
