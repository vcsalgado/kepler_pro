CREATE OR REPLACE FUNCTION keplersc.prod_consulta_lista(sucursal_id text, texto text, criterio text)
 RETURNS TABLE(sucursal text, clave_actual text, clave_original text, clave_ultima text, descripcion text, cadena_reemplazo text, existencias numeric)
 LANGUAGE plpgsql
AS $function$
declare

	--Variables de uso general
	clave_producto text = '';
	strValor text = '';
	intValor int = 0;
	totProd int = 0;
	mensaje text = '';
	fecha text = '';
	sqlExp text = '';
	espacio text = '''''';
	tilde text = '''';
	recProd record;
	numValor numeric = 0.00;

begin
	drop table if exists tmpResultados;
	create temp table tmpResultados (
		sucursal text,
		clave_actual text,
		clave_original text,
		clave_ultima text,
		descripcion text,
		cadena_reemplazo text,
		existencias numeric not null default 0.00
	);

	if upper(criterio)='DESCRIPCION' then
		sqlExp=concat('insert into tmpResultados 
			select ',tilde,sucursal_id,tilde,' as sucursal, c1 as clave_actual, c1 as clave_original, c1 as clave_ultima, ',
			'c2 as descripcion, ',espacio,' as cadena_reemplazo from keplersc.kdini where c2 like ',tilde, '%',texto,'%',tilde);
		raise notice '%',sqlExp;
		execute sqlExp;
	else 
		sqlExp=concat('insert into tmpResultados 
			select ',tilde,sucursal_id,tilde,' as sucursal, c1 as clave_actual, c1 as clave_original, c1 as clave_ultima, c2 as descripcion,',
			espacio, ' as cadena_reemplazo from keplersc.kdini where c1 like ',tilde, '%',texto,'%',tilde);
		raise notice '%',sqlExp;
		execute sqlExp;
		sqlExp=concat('insert into tmpResultados 
			select ',tilde,sucursal_id,tilde,' as sucursal, c1 as clave_actual, ',espacio, ' as clave_original,',espacio,' as clave_ultima, ',espacio,' as descripcion, ',
			espacio, ' as cadena_reemplazo from keplersc.kdinr where c1 like ',tilde, '%',texto,'%',tilde);	
		raise notice '%',sqlExp;
		execute sqlExp;
	end if;

	for recProd in select * from tmpResultados 
	loop
		if recProd.clave_original='' then
			--Obtener el producto origen en tabla de reemplazos	
			recProd.clave_original := recProd.clave_actual;
			totProd := 1;
			while totProd = 1 loop	
				select count(*) into totProd from keplersc.kdinr where c1 = recProd.clave_original;
				if totProd <> 0 then
					select c2 into strValor from keplersc.kdinr where c1 = recProd.clave_original;
					recProd.clave_original := strValor;
				end if;
			end loop;
		else 
			
		end if;
--raise notice 'recProd.clave_original %',recProd.clave_original;	
		--Obtener el producto actual y cadena de reemplazos en tabla de reemplazos
		recProd.clave_ultima := recProd.clave_original;
		recProd.cadena_reemplazo := recProd.clave_ultima;
		totProd := 1;
		while totProd = 1 loop	
			select count(*) into totProd from keplersc.kdinr where c2 = recProd.clave_ultima;
			if totProd <> 0 then
				select c1 into recProd.clave_ultima from keplersc.kdinr where c2 = recProd.clave_ultima;
				recProd.cadena_reemplazo := recProd.cadena_reemplazo || '|' || recProd.clave_ultima;		
			end if;
		end loop;

		--Verifica que el producto original actual se encuentre en la tabla de productos
		select coalesce(c2,'NO EXISTE') into recProd.descripcion from keplersc.kdini where c1 = recProd.clave_original;
		if recProd.descripcion = 'NO EXISTE' then
			raise exception 'El producto original % no existe.',recProd.clave_original;
		end if;
		
--		end if;
		--Obtiene la cantidad disponible
		numValor=0.00;
		select c5-c6 into numValor from keplersc.kdinl where c1=sucursal_id and c2=recProd.clave_original;

raise notice 'Existencias %',numValor;

		recProd.existencias=coalesce(numValor,0);
	
		update tmpResultados res set clave_original=recProd.clave_original, clave_ultima=recProd.clave_ultima,
			descripcion=recProd.descripcion, cadena_reemplazo=recProd.cadena_reemplazo, 
			existencias=recProd.existencias
		where res.sucursal=recProd.sucursal and res.clave_actual=recProd.clave_actual;
	
	end loop;
	return query select * from tmpResultados;	
end;
$function$
