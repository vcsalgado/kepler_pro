CREATE OR REPLACE FUNCTION keplersc.cfd_header(dataxml xml, xmlkdm1 xml, xmlkdmm xml, folio_operacion text)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
declare
--Descripcion: Genera informacion para CFDI. Resuelve CFD_HEADER,CFD_HEADER_VEHICULO,CFD_HEADER_SERVICIO Y CFD_HEADER_EXTRAS 
--Autor: Miriam Santana
--Fecha: 03/10/2022
--Bitacora de cambios
--04/10/2024 Miriam Santana: Obtener de KDUDCFD el metodo de pago
--24/10/2024 Miriam Santana: Obtener fecha de pago de documento por anexar si la fecha no es valida
--22/12/2024 Miriam Santana: Se eliminaron validaciones de una sustitucion c86='S' ahora son anulaciones UD flag=ANULACION_COB
--17/02/2025 Miriam Santana: Incluir el tipo de relacion CFDI y folio relacionado obtenidos de KDUDCFD, motivo de cancelacion
--13/03/2025 Miriam Santana: Agregar configuracion para las aplicaciones de anticipos flag_cobros=APLICA_ANTICIPO
--23/05/2025 Miriam Santana: Incluir el movimiento de sustitucion(nuevo) en una anulacion por sustitucion
--16/10/2025 Miriam Santana: Modificar la configuracion para las aplicaciones de anticipos flag_cobros=APLICA_ANTICIPO se manejen igual que las notas de credito en la linea 1
--08/01/2026 Miriam Santana: Relacionar el anticipo seleccionado con la factura y enviarlo como se manejen las notas de credito en la linea 1
--18/02/2026 Miriam Santana: La Nota de Credito UD61 de una Nota de descto debe ser EGRESO
--23/02/2026 Miriam Santana: Los anticipos sin IVA que aplican a facturas de unidades seminuevas les envie tasa de impto = 0

	--Variables para xml 
	sucursal_id text;
	genero text;
	naturaleza text;
	grupo text;
	tipo text;
	usuario text;
	uen text;

	--variables de uso general
	strValor text = '';
	intValor int = 0;
	expSql text='';
	totReg int;
	
	--variables cfdi
	cons_cfdi int = 1;
	cdf_auto text;	
	area_doc text;
	ind_naturaleza text;
	layout_pdf text;
	metodo_pago text; 
	precio_sin_impto decimal=0;
	importe decimal=0;
	cp_sat text;
	f_pago_sat text;
	cuenta text;
	uso_cfdi text;
	rfc text;
	correo text; 
	razon_social text;
	regfiscal text;
	desc_regfiscal text;
	cve_cteprov  text;	--Pantalla validacion cfdi
	
	-- Quitar cuando se liberen <datcfdi>
	nombre text;
	calle text;
	colonia text;
	poblacion text;
	num_ext text;
	num_int text;
	municipio text;
	estado text; 
	pais text;
	-- Quitar cuando se liberen <datcfdi>

	vin text;
	marca text;
	modelo text;
	anio_modelo text;
	color text;
	num_motor text;
	
	tipo_orden text;
	num_orden text;
	kilometraje int;
	placas text;
	asesor text;

	cve_inventario text ='';
	clase text;
	procedencia text;
	reg_vehicular text;
	cve_vehicular text;
	num_puertas text;
	num_cilindros text;
	num_pasajeros text;
	combustible text;
	anio_oper_ad text;
	patente_ad text;
	anio_pedmto_ad text;
	fec_pedmto_ad text;
	cont_cred text;
	traspaso_ag text;

	cve_impto text = '002';
	tipo_factor text = 'TASA';
	monto_iva decimal=0;
	tasa_impto decimal=0;
	monto_base_impto decimal=0;
	tipo_rel_notcred text;
	gen_docto_anx text;
	nat_docto_anx text;
	gpo_docto_anx int;
	tip_docto_anx int;
	folio_docto_anx text;

	serie_docto text ='';
	fecha_gen_cfdi text; 
	hora_gen_cdfi text;
		
	tipo_rel_sustpag text;
	desc_clase text;
	conscompl int = 1;
	importe_orig decimal=0;
	importe_tm decimal=0;
	cve_vehic_tm text;
	marca_tm text;
	modelo_tm text;
	anio_tm text;
	num_motor_tm text;
	vin_tm text;
	val_libro_tm decimal=0;
	num_importa_tm text;
	fec_import_tm text;
	niv_tm text;
	aduana_tm text;

	siniestro text ='';
	bonete text ='';
	obs1 text;
	obs2 text;
	obs3 text;
	referencia text;
	plazo int;
	fec_pago text;
	desc_docto text;
	transmision text;
	fecha_movto date;

	gpo_anx text;
	tipo_anx text;
	fec_pago_docto_p text;

	flag_cobros text = '';				--MSS 22122024 Anulacion de cobro
	
	tiporelacion text = '';				--MSS 17022025 Relacion CFDI
	foliorelacionado text = '';			--MSS 17022025 Relacion CFDI
	gen_folrel text = '';				--MSS 17022025 Relacion CFDI
	nat_folrel text = '';				--MSS 17022025 Relacion CFDI
	gpo_folrel text = '';				--MSS 17022025 Relacion CFDI
	tpo_folrel text = '';				--MSS 17022025 Relacion CFDI
	
	tipo_rel text = '';					--MSS 24022025 Anulacion por sustitucion
	motivo_cancel text = '';			--MSS 24022025 Anulacion por sustitucion
	movimiento_sustitucion text = '';	--MSS 23052025 Anulacion por sustitucion
	--MSS 23052025 Anulacion por sustitucion
	folio_orig text = '';				
	gen_orig text = '';					
	nat_orig text = '';					
	gpo_orig text = '';					
	tpo_orig text = '';					
	folio_sust text = '';				
	gen_sust text = '';					
	nat_sust text = '';					
	gpo_sust text = '';					
	tpo_sust text = '';					
	--MSS 23052025 Anulacion por sustitucion
	
	--Variables de retorno
	resultado text;
	mensaje text;
	adicionales text;

