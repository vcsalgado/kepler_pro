CREATE OR REPLACE FUNCTION keplersc.verify_es_factura_sustituible(sucursal_id text, genero text, naturaleza text, grupo text, tipo text, factura text)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
--Descripcion: Valida si una factura de auto se puede sustitur por otra, 
--Autor: Victor Salgado
--Fecha: 24/02/2025
--Bitacora de cambios
declare 
	reckdm1 record;
	totreg int;	
	estatus_movto_base text;

	--Variables de retorno
	resultado text ='0';
	mensaje text ='';
	adicionales text ='';

begin
	select count(*) into totreg from keplersc.kdm1
	where c1=sucursal_id and c2=genero and c3=naturaleza and c4 =grupo::integer and c5=tipo::integer and c6=factura;
	if totreg=0 then
		raise exception 'No se encontro registro';
	end if;

	select coalesce(m1.c43,'') as estatus_1, coalesce(motivo_cancelacion,'') as motivo_cancelacion into recKdm1 from keplersc.kdm1 m1
	where m1.c1=sucursal_id and m1.c2=genero and m1.c3=naturaleza and m1.c4 =grupo::integer and m1.c5=tipo::integer and m1.c6=factura;	
	estatus_movto_base:=recKdm1.estatus_1;
	if recKdm1.estatus_1 = 'C' then
		raise exception 'Factura cancelada';
		
	end if;


	select count(*) into totReg from keplersc.kdm1 m1
	where m1.c1=sucursal_id and m1.c2=genero and m1.c36=naturaleza and m1.c37 =grupo::integer and m1.c38=tipo::integer and m1.c39=factura
	and m1.c1='01' and m1.c2='U' and m1.c3='A' and m1.c4 in (60,70);	
	if totreg > 0 then
		select m1.c6 as folio_cancelacion into recKdm1 from keplersc.kdm1 m1
		where m1.c1=sucursal_id and m1.c2=genero and m1.c36=naturaleza and m1.c37 =grupo::integer and m1.c38=tipo::integer and m1.c39=factura
		and m1.c1='01' and m1.c2='U' and m1.c3='A' and m1.c4 in (60,70);
		if recKdm1.folio_cancelacion <> '' then
			raise exception 'Factura cancelada por: %',recKdm1.folio_cancelacion;
		end if;
	end if;


	select count(*) into totReg from keplersc.kdm1 m1
	where m1.c1=sucursal_id and m1.c2=genero and m1.c36=naturaleza and m1.c37 =grupo::integer and m1.c38=tipo::integer and m1.c39=factura
	and m1.tipo_relacion='04';	
	if totreg > 0 then
		select m1.c6 as folio_sustituto into recKdm1 from keplersc.kdm1 m1
		where m1.c1=sucursal_id and m1.c2=genero and m1.c36=naturaleza and m1.c37 =grupo::integer and m1.c38=tipo::integer and m1.c39=factura
		and m1.tipo_relacion='04';
		raise exception 'Factura sustituida por: %',recKdm1.folio_sustituto;
	end if;

	select count(*) into totReg from keplersc.kdm1 m1
	where m1.c1=sucursal_id and m1.c2=genero and m1.c3=naturaleza and m1.c4 =grupo::integer and m1.c5=tipo::integer and m1.c6=factura
	and m1.tipo_relacion='04';	
	if totreg > 0 then
		select m1.c36 as nat, m1.c37 as gpo, m1.c38 as tipo, m1.c39 as folio_sustituido into recKdm1 from keplersc.kdm1 m1
		where m1.c1=sucursal_id and m1.c2=genero and m1.c3=naturaleza and m1.c4=grupo::integer and m1.c5=tipo::integer and m1.c6=factura
		and m1.tipo_relacion='04';
		
		select coalesce(m1.c43,'') as estatus_1, coalesce(motivo_cancelacion,'') as motivo_cancelacion, m1.c6 as folio_sustituido into recKdm1 from keplersc.kdm1 m1
		where m1.c1=sucursal_id and m1.c2=genero and m1.c3=recKdm1.nat and m1.c4 =recKdm1.gpo::integer and m1.c5=recKdm1.tipo::integer and m1.c6=recKdm1.folio_sustituido;	
		if recKdm1.estatus_1 <> 'C' then
			raise exception 'Factura con cancelacion de sustitucion pendiente: %',recKdm1.folio_sustituido;
		end if;

	end if;

/*
	select m1.c43 as estatus_1, coalesce(m1a.c43,'NULL') as estatus_1a, coalesce(m1b.c43,'NULL') as estatus_1b, 
	m1a.c6 as folio_sustituto, m1b.c6 as folio_sustituido,
	coalesce(m1a.tipo_relacion,'') as tipo_relacion, coalesce(m1a.c2||m1a.c3||m1a.c4,'') as movto_m1a
	into recKdm1 from keplersc.kdm1 m1
	left outer join keplersc.kdm1 m1a on m1a.c1=m1.c1 and m1a.c2=m1.c2 and m1a.c36=m1.c3 and m1a.c37=m1.c4 and m1a.c38=m1.c5 and m1a.c39=m1.c6
	left outer join keplersc.kdm1 m1b on m1b.c1=m1.c1 and m1b.c2=m1.c2 and m1b.c3=m1.c36 and m1b.c4=m1.c37 and m1b.c5=m1.c38 and m1b.c6=m1.c39
	where m1.c1=sucursal_id and m1.c2=genero and m1.c3=naturaleza and m1.c4 =grupo::integer and m1.c5=tipo::integer and m1.c6=factura;
raise notice 'factura:% folio_sustituto:% folio_sustituido:%',factura ,recKdm1.folio_sustituto,recKdm1.folio_sustituido;

	if recKdm1.estatus_1 = 'C' then
		raise exception 'Factura cancelada';
	end if;

	if recKdm1.tipo_relacion = '04' then
		raise exception 'Factura sustituida por: %',recKdm1.folio_sustituto;
	end if;
	
	if recKdm1.movto_m1a = 'UA60' or recKdm1.movto_m1a = 'UA70' then
		raise exception 'Factura cancelada por: %',recKdm1.folio_sustituto;
	end if;
*/


	resultado:='1';
	mensaje:='Sustituible';
	adicionales:= 'Sustituible';
	--Retorno tipo tabla
	return query select resultado, mensaje, adicionales;

EXCEPTION
	WHEN others then
		--Retorno tipo tabla
		resultado := '0';
		mensaje := sqlerrm;
		adicionales:= sqlerrm;
		return query select resultado, mensaje, adicionales;
end;
$function$
