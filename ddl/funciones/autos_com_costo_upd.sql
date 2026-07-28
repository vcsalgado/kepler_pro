CREATE OR REPLACE FUNCTION keplersc.autos_com_costo_upd(dataxml xml)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
--Descripcion: Actualiza el precio de una compra 
--Autor: Victor Salgado
--Fecha: 16 Abr 2023
--Nota: Actualizar funcion de regeneracion de polizas
--Bitacora de cambios
declare
	movventa text = '';
	movcompra text ='';
	movvale text = '';
	sucursal_id text = '';
	genero text = '';
	naturaleza text = '';
	grupo text = '';
	tipo text = '';
	folio text = '';
	usuario_movto text = '';
	
	get_resultado text;
	get_mensaje text; 
	get_adicionales text;
	
	resultado text = '';
	mensaje text = '';
	adicionales text = '';

	strValor text = '';
	intValor int =0;
	monto_costo text = '0';
	monto_iva text = '0';
	monto_total text = '0';
	sub_ant decimal = 0.00;
	iva_ant decimal = 0.00;
	monto_ant decimal = 0.00;
	partida int = 0;
	intAnio int = 0;
	intMes int = 0;
	strAnio text = '';
	strMes text ='';
	xmlKDM1 xml;
	rec_KDM1 record;
	expSql text = '';
	no_poliza int = 0;
	tipo_poliza text = '';
	inventario text = '';
	estatusCompra int =0;
	estatusVenta int = 0;
	xmlValor xml;
	strfolio text = '';
	strBitacora text ='';

	tabla_kdc1 text = '';
	tabla_kdc2 text = '';

	fecha_movto text = '';
	hora_movto text = '';
	xmlUsr xml;

begin 
--inventario	movvta	fecha_vta	importe_venta	iva_venta	movcompra	fecha_compra	importe_compra	iva_compra	movvale	fecha_vale
--0020-IRN21	U-D-6-1-VAA0000006	2021-05-04 00:00:00.000	539,899.99	74,468.96	X-A-6-2-VXX0000009	2021-05-04 00:00:00.000	454,084.16	62,632.3	N-A-13-1-VXX0000018	2021-06-04 00:00:00.000
	
	sucursal_id:= (xpath('//document/k_sucn/r1/text()', dataxml))[1];
	inventario:= coalesce((xpath('//document/inventario/text()',dataxml))[1]::text,'0')::text;
	movventa:=coalesce((xpath('//document/movvta/text()',dataxml))[1]::text,'0')::text;
	movcompra:=coalesce((xpath('//document/movcompra/text()',dataxml))[1]::text,'0')::text;
	movvale:=coalesce((xpath('//document/movvale/text()',dataxml))[1]::text,'0')::text;
	monto_costo := coalesce((xpath('//document/monto_costo/text()',dataxml))[1]::text,'0')::text;
	monto_iva := coalesce((xpath('//document/monto_iva/text()',dataxml))[1]::text,'0')::text;
	monto_total := coalesce((xpath('//document/monto_total/text()',dataxml))[1]::text,'0')::text;
	usuario_movto := (xpath('//document/movimiento/usuario/text()',dataxml))[1];
	
	strBitacora:=concat(strBitacora,'Inventario:',inventario,'; movcompra:',movcompra,'; movvta:',movventa, '; ');

	--Validar que el movimiento cumpla con los estados de compra y venta para el proceso
	select c31,c32 into estatusCompra,estatusVenta from keplersc.kdinf where c1=sucursal_id and c2=inventario;
	
	if not found then 
		raise exception 'No se encontró registro de inventario(kdinf).';
	end if;
	if estatusCompra<>20 then
		raise exception 'El inventario % no tiene el estado de compra facturado.',inventario;
	end if;
	if estatusVenta=10 then
		raise exception 'El inventario % no tiene estado de venta facturada',inventario;
	end if;

