CREATE OR REPLACE FUNCTION keplersc.ser_fact_orden_sel(dataxml xml)
 RETURNS TABLE(encabezado xml)
 LANGUAGE plpgsql
AS $function$
declare
--Descripcion: Obtiene en formato XML el detalle de una orden para facturar
--Autor: Miriam Santana
--Fecha: 26/Sep/22
--Bitacora de cambios

	--Variables de definicion de documento
	sucursal_id text = '';
	tipo_orden text = '';
	num_orden text = '';
	
	--Variables de uso general 
	strValor text = '||';
	espacio text = ' ';
	vacio text = '';
	srtcero text = '0';
	
	--xmlReqDoctos text = '';
	expSql text = '';

	--Variables de retorno
	xmlEncabezado xml;

begin	
	sucursal_id := (xpath('//document/sucursal_id/text()', dataxml))[1];
	tipo_orden := (xpath('//document/tipo_orden/text()', dataxml))[1];
	num_orden := (xpath('//document/num_orden/text()', dataxml))[1];
	
	drop table if exists tmpResultados;
	create temp table tmpResultados (
		encabezado xml
	);
	expSql= format('select ord.c22 as k_vendedor, rec.c2 as k_nombre_recep, ord.c2%4$s%5$L%4$sord.c3 as k_refer, 
			ord.c10 as k_clave, ord.c30 as k_montoext1,ord.c31 as k_montoext2, ord.c32 as k_montoext3, 
			ord.c33 as k_montoext4, cte.c3 as k_nombreprov, cte.c4 as k_calleprov, cte.c5 as k_coloniaprov, 
			cte.c6 as k_poblacionprov, cte.c27 as k_cpprov, cte.c10 as k_rfc, cte.c11 as k_correo, 
			case when cte.c16 is null then %7$L when cte.c16=%6$L then %7$L else cte.c16 end k_plazo, cte.c30 as k_nombreimprfact,		
			''[''||cfd.c1||''] ''||cfd.c2 as k_cfdi, ord.c61 as k_subtotal, ord.c62 as k_iva, ord.c63 as k_monto
			from keplersc.kdord ord
			inner join keplersc.kdud cte on cte.c2=ord.c10
			left join keplersc.kdrecep rec on rec.c1=ord.c22
			left join keplersc.kdf3uso cfd on cfd.c1=cte.c53
			where ord.c1=%1$L and ord.c2=%2$L and ord.c3=%3$L'
		,sucursal_id,tipo_orden,num_orden,strValor,espacio,vacio,srtcero);	

raise notice '%' , expSql;

select query_to_xml(expSql,false,true,'') into xmlEncabezado;

insert into tmpResultados(encabezado) 
	values(xmlEncabezado);

return query select * from tmpResultados;

END;
$function$
