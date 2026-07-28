CREATE OR REPLACE FUNCTION keplersc.cat_pedidosugerido_validaciones_crud(dataxml xml)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
--Descripcion: Pedidos sugeridos / Configuracion
--Autor: Saltiel Rc
--Fecha: 24/02/2022
--Bitácora de cambios
declare
v_sucursal_id text= '';--k_sucN c1 
v_Fecha text = ''; -- k_FechaActualizada C7
v_anio numeric = 0;
v_mes numeric = 0;
v_dia numeric = 0;
v_h26 numeric = 0;
v_h27 numeric = 0;
v_h28 numeric = 0;
v_h29 numeric = 0;
v_h30 numeric = 0;
v_h31 numeric = 0;
v_h32 text = '';
v_h1 text = '';


resultado text= '';
mensaje text = '0';
adicionales text = '';
totreg int = 0;
strtTexto text ='';
v_nocatalogo text =''; --no de catalogo se refiere a la opción que se manda desde codigo


BEGIN

	v_nocatalogo := upper((xpath('//document/k_nocatalogo/text()', dataxml))[1]::text); 	
	v_sucursal_id := upper((xpath('//document/k_sucn/text()', dataxml))[1]::text); --C1

	if v_nocatalogo::numeric = 1 then
	
			v_sucursal_id := upper((xpath('//document/k_sucn/text()', dataxml))[1]::text); --C1
			v_h26  := upper((xpath('//document/k_cicloreorden_a1/text()', dataxml))[1]::text); --C26
			v_h27  := upper((xpath('//document/k_leadtime_a2/text()', dataxml))[1]::text); --C27
			v_h28  := upper((xpath('//document/k_maxfluletime_a3/text()', dataxml))[1]::text); --C28
			v_h29  := upper((xpath('//document/k_tasaservicio_a4/text()', dataxml))[1]::text); --C29
			v_h30  := upper((xpath('//document/k_stockseg_a5/text()', dataxml))[1]::text); --C30
			
			select EXTRACT(MONTH FROM c7) -1 into v_mes  from keplersc.KDPEDIDOSUGERIDOCONF WHERE c1 = v_sucursal_id ;
			select EXTRACT(day  FROM c7)  into v_dia  from keplersc.KDPEDIDOSUGERIDOCONF WHERE c1 = v_sucursal_id ;
			select EXTRACT(year  FROM c7) into v_anio  from keplersc.KDPEDIDOSUGERIDOCONF WHERE c1 = v_sucursal_id ;
	
		if v_mes < 1 then 
				v_mes = 12;
				v_anio = v_anio -1;			
		end if; --fin de v_mes 
	
		resultado = (select extract (day from (select date_trunc('month',(select c7 - interval '1 month' from keplersc.KDPEDIDOSUGERIDOCONF WHERE c1 = '02')::date) +'1month' ::interval -'1sec' ::interval)));
		v_Fecha = (LPAD(resultado::text ,2,'0') || '/' || LPAD(v_mes::text ,2,'0') || '/' || v_anio) :: text;
		
		update keplersc.KDPEDIDOSUGERIDOCONF
		set c7  = v_Fecha :: date,
			c6  = 1
		WHERE c1 = v_sucursal_id;
		--
		--raise notice 'Fecha Actualizada %' , v_Fecha;
		
		update keplersc.KDINI 
		set c26 = v_h26, 
			c27 = v_h27,
			c28 = v_h28,
			c29 = v_h29,
			c30 = v_h30;
		---raise notice '2';
		update keplersc.KDPEDIDOSUGERIDOCONF
		set c6  = 0
		WHERE c1 = v_sucursal_id;
		--raise notice '3';
	
		resultado := 1;
		mensaje := 'Registro actualizado.';
		adicionales := '0';		

	end if; -- fin de v_nocatalogo ( 1 )
	
	if v_nocatalogo::numeric = 2 then
			
			v_h26  := upper((xpath('//document/k_cicloreorden_a2/text()', dataxml))[1]::text); --C26
			v_h27  := upper((xpath('//document/k_leadtime_a3/text()', dataxml))[1]::text); --C27
			v_h28  := upper((xpath('//document/k_maxfluletime_a4/text()', dataxml))[1]::text); --C28
			v_h29  := upper((xpath('//document/k_tasaservicio_a5/text()', dataxml))[1]::text); --C29
			v_h30  := upper((xpath('//document/k_stockseg_a6/text()', dataxml))[1]::text); --C30
			v_h32  := upper((xpath('//document/k_clasificacion_a7/text()', dataxml))[1]::text); --C32
			v_h31  := upper((xpath('//document/k_multempa_a8/text()', dataxml))[1]::text); --C31
			v_h1   := upper((xpath('//document/k_pieza_a1/text()', dataxml))[1]::text); --C1
			
			select EXTRACT(MONTH FROM c7) -1 into v_mes  from keplersc.KDPEDIDOSUGERIDOCONF WHERE c1 = v_sucursal_id ;
			select EXTRACT(day  FROM c7)  into v_dia  from keplersc.KDPEDIDOSUGERIDOCONF WHERE c1 = v_sucursal_id ;
			select EXTRACT(year  FROM c7) into v_anio  from keplersc.KDPEDIDOSUGERIDOCONF WHERE c1 = v_sucursal_id ;
	
		if v_mes < 1 then 
				v_mes = 12;
				v_anio = v_anio -1;			
		end if; --fin de v_mes 
	
		resultado = (select extract (day from (select date_trunc('month',(select c7 - interval '1 month' from keplersc.KDPEDIDOSUGERIDOCONF WHERE c1 = '02')::date) +'1month' ::interval -'1sec' ::interval)));
		v_Fecha = (LPAD(resultado::text ,2,'0') || '/' || LPAD(v_mes::text ,2,'0') || '/' || v_anio) :: text;
		
		update keplersc.KDPEDIDOSUGERIDOCONF
		set c7  = v_Fecha :: date,
			c6  = 1
		WHERE c1 = v_sucursal_id;
		--
		--raise notice 'Fecha Actualizada %' , v_Fecha;
		
		update keplersc.KDINI 
		set c26 = v_h26, 
			c27 = v_h27,
			c28 = v_h28,
			c29 = v_h29,
			c30 = v_h30,
			c31 = v_h31,
			c32 = v_h32
		where c1 = v_h1;
		---raise notice '2';
		update keplersc.KDPEDIDOSUGERIDOCONF
		set c6  = 0
		WHERE c1 = v_sucursal_id;
		--raise notice '3';	
		resultado := 1;
		mensaje := 'Registro actualizado.';
		adicionales := '0';
	end if; -- fin de v_nocatalogo_Parámetro Pieza ( 2 )
	
	if v_nocatalogo::numeric = 3 then
	end if; -- fin de v_nocatalogo ( 3 )
	
	if v_nocatalogo::numeric = 4 then
	end if; -- fin de v_nocatalogo ( 4 )	
	
return query select resultado, mensaje, adicionales;

exception
	when others then
		resultado := 0;	
		mensaje := 'cat_pedidosugerido_validaciones_crud() ' || '['|| sqlstate || '] ' || sqlerrm ;
		adicionales := '';
		return query select resultado, mensaje, adicionales;
END;
$function$