/******************************
 *Actualizar registro de compra X-A-6-1
 *****************************/
	genero := split_part(movcompra,'-',1); 
	naturaleza := split_part(movcompra,'-',2); 
	grupo := split_part(movcompra,'-',3);
	tipo := split_part(movcompra,'-',4);
	folio := split_part(movcompra,'-',5);
	--Validar que el movimiento no este cancelado, obtener importes actuales
	select c43, c16, c14 into strValor, monto_ant, iva_ant from keplersc.kdm1 
	where c1=sucursal_id and c2=genero and c3=naturaleza and 
	c4=grupo::numeric and c5=tipo::numeric  and c6=folio;
	
	sub_ant = monto_ant - iva_ant;--El monto es con iva, separarlo

	strBitacora:=concat(strBitacora,'Sub_A.:',sub_ant, '; IVA_A.:',iva_ant,  '; Imp_A.:',monto_ant, '; ');
	strBitacora:=concat(strBitacora,'Sub_N.:',monto_costo,'; IVA_N.:',monto_iva,'; Imp_N.:',monto_total, '; ');

	--Actualizar registro de compras en kdm1
	update keplersc.kdm1 set c16=monto_total::decimal, c14=monto_iva::decimal,
	c89=monto_total::decimal
	where c1=sucursal_id and c2=genero and c3=naturaleza and 
	c4=grupo::numeric and c5=tipo::numeric and c6=folio;
--raise notice 'PASO 1';
	--Obtener el detalle del registro de compras en kdm1 actualizado
	select * into rec_KDM1 from keplersc.kdm1 
	where c1=sucursal_id and c2=genero and c3=naturaleza and 
	c4=grupo::numeric and c5=tipo::numeric and c6=folio;
	intAnio = extract(year from rec_KDM1.c9);
	intMes = extract(month from rec_KDM1.c9);
	strAnio = intAnio::text;
	strAnio = substring(strAnio,3,2);
	strMes = intMes::text;
	strMes = lpad(strMes,2,'0');

--raise notice 'PASO 2, inventario:%',inventario;
	--Modificar el ultimo movimiento en comisiones, debe estar en estatus 0
	select c3,c12,c8 into partida,intValor,strFolio from keplersc.kdicom 
	where c1=sucursal_id and c2= inventario 
	order by c3 desc limit 1;
	if not found then
		raise exception 'No se encontró registro de comisión';
	end if;
	if intValor=10 then --Estatus cancelado
		raise exception 'El registro de comisión está cancelado.';
	end if;
	update keplersc.kdicom set c23=monto_costo::decimal,
	c31=monto_costo::decimal, c32=monto_iva::decimal, c37=monto_total::decimal
	where c1=sucursal_id and c2= inventario and  
	c3=partida and c4='X' and c5='A' and c6=6 and c7=1 and c8=strFolio;

--raise notice 'PASO 3';
	--Actualizar registro de movimiento en entradas y salidas
	select c3,c4 into partida,intValor from keplersc.kdeinv 
		where c1=sucursal_id and c2= inventario and  
		c5=genero and c6=naturaleza and 
		c7=grupo::numeric and c8=tipo::numeric and c9=folio 
		order by c3 desc limit 1;
	if not  found then
		raise exception 'No se encontró registro de compra de inventario(kdeinv)';
	end if;
	update keplersc.kdeinv set c11=monto_costo::decimal, c12=monto_iva::decimal 
		where c1=sucursal_id and c2= inventario and  
		c3=partida and c5=genero and c6=naturaleza and 
		c7=grupo::numeric and c8=tipo::numeric and c9=folio;	
	
	--Actualizar registro de resumen de entradas y salidas al costo para compra kdginv
	select count(*) into intValor from keplersc.kdginv 
	where c1=sucursal_id and c2= inventario and  
		c3=strMes::numeric and c4=strAnio::numeric; --Registro de salida
	if not found then
		raise exception 'No se encontró registro de entradas y salidas al costo(kdginv)';
	end if;
	update keplersc.kdginv set c11=monto_costo::decimal, c13=monto_iva::decimal 
	where c1=sucursal_id and c2= inventario and  
		c3=strMes::numeric and c4=strAnio::numeric;	
