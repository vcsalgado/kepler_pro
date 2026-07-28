CREATE OR REPLACE PROCEDURE keplersc.rutina_inv_vales2()
 LANGUAGE plpgsql
AS $procedure$
--Descripcion: corrige vales de salida inventarios
--Autor: Luis Leal
--Fecha: 12/06/2024
--Bitacora de cambios
declare 

	sucursal text;
	inv text;
	serie text;
	vale_salida text;
	fcha date;
	traspaso text;
	estatus_venta numeric;
	ult_vale text;
	estatus_previo numeric;
	dataxml text;

	tipo_auto text;
	vendedor text;
	cli text;
	monto numeric;
	coach text;
	nombre_cli text;
	calle_cli text;
	col_cli text;
	correo_cli text;
	altas_inv int;
	bajas_inv int;
	altas_inv2 int;
	bajas_inv2 int;
	mensaje text;


	--Variables de retorno desde funciones externas
	get_resultado text; --retorno
	get_mensaje text; --retorno
	get_adicionales text; --retorno
		
begin
	
	for sucursal, inv, serie,vale_salida , fcha, traspaso
	in select col_suc,col_inv,col_serie, col_vale_salida, col_fecha, col_traspaso
	from keplersc.tmp_inv_vales2 
	loop 
	
				
		if vale_salida = 'S' then
		
			raise notice '%, %', sucursal, inv;
			
			select c21 into tipo_auto 
			from keplersc.kdinf where c1=sucursal and c2=inv;
				
			if tipo_auto ='USADO' then
				tipo_auto = 'U';
			else
				tipo_auto = 'N';
			end if;
					
			select (select c2 from keplersc.kduv where c1 = p.c1 and c2 = p.c10) , p.c9,p.c14,
			(select c1 from keplersc.KDCATCOACH where c1 = p.c42), 
			(select k.c3 from keplersc.kdud k where k.c2 = p.c9),
			(select k.c4 from keplersc.kdud k where k.c2 = p.c9),
			(select k.c5 from keplersc.kdud k where k.c2 = p.c9),
			(select k.c11 from keplersc.kdud k where k.c2 = p.c9)   
			into vendedor, cli, monto, coach, nombre_cli, calle_cli, col_cli, correo_cli
			from keplersc.kdpedido p where p.c1 = sucursal and p.c2 = inv;
		
			if vendedor is null then
				vendedor = '';
			end if;
		
				
			dataxml := format('
			<document>
				<inp_titulo>Alta de Vale</inp_titulo>
				<k_sucn>
					<r1>%1$s</r1>
				</k_sucn>
				<grpDoc>Alta de Vale
					<r0>Alta de Vale</r0>
					<r1>N</r1>
					<r2>A</r2>
					<r3>13</r3>
					<r4>0</r4>
					<r5>0</r5>
					<r6>A</r6>
					<r7>30</r7>
					<r8>35</r8>
				</grpDoc>
				<k_tipon>Vale de salida
					<r0>Vale de salida</r0>
					<r1>N</r1>
					<r2>A</r2>
					<r3>13</r3>
					<r4>1</r4>
					<r5>NA13001-0000000</r5>
					<r6>16</r6>
				</k_tipon>
				<operacion>ALTA</operacion>
				<k_folio/>
				<k_docto>NA13001-0000000</k_docto>
				<k_fecha>%2$s</k_fecha>
				<statusDoc/>
				<k_inventario>%3$s</k_inventario>
				<k_tipo_auto>U
					<r0>%4$s</r0>
				</k_tipo_auto>
				<k_vendedor>%5$s</k_vendedor>
				<k_coach>
					<r2>%6$s</r2>
				</k_coach>
				<k_asesor_cc>SA
					<r0>SA</r0>
				</k_asesor_cc>
				<k_clave_cliente>%7$s</k_clave_cliente>
				<k_nombre_cliente>%8$s</k_nombre_cliente>
				<k_calle_numero>%9$s</k_calle_numero>
				<k_colonia>%10$s</k_colonia>
				<k_monto>%11$s</k_monto>
				<k_moneda>PESOS</k_moneda>
				<k_paridad>0</k_paridad>
				<k_clave>%7$s</k_clave>
				<k_refer>%3$s</k_refer>
				<k_fecref>%2$s</k_fecref>
				<k_rfc/>
				<k_plazo/>
				<k_nombreprov/>
				<k_calleprov/>
				<k_coloniaprov/>
				<k_poblacionprov/>
				<k_cpprov/>
				<k_cuenta>000000</k_cuenta>
				<movimiento>
					<usuario>ADMIN80</usuario>
					<fecha>%12$s</fecha>
					<hora>%13$s</hora>
				</movimiento>
				<ambiente>
					<anio_contable>24</anio_contable>
					<uen>VEN</uen>
				</ambiente>
				<k_natdocto>A</k_natdocto>
				<k_gpodocto>35</k_gpodocto>
				<k_tipodocto>1</k_tipodocto>
				<k_ivadesglosado>N</k_ivadesglosado>
				<k_nombreimprfact>%8$s</k_nombreimprfact>
				<k_claveinv>%3$s</k_claveinv>
				<k_tipopagos>0</k_tipopagos>
				<k_tipoauto>%4$s</k_tipoauto>
				<k_pedimento/>
				<k_status_validacion>1</k_status_validacion>
				<k_f_pago>
					<r1>0</r1>
				</k_f_pago>
				<k_mov>
					<no_partidas>0</no_partidas>
				</k_mov>
				<k_foliodocto>VXX0000000</k_foliodocto>
				<k_clavedepto>SA</k_clavedepto>
				<k_cfdi>G03</k_cfdi>
				<k_correo>%14$s</k_correo>
			</document>',
			sucursal,fcha,inv, tipo_auto,vendedor,coach,cli,nombre_cli, 
			calle_cli, col_cli,monto,current_date,  left(current_time::text,5),correo_cli);
		
			raise notice '%', dataxml;
				
			select COUNT(*) into altas_inv
			from keplersc.kdcomismov 
			where c1=sucursal and c10 = '0'  and c8=inv;
		
			select COUNT(*) into altas_inv2
			from keplersc.kdcomismov2 
			where c1=sucursal and c10 = '0'  and c8=inv;
				 			
			select COUNT(*) into bajas_inv
			from keplersc.kdcomismov 
			where  c1=sucursal and c10 = '1'  and c8=inv;
		
			select COUNT(*) into bajas_inv2
			from keplersc.kdcomismov 
			where  c1=sucursal and c10 = '1'  and c8=inv;
		
		
			select c32 into estatus_previo from keplersc.kdinf where c1=sucursal and c2=inv;

			mensaje := '';
			if altas_inv = bajas_inv then
			
				mensaje := 'IGUAL';
			
				--crear vale de salida
				select * into get_resultado, get_mensaje, get_adicionales from keplersc.verify_invalta(dataxml::xml);
				if get_resultado = '0' then
					raise notice '(verify_invalta) Error en inv: %', inv;
			
					update keplersc.tmp_inv_vales2 set col_mensaje_error=get_mensaje 
					where col_suc=sucursal and col_inv=inv;
					commit;
					continue;
				
				end if;		
			
				select * into get_resultado, get_mensaje, get_adicionales from keplersc.docdis(dataxml::xml);
				if get_resultado = '0' then
					raise notice '(docdis) Error en inv: %', inv;
							
					update keplersc.tmp_inv_vales2 set col_mensaje_error=get_mensaje 
					where col_suc=sucursal and col_inv=inv;
					commit;
					continue;
				
				end if;	
			
			elseif altas_inv < bajas_inv then
			
				mensaje := 'MENOS';

				--ajustar estatus

				estatus_venta := 60;

				if traspaso = 'S' then
					estatus_venta := 70;
				end if;
			
						
				if estatus_previo < 60 then
					update keplersc.kdinf set c32=estatus_venta where c1=sucursal and c2=inv;
				end if;
			
				select c6 into ult_vale from keplersc.kdcomismov
				where c1=sucursal and c8=inv and c10='1' order by c6 desc limit 1;
			
				update keplersc.kdcomismov set c10='0'
				where c1=sucursal and c8=inv and c6=ult_vale;
			
			
				if altas_inv <> altas_inv2 or bajas_inv <> bajas_inv2 then
								
					delete from keplersc.kdcomismov2 
					where c1=sucursal and c8=inv and c6=ult_vale;
				
					insert into keplersc.kdcomismov2
					select c1,c2,c3,c4,c5,c6,c7,c8,'' as c9,'0' as c10,c11 
					from keplersc.kdcomismov where c1=sucursal
					and c6=ult_vale and c8=inv ;
				
					mensaje := 'DATOS CORREGIDOS';

				else
				
					update keplersc.kdcomismov2 set c10='0' 
					where c1=sucursal and c8=inv and c6=ult_vale;

				end if;
				
				update keplersc.kdm1 set c43='' 
				where c1=sucursal and c2='N' and c3='A' and c4=13 and c5=1 and c6=ult_vale;
			
				commit;
			
		
			else 
			
				if estatus_previo >= 60 then
					mensaje := 'CORRECTO';
				end if;


			end if;
		
			
			update keplersc.tmp_inv_vales2 set col_mensaje_error=mensaje
			where col_suc=sucursal and col_inv=inv;
			commit;
		

		end if;	
		
	end loop;
	
		
	raise notice 'Proceso Terminado';
		
END;
$procedure$
