CREATE OR REPLACE FUNCTION keplersc.cont_regenerar_poliza(dataxml xml)
 RETURNS xml
 LANGUAGE plpgsql
AS $function$

--Bitacora de cambios
--22/12/2024 Miriam Santana: Quitar validaciones para sustituye_cont, y pasen las anulacion de cobros por alta_cont_mov
declare
	--Variables de definicion de documento
	sucn_ini text = '';
	gen_ini text = '';
	nat_ini text = '';
	gpo_ini text = '';
	tipo_ini text = '';
	fecha_ini text = '';
	sucn_fin text = '';
	gen_fin text = '';
	nat_fin text = '';
	gpo_fin text = '';
	tipo_fin text = '';
	fecha_fin text = '';
	tipo_proc text = '';
	dia text = '';
	mes text = '';
	anio text = '';
	folio_unico text = '';
	rec_KDM1 record;
	rec_KDMM record;
	rec_TMP record;
	rec_poliza record;

	--Variables de uso general 
	strValor text = '';
	intValor int = 0;
	movtosIni text = '';
	movtosFin text ='';
	xmlUI xml;
	xmlKDM1 xml;
	xmlKDMM xml;
	expSql text ='';
	tbl_kdc1 text ='';
	tbl_kdc2 text ='';
	totReg int = 0;
	no_poliza int = 0;
	tipo_poliza text = '';
	no_poliza_proc int = 0;
	tipo_poliza_proc text = '';
	notaProceso text = '';
	simboloProceso text = '';
	funcionProceso text = '';
	get_resultado text = '';
	get_mensaje text = '';
	get_adicionales text = '';

	--Variables de log proceso
	fecha_movto text = '';
	hora_movto text = '';
	usuario_movto text = '';
	detalle_movto text = '';
	xmlUsr xml;
			
	--Variables de retorno
	resultadoXml xml;
	

begin
	sucn_ini := (xpath('//document/k_sucn_ini/r1/text()', dataxml))[1];
	gen_ini := (xpath('//document/k_gen_ini/text()', dataxml))[1];
	nat_ini := (xpath('//document/k_nat_ini/text()', dataxml))[1];
	gpo_ini := (xpath('//document/k_gpo_ini/text()', dataxml))[1];
	tipo_ini := (xpath('//document/k_tipo_ini/text()', dataxml))[1];
	fecha_ini := (xpath('//document/fecha_ini/text()', dataxml))[1];
	sucn_fin := (xpath('//document/k_sucn_fin/r1/text()', dataxml))[1];
	gen_fin := (xpath('//document/k_gen_fin/text()', dataxml))[1];
	nat_fin := (xpath('//document/k_nat_fin/text()', dataxml))[1];
	gpo_fin := (xpath('//document/k_gpo_fin/text()', dataxml))[1];
	tipo_fin := (xpath('//document/k_tipo_fin/text()', dataxml))[1];
	fecha_fin := (xpath('//document/fecha_fin/text()', dataxml))[1];
	tipo_proc := (xpath('//document/tipo_proc/text()', dataxml))[1];	
	folio_unico := coalesce((xpath('//document/inp_mov/text()', dataxml))[1],'');

	movtosIni:=concat(sucn_ini,gen_ini,nat_ini,lpad(gpo_ini,3,'0'),lpad(tipo_ini,3,'0'));
	movtosFin:=concat(sucn_fin,gen_fin,nat_fin,lpad(gpo_fin,3,'0'),lpad(tipo_fin,3,'0'));

	--Crear tabla temporal de proceso
	drop table if exists tmpRows;
	create temp table tmpRows (
		simbolo text,
		sucursal_id text, 
		genero text, 
		naturaleza text, 
		grupo numeric, 
		tipo numeric,
		descripcion text,
		folio text, 
		fecha date,
		tipo_poliza text, 
		no_poliza numeric,
		tipo_poliza_nueva text, 
		no_poliza_nueva numeric,		
		nota text,
		funcion_cont text,
		tabla_poliza text
		
	);

