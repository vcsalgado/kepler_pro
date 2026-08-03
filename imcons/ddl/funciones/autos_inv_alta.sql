CREATE OR REPLACE FUNCTION keplersc.autos_inv_alta(dataxml xml, xmlkdm1 xml, p_folio_operacion text, p_tmov_invent integer)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
declare
	--Esta funcion resuelve INV_ALTA UEN AUTos  ( MOVs Inventario : Entradas / Salidas )
	--Parametros de entrada en xml:dataXml--> Datos del movimiento; xmlkdm1--> Registro e kdm1 + 
	-- folio_operacion --> Folio asignado a la transacción + Tipo_Movto_Inventario [ 0 Entrada Inventario, 10 Salida Inventario ]
	--Parametros de salida tabla: campos resultado, mensaje y adicionales.
	--Author: Jose Mendoza 
	--Fecha: 18/10/2021
	--Bitacora de cambios:
	
	--Variables de uso general
	mensajeError text;
	expSql text;
	totalReg int;
	strValor text;
	folio_operacion text;
	TMov_Invent_AUT int;
	Nxt_Part int;
   
   --Variables kdm1
    campo_kdm1 text = '';
   	valor_kdm1 text = '';
   
    suc text;
    numinv text;
   	gen text;
   	nat text;
   	gpo text;
   	tipo text;
    folio text;
   	fecha text;
    vehi text;
   	modelo text;
   	importe text;
   	montoext4 text;
   	iva text;
   	costo_dec decimal;
   	importe_dec decimal;
   	montoext4_dec decimal;
   	iva_dec decimal;

   
	--Variables de retorno
	resultado text;
	mensaje text; --Se asigna el valor esperado de la cuenta
	adicionales text;

begin
	
	TMov_Invent_AUT := p_tmov_invent;
    folio_operacion := p_folio_operacion;

	select coalesce(max(h.c3),0) into Nxt_Part from keplersc.kdeinv h 
	where c1 = (xpath('//row/c1/text()',xmlkdm1))[1]::text and c2 = (xpath('//row/c100/text()',xmlkdm1))[1]::text;
	
	-- Calcula siguiente partida ...
	Nxt_Part := Nxt_Part + 1;

	/*
	totalReg := 0;
	select count(*) into totalReg from keplersc.kdinf 
	where c1 = (xpath('//row/c1/text()',xmlkdm1))[1]::text and c2 = (xpath('//row/c100/text()',xmlkdm1))[1]::text; 
	if totalReg = 0 then
		raise exception '%', 'No se encontro el Registro en la Tabla KDINF.' || '['|| 'sub_inv_compra()' || '] ';	
	end if; 
    */

	modelo := '';
	select c3 into modelo from keplersc.kdinf 
	where c1 = (xpath('//row/c1/text()',xmlkdm1))[1]::text and c2 = (xpath('//row/c100/text()',xmlkdm1))[1]::text;
	if modelo is null or length(modelo) = 0 then
		raise exception '%', 'No se encontro la INFO en la Tabla KDINF.' || '['|| 'sub_autos_inv_alta()' || '] ';
	end if;

	suc := (xpath('//row/c1/text()',xmlkdm1))[1]::text;
	numinv := (xpath('//row/c100/text()',xmlkdm1))[1]::text;

	gen := (xpath('//row/c2/text()', xmlkdm1))[1];
	nat := (xpath('//row/c3/text()', xmlkdm1))[1];
	gpo := (xpath('//row/c4/text()', xmlkdm1))[1]::text;
	tipo := (xpath('//row/c5/text()', xmlkdm1))[1]::text;
	--folio := (xpath('//row/c6/text()', dataxml))[1];

	fecha := coalesce((xpath('//row/c9/text()', xmlkdm1))[1]::text,'1800-01-01 00:00:00')::text;

	vehi := modelo;
    
	iva := coalesce((xpath('//row/c14/text()',xmlkdm1))[1]::text,'0')::text;
	montoext4 := coalesce((xpath('//row/c54/text()',xmlkdm1))[1]::text,'0')::text;
	importe := coalesce((xpath('//row/c16/text()',xmlkdm1))[1]::text,'0')::text;

	importe_dec := importe::decimal;
	montoext4_dec := montoext4::decimal;
	iva_dec := iva::decimal;

	if gen = 'X' then
		costo_dec := importe_dec - montoext4_dec - iva_dec;
	else
		--- No esta desarrollada esta opcion
		--- Enviara error si entra por aqui debido al valor del Costo = 0, hasta que la opcion se Desarrolle 
		costo_dec := 0;
	end if;

	
	if costo_dec <= 0 then
		raise exception '%', 'El Costo de la Transaccion es igual a cero ...' || '['|| 'sub_autos_inv_alta()' || '] ';
	end if;

	insert into keplersc.kdeinv (
		c1, c2, c3, c4, c5, c6, c7, c8, c9, c10, c11, c12, c13 
	)
	values (
		suc, numinv, Nxt_Part, TMov_Invent_AUT, gen, nat, gpo::integer, tipo::integer, folio_operacion, to_date(fecha,'YYYY-MM-DD'), 
		costo_dec, iva_dec, vehi 
	);

	resultado := 1;
	mensaje := '';
	adicionales := '';
	return query select resultado, mensaje, adicionales;	

exception
	when others then
		resultado := 0;
		mensaje := 'autos_inv_alta() ' || '['|| sqlstate || '] ' || sqlerrm;
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
end;
$function$
