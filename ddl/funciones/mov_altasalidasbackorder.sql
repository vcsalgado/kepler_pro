CREATE OR REPLACE FUNCTION keplersc.mov_altasalidasbackorder(dataxml xml)
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
folio_operacion text :='0000157';

begin

	v_sucursal_id := upper((xpath('//document/k_sucn/text()', dataxml))[1]::text); --C1
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

	raise notice '|%',montoTotal ;
	
	for cont in 0..no_partidas - 1 loop
		numero_partida := cont + 1;
		
		idproducto := (xpath('//document/k_mov/r' ||cont||'/k_parte/text()',dataxml))[1];
		strValor := (xpath('//document/k_mov/r' ||cont||'/k_q/text()',dataxml))[1]::text;
		cantidad_producto := strValor::integer;
	raise notice '|%',v_sucursal_id;
	raise notice '|%',genero;
	raise notice '|%',naturaleza;
	raise notice '|%',grupo;
	raise notice '|%',tipo;
	raise notice '|%',folio;
	raise notice '|%',numero_partida;
	raise notice '|%',idproducto;
	raise notice '|%',cantidad_producto;
	raise notice '|%',fecha;
	raise notice '|%',hora;

	
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
