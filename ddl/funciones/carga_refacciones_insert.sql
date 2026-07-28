CREATE OR REPLACE FUNCTION keplersc.carga_refacciones_insert(dataxml xml, folio_operacion text)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
--Descripcion: carga_refacciones_insert
--Autor: Luis Leal
--Fecha: 26/01/2022
--Bitacora de cambios
declare

	sucursal_id text;
	genero text;
	naturaleza text;
	grupo integer;
	tipo integer;

	fecha_mov text;
	tipo_orden text;
	orden text;
	M67 text;

	--variables loop
	Codigo_requisicion integer;
	partida integer;
	producto text;
	descr text;
	cantidad numeric;
	unidad text;
	unitario numeric;
	importe numeric; 
	monto numeric;

	resultado text = '';
	mensaje text = '0';
    adicionales text = '';
   
   	iva_cte decimal = 0.00;		--cfdi no calculos
	total_cte decimal = 0.00;	--cfdi no calculos
	iva_default decimal = 0.00; --cfdi no calculos
	
begin 

	sucursal_id := (xpath('//document/k_sucn/r1/text()', dataxml))[1];
	genero := (xpath('//document/k_tipon/r1/text()', dataxml))[1];
	naturaleza := (xpath('//document/k_tipon/r2/text()', dataxml))[1];
	grupo := (xpath('//document/k_tipon/r3/text()', dataxml))[1];
	tipo := (xpath('//document/k_tipon/r4/text()', dataxml))[1];
	
	select m1.c9,m1.c121,m1.c122,mm.c67 into fecha_mov,tipo_orden,orden,M67 from keplersc.kdm1 as m1
	inner join keplersc.kdmm as mm on mm.c1= m1.c2 and  mm.c2= m1.c3 and mm.c3= m1.c4 and mm.c4= m1.c5 
	where m1.c1=sucursal_id and m1.c2=genero and m1.c3=naturaleza and m1.c4=grupo and m1.c5=tipo 
	and m1.c6=folio_operacion;
	
	if found then
	--cfdi no calculos 
		--Obtiene %Iva
		select c11 into iva_default from keplersc.kdmargen where c1=tipo_orden;
	--
		for Codigo_requisicion,partida,producto,descr,cantidad,unidad,unitario,importe 
		in select c27,c7,c8,c10,c9,c11,c12,c13 from keplersc.kdm2 where c1=sucursal_id and c2=genero 
		and c3=naturaleza and c4=grupo and c5=tipo and c6=folio_operacion
		loop
								
			monto := importe;
			if M67 = 'S' then 
			
				select c12 into monto from keplersc.kdinm where c1=sucursal_id and c5=genero
				and c6=naturaleza and c7=grupo and c8=tipo and c9=folio_operacion and c10=partida;
				if not found then
				
					monto := importe;
				
				end if;

			end if;		
		--cfdi no cálculos
			iva_cte := 0; total_cte := 0;
			iva_cte := importe * (iva_default/100);
			total_cte := importe + iva_cte;
		--En el insert c21,c22			
			insert into keplersc.kdref (c1,c2,c3,c4,c5,c6,c7,c8,c9,c10,c11,c12,c13,c14,c15,
			c16,c17,c18,c19,c20,c21,c22) values(sucursal_id,tipo_orden, orden,Codigo_requisicion,genero,
			naturaleza,grupo,tipo,folio_operacion,partida,producto,descr,cantidad,unidad,unitario,
			importe,0.00,'I',monto,to_date(fecha_mov,'YYYY-MM-DD'),iva_cte,total_cte);
		
		end loop;
	
	end if;

	resultado := 1;
	mensaje := 'Guardado: ' || folio_operacion;
	adicionales := '';
	return query select resultado, mensaje, adicionales;	

exception
	when others then
		resultado := 0;
	
		mensaje := 'carga_refacciones_insert() ' || '['|| sqlstate || '] ' || sqlerrm ;		

		adicionales := '';
		return query select resultado, mensaje, adicionales;	
	
end;
$function$
