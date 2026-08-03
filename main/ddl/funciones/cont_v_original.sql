CREATE OR REPLACE FUNCTION keplersc.cont_v_original(xmlkdm1 xml, xmlkdmm xml, identificador_columna text)
 RETURNS xml
 LANGUAGE plpgsql
AS $function$
declare 
--Descripcion: 
--Autor: Saltiel Cruz
--Fecha: 19/10/2022
 
	--Variables de definicion de documento
	sucursal_id text = '';
	genero text = '';
	naturaleza text = '';
	grupo text = '';
	tipo text = '';
	
	--Variables de uso general
	expSql text;
 	strValor text = '';
    strValor2 text = '';
 	totReg	int;
 	str_usuario text;	
 	v_N1 numeric = 0;
	v_NumCol_CtaCont numeric = 0; --numero de cuenta
	v_numcam_a_aniadir_CtaPrincipal int = 0;--campo a concatenar
		
	v_numero_cuenta text = '';
	v_descripcion_cuenta text = '';
	v_monto text = '0';
	v_auxSql text = '';
	v_anio text ='';	
	xmlResult text;
	--Variables de retorno
	resultado text;
	mensaje text;
	adicionales text;
	strMonto text = '';
	strValorB text ='';
	cuenta text = '';
	cuenta_cargo text = '';
	cuenta_abono text = '';
	cuenta_iva text = '';
	cuenta_iva_cmp_isan text = '';
	cuenta_cargo_iva_anticipo text = '';
	cuenta_abono_iva_anticipo text = '';
	cuenta_cargo_anticipo text = '';
	cuenta_abono_anticipo text = '';
	cuenta_cargo_costo text = '';
	cuenta_abono_costo text = '';
	cuenta_extra_1 text = ''; 
	cuenta_extra_2 text = '';
	cuenta_extra_3 text = '';
	cuenta_extra_4 text = '';
	cuenta_extra_5 text = '';
	cuenta_extra_6 text = '';
	cuenta_extra_7 text = '';
	cuenta_extra_8 text = '';	
	cuenta_extra_9 text = '';
	cuenta_extra_10 text = '';
	descripcion_partida text = '';
	descripcion_cuenta text = '';
	monto_partida decimal = 0.00;
	monto_descuento decimal = 0.00;
	monto_iva decimal = 0.00;
	monto_ieps decimal = 0.00;
	monto_total decimal = 0.00;
	monto_sin_iva decimal = 0.00;
	monto_cargo decimal = 0.00;
	monto_abono decimal = 0.00;
	monto_isan_ieps decimal = 0.00;
	monto_extra_1 decimal = 0.00;
	monto_extra_2 decimal = 0.00;
	monto_extra_3 decimal = 0.00;
	monto_extra_4 decimal = 0.00;
	monto_extra_5 decimal = 0.00;
	monto_extra_6 decimal = 0.00;
	monto_extra_7 decimal = 0.00;
	monto_extra_8 decimal = 0.00;
	monto_extra_9 decimal = 0.00;
	monto_extra_10 decimal = 0.00;
	monto_anticipos decimal = 0.00;
	costo decimal = 0.00;
	monto_iva_anticipo decimal = 0.00;
	porcentaje_iva_kdmm decimal = 16.00;
	v_inventario text = '';
	v_descripcion_cuenta_1 text = '';
	v_condicion text = '';
