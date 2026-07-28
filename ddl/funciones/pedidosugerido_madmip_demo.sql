CREATE OR REPLACE FUNCTION keplersc.pedidosugerido_madmip_demo(dataxml xml)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
--Descripcion: Cursores
--Autor: Victor Salgado, tomado del original cat_pedidosugerido_madmip_crud
--Fecha: 07/02/2025

declare
v_sucursal_id text= ''; 
v_refaccion text = '';
v_C1_Refaccion text = '';

v_c26_Ciclo_Ordenamiento numeric = 0;
v_c27_Tiempo_Entrega numeric = 0;
v_c28_Max_Fluctuacion_Tiempo numeric = 0;
v_c29_Probabilidad_Entrega numeric = 0;
v_c30_Dias_Stock_Seguridad numeric = 0;

v_contador numeric = 0;

resultado text= '';
mensaje text = '0';
adicionales text = '';
totreg int = 0;
strtTexto text ='';
v_nocatalogo text =''; 

n1_anio numeric = 0 ; --anio
r1_anio text  = '' ; --anio string
n2_mes numeric = 0;
n3 numeric = 0;
n4 numeric = 0;
contador numeric = 0;


n11_vtas_mes_1 numeric = 0;
n12_vtas_mes_2 numeric = 0;
n13_vtas_mes_3 numeric = 0;
n14_vtas_mes_4 numeric = 0;
n15_vtas_mes_5 numeric = 0;
n16_vtas_mes_6 numeric = 0;

r2_Phase text = '';

b1_MAD numeric = 0;
b2_MIP numeric = 0;
b3_Max_Fluctuacion_Demandada numeric = 0;
b4_Vtas_Ult_Mes numeric = 0;
b5_MAD_12_Meses numeric = 0;
b6 numeric = 0;
b7 numeric = 0;
b8 numeric = 0;

totalReg int;
vzones int;

dor_ls numeric;
dor_li numeric;
alt_ls numeric;
alt_li numeric;
baj_ls numeric;
baj_li numeric;
obs_ls numeric;
obs_li numeric;

dor_ss numeric;
alt_ss numeric;
baj_ss numeric;
obs_ss numeric;
zone_ss numeric;
zone_tx text;

v_field_key text ;
v_h31_Unidades_Min_Pedido numeric = 0;
c_n3_existencias numeric =0;
c_n4_backorder_salidas numeric =0;
v_oc2_folcita text ='';
v_oc7_marca text ='';
v_oc8_modelo text ='';
v_pc4_Cita_autorizada text ='';
v_pc6_Paquete text ='';
v_qc7_cantidad_paquete text = '';
c_n6_total_cantidad_paquetes numeric =0;
c_n1_cantidad_sugerida_stock numeric=0;
v_k11_cantidad_especial numeric =0;
c_n5_cantidad_solicitada numeric=0;
c_n2 numeric=0;
v_DiasVenBus_A4 numeric=0;
v_DelayTraslado_A5 numeric =0;
v_Formula_A7 text ='';
v_InvVirtual_A11 text = '';
BEGIN

	--crear tablas temporales
	drop table if exists tmpkdinp;
	create temp table tmpkdinp (like keplersc.kdinp);

	drop table if exists tmpkdinpdet;
	create temp table tmpkdinpdet (like keplersc.kdinpdet);

	drop table if exists tmpResultados;
	create temp table tmpResultados (
		num_linea int,linea text);
	create index tmpResultados_num_linea_idx on tmpResultados (num_linea);

	v_sucursal_id := upper((xpath('//document/k_sucn/text()', dataxml))[1]::text);
	v_refaccion := upper((xpath('//document/k_ref/text()', dataxml))[1]::text);

raise notice 'Iniciando sucursal:%; refaccion:% ',v_sucursal_id,v_refaccion;
	totReg := 0;
	select count(c1) into totReg from keplersc.kdpedidosugeridoconf   
	where c1 = v_sucursal_id;   
	if totReg = 0 then
	 	mensaje := 'No existe el registro en la Tabla : kdpedidosugeridoconf';
		raise exception '%', mensaje;	
	else
	
		dor_ss := 0; alt_ss := 0; baj_ss := 0; obs_ss := 0;
	
		select c2,c3,c5,c10,c15, c16, c17, c18 into  v_DiasVenBus_A4,v_DelayTraslado_A5,v_Formula_A7,v_InvVirtual_A11,
			dor_ss, alt_ss, baj_ss, obs_ss 
		from keplersc.kdpedidosugeridoconf where c1 = v_sucursal_id; 
		dor_ss := coalesce(dor_ss, 0); 
		alt_ss := coalesce(alt_ss, 0); 
		baj_ss := coalesce(baj_ss, 0); 
		obs_ss := coalesce(obs_ss, 0); 
	end if;
