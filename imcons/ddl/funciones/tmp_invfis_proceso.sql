CREATE OR REPLACE FUNCTION keplersc.tmp_invfis_proceso()
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
declare
	--Variables de uso general 
	strValor text = '';
	intValor int = 0;

	--Variables de retorno
	resultado text;
	mensaje text;
	adicionales text;
begin

/* Este proceso es cuando en el excel estan todos los productos a actualizar
	1. Hacer una importacion de datos de excel a la tabla tmp_invfis_base.
		- El archivo de excel debe cumplir con el formato:
	   		Nombre fisico del archivo(renombrarlo si es necesario):tmp_invfis_base.xlsx
	   		Hoja unica del archivo con el nombre(renombrarlo si es necesario):tmp_invfis_base.xlsx
	   		Columnas: sucursal, parte, descripcion,teorico,fisico,valor_unitario y promedio
	   			La columna valor_unitario es el costo unitario, la columna promedio es el valor del inventario
	   		Eliminar comas, apostrofes y signos de pesos en todo el excel, la informacion util realmente es el numero de parte,fisico y valor unitario 
	   		Guardar el archivo de excel en formato cvs separado por comas
	   	- Usar la herramienta Import Data en dbeaver, pasar el csv a la tabla tmp_invfis_base
	   	- Auditar el archivo importado sumando las columnas fisico y valor unitario del excel y validar que el total es igual a un sum de los campos equivalentes en tmp_kdifis_base
		
		--Auditoria de tablas
			select * from keplersc.tmp_invfis_base base where parte not in 
			(select inl.c2 from keplersc.kdinl inl where inl.c2=base.parte);
		--Cantidades negativas
		select * from keplersc.tmp_invfis_base tib where tib.fisico <0 or tib.valor_unitario <0;	   	
		
		- Auditar que el sum de campos c6 y c7 ek kdifis cuadre con los correspondientes de físico y promedio del excel
			select sum(fisico) as cantidad, sum(valor_unitario) as costo from keplersc.tmp_invfis_base tib	
			
				   	    	   	    
	2. Generacion de kdifis a partir de tmp_invfis_base
		- Ejecutar:
			truncate table keplersc.kdifis;
			insert into keplersc.kdifis 
			select inl.c1,inl.c2,ini.c2,current_date,'',0,0,
			ini.c19,0,0,0,
			inl.c5-inl.c6,
			inl.c8-inl.c9
			from keplersc.kdinl inl 
			inner join keplersc.kdini ini on ini.c1=inl.c2
			inner join keplersc.tmp_invfis_base base on base.parte=inl.c2;
		- Auditar que el sum de campos c6 y c7 ek kdifis cuadre con los correspondientes de físico y promedio del excel
			select sum(fisico) as cantidad, sum(valor_unitario) as costo from keplersc.tmp_invfis_base tib		

	3. Completar registros de kdinl
		insert into keplersc.kdifis 
		select inl.c1,inl.c2,ini.c2,current_date,'',0,0,
		ini.c19,0,0,0,
		inl.c5-inl.c6,
		inl.c8-inl.c9
		from keplersc.kdinl inl 
		inner join keplersc.kdini ini on ini.c1=inl.c2
		where inl.c5-inl.c6 <> 0 or inl.c8-inl.c9 <> 0
		on conflict do nothing;	
*/


--Actualizar conteo fisico
	update keplersc.kdifis fis 
	set c6 = coalesce((select fisico from keplersc.tmp_invfis_base base where base.parte = fis.c2),0),
	c7 = coalesce((select valor_unitario from keplersc.tmp_invfis_base base where base.parte = fis.c2),0),
	costo_invent_real = coalesce((select promedio from keplersc.tmp_invfis_base base where base.parte = fis.c2),0);

--Calcular diferencias
	update keplersc.kdifis set c9=c6-cantidad_sis, c10=costo_invent_real-costo_invent_sis;	

--Continuar con el proceso desde la interfaz grafica


	resultado := 1;
	mensaje := '';
	adicionales := '';
	return query select resultado, mensaje, adicionales;	


/* Otras funciones	
--Generacion de kdifis a partir de kdinl
	truncate table keplersc.kdifis;
	insert into keplersc.kdifis 
	select inl.c1,inl.c2,ini.c2,current_date,'',0,0,
	ini.c19,0,0,0,
	inl.c5-inl.c6,
	inl.c8-inl.c9
	from keplersc.kdinl inl 
	inner join keplersc.kdini ini on ini.c1=inl.c2
	where inl.c5-inl.c6 <> 0 or inl.c8-inl.c9 <> 0;

--Auditoria kdinm, kdinl, kdink
select sum(cant_ent) as cant_ent, sum(monto_ent) as monto_ent, sum(cant_sal) cant_sal, sum(monto_sal) as monto_sal from
(select sum(c11) as cant_ent, 0 as cant_sal, sum(c12) as monto_ent, 0 as monto_sal from keplersc.kdinm where c6='A'
union
select 0 as cant_ent, sum(c11) as cant_sal, 0 as monto_ent, sum(c12) as monto_sal from keplersc.kdinm where c6='D' ) as total;

select sum(c5) as cant_ent, sum(c8) as monto_ent, sum(c6) as cant_sal,  sum(c9) as monto_sal from keplersc.kdinl;

select sum(c10+c11+c12+c13+c14+c15+c16+c17+c18+c19+c20+c21) as cant_ent,
sum(c22+c23+c24+c25+c26+c27+c28+c29+c30+c31+c32+c33) as monto_ent,
sum(c40+c41+c42+c43+c44+c45+c46+c47+c48+c49+c50+c51) as cant_sal,
sum(c52+c53+c54+c55+c56+c57+c58+c59+c60+c61+c62+c63) as monto_sal
from keplersc.kdink;

*/

exception
	when others then
		resultado := 0;
		mensaje := 'tmp_invfis_proceso() ' || '['|| sqlstate || '] ' || sqlerrm ;
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
end;
$function$
