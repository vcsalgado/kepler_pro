CREATE OR REPLACE FUNCTION keplersc.reg_ult_movto_cte(dataxml xml, xmlkdmm xml)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
declare
--Descripcion: Registra ultimo movimiento del cliente en KDUD
--Autor: Miriam Santana
--Fecha: 30/09/2022

	--Variables de definicion de documento
	sucursal_id text;
	genero text;
	naturaleza text;
	grupo text;
	tipo text;
	clave_cteprov text;
	forma_pago text;
	cuenta text;
	uen text;
	
	--Variables de retorno
	resultado text;
	mensaje text;
	adicionales text;

	--variables de uso general
	strValor text;
	intValor int;
	totalReg int;

begin
	--Valores de XML
	sucursal_id := (xpath('//document/k_sucn/r1/text()', dataxml))[1];
	genero := (xpath('//document/k_tipon/r1/text()', dataxml))[1];
	naturaleza := (xpath('//document/k_tipon/r2/text()', dataxml))[1];
	grupo := (xpath('//document/k_tipon/r3/text()', dataxml))[1];
	tipo := (xpath('//document/k_tipon/r4/text()', dataxml))[1];
	clave_cteprov := (xpath('//document/k_clave/text()', dataxml))[1];
	forma_pago := (xpath('//document/k_f_pago/r1/text()', dataxml))[1];
	cuenta := (xpath('//document/k_cuenta/text()', dataxml))[1];
		uen := coalesce((xpath('//document/ambiente/uen/text()',dataxml))[1],'');
	if genero = 'U' and naturaleza = 'D' then --Cuentas por cobrar, Deudora			
		update keplersc.kdud set c41=c40, c40=current_date
			where c2=clave_cteprov; 
	
	if (xpath('//row/c80/text()', xmlKDMM))[1]::text = 'S' and (uen ='REF' or uen ='VEN' ) then		--Genera CFD
			if forma_pago <> '02' or forma_pago <> '03' or forma_pago <> '04' or forma_pago <> '06' or forma_pago <> '28' or forma_pago <> '29' then
				cuenta:= coalesce(cuenta,'0');
			end if;
			update keplersc.kdud set c52=forma_pago, c53=cuenta
				where c2=clave_cteprov; 
		end if;
	end if;

	resultado := 1;
	mensaje := '';
	adicionales := '';
	return query select resultado, mensaje, adicionales;	

exception
	when others then
		resultado := 0;
		mensaje := 'reg_ult_movto_cte() ' || '['|| sqlstate || '] ' || sqlerrm;
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
	
end;
$function$