raise notice 'kdpedidosugeridoconf';
raise notice '	dor_ss:% ',dor_ss;
raise notice '	alt_ss:% ',alt_ss;
raise notice '	baj_ss:% ',baj_ss;
raise notice '	obs_ss:% ',obs_ss;
raise notice '	v_DiasVenBus_A4:% ',v_DiasVenBus_A4;
raise notice '	v_DelayTraslado_A5:% ',v_DelayTraslado_A5;
raise notice '	v_Formula_A7:% ',v_Formula_A7;
raise notice '	v_InvVirtual_A11:% ',v_InvVirtual_A11;
	vzones := 0;
	select count(c1) into vzones from keplersc.kdconfzonas 
	where c1 = 1;   
	if vzones = 0 then
	 	mensaje := 'CALC MIP Original';
raise notice '%', mensaje;
	else
		select c2, c3, c4, c5, c6, c7, c8, c9 
		into dor_li, dor_ls, alt_li, alt_ls, baj_li, baj_ls, obs_li, obs_ls  
		from keplersc.kdconfzonas where c1 = 1; 
		mensaje := 'CALC MIP x Zonas';
raise notice '%', mensaje;
	end if;




	delete from tmpkdinp;
	delete from tmpkdinpdet;
	--raise notice 'Ini %' , (select clock_timestamp());
	n1_anio = (select extract(year from  current_timestamp));
	n2_mes  = (select extract(month from current_timestamp)-6);
	
	if n2_mes <= 0 then 
		n2_mes = n2_mes + 12;
		n1_anio = n1_anio - 1;
	end if;
	
	r1_anio = n1_anio ::text ;

	for v_C1_Refaccion,v_c26_Ciclo_Ordenamiento,v_c27_Tiempo_Entrega,v_c28_Max_Fluctuacion_Tiempo,v_c29_Probabilidad_Entrega,v_c30_Dias_Stock_Seguridad in 
		select i.c1, i.c26, i.c27, i.c28, i.c29, i.c30  from  keplersc.KDINI i 
		left join keplersc.kding g on g.c1 = i.c32
		where i.c1=v_refaccion and 
			(g.c1 isnull or (g.c1 is not null and g.c3 = 'N')) 		
	loop      --loop 1 raise notice 'Registro %' , v_C1_Refaccion;	
