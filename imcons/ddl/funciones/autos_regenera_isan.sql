CREATE OR REPLACE FUNCTION keplersc.autos_regenera_isan(dataxml xml)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
declare
	--Variables de definicion de documento
	sucursal_id text = '';
	fecha_ini date;
	fecha_fin date;

	--Variables de uso general 
	totUpd int =0;
	totUpdVentas int =0;
	totUpdComis int =0;
	totUpdMovtos int =0;
	totUpdPedido int =0;
	strValor text = '';
	intValor int = 0;
	rec_V_IV record;
	rec_C_VENTAS record;
	b7012_importe numeric = 0.00;
	b7013_iva int=0;
	b7014_importe numeric = 0.00;
	b7015_tipooper int=0;
	inventario text ='';
	resultado_isan text;
	mensaje_isan text;
	adicionales_isan text;
	isan numeric = 0.00;
	iva numeric = 0.00;

	--Variables de retorno
	resultado text;
	mensaje text;
	adicionales text;
begin
	sucursal_id:=(xpath('//document/sucursal_id/text()', dataxml))[1];
	strValor:=(xpath('//document/fecha_ini/text()', dataxml))[1];
	fecha_ini:=to_date(strValor,'yyyy-mm-dd');
	strValor:=(xpath('//document/fecha_fin/text()', dataxml))[1];
	fecha_fin:=to_date(strValor,'yyyy-mm-dd');

	for rec_V_IV in select * from keplersc.kdiv 
	loop
		for rec_C_VENTAS in select * from keplersc.kdventas where c1=sucursal_id and 
			c14=rec_V_IV.c1 and c9>=fecha_ini and c9<=fecha_fin
		loop 
			b7012_importe:=rec_C_VENTAS.c26;
			b7013_iva:=16;
			b7014_importe:=rec_C_VENTAS.c26;
			if rec_C_VENTAS.c17<>'TRAS' then

				b7015_tipooper:=1;
			else
				b7015_tipooper:=0;
			end if;
			inventario:=rec_C_VENTAS.c2;
raise notice 'Modelo:% Tipo Oper:% Inventario:%, Importe:%',rec_V_IV.c1,rec_C_VENTAS.c17,inventario,rec_C_VENTAS.c26;		
			strValor:='<document>';
			strValor:=concat(strValor,'<k_sucn><r1>',sucursal_id,'</r1></k_sucn>');
			strValor:=concat(strValor,'<k_inventario>',inventario,'</k_inventario>');
			strValor:=concat(strValor,'<k_tipon><r1>','','</r1></k_tipon>');
			strValor:=concat(strValor,'<k_tipon><r2>','','</r2></k_tipon>');
			strValor:=concat(strValor,'<k_tipon><r3>','','</r3></k_tipon>');
			strValor:=concat(strValor,'<k_tipon><r4>','','</r4></k_tipon>');
			strValor:=concat(strValor,'<k_b7012>',b7012_importe,'</k_b7012>');
			strValor:=concat(strValor,'<k_b7014>',b7014_importe,'</k_b7014>');
			strValor:=concat(strValor,'<k_b7015>',b7015_tipooper,'</k_b7015>');		
			strValor:=concat(strValor,'</document>');
			select i.resultado, i.mensaje, i.adicionales into resultado_isan, mensaje_isan, adicionales_isan 
			from keplersc.invlib_sumas_inv(strValor::xml) as i;
			if resultado_isan='1' then
				isan:=mensaje_isan::numeric(15,2);
				iva:=adicionales_isan::numeric(15,2);
			else
				raise exception '%',mensaje_isan;
			end if;
		
			--Actualizacion de kdventas
			update keplersc.kdventas set c24=isan, c25=iva where c1=rec_C_VENTAS.c1 and c2=rec_C_VENTAS.c2
			and c3=rec_C_VENTAS.c3 and c4=rec_C_VENTAS.c4 and c5=rec_C_VENTAS.c5 and c6=rec_C_VENTAS.c6 
			and c7=rec_C_VENTAS.c7 and c8=rec_C_VENTAS.c8 and c14=rec_C_VENTAS.c14;
			get diagnostics totUpd = ROW_COUNT;
			totUpdVentas:=totUpdVentas+totUpd;
		
			--Ataulizacion de kdm1
			update keplersc.kdm1 set c14=iva, c15=isan where c1=rec_C_VENTAS.c1 and c2=rec_C_VENTAS.c4
			and c3=rec_C_VENTAS.c5 and c4=rec_C_VENTAS.c6 and c5=rec_C_VENTAS.c7 and c6=rec_C_VENTAS.c8;
			get diagnostics totUpd = ROW_COUNT;
			totUpdMovtos:=totUpdMovtos+totUpd;		
			
			--Actualizacion de kdcomismov
			update keplersc.kdcomismov set c20=isan ,c21=iva, c22=b7012_importe 
				where c1=rec_C_VENTAS.c1 and c8=rec_C_VENTAS.c2;
			get diagnostics totUpd = ROW_COUNT;
			totUpdComis:=totUpdComis+totUpd;		
		
			--Actualizacion de kdpedido
			update keplersc.kdpedido set c12=isan, c13=iva 
				where c1=rec_C_VENTAS.c1 and c2=rec_C_VENTAS.c2;
			get diagnostics totUpd = ROW_COUNT;
			totUpdPedido:=totUpdPedido+totUpd;		
		end loop;
	end loop;
	mensaje:=concat('Registros actualizados: Ventas:',totUpdVentas::text,'; ',
		'Comis:',totUpdComis,'; ','Movtos:',totUpdMovtos,'; ','Pedidos:',totUpdPedido);
	resultado := 1;
	adicionales := '';
	return query select resultado, mensaje, adicionales;	

exception
	when others then
		resultado := 0;
		mensaje := 'autos_regenera_isan() ' || '['|| sqlstate || '] ' || sqlerrm ;
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
end;
/*
SUB START
 A1=01: SALTA(3,A1...A3): A2=01+DATE(0,2)+DATE(0,1): A3=31+DATE(0,2)+DATE(0,1)
 LIB(INVLIB)
 CALL DEFINE_INV
 OPEN(S,KDMS,C,KDVENTAS,D,KDCOMISMOV,V,KDIV,W,KDM1,M,KDMM)
 LINK(A1,S,1,3,A1,%,1,Cve,2,Sucursal)
 LINK(-13,EJECUTA)
ENDSUB

SUB EJECUTA
 IF WIND(FIJO,"Presione <ENTER> para Continuar, <ESC> para Cancelar")=27 THEN EXIT: ENDIF
 VIEW(V)
  VIEW(C,3) WHILE C1=A1 AND C14=V1 AND C9>=A2 AND C9<=A3
   B7012=C26
   B7013=16
   B7014=C26
   IF C17><"TRAS" THEN 
   	B7015=1:  
   ELSE 
   	B7015=0: 
   ENDIF
   A100=C2
   CALL SUMAS_INV
   C25=B7011
   C24=B7010
   PUT(C)
   IF BUS(W,1,0,C1,C4...C8)>0 THEN
    W15=C24
    W14=C25
    PUT(W)
   ENDIF
   VIEW(D,3) WHILE D1=C1 AND D8=C2
    D22=C26: D21=C25: D20=C24: PUT(D)
   LOOP
  LOOP
 LOOP
 STOP
ENDSUB
*/
$function$