--raise notice 'PASO 5';
	
	--Actualizar registro de resumen de entradas y salidas al costo, kdlinv
	select count(*) into intValor from keplersc.kdlinv where c1=sucursal_id and c2= inventario;
	if not found then
		raise exception 'No se encontró registro de entradas y salidas al costo(kdlinv)';
	end if;
	update keplersc.kdlinv set c5=c5-sub_ant+monto_costo::decimal, c6=c6-sub_ant+monto_costo::decimal,
	c10=c10-iva_ant+monto_iva::decimal, c11=c11-iva_ant+monto_iva::decimal,
	c8=monto_costo::decimal, c9=monto_iva::decimal 
	where c1=sucursal_id and c2= inventario;
--raise notice 'PASO 6';

	--Regenerar la poliza con base en el movimiento y el importe del costo anterior
	intAnio = extract(year from rec_KDM1.c9);
	intMes = extract(month from rec_KDM1.c9);
	strAnio = intAnio::text;
	strAnio = substring(strAnio,3,2);
	strMes = intMes::text;
	strMes = lpad(strMes,2,'0');

	tabla_kdc1 = concat('keplersc.kdc1',strAnio) ;
	tabla_kdc2 = concat('keplersc.kdc2',strAnio,strMes);

--raise notice 'PASO 7: Anio:%; Mes:%; Sucursal:%; Gen:%; Nat:%; Gpo:%; Tipo:%; Folio:%',
--	strAnio, strMes,sucursal_id,genero,naturaleza,grupo,tipo,folio;

	select c1,c8 into no_poliza,tipo_poliza from keplersc.kdc2_view 
		where anio=strAnio and mes=strMes and 
		c14=sucursal_id and c15=genero and c16=naturaleza and 
		c17=grupo::numeric and c18=tipo::numeric and c19=folio limit 1;
	if not found then
		raise exception 'No se encontró la póliza del movimiento de compra.';	
	end if;
	strValor = concat('<document>
		<chk_rango>1</chk_rango>
		<k_sucn_ini>[',sucursal_id,'] 
			<r0>[',sucursal_id,']</r0>
			<r1>',sucursal_id,'</r1>
			<r2></r2>
			<r3></r3>
		</k_sucn_ini>
		<k_gen_ini>',genero,'</k_gen_ini>
		<k_nat_ini>',naturaleza,'</k_nat_ini>
		<k_gpo_ini>',grupo,'</k_gpo_ini>
		<k_tipo_ini>',tipo,'</k_tipo_ini>
		<k_sucn_fin>[',sucursal_id,'] 
			<r0>[',sucursal_id,']</r0>
			<r1>',sucursal_id,'</r1>
			<r2></r2>
			<r3></r3>
		</k_sucn_fin>
		<k_gen_fin>',genero,'</k_gen_fin>
		<k_nat_fin>',naturaleza,'</k_nat_fin>
		<k_gpo_fin>',grupo,'</k_gpo_fin>
		<k_tipo_fin>',tipo,'</k_tipo_fin>
		<fecha_ini>',rec_KDM1.c9,'</fecha_ini>
		<fecha_fin>',rec_KDM1.c9,'</fecha_fin>
		<chk_movto>0</chk_movto>
		<k_sucn_mov>[',sucursal_id,'] 
			<r0>[',sucursal_id,']</r0>
			<r1>',sucursal_id,'</r1>
			<r2></r2>
			<r3></r3>
		</k_sucn_mov>
		<k_gen_mov>',genero,'</k_gen_mov>
		<k_nat_mov>',naturaleza,'</k_nat_mov>
		<k_gpo_mov>',grupo,'</k_gpo_mov>
		<k_tipo_mov>',tipo,'</k_tipo_mov>
		<inp_mov>',folio,'</inp_mov>
		<k_mov/>
		<tipo_proc>F</tipo_proc>
		<movimiento>
			<usuario>ADMIN80</usuario>
		</movimiento></document>'	
	);	

	xmlValor:=strValor::xml;