raise notice 'Datos refaccion (kdini) v_C1_Refaccion:%;',v_C1_Refaccion;
raise notice '	v_c26_Ciclo_Ordenamiento:%; ',v_c26_Ciclo_Ordenamiento;
raise notice '	v_c27_Tiempo_Entrega:%; ',v_c27_Tiempo_Entrega;
raise notice '	v_c28_Max_Fluctuacion_Tiempo:%; ',v_c28_Max_Fluctuacion_Tiempo;
raise notice '	v_c29_Probabilidad_Entrega:%; ',v_c29_Probabilidad_Entrega;
raise notice '	v_c30_Dias_Stock_Seguridad:%; ',v_c30_Dias_Stock_Seguridad;
		 	contador = 0;
		 	n11_vtas_mes_1= 0; n12_vtas_mes_2= 0; n13_vtas_mes_3= 0; n14_vtas_mes_4= 0; n15_vtas_mes_5= 0; n16_vtas_mes_6= 0;
			case n2_mes
				when 1 then
				select c40,c41,c42,c43,c44,c45 into n11_vtas_mes_1,n12_vtas_mes_2,n13_vtas_mes_3,n14_vtas_mes_4,n15_vtas_mes_5,n16_vtas_mes_6  from  keplersc.kdink where c1=v_sucursal_id and c2=v_C1_Refaccion::text and c3 = r1_anio;
				when 2 then
				select c41,c42,c43,c44,c45,c46 into n11_vtas_mes_1,n12_vtas_mes_2,n13_vtas_mes_3,n14_vtas_mes_4,n15_vtas_mes_5,n16_vtas_mes_6 from  keplersc.kdink where c1=v_sucursal_id and c2=v_C1_Refaccion and c3 = r1_anio;
				when 3 then
				select c42,c43,c44,c45,c46,c47 into n11_vtas_mes_1,n12_vtas_mes_2,n13_vtas_mes_3,n14_vtas_mes_4,n15_vtas_mes_5,n16_vtas_mes_6 from  keplersc.kdink where c1=v_sucursal_id and c2=v_C1_Refaccion and c3 = r1_anio;
				when 4 then
				select c43,c44,c45,c46,c47,c48 into n11_vtas_mes_1,n12_vtas_mes_2,n13_vtas_mes_3,n14_vtas_mes_4,n15_vtas_mes_5,n16_vtas_mes_6 from  keplersc.kdink where c1=v_sucursal_id and c2=v_C1_Refaccion and c3 = r1_anio;
				when 5 then
				select c44,c45,c46,c47,c48,c49 into n11_vtas_mes_1,n12_vtas_mes_2,n13_vtas_mes_3,n14_vtas_mes_4,n15_vtas_mes_5,n16_vtas_mes_6 from  keplersc.kdink where c1=v_sucursal_id and c2=v_C1_Refaccion and c3 = r1_anio;
				when 6 then
				select c45,c46,c47,c48,c49,c50 into n11_vtas_mes_1,n12_vtas_mes_2,n13_vtas_mes_3,n14_vtas_mes_4,n15_vtas_mes_5,n16_vtas_mes_6 from  keplersc.kdink where c1=v_sucursal_id and c2=v_C1_Refaccion and c3 = r1_anio;
				when 7 then
				select c46,c47,c48,c49,c50,c51 into n11_vtas_mes_1,n12_vtas_mes_2,n13_vtas_mes_3,n14_vtas_mes_4,n15_vtas_mes_5,n16_vtas_mes_6 from  keplersc.kdink where c1=v_sucursal_id and c2=v_C1_Refaccion and c3 = r1_anio;
				when 8 then
				--8
				select c47,c48,c49,c50,c51 into n11_vtas_mes_1,n12_vtas_mes_2,n13_vtas_mes_3,n14_vtas_mes_4,n15_vtas_mes_5 from  keplersc.kdink where c1=v_sucursal_id and c2=v_C1_Refaccion and c3 = r1_anio;
				select c40 into n16_vtas_mes_6 from keplersc.kdink where c1=v_sucursal_id and c2=v_C1_Refaccion and c3 = (n1_anio + 1)::text ;
				when 9 then
				--9				
				select c48,c49,c50,c51 into n11_vtas_mes_1,n12_vtas_mes_2,n13_vtas_mes_3,n14_vtas_mes_4 from  keplersc.kdink where c1=v_sucursal_id and c2=(v_C1_Refaccion::text) and c3 = r1_anio;						
				select c40,c41 into n15_vtas_mes_5,n16_vtas_mes_6 from  keplersc.kdink where c1=v_sucursal_id and c2=(v_C1_Refaccion::text) and c3 = (n1_anio+1)::text ;
				if not found then 
						n15_vtas_mes_5 := 0;
						n16_vtas_mes_6 := 0;
				end if;
				when 10 then
				--10
				select c49,c50,c51 into n11_vtas_mes_1,n12_vtas_mes_2,n13_vtas_mes_3  from  keplersc.kdink where c1=v_sucursal_id and c2=v_C1_Refaccion and c3 = r1_anio;
				select c40,c41,c42 into n14_vtas_mes_4,n15_vtas_mes_5,n16_vtas_mes_6 from  keplersc.kdink where c1=v_sucursal_id and c2=v_C1_Refaccion and c3 = (n1_anio+1)::text ;
				when 11 then
				--11
				select c50,c51 into n11_vtas_mes_1,n12_vtas_mes_2 from  keplersc.kdink where c1=v_sucursal_id and c2=v_C1_Refaccion and c3 = r1_anio;
				select c40,c41,c42,c43  into n13_vtas_mes_3,n14_vtas_mes_4,n15_vtas_mes_5,n16_vtas_mes_6 from  keplersc.kdink where c1=v_sucursal_id and c2=v_C1_Refaccion and c3 = (n1_anio+1)::text ;
				when 12 then
				--12
				select c51 into n11_vtas_mes_1 from  keplersc.kdink where c1=v_sucursal_id and c2=v_C1_Refaccion and c3 = r1_anio;
				select c40,c41,c42,c43,c43 into n12_vtas_mes_2,n13_vtas_mes_3,n14_vtas_mes_4,n15_vtas_mes_5,n16_vtas_mes_6 from  keplersc.kdink where c1=v_sucursal_id and c2=v_C1_Refaccion and c3 = (n1_anio+1)::text ;
			end case ;
		
