CREATE OR REPLACE FUNCTION keplersc.alta_pedido_sugerido(dataxml xml, p_folio_operacion text)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
declare
	--Esta funcion resuelve ALTA_PEDIDO_SUGERIDO UEN REF  
	--Parametros de entrada en xml:
	-- dataXml--> Datos del movimiento; 
	-- folio_operacion --> Folio asignado a la transaccion
	--Parametros de salida tabla: campos resultado, mensaje y adicionales.
	--Author: Jose Mendoza 
	--Fecha: 3/09/2023
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
    
	--Variables de retorno
	resultado text;
	mensaje text; --Se asigna el valor esperado de la cuenta
	adicionales text;

begin
	
	suc := (xpath('//document/k_sucn/r1/text()', dataxml))[1];
	gen := (xpath('//document/k_tipon/r1/text()', dataxml))[1];
	nat := (xpath('//document/k_tipon/r2/text()', dataxml))[1];
	gpo := (xpath('//document/k_tipon/r3/text()', dataxml))[1];
	tipo := (xpath('//document/k_tipon/r4/text()', dataxml))[1];

	refer := (xpath('//document/k_refer/text()', dataxml))[1];

    folio := p_folio_operacion; 
   
    fecha := coalesce((xpath('//document/k_fecha/text()', dataxml))[1]::text,'1800-01-01 00:00:00')::text;
   
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
   

	update keplersc.kdpedesp   
	set 
		c16 = gen,
	    c17 = nat,
	    c18 = gpo::integer,
	    c19 = tipo::integer,
	    c20 = folio,
	    c21 = to_date(fecha,'YYYY-MM-DD') 
	where c14 = suc and c15 = refer;


	update keplersc.kdpedrefmov   
	set 
		c4 = gen,
	    c5 = nat,
	    c6 = gpo::integer,
	    c7 = tipo::integer,
	    c8 = folio,
	    c9 = to_date(fecha,'YYYY-MM-DD'),
	    c10 = 20
	where c1 = suc and c2 = refer;

	update keplersc.kdpedref   
	set 
	    c4 = 20
	where c1 = suc and c2 = refer;

	resultado := 1;
	mensaje := '';
	adicionales := '';
	return query select resultado, mensaje, adicionales;	

exception
	when others then
		resultado := 0;
		mensaje := 'alta_pedido_sugerido() ' || '['|| sqlstate || '] ' || sqlerrm;
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
end;
$function$
