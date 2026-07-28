CREATE OR REPLACE FUNCTION keplersc.tmkt_control_de_citas(dataxml xml)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
--Descripcion: control de citas
--Autor: Luis Leal
--Fecha: 01/11/2023

declare
	sucursal_id text;
	fcha text;
	fol_cita text;
	hora_cita text;
	clave_oper text;
	tipo_ope text;
	nombre_ope text;
	ini_horario_comida text;
	fin_horario_comida text;
	tipo_pun text;
	col_horario text = '';
	col_comida text = '';
	hrs numeric;
	mins numeric;
	mins_prog numeric;
	horario_inicio text;
	horario_fin text;
	hrs_ini time;
	hrs_fin time;
	sql_select text;
	datos xml;
	registro text;

	get_resultado text;
	get_mensaje text; 
	get_adicionales text;

	expSql text;
	strValor text = '';
	resultado text = '';
	mensaje text = '';
    adicionales text = '';
      
	
begin 
	
	sucursal_id := (xpath('//document/k_sucN/r1/text()', dataxml))[1]::text; 
	fcha := (xpath('//document/fecha/text()', dataxml))[1]; 

	--error en xml si se manda desde otra funcion de postgress
	/*if sucursal_id = '01' then
		raise notice 'es igual %', sucursal_id;
	else
		raise notice 'no es igual %', sucursal_id;
	end if;*/

	delete from keplersc.control_de_citas where col_fecha=fcha::date;

	for clave_oper,tipo_ope, nombre_ope, ini_horario_comida, fin_horario_comida
	in select c1,c2,c3, c23,c24 from keplersc.kdoper where c12='S'
	loop 
						
		expSql := format('insert into keplersc.control_de_citas(col_fecha,col_clave_operador,
		col_nombre_ope, col_tipo_ope) values (%1$L,%2$L,%3$L,%4$L)', 
		fcha, clave_oper, nombre_ope, tipo_ope);
		
		execute expSql;
	
		--LLENA HORARIOS DE COMIDA
		if ini_horario_comida::text <> '' then
		
			hrs_ini := ini_horario_comida::time;
			hrs_fin := fin_horario_comida::time;
		
			while hrs_ini < hrs_fin loop
	
				col_comida := 	concat('h_',  split_part(hrs_ini::text, ':', '1') , '_',split_part(hrs_ini::text, ':', '2')) ;
						
				expSql := format('update keplersc.control_de_citas set %1$s=%2$L
				where col_fecha=%3$L and col_clave_operador=%4$L',
				col_comida, 'COMIDA', fcha, clave_oper);
											
				execute expSql;
				
				hrs_ini := hrs_ini + interval '15 minute';

			end loop;
		
		end if;
	
	end loop;



	for fol_cita, hora_cita in select c2,c13
	from keplersc.kdctasser where c1=sucursal_id and c12=fcha::date and c20 <> 30 and c20 <> 40 and c20 <> 50
	loop 
		
		for clave_oper, tipo_pun, horario_inicio, horario_fin in select c10,c4,c12,c13 from keplersc.kdctassermov 
		where c1=sucursal_id and c2=fol_cita order by c3 
		loop 
					
			if clave_oper = '' or horario_inicio = '' or  horario_fin = '' then
				continue;
			end if; 
				
			hrs_ini := horario_inicio::time;
			hrs_fin := horario_fin::time;

			while hrs_ini < hrs_fin loop
		
				col_horario := 	concat('h_',  split_part(hrs_ini::text, ':', '1') , '_',split_part(hrs_ini::text, ':', '2')) ;
			
				sql_select := format('select %1$s as registro from keplersc.control_de_citas 
				where col_fecha=%2$L and col_clave_operador=%3$L', col_horario, fcha, clave_oper);
									
				select query_to_xml(sql_select, false, true, '' ) :: xml into datos;

				registro := (xpath('//row/registro/text()', datos))[1];
				
				if registro is null then
				
					expSql := format('update keplersc.control_de_citas set %1$s=%2$L where col_fecha=%3$L and col_clave_operador=%4$L',
					col_horario , concat(fol_cita, '-', tipo_pun), fcha, clave_oper);
				
				end if;
				
												
				execute expSql;
					
				hrs_ini := hrs_ini + interval '15 minute';
	
			end loop;
	
		
		end loop;
		
	end loop;


	resultado := 1;
	mensaje := '';
	adicionales := '';
	return query select resultado, mensaje, adicionales;	

exception
when others then
	resultado := 0;
	mensaje := 'tmkt_control_de_citas() ' || '['|| sqlstate || '] ' || sqlerrm ;		
	adicionales := '';
	return query select resultado, mensaje, adicionales;	
	
end;
$function$