raise notice 'Detalle de ventas';
raise notice '	n11_vtas_mes_1:% ',n11_vtas_mes_1;
raise notice '	n12_vtas_mes_2:% ',n12_vtas_mes_2;
raise notice '	n13_vtas_mes_3:% ',n13_vtas_mes_3;
raise notice '	n14_vtas_mes_4:% ',n14_vtas_mes_4;
raise notice '	n15_vtas_mes_5:% ',n15_vtas_mes_5;
raise notice '	n15_vtas_mes_6:% ',n16_vtas_mes_6;

			if (n11_vtas_mes_1 is not null and n12_vtas_mes_2 is not null and n13_vtas_mes_3 is not null and n14_vtas_mes_4 is not null and n15_vtas_mes_5 is not null and n16_vtas_mes_6 is not null) then 
			
				insert into tmpkdinpdet(c1,c2,c3,c4,c5,c6,c7,c8) 
				values (v_sucursal_id,v_C1_Refaccion,n11_vtas_mes_1,n12_vtas_mes_2,n13_vtas_mes_3,n14_vtas_mes_4,n15_vtas_mes_5,n16_vtas_mes_6);
				--raise notice 'Insertado : %', v_C1_Refaccion;	 			
				
			end if;
		
			-- Added Fixing JMM (Homologar Calculos con K75)
		
			n11_vtas_mes_1 := 0; n12_vtas_mes_2 := 0; n13_vtas_mes_3:= 0; n14_vtas_mes_4 := 0; n15_vtas_mes_5 := 0; n16_vtas_mes_6 := 0;
		
			select c3,c4,c5,c6,c7,c8 into n11_vtas_mes_1,n12_vtas_mes_2,n13_vtas_mes_3,n14_vtas_mes_4,n15_vtas_mes_5,n16_vtas_mes_6 from keplersc.kdinpdet 
			where c1 = v_sucursal_id and c2 = v_C1_Refaccion;
		
			n11_vtas_mes_1 := coalesce(n11_vtas_mes_1,0); n12_vtas_mes_2 := coalesce(n12_vtas_mes_2,0); n13_vtas_mes_3 := coalesce(n13_vtas_mes_3,0);
			n14_vtas_mes_4 := coalesce(n14_vtas_mes_4,0); n15_vtas_mes_5 := coalesce(n15_vtas_mes_5,0); n16_vtas_mes_6 := coalesce(n16_vtas_mes_6,0);
		
			-- Added Fixing JMM (K75 si las Inicializa, en K80 Faltaba)
		
		
			--seccion dos, 
			contador = 0;
			n3 = 0;
			if(n11_vtas_mes_1 > 0 ) then 
	 			contador = contador + 1;	 			
	 			if (n11_vtas_mes_1 > n3 ) then 
		 			n3 := n11_vtas_mes_1;
	 			end if;
			end if;
			if(n12_vtas_mes_2 > 0 ) then 
	 			contador = contador + 1;
		 		if (n12_vtas_mes_2 > n3 ) then 
		 			n3 := n12_vtas_mes_2;
	 			end if;
			end if;
			if(n13_vtas_mes_3 > 0 ) then 
	 			contador = contador + 1;
		 		if (n13_vtas_mes_3 > n3 ) then 
		 			n3 := n13_vtas_mes_3;
	 			end if;
			end if;
			if(n14_vtas_mes_4 > 0 ) then 
	 			contador = contador + 1;
		 		if (n14_vtas_mes_4 > n3 ) then 
		 			n3 := n14_vtas_mes_4;
	 			end if;
			end if;
			if(n15_vtas_mes_5 > 0 ) then 
	 			contador = contador + 1;
		 		if (n15_vtas_mes_5 > n3 ) then 
		 			n3 := n15_vtas_mes_5;
	 			end if;
			end if;
			if(n16_vtas_mes_6 > 0 ) then 
	 			contador = contador + 1;
		 		if (n16_vtas_mes_6 > n3 ) then 
		 			n3 := n16_vtas_mes_6;
	 			end if;
			end if;

		
			-- Added Fixing JMM (K75 si las Inicializa, en K80 Faltaba)
			--/*
			b1_MAD := 0;  b2_MIP := 0;  b3_Max_Fluctuacion_Demandada := 0;  b4_Vtas_Ult_Mes := 0;  b5_MAD_12_Meses := 0;
			b6 := 0;  b7 := 0;  b8 := 0;
			--*/	
			-- End Added 
		

			zone_tx := '';  -- Added 20231015 to implement calc by zone
		
			n4 = n16_vtas_mes_6; 
