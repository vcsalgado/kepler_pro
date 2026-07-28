CREATE OR REPLACE FUNCTION keplersc.verify_cont_format(dataxml xml, xmlkdmm xml, cuenta integer, campoconcatenar integer, renglonmov text)
 RETURNS TABLE(resultado text, mensaje text, v_no_cuenta text, v_desc_cuenta text)
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
	v_inventario text ='';
	clave_cteprov text ='';
	v_nombre_impresion text ='';
	--Variables de uso general
 	strValor text = '';
    strValor2 text = '';
 	totReg	int;
 	str_usuario text;	
	v_valor_CtaCont text = '';
 	v_N1 numeric = 0;
	v_N2 numeric = 0;
	v_numcam_a_aniadir_CtaPrincipal numeric = 0;	
	v_valorcampo_a_concatenar numeric = 0;
	v_prefijo_inicio_cuenta text ='';	
	v_no_cuenta text ='';
	v_desc_cuenta text ='';
	v_resultado_concatena_cuenta text ='';
	
	v_anio_modelo text ='';
	v_auxSql text = '';
	v_Columna text = '';
	v_Columna_valor text = '';
	k_fecref text = '';
	--Variables de retorno
	
	resultado text;
	mensaje text;
	adicionales text;
	
	v_clave_del_vehiculo text ='';
begin 					---********** dataxml en realidad es KDM1************
		sucursal_id := (xpath('//row/c1/text()',dataxml))[1];
		v_inventario := (xpath('//row/c100/text()',dataxml))[1];
		clave_cteprov :=(xpath('//row/c10/text()',dataxml))[1];--'C100000';--
		v_nombre_impresion := (xpath('//row/c32/text()',dataxml))[1];
	
		
		v_numcam_a_aniadir_CtaPrincipal = cuenta;--inicia en 19
		v_valorcampo_a_concatenar := (xpath('//row/c'||campoconcatenar||'/text()',xmlKDMM))[1]::text;--= 10; --inicia en v_numcam_a_aniadir_CtaPrincipal + 6 = c25.. donde se obtiene el valor 10
		--raise notice 'v_valorcampo_a_concatenar %',v_valorcampo_a_concatenar;
		v_N2 =	renglonmov;
		v_valor_CtaCont = (xpath('//row/c'||v_numcam_a_aniadir_CtaPrincipal||'/text()',xmlKDMM))[1]::text;--'V22'; --
		resultado = 1;
		v_prefijo_inicio_cuenta = v_valor_CtaCont;--M20 = V22
		v_no_cuenta = v_valor_CtaCont;
		v_desc_cuenta = 'Cuenta Creada por el Sistema';
		v_clave_del_vehiculo = '-1';-- se define como parte de una validación
		v_anio_modelo = (select substring ((select EXTRACT(year  FROM (select now()))::text),3,2)); --k_fecref
		mensaje := '0';
		if (select substring(v_valor_CtaCont,1,1)) = 'V' then
			select c3 into v_clave_del_vehiculo from keplersc.KDINF where c1 = sucursal_id and c2 = v_inventario;			
			if v_clave_del_vehiculo <> '-1'  then 
