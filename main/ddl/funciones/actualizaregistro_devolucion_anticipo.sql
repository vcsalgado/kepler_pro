CREATE OR REPLACE FUNCTION keplersc.actualizaregistro_devolucion_anticipo()
 RETURNS integer
 LANGUAGE plpgsql
AS $function$
--Descripcion: Actualiza el registro de las devoluciones de anticipos en KDF3NCANT
--Autor: Miriam Santana
--Fecha: 31/01/2023
--Bitacora de cambios
declare
estatus int;
fecha_operacion date;
rec record;

folio_anticipo text;
fol text;
grupo int;

begin

--1. Tomar como base el registro de kdm1 de las devoluciones 
	for rec in select * from keplersc.kdm1 k
		where k.c2='U' and k.c3='A' and k.c4=78 and k.c9 >'2022-08-01 00:00:00.000' --Fecha ultimo registro de devoluciones en k75
	
		loop 
					
	raise notice 'Actualiza registro de Devoluciones  UA78 en KDF3NCANT';			
	
			select c8 into estatus
				from keplersc.kdf3ncant
				where c2=rec.c2 and c3=rec.c36 and c4=rec.c37 and c5=rec.c38 and c6=rec.c39;
				
				if not found then
	raise notice 'NO existe registro de anticipo Folio:% en KDF3NCANT',rec.c39;
					
				else
					if estatus=0 then
	raise notice 'Registro Pendiente estaus 0 de anticipo en KDF3NCANT';			
						
						update keplersc.kdf3ncant set
							c8=10,
							c9=rec.c3,
							c10=rec.c4,
							c11=rec.c5,
							c12=rec.c6,
							c13=rec.c9
							where c1=rec.c1 and c2=rec.c2 and c3=rec.c36 and c4=rec.c37 and c5=rec.c38 and c6=rec.c39;
						
						select C6 into folio_anticipo from keplersc.kdf3ncant
							where c1=rec.c1 and c2=rec.c2 and c3=rec.c36 and c4=rec.c37 and c5=rec.c38 and c6=rec.c39;
	raise notice 'Actualiza Devolucion c8=10 nat_devolucion:% gpo_devolucion:% tipo_devolucion:% folio_devolucion:% fec_ope:%',rec.c3,rec.c4,rec.c5,rec.c6,rec.c9;
	raise notice 'Para el Anticipo gen:% nat_anx_anticipo:% gpo_anx_anticipo:% tipo:% folio_anx_anticipo:%',rec.c2,rec.c36,rec.c37,rec.c38,rec.c39;
	raise notice '****VERIFICA UPDATE:%',folio_anticipo;
					else
						select C10,c12 into grupo,fol from keplersc.kdf3ncant
							where c1=rec.c1 and c2=rec.c2 and c3=rec.c36 and c4=rec.c37 and c5=rec.c38 and c6=rec.c39;
						if grupo=80 then
							raise notice 'Revisar....Registro de estatus 10 de anticipo Folio:% en KDF3NCANT',rec.c39;
						end if;
						if fol=rec.c6 then
							raise notice 'Registro correcto de devolucion Folio Anticipo:% en KDF3NCANT',rec.c39;
						end if;
					end if;
				end if;
				
			folio_anticipo='';
			
	end loop;		
return 1;
--raise exception 'ALTO MANUAL PARA PRUEBAS';
end;
$function$
