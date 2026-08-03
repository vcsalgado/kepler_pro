CREATE OR REPLACE FUNCTION keplersc.jmm_test_autos_contabilidad(dataxml xml, folio text)
 RETURNS TABLE(xmlresults xml, xmldata xml, xmlkdmm xml, xmlkdm1 xml)
 LANGUAGE plpgsql
AS $function$
declare

	--Variables de definicion de documento
	valor_get text = '';
	expSql text;
	sqlStr text;
	xmlResult xml;

	sucursal_id text;
	genero text;
	naturaleza text;
	grupo text;
	tipo text;
	folio_operacion text;

	--xml documento
	xmlKDMM xml;
	xmlKDM1 xml;
	
	--Variables de uso general 
	var_value decimal = 0.00;
	totReg int = 0;
	cadena_datos text = '';
   
	strValor text = '';
	intValor int = 0;
	intCont int = 0;
	xmlCadena xml;

	--Variables de retorno
	resultado text;
	mensaje text;
	adicionales text;

	get_resultado text; --retorno
	get_mensaje text; --retorno
	get_adicionales text; --retorno

begin
	
	--Function receiving XML of K80, to test accountant function (general) 4 Autos
	
	drop table if exists tmpResultados;
	create temp table tmpResultados (
		xml_results xml,	
		xml_data xml,
		xml_kdmm xml,
		xml_kdm1 xml
			
	);
	
	sucursal_id := (xpath('//document/k_sucn/r1/text()', dataxml))[1];
	genero := (xpath('//document/k_tipon/r1/text()', dataxml))[1];
	naturaleza := (xpath('//document/k_tipon/r2/text()', dataxml))[1];
	grupo := (xpath('//document/k_tipon/r3/text()', dataxml))[1];
	tipo := (xpath('//document/k_tipon/r4/text()', dataxml))[1];
	--folio_operacion := '0000117';
	
	/*
	sucursal_id := '01';
	genero := 'X';
	naturaleza := 'A';
	grupo := '6';
	tipo := '1';
	*/
	folio_operacion := folio;
	
	
	expSql = 'select * from keplersc.kdmm where c1='  || E'\'' || genero || E'\'' ||
		' and c2=' || E'\'' || naturaleza || E'\'' || ' and c3=' || grupo || ' and c4=' || tipo;	
	
	select query_to_xml(expSql, true, false, '') into xmlKDMM;

	strValor := (xpath('//row/c90/text()', xmlKDMM))[1];
	if strValor is not null then
		if strValor = 'S' then
			mensaje := 'Documento no valido ...';
			raise exception '%',mensaje;			
		end if;
	end if;
	

	--Obtener xml de KDM1 de registro generado 		
	expSql = 'select * from keplersc.kdm1 where' || 
		' c1=' || E'\'' || sucursal_id || E'\'' ||  
		' and c2=' || E'\'' || genero || E'\'' ||
		' and c3=' || E'\'' || naturaleza || E'\'' || 
		' and c4=' || grupo || 
		' and c5=' || tipo ||
		' and c6=' || E'\'' || folio_operacion || E'\'';

	select query_to_xml(expSql, true, false, '') into xmlKDM1;
	
	--raise 'kdm1 %', xmlKDM1::text;

	/*
	mensaje := 'Opcion en pruebas operativas ...';
	--cmnt(1).free4eg by JMM
	raise exception '%', mensaje;
	*/

	--/*
	--paso:= 'docdis.cont_general_alta';
	select * into get_resultado, get_mensaje, get_adicionales from keplersc.cont_general_alta(dataxml,xmlKDM1,xmlKDMM,folio_operacion);
	if get_resultado = '0' then
		raise exception '%',get_mensaje;
	end if;	
	--*/

	/*
	get_mensaje = 'Paso OK por la opcion [ cont_general_alta ] / JMM';
	raise exception '%',get_mensaje;
	*/


	--mensaje := 'Opcion en Construccion ...';
	resultado := 1;
	mensaje := 'Los datos se procesaron satisfactoriamente [Contabilidad] ...';
	adicionales := '';
	--return query select resultado, mensaje, adicionales;	

	sqlStr = format('select %1$L as resultado, %2$L as mensaje, %3$L as adicionales',resultado,mensaje,adicionales);
	select query_to_xml(sqlStr, true, false, '') into xmlResult;

	insert into tmpResultados(xml_results,xml_data,xml_kdmm,xml_kdm1) 
	values(xmlResult,dataxml,xmlKDMM,xmlKDM1);
	
	return query select * from tmpResultados;

exception
	when others then
		resultado := 0;
		mensaje := 'jmm_test_autos_contabilidad(); ' || '['|| sqlstate || '] ' || sqlerrm ;
		adicionales := '';
		--return query select resultado, mensaje, adicionales;
	
		drop table if exists tmpResultados;
		create temp table tmpResultados (
			xml_results xml,	
			xml_data xml,
			xml_kdmm xml,
			xml_kdm1 xml
			
		);
	
		sqlStr = format('select %1$L as resultado, %2$L as mensaje, %3$L as adicionales',resultado,mensaje,adicionales);
		select query_to_xml(sqlStr, true, false, '') into xmlResult;

		insert into tmpResultados(xml_results,xml_data,xml_kdmm,xml_kdm1) 
		values(xmlResult,dataxml,xmlKDMM,xmlKDM1);
	
		return query select * from tmpResultados;

end;
$function$
