CREATE OR REPLACE FUNCTION keplersc.cat_pedidosugerido_altamod_gensug_crud(dataxml xml)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$

--Descripcion: Cursores
--Autor: Saltiel Rc
--Fecha: 25/03/2022
--Bitacora de cambios
--RVW & Fixed By JMM 24/08/2023

declare

v_sucursal_id text = ''; --A1
v_referencia text = ''; --A6 
v_DiasVenBus_A4 text = '';
v_Formula_A7 text = '';
v_DelayTraslado_A5 text = '';
v_InvVirtual_A11 text ='';

v_N numeric = 0;
v_contador numeric = 0;

/*
v_k11 numeric = 0;
v_k14 numeric = 0;
v_k15 numeric = 0;
v_k16 numeric = 0;
v_k18 numeric = 0;
v_fc1 numeric = 0;
v_fc2 numeric = 0;
v_fc4 numeric = 0;
v_fc5 numeric = 0;
*/
-- Fixed by JMM , 20230824 
v_k11 decimal = 0.00;
v_k14 decimal = 0.00;
v_k15 decimal = 0.00;
v_k16 decimal = 0.00;
v_k18 decimal = 0.00;
v_fc4 decimal = 0.00;
v_fc5 decimal = 0.00;
v_fc1 text = '';
v_fc2 text = '';
-- End Fixed

v_oc2 text = '';
v_oc7 text = '';
v_oc8 text = '';
v_pc4 text = '';
v_pc6 text = '';

/*
v_qc7 numeric = 0;
c_n1 numeric = 0;
c_n2 numeric = 0;
c_n3 numeric = 0;
c_n4 numeric = 0;
c_n5 numeric = 0;
c_n6 numeric = 0;
c_n7 numeric = 0;
c_n8 numeric = 0;
c_n9 numeric = 0;
v_h31 numeric = 0;
*/
-- Fixed by JMM , 20230824 
v_qc7 decimal = 0.00;
c_n1 decimal = 0.00;
c_n2 decimal = 0.00;
c_n3 decimal = 0.00;
c_n4 decimal = 0.00;
c_n5 decimal = 0.00;
c_n6 decimal = 0.00;
c_n7 decimal = 0.00;
c_n8 decimal = 0.00;
c_n9 decimal = 0.00;
v_h31 decimal = 0.00;
-- End Fixed 

resultado text= '';
mensaje text = '0';
adicionales text = '';
totreg int = 0;
strtTexto text ='';
v_nocatalogo text =''; 

--Added by JMM 
jc9 text = '';
jc10 decimal = 0.00;
v_field_key text = '';
jc2 text = '';
jc3 text = '';
jc4 numeric = 0;
jc5 numeric = 0;
jc6 text = '';
jc7 numeric = 0;
jc8 timestamp;

get_resultado text; --retorno
get_mensaje text; --retorno
get_adicionales text; --retorno

