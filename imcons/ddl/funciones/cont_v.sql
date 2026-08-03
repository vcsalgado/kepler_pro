CREATE OR REPLACE FUNCTION keplersc.cont_v(xmlkdm1 xml, xmlkdmm xml, identificador_columna text)
 RETURNS xml
 LANGUAGE plpgsql
AS $function$
declare 
--Descripcion: 
--Autor: Saltiel Cruz
--Fecha: 29/11/2022
 
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
	strValorC text = '';
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
	v_descripcion_partida text = '';
	descripcion_cuenta text = '';
	monto_partida decimal = 0.00;
	monto_descuento decimal = 0.00;
	monto_iva decimal = 0.00;
	monto_ieps decimal = 0.00;
	monto_total decimal = 0.00;
	monto_sin_iva decimal = 0.00;
	monto_cargo decimal = 0.00;
	monto_abono decimal = 0.00;
	v_B8053_isan_o_iva_complementario decimal = 0.00;
	v_B8054_anticipo decimal = 0.00;
	v_B8064_iva_anticipo decimal = 0.00;
	v_B8056_costo decimal = 0.00;
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
	v_entradasenunidades decimal = 0.00;
	v_salidasenunidades decimal = 0.00;
	v_entradasenmonto decimal = 0.00;
	v_salidasenmonto decimal = 0.00;
	v_ultimocosto decimal = 0.00;
	
