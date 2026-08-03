CREATE OR REPLACE FUNCTION keplersc.tiempos_no_disponibles_crud(dataxml xml)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
--Descripcion: crud de tiempos no disponibles
--Autor: Luis Leal
--Fecha: 23/10/2023
--Bitacora de cambios
declare
	--Variables de definicion de documento
	fecha text = '';
	tipo_ope text = '';
	operario text = '';
	horas numeric;
	comentarios text = '';
	crud text = '';
	mes text; 
	anio text;
	nombre_dia text;
	hrs_laborales_semana numeric;
	hrs_laborales_fin numeric;
	activo text;
	horario_ini text;
	horario_fin text;
	mins text;


	resultado text = '';
	mensaje text = '0';
    adicionales text = '';
	
begin 
	
	fecha := upper((xpath('//document/fecha/text()', dataxml))[1]::text);
	tipo_ope := upper((xpath('//document/tipo_ope/r1/text()', dataxml))[1]::text);
	operario := upper((xpath('//document/operario/r1/text()', dataxml))[1]::text);
	horas := upper(coalesce((xpath('//document/horas/text()', dataxml))[1]::text,'0')::text);
	comentarios := upper(coalesce((xpath('//document/comentarios/text()', dataxml))[1]::text,'')::text);

	--LGLG 07/06/24
	horario_ini := upper(coalesce((xpath('//document/horario_ini/text()', dataxml))[1]::text,'')::text);
	horario_fin := upper(coalesce((xpath('//document/horario_fin/text()', dataxml))[1]::text,'')::text);


	crud := (xpath('//document/input_crud/text()', dataxml))[1];

	if crud = 'Nuevo' then
		if fecha is null then 
			raise exception 'Tiene que seleccionar una fecha';
		end if;
	
		if tipo_ope is null then 
			raise exception 'Tiene que seleccionar un tipo de operario';
		end if;
	
		if operario is null then 
			raise exception 'Tiene que seleccionar un operario';
		end if;
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

	if horas = 0 then
		raise exception 'El tiempo que se va a marcar como no disponible no puede ser negativo o cero.' ;
	end if;

	if comentarios = '' then 
		raise exception 'Debes introducir comentarios';
	end if;

	select c4,c5 into hrs_laborales_semana, hrs_laborales_fin from keplersc.kdserconfctas;

	SELECT trim(TO_CHAR(fecha::date , 'DAY')) into nombre_dia;

	if fecha::date <= current_date then
		raise exception '%', 'No puede marcar tiempo no disponible de días pasados o el día en curso.';
	end if;

	if nombre_dia = 'SATURDAY' then 
		if horas > hrs_laborales_fin then
			raise exception 'No puede marcar como no disponible un tiempo mayor a las horas disponibles laborables en sabado.' ; 
		end if;
	elsif nombre_dia = 'SUNDAY' then
		raise exception 'No puede marcar tiempo no disponible en días domingo.' ; 
	else
		if horas > hrs_laborales_semana then
			raise exception 'No puede marcar como no disponible un tiempo mayor a las horas disponibles laborables.' ; 
		end if;
	end if;

	select c12 into activo from keplersc.kdoper where c1=operario;

	if activo <> 'S' then
		raise exception 'No puede marcar tiempo no disponible de operarios no activos.' ; 
	end if;

	SELECT date_part('month', (SELECT fecha::date)) into mes ;

	SELECT date_part('year', (SELECT fecha::date)) into anio ;

	if crud = 'Nuevo' then		
		insert into keplersc.kdtiemposnd(c1,c2,c3,c4,c5,c6,c7,c9,c10) 
		values(operario,tipo_ope,fecha::date,horas,mes,anio,comentarios,horario_ini,horario_fin);
	end if;

	if crud = 'Modificar' then
		update keplersc.kdtiemposnd set c4=horas,c7=comentarios, c9=horario_ini, c10=horario_fin
		where c1=operario and c2=tipo_ope and c3=fecha::date;
	end if;

	if crud = 'Eliminar' then
		delete from keplersc.kdtiemposnd where c1=operario and c2=tipo_ope and c3=fecha::date;	
	end if;

	resultado := 1;
	mensaje := '';
	adicionales := '';
	return query select resultado, mensaje, adicionales;	

exception
	when others then
		resultado := 0;
	
		mensaje := 'tiempos_no_disponibles_crud() ' || '['|| sqlstate || '] ' || sqlerrm ;		

		adicionales := '';
		return query select resultado, mensaje, adicionales;	
	
end;
$function$
