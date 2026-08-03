CREATE OR REPLACE FUNCTION keplersc.verify_credit(dataxml xml, xmlkdmm xml)
 RETURNS TABLE(resultado text)
 LANGUAGE plpgsql
AS $function$
declare 
--Descripcion: Realiza validacion para no sobrepasar el límite de crédito del cliente
--Autor: Miriam Santana
--Fecha: 28/09/2022

	--Variables de definicion de documento
	sucursal_id text = '';
	genero text = '';
	naturaleza text = '';
	grupo text = '';
	tipo text = '';
	cve_cteprov text = '';
	cve_usuario text = '';
	var_sr text ='';
	uen text ='';
		
	--Variables de uso general
 	strValor text = '';
 	totReg	int;
 	str_usuario text;
	p_adm	text;
	p_cont text;
	p_cart text;
	monto_credito decimal;
	saldo decimal;
 	
	--Variables de retorno
	resultado text;

begin 
	
	sucursal_id := (xpath('//document/k_sucn/r1/text()', dataxml))[1];
	genero := (xpath('//document/k_tipon/r1/text()', dataxml))[1];
	naturaleza := (xpath('//document/k_tipon/r2/text()', dataxml))[1];
	grupo := (xpath('//document/k_tipon/r3/text()', dataxml))[1];
	tipo := (xpath('//document/k_tipon/r4/text()', dataxml))[1];
	cve_cteprov := (xpath('//document/k_clave/text()', dataxml))[1];
	cve_usuario := (xpath('//document/movimiento/usuario/text()', dataxml))[1];	
	var_sr := (xpath('//document/k_var_sr/text()', dataxml))[1];	
	uen := coalesce((xpath('//document/ambiente/uen/text()',dataxml))[1],'');
--raise notice 'VERIFY CREDIT';
	resultado = '0';
	if (uen='SER' or uen='REF') and (xpath('//row/c7/text()', xmlKDMM))[1]::text = 'S' and var_sr ='SR' and genero = 'U' then
		select c1,c5,c6,c17 into str_usuario, p_adm, p_cont, p_cart from keplersc.kdusrinfo k 	
				where c1=cve_usuario;
		strValor = coalesce((xpath('//row/c92/text()', xmlKDMM))[1]::text,'');
		if found then
			if (strValor<>'S' or (strValor='S' and (p_adm='S' or p_cont='S' or p_cart='S'))) then
				select c15 into monto_credito from keplersc.kdud
					where c2=cve_cteprov;			--VERIFICANDO QUE EL CLIENTE TENGA CREDITO
				if found then
					if (naturaleza = 'D') then
						select sum(c6)-sum(c7) into saldo from keplersc.kduxg
							where c1=sucursal_id AND c2=genero AND c3=cve_cteprov;		--OBTENER SALDO
						if (saldo>=monto_credito) then
							raise exception 'El cliente sobrepasa su límite de crédito';	
						end if;
					end if;
				else
					raise exception 'El cliente no se encuentra, imposible continuar con la operación';
				end if;
			else
				raise exception 'El usuario no tiene privilegios para hacer movimientos que generen cartera';
			end if;
		end if;
	end if;

	resultado ='1';

	return query select resultado;	
			
	
end;
$function$
