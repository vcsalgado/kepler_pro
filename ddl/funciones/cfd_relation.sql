CREATE OR REPLACE FUNCTION keplersc.cfd_relation(dataxml xml, xmlkdm1 xml, xmlkdmm xml, cons_cfdi text)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
declare
--Descripcion: Resuelve CFD_RELATION
--Autor: Miriam Santana
--Fecha: 11/10/2022
--Bitacora de Cambios
--08/10/2024 Miriam Santana: Agregue no considerar los UD63 (Nota de descuento) para obtener el registro de kduxe.
--10/03/2025 Miriam Santana: Obtener el no de paricalidad descontando la parcialidad cancelada 
--08/06/2026 Miriam Santana: No considerar los UD65 (Anulacion de subsidio) para obtener el registro de kduxe y UA53 (Alta de subsidio) en el no de parcialidad
 
	--Variables para xml 
	sucursal_id text;
	genero text;
	naturaleza text;
	grupo text;
	tipo text;
	
	--Variables de uso general
	folio_operacion text;
	rec_relation record;
	tipo_rel text = '01';
	partida int;
	cve_cteprov text;
	suc_xe text;
	gen_xe text;
	nat_xe text;
	gpo_xe int;
	tipo_xe int;
	folio_xe text;
	saldo_ant decimal = 0;
	saldo_act decimal = 0;
	cargos decimal = 0;
	abonos decimal = 0;
	parcialidad int = 0;

	--Variables de retorno
	resultado text;
	mensaje text;
	adicionales text;	
begin
	--Transaccion
	sucursal_id := (xpath('//document/k_sucn/r1/text()', dataxml))[1];
	genero := (xpath('//document/k_tipon/r1/text()', dataxml))[1];
	naturaleza := (xpath('//document/k_tipon/r2/text()', dataxml))[1];
	grupo := (xpath('//document/k_tipon/r3/text()', dataxml))[1];
	tipo := (xpath('//document/k_tipon/r4/text()', dataxml))[1];
	folio_operacion := (xpath('//row/c6/text()', xmlKDM1))[1];
	cve_cteprov := (xpath('//row/c10/text()', xmlKDM1))[1];
	   
	if genero='U' and naturaleza='A' and (xpath('//row/c80/text()', xmlKDMM))[1]::text = 'S' 
		and (xpath('//row/c47/text()', xmlKDMM))[1]::text = 'S' then
		for rec_relation 
			in select * from keplersc.kdm5
			where c1=sucursal_id and c2=genero and c3=naturaleza and c4=grupo::integer and c5=tipo::integer and c6=folio_operacion
		loop 
			--MSS 08102024 Agregue c7<>63 para que no considere los UD63 que corresponden a Nota de descuento, de acuerdo a lo comentado con VCSS
			select c1,c5,c6,c7,c8,c9 into suc_xe,gen_xe,nat_xe,gpo_xe,tipo_xe,folio_xe
				from keplersc.kduxe
				where c1=sucursal_id and c2=cve_cteprov and c3=rec_relation.c14 and c4=1 and c5='U' and c6='D' and (c7 <>63 and c7 <>32 and c7 <>65) order by c11 desc limit 1;
			select c6,c7 into cargos, abonos from keplersc.kduxg
				where c1=sucursal_id and c2=genero and c3=cve_cteprov and c4=rec_relation.c14 and c5=1;	
			saldo_ant:= cargos-abonos+rec_relation.c12;
		
			--MSS 10032025 Obtener el no de paricalidad descontando la parcialidad cancelada UD32, las notas de descuento UA52, sustituciones UA32 y aplicaciones de anticipos UA81
			select sum(pago) into parcialidad from (		
				select case when m1.c39=xe.c9 then 0 else 1 end as pago
				from keplersc.kduxe xe
				left join keplersc.kdm1 m1 on m1.c1=xe.c1 and m1.c2=xe.c5 and m1.c36=xe.c6 and m1.c37=xe.c7 and m1.c38=xe.c8 and m1.c39=xe.c9
				where xe.c1=sucursal_id and xe.c2=cve_cteprov and  xe.c3=rec_relation.c14 and xe.c4=1 and xe.c5='U' and xe.c6='A' and (xe.c7 <>52 and xe.c7 <>32 and xe.c7 <>81 and xe.c7 <>53) and xe.c9<=folio_operacion) as revision_pagos;
/*Asi se obtenia antes el no de parcialidad		
			select count(*) into parcialidad from keplersc.kduxe
				where c1=sucursal_id and c2=cve_cteprov and  c3=rec_relation.c14 and c4=1 and c5='U' and c6='A' and c9<=folio_operacion;
*/
			insert into keplersc.kdf3relation (
			   	c1,c2,c3,c4,c5,
				c6,c7,c8,c9,c10,
				c11,c12,c13,c14,c15,
				c16,c17,c18,c19)
				values(
				sucursal_id,genero,naturaleza,grupo::integer,tipo::integer,
				folio_operacion,cons_cfdi::integer,rec_relation.c7,tipo_rel,suc_xe,
				gen_xe,nat_xe,gpo_xe,tipo_xe,folio_xe,
				saldo_ant,rec_relation.c12,cargos-abonos,parcialidad);
		end loop;
	end if;

	resultado := 1;
	mensaje := '';
	adicionales := '';
	return query select resultado, mensaje, adicionales;		
	
exception
	when others then
		resultado := 0;
		mensaje := 'cfd_relation() ' || '['|| sqlstate || '] ' || sqlerrm;
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
end;
$function$
