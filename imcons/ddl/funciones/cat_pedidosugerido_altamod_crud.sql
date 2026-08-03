CREATE OR REPLACE FUNCTION keplersc.cat_pedidosugerido_altamod_crud(dataxml xml)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
--Descripcion: Cursores
--Autor: Saltiel Rc
--Fecha: 20/05/2022
--Fecha: 21/06/2022
--Bitácora de cambios
--Fixed Structure JMM 20230815
declare
v_sucursal_id text = '';
v_referencia text = '';
v_ModOpe_A3 text = '';
v_DiasVenBus_A4 text = '';
v_DelayTraslado_A5 text = '';
v_Count_KDPEDREF numeric= 0;
v_contador numeric = 0;
v_fecha timestamp;
resultado text= '';
mensaje text = '0';
adicionales text = '';
totreg int = 0;
strtTexto text ='';
v_nocatalogo text =''; 
v_fecha_anio text ='';
v_fecha_mes text ='';
v_fecha_dia text ='';
v_fecha_KDPEDIDOSUGERIDOCONF numeric = 0;
v_fecha_anio_2 text ='';
v_fecha_mes_2 text ='';
v_fecha_dia_2 text ='';
v_fecha_KDPEDIDOSUGERIDOCONF_2 numeric = 0;

begin
	
	v_sucursal_id := upper((xpath('//document/k_sucn/text()', dataxml))[1]::text); --
	v_referencia := upper((xpath('//document/k_referencia_a6/text()', dataxml))[1]::text); --
	v_ModOpe_A3:= upper((xpath('//document/k_modope_a3/text()', dataxml))[1]::text); --
	v_DiasVenBus_A4:= upper((xpath('//document/k_diasvenbus_a4/text()', dataxml))[1]::text); --
	v_DelayTraslado_A5:= upper((xpath('//document/k_delaytraslado_a5/text()', dataxml))[1]::text); --	
	v_Count_KDPEDREF := (select count(*) from keplersc.KDPEDREF where c1 = v_sucursal_id  and c2 = v_referencia) :: numeric ;
	--raise notice 'v_Count_KDPEDREF %',v_Count_KDPEDREF;	

	if(v_Count_KDPEDREF = 0) then
	
		if((select count(*) from keplersc.KDPEDIDOSUGERIDOCONF where c1 = v_sucursal_id ) = 0) then
			resultado ='0';
			mensaje ='La configuracion del pedido sugerido para esta sucursal no existe';
			adicionales ='0';	
		    return query select resultado, mensaje, adicionales;
		end if;
	
	    if((select c6 from keplersc.KDPEDIDOSUGERIDOCONF where c1 = v_sucursal_id ) = 1) then
			resultado ='0';
			mensaje ='Se esta realizando un pedido sugerido o un lisado MAD/MIP';
			adicionales ='1';
			return query select resultado, mensaje, adicionales;
		end if;
	
		if((select count(*) from keplersc.KDPEDIDOSUGERIDOCONF where c1 = v_sucursal_id and c12 ='S' or c12 ='N') = 0) then
		    resultado ='0';
			mensaje ='El uso de la desviación estandard no esta bien configurado';
			adicionales ='2';
			return query select resultado, mensaje, adicionales;
		end if;
	
		select c7 into v_fecha from keplersc.KDPEDIDOSUGERIDOCONF where c1 = v_sucursal_id;
	
    	--raise notice 'current_timestamp %', current_timestamp;
		--raise notice 'v_fecha %', v_fecha;	
		
		v_fecha_anio = (select EXTRACT(year  FROM c7) from keplersc.KDPEDIDOSUGERIDOCONF WHERE c1 = v_sucursal_id );	
		v_fecha_mes = (select EXTRACT(MONTH FROM c7) -1 from keplersc.KDPEDIDOSUGERIDOCONF WHERE c1 = v_sucursal_id);		
		v_fecha_dia = (select extract (day from (select date_trunc('month',(select c7 - interval '1 month' from keplersc.KDPEDIDOSUGERIDOCONF WHERE c1 = v_sucursal_id)::date) +'1month' ::interval -'1sec' ::interval)));
		v_fecha_KDPEDIDOSUGERIDOCONF = (select CONCAT(v_fecha_anio, v_fecha_mes, v_fecha_dia) ::numeric);
	
        --raise notice 'Fecha_Pedido: %',v_fecha_KDPEDIDOSUGERIDOCONF;
	
		v_fecha_anio_2 = (select EXTRACT(year  FROM (select now())));
		v_fecha_mes_2 = (select EXTRACT(MONTH FROM (select now())));
		v_fecha_dia_2 = '31';
		v_fecha_KDPEDIDOSUGERIDOCONF_2 = (select CONCAT(v_fecha_anio_2, v_fecha_mes_2, v_fecha_dia_2) ::numeric );
	
	    --raise notice 'Fecha_Valida: %',v_fecha_KDPEDIDOSUGERIDOCONF_2;
	
        --if(current_timestamp > v_fecha) then
		if(v_fecha_KDPEDIDOSUGERIDOCONF > v_fecha_KDPEDIDOSUGERIDOCONF_2) then		--raise notice 'abc';
			resultado ='0';
			mensaje ='El listado MAD/MIP ya no es valido';
			adicionales ='3';
			return query select resultado, mensaje, adicionales;
		end if;		
	
		if((select count(*) from keplersc.KDPEDIDOSUGERIDOCONF where c1 = v_sucursal_id and c5 ='M' or c5 ='Q') = 0) then
			resultado ='0';
			mensaje ='La fórmula para el pedido sugerido no es correcta';
			adicionales ='4';		
			return query select resultado, mensaje, adicionales;
		end if;	

	    if((select count(*) from keplersc.KDPEDIDOSUGERIDOCONF where c1 = v_sucursal_id and c5 ='M' ) > 0) then
	    
		    if(v_ModOpe_A3::numeric < 0 or v_ModOpe_A3::numeric > 1) then		
				resultado ='0';
				mensaje ='El modo de operacion no es correcto';
				adicionales ='5';
			    return query select resultado, mensaje, adicionales;
		    end if;
		   
			if(v_DiasVenBus_A4::numeric  < 0 ) then
				resultado ='0';
				mensaje ='Los dias de venta buscados debe ser mayor a cero';
				adicionales ='6';
		    	return query select resultado, mensaje, adicionales;
			end if;		
		
			if(v_DelayTraslado_A5::numeric  < 0 ) then 
				resultado ='0';
				mensaje ='El delay de traslado debe ser mayor a cero';
				adicionales ='7';
				return query select resultado, mensaje, adicionales;
			end if;
		
		end if; --fin de la validacion M
		
		if((select count(*) from keplersc.KDPEDREF where c1 =v_sucursal_id and c4 = 10) >  0 and 
			(select count(*) from keplersc.KDPEDREF where c1 =v_sucursal_id and c2 = v_referencia) = 0) then 			
		    	resultado ='0';
				mensaje ='Hay pedidos sugeridos que no han sido solicitados,Solicite dichos pedidos o cancelelos antes de realizar uno nuevo';
				adicionales ='8';
				return query select resultado, mensaje, adicionales;
		end if;	
	
	    if (select count(*) from keplersc.KDPEDREF where c1 =v_sucursal_id and c4 = 0 and c2 = v_referencia) then 			
				resultado ='0';
				mensaje ='Este pedido ha sido previamente eliminado y no puede ser consultado.';
				adicionales ='9';
				return query select resultado, mensaje, adicionales;
		end if;
	
		if ((select count(*) from keplersc.KDPEDREF where c1 =v_sucursal_id and c2 = v_referencia) = 0) then
				resultado ='3';
				mensaje ='Este pedido no existe, se creara.';
				adicionales ='10';
				return query select resultado, mensaje, adicionales;
		end if;
		
	end if;	
	
	--raise notice 'Ini %' , (select clock_timestamp());
	--n1_anio = (select extract(year from  current_timestamp));
	--n2_mes  = (select extract(month from current_timestamp)-6);
	  
	resultado ='1';
	mensaje ='Finalizado';
	adicionales ='';

	--raise notice 'Fin %' , (select clock_timestamp());

	return query select resultado, mensaje, adicionales;

exception
	when others then
		resultado := 0;	
		mensaje := 'cat_altamod_crud() ' || '['|| sqlstate || '] ' || sqlerrm ;
		adicionales := '';
		return query select resultado, mensaje, adicionales;
END;
$function$