begin
	--Transaccion
	sucursal_id := (xpath('//document/k_sucn/r1/text()', dataxml))[1];
	genero := (xpath('//document/k_tipon/r1/text()', dataxml))[1];
	naturaleza := (xpath('//document/k_tipon/r2/text()', dataxml))[1];
	grupo := (xpath('//document/k_tipon/r3/text()', dataxml))[1];
	tipo := (xpath('//document/k_tipon/r4/text()', dataxml))[1];
	usuario := (xpath('//document/movimiento/usuario/text()', dataxml))[1];
	uen := coalesce((xpath('//document/ambiente/uen/text()',dataxml))[1],'');
	cve_cteprov := coalesce((xpath('//document/k_clave/text()', dataxml))[1]::text,'0')::text;	--Pantalla validacion cfdi
	fecha_gen_cfdi := (xpath('//document/k_fecha/text()', dataxml))[1];

	flag_cobros :=coalesce((xpath('//document/ambiente/flag_cobros/text()',dataxml))[1]::text,'')::text;	--MSS 22122024 Anulacion de cobro


	if genero = 'U' and (xpath('//row/c80/text()', xmlKDMM))[1]::text = 'S' then
		--Pantalla validacion cfdi							--MSS 17022025 Relacion CFDI, obtiene datos de folio relacionado
		--KDUDCFD
		select c10,c20,c21,c22,c23,c11,c12,c2,c24,
		tipo_relacion, genero_doctorel, naturaleza_doctorel, grupo_doctorel, tipo_doctorel, folio_relacionado		
		into cp_sat,f_pago_sat,metodo_pago,cuenta,uso_cfdi,rfc,correo,razon_social,regfiscal,
		tiporelacion, gen_folrel, nat_folrel, gpo_folrel, tpo_folrel, foliorelacionado
		from keplersc.kdudcfd
		where c1 = cve_cteprov;
		if not found then