raise notice 'Hints:% ',contador;
			if(contador >= 3) then 
				r2_Phase := 'I';
raise notice 'r2_Phase:% ',r2_Phase;
				b1_MAD := ((n11_vtas_mes_1 + n12_vtas_mes_2 + n13_vtas_mes_3 + n14_vtas_mes_4 + n15_vtas_mes_5 + n16_vtas_mes_6) /  6);	
raise notice 'b1_MAD:% (Suma vtas_meses)/6 ',b1_MAD;		 	
				b6 := (((n3 * (v_c29_Probabilidad_Entrega / 100))-b1_MAD)/25);
				b7 := (( v_c28_Max_Fluctuacion_Tiempo-1 ) / 25);
				b8 := b6 + b7;
			
				-- code updated & added to implement calc by zones
				if vzones = 0 then
					-- Original Calc
					b2_MIP := ((b1_MAD * (v_c26_Ciclo_Ordenamiento + v_c27_Tiempo_Entrega + v_c30_Dias_Stock_Seguridad)) / 25);
raise notice 'Calc original, b2_MIP;% ',b2_MIP;
				else
				
					-- Calc by Zone
					zone_ss := -1;
				
					-- Se supone que Zona Dorada es el Mayor Rango
					-- Por ello no se usa Limite Superior 
raise notice 'Calcular ss y tx zona b1_MAD:%; dor_li:%; alt_li:%; alt_ls:%; baj_li:%; baj_ls:%; obs_li:%; obs_ls:%; ',
b1_MAD,dor_li,alt_li,alt_ls,baj_li,baj_ls,obs_li,obs_ls;
					if b1_MAD >= dor_li /*and b1_MAD <= dor_ls*/ then 
						zone_ss := dor_ss;
						zone_tx := 'Dorada';
					end if;
				
		
					if b1_MAD >= alt_li and b1_MAD <= alt_ls then
						zone_ss := alt_ss;
						zone_tx := 'Alto Movimiento';
					end if;
				
					if b1_MAD >= baj_li and b1_MAD <= baj_ls then 
						zone_ss := baj_ss;
						zone_tx := 'Lento Movimiento';
					end if;
				
					if b1_MAD >= obs_li and b1_MAD <= obs_ls then 
						zone_ss := obs_ss;
						zone_tx := 'Obsoleto';
					end if;
raise notice '	zone_ss:% ',zone_ss;
raise notice '	zone_tx:% ',zone_tx;
					if  zone_ss = -1 then
						r2_Phase := 'O';
raise notice '	r2_Phase:%; ',r2_Phase;
					end if;
					
					-- Condition Added 20240106 ... Evitar Inputs Negativos
					if r2_Phase <> 'O' then 
						b2_MIP := ((b1_MAD * (v_c26_Ciclo_Ordenamiento + v_c27_Tiempo_Entrega + zone_ss)) / 25);