begin
	
	v_sucursal_id := upper((xpath('//document/k_sucn/text()', dataxml))[1]::text); --
	v_referencia := upper((xpath('//document/k_referencia_a6/text()', dataxml))[1]::text); --	
	v_DiasVenBus_A4:= upper((xpath('//document/k_diasvenbus_a4/text()', dataxml))[1]::text); --
	v_DelayTraslado_A5:= upper((xpath('//document/k_delaytraslado_a5/text()', dataxml))[1]::text); --
	v_Formula_A7:= upper((xpath('//document/k_formula_a7/text()', dataxml))[1]::text); --
	v_InvVirtual_A11:= upper((xpath('//document/k_invvirtual_a11/text()', dataxml))[1]::text); --
	
	v_N = 0;

	-- JMM ... se cambiara de ubicacion al final para determinar si el proceso corrio bien ... se pretende ligar 
	-- a este proceso la creacion del ENC en el proceso : cat_pedidosugerido_altamod_insert_crud  
	/*
	resultado ='1';
	mensaje ='Iniciado';
	adicionales ='';
	*/

	-- UPD ST de KDPEDIDOSUGERIDOCONF para el CTRL de la corrida del Proceso ... En Proceso
	update keplersc.KDPEDIDOSUGERIDOCONF set c6 = 1 where c1 = v_sucursal_id;

	--raise notice '%','Paso UPD KDPEDIDOSUGERIDOCONF set c6 = 1'; 

	-- Obtiene pedidos especiales 
	if ( (select count(*) from keplersc.KDPEDESP where c1=v_sucursal_id and c13 = 10) > 0 ) then  --1 
	
		-- JMM, esto esta mal, se requiere tener un FOR LOOP que haga el barrido de los Registros 
		/*
		if(select c9 as jc9, c10 as jc10 from keplersc.KDPEDESP where c1 = v_sucursal_id and c13 = 10 order by c8 desc ) then 
		--c9 = h1
		*/
		for jc9,jc10,jc2,jc3,jc4,jc5,jc6,jc7,jc8 in select c9,c10,c2,c3,c4,c5,c6,c7,c8 from keplersc.kdpedesp where c1 = v_sucursal_id and c13 = 10 /*order by c8 desc*/
		loop
		
			-- Code Added by JMM to FIX 
			v_field_key := '';	
			select h.c1, h.c31 into v_field_key, v_h31 from keplersc.kdini h where h.c1 = jc9;
			v_field_key := coalesce(v_field_key,'');
			if length(v_field_key) > 0 then
			
			-- Err Code , Cmnt by JMM 20230824 
			--if(select c31 as hc31 from keplersc.kdini where c1 = jc9 /*c9*/) then 
			
				-- UPD Var by JMM 20230824 
				if( (select count(*) from keplersc.KDPEDREFMOV where c1 = v_sucursal_id and c2 = v_referencia and c3 = jc9 /*c9*/) = 0 ) then 
				
					insert into keplersc.KDPEDREFMOV (c1,c2,c3) values (v_sucursal_id, v_referencia, jc9);
					v_N = v_N + 1;
				
				end if;	
				
				-- Err Code , Cmnt by JMM 20230824
				/*
				if((select c5 as v_k14 from keplersc.KDINP where c1 = v_sucursal_id and c2 = jc9) > 0) then 
					v_k14 = c5;
				else 
					v_k14 = 0;
				end if ;
				*/
			
				-- Code Added by JMM to FIX 
				v_field_key := '';
				v_k14 = 0;
				select f.c2, f.c5 into v_field_key, v_k14 from keplersc.kdinp f where f.c1 = v_sucursal_id and f.c2 = jc9;
				v_field_key := coalesce(v_field_key,'');
				if length(v_field_key) = 0 then
					v_k14 = 0;
				end if;
			
				-- Err Code , Cmnt by JMM 20230824
				/*
				if ((select (c5-c6) as k15  from keplersc.KDINL where c1 = v_sucursal_id and c2 = jc9)) then 
				   v_k15 = k15 ;
				else 
					v_k15 =0;				  
				end if;
				*/
			
				-- Code Added by JMM to FIX 
				v_field_key := '';
				v_k15 = 0;
				select l.c2, (coalesce(l.c5,0) - coalesce(l.c6,0)) into v_field_key, v_k15 from keplersc.kdinl l where l.c1 = v_sucursal_id and l.c2 = jc9;
				v_field_key := coalesce(v_field_key,'');
				if length(v_field_key) = 0 then
					v_k15 = 0;
				end if;
				
				-- Err Code , Cmnt by JMM 20230824
				/*
				if ((select (c3-c4) as k16 from keplersc.KDBOL  where c1 = v_sucursal_id and c2 = jc9)) then 
				   v_k16 = k16 ;
				else 
					v_k16 =0;				  
				end if;
				*/
			
				-- Code Added by JMM to FIX 
				v_field_key := '';
				v_k16 = 0;
				select i.c2, (coalesce(i.c3,0) - coalesce(i.c4,0)) into v_field_key, v_k16 from keplersc.kdbol i where i.c1 = v_sucursal_id and i.c2 = jc9;
				v_field_key := coalesce(v_field_key,'');
				if length(v_field_key) = 0 then
					v_k16 = 0;
				end if;		
			
				-- Err Code , Cmnt by JMM 20230824
				--v_h31 = hc31;
			
				update keplersc.KDPEDREFMOV 
				set c10 = 10, 
					/*c11 = jc10,*/ -- Fixed
					c11 = coalesce(c11,0) + jc10,
					/*c13 = hc31,*/ -- Fixed
					c13 = v_h31,
					c14 = v_k14,
					--c15 & c16 Added by JMM
					c15 = v_k15,
					c16 = v_k16,
					/*c18 = (select (c18 + jc10) from keplersc.KDPEDREFMOV  where c1 = v_sucursal_id and c2 = v_referencia and c3 = jc9)*/
					-- Fixed
					c18 = coalesce(c18,0) + jc10
				where c1 = v_sucursal_id and c2 = v_referencia and c3 = jc9;
					
				-- Code Moved and Fixed by JMM ... 20230824 , ver nota en mismo segmento comentado abajo 
				update keplersc.kdpedesp
				set c13 = 20,
					c14 = v_sucursal_id,
					c15 = v_referencia 		
				-- Err Code , Cmnt by JMM 20230824
				--where c1 = v_sucursal_id and c13 = 10 and c9 = jc9;
				-- Code Added by JMM to FIX
				where c1 = v_sucursal_id and c13 = 10  
					and c9 = jc9 and c2 = jc2 and c3 = jc3 and c4 = jc4 
					and c5 = jc5 and c6 = jc6 and c7 = jc7 and c8 = jc8;
					
			end if;-- fin de Kdini
			
			-- Code Moved Up and Fixed by JMM ... 20230824, Se supone que debe quedar saldado si se 
			-- agrego al pedido sugerido 
			/*
			update keplersc.KDPEDESP
			set c13 = 20,
				c14 = v_sucursal_id,
				c15 = v_referencia 			
			where c1=v_sucursal_id and c13 = 10 and c9 = jc9;
			*/
		
		-- JMM, esta estructura se cambio por estar mal conceptualizada
		/*
		end if; --fin de kdpedesp
		*/
		end loop;
		
	end if; --1 fin de pedidos especiales 
	
	--raise notice '%','Paso Proc pedidos especiales';

	-- Obtener pedido stock	
	for v_fc1,v_fc2,v_fc4,v_fc5 in select c1,c2,c4,c5 from keplersc.kdinp where c1 = v_sucursal_id and c3 = 'I' 
	loop      --loop 1 raise notice 'Registro %' , v_C1;
		
		/*
		if((select c1 from keplersc.kdini
			where c1 = (select c2 from keplersc.kdinp where c1 = v_sucursal_id and  c3 = 'I' and c2 = v_fc2))) then
		*/
	
		-- Code Added by JMM to FIX 
		v_field_key := '';	
		select h.c1, h.c31 into v_field_key, v_h31 from keplersc.kdini h where h.c1 = v_fc2;
		v_field_key := coalesce(v_field_key,'');
		if length(v_field_key) > 0 then
		
		
			-- Code Segment Added by JMM to FIX  ( This code not exists )
		
			-- Code Added by JMM to FIX 
			v_field_key := '';
			c_n3 = 0;
			select l.c2, (coalesce(l.c5,0) - coalesce(l.c6,0)) into v_field_key, c_n3 from keplersc.kdinl l where l.c1 = v_sucursal_id and l.c2 = v_fc2;
			v_field_key := coalesce(v_field_key,'');
			if length(v_field_key) = 0 then
				c_n3 = 0;
			end if;
		
			-- Code Added by JMM to FIX 
			v_field_key := '';
			c_n4 = 0;
			select i.c2, (coalesce(i.c3,0) - coalesce(i.c4,0)) into v_field_key, c_n4 from keplersc.kdbol i where i.c1 = v_sucursal_id and i.c2 = v_fc2;
			v_field_key := coalesce(v_field_key,'');
			if length(v_field_key) = 0 then
				c_n4 = 0;
			end if;	
			
			-- End Code Segment Added by JMM 
		
			--raise notice '%','obtener pedido stock.code added by JMM';
		
			if v_InvVirtual_A11 = 'S' then 
			
				c_n6 = 0;			
			
				for v_oc2, v_oc7, v_oc8 in select c2,c7,c8 from keplersc.KDCTASSER where c1 = v_sucursal_id and c20 = 10 and to_date(c12::text,'YYYY-MM-DD')/*c12*/ > current_date  
				loop 
					
					for v_pc4, v_pc6 in select c4,c6 from keplersc.KDCTASSERMOV where c1 = v_sucursal_id and c2 = v_oc2
					loop 
						
						if v_pc4 = 'S' then
						
							for v_qc7 in select c7 from	keplersc.KDSPAQM where c1 = v_oc7 and c2 = v_oc8 and c4 = v_pc6 and c6 = v_fc2 
							loop 
								c_n6 = c_n6 + coalesce(v_qc7,0);
							end loop; 		
														
						end if;--end if S de v_pc4
								
					end loop;--end de la tabla P KDCTASSERMOV
												
				end loop; --end de la tabla O KDCTASSER		
						
			end if;--end de v_InvVirtual_A11
			
			if v_Formula_A7 = 'Q' then			
				c_n1 = v_fc4 / 30 * (v_DiasVenBus_A4 + v_DelayTraslado_A5) - c_n3 - c_n4 + c_n6;
			else
				c_n1 = v_fc5 - c_n3 - c_n4 + c_n6;
			end if;	
		
			if c_n1 <= 0 then
				c_n1 = 0; 
			end if;
		
			--c_n2 = c_n1 - round(c_n1);
			c_n2 = c_n1 - trunc(c_n1);
			--c_n1 = round(c_n1);
			c_n1 = trunc(c_n1);
			if c_n2 >= .5 then
				c_n1 = c_n1 + 1; 
			end if;
			
			-- To Check Values ... 
			/*
			if v_fc2 in ( 
			'122740'
			, '121730'
			, '85212YZZ1BTM'
			, '852140D121'
			, '852140R040'
			, '90916T2047'
			, 'G92DH12050'
			, 'G92DH42010' 
			, '0400218342' -- to check this (vs k75) ... sale por el ajuste que se hizo en Tipos de Datos en TBL 
			) then
				raise notice '%''%''%''%''%''%''%''%','Antes del IF c_n1 > 0',v_fc2, c_n1, c_n2, v_fc5, c_n3, c_n4, c_n6;
			end if;
			*/
		
			if c_n1 > 0 then	
			
				if ( (select count(*) from keplersc.KDPEDREFMOV where c1 = v_sucursal_id and c2 = v_referencia and c3 = v_fc2) = 0 ) then
					
					insert into keplersc.KDPEDREFMOV (c1,c2,c3) values (v_sucursal_id,v_referencia,v_fc2);
					v_N = v_N + 1;
				
				end if; -- fin de consulta 
				
				-- Este Codigo esta en K75, No tienen razon de ser porque se rescribe (recalcula) inmediatamente despues 
				if v_h31 > 0 then
					c_n5 = round(c_n1 / v_h31);
					c_n5 = c_n5 * v_h31;
				end if; -- end de v_h31
				
				-- Code cmnt by JMM 20230824 
				--v_k11 = (select c11 from keplersc.KDPEDREFMOV where c1 = v_sucursal_id and c2 = v_referencia and c3 = v_fc2);
				
				-- Code Added by JMM to FIX 
				v_field_key := '';
				v_k11 = 0;
				select k.c3, k.c11 into v_field_key, v_k11 from keplersc.kdpedrefmov k where k.c1 = v_sucursal_id and k.c2 = v_referencia and k.c3 = v_fc2;
				v_field_key := coalesce(v_field_key,'');
				if length(v_field_key) = 0 then
					v_k11 = 0;
				else 
					v_k11 = coalesce(v_k11,0);
				end if;	
				
	 			c_n5 = c_n1 + coalesce(v_k11,0);
	 		
				if v_h31 > 0 then
					c_n5 = round(c_n5 / v_h31);
					c_n5 = c_n5 * v_h31;
				end if; -- end de v_h31
				
								
				update keplersc.KDPEDREFMOV 
				set c10 = 10,
					c12 = c_n1,
					c13 = v_h31,
					c14 = v_fc5/*c_fc5*/,
					c15 = c_n3,
					c16 = c_n4,
					c17 = (c_n5 - coalesce(v_k11,0)),
					c18 = c_n5,
					c20 = c_n6				
				where c1 = v_sucursal_id and 
					  c2 = v_referencia and 
					  c3 = v_fc2; 	
					 
			end if; -- end de c_n1 > 0 
		
		end if; --end if de keplersc.kdini
			
	end loop;--end for obtener pedido stock 
	
	--raise notice '%','obtener pedido stock';
	
	-- UPD ST de KDPEDIDOSUGERIDOCONF para el CTRL de la corrida del Proceso ... Finalizado 
	update keplersc.KDPEDIDOSUGERIDOCONF set c6 = 0 where c1 = v_sucursal_id;

	--raise notice '%','Paso UPD KDPEDIDOSUGERIDOCONF set c6 = 0';
	
	if v_N <= 0 then
	
		-- Code commented / adapted by JMM IF is included execution of 
		-- {cat_pedidosugerido_altamod_insert_crud} 
		-- below in {else} section   
		/*
		resultado ='0';
		mensaje ='El pedido sugerido no genero ninguna sugerencia y la referencia ya fue marcada como eliminada.';
		adicionales ='El pedido sugerido no genero ninguna sugerencia y la referencia ya fue marcada como eliminada.';
			update keplersc.KDPEDREF
			set c4 = 0 
			where c1= v_sucursal_id
			and c2 = v_referencia;
		*/
	
		resultado ='0';
		mensaje ='El pedido sugerido no genero ninguna sugerencia, la referencia no se registro.';
		adicionales ='El pedido sugerido no genero ninguna sugerencia, la referencia no se registro.';
	
		raise exception '%', mensaje;
	
	-- Code Segment {else} Added by JMM , 20230824
	else
	
		-- Aqui yo incluiria la creacion del ENC 
		select * into get_resultado, get_mensaje, get_adicionales 
		from keplersc.cat_pedidosugerido_altamod_insert_crud(dataxml);
		
		if get_resultado = '0' then
			raise exception '%', get_mensaje;
		end if;
		
	
		resultado ='1';
		mensaje ='Procesos Finalizados';
		adicionales ='';
	-- End Code Segment {else} Added

	end if;
	
	--raise notice '%','Procesos Completados ...';

	return query select resultado, mensaje, adicionales;

exception
	when others then
		resultado := 0;	
		mensaje := 'cat_pedidosugerido_altamod_gensug_crud() ' || '['|| sqlstate || '] ' || sqlerrm ;
		adicionales := '';
		return query select resultado, mensaje, adicionales;
	
end;
$function$
