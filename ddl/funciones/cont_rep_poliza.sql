CREATE OR REPLACE FUNCTION keplersc.cont_rep_poliza(dataxml xml)
 RETURNS text
 LANGUAGE plpgsql
AS $function$
--Descripcion: Reporte de polizas Contables
--Autor: Luis Leal
--Fecha: 10/01/2022
--Bitacora de cambios
declare
	--Variables de definicion de documento
	sucursal_id text = '';
	suc_desc text = '';
	anio text = '';
	mes text = '';
	tipo_poliza text = '';
	poliza_inicial text = '';
	poliza_final text = '';
	tabla text = '';
	tabla_2 text = '';
	año_actual text = '';


	--Variables loop
	 cuenta text = '';
	 fecha_pol text = '';
	 cargo_abono text = '';
	 monto text = '';
	 sucursal text = '';
	 genero text = '';
	 naturaleza text = '';
	 grupo text = '';
	 tipo text = '';
	 folio text = '';
	 poliza text = '';
	 fecha_mov text = '';
	 descripcion text = '';
	 doc text = '';
	 refer text = '';
	 poliza_pasada text = '';
	 desc_mov text = '';
	 poliza_repetida_num int = 0;
	 desc_cuenta text = '';
	 status_movto text='';

	--Variables de uso general 
	intValor int = 0;
	xmlResultado text;
	expSql text = '';



	--Variables de retorno

begin
	--raise notice '%', dataxml;

	sucursal_id := (xpath('//document/sucursal_id/text()', dataxml))[1];
	anio:= (xpath('//document/anio/text()', dataxml))[1];
	mes := (xpath('//document/mes/text()', dataxml))[1];
	tipo_poliza := (xpath('//document/tipo_poliza/text()', dataxml))[1];
	poliza_inicial := (xpath('//document/poliza_inicial/text()', dataxml))[1];
	poliza_final := (xpath('//document/poliza_final/text()', dataxml))[1];
	

   	SELECT date_part('year', (SELECT current_timestamp)) into año_actual;
 
	--tabla := concat('kdc2',substring(año_actual,3,2), lpad(mes,2,'0'));
	tabla := concat('kdc2',lpad(anio,2,'0'), lpad(mes,2,'0'));
	--tabla_2 := concat('kdc1',substring(año_actual,3,2));
	tabla_2 := concat('kdc1',lpad(anio,2,'0'));

	select c2 into suc_desc from keplersc.kdms where c1 =sucursal_id;

	expSql:=format('select cnt.c1,cnt.c2,cnt.c3,cnt.c4,cnt.c5,cnt.c6,cnt.c7,cnt.c15,cnt.c16,cnt.c17,cnt.c18,cnt.c19,
		km.c9, mm.c5,dc.c2,coalesce(km.c43,%7$L) 
		from keplersc.%1$s as cnt 
		left outer join keplersc.%2$s as dc on dc.c1=cnt.c3
		inner join keplersc.kdm1 as km on km.c1=cnt.c14 and km.c2=cnt.c15 and km.c3=cnt.c16 and km.c4=cnt.c17 and km.c5=cnt.c18 and km.c6=cnt.c19
 		inner join keplersc.kdmm as mm on mm.c1=cnt.c15 and mm.c2=cnt.c16 and mm.c3=cnt.c17 and mm.c4=cnt.c18
		where cnt.c8=%3$L and cnt.c1 between %4$L::numeric and %5$L::numeric and cnt.c14=%6$L 
		order by cnt.c14,cnt.c8,cnt.c1'
		,tabla,tabla_2,tipo_poliza,poliza_inicial,poliza_final,sucursal_id,'');

raise notice 'expSql:% ',expSql;
	for poliza,fecha_pol,cuenta,cargo_abono,monto,descripcion,refer,genero,naturaleza,grupo,tipo,folio, fecha_mov ,desc_mov,desc_cuenta,status_movto
		in execute format('select cnt.c1,cnt.c2,cnt.c3,cnt.c4,cnt.c5,cnt.c6,cnt.c7,cnt.c15,cnt.c16,cnt.c17,cnt.c18,cnt.c19,
		km.c9, mm.c5,dc.c2,coalesce(km.c43,%7$L) 
		from keplersc.%1$s as cnt 
		left outer join keplersc.%2$s as dc on dc.c1=cnt.c3
		inner join keplersc.kdm1 as km on km.c1=cnt.c14 and km.c2=cnt.c15 and km.c3=cnt.c16 and km.c4=cnt.c17 and km.c5=cnt.c18 and km.c6=cnt.c19
 		inner join keplersc.kdmm as mm on mm.c1=cnt.c15 and mm.c2=cnt.c16 and mm.c3=cnt.c17 and mm.c4=cnt.c18
		where cnt.c8=%3$L and cnt.c1 between %4$L::numeric and %5$L::numeric and cnt.c14=%6$L 
		order by cnt.c14,cnt.c8,cnt.c1'
		,tabla,tabla_2,tipo_poliza,poliza_inicial,poliza_final,sucursal_id,'') 
		loop
--raise notice 'Poliza:%; cuenta:% ',poliza,cuenta;		
			if poliza <> poliza_pasada then 
			
				--cierra el renglon de la poliza pasada
				if intValor != 0 then
				
					xmlResultado :=  concat(xmlResultado,format('</polizas></r%1$s>', intValor - 1 ,fecha_mov));
				
				end if;
			
				fecha_mov :=  substring(fecha_mov, 1, 10);
				fecha_pol :=  substring(fecha_pol, 1, 10);
			
				doc := concat(genero,naturaleza, lpad(grupo,2,'0'), lpad(tipo,3,'0'), '-', folio);
				xmlResultado :=  concat(xmlResultado,format('<r%1$s><tipo_poliza>%2$s</tipo_poliza><poliza>%3$s</poliza>
				<fecha_pol>%4$s</fecha_pol><fecha_mov>%5$s</fecha_mov><sucursal_id>%6$s</sucursal_id>
				<suc_desc>%7$s</suc_desc><doc>%8$s</doc><desc_mov>%9$s</desc_mov><status_movto>%10$s</status_movto><polizas>', 
				intValor,tipo_poliza,poliza,fecha_pol,fecha_mov,sucursal_id,suc_desc,doc,desc_mov,status_movto ));
			
				intValor := intValor + 1;
				poliza_repetida_num := 0;
			
			else
			
				poliza_repetida_num := poliza_repetida_num + 1;
			
			end if;

			if desc_cuenta is null then
				desc_cuenta := 'CUENTA INEXISTENTE';
			end if;
			
			xmlResultado :=  concat(xmlResultado,format('<r%1$s><cuenta>%2$s</cuenta><desc_cuenta>%3$s</desc_cuenta>
			<descripcion>%4$s</descripcion><refer>%5$s</refer><cargo_abono>%6$s</cargo_abono><monto>%7$s</monto></r%1$s>', 
			poliza_repetida_num,cuenta, desc_cuenta,descripcion, refer,cargo_abono, monto));
			
			poliza_pasada := poliza;
			
		end loop;
	
		xmlResultado := concat('<document>',xmlResultado, format('</polizas></r%1$s></document>', intValor - 1));
		
		return xmlResultado;

exception
	when others then
		raise exception '%', sqlerrm;	
end;
$function$