raise notice 'Calculo MIP ((b1_MAD * (v_c26_Ciclo_Ordenamiento + v_c27_Tiempo_Entrega + zone_ss)) / 25)';
raise notice '	(% * (% + % + %)) / 25)=% ',b1_MAD,v_c26_Ciclo_Ordenamiento,v_c27_Tiempo_Entrega,zone_ss, b2_MIP;
					end if;
					
				end if;
			
				-- Condition Added 20240106 ... Evitar Inputs Negativos 
				if r2_Phase <> 'O' then
				    b2_MIP := ceiling(b2_MIP);
					--b2_MIP := ceil(b2_MIP);
				   	b3_Max_Fluctuacion_Demandada := n3;
	  			    b4_Vtas_Ult_Mes := N4;
	  			    b5_MAD_12_Meses := b1_MAD;
	  			else
	  				b1_MAD := 0;
				    b2_MIP := 0;
				   	b3_Max_Fluctuacion_Demandada := 0;
	  			    b4_Vtas_Ult_Mes := 0;
	  			    b5_MAD_12_Meses := 0;
	  			    zone_tx := '';
	  			end if;
	  			
			else
				r2_Phase := 'O';
			end if;
raise notice 'v_sucursal_id:%; v_C1_Refaccion:%; r2_Phase:%; b1_MAD:%; b2_MIP:%; b3_Max_Fluctuacion_Demandada:%; b4_Vtas_Ult_Mes:%; b5_MAD_12_Meses:%; zone_tx:%; ',
v_sucursal_id,v_C1_Refaccion,r2_Phase,b1_MAD,b2_MIP,b3_Max_Fluctuacion_Demandada,b4_Vtas_Ult_Mes,b5_MAD_12_Meses,zone_tx;
	    	insert into tmpkdinp (c1,c2,c3,c4,c5,c6,c7,c8,zona) 
	    	values(v_sucursal_id,v_C1_Refaccion,r2_Phase,b1_MAD,b2_MIP,b3_Max_Fluctuacion_Demandada,b4_Vtas_Ult_Mes,b5_MAD_12_Meses,zone_tx);
			--raise notice 'fin reg %',v_C1_Refaccion ;


			if r2_Phase = 'I' then
				select h.c1, h.c31 into v_field_key, v_h31_Unidades_Min_Pedido from keplersc.kdini h where h.c1 = v_C1_Refaccion;
				v_field_key := coalesce(v_field_key,'');
				if length(v_field_key) > 0 then
					v_field_key := '';
					c_n3_existencias = 0;
					select l.c2, (coalesce(l.c5,0) - coalesce(l.c6,0)) into v_field_key, c_n3_existencias from keplersc.kdinl l where l.c1 = v_sucursal_id and l.c2 = v_C1_Refaccion;
					v_field_key := coalesce(v_field_key,'');
					if length(v_field_key) = 0 then
						c_n3_existencias = 0;
					end if;
raise notice 'Existencias:%',c_n3_existencias;
					v_field_key := '';
					c_n4_backorder_salidas = 0;
					select i.c2, (coalesce(i.c3,0) - coalesce(i.c4,0)) into v_field_key, c_n4_backorder_salidas from keplersc.kdbol i where i.c1 = v_sucursal_id and i.c2 = v_C1_Refaccion;
					v_field_key := coalesce(v_field_key,'');
					if length(v_field_key) = 0 then
						c_n4_backorder_salidas = 0;
					end if;	
raise notice 'Backorder salidas:%',c_n4_backorder_salidas;

					if v_InvVirtual_A11 = 'S' then 
						c_n6_total_cantidad_paquetes = 0;			
						for v_oc2_folcita, v_oc7_marca, v_oc8_modelo in select c2,c7,c8 from keplersc.KDCTASSER where c1 = v_sucursal_id and c20 = 10 and to_date(c12::text,'YYYY-MM-DD')/*c12*/ > current_date  
						loop 
							for v_pc4_Cita_autorizada, v_pc6_Paquete in select c4,c6 from keplersc.KDCTASSERMOV where c1 = v_sucursal_id and c2 = v_oc2_folcita
							loop 
								if v_pc4_Cita_autorizada = 'S' then
									for v_qc7_cantidad_paquete in select c7 from	keplersc.KDSPAQM where c1 = v_oc7_marca and c2 = v_oc8_modelo and c4 = v_pc6_Paquete and c6 = v_C1_Refaccion 
									loop 
										c_n6_total_cantidad_paquetes = c_n6_total_cantidad_paquetes + coalesce(v_qc7_cantidad_paquete,0);
									end loop; 		
								end if;--end if S de v_pc4_Cita_autorizada
							end loop;--end de la tabla P KDCTASSERMOV
						end loop; --end de la tabla O KDCTASSER		
					end if;--end de v_InvVirtual_A11