--raise notice 'movtosIni:%, movtosFin:%, fecha_ini:%, Fecha_fin:% ', movtosIni, movtosFin,Fecha_Ini ,Fecha_Fin;
	--Obtener registros a procesar desde kdm1
	for rec_KDM1 in select * from keplersc.kdm1 
		where c9>=to_date(fecha_Ini,'yyyy-mm-dd') 
		and c9<=to_date(fecha_Fin,'yyyy-mm-dd')
		and concat(c1,c2,c3,lpad(c4::text,3,'0'),lpad(c5::text,3,'0'))>=movtosIni 
		and concat(c1,c2,c3,lpad(c4::text,3,'0'),lpad(c5::text,3,'0'))<=movtosFin
		order by c1,c2,c3,c4,c5,c6
	loop
--raise notice 'kdm1 movto:%',concat(rec_KDM1.c1,rec_KDM1.c2,rec_KDM1.c3,lpad(rec_KDM1.c4::text,3,'0'),lpad(rec_KDM1.c5::text,3,'0'));		
		if folio_unico<>'' and rec_KDM1.c6<>folio_unico then
			continue;
		end if;
		strValor:=rec_KDM1.c9::text;
		dia:=substring(strValor,9,2);
		mes:=substring(strValor,6,2);
		anio:=substring(strValor,3,2);	


		--Obtener registro de kdmm
		select * into rec_KDMM from keplersc.kdmm 
		where col_sucursal=rec_KDM1.c1 and c1=rec_KDM1.c2 and c2=rec_KDM1.c3 and c3=rec_KDM1.c4 and c4=rec_KDM1.c5;	
	
		--Obtener la referencia de la poliza asociada al movimiento.
		tbl_kdc1:= concat('keplersc.kdc1',anio);	
		tbl_kdc2:= concat('keplersc.kdc2',anio,mes);	

		no_poliza = 0;
		tipo_poliza = '';
		notaProceso:='';
		simboloProceso:='';	
		expSql:=concat('select count(poliza) from (select c1 as poliza from ',
			tbl_kdc2,' where c14=', E'\'',rec_KDM1.c1, E'\''
			,' and c15=', E'\'',rec_KDM1.c2, E'\'',' and c16=', E'\'',rec_KDM1.c3, E'\'' 
			,' and c17=',rec_KDM1.c4,' and c18=',rec_KDM1.c5,' and c19=',E'\'',rec_KDM1.c6,E'\'' 
			,' group by c1) as polizas');
		execute expSql into totReg;
		if totReg>1 then
			--Verificar si tiene un movimiento de baja para el movimiento
			expSql:=concat('select count(c1) as total from ',
				tbl_kdc2,' where c14=', E'\'',rec_KDM1.c1, E'\''
				,' and c15=', E'\'',rec_KDM1.c2, E'\'',' and c16=', E'\'',rec_KDM1.c3, E'\'' 
				,' and c17=',rec_KDM1.c4,' and c18=',rec_KDM1.c5,' and c19=',E'\'',rec_KDM1.c6,E'\''
				,' and substring(c6,1,5)=''BAJA:'' ');
			
			execute expSql into totReg;
--raise notice 'expSql:% -->TotReg;%',expSql,totReg;		
			if totReg>0 then
				notaProceso:='Movto. dado de BAJA';
				simboloProceso:='X';
			else
				notaProceso:='Movto. con más de 1 póliza';
				simboloProceso:='X';			
			end if;
		end if;