/***********Se comenta hasta que se ponga el dato <dat_cfdi> a todas las pantallas que kdmm.c80='S'(generen CFDI)**********			
			raise exception 'No existe registro de valdacion de informacion del cfdi';
**********Se comenta hasta que se ponga el dato <dat_cfdi> a todas las pantallas que kdmm.c80='S'(generen CFDI)***********/			
--	Este bloque que inserta en kdudcfd quitar hasta que se ponga el dato <dat_cfdi> a todas las pantallas que kdmm.c80='S'(generen CFDI) 	
			select c22,c163,c165,c164,c99,c166,c160,c162,c161
			into rfc,cp_sat,correo,uso_cfdi,razon_social,regfiscal,f_pago_sat,metodo_pago,cuenta
			from keplersc.kdm1 
			where c1=sucursal_id and c2=genero and c3=naturaleza and c4=grupo::integer and c5=tipo::integer and c6=folio_operacion;
		
			select c3,c4,c5,c6,c45,c46,c47,c48,c49 from keplersc.kdud
			into nombre,calle,colonia,poblacion,num_ext,num_int,municipio,estado,pais
			where c2=cve_cteprov;
		
			--MSS 24/09/2024 Escapar & y '
			nombre:=regexp_replace(nombre,'&AMP;','&','gi');
			nombre:=regexp_replace(nombre,'\\''','''','gi');
			insert into keplersc.kdudcfd  
				(c1, c2, c3, c4, c5, 
				c6, c7, c8, c9, c10, 
				c11, c12, c13, c14, c20, 
				c21, c22, c23, c24) 
			values(cve_cteprov, nombre, calle, colonia, num_ext, 
				num_int, municipio, estado, pais, cp_sat, 
				rfc, correo, sucursal_id, poblacion, f_pago_sat, 
				metodo_pago, cuenta, uso_cfdi, regfiscal);
--	Este bloque que inserta en kdudcfd quitar hasta que se ponga el dato <dat_cfdi> a todas las pantallas que kdmm.c80='S'(generen CFDI) 				

		end if;
	
		--OTROS	
		--raise notice 'folio_operacion %',folio_operacion;
		
		select c7 into cons_cfdi from keplersc.kdf3header
			where c1=sucursal_id and c2=genero and c3=naturaleza and c4=grupo::integer and c5=tipo::integer and c6=folio_operacion
			order by c7 desc limit 1;
		if found and cons_cfdi is not null then
				cons_cfdi := coalesce(cons_cfdi,0)+1;		--Consecutivo
			else
				cons_cfdi:= 1;
		end if;
		
		select c6 into serie_docto from keplersc.kdcfdsersucdoc	
			where c1=sucursal_id and c2=genero and c3=naturaleza and c4=grupo::integer and c5=tipo::integer;	--Serie del Documento
		serie_docto:=concat(substring(uen, 1,1),serie_docto);	--uen+serie del documento
		
		--KDMM
		cdf_auto := (xpath('//row/c87/text()', xmlKDMM))[1]; 	--cdf automatico
		area_doc := (xpath('//row/c86/text()', xmlKDMM))[1]; 	--(A)nticipo (F)actura (P)ago Cancelaci(O)n 
		
		ind_naturaleza := 'EGRESO';
		if naturaleza = 'D' then
			ind_naturaleza := 'INGRESO';						--Ingreso, Egreso o Pago
		end if;
		if (xpath('//row/c86/text()', xmlKDMM))[1]::text = 'P' then
			ind_naturaleza := 'PAGO';							--Ingreso, Egreso o Pago
		end if;
		if (genero||naturaleza||grupo = 'UD61') then			--MSS 18022026 La Nota de Credito de una Nota de descto debe ser EGRESO 
			ind_naturaleza := 'EGRESO';
		end if;	
		layout_pdf := (xpath('//row/c88/text()', xmlKDMM))[1];	--Layout de pdf
		strValor := coalesce((xpath('//row/c16/text()', xmlKDMM))[1],'0');
		
	--raise notice 'impto_header%',strValor;
		tasa_impto := strValor::decimal/100;
	----raise notice 'impto_header%',tasa_impto;			
	
		--MSS 24022025 Anulacion por sustitucion: Obtener el dato tipo_relacion y motivo_cancelacion
		--KDM1
		select c9,c14,c16-c14,c16,
			c2,c36,c37,c38,
			c39,c121,c122,c100,regexp_replace(c24,'\r|\n',' ' , 'g'),
			regexp_replace(c25, '\r|\n',' ' , 'g'),regexp_replace(c26, '\r|\n',' ' , 'g'),C11,C17,C18,
			c44,tipo_relacion,motivo_cancelacion
			into fecha_movto,monto_iva,precio_sin_impto,importe,
			gen_docto_anx,nat_docto_anx,gpo_docto_anx,tip_docto_anx,
			folio_docto_anx,tipo_orden,num_orden,cve_inventario,obs1,
			obs2,obs3,referencia,plazo,fec_pago,
			cont_cred,tipo_rel,motivo_cancel
			from keplersc.kdm1 
			where c1=sucursal_id and c2=genero and c3=naturaleza and c4=grupo::integer and c5=tipo::integer and c6=folio_operacion;
			
		select c2 into desc_regfiscal
			from keplersc.kdf3rf
			where c1=regfiscal;
		
		--VCSS 14 Julio 2025, para las facuturas de ordenes de servicio los importes se toman del movimiento kdm1 y no de a orden kdord, como se estaba haciendo		
/*
		if genero='U' and naturaleza='D' and grupo='10' then
			select c62,c61,c63 into monto_iva,precio_sin_impto,importe 
				from keplersc.kdord
				where c1=sucursal_id and c2=tipo_orden and c3=num_orden;
		end if;
*/
	
		fecha_gen_cfdi := coalesce(substring(fecha_gen_cfdi,1,10),substring(fecha_movto::text,1,10));		--Fecha de Generacion
		hora_gen_cdfi := substring(current_time::text,1,8);		--Hora de Generacion
		
		--CFD_HEADER_CLIENTE
		select * into resultado, mensaje, adicionales from keplersc.cfd_header_cliente(dataxml, xmlkdm1, cons_cfdi);
		if resultado = '0' then
				raise exception 'cfd_header_cliente %',mensaje;
		end if;
		--

		--CFD_HEADER_VEHICULO				
		strValor := (xpath('//row/c65/text()', xmlKDMM))[1];
		intValor := strValor::integer;
	--raise notice 'c65:%',intvalor;
		if intValor >=30 then			--kdmm.c65>=30
		
			if (substring(trim(cve_inventario),8,1)='N') then
				select trim(inf.c5),upper(mar.c2),upper(inf.c4),inf.c15,inf.c34,
					inf.c6,inf.c2,inf.c18,iv.c52,inf.c14,
					inf.c13,iv.c54,iv.c50,iv.c51,iv.c53,
					left(inf.c26,4),substring(inf.c26,5,4),right(inf.c26,7),CAST(inf.c27 AS date)
					into vin,marca,modelo,anio_modelo,color,
					num_motor,cve_inventario,clase,procedencia,reg_vehicular,
					cve_vehicular,num_puertas,num_cilindros,num_pasajeros,combustible,
					anio_oper_ad,patente_ad,anio_pedmto_ad,fec_pedmto_ad
					from keplersc.kdinf inf
					inner join keplersc.kdiv iv on iv.c1=inf.c3
					left join keplersc.kdmarca mar on mar.c1=inf.c17
					where inf.c1=sucursal_id and inf.c2=cve_inventario;
			else 
				if substring(trim(cve_inventario),8,1)='U' then
					select trim(inf.c5),upper(inf.c85),upper(inf.c4),inf.c87,inf.c34,
						inf.c6,inf.c2,inf.c18,inf.c90,inf.c14,
						inf.c13,inf.c93,inf.c92,inf.c91,inf.c94,
						left(inf.c26,4),substring(inf.c26,5,4),right(inf.c26,7),CAST(inf.c27 AS date)
						into vin,marca,modelo,anio_modelo,color,
						num_motor,cve_inventario,clase,procedencia,reg_vehicular,
						cve_vehicular,num_puertas,num_cilindros,num_pasajeros,combustible,
						anio_oper_ad,patente_ad,anio_pedmto_ad,fec_pedmto_ad
						from keplersc.kdinf inf
						where inf.c1=sucursal_id and inf.c2=cve_inventario;
				end if;
			end if;
		
			select c2 into desc_clase from keplersc.kdic
				where c1=clase;
			traspaso_ag := 'N';
			strValor := (xpath('//row/c65/text()', xmlKDMM))[1];
			intValor := strValor::integer;
			if intValor = 80 then		--kdmm.c65 =80
				traspaso_ag := 'S';	
			end if;
--raise notice '%','si entro a header vehiculo';
			--CFD_COMPLEMENT					
			select count(*) into totReg from keplersc.kdinf
			where c1=sucursal_id and c2=cve_inventario;
			if totReg>0 then
			--raise notice '%','si entro a if DE HEADER COMPLEMENT';
				for importe_orig,importe_tm,cve_vehic_tm,marca_tm,modelo_tm,anio_tm,num_motor_tm,
					vin_tm,val_libro_tm,num_importa_tm,fec_import_tm,niv_tm,aduana_tm
					in select c9,c10,c4,c16,c5,c6,c11,c7,c17,c12,c13,c8,c14
					from keplersc.kdtomas 
				where c1=sucursal_id and c2=cve_inventario
					
				loop 
						--raise notice 'cve_vehic_tm:%',cve_vehic_tm;
					if cve_vehic_tm <> '' then
						insert into keplersc.kdf3complement (
							c1,c2,c3,c4,c5,
							c6,c7,c8,c9,c10,
							c11,c12,c13,c14,c15,
							c16,c17,c18,c19,c20,
							c21)
							values(
							sucursal_id,genero,naturaleza,grupo::integer,tipo::integer,
							folio_operacion,cons_cfdi,conscompl,importe_orig,importe_tm,
							cve_vehic_tm,marca_tm,modelo_tm,anio_tm,num_motor_tm,
							vin_tm,val_libro_tm,coalesce(num_importa_tm,''),coalesce(to_char(cast(fec_import_tm as date),'DD/MM/YYYY'),''),niv_tm,
							coalesce(aduana_tm,''));
						conscompl := conscompl+1;
					--raise notice '%','si entro INSERTA EN  complement';
					end if;		
				end loop;				
			end if;
		end if;
		--

		--CFD_HEADER_SERVICIO			
		
		select count(*) into totReg
			from keplersc.kdord ord
			inner join keplersc.kdserie ser on ser.c1 = ord.c6
			inner join keplersc.kdmarcas mar on mar.c1 = ser.c2
			where ord.c1=sucursal_id and ord.c2=tipo_orden and ord.c3=num_orden;
		if totReg>0 then
			select ser.c4,mar.c2,ser.c3,ser.c11,ser.c10,ser.c5,ord.c20,ser.c8,ord.c22
				into vin,marca,modelo,anio_modelo,color,num_motor,kilometraje,placas,asesor
				from keplersc.kdord ord
				inner join keplersc.kdserie ser on ser.c1 = ord.c6
				inner join keplersc.kdmarcas mar on mar.c1 = ser.c2
				where ord.c1=sucursal_id and ord.c2=tipo_orden and ord.c3=num_orden;
		
		end if;
		-- 

		--CFD_HEADER_EXTRAS		
		/*		Se quita validacion de fec_pago de acuerdo a libreria de Imcelaya 27/12/2023											
		if genero = 'U' and naturaleza = 'A' then 	
			select current_date into fec_pago;		--Si es pago cambia la fecha de pago
		end if;
		*/
		--MSS 24102024 Obtener fecha del pago si no trae fecha valida
		if (genero = 'U' and naturaleza = 'A' and (xpath('//row/c36/text()', xmlkdm1))[1]::text <>'') or (flag_cobros = 'ANULACION_COB') then	--MSS 22122024 Anulacion de cobro 	
			if substring(fec_pago,1,10)='1800-01-01' then
				gpo_anx := (xpath('//row/c37/text()', xmlkdm1))[1]::text;
				tipo_anx := (xpath('//row/c38/text()', xmlkdm1))[1]::text;
				select c18 into fec_pago_docto_p from keplersc.kdm1
					where c1=sucursal_id and c2=genero and c3=(xpath('//row/c36/text()', xmlkdm1))[1]::text and c4=gpo_anx::integer 
					and c5=tipo_anx::integer and c6=(xpath('//row/c39/text()', xmlkdm1))[1]::text;
				if found then
					fec_pago := fec_pago_docto_p;	
				end if;
			end if;
		end if;
	
		select c55,c19 into siniestro,bonete from keplersc.kdord k 
			where c1=sucursal_id and c2=tipo_orden and c3=num_orden;
		select c8 into transmision from keplersc.kdinf
			where c1=sucursal_id and c2=cve_inventario;
		select c7 into desc_docto from keplersc.kdcfdsersucdoc
			where c1=sucursal_id and c2=genero and c3=naturaleza and c4=grupo::integer and c5=tipo::integer;
		
		movimiento_sustitucion='';
		if motivo_cancel <> '' and folio_docto_anx <>'' then 		--MSS 23052025 Anulacion por sustitucion
			select c2,c36,c37,c38,c39 into gen_orig,nat_orig,gpo_orig,tpo_orig,folio_orig from keplersc.kdm1		--obtener el registro original
				where c1=sucursal_id and c2=genero and c3=naturaleza and c4=grupo::integer and c5=tipo::integer and c6=folio_operacion and motivo_cancelacion ='01';
	
			select c2,c3,c4,c5,c6 into gen_sust,nat_sust,gpo_sust,tpo_sust,folio_sust from keplersc.kdm1			--obtener el registro sustitucion
				where c1=sucursal_id and c2=genero and c36=nat_orig and c37=gpo_orig::integer and c38=tpo_orig::integer and c39=folio_orig and tipo_relacion='04';
		
			movimiento_sustitucion=concat(coalesce(gen_sust,''),coalesce(nat_sust,''),lpad(coalesce(gpo_sust,'0')::text,2,'0'),lpad(coalesce(tpo_sust,'0')::text,3,'0'),'-',folio_sust);
		end if;
	
		insert into keplersc.kdf3headextras (
			c1,c2,c3,c4,c5,
			c6,c7,c8,c9,c10,
			c11,c12,c13,c14,c15,
			c16,c17,c19,c20,motivo_cancelacion,
			movto_sustitucion)
			values(
			sucursal_id,genero,naturaleza,grupo::integer,tipo::integer,
			folio_operacion,cons_cfdi::integer,coalesce(obs1,''),coalesce(obs2,''),coalesce(obs3,''),
			coalesce(referencia,''),coalesce(plazo,'0')::integer,coalesce(to_char(cast(fec_pago as date),'DD/MM/YYYY'),''),coalesce(siniestro,''),coalesce(bonete,''),
			coalesce(transmision,''),coalesce(desc_docto,''),coalesce(regfiscal,''),coalesce(desc_regfiscal,''),coalesce(motivo_cancel,''), 		--MSS 24022025 Anulacion por sustitucion
			coalesce(movimiento_sustitucion,'')); 																									--MSS 09052025 Anulacion por sustitucion
		--
		monto_base_impto := precio_sin_impto;		 				--monto de base para impuesto
		if monto_base_impto <=0 then
			monto_base_impto := 0.01;								--No puede ser 0 la base del impjuesto
		end if;
		if monto_iva <=0 then										--SI NO SE PAGA IVA, POR EJEMPLO UN SEMINUEVO SIN UTILIDAD BRUTA
			monto_base_impto := precio_sin_impto;					----monto de base para impuesto
			if substring(cve_inventario,8,1) = 'U' then				--B7938 ES CVE INVENTARIO Y SE OBTIENE DE LA FUNCION CFD_HEADER_VEHICULO dato cve_inventario se 
				monto_base_impto := 0.01;							--Es una operacion de un seminuevo sin Utilidad
				if flag_cobros = 'APLICA_ANTICIPO' then
					tasa_impto := 0;								--MSS 23022026 Los anticipos sin IVA que aplican a facturas de unidades seminuevas les envie tasa de impto = 0
				end if;	
			end if;
		end if;
		
		if folio_docto_anx <>'' then
			if tipo_rel <>'' then									--MSS 24022025 Anulacion por sustitucion
				tipo_rel_notcred := tipo_rel;
			else
				if flag_cobros = 'APLICA_ANTICIPO' then				--MSS 16102025 Aplicacion de anticipos
					f_pago_sat = 30;								--La forma de pago para Aplicacion de anticipos simpre debe ser 30-Aplicacion de anticipo
					tipo_rel_notcred := '07';						--Tipo de Relacion para Aplicacion de anticipos debe se 07
				else
					tipo_rel_notcred := '01';						--Tipo de Relacion Nota de Credito
					
					--MSS 08012026 Relacionar el anticipo seleccionado en KDF3NCANT con la factura 
					if naturaleza = 'D' then
						select count(*) into totReg	from keplersc.kdf3ncant
							where c1=sucursal_id and tipo_relacion='07' and genero_doctorel=genero and naturaleza_doctorel=naturaleza and grupo_doctorel=grupo::integer and tipo_doctorel=tipo::integer and folio_relacionado=folio_operacion; 
	
						if totReg>0 then
							select c2,c3,c4,c5,c6,tipo_relacion 
								into gen_docto_anx,nat_docto_anx,gpo_docto_anx,tip_docto_anx,folio_docto_anx,tipo_rel_notcred 
								from keplersc.kdf3ncant
								where c1=sucursal_id and tipo_relacion='07' and genero_doctorel=genero and naturaleza_doctorel=naturaleza and grupo_doctorel=grupo::integer and tipo_doctorel=tipo::integer and folio_relacionado=folio_operacion; 
						end if;
					end if;
				
				end if;
			end if;
		end if;
	
		if tiporelacion <>'' then 									--MSS 17022025 Relacion CFDI  Este codigo solo si se usan datos tipo relacion y folio relacionado de la pantalla de validacion de CFDI
			tipo_rel_notcred := tiporelacion;
			gen_docto_anx := gen_folrel;
			nat_docto_anx := nat_folrel;
			gpo_docto_anx := gpo_folrel;
			tip_docto_anx := tpo_folrel; 
			folio_docto_anx := foliorelacionado;
		end if;
	 --raise notice 'paso insert .kdf3headextras %',folio_docto_anx;
		--MSS 24/09/2024 Escapar & y '
		razon_social := regexp_replace(razon_social,'&AMP;','&','gi');
		razon_social:=regexp_replace(razon_social,'\\''','''','gi');
		insert into keplersc.kdf3header (
			c1,c2,c3,c4,c5,
			c6,c7,c8,c9,c10,
			c11,c12,c13,c14,c15,
			c16,c17,c18,c19,c20,
			c21,c22,c23,c24,c25,
			c27,c28,c29,c30,		
			c31,c32,c33,c34,c35,
			c36,c37,c38,c39,c40,
			c41,c42,c43,c44,c45,		
			c46,c47,c48,c49,c50,
			c51,c52,c54,c55,
			c56,c57,c58,
			c64,c65,
			c66,c67,c68,c69)
			values(
			sucursal_id,genero,naturaleza,grupo::integer,tipo::integer,
			folio_operacion,cons_cfdi::integer,usuario,cdf_auto,area_doc,
			ind_naturaleza,layout_pdf,serie_docto,to_char(cast(fecha_gen_cfdi as date),'DD/MM/YYYY'),hora_gen_cdfi,
			metodo_pago,precio_sin_impto,importe,cp_sat,f_pago_sat,
			coalesce(cuenta,''),uso_cfdi,rfc,coalesce(correo,''),coalesce(razon_social,''),
			coalesce(vin,''),coalesce(marca,''),coalesce(modelo,''),coalesce(anio_modelo,''),
			coalesce(color,''),coalesce(num_motor,''),coalesce(tipo_orden,''),coalesce(num_orden,''),coalesce(kilometraje,0),
			coalesce(placas,''),coalesce(asesor,''),coalesce(cve_inventario,''),coalesce(desc_clase,''),coalesce(procedencia,''),
			coalesce(reg_vehicular,''),coalesce(cve_vehicular,''),coalesce(num_puertas,''),coalesce(num_cilindros,''),coalesce(num_pasajeros,''),
			coalesce(combustible,''),coalesce(anio_oper_ad,''),coalesce(patente_ad,''),coalesce(anio_pedmto_ad,''),coalesce(to_char(cast(fec_pedmto_ad as date),'DD/MM/YYYY'),''), 
			coalesce(cont_cred,''),coalesce(traspaso_ag,''),cve_impto,tipo_factor,
			monto_iva,tasa_impto,monto_base_impto,
			coalesce(tipo_rel_notcred,''),coalesce(gen_docto_anx,''),
			coalesce(nat_docto_anx,''),coalesce(gpo_docto_anx,'0')::integer,coalesce(tip_docto_anx,'0')::integer,coalesce(folio_docto_anx,''));
		
		resultado := 1;
		mensaje := cons_cfdi;			--Regresa el Consecutivo CFDI
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
	end if;
exception
	when others then
		raise notice '%',sqlerrm;
		resultado := 0;
		mensaje := 'cfd_header() ' || '['|| sqlstate || '] ' || sqlerrm;
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
end;
$function$
