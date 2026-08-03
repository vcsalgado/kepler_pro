CREATE OR REPLACE FUNCTION keplersc.regenera_cartera()
 RETURNS integer
 LANGUAGE plpgsql
AS $function$
--Descripcion: Regenera cartera en kduxg 
--Autor: Miriam Santana
--Fecha: 16/12/2024
--Bitacora de cambios
declare
	xmlKDUXE xml;
	xmlKDM1 xml;
	expSql text;
	strValor text;

	cte_uxg text;
	ref_uxg text;
	imp_cargo decimal;
	imp_abono decimal;
	iva_cargo decimal;
	iva_abono decimal;
	saldado int;
	--Variables de retorno
	get_resultado text;
	get_mensaje text; 
	get_adicionales text;

	resultado text = '';
	rec record;
	recxe record;
	recsuc record;
begin
	raise notice 'Inicio';
	
	for recsuc in select * from keplersc.kdms
	loop
		raise notice 'Sucursal:%',recsuc.c1;
		--CAMBIAR UA32 POR UD32 EN KDM1,KDM5 Y KDUXE
		raise notice 'Actualiza KDM5';
		update keplersc.kdm5 set c3='D' 
		--select * from keplersc.kdm5 
		where c1=recsuc.c1 and c2='U' and c3='A' and c4=32 and c6 in (
		select c6 from keplersc.kdm1
		where c1=recsuc.c1 and c2='U' and c3='A' and c4=32 and c16>0.01 and upper(c31) like 'ANULACION%');
		
		
		raise notice 'Actualiza KDUXE';
		update keplersc.kduxe set c6='D' 
		--select * from keplersc.kduxe 
		where c1=recsuc.c1 and c5='U' and c6='A' and c7=32 and c9 in (
		select c6 from keplersc.kdm1
		where c1=recsuc.c1 and c2='U' and c3='A' and c4=32 and c16>0.01 and upper(c31) like 'ANULACION%');
	
		raise notice 'Actualiza KDC22411';
		update keplersc.kdc22411 set c16='D'
		--select * from keplersc.kdc22411
		where c14=recsuc.c1 and c15='U' and c16='A' and c17=32 and c19 in (
		select c6 from keplersc.kdm1
		where c1=recsuc.c1 and c2='U' and c3='A' and c4=32 and c16>0.01 and upper(c31) like 'ANULACION%');

		raise notice 'Actualiza KDC22412';
		update keplersc.kdc22412 set c16='D'
		--select * from keplersc.kdc22412
		where c14=recsuc.c1 and c15='U' and c16='A' and c17=32 and c19 in (
		select c6 from keplersc.kdm1
		where c1=recsuc.c1 and c2='U' and c3='A' and c4=32 and c16>0.01 and upper(c31) like 'ANULACION%');
	
		raise notice 'Inserta registros en KDVALNTCR';
		insert into keplersc.kdvalntcr
		select c1,c2,'D',c8,c9,c10,c3,c4,c5,c6 from keplersc.kdf3sustitucion  
		where c1=recsuc.c1 and c2='U' and c3='A' and c8=32 and c10 in (
		select c6 from keplersc.kdm1
		where c1=recsuc.c1 and c2='U' and c3='A' and c4=32 and c16>0.01 and upper(c31) like 'ANULACION%');

		raise notice 'Actualiza KDM1';
		update keplersc.kdm1 set c3='D'
		--select * from keplersc.kdm1
		where c1=recsuc.c1 and c2='U' and c3='A' and c4=32 and c16>0.01 and upper(c31) like 'ANULACION%';
		
		for rec in select distinct c10 from keplersc.kdm1
			where c1=recsuc.c1 and c2='U' and c3='D' and c4=32 and c16>0.01 and upper(c31) like 'ANULACION%'  order by c10 desc			
		loop
			raise notice 'KDM1';
			
			strValor:='';
			strValor:=concat(strValor,'<document>');
			strValor:=concat(strValor,'<k_sucn><r1>',recsuc.c1,'</r1></k_sucn>');
			strValor:=concat(strValor,'</document>');	
			xmlKDM1:=strValor::xml;
			raise notice 'Rec kdm1- Suc:% clave_cteprov:%',recsuc.c1,rec.c10;
			--Elimina registro de kduxg
			raise notice 'Elimina KDUXG sucursal_id:% genero:% clave_cteprov:%',recsuc.c1,'U',rec.c10; 
			delete from keplersc.kduxg 	
				where c1 = recsuc.c1/*sucursal_id*/ and c2= 'U'/*genero*/ and c3 = rec.c10/*clave_cteprov*/;
					--and c4 =recxe.c3 /*referencia*/ and c5 = 1;	
			for recxe in select * from keplersc.kduxe	
				where c1=recsuc.c1/*sucursal_id*/ and c2=rec.c10/*clave_cteprov*/
				order by c1,c2,c3
			loop
				raise notice 'KDUXE cte:% referencia:% nat:% tipo:% folio:% importe:% iva:%',recxe.c2,recxe.c3,recxe.c6,recxe.c7,recxe.c9,recxe.c13,recxe.c14;	
				expSql=format('select * from keplersc.kduxe where c1=%1$L and c2=%2$L and c3=%3$L and c4=%4$s and c5=%5$L and c6=%6$L and c7=%7$s and c8=%8$s and c9=%9$L',
							recxe.c1/*sucursal_id*/,recxe.c2/*clave_cteprov*/,recxe.c3/*referencia*/,1,recxe.c5/*genero*/,recxe.c6/*naturaleza*/,recxe.c7/*grupo*/,recxe.c8/*tipo_clave*/,recxe.c9/*folio_operacion*/);
				select query_to_xml(expSql, true, false, '') into xmlKDUXE;
				--raise notice 'expSql KDUXE:%',expSql;
											
				select * into get_resultado, get_mensaje, get_adicionales from keplersc.cxcp_sinmov_kduxg_alta(xmlKDM1,xmlKDUXE,recxe.c9);
				if get_resultado = '0' then
					raise exception '%',get_mensaje;
				end if;
				
				select c3,c4,c6,c7,c8,c9,c10 into cte_uxg,ref_uxg,imp_cargo,imp_abono,iva_cargo,iva_abono,saldado from keplersc.kduxg where c1=recxe.c1 and c2=recxe.c5 and c3=recxe.c2 and c4=recxe.c3 and c5=1;
				raise notice 'KDUXG cte_uxg:%,ref_uxg:%,imp_cargo:%,imp_abono:%,iva_cargo:%,iva_abono:%,saldado:%',cte_uxg,ref_uxg,imp_cargo,imp_abono,iva_cargo,iva_abono,saldado;
			
			end loop;
		end loop;
	end loop;
--raise exception 'Alto manual';	
return '1';

end;
$function$
