CREATE OR REPLACE FUNCTION keplersc.validar_paquete(dataxml xml)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
declare 
	--Variables de definicion de documento
	criterio text = '';
	strValor text='';

	--Variables de proceso
	mensajeError text = '';
	recMst record;
	recDet record;
	marca text;
	modelo text;
	paquete text;
	ref_paquete text = '';
	total_refacciones numeric = 0;
	horas_mo_paquete numeric = 0;
	factor_minimo_mo numeric=0;
	horas_minimo numeric = 0;
	precio_paq_siva numeric = 0;
	iva numeric =16;	

   --Variables de retorno
	resultado text = '0';
	mensaje text = '0';
    adicionales text = '';

begin
	select valor into strValor from keplersc.param_oper p 
	where upper(parametro) = upper('validar paquete en citas');
	if not found then 
		mensajeError := 'No se encontro el Parametro de validar paquete en citas en Tabla PARAM_OPER ... ';
		raise exception '%', mensajeError;
	end if;

	if strValor='N' then
		resultado := 1;
		mensajeError := 'Validacion excluida';
		raise exception '%', mensajeError;	
	end if;

	--factor minimo mo
	select valor into strValor from keplersc.param_oper p 
	where upper(parametro) = upper(trim('minimo horas mano obra'));
	if not found then 
		mensajeError := 'No se encontro el Parametro minimo horas mano obra en Tabla PARAM_OPER ... ';
		raise exception '%', mensajeError;		
	end if;
	factor_minimo_mo = strValor::numeric;


	marca:=coalesce((xpath('//document/marca/text()', dataxml))[1],'');
	modelo:=coalesce((xpath('//document/modelo/text()', dataxml))[1],'');
	paquete:=coalesce((xpath('//document/paquete/text()', dataxml))[1],'');
	ref_paquete=marca || '-' || modelo || '-' || paquete ;

	select * into recMst from keplersc.kdspaq where c1=marca and c2=modelo and c4=paquete;
	if not found then
		raise exception 'El paquete: % no se encontro',ref_paquete;
	end if;

	select * into recDet from keplersc.kdspaqm where c1=marca and c2=modelo and c4=paquete;
	if not found then
		raise exception 'El detalle de refacciones del paquete:  % no se encontro',ref_paquete;
	end if;

	

	--Validar precio de paquete
	if recMst.c10 <= 0 then --Precio con IVA
		raise exception 'El Precio del paquete % no es valido (%)', ref_paquete, recMst.c10;
	end if;
	precio_paq_siva = recMst.c10 /  (1 + (iva/100));

	-- Valida Precio MO minimo vs Precio MO paquete
	if recMst.c6 < (recMst.c9 * factor_minimo_mo) then --Hrs paquete * factor menor a precio de la mo en paquete
		raise exception 'El Precio de la MO del paquete % es menor al minimo (% , %)', ref_paquete, recMst.c9 * factor_minimo_mo, recMst.c6;
	end if;

	-- Refacciones no puede ser mayor a total paquete
	if recMst.c7 > precio_paq_siva then 
		raise exception 'El Total de refacciones % es mayor al precio del paquete %', recMst.c7, recMst.c10;
	end if;

	-- MO no puede ser mayor a total paquete
	if recMst.c6 > precio_paq_siva then 
		raise exception 'El Total de la MO % es mayor al precio del paquete %', recMst.c6, recMst.c10;
	end if;

	-- MO + Refacciones no puede ser mayor a total paquete
	if precio_paq_siva - recMst.c6 <= 0 then 
		raise exception 'La MO % es negativa', precio_paq_siva - recMst.c6;
	end if;	

	resultado := 1;
	mensaje := 'Paquete valido';
	adicionales := '';
	return query select resultado, mensaje, adicionales;	

exception
	when others then
--		resultado := 0; --No calcular este valor, ya que se determina en la funcion
		mensaje := sqlerrm;
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
end;
$function$