begin
	
	sucursal_id := (xpath('//row/c1/text()',xmlKDM1))[1];
	genero := (xpath('//row/c2/text()',xmlKDM1))[1];
	naturaleza := (xpath('//row/c3/text()',xmlKDM1))[1];
	grupo := (xpath('//row/c4/text()',xmlKDM1))[1];
	tipo := (xpath('//row/c5/text()',xmlKDM1))[1];
	v_monto := (xpath('//row/c16/text()',xmlKDM1))[1];
	strValor := (xpath('//row/c90/text()', xmlKDMM))[1];
	
	if strValor is not null then
		if strValor = 'S' then
			mensaje := 'Documento no válido';
			raise exception '%',mensaje;			
		end if;
	end if;

	strMonto := coalesce((xpath('//row/c13/text()', xmlkdm1))[1]::text,'0.00')::text;
	monto_descuento:=strMonto::decimal;
	strMonto := coalesce((xpath('//row/c14/text()', xmlkdm1))[1]::text,'0.00')::text; 	
	monto_iva := strMonto::decimal;
	strMonto := coalesce((xpath('//row/c15/text()', xmlkdm1))[1]::text,'0.00')::text; 			
	monto_ieps := strMonto::decimal;
	strMonto := coalesce((xpath('//row/c16/text()', xmlkdm1))[1]::text,'0.00')::text; 
	monto_total := strMonto::decimal;
	monto_sin_iva = monto_total - monto_iva;	

	strMonto := coalesce((xpath('//row/c51/text()', xmlkdm1))[1]::text,'0.00')::text;
	monto_extra_1 := StrMonto::decimal;
	strMonto := coalesce((xpath('//row/c52/text()', xmlkdm1))[1]::text,'0.00')::text;
	monto_extra_2 := StrMonto::decimal;
	strMonto := coalesce((xpath('//row/c53/text()', xmlkdm1))[1]::text,'0.00')::text;
	monto_extra_3 := StrMonto::decimal;
	strMonto := coalesce((xpath('//row/c54/text()', xmlkdm1))[1]::text,'0.00')::text;
	monto_extra_4 := StrMonto::decimal;
	strMonto := coalesce((xpath('//row/c55/text()', xmlkdm1))[1]::text,'0.00')::text;
	monto_extra_5 := StrMonto::decimal;
	strMonto := coalesce((xpath('//row/c56/text()', xmlkdm1))[1]::text,'0.00')::text;
	monto_extra_6 := StrMonto::decimal;
	strMonto := coalesce((xpath('//row/c57/text()', xmlkdm1))[1]::text,'0.00')::text;
	monto_extra_7 := StrMonto::decimal;
	strMonto := coalesce((xpath('//row/c58/text()', xmlkdm1))[1]::text,'0.00')::text;
	monto_extra_8 := StrMonto::decimal;
	strMonto := coalesce((xpath('//row/c59/text()', xmlkdm1))[1]::text,'0.00')::text;
	monto_extra_9 := StrMonto::decimal;
	strMonto := coalesce((xpath('//row/c60/text()', xmlkdm1))[1]::text,'0.00')::text;
	monto_extra_10 := StrMonto::decimal;
	
	if (xpath('//row/c6/text()', xmlKDMM))[1]::text = 'S' then
			
	 		if identificador_columna = 'c19' then
		 		strValor2 := 'C';
	 		end if;
	 		if identificador_columna = 'c20' then
		 		strValor2 := 'A';
	 		end if;
	 		
	 		if identificador_columna = 'c21' or identificador_columna = 'c22' or 
	 			identificador_columna = 'c34' or identificador_columna = 'c35'  then
				--raise notice '2 identificador_columna %',strValor2;	
	 			if naturaleza = 'D' then 
					strValor2 := 'A';
				else
					strValor2 := 'C';
				end if;				 				
			end if;		
			if identificador_columna = 'c22' then 	
				if (xpath('//row/c30/text()', xmlKDMM))[1]::text <> 'S' then
					--strValor2 se queda como está
				else
					if strValor2 = 'C' then 
						strValor2 := 'A';
					else
						strValor2 := 'C';
					end if;
				end if;  --end
			end if;
		
			strValor := (xpath('//row/c16/text()', xmlKDMM))[1]::text;
			if strValor is not null and strValor <> '0' then
				porcentaje_iva_kdmm = strValor::decimal;
			end if;		 
			strMonto := coalesce((xpath('//row/c15/text()', xmlkdm1))[1]::text,'0.00')::text;
			monto_isan_ieps := StrMonto::decimal;
			
			if naturaleza = 'D'  then
				monto_cargo := monto_total::decimal;
					if strValor2 = 'A' then 
						monto_cargo := monto_total - monto_iva - monto_isan_ieps;	
					end if;
			else --Naturaleza <> 'D'
				strValor:=coalesce((xpath('//row/c30/text()', xmlKDMM))[1]::text,''); --Divide la cta de IVA en cuentas complemetarias				
				if strValor <> 'S' then --Divide IVA en ctas complementarias
					monto_cargo := monto_total - monto_iva - monto_isan_ieps;				
				else 				
					monto_cargo := monto_total - monto_isan_ieps;
				end if;						
			end if;		
			
		
			if identificador_columna = 'c19' then 
				v_NumCol_CtaCont = '19'; v_numcam_a_aniadir_CtaPrincipal = 25;			
			end if;	
			if identificador_columna = 'c20' then 
				v_NumCol_CtaCont = '20'; v_numcam_a_aniadir_CtaPrincipal = 26;								
			end if;	
			if identificador_columna = 'c22' then 
				v_NumCol_CtaCont = '22'; v_numcam_a_aniadir_CtaPrincipal = 31;
				monto_cargo := monto_isan_ieps;
			end if;	
			if identificador_columna = 'c21' then 
				v_NumCol_CtaCont = '21'; v_numcam_a_aniadir_CtaPrincipal = 30;
				monto_cargo := monto_iva;
			end if;
			if identificador_columna = 'c34' then
				v_NumCol_CtaCont = '34'; v_numcam_a_aniadir_CtaPrincipal = 56;
			end if;
			if identificador_columna = 'c35' then 
				v_NumCol_CtaCont = '35'; v_numcam_a_aniadir_CtaPrincipal = 57;
			end if;	
		
		
			select * into resultado,mensaje,v_numero_cuenta,v_descripcion_cuenta from keplersc.verify_cont_format(xmlKDM1,xmlKDMM,v_NumCol_CtaCont::int,v_numcam_a_aniadir_CtaPrincipal::int,'0');			
			
			--v_descripcion_cuenta_1 = v_descripcion_cuenta;	
			v_descripcion_cuenta_1 = (xpath('//row/c133/text()',xmlKDM1))[1]::text || '/' || (xpath('//row/c32/text()',xmlKDM1))[1]::text;
			v_descripcion_cuenta_1 = replace(v_descripcion_cuenta_1, '&', '-');
			if v_NumCol_CtaCont::int = 19 then
				--if uen = 'VEN' then
				v_condicion := (xpath('//row/c25/text()',xmlKDMM))[1]::text;--raise notice '19 v_condicion %',v_condicion;
				if v_condicion::numeric < 0 then 
						--raise notice 'resultado c26 %', v_descripcion_cuenta_1;
					 	v_inventario := (xpath('//row/c100/text()',xmlKDM1))[1]::text;
					 	v_inventario := (select substring(v_inventario,1,4)) || (select substring(v_inventario,8,1)) || '/' || 
									(right(v_inventario, length(v_inventario)-(length(v_inventario)-2)));
					 	--raise notice 'v_inventario %', v_inventario;
						v_numero_cuenta = v_numero_cuenta ||'-'|| v_inventario;
						v_descripcion_cuenta = (xpath('//row/c133/text()',xmlKDM1))[1]::text; 
						v_descripcion_cuenta_1 = (xpath('//row/c133/text()',xmlKDM1))[1]::text || '/' || (xpath('//row/c32/text()',xmlKDM1))[1]::text;
				end if;
			   	if v_condicion::numeric = 0 then 
				   	--v_descripcion_cuenta = (xpath('//row/c32/text()',xmlKDM1))[1]::text; 
					--v_descripcion_cuenta_1 = (xpath('//row/c32/text()',xmlKDM1))[1]::text;			   		
			   	end if ;
			   if v_condicion::numeric > 0 then 
			   		v_inventario := (xpath('//row/c10/text()',xmlKDM1))[1]::text;
			   		v_numero_cuenta = v_numero_cuenta ||'-'|| v_inventario;
				   	--v_descripcion_cuenta = (xpath('//row/c32/text()',xmlKDM1))[1]::text; 
					--v_descripcion_cuenta_1 = (xpath('//row/c32/text()',xmlKDM1))[1]::text;
			   	end if ;
			end if;
			if v_NumCol_CtaCont::int = 20 then
				--if uen = 'VEN' then
				v_condicion := (xpath('//row/c26/text()',xmlKDMM))[1]::text;--raise notice '20 v_condicion %',v_condicion;
				if v_condicion::numeric < 0 then 
						--raise notice 'resultado c26 %', v_descripcion_cuenta_1;
					 	v_inventario := (xpath('//row/c100/text()',xmlKDM1))[1]::text;
					 	v_inventario := (select substring(v_inventario,1,4)) || (select substring(v_inventario,8,1)) || '/' || 
									(right(v_inventario, length(v_inventario)-(length(v_inventario)-2)));
					 	--raise notice 'v_inventario %', v_inventario;
						v_numero_cuenta = v_numero_cuenta ||'-'|| v_inventario;
						v_descripcion_cuenta = (xpath('//row/c133/text()',xmlKDM1))[1]::text; 
						v_descripcion_cuenta_1 = (xpath('//row/c133/text()',xmlKDM1))[1]::text || '/' || (xpath('//row/c32/text()',xmlKDM1))[1]::text;
				end if;
		   		if v_condicion::numeric = 0 then  
				   	--v_descripcion_cuenta = (xpath('//row/c32/text()',xmlKDM1))[1]::text; 
					--v_descripcion_cuenta_1 = (xpath('//row/c32/text()',xmlKDM1))[1]::text;
			   	end if ;
			    if v_condicion::numeric > 0 then 
			   	    v_inventario := (xpath('//row/c10/text()',xmlKDM1))[1]::text;
			   		v_numero_cuenta = v_numero_cuenta ||'-'|| v_inventario;
				   	--v_descripcion_cuenta = (xpath('//row/c32/text()',xmlKDM1))[1]::text; 
					--v_descripcion_cuenta_1 = (xpath('//row/c32/text()',xmlKDM1))[1]::text;
			   	end if ;			   
			end if;
		/*raise notice 'v_numero_cuenta:%',v_numero_cuenta;
		raise notice 'strValor2 :%',strValor2;
		raise notice 'v_descripcion_cuenta_1:%',v_descripcion_cuenta_1;
		raise notice 'mensaje:%',mensaje;
		raise notice 'monto_cargo:%',monto_cargo;
		raise notice 'v_descripcion_cuenta:%',v_descripcion_cuenta;*/
		select format('
				<document>
					<poliza>
  			  			<poliza_enc>
	  						<no_partidas>1</no_partidas>
					 		<error>%4$s</error>
	   			     		<monto_base_kdmm></monto_base_kdmm>
	  		      			<descripcion_poliza></descripcion_poliza>
	  		      			<referencia></referencia>
			    		</poliza_enc>
			  		  <partidas>    
	   						<partida_1>
					            <cuenta>%1$s</cuenta>
								<descripcion_cuenta>%6$s</descripcion_cuenta>
					            <tipo_asiento>%2$s</tipo_asiento>
					            <monto>%5$s</monto>
					            <descripcion_partida>%3$s</descripcion_partida>			            
				       		</partida_1>
			   		   </partidas>
					</poliza>
				 </document>',
				v_numero_cuenta::text,
				strValor2::text,
				left(v_descripcion_cuenta_1,40)::text,
				mensaje::text,
				monto_cargo::text,
				left(v_descripcion_cuenta,40)::text)::xml into xmlResult;
	end if;

	return xmlResult;

exception
	when others then
		raise notice '%',sqlerrm;
		resultado := 0;
		mensaje := 'verify_cont() ' || sqlerrm;
		adicionales := '';
		return xmlResult ;	
end;
$function$
