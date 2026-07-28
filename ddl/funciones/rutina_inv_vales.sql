CREATE OR REPLACE PROCEDURE keplersc.rutina_inv_vales()
 LANGUAGE plpgsql
AS $procedure$
--Descripcion: corrige estatus vales de salida
--Autor: Luis Leal
--Fecha: 31/05/2024
--Bitacora de cambios
declare 

	sucursal text;
	inv text;
	serie text;
	vale_salida text;
	traspaso text;
	estatus_venta numeric;
	ult_vale text;
	estatus_previo numeric;
		
begin
	
	for sucursal, inv, serie,vale_salida ,traspaso
	in select col_suc,col_inv,col_serie, col_vale_salida, col_traspaso
	from keplersc.tmp_inv_vales
	loop 
			
		estatus_venta := 60;
	
		if vale_salida = 'S' then
		
			if traspaso = 'S' then
				estatus_venta := 70;
			end if;
		
			select c32 into estatus_previo from keplersc.kdinf where c1=sucursal and c2=inv;
					
			if estatus_previo < 60 then
				update keplersc.kdinf set c32=estatus_venta where c1=sucursal and c2=inv;
			end if;
		
			select c6 into ult_vale from keplersc.kdcomismov
			where c1=sucursal and c8=inv and c10='0' order by c6 desc limit 1;
				
			update keplersc.kdm1 set c43='' 
			where c1=sucursal and c2='N' and c3='A' and c4=13 and c5=1 and c6=ult_vale;
			
		end if;	
		
	end loop;
	
		
	raise notice 'Proceso Terminado';
		
END;
$procedure$
