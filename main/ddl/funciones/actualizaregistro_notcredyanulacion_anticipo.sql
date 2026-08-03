CREATE OR REPLACE FUNCTION keplersc.actualizaregistro_notcredyanulacion_anticipo()
 RETURNS integer
 LANGUAGE plpgsql
AS $function$
--Descripcion: Actualiza el registro de las NC y anulaciones en KDF3NCANT que se grabaron en KDVALNTCR
--Autor: Miriam Santana
--Fecha: 11/01/2023
--Bitacora de cambios
declare
totReg int;
fecha_operacion date;
rec record;
rec79 INT;
rec80 INT;
folio_anulacion text;

begin

--1. Borrar las NC de anticipos de keplersc.kdvalntcr
	--delete from keplersc.kdvalntcr where c2='U'and c3='A' and c4=79
	select COUNT(*) into REC79 from keplersc.kdvalntcr where c2='U'and c3='A' and c4=79;
raise notice 'Elimina Notas de credito UA79  de KDVALNTCR: %',REC79; 
--2. Consultar en un rec las anulaciones 
for rec in select * from keplersc.kdvalntcr k 
	where c2='U'and c3='A' and c4=80
	loop 
	--	select * from keplersc.kdf3ncant
		--	where c2=rec.c2 and c3=rec.c7 and c4=rec.c8 and c5=rec.c9 and c6=rec.c10;
raise notice 'Actualiza registro de Anulaciones  UA80 en KDF3NCANT';			
raise notice 'gen:% nat_anx_anticipo:% gpo_anx_anticipo:% tipo:% folio_anx_anticipo:%',rec.c2,rec.c7,rec.c8,rec.c9,rec.c10;	
		select count(*) into totReg
			from keplersc.kdf3ncant
			where c2=rec.c2 and c3=rec.c7 and c4=rec.c8 and c5=rec.c9 and c6=rec.c10;
			
			if totReg=0 then
raise notice 'NO existe registro de anticipo en KDF3NCANT';
				select c9 into fecha_operacion 
					from keplersc.kdm1 
					where c1=rec.c1 and c2=rec.c2 and c3=rec.c7 and c4=rec.c8 and c5=rec.c9 and c6=rec.c10;
raise notice 'fec_ope_anticipo:%',fecha_operacion;
/*
				insert into keplersc.kdf3ncant (
					c1,c2,c3,c4,c5,
					c6,c7,c8)
				values(
					rec.c1,rec.c2,rec.c7,rec.c8,rec.c9,
					rec.c10,fecha_operacion,0);
*/
raise notice 'Inserta suc:% gen:% nat_anx_anticipo:% gpo_anx_anticipo:% tipo_anx_anticipo:% folio_anx_anticipo:% fec_ope_anx_anticipo:% c8=0',
					rec.c1,rec.c2,rec.c7,rec.c8,rec.c9,rec.c10,fecha_operacion;
			else
raise notice 'SI existe registro de anticipo en KDF3NCANT';			
				select c9 into fecha_operacion 
					from keplersc.kdm1 
					where c1=rec.c1 and c2=rec.c2 and c3=rec.c3 and c4=rec.c4 and c5=rec.c5 and c6=rec.c6;
raise notice 'fec_ope_anulacion:%',fecha_operacion;
				update keplersc.kdf3ncant set
					c8=10,
					c9=rec.c3,
					c10=rec.c4,
					c11=rec.c5,
					c12=rec.c6,
					c13=fecha_operacion
					where c1=rec.c1 and c2=rec.c2 and c3=rec.c7 and c4=rec.c8 and c5=rec.c9 and c6=rec.c10;
				select C12 into folio_anulacion from keplersc.kdf3ncant
					where c1=rec.c1 and c2=rec.c2 and c3=rec.c7 and c4=rec.c8 and c5=rec.c9 and c6=rec.c10;
raise notice 'Actualiza Anulacion c8=10 nat_anulacion:% gpo_anulacion:% tipo_anulacion:% folio_anulacion:% fec_ope:%',rec.c3,rec.c4,rec.c5,rec.c6,fecha_operacion;
raise notice 'Para el Anticipo gen:% nat_anx_anticipo:% gpo_anx_anticipo:% tipo:% folio_anx_anticipo:%',rec.c2,rec.c7,rec.c8,rec.c9,rec.c10;
raise notice '****VERIFICA UPDATE:        %           ********',folio_anulacion;
			end if;
			
			fecha_operacion=to_date('1800-01-01 00:00:00.000','YYYY-MM-DD');
		folio_anulacion='';
		
end loop;		
		
--3. Borrar las Anulaciones de anticipos de keplersc.kdvalntcr
	--delete from keplersc.kdvalntcr where c2='U'and c3='A' and c4=80;
select COUNT(*) into REC80 from keplersc.kdvalntcr where c2='U'and c3='A' and c4=80;
raise notice 'Elimina Anulaciones UA80 de KDVALNTCR: %',REC80;	
return 1;
--raise exception 'ALTO MANUAL PARA PRUEBAS';
end;
$function$
