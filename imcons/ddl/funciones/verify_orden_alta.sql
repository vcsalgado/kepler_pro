CREATE OR REPLACE FUNCTION keplersc.verify_orden_alta(dataxml xml, xmlkdmm xml)
 RETURNS TABLE(resultado text)
 LANGUAGE plpgsql
AS $function$
declare 
--Descripcion: Verifica si ya existe una factura o nota de crÃ©dito de una orden
--			   Resuelve VERIFY_ORDEN_ALTA
--Autor: Miriam Santana
--Fecha: 12/15/2022

	--Variables de definicion de documento
	sucursal_id text = '';
	genero text = '';
	naturaleza text = '';
	grupo text = '';
	tipo text = '';
	cve_usuario text = '';
	uen text ='';
	tipo_orden text;
	num_orden text;
	suc_inventario text;
	cve_inventario text;

	--varibales de uso general
	tipo_trabajo text;
	privilegios_conta text;
	flujo_admon int;

	totReg int;
	resultado text;

begin
	sucursal_id := (xpath('//document/k_sucn/r1/text()', dataxml))[1];
	genero := (xpath('//document/k_tipon/r1/text()', dataxml))[1];
	naturaleza := (xpath('//document/k_tipon/r2/text()', dataxml))[1];
	grupo := (xpath('//document/k_tipon/r3/text()', dataxml))[1];
	tipo := (xpath('//document/k_tipon/r4/text()', dataxml))[1];
	cve_usuario := (xpath('//document/movimiento/usuario/text()', dataxml))[1];	
	tipo_orden := (xpath('//document/k_tipo_orden/r1/text()',dataxml))[1];
	num_orden := (xpath('//document/k_orden/text()',dataxml))[1];
	uen := coalesce((xpath('//document/ambiente/uen/text()',dataxml))[1],'');
	suc_inventario := (xpath('//document/k_pedimento/text()',dataxml))[1];
	cve_inventario := (xpath('//document/k_claveinv/text()',dataxml))[1];
--raise notice 'VERIFY ORDEN';
	resultado = '0';
	if uen='SER' and genero='U' and (xpath('//row/c11/text()', xmlKDMM))[1]::text = 'S' then
		select c7 into flujo_admon from keplersc.kdord
			where c1=sucursal_id and c2=tipo_orden and c3=num_orden;
		if found then
			 if naturaleza='D' and flujo_admon <> 10 then
			 	raise exception 'Esta Orden ya tiene factura, No se puede elaborar otra';             
			 end if;
			if naturaleza='A' and flujo_admon < 20 then
			 	raise exception 'Esta Orden no tiene factura, No se puede elaborar NOTA DE CREDITO';             
			 end if;
			if (xpath('//row/c67/text()', xmlKDMM))[1]::text = 'A' or (xpath('//row/c67/text()', xmlKDMM))[1]::text = 'U' then 
				select count (*) into totReg from keplersc.kdinf where 
					c1=suc_inventario and c2=cve_inventario;
				if totReg=0 then
					raise exception 'No se encuentra el número de inventario, Imposible Continuar';
				end if;
			end if;	
		end if;    
	end if;

	resultado ='1';

	return query select resultado;	
				
end;
$function$
