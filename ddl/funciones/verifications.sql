CREATE OR REPLACE FUNCTION keplersc.verifications(dataxml xml, xmlkdmm xml)
 RETURNS TABLE(resultado_verificar text)
 LANGUAGE plpgsql
AS $function$
--Descripcion: verifications
--Autor: Luis Leal
--Fecha: 13/12/2021
--Bitacora de cambios
--Miriam Santana: Agregue la ejecución de la funcion verify_credit,verify_facturacion_orden,verify_orden_alta,verify_bonificacion y verify_year
--Fecha: 12/03/2024
---- By JMM : Se adapto que para un DOC TRANSFER No se Valide el Proveedor porque No existe en el Encabezado 
declare
    fecha text;
    dia text ='';
    mes text ='';
    anio text ='';
    mensaje text;
    operacion_desc text  ='';
   
   	--Added by JMM 20240312
   flag_gastos text = '';
  
    resultado_verificar text;
begin
	operacion_desc := coalesce((xpath('//document/operacion/text()', dataxml))[1],'');
	if upper(operacion_desc) = upper('baja') then
		if xpath_exists('//document/movimiento/fecha/text()', dataxml) = true then 
			fecha := coalesce((xpath('//document/movimiento/fecha/text()', dataxml))[1]::text,'1800-01-01 00:00:00')::text;
			if extract(year from fecha::date) = 1800 then
				fecha := current_date::text;
			end if;
		else
			fecha := current_date::text;
		end if;
	else
    	fecha := (xpath('//document/k_fecha/text()',dataxml))[1];
	end if;

    select split_part(fecha,'-', 3) into dia;
    select split_part(fecha,'-', 2) into mes;
    select split_part(fecha,'-', 1) into anio;
    fecha := concat(dia,'/',mes,'/',anio);
    
    resultado_verificar = '1';
    select * into resultado_verificar, mensaje from keplersc.verify_year(fecha);
    if resultado_verificar = '0' then
        raise exception '%',mensaje;
    end if;
    
    resultado_verificar = '0';        --MSS Se pone aqui xq en verify_year la excepcion tiene 0

    --Condition of CALL Added by JMM 20240312 
    flag_gastos = '';
	if xpath_exists('//document/ambiente/schema/text()', dataxml) = true /*false*/ then 
		flag_gastos := coalesce((xpath('//document/ambiente/schema/text()',dataxml))[1]::text,'')::text;
		if upper(flag_gastos) = 'CXP_TRANSFER' then
			-- NO HACER VALIDACION 
		else
			-- Original Code ... Marked Up by JMM 20240312
			select resultado into resultado_verificar from keplersc.verify_customer(dataxml);
		
		end if;
	end if;
    
   
    --verifica cfdi
    select resultado into resultado_verificar from keplersc.verify_cfdi(dataxml, xmlKDMM);

    select resultado into resultado_verificar from keplersc.verify_credit(dataxml, xmlKDMM);
    
    select resultado into resultado_verificar from keplersc.verify_facturacion_orden(dataxml, xmlKDMM);
       
    select resultado into resultado_verificar from keplersc.verify_orden_alta(dataxml, xmlKDMM);
    
    select resultado into resultado_verificar from keplersc.verify_bonificacion(dataxml, xmlKDMM);
    return query select resultado_verificar;    

end;
$function$
