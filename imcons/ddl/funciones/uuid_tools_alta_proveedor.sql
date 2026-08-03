CREATE OR REPLACE FUNCTION keplersc.uuid_tools_alta_proveedor(dataxml xml)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
declare
	--Esta funcion resuelve dar de Alta un Proveedor con datos obtenidos de un XML.DOC 
	--Obtenidos y Lanzados en un xml armado en K80   
	--Parametros de entrada en xml:
	-- dataXml--> Sucursal, Nombre Proveedor y RFC del Proveedor; 
	--Parametros de salida tabla: campos resultado, mensaje y adicionales.
	--Author: Jose Mendoza 
	--Fecha: 18/01/2024
	--Bitacora de cambios:
	--13/03/2025 VCSS Los proveedores no van por sucursal, se elimina condicion

	--Variables de uso general
	mensajeError text;
	expSql text;
	totalReg int;
	strValor text;
   
    campo text = '';
   
    suc text;
   	nomb text;
   	rfc text;
  
   	idmax int/*text*/;
   	idnew text;
   
    -- Added 20240130
   	plazo int; 
   	plazo_default text;
   	plazo_param text;
    
	--Variables de retorno
	resultado text;
	mensaje text; --Se asigna el valor esperado de la cuenta
	adicionales text;

begin
	
	--suc := (xpath('//document/k_sucn/r1/text()', dataxml))[1];
	
	suc := coalesce((xpath('//document/sucursal/text()', dataxml))[1]::text,'');
	nomb := coalesce((xpath('//document/nombre/text()', dataxml))[1]::text,'');
	rfc := coalesce((xpath('//document/rfc/text()', dataxml))[1]::text,'');

	suc := ''; --Los proveedores no van por sucursal VCSS 12/03/2025
	nomb := trim(nomb);
	rfc := trim(rfc);
	

	if length(nomb) = 0 or length(rfc) = 0 then 
		raise exception '%', 'No se tienen los datos mandatorios completos para registrar al Proveedor ...';
	end if;

	totalReg := -1;
	select count(*) into totalReg from keplersc.kdxd where keplersc.full_replace(c10,'-','')/*c10*/ = rfc;
	if totalReg <> 0 then
		raise exception '%', 'El R.F.C. ya existe, No se podra crear el Proveedor ' || '['|| rfc || '] ';	
	end if; 


	select max(right(c2,length(c2)-1))::int into idmax from keplersc.kdxd d;

	idmax := coalesce(idmax,0);

	idnew := 'D' || trim( lpad( ( idmax + 1 )::text ,6,'0') );

	
	
	plazo_param := 'Plazo Pago Proveedores';
	plazo_default := '15';
	plazo := 0;

	totalReg := -1;
	select count(*) into totalReg from keplersc.param_oper where parametro = plazo_param;
	if totalReg <= 0 or totalReg > 1 then
		if totalReg <= 0 then
			raise exception '%', 'No se encontro el Parametro Operativo  ' || '['|| plazo_param || '] ';
		else
			raise exception '%', 'Se encontro mas de un Registro para el Parametro Operativo  ' || '['|| plazo_param || '] ';
		end if;
	else
		select coalesce(valor, plazo_default) into strValor from keplersc.param_oper where parametro = plazo_param limit 1;
		plazo := strValor::int;
	end if; 


	insert into keplersc.kdxd(c1, c2, c3,c10, c16)
	select suc, idnew, nomb, rfc, plazo::text;	

	
	totalReg := -1;
	select count(*) into totalReg from keplersc.kdxd where keplersc.full_replace(c10,'-','')/*c10*/ = rfc;
	if totalReg <> 1 then
		raise exception '%', 'Se presentaron inconsistencias en la creacion del Proveedor ' || '[ '|| rfc || ' ] ';	
	end if; 

	totalReg := -1;
	select count(*) into totalReg from keplersc.kdxd where c2 = idnew;
	if totalReg <> 1 then
		raise exception '%', 'Se presentaron inconsistencias en la creacion del Proveedor ' || '[ '|| idnew || ' ] ';	
	end if; 


	resultado := 1;
	mensaje := idnew /*'Se creo el proveedor ' || '[ '|| idnew || ' ] '*/;
	adicionales := '';
	return query select resultado, mensaje, adicionales;	

exception
	when others then
		resultado := 0;
		mensaje := 'uuid_tools_alta_proveedor() ' || '['|| sqlstate || '] ' || sqlerrm;
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
end;
$function$