begin
	
	sucursal_id := (xpath('//row/c1/text()',xmlKDM1))[1];
	genero := (xpath('//row/c2/text()',xmlKDM1))[1];
	naturaleza := (xpath('//row/c3/text()',xmlKDM1))[1];
	grupo := (xpath('//row/c4/text()',xmlKDM1))[1];
	tipo := (xpath('//row/c5/text()',xmlKDM1))[1];
	v_monto := (xpath('//row/c16/text()',xmlKDM1))[1];
	strValor := (xpath('//row/c90/text()', xmlKDMM))[1];
	v_inventario:= (xpath('//row/c100/text()',xmlKDM1))[1];

	v_descripcion_partida = 'NUEVAPOLIZA';
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
		if naturaleza = 'D' then
			monto_cargo := monto_total;
			strValorC := coalesce((xpath('//row/c30/text()', xmlKDMM))[1]::text,'');
			if strValorC <> 'S' then
				monto_abono = monto_total - monto_iva - monto_ieps -
						(monto_extra_1 + monto_extra_2 + monto_extra_3 + monto_extra_4 + monto_extra_5 +
						monto_extra_6 + monto_extra_7);
			else --CUENTA COMPLEMENTARIA DE IVA
				monto_abono = monto_total - monto_ieps -
						(monto_extra_1 + monto_extra_2 + monto_extra_3 + monto_extra_4 + monto_extra_5 +
						monto_extra_6 + monto_extra_7);
			end if;
		else
			strValorC := coalesce((xpath('//row/c30/text()', xmlKDMM))[1]::text,'');
			if strValorC <> 'S' then
				raise notice 'monto_total %',monto_total;
				monto_cargo = monto_total - monto_iva - monto_ieps -
						(monto_extra_1 + monto_extra_2 + monto_extra_3 + monto_extra_4 + monto_extra_5 +
						monto_extra_6 + monto_extra_7);
			else 
				monto_cargo = monto_total - monto_ieps -
						(monto_extra_1 + monto_extra_2 + monto_extra_3 + monto_extra_4 + monto_extra_5 +
						monto_extra_6 + monto_extra_7);
				raise notice 'else : monto_cargo %',monto_cargo;
			end if;
			monto_abono := monto_total;
		end if;
		monto_iva := monto_iva;

		strValorC := coalesce((xpath('//row/c30/text()', xmlKDMM))[1]::text,'');
		if strValorC <> 'S' then
			v_B8053_isan_o_iva_complementario := monto_ieps;
		else 
			v_B8053_isan_o_iva_complementario := monto_iva;
		end if;
		v_B8054_anticipo := coalesce((xpath('//row/c49/text()', xmlkdm1))[1]::text,'0.00')::text;
		v_B8056_costo := 0;
		
		if (select count(*) from keplersc.KDLINV where c1 = sucursal_id and c2 = v_inventario) > 0 then 
			select c3,c4,c5,c6,c8 into v_entradasenunidades,v_salidasenunidades,v_entradasenmonto,v_salidasenmonto,v_ultimocosto from keplersc.KDLINV where c1 = sucursal_id and c2 = v_inventario;		
			if (v_entradasenunidades - v_salidasenunidades) = 0 then 
				v_B8056_costo = v_ultimocosto;
			else	
				v_B8056_costo = (v_entradasenmonto - v_salidasenmonto) / (v_entradasenunidades-v_salidasenunidades);
			end if;		
		else
			v_B8056_costo = 0;
		end if;
		
			strValor := (xpath('//row/c66/text()', xmlKDMM))[1]::text;
			strValorB := (xpath('//row/c49/text()', xmlKDM1))[1]::text;
		    if strValor <> 'C'	and strValor <> 'V' then 
			   	v_B8064_iva_anticipo := strValorB::decimal * (1- (1/(1 + monto_total::decimal/100)));
			else 
				v_B8064_iva_anticipo := 0;
		    end if;
		if naturaleza = 'D' then 
				strValor2 := 'A';
		else
				strValor2 := 'C';
		end if;	
			if identificador_columna = 'c19' then 
				v_NumCol_CtaCont = '19'; v_numcam_a_aniadir_CtaPrincipal = 25;	
				strValor2 := 'C';
				monto_partida := monto_cargo;
				raise notice 'Col 19 entro ...';
			end if;	
			if identificador_columna = 'c20' then 
				v_NumCol_CtaCont = '20'; v_numcam_a_aniadir_CtaPrincipal = 26;
				strValor2 := 'A';
				monto_partida := monto_abono;
			end if;	
			
		
			if identificador_columna = 'c21' then 
				v_NumCol_CtaCont = '21'; v_numcam_a_aniadir_CtaPrincipal = 0;				
				--strValor2 := strValor2;
				monto_partida := monto_iva;
			end if;
			if identificador_columna = 'c22' then 
				v_NumCol_CtaCont = '22'; v_numcam_a_aniadir_CtaPrincipal = 0;
				strValorC := coalesce((xpath('//row/c30/text()', xmlKDMM))[1]::text,'');
				if strValorC <> 'S' then
					--strValor2 se queda como está
				else
					if strValor2 = 'C' then 
						strValor2 := 'A';
					else
						strValor2 := 'C';
					end if;
				end if;  --end
				monto_partida := v_B8053_isan_o_iva_complementario;
			end if;	
			if identificador_columna = 'c23' then 
				v_NumCol_CtaCont = '23'; v_numcam_a_aniadir_CtaPrincipal = 54;				
				strValor2 := 'C';
				monto_partida := v_B8054_anticipo;
			end if;	
			if identificador_columna = 'c24' then 
				v_NumCol_CtaCont = '24'; v_numcam_a_aniadir_CtaPrincipal = 55;				
				strValor2 := 'A';
				monto_partida := v_B8054_anticipo;
			end if;	
			if identificador_columna = 'c34' then
				v_NumCol_CtaCont = '34'; v_numcam_a_aniadir_CtaPrincipal = 56;
				strValor2 := 'C';
				monto_partida := v_B8056_costo;
				/*if (select count(*) from keplersc.KDBONIF 
					where c1 = sucursal_id and c8 = v_inventario and c9 = 'C') > 0 then 
					select c10 into monto_extra_10 from keplersc.KDBONIF where c1 = sucursal_id and c8 = v_inventario and c9 = 'C';
					strValor2 := 'A';
				else 
					monto_extra_10 := 0;
				end if ; 
				monto_partida := monto_partida + monto_extra_10;*/
			end if;
			if identificador_columna = 'c35' then 
				v_NumCol_CtaCont = '35'; v_numcam_a_aniadir_CtaPrincipal = 57;
				strValor2 := 'A';
				monto_partida := v_B8056_costo;
				/*if (select count(*) from keplersc.KDBONIF where c1 = sucursal_id and c8 = v_inventario and c9 = 'C') > 0 then 
					select c10 into monto_extra_10 from keplersc.KDBONIF where c1 = sucursal_id and c8 = v_inventario and c9 = 'C';
					strValor2 := 'C';
				else 
					monto_extra_10 := 0;
				end if ; 
				monto_partida := monto_partida + monto_extra_10;*/
			end if;	
			if identificador_columna = 'c36' then 
				v_NumCol_CtaCont = '36'; v_numcam_a_aniadir_CtaPrincipal = 58;monto_partida := 0;				
			end if;		
			if identificador_columna = 'c37' then 
				v_NumCol_CtaCont = '37'; v_numcam_a_aniadir_CtaPrincipal = 59;monto_partida := 0;
			end if;		
			if identificador_columna = 'c38' then 
				v_NumCol_CtaCont = '38'; v_numcam_a_aniadir_CtaPrincipal = 60;monto_partida := 0;
			end if;		
			if identificador_columna = 'c39' then 
				v_NumCol_CtaCont = '39'; v_numcam_a_aniadir_CtaPrincipal = 61;monto_partida := 0;
			end if;		
			if identificador_columna = 'c40' then 
				v_NumCol_CtaCont = '40'; v_numcam_a_aniadir_CtaPrincipal = 62;monto_partida := 0;
			end if;		
			if identificador_columna = 'c41' then 
				v_NumCol_CtaCont = '41'; v_numcam_a_aniadir_CtaPrincipal = 63;monto_partida := 0;
			end if;		
			if identificador_columna = 'c72' then 
				v_NumCol_CtaCont = '72'; v_numcam_a_aniadir_CtaPrincipal = 0;
				strValor2 := 'C';
				monto_partida := v_B8064_iva_anticipo;
			end if;		
			if identificador_columna = 'c73' then 
				v_NumCol_CtaCont = '73'; v_numcam_a_aniadir_CtaPrincipal = 0;
				strValor2 := 'A';
				monto_partida := v_B8064_iva_anticipo;
			end if;	
		
			
			select * into resultado,mensaje,v_numero_cuenta,v_descripcion_cuenta from keplersc.verify_cont_format(xmlKDM1,xmlKDMM,v_NumCol_CtaCont::int,v_numcam_a_aniadir_CtaPrincipal::int,'0');			
			
			v_descripcion_cuenta_1 = (xpath('//row/c133/text()',xmlKDM1))[1]::text || '/' || (xpath('//row/c32/text()',xmlKDM1))[1]::text;
			v_descripcion_cuenta_1 = replace(v_descripcion_cuenta_1, '&', '-');
			if v_NumCol_CtaCont::int = 19 then				
				v_condicion := (xpath('//row/c25/text()',xmlKDMM))[1]::text;
				if v_condicion::numeric < 0 then 
					 	v_inventario := (xpath('//row/c100/text()',xmlKDM1))[1]::text;
					 	v_inventario := (select substring(v_inventario,1,4)) || (select substring(v_inventario,8,1)) || '/' || 
									(right(v_inventario, length(v_inventario)-(length(v_inventario)-2)));
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
				v_condicion := (xpath('//row/c26/text()',xmlKDMM))[1]::text;
				if v_condicion::numeric < 0 then 						
					 	v_inventario := (xpath('//row/c100/text()',xmlKDM1))[1]::text;
					 	v_inventario := (select substring(v_inventario,1,4)) || (select substring(v_inventario,8,1)) || '/' || 
									(right(v_inventario, length(v_inventario)-(length(v_inventario)-2)));					 	
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
			if v_NumCol_CtaCont::int = 21 then
			end if;
			if v_NumCol_CtaCont::int = 22 then
			end if;
			if v_NumCol_CtaCont::int = 23 then
			end if;
			if v_NumCol_CtaCont::int = 24 then
			end if;
			if v_NumCol_CtaCont::int = 23 then
			end if;
			if v_NumCol_CtaCont::int = 24 then
			end if;
		/*raise notice 'v_numero_cuenta:%',v_numero_cuenta;
		raise notice 'strValor2 :%',strValor2;
		raise notice 'v_descripcion_cuenta_1:%',v_descripcion_cuenta_1;
		raise notice 'mensaje:%',mensaje;
		raise notice 'monto_partida:%',monto_partida;
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
				monto_partida::text,
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
