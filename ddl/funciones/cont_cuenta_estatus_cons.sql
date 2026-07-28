CREATE OR REPLACE FUNCTION keplersc.cont_cuenta_estatus_cons(cuenta text, anio_cta text)
 RETURNS xml
 LANGUAGE plpgsql
AS $function$
declare
	--Descripcion: Consulta cuenta para saber su existencia, nivel y saldo
	--Autor: Victor Salgado
	--Fecha: 27 Jul 2023

	--Variables de retorno
	existe text;
	espadre text;
	ultimonivel text;
	saldoini numeric;
	saldoactual numeric;
	descripcion text;

	--variables de uso general
	intValor int = 0;
	expSql text = '';
	xmlResultados xml;
	strValor text = '';
begin
	--Cuenta existe
	select count(*) into intValor from keplersc.kdc1_view where anio=anio_cta and c1=cuenta;
	existe='N';
	descripcion='';
	if intValor > 0 then
		existe='S';
		select c2 into descripcion from keplersc.kdc1_view where anio=anio_cta and c1=cuenta;
	end if;
 

	--Primer nivel, resultado debe ser cero
	select count(*) into intValor from keplersc.kdc1_view where anio=anio_cta and position(c1 in cuenta)>0 
	and substring(cuenta,1,1) = substring(c1,1,1) and cuenta<>c1;
	espadre='N';
	if intValor = 0 then
		espadre='S';
	end if;
	
	--Ultimo nivel, resultado debe ser 0
	select count(*) into intValor from keplersc.kdc1_view where anio=anio_cta and position(cuenta in c1)>0 
	and substring(cuenta,1,1) = substring(c1,1,1) and cuenta<>c1;
	ultimonivel:='N';
	if intValor = 0 then
		ultimonivel='S';
	end if;
	strValor:=format('<resultado><existe>%1$s</existe><espadre>%2$s</espadre><ultimonivel>%3$s</ultimonivel><descripcion>%4$s</descripcion></resultado>',existe,espadre,ultimonivel,descripcion);
	xmlResultados:=strValor::xml;
	return xmlResultados;
--	return query_to_xml('select existe,espadre,ultimonivel',false,true,'');	

end;
$function$
