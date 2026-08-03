CREATE OR REPLACE PROCEDURE keplersc.ser_rutina_ords(sucursal text, fecha_ini date, fecha_fin date, usuario text)
 LANGUAGE plpgsql
AS $procedure$
	declare 
	--Descripcion: rutina sevicio
	--Autor: Luis Leal
	--Fecha: 25/04/2023
	--Bitacora de cambios
	
		--kdmargen--
		tipo_trabajo text;
	 	costo_m_obra text;
	 	costo_refs text;
		costo_tots text;
		costo_varios text;
	
		--kdmm--
		suc_kdmm text;
		gen_kdmm text;
		nat_kdmm text;
		gpo_kdmm numeric;
		tipo_kdmm numeric;
	
		--kdm1--
		gen text;
		nat text; 
		gpo numeric;
		tip numeric;
		fol text;
		monto_iva numeric;
		importe numeric;
	
		--bitacora--			
		xmlUsr xml;
		strValor text;
		strBitacora text;
		fecha_movto text;
		hora_movto text;
	
		get_resultado text;
		get_mensaje text; 
		get_adicionales text;
				 
	
	begin 
		 
		strBitacora := 'resta el iva del importe del movimiento';
		
		for tipo_trabajo in select c2 from keplersc.kdmargen 
			where c2= 'I' or c2='Q' or c2='P' or c2='R'
			loop 
							
				update keplersc.kdmargen set c5=0, c6=0, c7=0
				where c2=tipo_trabajo;
				
				select c10,c11,c12,c13 into costo_m_obra,costo_refs,
				costo_tots, costo_varios from keplersc.kdtallcont 
				where c1=tipo_trabajo and c2=sucursal and c3=substring(fecha_ini::text, 3,2);
				if found then
				
					update keplersc.kdtallcont set c5=costo_m_obra,
					c6=costo_refs, c7=costo_tots, c8=costo_varios
					where c1=tipo_trabajo and c2=sucursal and c3=substring(fecha_ini::text, 3,2);
				
				end if;
				
			end loop;
		
		
		for suc_kdmm,gen_kdmm,nat_kdmm,gpo_kdmm ,tipo_kdmm in select col_sucursal,c1,c2,c3,c4 
		from keplersc.kdmm where col_sucursal = sucursal and (c1='U' and c2='D' and c3='10') 
		or (c1='U' and c2='A' and c3='14') or (c1='U' and c2='A' and c3='24')
		loop 
			
			if (tipo_kdmm >= 3 and tipo_kdmm <=10) or tipo_kdmm=13 or tipo_kdmm=15 or tipo_kdmm=16 then 
						
				update keplersc.kdmm set c16=0, c21='' where col_sucursal=sucursal and c1=gen_kdmm
				and c2=nat_kdmm and c3=gpo_kdmm and c4=tipo_kdmm;
			
				for gen, nat, gpo, tip, fol, monto_iva, importe
				in select c2,c3,c4,c5,c6,c14,c16 from keplersc.kdm1 where c1=sucursal 
				and c2=gen_kdmm and c3=nat_kdmm and c4=gpo_kdmm and c5=tipo_kdmm 
				and c9 >= fecha_ini and c9 <=fecha_fin
				loop
							
					update keplersc.kdm1 set c16=importe-monto_iva, c14=0 where c1=sucursal 
					and c2=gen_kdmm and c3=nat_kdmm and c4=gpo_kdmm and c5=tipo_kdmm 
					and c9 >= fecha_ini and c9 <=fecha_fin;
				
					fecha_movto :=  current_date::text;
					hora_movto := left(current_time::text, 8);
					select xmlforest(usuario, fecha_movto as fecha, hora_movto as hora, 
					sucursal, gen as genero, nat as naturaleza, 
					gpo as grupo, tip as tipo, fol as folio,
					'RSTORDCOST' as tipo_movto, strBitacora as detalle_movto) :: text into strValor;		
					select '<document>'||strValor||'</document>' into strValor;
				
					xmlUsr := strValor::xml;
				
					raise notice 'Bitacora:%',xmlUsr;
				
					select * into get_resultado, get_mensaje, get_adicionales from keplersc.usr_kdusraccess_alta(xmlUsr);
				
				
					raise notice '%,%,%' , get_resultado, get_mensaje, get_adicionales;
				end loop;
			
			end if;
			
		end loop;
		
		
	EXCEPTION
		WHEN others THEN
			ROLLBACK;
			raise exception '%', SQLERRM;
		    
	end;
$procedure$