--raise exception 'sucursal_id: %; clave_vehiculo: %; strAnioContable: %',sucursal_id,v_clave_del_vehiculo,v_anio_modelo;			
				if (select count(*) from keplersc.KDIVCL where c1 = v_clave_del_vehiculo and c2 = v_anio_modelo and c3 =sucursal_id) > 0 then 
					--raise notice 'encontrado  %',v_anio_modelo ;
					v_Columna = (select substring(v_valor_CtaCont,2,2))::text; --10
					v_auxSql = format('SELECT c%1$s from keplersc.KDIVCL where c1=%2$L and c2 =%3$L and c3 = %4$L',v_Columna,v_clave_del_vehiculo,v_anio_modelo,sucursal_id);					
					--raise notice 'sqldkivcl %',v_auxSql;
					execute v_auxSql into v_Columna_valor;
					v_prefijo_inicio_cuenta= v_Columna_valor;
					v_no_cuenta= v_prefijo_inicio_cuenta;							
				else
					resultado = 0;
					mensaje := 'No esta correctamente configurada la cuenta Contable para el vehiculo';
					raise exception 'No esta correctamente configurada la cuenta Contable para el vehiculo';	
				end if;			
			end if;--end -1		
		end if; --end validación V
		--raise notice 'valor v_valorcampo_a_concatenar %', v_valorcampo_a_concatenar ;
		if v_valorcampo_a_concatenar < 0 then  --CONCATENANDO EL NUMERO DE INVENTARIO
				strValor := (xpath('//row/c47/text()', xmlKDMM))[1]::text; --'S';--
				if strValor = 'S' then --c47 Pantalla movimientos CxP
					/*IF DMOV(N2,1)="PENDIENTE" THEN     B11032="PENDIENTE": B11040="PENDIENTE"    ENDIF */
					--DMOV(N2,1) = valor obtenido de pantalla ...
					if(select count(*) from keplersc.KDINF where c1 = sucursal_id and c2 = 'VALOR DE DMOV(N2,1)') > 0 then 
						--v_resultado_concatena_cuenta=LEFT(DMOV(N2,1),4)+MID(DMOV(N2,1),8,1)+"/"+RIGHT(DMOV(N2,1),2): 
						--v_desc_cuenta=(select c5 from keplersc.KDINF where c1 = sucursal_id and c2 = 'VALOR DE DMOV(N2,1)');
					end if;--end DMOV				
	
				else  -- c47 no es 'S'
					/*IF A100="PENDIENTE" then  B11032="PENDIENTE": B11040="PENDIENTE" ENDIF*/
					if(select count(*) from keplersc.KDINF WHERE c1 = sucursal_id and C2 = v_inventario) > 0 then					
					v_resultado_concatena_cuenta = (select substring(v_inventario,1,4)) || (select substring(v_inventario,8,1)) || '/' || 
								(right(v_inventario, length(v_inventario)-(length(v_inventario)-2)));
									--								(select substring(v_inventario,9,2));--0029U22
								
					v_desc_cuenta=(select c5 from keplersc.KDINF WHERE c1 = sucursal_id and C2 = v_inventario)::text;--3KPA25AC2JE042943
					end if;
				end if;--end M47 = S
				
				v_no_cuenta = v_prefijo_inicio_cuenta ||'-'|| v_resultado_concatena_cuenta; -- Resultado=  [ -0029U22]
		else --EL CAMPO A CONCATENAR ES 0 O POSITIVO
			if v_valorcampo_a_concatenar > 0 then --CONCATENANDO UN CAMPO DE LA PANTALLA--10
				--raise notice 'Es mayor a 0 B11009' ;
				v_resultado_concatena_cuenta= clave_cteprov;--A(M(B11009))--C100000
				v_no_cuenta = v_prefijo_inicio_cuenta ||'-'|| v_resultado_concatena_cuenta; -- Resultado=  [ -C100000]
				if length(v_prefijo_inicio_cuenta) = 0 then 
					v_prefijo_inicio_cuenta = v_resultado_concatena_cuenta;
					v_no_cuenta = v_resultado_concatena_cuenta;
				end if;
				v_desc_cuenta = v_nombre_impresion; --A32
			else--SI EL CAMPO A CONCATENAR ES 0
				strValor := (xpath('//row/c71/text()', xmlKDMM))[1]::text; --strValor  = 'S';--
 			    strValor2 =   (xpath('//row/c'||v_numcam_a_aniadir_CtaPrincipal||'/text()',xmlKDMM))[1]::text; --c71 y c19...n 
				if strValor = 'S' and length(strValor2) = 0 then --CUANDO ES UNA PANTALLA DE MOVIMIENTOS CONTABLES Y NO TIENE CUENTA EN KDMM
				   /*v_resultado_concatena_cuenta=DMOV(N2,1);--revisar el valor en pantalla que se obtendrá de DMOV
				   v_prefijo_inicio_cuenta=v_resultado_concatena_cuenta; 
				   v_no_cuenta=v_resultado_concatena_cuenta;
				   */
				else
					if length(v_prefijo_inicio_cuenta) = 0 then  --NO ENCONTRO CUENTA A FORMATEAR
					resultado=0; 
					mensaje := 'NO SE ENCUENTRA CUENTA A FORMATEAR';
					end if;					
				end if;
			end if;
			
		end if;-- end v_valorcampo_a_concatenar
		

	--mensaje := '';
	adicionales := '';
	return query select resultado,mensaje,v_no_cuenta,v_desc_cuenta;

exception
	when others then
		resultado := 0;
		--mensaje := 'verify_cont() ' || sqlerrm;
		adicionales := '';
		return query select resultado,mensaje,v_no_cuenta::text,v_desc_cuenta::text;	
end;
$function$
