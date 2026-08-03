CREATE OR REPLACE FUNCTION keplersc.baja_pedido_sugerido(dataxml xml)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
declare
	--Esta funcion resuelve BAJA_PEDIDO_SUGERIDO UEN REF  
	--Parametros de entrada en xml:
	-- dataXml--> Datos del movimiento; 
	-- folio_operacion --> Folio asignado a la transaccion
	--Parametros de salida tabla: campos resultado, mensaje y adicionales.
	--Author: Jose Mendoza 
	--Fecha: 5/11/2023
	--Bitacora de cambios:
	
	--Variables de uso general
	mensajeError text;
	expSql text;
	totalReg int;
	strValor text;
   
    campo text = '';
   	valor text = '';
   
    suc text;
   	gen text;
   	nat text;
   	gpo text;
   	tipo text;
    folio text;
   	fecha text;
   	refer text;
   
   	pedmax text;
    pedst int;
    
	--Variables de retorno
	resultado text;
	mensaje text; --Se asigna el valor esperado de la cuenta
	adicionales text;

begin
	
	suc := (xpath('//document/k_sucn/r1/text()', dataxml))[1];
	/*
	gen := (xpath('//document/k_tipon/r1/text()', dataxml))[1];
	nat := (xpath('//document/k_tipon/r2/text()', dataxml))[1];
	gpo := (xpath('//document/k_tipon/r3/text()', dataxml))[1];
	tipo := (xpath('//document/k_tipon/r4/text()', dataxml))[1];
	folio := (xpath('//document/k_folio/text()', dataxml))[1];
	*/

	refer := (xpath('//document/k_refer/text()', dataxml))[1];

    --folio := p_folio_operacion; 
   
    -- k_fecha
    fecha := coalesce((xpath('//document/movimiento/fecha/text()', dataxml))[1]::text,'1800-01-01 00:00:00')::text;
   
	totalReg := 0;
	select count(*) into totalReg from keplersc.kdpedrefmov   
	where c1 = suc and c2 = refer; 
	if totalReg = 0 then
		raise exception '%', 'No se encontro Registro del Pedido Sugerido - Detalle ' || '['|| refer || '] ';	
	end if; 

	totalReg := 0;
	select count(*) into totalReg from keplersc.kdpedref   
	where c1 = suc and c2 = refer; 
	if totalReg = 0 then
		raise exception '%', 'No se encontro Registro del Pedido Sugerido - Encabezado ' || '['|| refer || '] ';	
	end if; 

	-- Verificar si es el ultimo Pedido Generado para validar si procede ajustar los valores de las Tablas
    -- Involucradas, sino quedaran con los datos que tienen al momento de la operacion como parte del rastreo 
    -- de las operaciones (donde para kdm2 si se eliminan los registros en la operacion : Baja)
   
	
	select lpad(coalesce(max(c2),''),10,'0') into pedmax from keplersc.kdpedref 
	where c1 = suc;  
		/*and c2 <> '0000000954X';  --4 Testing*/
	
	select coalesce(c4,-1) into pedst from keplersc.kdpedref 
	where c1 = suc and c2 = refer;
	
		
	-- Condiciones para actualizar las tablas (Ultimo Pedido, ST Asinado)
	if refer = pedmax and pedst = 20 then
	
		raise notice/*exception*/ '%', 'Se procesaran cambios ... [baja_pedido_sugerido] ... Testing Option';

		update keplersc.kdpedesp   
		set 
			c16 = '',
		    c17 = '',
		    c18 = 0,
		    c19 = 0,
		    c20 = '',
		    c21 = to_date(fecha,'YYYY-MM-DD') 
		where c14 = suc and c15 = refer;
	
	
		update keplersc.kdpedrefmov   
		set 
			c4 = '',
		    c5 = '',
		    c6 = 0,
		    c7 = 0,
		    c8 = '',
		    c9 = to_date(fecha,'YYYY-MM-DD'),
		    c10 = 10 /*20*/
		where c1 = suc and c2 = refer;
	
		update keplersc.kdpedref   
		set 
		    c4 = 10 /*20*/
		where c1 = suc and c2 = refer;
	
	else
		
		-- No hara nada porque no se esta procesando el ultimo pedido o el ST <> 20 
		raise notice '%', 'No se procesaran cambios ... [baja_pedido_sugerido]';
	
	end if;

	resultado := 1;
	mensaje := '';
	adicionales := '';
	return query select resultado, mensaje, adicionales;	

exception
	when others then
		resultado := 0;
		mensaje := 'baja_pedido_sugerido() ' || '['|| sqlstate || '] ' || sqlerrm;
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
end;
$function$
