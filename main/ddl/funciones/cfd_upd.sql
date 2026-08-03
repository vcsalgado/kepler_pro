CREATE OR REPLACE FUNCTION keplersc.cfd_upd(dataxml xml)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
--Descripcion: Guarda datos del CFDI del cliente 
--Autor: Luis Leal
--Fecha: 08/05/2023
--Bitacora de cambios
--17/02/2025 Miriam Santana: Guardar los datos de tipo de relacion CFDI y gen, nat, gpo, tipo y folio relacionado

declare
	--Variables de definicion de documento
	sucursal_id text = '';
	clave_cli text = '';
    nombre text = '';
	calle text = '';
	colonia text = '';
    no_exterior text = '';
	no_interior text = '';
	poblacion text = '';
 	municipio text = '';
	estado text = '';
	pais text = '';
    cp text = '';
	rfc text = '';
 	email text = '';
	f_pago text = '';
	cuenta text = '';
    m_pago text = '';
	cfdi text = '';
	regfiscal text = '';
	crud text = '';
	tiporelacion text = '';				--MSS 17022025 Relacion CFDI
	foliorelacionado text = '';			--MSS 17022025 Relacion CFDI
	gen_folrel text = '';				--MSS 17022025 Relacion CFDI
	nat_folrel text = '';				--MSS 17022025 Relacion CFDI
	gpo_folrel text = '';				--MSS 17022025 Relacion CFDI
	tpo_folrel text = '';				--MSS 17022025 Relacion CFDI

   --Variables de retorno
	resultado text = '';
	mensaje text = '0';
    adicionales text = '';
	
begin 
	crud:=dataxml::text;
	crud:=replace(crud,'\&quot;','"');

	dataxml:=crud::xml;

	sucursal_id := (xpath('//document/k_sucn/text()', dataxml))[1];    
	clave_cli := coalesce((xpath('//document/k_clave/text()', dataxml))[1],'');
   	nombre := coalesce((xpath('//document/k_nombre/text()', dataxml))[1],'');
	calle := coalesce((xpath('//document/k_calle/text()', dataxml))[1],'');
	colonia := coalesce((xpath('//document/k_colonia/text()', dataxml))[1],'');
	no_exterior := coalesce((xpath('//document/k_no_exterior/text()', dataxml))[1],'');
	no_interior := coalesce((xpath('//document/k_no_interior/text()', dataxml))[1],'');
	poblacion := coalesce((xpath('//document/k_poblacion/text()', dataxml))[1],'');
	municipio := coalesce((xpath('//document/k_municipio/text()', dataxml))[1],'');
	estado := coalesce((xpath('//document/k_estado/text()', dataxml))[1],'');
	pais := coalesce((xpath('//document/k_pais/text()', dataxml))[1],'');
	cp := coalesce((xpath('//document/k_cp/text()', dataxml))[1],'');
	rfc := coalesce((xpath('//document/k_rfc/text()', dataxml))[1],'');
	email := coalesce((xpath('//document/k_email/text()', dataxml))[1],'');
	f_pago := coalesce((xpath('//document/k_f_pago/r1/text()', dataxml))[1],'');
	cuenta := coalesce((xpath('//document/k_cuenta/text()', dataxml))[1],'');
	m_pago := coalesce((xpath('//document/k_m_pago/text()', dataxml))[1],'');
	cfdi := coalesce((xpath('//document/k_cfdi/r1/text()', dataxml))[1],'');
	regfiscal := coalesce((xpath('//document/k_regfiscal/r1/text()', dataxml))[1],'');

	tiporelacion := coalesce((xpath('//document/k_tiporelacion/r1/text()', dataxml))[1],'');		--MSS 17022025 Relacion CFDI
	gen_folrel := coalesce((xpath('//document/gen_folrel/text()', dataxml))[1],'');					--MSS 17022025 Relacion CFDI
	nat_folrel := coalesce((xpath('//document/nat_folrel/text()', dataxml))[1],'');					--MSS 17022025 Relacion CFDI
	gpo_folrel := coalesce((xpath('//document/gpo_folrel/text()', dataxml))[1],'0');				--MSS 17022025 Relacion CFDI
	tpo_folrel := coalesce((xpath('//document/tpo_folrel/text()', dataxml))[1],'0');				--MSS 17022025 Relacion CFDI
	foliorelacionado := coalesce((xpath('//document/k_folio_rel/text()', dataxml))[1],'');			--MSS 17022025 Relacion CFDI

	if nombre = '' then
		raise exception 'Falta Nombre por llenar';
	end if;

	if calle = '' then
		raise exception 'Falta Calle por llenar';
	end if;

	if colonia = '' then
		raise exception 'Falta Colonia por llenar';
	end if;

	if municipio = '' then
		raise exception 'Falta Municipio por llenar';
	end if;

	if estado = '' then
		raise exception 'Falta Estado por llenar';
	end if;

	if cp = '' then
		raise exception 'Falta CP por llenar';
	end if;
		
	if rfc = '' then
		raise exception 'Falta RFC por llenar';
	end if;

	if f_pago = '' then
		raise exception 'Falta Forma de pago por llenar';
	end if;

	if cuenta = '' then
		raise exception 'Falta Cuenta por llenar';
	end if;
		
	if m_pago = '' then
		raise exception 'Falta Metodo de pago por llenar';
	end if;
		
	if cfdi = '' then
		raise exception 'Falta Uso de cfdi por llenar';
	end if;

	if regfiscal = '' then
		raise exception 'Falta Regimen Fiscal por llenar';
	end if;
		
	--MSS 24/09/2024 Escapar & y '
	nombre:=regexp_replace(nombre,'&AMP;','&','gi');
	nombre:=regexp_replace(nombre,'\\''','''','gi');
	rfc := regexp_replace(rfc,'&AMP;','&','gi');							--MSS 20/06/2025 Escapar &

	delete from keplersc.kdudcfd where c1=clave_cli;

	--MSS 17022025 Relacion CFDI, insertar tipo_relacion,folio_relacionado
	insert into keplersc.kdudcfd  
		(c1, c2, c3, c4, c5, 
		c6, c7, c8, c9, c10, 
		c11, c12, c13, c14, c20, 
		c21, c22, c23, c24, tipo_relacion,
		genero_doctorel, naturaleza_doctorel, grupo_doctorel, tipo_doctorel, folio_relacionado) 
	values(clave_cli, nombre, calle, colonia, no_exterior, 
		no_interior, municipio, estado, pais, cp, 
		rfc, email, sucursal_id, poblacion, f_pago, 
		m_pago, cuenta, cfdi, regfiscal, tiporelacion,
		gen_folrel, nat_folrel, gpo_folrel::integer, tpo_folrel::integer, foliorelacionado);

	
	resultado := 1;
	mensaje := 'Registro del cliente: ' || clave_cli || ' actualizado';
	adicionales := '';
	return query select resultado, mensaje, adicionales;	

exception
	when others then
		resultado := 0;
		mensaje := 'cfd_upd() ' || '['|| sqlstate || '] ' || sqlerrm ;		
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
	
end;
$function$
