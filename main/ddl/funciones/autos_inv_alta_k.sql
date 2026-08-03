CREATE OR REPLACE FUNCTION keplersc.autos_inv_alta_k(dataxml xml, xmlkdm1 xml, p_folio_operacion text, p_tmov_invent integer)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
declare
	--Esta funcion resuelve INV_ALTA_K UEN AUTos ( Estadisticas )
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
	intValor int = 0;
   
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
   	anio text;
   	mes text;
 	fechValor date;
    vehi text;
   	modelo text;
    color_int text;
    color_ext text;
    nvousd text; 
   	importe text;
   	montoext4 text;
   	iva text;
   	costo_dec decimal;
   	importe_dec decimal;
   	montoext4_dec decimal;
   	iva_dec decimal;
   
   	fech_kdeinv date;
   	fech_kdlinv date;
   	st_kdlinv int;
   	ent_u decimal;
   	sal_u decimal;

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
	Nxt_Part := Nxt_Part;

	if Nxt_Part = 0 then
		-- No encontro la partida que se debio registrar en el proceso / funcion predecesora 
		raise exception '%', 'No se encontro la INFO en la Tabla kdeinv.' || '['|| 'sub_autos_inv_alta_k()' || '] ';
	end if;

	/*
	totalReg := 0;
	select count(*) into totalReg from keplersc.kdinf 
	where c1 = (xpath('//row/c1/text()',xmlkdm1))[1]::text and c2 = (xpath('//row/c100/text()',xmlkdm1))[1]::text; 
	if totalReg = 0 then
		raise exception '%', 'No se encontro el Registro en la Tabla KDINF.' || '['|| 'sub_autos_inv_alta_k()' || '] ';	
	end if; 
    */

	modelo := '';
	color_int := '';
	color_ext := '';
	nvousd := '';
	select c3, c10, c11, c21 into modelo, color_int, color_ext, nvousd from keplersc.kdinf 
	where c1 = (xpath('//row/c1/text()',xmlkdm1))[1]::text and c2 = (xpath('//row/c100/text()',xmlkdm1))[1]::text;
	if modelo is null or length(modelo) = 0 or nvousd is null or length(nvousd) = 0 then
		raise exception '%', 'No se encontro la INFO en la Tabla KDINF.' || '['|| 'sub_autos_inv_alta_k()' || '] ';
	end if;

	select c10 into fech_kdeinv from keplersc.kdeinv 
	where c1 = (xpath('//row/c1/text()',xmlkdm1))[1]::text and c2 = (xpath('//row/c100/text()',xmlkdm1))[1]::text
		and c3 = Nxt_Part;
	if fech_kdeinv is null then
		raise exception '%', 'No se encontro la INFO en la Tabla kdeinv.' || '['|| 'sub_autos_inv_alta_k()' || '] ';
	end if;

	suc := (xpath('//row/c1/text()',xmlkdm1))[1]::text;
	numinv := (xpath('//row/c100/text()',xmlkdm1))[1]::text;

	gen := (xpath('//row/c2/text()', xmlkdm1))[1];
	nat := (xpath('//row/c3/text()', xmlkdm1))[1];
	gpo := (xpath('//row/c4/text()', xmlkdm1))[1]::text;
	tipo := (xpath('//row/c5/text()', xmlkdm1))[1]::text;
	--folio := (xpath('//row/c6/text()', dataxml))[1];

	fecha := coalesce((xpath('//row/c9/text()', xmlkdm1))[1]::text,'1800-01-01 00:00:00')::text;

	fechValor := to_date(fecha,'YYYY-MM-DD');

	intValor := extract(year from fechValor) /*year(fechValor)*/;
	anio := right(intValor::text,2);

	intValor := extract(month from fechValor);
	mes := lpad(intValor::text,2,'0');

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
		raise exception '%', 'El Costo de la Transaccion es igual a cero ...' || '['|| 'sub_autos_inv_alta_k()' || '] ';
	end if;


	-- TBL : kdginv 
	totalReg := 0;
	select count(*) into totalReg from keplersc.kdginv  
	where c1 = suc and c2 = numinv and c3 = mes::int and c4 = anio::int; 
	if totalReg = 0 then
		insert into keplersc.kdginv (
			c1, c2, c3, c4, c5, c6, c7, c8, c9, c10  
		)
		values (
			suc, numinv, mes::int, anio::int, 0, 0, vehi, color_ext, color_int, nvousd 
		);	
	end if; 


	-- TBL : kdlinv 
	totalReg := 0;
	select count(*) into totalReg from keplersc.kdlinv  
	where c1 = suc and c2 = numinv; 
	if totalReg = 0 then
		insert into keplersc.kdlinv (
			c1, c2, c3, c4, c5, c6, c7, c8, c9, c10, c11, c12, c13, c14, c15   
		)
		values (
			suc, numinv, 0, 0, 0, 0, to_date(current_date::text,'YYYY-MM-DD'), 0, 0, 0, 0, vehi, 0, color_ext, color_int  
		);	
	end if; 


	if TMov_Invent_AUT = 0 then	--  * * *  ENTRADA
	
		update keplersc.kdginv set c5 = c5 + 1, c11 = c11 + costo_dec, c13 = c13 + iva_dec 
		where c1 = suc and c2 = numinv and c3 = mes::int and c4 = anio::int; 
	
		update keplersc.kdlinv set c3 = c3 + 1, c5 = c5 + costo_dec, c10 = c10 + iva_dec 
		where c1 = suc and c2 = numinv;
		
	else --  * * *  SALIDA
	
		/*
		--- No esta desarrollada esta opcion
		--- Enviara error hasta que la opcion se Desarrolle 
		raise exception '%', 'Opcion : autos_inv_alta_k() No Desarrollada ...' || '['|| 'sub_autos_inv_alta_k()' || '] ';
		*/

		update keplersc.kdginv set c6 = c6 + 1, c12 = c12 + costo_dec, c14 = c14 + iva_dec 
		where c1 = suc and c2 = numinv and c3 = mes::int and c4 = anio::int; 
	
		update keplersc.kdlinv set c4 = c4 + 1, c6 = c6 + costo_dec, c11 = c11 + iva_dec 
		where c1 = suc and c2 = numinv;	
	
	end if;

	select k.c7, coalesce(k.c3,0), coalesce(k.c4,0) into fech_kdlinv, ent_u, sal_u from keplersc.kdlinv k 
	where k.c1 = (xpath('//row/c1/text()',xmlkdm1))[1]::text and k.c2 = (xpath('//row/c100/text()',xmlkdm1))[1]::text;
	if fech_kdlinv is null then
		raise exception '%', 'No se encontro la INFO en la Tabla kdlinv.' || '['|| 'sub_autos_inv_alta_k()' || '] ';
	end if;

	if (gen = 'X' or gen = 'N') and nat = 'A' then 
	
		if fech_kdeinv < fech_kdlinv then
			fech_kdlinv = fech_kdeinv;
		end if;
	
	end if;

	if ent_u <= sal_u then
		st_kdlinv = 10;
	else
		st_kdlinv = 0;
	end if;
		
	update keplersc.kdlinv set c7 = fech_kdlinv, c8 = costo_dec, c9 = iva_dec, c13 = st_kdlinv 
	where c1 = suc and c2 = numinv;
	
	resultado := 1;
	mensaje := '';
	adicionales := '';
	return query select resultado, mensaje, adicionales;	

exception
	when others then
		resultado := 0;
		mensaje := 'autos_inv_alta_k() ' || '['|| sqlstate || '] ' || sqlerrm;
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
end;
$function$
