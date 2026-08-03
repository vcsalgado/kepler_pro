CREATE OR REPLACE FUNCTION keplersc.autos_inv_status(dataxml xml, xmlkdm1 xml, xmlkdmm xml)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
declare
	--Esta funcion resuelve INV_STATUS UEN AUTos 
	--Aplicable a Compras, Ventas 
	--Parametros de entrada en xml:dataXml--> Datos del movimiento; xmlkdm1--> Registro en kdm1 + 
	-- Datos del Documento xmlkdmm --> Registro en kdmm 
	--Parametros de salida tabla: campos resultado, mensaje y adicionales.
	--Author: Jose Mendoza 
	--Fecha: 19/10/2021
	--Bitacora de cambios:
	
	--Variables de uso general
	mensajeError text;
	expSql text;
	totalReg int;
	strValor text;
	ST_Inventario_AUT int;

   
   --Variables kdm1
    campo_kdm1 text = '';
   	valor_kdm1 text = '';
   
    suc text;
    numinv text;
    vehi text;
   	modelo text;
   
	--Variables de retorno
	resultado text;
	mensaje text; --Se asigna el valor esperado de la cuenta
	adicionales text;

begin
	
	modelo := '';
	select c3 into modelo from keplersc.kdinf 
	where c1 = (xpath('//row/c1/text()',xmlkdm1))[1]::text and c2 = (xpath('//row/c100/text()',xmlkdm1))[1]::text;
	if modelo is null or length(modelo) = 0 then
		raise exception '%', 'No se encontro la INFO en la Tabla KDINF.' || '['|| 'sub_autos_inv_status()' || '] ';
	end if;

	strValor := '';
	select c3 into strValor from keplersc.kdasig 
	where c1 = (xpath('//row/c1/text()',xmlkdm1))[1]::text and c2 = (xpath('//row/c100/text()',xmlkdm1))[1]::text
		and c3 = modelo;
	if strValor is null or length(strValor) = 0 then
		raise exception '%', 'No se encontro la INFO en la Tabla KDINF.' || '['|| 'sub_autos_inv_status()' || '] ';
	end if;

	suc := (xpath('//row/c1/text()',xmlkdm1))[1]::text;
	numinv := (xpath('//row/c100/text()',xmlkdm1))[1]::text;
	vehi := modelo;
    
	-- Resuelve el caso de la Compra Registrada
	if (xpath('//row/c65/text()', xmlkdmm))[1]::text = '10' and 
		(xpath('//row/c2/text()', xmlkdmm))[1]::text = 'A' then
		
		ST_Inventario_AUT = 20;
		
		update keplersc.kdinf set c31 = ST_Inventario_AUT where c1 = suc and c2 = numinv and c3 = vehi;
	
		update keplersc.kdasig set c11 = ST_Inventario_AUT where c1 = suc and c2 = numinv and c3 = vehi;
	
	end if;

	-- Resuelve el caso de la Baja Compra Registrada 
	if (xpath('//row/c65/text()', xmlkdmm))[1]::text = '10' and 
		(xpath('//row/c2/text()', xmlkdmm))[1]::text = 'D' then
		
		ST_Inventario_AUT = 10;
		
		update keplersc.kdinf set c31 = ST_Inventario_AUT where c1 = suc and c2 = numinv and c3 = vehi;
	
		update keplersc.kdasig set c11 = ST_Inventario_AUT where c1 = suc and c2 = numinv and c3 = vehi;
	
	end if;

	if (xpath('//row/c65/text()', xmlkdmm))[1]::text <> '10' or
		(
			(xpath('//row/c2/text()', xmlkdmm))[1]::text <> 'A' and  
			(xpath('//row/c2/text()', xmlkdmm))[1]::text <> 'D' 
		) then 
		
		mensaje := 'No se pudo modificar el Estatus, Parametros No Validos ...' || '['|| 'sub_autos_inv_status()' || '] ';
		raise exception '%', mensaje;
			
	end if;

	resultado := 1;
	mensaje := '';
	adicionales := '';
	return query select resultado, mensaje, adicionales;	

exception
	when others then
		resultado := 0;
		mensaje := 'autos_inv_status() ' || '['|| sqlstate || '] ' || sqlerrm;
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
end;
$function$