raise notice 'Inventario virtual:%; Cantidad en Paquetes:%',v_InvVirtual_A11,c_n6_total_cantidad_paquetes;
					
					if v_Formula_A7 = 'Q' then			
						c_n1_cantidad_sugerida_stock = b1_MAD / 30 * (v_DiasVenBus_A4 + v_DelayTraslado_A5) - c_n3_existencias - c_n4_backorder_salidas + c_n6_total_cantidad_paquetes;
						if c_n1_cantidad_sugerida_stock <= 0 then
							c_n1_cantidad_sugerida_stock = 0; 
						end if;
raise notice 'Cantidad sugerida stock formula:% ; [b1_MAD / 30 * (v_DiasVenBus_A4 + v_DelayTraslado_A5) - c_n3_existencias - c_n4_backorder_salidas + c_n6_total_cantidad_paquetes], %', v_Formula_A7, c_n1_cantidad_sugerida_stock;	
					else
						c_n1_cantidad_sugerida_stock = b2_MIP - c_n3_existencias - c_n4_backorder_salidas + c_n6_total_cantidad_paquetes;
raise notice 'Cantidad sugerida stock formula:% ; [b2_MIP - c_n3_existencias - c_n4_backorder_salidas + c_n6_total_cantidad_paquetes], %', v_Formula_A7, c_n1_cantidad_sugerida_stock;	
						if c_n1_cantidad_sugerida_stock <= 0 then
							c_n1_cantidad_sugerida_stock = 0; 
						end if;
					end if;	
	
					c_n2 = c_n1_cantidad_sugerida_stock - trunc(c_n1_cantidad_sugerida_stock);
					c_n1_cantidad_sugerida_stock = trunc(c_n1_cantidad_sugerida_stock);
					if c_n2 >= .5 then
						c_n1_cantidad_sugerida_stock = c_n1_cantidad_sugerida_stock + 1; 
					end if;
raise notice 'Cantidad sugerida stock redondeada:% ',c_n1_cantidad_sugerida_stock;						
					if c_n1_cantidad_sugerida_stock > 0 then
						c_n5_cantidad_solicitada :=0;	
						if v_h31_Unidades_Min_Pedido > 0 then
							c_n5_cantidad_solicitada = round(c_n1_cantidad_sugerida_stock / v_h31_Unidades_Min_Pedido);
							c_n5_cantidad_solicitada = c_n5_cantidad_solicitada * v_h31_Unidades_Min_Pedido;
						end if; -- end de v_h31_Unidades_Min_Pedido
		
						v_field_key := '';
						v_k11_cantidad_especial = 0; --Es cero en general
						
			 			c_n5_cantidad_solicitada = c_n1_cantidad_sugerida_stock + coalesce(v_k11_cantidad_especial,0);
			 		
						if v_h31_Unidades_Min_Pedido > 0 then
							c_n5_cantidad_solicitada = round(c_n5_cantidad_solicitada / v_h31_Unidades_Min_Pedido);
							c_n5_cantidad_solicitada = c_n5_cantidad_solicitada * v_h31_Unidades_Min_Pedido;
						end if; -- end de v_h31_Unidades_Min_Pedido
raise notice 'Unidades minimas pedido:% ',v_h31_Unidades_Min_Pedido;
raise notice 'Cantidad solicitada:% ',c_n5_cantidad_solicitada;
raise notice 'Cantidad solicitada stock:% ',c_n5_cantidad_solicitada - coalesce(v_k11_cantidad_especial,0);
					end if; -- end de c_n1_cantidad_sugerida_stock > 0 
				end if; --end if de keplersc.kdini
			end if;
		end loop; --end loop 1 

		
	--end for 
		resultado ='1';
		mensaje ='Finalizado';
		adicionales ='';
	--raise notice 'Fin %' , (select clock_timestamp());

return query select resultado, mensaje, adicionales;

exception
	when others then
		resultado := 0;	
		mensaje := 'PedSug_MadMip() ' || '['|| sqlstate || '] ' || sqlerrm ;
		adicionales := '';
		return query select resultado, mensaje, adicionales;
END;
$function$
