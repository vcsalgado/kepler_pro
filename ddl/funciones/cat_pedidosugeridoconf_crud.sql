CREATE OR REPLACE FUNCTION keplersc.cat_pedidosugeridoconf_crud(dataxml xml)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
--Descripcion: Pedidos sugeridos / Configuracion
--Autor: Saltiel Rc
--Fecha: 11/02/2022
--Bitacora de cambios
declare
v_sucursal_id text= '';--k_sucN c1 
v_Apli_min_anticipo text= '';--k_AplMinAnt c11
v_min_anticipo text= '';--k_MinAnticipo c9
v_Formula text = ''; --k_Formula c5 
v_DiasVenBusMen text= '';--k_DiasVenBusMen c2 
v_DiasVenBusDia text= ''; --k_DiasVenBusDia c4
v_DelayTraslado text= ''; -- k_DelayTraslado c3
v_DiasHabMes text= ''; --k_DiasHabMes c8
v_DesvEst text = ''; --k_DesvEst c12
v_StockSeguridad text = ''; --k_StockSeguridad c14
v_InvVirtual text = ''; --k_InvVirtual c10
v_PedMostVIN text = ''; --k_PedMostVIN C13
--v_1_2 text = ''; -- k_1o2 C6
--v_Fecha text = ''; -- k_FechaActualizada C7
resultado text= '';
mensaje text = '0';
adicionales text = '';
totreg int = 0;
strtTexto text ='';
v_nocatalogo text ='';

BEGIN

	v_sucursal_id := upper((xpath('//document/k_sucn/r1/text()', dataxml))[1]::text); --C1
	v_Apli_min_anticipo := upper((xpath('//document/k_aplminant/r0/text()', dataxml))[1]::text); --C11
	v_min_anticipo =upper((xpath('//document/k_minanticipo/text()', dataxml))[1]::text);--C9	   
	v_Formula := upper((xpath('//document/k_formula/text()', dataxml))[1]::text); --C5
	v_DiasVenBusMen:= upper((xpath('//document/k_diasvenbusmen/text()', dataxml))[1]::text); --C2	 	 
	v_DiasVenBusDia:= upper((xpath('//document/k_diasvenbusdia/text()', dataxml))[1]::text); -- C4	 	
	v_DelayTraslado:=  upper((xpath('//document/k_delaytraslado/text()', dataxml))[1]::text) ;--C3		
	v_DiasHabMes:= upper((xpath('//document/k_diashabmes/text()', dataxml))[1]::text); --C8	 	
	v_DesvEst := upper((xpath('//document/k_desvest/r0/text()', dataxml))[1]::text); --C12
	v_StockSeguridad := upper((xpath('//document/k_stockseguridad/r0/text()', dataxml))[1]::text); --C14
	v_InvVirtual := upper((xpath('//document/k_invvirtual/r0/text()', dataxml))[1]::text); --C10
	v_PedMostVIN := upper((xpath('//document/k_pedmostvin/r0/text()', dataxml))[1]::text);--C13	
	--v_1_2 := upper((xpath('//document/k_1_2/text()', dataxml))[1]::text);--C6
	--v_Fecha := upper((xpath('//document/k_Fecha/text()', dataxml))[1]::text);--C7	
	/*v_nocatalogo := upper((xpath('//document/k_nocatalogo/text()', dataxml))[1]::text);--COpcion*/
  --	raise notice 'Variables cargadas %' ,v_sucursal_id;
    /*	raise notice 'C1 v_sucursal_id %' ,v_sucursal_id;*/
	select count(*) into totreg from keplersc.KDPEDIDOSUGERIDOCONF 
	where C1 = v_sucursal_id;

	--if v_NoCatalogo = 0 then  --Catálogo 1, Pedido sugerido Configuración 
			
		if totreg = 0 then 
		--insert into	
			insert into keplersc.kdpedidosugeridoconf 
			(C1,C11,C9,C5,C2,C4,C3,C8,C12,C14,C10,C13)
			values (v_sucursal_id,
				v_Apli_min_anticipo,
				v_min_anticipo::numeric,
				v_Formula,
				v_DiasVenBusMen::numeric,
				v_DiasVenBusDia::numeric,
				v_DelayTraslado::numeric,
				v_DiasHabMes::numeric,
				v_DesvEst,
				v_StockSeguridad,
				v_InvVirtual,
	 			v_PedMostVIN);
		 	--raise notice 'var%' , v_sucursal_id;
		end if;
		raise notice 'resultado: %', 'Actualizar' ; 	
		--raise exception 'Error X';
		UPDATE keplersc.KDPEDIDOSUGERIDOCONF
			set 
			C11 = v_Apli_min_anticipo,
			C9 = v_min_anticipo ::numeric,
			C5 = v_Formula,
			C2 = v_DiasVenBusMen::numeric,
			C4 = v_DiasVenBusDia::numeric,
			C3 = v_DelayTraslado::numeric,
			C7 = (select NOW()),
			C8 = v_DiasHabMes::numeric,
			C12 = v_DesvEst,
			C14 = v_StockSeguridad,
			C10 = v_InvVirtual,
			C13 = v_PedMostVIN
		WHERE C1 = v_sucursal_id;
--	raise notice 'actualizado ';
			resultado := 1;
			mensaje := 'Pedido Sugerido actualizado:';
			adicionales := '0';
	--end if;
	return query select resultado, mensaje, adicionales;

exception
	when others then
		resultado := 0;	
		mensaje := 'cat_pedidosugeridoconf() ' || '['|| sqlstate || '] ' || sqlerrm ;
		adicionales := '';
		return query select resultado, mensaje, adicionales;
END;
$function$
