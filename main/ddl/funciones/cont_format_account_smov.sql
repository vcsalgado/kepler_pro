CREATE OR REPLACE FUNCTION keplersc.cont_format_account_smov(xmlkdm1 xml, xmlkdmm xml, folio_operacion text, varcontxml xml)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
declare
	--Esta funcion resuelve FORMAT_ACCOUNT_SMOV, genera la cuenta a partir de los campos
	--configurados en kdmm, excluyendo aquellos que se obtienen a partir de otras funciones
	--
	--Parametros de entrada en xml:xmlkdm1--> Datos del movimiento; xmlkdmm--> Registro e kdmm
	-- folio_operacion --> Folio asignado a la transacción
	--Parametros de salida tabla: campos resultado, mensaje y adicionales.
	--Author: Victor salgado
	--Fecha: 07/10/2021
	--Bitacora de cambios:
	--01/01/2023 Victor Salgado, se agrega evaluacion de cuenta para V's
	
	--Variables base para  varcontxml
    n5 text; --NUMERO DE CAMPO A CONCATENAR EN KDMM
    n6 text; --NUMERO DE CAMPO EN QUE SE ENCUENTRA LA CUENTA EN KDMM		

    --Variables kdmm
    campo_concatenar_kdmm text = ''; --n5
   	campo_cuenta_kdmm text = ''; --n6
   	int_concatenar_kdmm int = 0;
   	valor_concatenar text = '';
   	sucursal_id text = '';
   	inventario text = '';
   	clave_vehiculo text ='';
   	anio_modelo text = '';
   
   --Variables kdm1
    campo_kdm1 text = '';
   	valor_kdm1 text = '';
   	valor_kdm1_32 text = '';
   	desc_cuenta text = '';
   	desc_partida text = '';
    uen text = '';
   
   	--variables de uso general
   	expSql text = '';
  	strValor text = '';
  	strAnioContable text = '';
  	inventario_base text = '';
  	serie text = '';
  
	--Variables de retorno
	resultado text;
	mensaje text; --Se asigna el valor esperado de la cuenta
	adicionales text;

begin
	sucursal_id := (xpath('//row/c1/text()',xmlkdm1))[1]::text;
	n5:= (xpath('//varcont/n5/text()',varcontxml))[1]::text; --25,26,54,55...
	n6:= (xpath('//varcont/n6/text()',varcontxml))[1]::text; --19,20,21,23...
	
--	uen := left(folio_operacion,1);
	uen := (xpath('//row/c95/text()', xmlkdmm))[1]::text;		--MSS 17102024 Obtener la uen de la KDMM.c95
	valor_kdm1_32 := (xpath('//row/c32/text()',xmlkdm1))[1]::text;	--Descripcion cliente/proveedor
	desc_partida := left(valor_kdm1_32,40);
	
	inventario_base:= coalesce((xpath('//varcont/inventario/text()',varcontxml))[1],''); --19,20,21,23...
	if n5<>'0' then
		campo_concatenar_kdmm := (xpath('//row/c' ||n5|| '/text()',xmlkdmm))[1]::text; --10,11,45,100
	else
		campo_concatenar_kdmm = '0';
	end if;
	campo_cuenta_kdmm := (xpath('//row/c' ||n6|| '/text()',xmlkdmm))[1]::text; --
--raise notice 'campo_cuenta_kdmm : %',campo_cuenta_kdmm;
	if substring(campo_cuenta_kdmm,1,1) = 'V' and uen = 'V' then -- se toma valor de tabla KDIVCL, esto es para autos
		if inventario_base <> '' then
			inventario := inventario_base;
		else
			inventario := (xpath('//row/c100/text()',xmlkdm1))[1]::text;		
		end if;
		select c3, c15, c5 into clave_vehiculo, anio_modelo, serie from keplersc.KDINF where c1 = sucursal_id and c2 = inventario;
	
		if clave_vehiculo is not null and clave_vehiculo <> '-1'  then
			if substring(clave_vehiculo,1,2)='U-' then
				strAnioContable = substring ((select EXTRACT(year  FROM (select now()))::text),3,2);
			else
				strAnioContable=substring(anio_modelo,3,2);
			end if;