--raise notice 'PASO 8 ';
--raise notice 'PASO 8 poliza compra:%',xmlValor;	
	xmlValor = (select * from keplersc.cont_regenerar_poliza(xmlValor));
	strValor:=coalesce((xpath('//row/no_poliza_nueva/text()', dataxml))[1],'');
	if strValor<>'' then
		raise exception 'No se generó nueva póliza de compra.';
	end if;
--raise notice 'PASO 9, xmlPolizaComp:%',xmlValor;


/******************************
 *Actualizar registro de venta, U-D-6
 *****************************/
	genero := split_part(movventa,'-',1); 
	naturaleza := split_part(movventa,'-',2); 
	grupo := split_part(movventa,'-',3);
	tipo := split_part(movventa,'-',4);
	folio := split_part(movventa,'-',5);

	--Obtener movimiento de venta
	select * into rec_KDM1 from keplersc.kdm1 
	where c1=sucursal_id and c2=genero and c3=naturaleza and 
		c4=grupo::numeric and c5=tipo::numeric and c6=folio; 
	intAnio = extract(year from rec_KDM1.c9);
	intMes = extract(month from rec_KDM1.c9);
	strAnio = intAnio::text;
	strAnio = substring(strAnio,3,2);
	strMes = intMes::text;
	strMes = lpad(strMes,2,'0');

	--Actualizar registro de comision
--raise notice 'PASO 10';
	select count(*) into intValor from keplersc.kdcomismov where c1=sucursal_id and c2='N' and c3='A' and c4=13 and 
		c5=1 and c8=inventario;
	if intValor = 0 then
		raise exception 'No se encontró registro de comisión de venta';
	end if;
	update keplersc.kdcomismov set c23=monto_costo::decimal 
	where c1=sucursal_id and c2='N' and c3='A' and c4=13 and 
		c5=1 and c8=inventario;

	--Actualizar registro de movimiento en entradas y salidas
	select c3,c4 into partida,intValor from keplersc.kdeinv 
		where c1=sucursal_id and c2= inventario and  
		c5=genero and c6=naturaleza and 
		c7=grupo::numeric and c8=tipo::numeric and c9=folio 
		order by c3 desc limit 1;
	if not  found then
		raise exception 'No se encontró registro de venta de inventario(kdeinv)';
	end if;
	update keplersc.kdeinv set c11=monto_costo::decimal, c12=monto_iva::decimal 
		where c1=sucursal_id and c2= inventario and  
		c3=partida and c5=genero and c6=naturaleza and 
		c7=grupo::numeric and c8=tipo::numeric and c9=folio;

