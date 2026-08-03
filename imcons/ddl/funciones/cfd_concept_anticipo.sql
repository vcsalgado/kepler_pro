CREATE OR REPLACE FUNCTION keplersc.cfd_concept_anticipo(dataxml xml, xmlkdm1 xml, xmlkdmm xml, cons_cfdi text)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
declare
--Descripcion: Genera informacion para CFDI. Resuelve CFD_CONCEPT_ANTICIPO
--Autor: Miriam Santana
--Fecha: 05/10/2022
--Bitacora de cambios
--22/12/2024 Miriam Santana: Se eliminaron validaciones de una sustitucion c86='S'
--13/03/2025 Miriam Santana: Aplicacion de anticipo

	--Variables para xml 
	sucursal_id text;
	genero text;
	naturaleza text;
	grupo text;
	tipo text;

	--Variables de uso general
	folio_operacion text;
	partida int = 1;
	cantidad int = 1;
	unid_medida text = 'ACT';
	cve_prodserv text= '84111506';
	descripcion text;
	precio_sin_impto decimal=0;
	cve_impto text = '002';
	tipo_factor text = 'TASA';		--Tasa, Cuota o Exento
	tasa_impto decimal=0;
	monto_iva text;
	monto_base_impto decimal=0;
	cve_catprodserv text ='';

	flag_cobros text = '';				--MSS 13032025 Aplicacion de anticipos

	strValor text;
	decValor decimal=0;

	--Variables de retorno
	resultado text;
	mensaje text;
	adicionales text;	
begin
	--Transaccion
	sucursal_id := (xpath('//document/k_sucn/r1/text()', dataxml))[1];
	genero := (xpath('//document/k_tipon/r1/text()', dataxml))[1];
	naturaleza := (xpath('//document/k_tipon/r2/text()', dataxml))[1];
	grupo := (xpath('//document/k_tipon/r3/text()', dataxml))[1];
	tipo := (xpath('//document/k_tipon/r4/text()', dataxml))[1];
	folio_operacion := (xpath('//row/c6/text()', xmlKDM1))[1];

	flag_cobros :=coalesce((xpath('//document/ambiente/flag_cobros/text()',dataxml))[1]::text,'')::text;		--MSS 13032025 Aplicacion de anticipos

	if (xpath('//row/c86/text()', xmlKDMM))[1]::text = 'A' then             
		--Descripcion
		if naturaleza = 'D' then 
           	descripcion :='ANTICIPO DEL BIEN O SERVICIO';
       	end if;
       	if naturaleza = 'A' then		
			if flag_cobros = 'APLICA_ANTICIPO' then					--MSS 13032025 Aplicacion de anticipos
				descripcion :='APLICACION DE ANTICIPO';
			else
           		descripcion :='NOTA DE CREDITO DEL ANTICIPO';
           	end if;
       	end if;
    end if;
    if (xpath('//row/c86/text()', xmlKDMM))[1]::text = 'P' then 
       	descripcion :='PAGO DEL BIEN O SERVICIO';
    end if;
   	if (xpath('//row/c86/text()', xmlKDMM))[1]::text = 'F' then
       	if naturaleza = 'D' then 
           	descripcion= 'FACTURA DEL BIEN O SERVICIO';
       	end if;
        if naturaleza = 'A' then 
           	descripcion='NOTA DE CREDITO DE LA FACTURA';
        end if;
    end if;
	if (xpath('//row/c65/text()', xmlKDMM))[1]::text = '90' and (xpath('//row/c44/text()', xmlKDM1))[1]::text <> '' and 
		(xpath('//row/c47/text()', xmlKDM1))[1]::text <> '' then
       	unid_medida :='C62';													--Unidad de Medida
       	cve_prodserv := (xpath('//row/c44/text()', xmlKDM1))[1]::text;			--Clave del Producto o Servicio
       	descripcion := (xpath('//row/c47/text()', xmlKDM1))[1]::text;			--Descripcion
    end if;
	strValor := (xpath('//row/c16/text()', xmlKDM1))[1]::text;
	decValor := strValor::decimal;
	strValor := (xpath('//row/c14/text()', xmlKDM1))[1]::text;
	precio_sin_impto :=  decValor-strValor::decimal;	--B7843=W16-W14 B7844=W16-W14   --Precio Unitario sin Impuestos
    strValor := coalesce((xpath('//row/c16/text()', xmlKDMM))[1]::text,'0');
    tasa_impto := strValor::decimal/100;      									--Porcentaje
    monto_iva := (xpath('//row/c14/text()', xmlKDM1))[1]::text;      			--Monto del Impuesto
    if tasa_impto > 0 then
     	--monto_base_impto := monto_iva::decimal/tasa_impto;							--Monto para la Base del Calculo de Impuesto
    	monto_base_impto := precio_sin_impto;							--Monto para la Base del Calculo de Impuesto
    else
    	monto_base_impto :=0;
    end if;

    if monto_base_impto <= 0 then 
       	monto_base_impto := 0.01;												--La base del impuesto no puede ser 0
    end if;
    insert into keplersc.kdf3concept (
    	c1,c2,c3,c4,c5,
		c6,c7,c8,c9,c10,
		c11,c12,c13,c14,c15,
		c16,c17,c18,C19,c20)
		values(
		sucursal_id,genero,naturaleza,grupo::integer,tipo::integer,
		folio_operacion,cons_cfdi::integer,partida,cantidad,unid_medida,
		coalesce(cve_prodserv,''),coalesce(descripcion,''),precio_sin_impto,precio_sin_impto,cve_impto,
		tipo_factor,tasa_impto,monto_iva::decimal,coalesce(cve_catprodserv,''),monto_base_impto);

	resultado := 1;
	mensaje := '';
	adicionales := '';
	return query select resultado, mensaje, adicionales;
		
exception
	when others then
		resultado := 0;
		mensaje := 'cfd_concept_anticipo() ' || '['|| sqlstate || '] ' || sqlerrm;
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
end;
$function$
