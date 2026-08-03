CREATE OR REPLACE FUNCTION keplersc.cont_agrupa_cuentas(dataxml xml)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
--Descripcion: Agrupa cuentas y suma saldos correspondientes a los cargos y abonos, y deja un solo registro de C y A  
--Autor: Miriam Santana
--Fecha: 22/07/2024
--Bitacora de cambios
declare
	--Variables de definicion de documento
	sucursal_id text = '';	--col_sucursal
	stranio text='';
	strmes text='';
	poliza text='';
	tipo_poliza text='';

	--Variables de uso general
	cambiaTipo int;
	strValor text;	
	nombre_tabla text;
	sqlExp text;
	dif_original decimal;
	dif_agrupadas decimal;
	partida int;
	tipo_upd text='';
	rec record;

    --Variables de retorno
	resultado text = '';
	mensaje text = '0';
    adicionales text = '';
	
begin 
	sucursal_id := (xpath('//document/sucursal/text()', dataxml))[1];
	stranio := (xpath('//document/anio/text()', dataxml))[1];
	strmes := (xpath('//document/mes/text()', dataxml))[1];
	poliza := (xpath('//document/num_poliza/text()', dataxml))[1];
	tipo_poliza := (xpath('//document/tipo/text()', dataxml))[1];
	
	--Tabla de Polizas
	nombre_tabla = concat('kdc2',lpad(stranio,2,'0'),lpad(strmes,2,'0')); 
	
	--Obtiene difeerncia entre cargos y abonos antes de agrupar
	sqlExp := format('select (sum(pol.cargo_movto) - sum(pol.abono_movto)) as diferencia from (
			 	select c1,
				case when c4 = ''C'' then sum(c5) else 0 end cargo_movto, 
				case when c4 = ''A'' then sum(c5) else 0 end abono_movto
				from keplersc.%1$s
				where c1=%2$s and c8=%3$L and c14=%4$L
				group by c1,c4) as pol',nombre_tabla,poliza,tipo_poliza,sucursal_id);
			
	execute sqlExp into dif_original;
	 
	partida=0;
	sqlExp := format('select c2,c3,c4,
			case when c4 = ''C'' then sum(c5) else 0 end cargo_movto,
			case when c4 = ''A'' then sum(c5) else 0 end abono_movto,
			c6,c7,c15,c16,c17,c18,c19,c33
			from keplersc.%1$s
			where c1=%2$s and c8=%3$L and c14=%4$L
			group by c2,c3,c4,c6,c7,c15,c16,c17,c18,c19,c33
			order by c3,c4 desc',nombre_tabla,poliza,tipo_poliza,sucursal_id);
	
	cambiaTipo=0;
	for rec in execute sqlExp 
	loop
		if cambiaTipo=0 then
			--Cambiar el c8 tipo de p lzia por B para que permita hacer los nuevos inserts
			sqlExp := format('update keplersc.%1$s set c8=''B'' where c1=%2$s and c8=%3$L and c14=%4$L',nombre_tabla,poliza,tipo_poliza,sucursal_id);
			execute sqlExp;
			cambiaTipo=1;	
		end if;	
		partida=partida+1;
		if rec.c4 ='C' then
			sqlExp := format('insert into keplersc.%1$s 
					(c1,c2,c3,c4,c5,
					c6,c7,c8,c10,
					c14,c15,
					c16,c17,c18,c19,c33)
					values (
					%2$s,%3$L,%4$L,%5$L,%6$s,
					%7$L,%8$L,%9$L,%10$s,
					%11$L,%12$L,
					%13$L,%14$L,%15$L,%16$L,%17$L)',nombre_tabla,poliza,rec.c2,rec.c3,rec.c4,rec.cargo_movto,
					rec.c6,rec.c7,tipo_poliza,partida,
					sucursal_id,rec.c15,
					rec.c16,rec.c17,rec.c18,rec.c19,rec.c33);
	
			execute sqlExp;
		end if;
		if rec.c4 ='A' then
			sqlExp := format('insert into keplersc.%1$s 
					(c1,c2,c3,c4,c5,
					c6,c7,c8,c10,
					c14,c15,
					c16,c17,c18,c19,c33)
					values (
					%2$s,%3$L,%4$L,%5$L,%6$s,
					%7$L,%8$L,%9$L,%10$s,
					%11$L,%12$L,
					%13$L,%14$L,%15$L,%16$L,%17$L)',nombre_tabla,poliza,rec.c2,rec.c3,rec.c4,rec.abono_movto,
					rec.c6,rec.c7,tipo_poliza,partida,
					sucursal_id,rec.c15,
					rec.c16,rec.c17,rec.c18,rec.c19,rec.c33);

			execute sqlExp;
		end if;
	end loop;
	
	--Validar que sumen lo mismo ya agrupadas
	sqlExp := format('select (sum(pol.cargo_movto) - sum(pol.abono_movto)) as diferencia from (
			select c2,c3,c4,
			case when c4 = ''C'' then sum(c5) else 0 end cargo_movto,
			case when c4 = ''A'' then sum(c5) else 0 end abono_movto,
			c6,c7,c15,c16,c17,c18,c19,c33
			from keplersc.%1$s
			where c1=%2$s and c8=%3$L and c14=%4$L
			group by c2,c3,c4,c6,c7,c15,c16,c17,c18,c19,c33
			order by c3,c4 desc) as pol',nombre_tabla,poliza,tipo_poliza,sucursal_id);
	
	execute sqlExp into dif_agrupadas;

	if dif_original <> dif_agrupadas then
		raise exception 'Revisar proceso de agrupacion de cuentas, existe diferencia entre los montos de C y A originales y los montos agrupados';
	else
		--Eliminar registros anteriores
		tipo_upd ='B';
		sqlExp := format('delete from keplersc.%1$s	where c1=%2$s and c8=%3$L and c14=%4$L',nombre_tabla,poliza,tipo_upd,sucursal_id);

		execute sqlExp;
	end if; 
		
	resultado := 1;
	mensaje := 'Registro exitoso';
	adicionales := '';
	return query select resultado, mensaje, adicionales;	

exception
	when others then
		resultado := 0;
		mensaje := 'cont_agrupa_cuentas() ' || '['|| sqlstate || '] ' || sqlerrm ;		
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
	
end;
$function$