--raise notice 'expSql:% -->TotReg;%',expSql,totReg;	
		if totReg=0 then --Mas de una poliza c/el mismo folio
			notaProceso:='Movto. sin póliza';
			simboloProceso:='!';
		end if;	

		if totReg=1 then --Una poliza para el movimiento
			--Obtener el tipo de poliza y consecutivo
			expSql:=concat('select * from ',tbl_kdc2, ' where c14=', E'\'',rec_KDM1.c1, E'\''
				,' and c15=', E'\'',rec_KDM1.c2, E'\'',' and c16=', E'\'',rec_KDM1.c3, E'\'' 
				,' and c17=',rec_KDM1.c4,' and c18=',rec_KDM1.c5,' and c19=',E'\'',rec_KDM1.c6,E'\'' 
				,' limit 1 ');
			execute expSql into rec_Poliza;
		
			no_poliza := rec_Poliza.c1;
			tipo_poliza := rec_Poliza.c8;
		
			if substring(rec_Poliza.c6,1,5)='BAJA:' then
				notaProceso:='Movto. de BAJA';
				simboloProceso:='X';
			end if;
		end if;
	
	simboloProceso:='';
		--Validar que el movimiento no este cancelado
		if simboloProceso <> 'X' then		
			if rec_KDM1.c43 = 'C' then
				notaProceso:='Movimiento Cancelado';
				simboloProceso:='X';
				funcionProceso:='';						
			end if;
		end if;
	
		if simboloProceso <> 'X' then
			--Validar tipo de afectacion contable
			funcionProceso:='keplersc.cont_general_alta';
			if rec_KDMM.c6<>'S' then
				if no_poliza <> 0 then
					notaProceso:='No genera póliza, solo se eliminará la actual.';
				else
					notaProceso:='No hay póliza actual y no genera póliza';			
				end if;
				funcionProceso:='';
				simboloProceso:='!';
			else --Genera poliza
				if rec_KDMM.c19='TRASPASO' then --ALTA_CONT_TRASPASO_CONTADO
					notaProceso:='No se puede regenerar póliza para TRASPASO';
					simboloProceso:='X';
					funcionProceso:='alta_cont_traspaso_contado';
				else
					if rec_KDMM.c71='S' then
						notaProceso:='No se puede regenerar póliza para alta_cont_cont';
						simboloProceso:='X';
						funcionProceso:='alta_cont_cont';					
					else
						if rec_KDMM.c10='C' then
							notaProceso:='No se puede regenerar póliza para ALTA_CONT_OCOMPRA';
							simboloProceso:='X';
							funcionProceso:='alta_cont_ocompra';
						else
							if rec_KDMM.c47='S' then
								notaProceso:='';
								simboloProceso:='.';
								funcionProceso:='alta_cont_mov';
							else
								notaProceso:='';
								simboloProceso:='.';
								funcionProceso:='cont_general_alta';
							end if;
						end if;							
					end if;
				end if;	
			end if;
		end if;
		
		--Validar movimientos particulares para regenerar poliza
		if simboloProceso <> 'X' then		
			if (rec_KDM1.c2='X' and rec_KDM1.c3='A' and rec_KDM1.c4=12) or
				(rec_KDM1.c2='N' and rec_KDM1.c3='A' and rec_KDM1.c4=21)
			then 
				notaProceso:='No se puede regenerar póliza para este movimiento';
				simboloProceso:='X';
				funcionProceso:='';
			end if;
		end if;

		--Validar que el mes y el anio esten abiertos
		if simboloProceso <> 'X' then			
			expSql:=concat('select c',lpad(((mes::int)+9)::text,2,'0'),
				' from keplersc.kdym where c1=',E'\'', '20',anio,E'\'');
			execute expSql into strValor;
			if strValor <> 'A' then
				notaProceso:='Anio/Mes cerrado';
				simboloProceso:='X';
				funcionProceso:='';			
			end if;
		end if;
 
		--Insertar en temporal el registro a procesar y comentarios
		insert into tmpRows(simbolo,sucursal_id,genero,naturaleza,grupo,tipo, 
		descripcion,folio,fecha,tipo_poliza,no_poliza,nota,tipo_poliza_nueva,
		no_poliza_nueva,funcion_cont,tabla_poliza) 
		values(simboloProceso,rec_KDM1.c1,rec_KDM1.c2,rec_KDM1.c3,rec_KDM1.c4,rec_KDM1.c5,
		rec_KDMM.c5,rec_KDM1.c6,rec_KDM1.c9,tipo_poliza,no_poliza,notaProceso,'',
		0,funcionProceso,tbl_kdc2);

	end loop;

	if tipo_proc='F' then --Proceso Final
		--Ejecutar el proceso
		for rec_TMP in select * from tmpRows
		loop
			if rec_TMP.simbolo = 'X' then
				continue;
			end if;
			tbl_kdc2:=rec_TMP.tabla_poliza;
			--Obtener registro en kdm1
			select * into rec_KDM1 from keplersc.kdm1 where c1=rec_TMP.sucursal_id 
				and c2=rec_TMP.genero and c3=rec_TMP.naturaleza and c4=rec_TMP.grupo
				and c5=rec_TMP.tipo and c6=rec_TMP.folio;

		
			--Obtener xml de KDM1 de registro actual en xml
			expSql=concat('select * from keplersc.kdm1 where c1=', E'\'' ,rec_KDM1.c1, E'\'' ,' and c2=',E'\'' ,rec_KDM1.c2,
				E'\'' ,' and c3=', E'\'' ,rec_KDM1.c3,E'\'' ,' and c4=',rec_KDM1.c4,' and c5=',	rec_KDM1.c5,' and c6=',
				E'\'' ,rec_KDM1.c6,E'\'');	
			select query_to_xml(expSql, true, false, '') into xmlKDM1;

		
			--Obtener registro de kdmm
			select * into rec_KDMM from keplersc.kdmm 
			where col_sucursal=rec_KDM1.c1 and c1=rec_KDM1.c2 and c2=rec_KDM1.c3
			and c3=rec_KDM1.c4 and c4=rec_KDM1.c5;
	
			--Obtener xml de KDMM de registro actual en xml
			expSql=concat('select * from keplersc.kdmm where col_sucursal='|| E'\'' || rec_KDM1.c1 || E'\'' || ' and c1=',E'\'' ,rec_KDM1.c2,
				E'\'' ,' and c2=', E'\'' ,rec_KDM1.c3,E'\'' ,' and c3=',rec_KDM1.c4,
				' and c4=',	rec_KDM1.c5);
			select query_to_xml(expSql, true, false, '') into xmlKDMM;

			--Crear xml de UI con los datos basicos para contabilidad
			strValor:='';
			strValor:=concat(strValor,'<document>');
			strValor:=concat(strValor,'<k_sucn><r1>',rec_KDM1.c1,'</r1></k_sucn>');
			strValor:=concat(strValor,'<k_tipon><r1>',rec_KDM1.c2,'</r1></k_tipon>');
			strValor:=concat(strValor,'<k_tipon><r2>',rec_KDM1.c3,'</r2></k_tipon>');
			strValor:=concat(strValor,'<k_tipon><r3>',rec_KDM1.c4::text,'</r3></k_tipon>');
			strValor:=concat(strValor,'<k_tipon><r4>',rec_KDM1.c5::text,'</r4></k_tipon>');
			strValor:=concat(strValor,'<k_fecha>',substring(to_char(rec_KDM1.c9,'yyyy-mm-dd'),1,10),'</k_fecha>');	
			strValor:=concat(strValor,'<k_refer>',rec_KDM1.c11,'</k_refer>');
			strValor:=concat(strValor,'<k_iva>',rec_KDM1.c14::text,'</k_iva>');
			strValor:=concat(strValor,'<k_ieps>',rec_KDM1.c15::text,'</k_ieps>');		
			strValor:=concat(strValor,'<k_monto>',rec_KDM1.c16::text,'</k_monto>');	
			strValor:=concat(strValor,'<k_miepsret>',rec_KDM1.c15::text,'</k_miepsret>');	
			strValor:=concat(strValor,'<k_mivaret>',rec_KDM1.c25::text,'</k_mivaret>');	
			strValor:=concat(strValor,'</document>');	
			xmlUI:=strValor::xml;

			--Crear nueva poliza, llamar funcion contabilidad dependiendo del tipo
			if rec_TMP.funcion_cont='cont_general_alta' then
				select * into get_resultado, get_mensaje, get_adicionales from keplersc.cont_general_alta(xmlUI,xmlKDM1,xmlKDMM,rec_TMP.folio);
				if get_resultado = '0' then
					no_poliza_proc := 0;
					tipo_poliza_proc:= '';
					notaProceso := get_mensaje;
				else 
					no_poliza_proc := get_mensaje::numeric;
					tipo_poliza_proc := rec_KDMM.c18;
					notaProceso := 'Póliza regenerada correctamente';
				end if;	
			end if;

			if rec_TMP.funcion_cont='alta_cont_mov' then
				select * into get_resultado, get_mensaje, get_adicionales from keplersc.alta_cont_mov(xmlUI,xmlKDM1,xmlKDMM,rec_TMP.folio);
				if get_resultado = '0' then
					no_poliza_proc := 0;
					tipo_poliza_proc:= '';
					notaProceso := get_mensaje;
				else 
					no_poliza_proc := get_mensaje::numeric;
					tipo_poliza_proc := rec_KDMM.c18;
					notaProceso := 'Póliza regenerada correctamente';
				end if;	
			end if;

			if get_resultado = '1' then
				--Eliminar registro de poliza
				if 	rec_TMP.no_poliza <> 0 and rec_TMP.tipo_poliza <> '' then
					expSql:=concat('delete from ',tbl_kdc2, ' where c14=', E'\'',rec_TMP.sucursal_id, E'\'',
						' and c1=', rec_TMP.no_poliza, ' and c8=', E'\'',rec_TMP.tipo_poliza, E'\'');
					execute expSql;
				end if;
			
				/* Habilitar cuando se tenga el proceso de cont_cont			
				--Eliminar registros de costo a la unidad
				delete from keplersc.kdsunicosto 
				where c1=rec_KDM1.c1 and c2=rec_KDM1.c2 and c3=rec_KDM1.c3
				and c4=rec_KDM1.c4 and c5=rec_KDM1.c5 and c6=rec_KDM1.c6;
				*/
			end if;
		
			--Actualizar registro de proceso
			update tmpRows as tmp set tipo_poliza_nueva=tipo_poliza_proc, no_poliza_nueva=no_poliza_proc,
			nota=notaProceso
			where tmp.sucursal_id=rec_TMP.sucursal_id and tmp.genero=rec_TMP.genero and tmp.naturaleza=rec_TMP.naturaleza 
			and	tmp.grupo=rec_TMP.grupo and tmp.tipo=rec_TMP.tipo and folio=rec_TMP.folio and tmp.tipo_poliza=rec_TMP.tipo_poliza;
		
			/*
			 * REGISTRO DE OPERACION EN BITACORA DE USUARIOS PARA TRANSACCIONES SATISFACTORIAS
			 */
				
				fecha_movto :=  current_date::text;
				hora_movto := left(current_time::text, 8);
				usuario_movto := (xpath('//document/movimiento/usuario/text()',dataxml))[1];
				detalle_movto := concat('Movtos:',movtosIni,'-',movtosFin,
					'; Periodo: ',fecha_ini,'-',fecha_fin,
					'; Proceso: ',
					'; Movto: ',rec_TMP.sucursal_id,'-',rec_TMP.genero,'-',rec_TMP.naturaleza,'-',
					rec_TMP.grupo,'-','-',rec_TMP.tipo,rec_TMP.folio,
					'; Ant.:',rec_TMP.tipo_poliza,'-',rec_TMP.no_poliza,
					'; Nvo.:',tipo_poliza_proc,'-',no_poliza_proc);
				
				select xmlforest(usuario_movto as usuario, fecha_movto as fecha, hora_movto as hora, 
				rec_TMP.sucursal_id as sucursal, rec_TMP.genero as genero, rec_TMP.naturaleza as naturaleza, 
				rec_TMP.grupo as grupo, rec_TMP.tipo as tipo, rec_TMP.folio as folio,
				'REGPOLIZA' as tipo_movto, detalle_movto as detalle_movto) :: text into strValor;		
				select '<document>'||strValor||'</document>' into strValor;
		
				xmlUsr := strValor::xml;
				select * into get_resultado, get_mensaje, get_adicionales from keplersc.usr_kdusraccess_alta(xmlUsr);
				--raise notice '%',sucursal_id;	
				if get_resultado = '0' then
					raise exception '%',get_mensaje;
				end if;
		end loop;
	end if;
--raise exception 'Error inyectado'; 
	select query_to_xml('select * from tmpRows order by fecha',false,true,'') into resultadoXml;	
	return resultadoXml;
end;
$function$
