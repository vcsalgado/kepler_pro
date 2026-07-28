CREATE OR REPLACE FUNCTION keplersc.cfd_header_cliente(dataxml xml, xmlkdm1 xml, cons_cfdi integer)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
declare
--Descripcion: Genera informacion para CFDI. Resuelve CFD_HEADER_CLIENTE 
--Autor: Miriam Santana
--Fecha: 30/09/2022
	--Variables para xml 
	sucursal_id text;
	genero text;
	naturaleza text;
	grupo text;
	tipo text;
	folio_operacion text;
	cve_cteprov text;

	--Variables cfdi
	rfc text;
	cp_sat text;
	correo text;
	nombre text;
	calle text;
	colonia text;
	poblacion text;
	num_ext text;
	num_int text;
	municipio text;
	estado text; 
	pais text;


	--Variables de retorno
	resultado text;
	mensaje text;
	adicionales text;
	
begin
	sucursal_id := (xpath('//document/k_sucn/r1/text()', dataxml))[1];
	genero := (xpath('//document/k_tipon/r1/text()', dataxml))[1];
	naturaleza := (xpath('//document/k_tipon/r2/text()', dataxml))[1];
	grupo := (xpath('//document/k_tipon/r3/text()', dataxml))[1];
	tipo := (xpath('//document/k_tipon/r4/text()', dataxml))[1];
	folio_operacion := (xpath('//row/c6/text()', xmlkdm1))[1];
	cve_cteprov := (xpath('//document/k_clave/text()', dataxml))[1];

	select c2,c3,c4,c14,c11,
		c12,c10,c5,c6,c7,
		c8,c9
		into nombre,calle,colonia,poblacion,rfc,
		correo,cp_sat,num_ext,num_int,municipio,
		estado,pais
		from keplersc.kdudcfd
		where c1 = cve_cteprov;
	if not found then
		raise exception 'No existe registro de valdación de información del cfdi';
	end if;

	--MSS 24/09/2024 Escapar & y '
	nombre:=regexp_replace(nombre,'&AMP;','&','gi');
	nombre:=regexp_replace(nombre,'\\''','''','gi');
	insert into keplersc.kdf3cliente (
		c1,c2,c3,c4,c5,
		c6,c7,c8,c9,c10,
		c11,c12,c13,c14,
		c15,c16,c17,c18,c19,c20)	
	values(
		sucursal_id,genero,naturaleza,grupo::integer,tipo::integer,
		folio_operacion,cons_cfdi,cve_cteprov,nombre,calle,
		colonia,poblacion,rfc,correo,cp_sat,
		num_ext,num_int,municipio,estado,pais);
	
	resultado := 1;
	mensaje := '';
	adicionales := '';
	return query select resultado, mensaje, adicionales;	

exception
	when others then
		resultado := 0;
		mensaje := 'cfd_header_cliente() ' || '['|| sqlstate || '] ' || sqlerrm;
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
end;
$function$