--Actualizar registro de resumen de entradas y salidas al costo para compra kdginv
	select count(*) into intValor from keplersc.kdginv 
	where c1=sucursal_id and c2= inventario and  
		c3=strMes::numeric and c4=strAnio::numeric; --Registro de salida
	if not found then
		raise exception 'No se encontró registro de entradas y salidas al costo(kdginv)';
	end if;
	update keplersc.kdginv set c12=monto_costo::decimal, c14=monto_iva::decimal 
	where c1=sucursal_id and c2= inventario and  
		c3=strMes::numeric and c4=strAnio::numeric;	
	
	--Regenerar poliza de venta
	select c1,c8 into no_poliza,tipo_poliza from keplersc.kdc2_view 
	where anio=strAnio and mes=strMes and c14=sucursal_id and c15=genero and c16=naturaleza and 
		c17=grupo::numeric and c18=tipo::numeric and c19=folio limit 1;
	if not found then
		raise exception 'El inventario % no tiene póliza asociada a su venta.', inventario;
	end if;
	strValor = concat('<document>
		<chk_rango>1</chk_rango>
		<k_sucn_ini>[',sucursal_id,'] 
			<r0>[',sucursal_id,']</r0>
			<r1>',sucursal_id,'</r1>
			<r2></r2>
			<r3></r3>
		</k_sucn_ini>
		<k_gen_ini>',genero,'</k_gen_ini>
		<k_nat_ini>',naturaleza,'</k_nat_ini>
		<k_gpo_ini>',grupo,'</k_gpo_ini>
		<k_tipo_ini>',tipo,'</k_tipo_ini>
		<k_sucn_fin>[',sucursal_id,'] 
			<r0>[',sucursal_id,']</r0>
			<r1>',sucursal_id,'</r1>
			<r2></r2>
			<r3></r3>
		</k_sucn_fin>
		<k_gen_fin>',genero,'</k_gen_fin>
		<k_nat_fin>',naturaleza,'</k_nat_fin>
		<k_gpo_fin>',grupo,'</k_gpo_fin>
		<k_tipo_fin>',tipo,'</k_tipo_fin>
		<fecha_ini>',rec_KDM1.c9,'</fecha_ini>
		<fecha_fin>',rec_KDM1.c9,'</fecha_fin>
		<chk_movto>0</chk_movto>
		<k_sucn_mov>[',sucursal_id,'] 
			<r0>[',sucursal_id,']</r0>
			<r1>',sucursal_id,'</r1>
			<r2></r2>
			<r3></r3>
		</k_sucn_mov>
		<k_gen_mov>',genero,'</k_gen_mov>
		<k_nat_mov>',naturaleza,'</k_nat_mov>
		<k_gpo_mov>',grupo,'</k_gpo_mov>
		<k_tipo_mov>',tipo,'</k_tipo_mov>
		<inp_mov>',folio,'</inp_mov>
		<k_mov/>
		<tipo_proc>F</tipo_proc>
		<movimiento>
			<usuario>ADMIN80</usuario>
		</movimiento></document>');

	xmlValor:=strValor::xml;
--raise notice 'PASO 9 poliza venta:%',xmlValor;

	xmlValor = (select * from keplersc.cont_regenerar_poliza(xmlValor));
	strValor:=coalesce((xpath('//row/no_poliza_nueva/text()', dataxml))[1],'');
	if strValor<>'' then
		raise exception 'No se generó nueva póliza de compra.';
	end if;

	fecha_movto :=  current_date::text;
	hora_movto := left(current_time::text, 8);
	select xmlforest(usuario_movto as usuario, fecha_movto as fecha, hora_movto as hora, 
	sucursal_id as sucursal, genero as genero, naturaleza as naturaleza, 
	grupo as grupo, tipo as tipo, folio as folio,
	'REGCOSUNI' as tipo_movto, strBitacora as detalle_movto) :: text into strValor;		
	select '<document>'||strValor||'</document>' into strValor;

	xmlUsr := strValor::xml;

--raise notice 'Bitacora:%',xmlUsr;

	select * into get_resultado, get_mensaje, get_adicionales from keplersc.usr_kdusraccess_alta(xmlUsr);
	--raise notice '%',sucursal_id;	
	if get_resultado = '0' then
		raise exception '%',get_mensaje;
	end if;
			
--raise notice 'PASO 11, xmlPolizaVta:%',xmlValor;	
--raise exception 'Error inyectado...';
	
/*
 * 
select vta.c100 as inventario, vta.c2||'-'||vta.c3||'-'||vta.c4||'-'||vta.c5||'-'||vta.c6 as movvta,vta.c9 as fecha_vta,vta.c16 as importe_venta, vta.c14 as iva_venta,
mc.c2||'-'||mc.c3||'-'||mc.c4||'-'||mc.c5||'-'||mc.c6 as movcompra,mc.c9 as fecha_compra, mc.c16 as importe_compra, mc.c14 as iva_compra,
val.c2||'-'||val.c3||'-'||val.c4||'-'||val.c5||'-'||val.c6 as movvale,val.c9 as fecha_vale
from keplersc.kdm1 vta 
left outer join keplersc.kdm1 mc on vta.c1=mc.c1 and vta.c100=mc.c100
and mc.c2='X' and mc.c3='A' and (mc.c4=6 or mc.c4=7) 
left outer join keplersc.kdm1 val on vta.c1=val.c1 and vta.c100=val.c100
and val.c2='N' and val.c3='A' and val.c4=13 
where vta.c1='01' and vta.c2='U' and vta.c3='D' and vta.c4=6 
and vta.c6 not in (select mexv.c39 from keplersc.kdm1 mexv where vta.c1=mexv.c1 and vta.c6=mexv.c39)
and mc.c6 not in(select kexc.c39 from keplersc.kdm1 kexc where kexc.c1=mc.c1 and mc.c6=kexc.c39)
and val.c43 <>'C'

inventario	movvta	fecha_vta	importe_venta	iva_venta	movcompra	fecha_compra	importe_compra	iva_compra	movvale	fecha_vale
0020-IRN21	U-D-6-1-VAA0000006	2021-05-04 00:00:00.000	539,899.99	74,468.96	X-A-6-2-VXX0000009	2021-05-04 00:00:00.000	454,084.16	62,632.3	N-A-13-1-VXX0000018	2021-06-04 00:00:00.000

select * from keplersc.autos_com_costo_upd('
<document>
<sucursal_id>01</sucursal_id>
<inventario>0020-IRN21</inventario>
<movvta>U-D-6-1-VAA0000006</movvta>
<fecha_vta>2021-05-04</fecha_vta>
<importe_venta>539899.99</importe_venta>
<iva_venta>74468.96</iva_venta>
<movcompra>X-A-6-2-VXX0000009</movcompra>
<fecha_compra>2021-05-04</fecha_compra>
<subt>454084.16</subt>
<k_iva>454084.16</k_iva>
<k_monto>62632.3</k_monto>
<movvale>N-A-13-1-VXX0000018</movvale>
<fecha_vale>2021-06-04</fecha_vale>
</document>')



<document>
	<fecha>2023-04-24</fecha>
	<hora>19:04:48</hora>
	<sucursal>01</sucursal>
	<genero>U</genero>
	<naturaleza>D</naturaleza>
	<grupo>6</grupo>
	<tipo>1</tipo>
	<folio>VAA0000735</folio>
	<tipo_movto>REGCOSUNI</tipo_movto>
	<detalle_movto>movcompra:X-A-6-1-VXX0000262; movvta:U-D-6-1-VAA0000735; Sub ant.:485976.00; IVA ant.:77756.16 Importe ant.:563732.16; Sub nvo.:485976.00; IVA nvo.:77756.16; Importe nvo.:563732.16; 
	</detalle_movto>
</document>

select * from keplersc.autos_com_costo_upd('
<document>
<sucursal_id>01</sucursal_id>
<inventario>0064-IRN23</inventario>
<movvta>U-D-6-1-VAA0000735</movvta>
<fecha_vta>2023-02-09</fecha_vta>
<importe_venta>669900.00</importe_venta>
<iva_venta>92400.00</iva_venta>
<movcompra>X-A-6-1-VXX0000262</movcompra>
<fecha_compra>2023-01-27</fecha_compra>
<subt>485976.00</subt>
<k_iva>77756.16</k_iva>
<k_monto>563732.16</k_monto>
<movvale>N-A-13-1-VXX0000534</movvale>
<fecha_vale>2023-02-17</fecha_vale>
</document>')


select * from keplersc.cont_actualizar_saldos()
 *  * 
 */	
			
	resultado := 1;
	mensaje := 'Costo actualizado';
	adicionales := '';
	return query select resultado, mensaje, adicionales;	

exception
	when others then
		resultado := 0;
		mensaje := 'autos_com_costo_upd() ' || '['|| sqlstate || '] ' || sqlerrm ;		
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
	
end;
$function$