--raise exception 'sucursal_id: %; clave_vehiculo: %; strAnioContable: %',sucursal_id,clave_vehiculo,strAnioContable;		
			if (select count(*) from keplersc.KDIVCL where c1 = clave_vehiculo and c2 = strAnioContable and c3 =sucursal_id) > 0 then 
			expSql = format('SELECT %1$s from keplersc.KDIVCL where c1=%2$L and c2 =%3$L and c3 = %4$L',
				replace(campo_cuenta_kdmm,'V','c'),clave_vehiculo,strAnioContable,sucursal_id);					
				--raise notice 'sqldkivcl %',v_auxSql;
raise notice 'Exp sql %',expSql;
				execute expSql into strValor;
				campo_cuenta_kdmm=strValor;
			else
				resultado = 0;
				mensaje := 'No esta correctamente configurada la cuenta Contable para el vehiculo';
				raise exception 'No esta correctamente configurada la cuenta Contable para el vehiculo';	
			end if;
		else 
			raise exception 'Clave del vehículo inválida';
		end if;
	
		desc_cuenta:=serie;
		desc_partida := left(concat(desc_cuenta,'/',valor_kdm1_32),40); --Cuenta/Cliente
	
	end if;

	int_concatenar_kdmm := campo_concatenar_kdmm::int;

	if int_concatenar_kdmm = -1 then --Se utiliza para autos, concatena inventario, campo 100		
		if inventario_base <> '' then
			inventario=inventario_base;
			valor_concatenar := inventario_base;
		else
			inventario := (xpath('//row/c100/text()',xmlkdm1))[1]::text;
		    campo_concatenar_kdmm := 100;
			valor_concatenar = (xpath('//row/c' || campo_concatenar_kdmm ||'/text()',xmlkdm1))[1]::text;		
		end if;
		select c3, c15, c5 into clave_vehiculo, anio_modelo, serie from keplersc.KDINF where c1 = sucursal_id and c2 = inventario;	
		/* TEST Saltiel, JM*/ 	
		valor_concatenar :=(select substring(valor_concatenar,1,4)) || (select substring(valor_concatenar,8,1)) || '/' || 
								(right(valor_concatenar, length(valor_concatenar)-(length(valor_concatenar)-2)));
					
		campo_cuenta_kdmm = concat(campo_cuenta_kdmm,'-',valor_concatenar);
		desc_cuenta:=serie;
		--desc_cuenta = (xpath('//row/c133/text()',xmlkdm1))[1]::text; --Serie auto, se obtiene de kdinf	
		desc_partida := left(concat(desc_cuenta,'/',valor_kdm1_32),40); --Cuenta/Cliente
	
	end if;

	if int_concatenar_kdmm = 0 then --Nada que concatenar, cuenta en kdmm pero no en catalogo
		valor_concatenar = '' ;
		campo_cuenta_kdmm = campo_cuenta_kdmm;
		desc_cuenta = 'Cuenta Creada por el Sistema';
		if uen <> 'V' then 
			desc_partida := left(valor_kdm1_32,40); --Cuenta/Cliente
		end if;			
	end if;

	if int_concatenar_kdmm > 0 then --Se concatena el valor indicado en la columna.
		valor_concatenar = (xpath('//row/c' || campo_concatenar_kdmm ||'/text()',xmlkdm1))[1]::text;
		campo_cuenta_kdmm = concat(campo_cuenta_kdmm,'-',valor_concatenar);
		desc_cuenta = valor_kdm1_32;
		desc_partida := left(valor_kdm1_32,40); --Cuenta/Cliente		
	end if;

	adicionales := concat(campo_cuenta_kdmm,'|',desc_partida,'|',desc_cuenta);

	resultado := 1;
	mensaje := '';
	adicionales := adicionales;
	return query select resultado, mensaje, adicionales;	

--exception
--	when others then
--		resultado := 0;
--		mensaje := 'cont_format_account_smov() ' || '['|| sqlstate || '] ' || sqlerrm;
--		adicionales := '';
--		return query select resultado, mensaje, adicionales;	
end;
$function$
