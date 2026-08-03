CREATE OR REPLACE FUNCTION keplersc.autos_inv_compra(dataxml xml, xmlkdm1 xml, p_folio_operacion text, p_st_compra integer)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
declare
	--Esta funcion resuelve INV_COMPRA UEN AUTos  
	--Parametros de entrada en xml:dataXml--> Datos del movimiento; xmlkdm1--> Registro e kdm1 + 
	-- folio_operacion --> Folio asignado a la transacción + ST_Compra [ 0 Alta Compra, 10 Baja Compra ]
	--Parametros de salida tabla: campos resultado, mensaje y adicionales.
	--Author: Jose Mendoza 
	--Fecha: 17/10/2021
	--Bitacora de cambios:
	
	--Variables de uso general
	mensajeError text;
	expSql text;
	totalReg int;
	strValor text;
	folio_operacion text;
	ST_Compra_AUT int;
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
   	prov text;
   	fac text;
    vehi text;
   	modelo text;
   	anio_mod text;
   	marca text;
   	linea text;
   	nvousd text; 
   	importe text;
   	montoext4 text;
   	iva text;
   	importe_dec decimal;
   	montoext4_dec decimal;
   	iva_dec decimal;
   	es_trsp text; 
   	cve_comprador text; 
   	asesor_comprador text;
   	valuador text;
   
	--Variables de retorno
	resultado text;
	mensaje text; --Se asigna el valor esperado de la cuenta
	adicionales text;

begin
	
	ST_Compra_AUT := p_st_compra;
    folio_operacion := p_folio_operacion;

	select coalesce(max(j.c3),0) into Nxt_Part from keplersc.kdicom j 
	where c1 = (xpath('//row/c1/text()',xmlkdm1))[1]::text and c2 = (xpath('//row/c100/text()',xmlkdm1))[1]::text;
	
	-- Calcula siguiente partida ...
	Nxt_Part := Nxt_Part + 1;

	totalReg := 0;
	select count(*) into totalReg from keplersc.kdinf 
	where c1 = (xpath('//row/c1/text()',xmlkdm1))[1]::text and c2 = (xpath('//row/c100/text()',xmlkdm1))[1]::text; 
	if totalReg = 0 then
		raise exception '%', 'No se encontro el Registro en la Tabla KDINF.' || '['|| 'sub_autos_inv_compra()' || '] ';	
	end if; 
   
	totalReg := 0;
	select count(*) into totalReg from keplersc.kdiv 
	where c1 = (xpath('//document/c_modelo/text()',dataxml))[1]::text; 
	if totalReg = 0 then
		raise exception '%', 'No se encontro el Registro en la Tabla KDIV.' || '['|| 'sub_autos_inv_compra()' || '] ';	
	end if; 

	modelo := '';
	anio_mod := '';
	nvousd := '';
	marca := '';
	select c3, c15, c17, c21 into modelo, anio_mod, marca, nvousd from keplersc.kdinf 
	where c1 = (xpath('//row/c1/text()',xmlkdm1))[1]::text and c2 = (xpath('//row/c100/text()',xmlkdm1))[1]::text;
	if modelo is null or length(modelo) = 0 or anio_mod is null or length(anio_mod) = 0 or nvousd is null or length(nvousd) = 0 then
		raise exception '%', 'No se encontro la INFO en la Tabla KDINF.' || '['|| 'sub_autos_inv_compra()' || '] ';
	end if;

	linea := '';
	select c7 into linea from keplersc.kdiv 
	where c1 = (xpath('//document/c_modelo/text()',dataxml))[1]::text; 
	-- Se comento el codigo y se aplico el coalesce el 20221208 0100 por JMM
	/*
	if linea is null or length(linea) = 0 then 
		raise exception '%', 'No se encontro la INFO en la Tabla KDIV.' || '['|| 'sub_autos_inv_compra()' || '] ';
	end if;
	*/
	linea := coalesce(linea,'');

	suc := (xpath('//row/c1/text()',xmlkdm1))[1]::text;
	numinv := (xpath('//row/c100/text()',xmlkdm1))[1]::text;

	gen := (xpath('//row/c2/text()', xmlkdm1))[1];
	nat := (xpath('//row/c3/text()', xmlkdm1))[1];
	gpo := (xpath('//row/c4/text()', xmlkdm1))[1]::text;
	tipo := (xpath('//row/c5/text()', xmlkdm1))[1]::text;
	--folio := (xpath('//row/c6/text()', dataxml))[1];

	fecha := coalesce((xpath('//row/c9/text()', xmlkdm1))[1]::text,'1800-01-01 00:00:00')::text;

	prov := (xpath('//row/c10/text()', xmlkdm1))[1];

	--fac := (xpath('//row/c11/text()', xmlkdm1))[1];
	fac := (xpath('//row/c138/text()', xmlkdm1))[1]; -- returned to original 221111
	
	--vehi := (xpath('//document/c_modelo/text()',dataxml))[1]::text; 
	vehi := modelo;
    
	iva := coalesce((xpath('//row/c14/text()',xmlkdm1))[1]::text,'0')::text;
	montoext4 := coalesce((xpath('//row/c54/text()',xmlkdm1))[1]::text,'0')::text;
	importe := coalesce((xpath('//row/c16/text()',xmlkdm1))[1]::text,'0')::text;

	importe_dec := importe::decimal;
	montoext4_dec := montoext4::decimal;
	iva_dec := iva::decimal;

	es_trsp := (xpath('//row/c108/text()', xmlkdm1))[1];
	cve_comprador := coalesce((xpath('//row/c12/text()', xmlkdm1))[1]::text,''); 
	asesor_comprador := coalesce((xpath('//row/c44/text()', xmlkdm1))[1]::text,'');
	valuador := coalesce((xpath('//row/c45/text()', xmlkdm1))[1]::text,'');

	insert into keplersc.kdicom (
		c1, c2, c3, c4, c5, c6, c7, c8, c9, c10, c11, c12, c13, c14, c15, c16, c17, c18, c19, c20, c21, c22,   
		c23, c24, c25, c26, c27, c28, c29, c30, c31, c32, c33, c34, c35, c36, c37, c38, c39, c40, c41, c42 
	)
	values (
		suc, numinv, Nxt_Part, gen, nat, gpo::integer, tipo::integer, folio_operacion, to_date(fecha,'YYYY-MM-DD'), prov, 
		fac, ST_Compra_AUT, '', '', '', vehi, anio_mod, marca, linea, nvousd, '', '', importe_dec - montoext4_dec - iva_dec, 
		0, 0, 0, 0, 0, 0, 0, importe_dec - montoext4_dec - iva_dec, iva_dec, montoext4_dec, 0, 0, 0, importe_dec, '', es_trsp,
		cve_comprador, asesor_comprador, valuador 
	);

	resultado := 1;
	mensaje := '';
	adicionales := '';
	return query select resultado, mensaje, adicionales;	

exception
	when others then
		resultado := 0;
		mensaje := 'autos_inv_compra() ' || '['|| sqlstate || '] ' || sqlerrm;
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
end;
$function$
