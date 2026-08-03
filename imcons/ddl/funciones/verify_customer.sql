CREATE OR REPLACE FUNCTION keplersc.verify_customer(dataxml xml)
 RETURNS TABLE(resultado text)
 LANGUAGE plpgsql
AS $function$
--Descripcion: verify_customer
--Autor: Luis Leal
--Fecha: 13/12/2021
--Bitacora de cambios
declare
	--Variables de definicion de documento
	sucursal_id text;
	genero text;
	naturaleza text;
	grupo text;
	tipo text;

	clave_cteprov text;
	rfc text;
	solicitar_rfc_cp text;
	codigo_postal text;
	resultado_cliente text;
	
	resultado text;

begin
	resultado = '0';
	
	--Documento
	sucursal_id := (xpath('//document/k_sucn/r1/text()', dataxml))[1];
	genero := (xpath('//document/k_tipon/r1/text()', dataxml))[1];
	naturaleza := (xpath('//document/k_tipon/r2/text()', dataxml))[1];
	grupo := (xpath('//document/k_tipon/r3/text()', dataxml))[1];
	tipo := (xpath('//document/k_tipon/r4/text()', dataxml))[1];

	clave_cteprov := coalesce((xpath('//document/k_clave/text()', dataxml))[1]::text,'0')::text;

	--SUB VERIFY_CFDI
	if genero = 'X' then
	
		select c10,c27,c28 into rfc,codigo_postal,solicitar_rfc_cp from keplersc.kdxd where c2 = clave_cteprov;
		if not found then
			raise exception 'Proveedor Invalido';
		end if;
	
		if solicitar_rfc_cp <> 'N' then
		
			if length(rfc) < 12 or length(rfc) > 15/*13*/ then 
				raise exception 'RFC invalido, por favor solicite que modifiquen el catalogo';
			end if;
			
			if length(codigo_postal) <> 5 then 
				raise exception 'Codigo Postal invalido, por favor solicite que modifiquen el catalogo';
			end if;
		
		end if ;
	
	end if ;

	if genero = 'U' then
	
		select * into resultado_cliente from keplersc.kdud where c2 = clave_cteprov;
		if not found then
			raise exception 'Cliente Invalido';
		end if;
	
	end if;


	
	resultado ='1';

	return query select resultado;	
			

end;
$function$
