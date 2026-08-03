CREATE OR REPLACE FUNCTION keplersc.mov_altasalidasbackorder(dataxml xml, folio_operacion text)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
	
declare
v_sucursal_id text = '';--k_sucN c1
strValor text:='';
no_partidas int;
genero text := ''; --c2
naturaleza text := ''; --c3
grupo int;--c4
tipo int; --c5
folio text :=''; --c6
partida int; --c7
numero_partida int;  
idproducto text :=''; --c8
cantidad_producto int; --c9
fecha timestamp; --c10
hora text :=''; --c11
tipomovimiento text = ''; --c12
montoTotal decimal;
resultado text := '';
mensaje text := '';
adicionales text := '';
totreg int = 0;
--folio_operacion text :='0000157';
expSql text = '';
fechaanio_aux text :='';
fechames_aux text :='';
registro int = 0;
begin

	v_sucursal_id := upper((xpath('//document/k_sucn/r1/text()', dataxml))[1]::text); --C1
	strValor := (xpath('//document/k_mov/no_partidas/text()',dataxml))[1];
	no_partidas := strValor::integer;
	genero := (xpath('//document/k_tipon/r1/text()',dataxml))[1]::text;
	naturaleza := (xpath('//document/k_tipon/r2/text()',dataxml))[1]::text;
	strValor := (xpath('//document/k_tipon/r3/text()',dataxml))[1]::text;
	grupo := strValor::integer;
	strValor :=	(xpath('//document/k_tipon/r4/text()',dataxml))[1]::text;
	tipo := strValor::integer;
	folio := folio_operacion;
	strValor:= (xpath('//document/k_fecha/text()',dataxml))[1]::text;
	fecha = strValor::Timestamp;
	hora := (xpath('//document/k_hora/text()',dataxml))[1]::text;
	strValor := (xpath('//document/k_monto/text()',dataxml))[1]::text;
	montoTotal := strValor::decimal; 

--	raise notice '|%,|%',folio,montoTotal ;
	
	for cont in 0..no_partidas - 1 loop
		numero_partida := cont + 1;
		
		idproducto := (xpath('//document/k_mov/r' ||cont||'/k_parte/text()',dataxml))[1];
		strValor := (xpath('//document/k_mov/r' ||cont||'/k_q/text()',dataxml))[1]::text;
		cantidad_producto := strValor::integer;
		
		------------- insertar en KDBOM	 L

		insert into keplersc.KDBOM (c1,c2,c3,c4,c5,c6,c7,c8,c9,c10,c11,c12) values 
		(v_sucursal_id,
		genero,
		naturaleza,
		grupo,
		tipo,
		folio,
		numero_partida,
		idproducto,
		cantidad_producto,
		fecha,
		hora,
		1);   
		
	 select into fechaanio_aux EXTRACT(YEAR FROM fecha);
--	raise notice 'sql: %',fechaanio_aux;
	select into fechames_aux EXTRACT(Month FROM fecha);
	select into strValor LPAD(fechames_aux,2,'0');

	------------------------insertar en KDBOK	K

	 	
	select into registro count(*) from keplersc.kdbok where c1 = v_sucursal_id and c2 = idproducto and c3 = fechaanio_aux and c4 = strValor;
	if  registro = 0 then 
		insert into keplersc.kdbok (c1,c2,c3,c4,c5,c6) values (v_sucursal_id,idproducto,fechaanio_aux,strValor,0,0);
	end if;

	------------------------insertar en KDBOL J

	select into registro count(*) from keplersc.kdbol where c1 = v_sucursal_id and c2 = idproducto;
	if  registro = 0 then 
		insert into keplersc.kdbol (c1,c2,c3,c4) values (v_sucursal_id,idproducto);
	end if;
	
	if naturaleza = 'A' then
			update keplersc.kdbol 
			set c4 = c4 + cantidad_producto
			where c1 = v_sucursal_id and c2 = idproducto;
		
			update keplersc.kdbok 
			set c6 = c6 + cantidad_producto
			where c1 = v_sucursal_id and c2 = idproducto and c3 = fechaanio_aux and c4 = strValor;
	else
			update keplersc.kdbol 
			set c3 = c3 + cantidad_producto
			where c1 = v_sucursal_id and c2 = idproducto;
		
			update keplersc.kdbok 
			set c5 = c5 + cantidad_producto
			where c1 = v_sucursal_id and c2 = idproducto and c3 = fechaanio_aux and c4 = strValor;
	end if;
	
	end loop ;	
	
	resultado := 1;
	mensaje := 'OK';
	adicionales := '';
	
	return query select resultado, mensaje,adicionales;
exception 
	when others then
		resultado:=0;
		mensaje := '' || sqlerrm ;
		adicionales := '';
		return query select resultado, mensaje, adicionales;

	END;
$function$
