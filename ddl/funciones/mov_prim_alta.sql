CREATE OR REPLACE FUNCTION keplersc.mov_prim_alta(dataxml xml, folio_operacion text)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
--Descripcion: Realiza insercion de encabezados de documentos en KDM1
--Autor: Victor Salgado
--Fecha: 21/06/2021
--Bitacora de cambios
--25/07/22 Miriam Santana:
--Completar la insercion de las 200 columnas, se estandarizan 
--los nombres de los campos para la interfaz grafica K80 
--12/01/2024 (JMM) :
---- Se Incluyen Campos UUID al final (con otra nomenclatura) 
---- para las Operaciones de los Documentos que aplique, en este caso dentro del Nvo Esquema de  CxP 
--29/02/2024 (JMM) :
---- Se Incluyen Campos Prov_Pago al final 
---- para las Operaciones de los Documentos que aplique, dentro del Nvo Esquema de CxP 
--23/04/2024 ... 24/04/2024 (JMM) :
---- Se Incluyen Campos Asociados a la Referencia Complementaria ( DOC.Devolucion_Clientes) 
---- para las Operaciones de los Comtrarecibos Tipo DEV CLIE, dentro del Nvo Esquema de CxP 
--24/04/2024 ... 24/04/2024 (JMM) :
---- Se Incluyen Operacion para Detectar Devoluciones de Anticipos y Marcar Estatus para poder Generar
---- posteriormente Contrarecibos Tipo DEV CLIE, dentro del Nvo Esquema de CxP
--29/01/2025 Miriam Santana: Grabar el estatus del pago en las anulaciones de cobros
--24/02/2025 Miriam Santana: Grabar tipo de relacion, motivo de cancelacion por sustitucion y el c43='C' para la factura anulada x sustitucion
--12/03/2025 Miriam Santana: Grabar la forma de pago 30-Aplicacion de anticipos para flag_cobros=APLICA_ANTICIPO
--06/07/2025 Victor Salgado: Agregar columnas complemento de impuestos
--25/07/2025 Miriam Santana: Para la bonificacion cxp anulada marcar el c43='C' y no hacer validacion de UUID asociado en las anulaciones por que es una XA
 				  
declare
	--Variables de definicion de documento
	sucursal_desc text;
	sucursal_id text;
	tipo_desc text;
	genero text;
	naturaleza text;
	grupo text;
	tipo_compuesto text;
	tipo_clave text;

	--Variables de transaccion
	porc_ret_isr text;
	porc_ret_iva text;
	res_fac_rojo text;
	afecta_inv text;
	operacion text;
	fecha_operacion text; --yyyy-mm-dd
	clave_cteprov text = '0';

	clave_vendedor text = '';

	rfc_cteprov text = '';
	datos_cteprov text = '';
	nombre_cteprov text = '';
	calle_cteprov text = '';
	colonia_cteprov text = '';
	poblacion_cteprov text = '';

	iva_desglosado text = '';
	serie_vehiculo text = '';


	cp_cteprov text = '';
	moneda text  = '';
	num_almacen text = '0';  
	
	referencia text = '';
	plazo text;
	plazo_vencimiento text;
	condiciones text = '';
	comentarios text = '';
	subtotal text = '0';
	monto_iva text = '0';
	monto_total text = '0';
	
	--Inicio datos agregados 
	comentarios2 text = '';
	comentarios3 text = '';

	monto_desc text = '0'; 
	monto_ieps_ret text = '0';
	monto_iva_ret text = '0';
	naturaleza_docto text = '';
	grupo_docto text = '0';
	tipo_docto text = '0';
	folio_docto text = '';
	paridad text = '';
	
	porc_desc1 text = '0.00';
	porc_desc2 text = '0.00';
	porc_desc3 text = '0.00';

	fecha_ref text;
	saldo_docto text = '0';
	estado_movto text = '';
	clave_proyecto text = '';
	clave_banco_subcta text = '';

	clave_cteprov_sec text = '';
	destinatario_chq text = '';
	nombre_pers_solic text = '';
	monto_anticipo text = '0';
	porc_comision_vend text = '0';

	monto_extra1 text = '0';
	monto_extra2 text = '0';
	monto_extra3 text = '0';
	monto_extra4 text = '0';
	monto_extra5 text = '0';
	monto_extra6 text = '0';
	monto_extra7 text = '0';
	monto_extra8 text = '0';
	monto_extra9 text = '0';
	monto_extra10 text = '0';

	clave_depto text = '';
	hora_pagoentrega text; 
	no_usar_c63 text = '';
	no_usar_c64 text = '';
	no_usar_c65 text = '0';

	prov_real text = '';
	no_usar_c70 text = '';
	no_usar_c71 text = '';
	no_usar_c72 text = '';
	no_usar_c73 text = '';
	no_usar_c74 text = '';
	no_usar_c75 text = '';
	no_usar_c76 text = '';
	no_usar_c77 text = '';
	no_usar_c78 text = '';
	no_usar_c79 text = '';
	uso_libre_c80 text = '';
	uso_libre_c81 text = '';
	uso_libre_c82 text = '';

	importe_docto text = '0';
	vencimiento_docto text = '';
	empresa_cobro text = '';

	dias_retraso text = '0';
	tasa_int_mor_anual text = '0';
	uso_libre_c88 text = '';
	importe text = '0';
	desc_mano_obra text = '0';

	desc_refacciones text = '0';
	desc_tots text = '0';
	desc_varios text = '0';
	sin_descrip_c94 text = '0';
	sin_descrip_c95 text = '0';

	sin_descrip_c96 text = '';
	tipo_operacion text = '';
	nombre_impresion_fact text = '';
	clave_inventario text = '';

	valor_unidad text = '0';
	porc_enganche text = '0';
	valor_enganche text = '0';
	sin_descrip_c104 text = '';
	monto_financiar text = '0';

	interes_porc_anual text = '0';
	num_pagos text = '0';
	tipo_pagos text = '';
	valor_pagos text = '0';
	tipo_auto text = '';

	porc_cobranza text = '0';
	valor_cobranza text = '0';
	intereses_mor text = '0';
	sin_descrip_c114 text = '';
	nombre_aval text = '';

	direccion_aval text = '';
	colonia_aval text = '';
	poblacion_aval text = '';
	rfc_aval text = '';
	sin_descrip_c120 text = '';

	punto text = '0';
	descrip_tot text = '';
	sin_descrip_c125 text = '';

	sin_descrip_c126 text = '';
	sin_descrip_c127 text = '';	
	sin_descrip_c128 text = '';
	sin_descrip_c129 text = '';

	bonete text = '';

	color text = '';
	sin_descrip_c142 text = '';
	sin_descrip_c143 text = '';	
	sin_descrip_c144 text = '';
	sin_descrip_c145 text = '';

	sin_descrip_c146 text = '';
	sin_descrip_c147 text = '';
	sin_descrip_c148 text = '';
	sin_descrip_c149 text = '';
	clave_cobro1 text = '';

	fol_ref_descrip1 text = '';
	monto1 text= '0';
	clave_cobro2 text = '';
	fol_ref_descrip2 text = '';
	monto2 text= '0';

	clave_cobro3 text = '';
	fol_ref_descrip3 text = '';
	monto3 text= '0';
	sin_descrip_c159 text = '';

	sin_descrip_c166 text = '';
	sin_descrip_c167 text = '';
	sin_descrip_c168 text = '';
	sin_descrip_c169 text = '';
	sin_descrip_c170 text = '';

	sin_descrip_c171 text = '';
	sin_descrip_c172 text = '';
	sin_descrip_c173 text = '';
	sin_descrip_c174 text = '';
	sin_descrip_c175 text = '';

	sin_descrip_c176 text = '';
	sin_descrip_c177 text = '';
	sin_descrip_c178 text = '';
	sin_descrip_c179 text = '';
	sin_descrip_c180 text = '';

	sin_descrip_c181 text = '';
	sin_descrip_c182 text = '';
	sin_descrip_c183 text = '';
	sin_descrip_c184 text = '';
	sin_descrip_c185 text = '';

	sin_descrip_c186 text = '';
	sin_descrip_c187 text = '';
	sin_descrip_c188 text;
	sin_descrip_c189 text = '';
	sin_descrip_c190 text = '';

	sin_descrip_c191 text;
	sin_descrip_c192 text = '';
	sin_descrip_c193 text = '';
	sin_descrip_c194 text = '';
	sin_descrip_c195 text;

	sin_descrip_c196 text = '';
	sin_descrip_c197 text;
	sin_descrip_c198 text = '';
	sin_descrip_c199 text = '';
	sin_descrip_c200 text = '';

	--Added 20240112 by JMM , UUID Info 
	serie_uuid text = '';
	folio_uuid text = '';
	total_uuid text = '';
	fechatimbrado_uuid text = '';
	impuesto_uuid text = '';
	totreg int;
	--Added 20240617 by JMM , Extra UUID Info
	isrret_uuid text = '';
	ivaret_uuid text = '';

	--VCSS 06 Jul  2025, variables complemento de impuestos
	iepstras_uuid text = '';
	totalimptoret_uuid text ='';
	totalimptotras_uuid text ='';
	subtotal_uuid text = '';
	otroimptoa_uuid text = '';
	otroimptob_uuid text = '';

	--Added 20240229 by JMM , Proveedor de Pago
	clave_provpago text = '';

	--Added 20240322 by JMM, Tranfer to_regtype
	transfer_type text = ''; 
	flag_gastos text = '';

	--Added 20240328 by JMM, Contra-Recibo to_regtype (x Comprobar)
	cr_type text = ''; 
	cr_st text = '';
	ref_compl text = ''; 

	--Added 20240423 by JMM, Contra-Recibo to_regtype (DEV Clientes)
	aux_gen text = ''; 
	aux_nat text = '';
	aux_gpo text = '0'; 
	aux_tip text = '0';
	aux_folio text = '';
	totalReg numeric;
	mensajeError text = '';

	--Added 20240424 by JMM
	doc_gen text = '';
	doc_nat text = '';
	doc_gpo text = '';
	doc_tip text = '';
	doc_param text = '';

	--Added 20240828 by JMM , Grupo de Gasto
	clave_gpogasto text = '';

	--Added 20240905 by JMM
	ref_aux text = '';

	--Fin datos agregados

	metodo_de_pago text = '';
	forma_de_pago text = '';
	numero_cuenta text = '';
	uso_cfdi text = '';
	correo text = '';
	regfiscal text = '';		--cfdi 4.00

	pedimento text = '';

	iva_retpedimento text;
	usuario_movto text;
	fecha_movto text;
	hora_movto text;
	no_partidas int;
	no_coment_partida text= '0';
	no_caract_coment_part text= '0';
	tipo_movto text = '123'; 

	--vehiculo
	uen text = '';

	--vehiculo
	marca text = '';
	modelo text = '';
	motor text = '';
	transmision text = '';
	ejetrasero text = '';
	placas text = '0';
	anio text = '';
	kilometraje numeric = 0;
	fechaventa date = '1800-01-01 00:00:00';

	--fact taller
	tipo_orden text = '';
	orden text = '';

	flag_cobros text = '';	--MSS 29012025 Anulacion de cobro
	tipo_rel text = '';		--MSS 24022025 Anulacion por sustitucion
	motivo_cancel text = '';--MSS 24022025 Anulacion por sustitucion
	flag_anulacion text = '';--MSS 24022025 Anulacion por sustitucion
	

	--Variables de retorno
	resultado text;
	mensaje text;
	adicionales text;

	--variables de uso general
	strValor text;

begin
	sucursal_desc := (xpath('//document/k_sucn/r0/text()', dataxml))[1];
	sucursal_id := (xpath('//document/k_sucn/r1/text()', dataxml))[1];

	--Tipo de documento
	tipo_desc := (xpath('//document/k_tipon/r0/text()', dataxml))[1]; 
	genero := (xpath('//document/k_tipon/r1/text()', dataxml))[1];
	naturaleza := (xpath('//document/k_tipon/r2/text()', dataxml))[1];
	grupo := (xpath('//document/k_tipon/r3/text()', dataxml))[1];
	tipo_clave := (xpath('//document/k_tipon/r4/text()', dataxml))[1];
	tipo_compuesto := (xpath('//document/k_tipon/r5/text()', dataxml))[1];
	porc_ret_isr := coalesce((xpath('//document/k_tipon/r7/text()', dataxml))[1]::text,'0');

	-- Included by JMM 221120 
	uen := coalesce((xpath('//document/ambiente/uen/text()', dataxml))[1]::text,'');

	if porc_ret_isr = 'N' then
		porc_ret_isr = '0';
	end if;

	porc_ret_iva := coalesce((xpath('//document/k_tipon/r6/text()', dataxml))[1]::text,'0');
	if porc_ret_iva = 'N' then
		porc_ret_iva = '0';
	end if;
	res_fac_rojo := coalesce((xpath('//document/k_tipon/r9/text()', dataxml))[1]::text,'0')::text;
	afecta_inv := coalesce((xpath('//document/k_tipon/r10/text()', dataxml))[1]::text,'S')::text;

	--Operacion	
	operacion := coalesce((xpath('//document/operacion/text()', dataxml))[1]::text,'');	
	
	--fecha
	fecha_operacion := coalesce((xpath('//document/k_fecha/text()', dataxml))[1]::text,'1800-01-01 00:00:00')::text;
			  
	--cteprov
	clave_cteprov := coalesce((xpath('//document/k_clave/text()', dataxml))[1]::text,'0')::text;

	clave_vendedor := coalesce((xpath('//document/k_vendedor/text()', dataxml))[1]::text,'')::text;
	
	if clave_cteprov <> '0' then 
		if substring(clave_cteprov,1,1) = 'C' then 
			--MSS 230223: Obtener datos del regimen fiscal para grabarlos en la col kdm1.c166, nueva version cfdi 4.0
			select ud.c3,ud.c4,ud.c5,ud.c6,ud.c10,ud.c27,coalesce(ud.c54,'') 
				into nombre_cteprov ,calle_cteprov,colonia_cteprov,poblacion_cteprov,rfc_cteprov,cp_cteprov,regfiscal 
				from keplersc.kdud ud where ud.c2=clave_cteprov;	
		else 
			select c3,c4,c5,c6,c10,c27 into nombre_cteprov ,calle_cteprov,colonia_cteprov,poblacion_cteprov,
				rfc_cteprov,cp_cteprov from keplersc.kdxd where c2=clave_cteprov;
		end if;
	else
		nombre_cteprov := coalesce((xpath('//document/k_descr/text()', dataxml))[1]::text,'SIN DESCRIPCION')::text;
	end if;

	--raise notice 'valor RFC %',rfc_cteprov;
	iva_desglosado := coalesce((xpath('//document/k_ivadesglosado/r0/text()',dataxml))[1]::text,'')::text;

	serie_vehiculo := coalesce((xpath('//document/k_serievehiculo/text()',dataxml))[1]::text,'')::text;

	--Moneda
	moneda := coalesce((xpath('//document/k_moneda/r0/text()', dataxml))[1]::text,'PESOS')::text;

	--Paridad
	paridad := coalesce((xpath('//document/k_paridad/text()', dataxml))[1]::text,'1')::text;
	--Numero almacen
	num_almacen := coalesce((xpath('//document/k_numalmacen/text()',dataxml))[1]::text,'0')::text;
	--Refrerencia guia
	referencia := coalesce((xpath('//document/k_refer/text()',dataxml))[1]::text,'')::text;

	--Plazo
	plazo := coalesce((xpath('//document/k_plazo/text()',dataxml))[1]::text,'0')::text;

	plazo_vencimiento:= coalesce((xpath('//document/k_vence/text()',dataxml))[1]::text,'1800-01-01 00:00:00')::text;

	--Condiciones
	condiciones:= coalesce((xpath('//document/k_cond/text()',dataxml))[1]::text,'0')::text;

	--Comentarios
	comentarios := coalesce((xpath('//document/k_coment/text()',dataxml))[1]::text,'')::text;
	comentarios2 := coalesce((xpath('//document/k_coment2/text()',dataxml))[1]::text,'')::text;
	comentarios3 := coalesce((xpath('//document/k_coment3/text()',dataxml))[1]::text,'')::text;	
	
	--Numero comentarios partida
	no_coment_partida := coalesce((xpath('//document/k_ncomentp/text()',dataxml))[1]::text,'0')::text;
	
	--Numero caracteres comentarios partida
	no_caract_coment_part := coalesce((xpath('//document/ncharcomentp/text()',dataxml))[1]::text,'0')::text;
	
	--Tipo movimiento 
	tipo_movto := coalesce((xpath('//document/k_tipon/r0/text()',dataxml))[1]::text,'123')::text;

	--Totales
	subtotal := coalesce((xpath('//document/subt/text()',dataxml))[1]::text,'0')::text;
	monto_iva := coalesce((xpath('//document/k_iva/text()',dataxml))[1]::text,'0')::text;
	monto_total := coalesce((xpath('//document/k_monto/text()',dataxml))[1]::text,'0')::text;
	
		if subtotal = '0' then 
		subtotal = monto_total; 
	end if;

	monto_desc := coalesce((xpath('//document/k_mdesc/text()',dataxml))[1]::text,'0')::text;
	monto_ieps_ret := coalesce((xpath('//document/k_miepsret/text()',dataxml))[1]::text,'0')::text;
	monto_iva_ret := coalesce((xpath('//document/k_mivaret/text()',dataxml))[1]::text,'0')::text;

	porc_desc1 := coalesce((xpath('//document/k_pdesc1/text()',dataxml))[1]::text,'0.00')::text;
	porc_desc2 := coalesce((xpath('//document/k_pdesc2/text()',dataxml))[1]::text,'0.00')::text;
	porc_desc3 := coalesce((xpath('//document/k_pdesc3/text()',dataxml))[1]::text,'0.00')::text;
	
	naturaleza_docto := coalesce((xpath('//document/k_natdocto/text()',dataxml))[1]::text,'')::text;--c36
	grupo_docto := coalesce((xpath('//document/k_gpodocto/text()',dataxml))[1]::text,'0')::text;--c37
	tipo_docto := coalesce((xpath('//document/k_tipodocto/text()',dataxml))[1]::text,'0')::text;--c38
	folio_docto := coalesce((xpath('//document/k_foliodocto/text()',dataxml))[1]::text,'')::text;--c39
	
	fecha_ref := coalesce((xpath('//document/k_fecref/text()', dataxml))[1]::text,'1800-01-01 00:00:00')::text;	--41
	saldo_docto := coalesce((xpath('//document/k_saldodocto/text()',dataxml))[1]::text,'0')::text;
	estado_movto := coalesce((xpath('//document/k_edodocto/text()',dataxml))[1]::text,'')::text;
	clave_proyecto := coalesce((xpath('//document/k_proyecto/text()',dataxml))[1]::text,'')::text;
	clave_banco_subcta := coalesce((xpath('//document/k_subctabanco/text()',dataxml))[1]::text,'')::text;

	clave_cteprov_sec := coalesce((xpath('//document/k_clavecteprovsec/text()',dataxml))[1]::text,'')::text;
	destinatario_chq := coalesce((xpath('//document/k_destinatariochq/text()',dataxml))[1]::text,'')::text;
	nombre_pers_solic := coalesce((xpath('//document/k_nombreperssolic/text()',dataxml))[1]::text,'')::text;
	monto_anticipo := coalesce((xpath('//document/k_montoanticipo/text()',dataxml))[1]::text,'0')::text;
	porc_comision_vend := coalesce((xpath('//document/k_porccomisionvend/text()',dataxml))[1]::text,'0')::text;

	monto_extra1 := coalesce((xpath('//document/k_montoext1/text()',dataxml))[1]::text,'0')::text;
	monto_extra2 := coalesce((xpath('//document/k_montoext2/text()',dataxml))[1]::text,'0')::text;
	monto_extra3 := coalesce((xpath('//document/k_montoext3/text()',dataxml))[1]::text,'0')::text;
	monto_extra4 := coalesce((xpath('//document/k_montoext4/text()',dataxml))[1]::text,'0')::text;
	monto_extra5 := coalesce((xpath('//document/k_montoext5/text()',dataxml))[1]::text,'0')::text;
	monto_extra6 := coalesce((xpath('//document/k_montoext6/text()',dataxml))[1]::text,'0')::text;
	monto_extra7 := coalesce((xpath('//document/k_montoext7/text()',dataxml))[1]::text,'0')::text;
	monto_extra8 := coalesce((xpath('//document/k_montoext8/text()',dataxml))[1]::text,'0')::text;
	monto_extra9 := coalesce((xpath('//document/k_montoext9/text()',dataxml))[1]::text,'0')::text;
	monto_extra10 := coalesce((xpath('//document/k_montoext10/text()',dataxml))[1]::text,'0')::text;

	clave_depto := coalesce((xpath('//document/k_clavedepto/text()',dataxml))[1]::text,'')::text;
	hora_pagoentrega := coalesce((xpath('//document/k_horapagent/text()',dataxml))[1]::text,'')::text;
	no_usar_c63 := coalesce((xpath('//document/k_nousarc63/text()',dataxml))[1]::text,'')::text;
	no_usar_c64 := coalesce((xpath('//document/k_nousarc64/text()',dataxml))[1]::text,'')::text;
	no_usar_c65 := coalesce((xpath('//document/k_nousarc65/text()',dataxml))[1]::text,'0')::text;

	prov_real := coalesce((xpath('//document/k_provreal/text()',dataxml))[1]::text,'')::text;
	no_usar_c70 := coalesce((xpath('//document/k_nousarc70/text()',dataxml))[1]::text,'')::text;
	no_usar_c71 := coalesce((xpath('//document/k_nousarc71/text()',dataxml))[1]::text,'')::text;
	no_usar_c72 := coalesce((xpath('//document/k_nousarc72/text()',dataxml))[1]::text,'')::text;
	no_usar_c73 := coalesce((xpath('//document/k_nousarc73/text()',dataxml))[1]::text,'')::text;
	no_usar_c74 := coalesce((xpath('//document/k_nousarc74/text()',dataxml))[1]::text,'')::text;
	no_usar_c75 := coalesce((xpath('//document/k_nousarc75/text()',dataxml))[1]::text,'')::text;
	no_usar_c76 := coalesce((xpath('//document/k_nousarc76/text()',dataxml))[1]::text,'')::text;
	no_usar_c77 := coalesce((xpath('//document/k_nousarc77/text()',dataxml))[1]::text,'')::text;
	no_usar_c78 := coalesce((xpath('//document/k_nousarc78/text()',dataxml))[1]::text,'')::text;
	no_usar_c79 := coalesce((xpath('//document/k_nousarc79/text()',dataxml))[1]::text,'')::text;
	uso_libre_c80:= coalesce((xpath('//document/k_usolibrec80/text()',dataxml))[1]::text,'')::text;

	uso_libre_c81 := coalesce((xpath('//document/k_usolibrec81/text()',dataxml))[1]::text,'')::text;
	uso_libre_c82 := coalesce((xpath('//document/k_usolibrec82/text()',dataxml))[1]::text,'')::text;
	importe_docto := coalesce((xpath('//document/k_importedocto/text()',dataxml))[1]::text,'0')::text;
	vencimiento_docto := coalesce((xpath('//document/k_vencimientodocto/text()', dataxml))[1]::text,'1800-01-01 00:00:00')::text;	
	empresa_cobro := coalesce((xpath('//document/k_empresacobro/text()',dataxml))[1]::text,'')::text;

	dias_retraso := coalesce((xpath('//document/k_diasretraso/text()',dataxml))[1]::text,'0')::text;
	tasa_int_mor_anual := coalesce((xpath('//document/k_tasaintmoranual/text()',dataxml))[1]::text,'0')::text;
	uso_libre_c88 := coalesce((xpath('//document/k_usolibrec88/text()',dataxml))[1]::text,'')::text;
	importe := coalesce((xpath('//document/k_importe/text()',dataxml))[1]::text,'0')::text;
	desc_mano_obra := coalesce((xpath('//document/k_descmanoobra/text()',dataxml))[1]::text,'0')::text;
	
	desc_refacciones := coalesce((xpath('//document/k_descrefaccion/text()',dataxml))[1]::text,'0')::text;
	desc_tots := coalesce((xpath('//document/k_desctots/text()',dataxml))[1]::text,'0')::text;
	desc_varios := coalesce((xpath('//document/k_descvarios/text()',dataxml))[1]::text,'0')::text;
	sin_descrip_c94 := coalesce((xpath('//document/k_sindesc94/text()',dataxml))[1]::text,'0')::text;
	sin_descrip_c95 := coalesce((xpath('//document/k_sindesc95/text()',dataxml))[1]::text,'0')::text;

	sin_descrip_c96 := coalesce((xpath('//document/k_sindesc96/text()',dataxml))[1]::text,'')::text;
	tipo_operacion := coalesce((xpath('//document/operacion/text()', dataxml))[1]::text,'')::text;--c97

	nombre_impresion_fact := coalesce((xpath('//document/k_nombreimprfact/text()',dataxml))[1]::text,'')::text;
	clave_inventario := coalesce((xpath('//document/k_claveinv/text()',dataxml))[1]::text,'')::text;

	valor_unidad := coalesce((xpath('//document/k_valorunid/text()',dataxml))[1]::text,'0')::text;
	porc_enganche := coalesce((xpath('//document/k_porcenganche/text()',dataxml))[1]::text,'0')::text;
	valor_enganche := coalesce((xpath('//document/k_valorenganche/text()',dataxml))[1]::text,'0')::text;
	sin_descrip_c104 := coalesce((xpath('//document/k_sindesc104/text()',dataxml))[1]::text,'')::text;
	monto_financiar := coalesce((xpath('//document/k_montofinan/text()',dataxml))[1]::text,'0')::text;

	interes_porc_anual := coalesce((xpath('//document/k_intporcanual/text()',dataxml))[1]::text,'0')::text;
	num_pagos := coalesce((xpath('//document/k_numpagos/text()',dataxml))[1]::text,'0')::text;
	tipo_pagos := coalesce((xpath('//document/k_tipopagos/text()',dataxml))[1]::text,'')::text;
	valor_pagos := coalesce((xpath('//document/k_valorpagos/text()',dataxml))[1]::text,'0')::text;
	tipo_auto := coalesce((xpath('//document/k_tipoauto/text()',dataxml))[1]::text,'')::text;

	porc_cobranza := coalesce((xpath('//document/k_porccobr/text()',dataxml))[1]::text,'0')::text;
	valor_cobranza := coalesce((xpath('//document/k_valorcobr/text()',dataxml))[1]::text,'0')::text;
	intereses_mor := coalesce((xpath('//document/k_intmor/text()',dataxml))[1]::text,'0')::text;
	sin_descrip_c114 := coalesce((xpath('//document/k_sindesc114/text()',dataxml))[1]::text,'')::text;
	nombre_aval := coalesce((xpath('//document/k_nombreaval/text()',dataxml))[1]::text,'')::text;

	direccion_aval := coalesce((xpath('//document/k_direccaval/text()',dataxml))[1]::text,'')::text;
	colonia_aval := coalesce((xpath('//document/k_coloniaaval/text()',dataxml))[1]::text,'')::text;
	poblacion_aval := coalesce((xpath('//document/k_poblacaval/text()',dataxml))[1]::text,'')::text;
	rfc_aval := coalesce((xpath('//document/k_rfcaval/text()',dataxml))[1]::text,'')::text;
	sin_descrip_c120 := coalesce((xpath('//document/k_sindesc120/text()',dataxml))[1]::text,'')::text;

	punto := coalesce((xpath('//document/k_punto/text()',dataxml))[1]::text,'0')::text;
	descrip_tot := coalesce((xpath('//document/k_descriptot/text()',dataxml))[1]::text,'')::text;
	sin_descrip_c125 := coalesce((xpath('//document/k_sindesc125/text()',dataxml))[1]::text,'')::text;

	sin_descrip_c126 := coalesce((xpath('//document/k_sindesc126/text()',dataxml))[1]::text,'')::text;
	sin_descrip_c127 := coalesce((xpath('//document/k_sindesc127/text()',dataxml))[1]::text,'')::text;
	sin_descrip_c128 := coalesce((xpath('//document/k_sindesc128/text()',dataxml))[1]::text,'')::text;
	sin_descrip_c129 := coalesce((xpath('//document/k_sindesc129/text()',dataxml))[1]::text,'')::text;

	bonete := coalesce((xpath('//document/k_bonete/text()',dataxml))[1]::text,'')::text;

	color := coalesce((xpath('//document/k_color/text()',dataxml))[1]::text,'')::text;
	sin_descrip_c142 := coalesce((xpath('//document/k_sindesc142/text()',dataxml))[1]::text,'')::text;
	sin_descrip_c143 := coalesce((xpath('//document/k_sindesc143/text()',dataxml))[1]::text,'')::text;
	sin_descrip_c144 := coalesce((xpath('//document/k_sindesc144/text()',dataxml))[1]::text,'')::text;
	sin_descrip_c145 := coalesce((xpath('//document/k_sindesc145/text()',dataxml))[1]::text,'')::text;
	
	sin_descrip_c146 := coalesce((xpath('//document/k_sindesc146/text()',dataxml))[1]::text,'')::text;
	sin_descrip_c147 := coalesce((xpath('//document/k_sindesc147/text()',dataxml))[1]::text,'')::text;
	sin_descrip_c148 := coalesce((xpath('//document/k_sindesc148/text()',dataxml))[1]::text,'')::text;
	sin_descrip_c149 := coalesce((xpath('//document/k_sindesc149/text()',dataxml))[1]::text,'')::text;
	clave_cobro1 := coalesce((xpath('//document/k_clavecobro1/text()',dataxml))[1]::text,'')::text;

	fol_ref_descrip1 := coalesce((xpath('//document/k_folrefdesc1/text()',dataxml))[1]::text,'')::text;
	monto1 := coalesce((xpath('//document/k_monto1/text()',dataxml))[1]::text,'0')::text;
	clave_cobro2 := coalesce((xpath('//document/k_clavecobro2/text()',dataxml))[1]::text,'')::text;
	fol_ref_descrip2 := coalesce((xpath('//document/k_folrefdesc2/text()',dataxml))[1]::text,'')::text;
	monto2 := coalesce((xpath('//document/k_monto2/text()',dataxml))[1]::text,'0')::text;

	clave_cobro3 := coalesce((xpath('//document/k_clavecobro3/text()',dataxml))[1]::text,'')::text;
	fol_ref_descrip3 := coalesce((xpath('//document/k_folrefdesc3/text()',dataxml))[1]::text,'')::text;
	monto3 := coalesce((xpath('//document/k_monto3/text()',dataxml))[1]::text,'0')::text;
	sin_descrip_c159 := coalesce((xpath('//document/k_sindesc159/text()',dataxml))[1]::text,'')::text;
	forma_de_pago := coalesce((xpath('//document/k_f_pago/r1/text()',dataxml))[1]::text,'')::text;

	sin_descrip_c166 := coalesce((xpath('//document/k_sindesc166/text()',dataxml))[1]::text,'')::text;
	sin_descrip_c167 := coalesce((xpath('//document/k_sindesc167/text()',dataxml))[1]::text,'')::text;
	sin_descrip_c168 := coalesce((xpath('//document/k_sindesc168/text()',dataxml))[1]::text,'')::text;
	sin_descrip_c169 := coalesce((xpath('//document/k_sindesc169/text()',dataxml))[1]::text,'')::text;
	sin_descrip_c170 := coalesce((xpath('//document/k_sindesc170/text()',dataxml))[1]::text,'')::text;

	sin_descrip_c171 := coalesce((xpath('//document/k_sindesc171/text()',dataxml))[1]::text,'')::text;
	sin_descrip_c172 := coalesce((xpath('//document/k_sindesc172/text()',dataxml))[1]::text,'')::text;
	sin_descrip_c173 := coalesce((xpath('//document/k_sindesc173/text()',dataxml))[1]::text,'')::text;
	sin_descrip_c174 := coalesce((xpath('//document/k_sindesc174/text()',dataxml))[1]::text,'')::text;
	sin_descrip_c175 := coalesce((xpath('//document/k_sindesc175/text()',dataxml))[1]::text,'')::text;

	sin_descrip_c176 := coalesce((xpath('//document/k_sindesc176/text()',dataxml))[1]::text,'')::text;
	sin_descrip_c177 := coalesce((xpath('//document/k_sindesc177/text()',dataxml))[1]::text,'')::text;
	sin_descrip_c178 := coalesce((xpath('//document/k_sindesc178/text()',dataxml))[1]::text,'')::text;
	sin_descrip_c179 := coalesce((xpath('//document/k_sindesc179/text()',dataxml))[1]::text,'')::text;
	sin_descrip_c180 := coalesce((xpath('//document/k_sindesc180/text()',dataxml))[1]::text,'')::text;

	sin_descrip_c181 := coalesce((xpath('//document/k_sindesc181/text()',dataxml))[1]::text,'')::text;
	sin_descrip_c182 := coalesce((xpath('//document/k_sindesc182/text()',dataxml))[1]::text,'')::text;
	sin_descrip_c183 := coalesce((xpath('//document/k_sindesc183/text()',dataxml))[1]::text,'')::text;
	sin_descrip_c184 := coalesce((xpath('//document/k_sindesc184/text()',dataxml))[1]::text,'')::text;
	sin_descrip_c185 := coalesce((xpath('//document/k_sindesc185/text()',dataxml))[1]::text,'')::text;

	sin_descrip_c186 := coalesce((xpath('//document/k_sindesc186/text()',dataxml))[1]::text,'')::text;
	sin_descrip_c187 := coalesce((xpath('//document/k_sindesc187/text()',dataxml))[1]::text,'')::text;
	sin_descrip_c188 := coalesce((xpath('//document/k_sindesc188/text()', dataxml))[1]::text,'1800-01-01 00:00:00')::text;		
	sin_descrip_c189 := coalesce((xpath('//document/k_sindesc189/text()',dataxml))[1]::text,'')::text;
	sin_descrip_c190 := coalesce((xpath('//document/k_sindesc190/text()',dataxml))[1]::text,'')::text;

	sin_descrip_c191 := coalesce((xpath('//document/k_sindesc191/text()', dataxml))[1]::text,'1800-01-01 00:00:00')::text;	
	sin_descrip_c192 := coalesce((xpath('//document/k_sindesc192/text()',dataxml))[1]::text,'')::text;
	sin_descrip_c193 := coalesce((xpath('//document/k_sindesc193/text()',dataxml))[1]::text,'')::text;
	sin_descrip_c194 := coalesce((xpath('//document/k_sindesc194/text()',dataxml))[1]::text,'')::text;
	sin_descrip_c195 := coalesce((xpath('//document/k_sindesc195/text()', dataxml))[1]::text,'1800-01-01 00:00:00')::text;

	sin_descrip_c196 := coalesce((xpath('//document/k_sindesc196/text()',dataxml))[1]::text,'')::text;
	sin_descrip_c197 := coalesce((xpath('//document/k_sindesc197/text()', dataxml))[1]::text,'1800-01-01 00:00:00')::text;	
	sin_descrip_c198 := coalesce((xpath('//document/k_sindesc198/text()',dataxml))[1]::text,'')::text;
	sin_descrip_c199 := coalesce((xpath('//document/k_sindesc199/text()',dataxml))[1]::text,'')::text;
	sin_descrip_c200 := coalesce((xpath('//document/k_sindesc200/text()',dataxml))[1]::text,'')::text;

	flag_cobros :=coalesce((xpath('//document/ambiente/flag_cobros/text()',dataxml))[1]::text,'')::text;		--MSS 29012025 Anulacion de cobro
	tipo_rel := coalesce((xpath('//document/k_tipo_rel/text()',dataxml))[1]::text,'')::text;					--MSS 24022025 Anulacion por sustitucion
	motivo_cancel:= coalesce((xpath('//document/k_motivocancel/r1/text()', dataxml))[1]::text,'')::text;		--MSS 24022025 Anulacion por sustitucion
	flag_anulacion :=coalesce((xpath('//document/ambiente/flag_anulacion/text()',dataxml))[1]::text,'')::text;	--MSS 24022025 Anulacion por sustitucion

	--  * * * * *  Added 20240112 by JMM, UUID Info 
	serie_uuid := '';
	folio_uuid := '';
	total_uuid := '';
	impuesto_uuid := '';
	fechatimbrado_uuid := '';
	-- Added 20240617 by JMM, UUID Info
	isrret_uuid = '';
	ivaret_uuid = '';

	if xpath_exists('//document/uuid/serie/text()', dataxml) = true /*false*/ then 
		serie_uuid := coalesce((xpath('//document/uuid/serie/text()',dataxml))[1]::text,'')::text;
	end if;
	if xpath_exists('//document/uuid/folio/text()', dataxml) = true /*false*/ then 
		folio_uuid := coalesce((xpath('//document/uuid/folio/text()',dataxml))[1]::text,'')::text;
	end if;
	if xpath_exists('//document/uuid/total/text()', dataxml) = true /*false*/ then 
		total_uuid := coalesce((xpath('//document/uuid/total/text()',dataxml))[1]::text,'')::text;
	end if;
	if xpath_exists('//document/uuid/fechatimbrado/text()', dataxml) = true /*false*/ then 
		fechatimbrado_uuid := coalesce((xpath('//document/uuid/fechatimbrado/text()',dataxml))[1]::text,'')::text;
	end if;
	-- Added by JMM 20240226 
	if xpath_exists('//document/uuid/impuesto/text()', dataxml) = true /*false*/ then 
		impuesto_uuid := coalesce((xpath('//document/uuid/impuesto/text()',dataxml))[1]::text,'')::text;
	end if;
	-- Added by JMM 20240617 
	if xpath_exists('//document/uuid/retisr/text()', dataxml) = true /*false*/ then 
		isrret_uuid := coalesce((xpath('//document/uuid/retisr/text()',dataxml))[1]::text,'')::text;
	end if;
	if xpath_exists('//document/uuid/retiva/text()', dataxml) = true /*false*/ then 
		ivaret_uuid := coalesce((xpath('//document/uuid/retiva/text()',dataxml))[1]::text,'')::text;
	end if;

	--VCSS 06 Jul 2025 Complemento de impuestos
	if xpath_exists('//document/uuid/iepstras/text()', dataxml) = true then 
		iepstras_uuid := coalesce((xpath('//document/uuid/iepstras/text()',dataxml))[1]::text,'')::text;
	end if;
	if xpath_exists('//document/uuid/totalimptoret/text()', dataxml) = true then 
		totalimptoret_uuid := coalesce((xpath('//document/uuid/totalimptoret/text()',dataxml))[1]::text,'')::text;
	end if;
	if xpath_exists('//document/uuid/totalimptotras/text()', dataxml) = true then 
		totalimptotras_uuid := coalesce((xpath('//document/uuid/totalimptotras/text()',dataxml))[1]::text,'')::text;
	end if;
	if xpath_exists('//document/uuid/subtotal/text()', dataxml) = true then 
		subtotal_uuid := coalesce((xpath('//document/uuid/subtotal/text()',dataxml))[1]::text,'')::text;
	end if;
	if xpath_exists('//document/uuid/otroimptoa/text()', dataxml) = true then 
		otroimptoa_uuid := coalesce((xpath('//document/uuid/otroimptoa/text()',dataxml))[1]::text,'')::text;
	end if;
	if xpath_exists('//document/uuid/otroimptob/text()', dataxml) = true then 
		otroimptob_uuid := coalesce((xpath('//document/uuid/otroimptob/text()',dataxml))[1]::text,'')::text;
	end if;


	-- Validar que no se repita el uuid ... To Addapting
	if length(/*folio_uuid*/total_uuid) > 0 then
	
		/*condition added by JMM 20240226*/
		if upper(genero) = upper('X') and upper(naturaleza) = upper('A') and upper(flag_anulacion) <> 'ANULACION_BONIF_CXP' then 	--MSS 25072025 no hacer esta validacion para anulacion bonificacion cxp 

			totreg := 0;
			/*
			select count(c1) into totreg from keplersc.kdm1 w 
			where c1 = sucursal_id and c2 = genero and c3 = naturaleza and c4 = grupo::integer and c5 = tipo_clave::integer 
				and c11 = referencia;
			*/
			-- Func Adaptada para su verificacion solo en las Compras (Entradas)
			select count(c11) into totreg from keplersc.kdm1 where c1 = sucursal_id 
					and c2 = 'X' and c3 = 'A' and c11 = referencia 
					and upper(coalesce(c43,'')) <> 'C';	 /*Added by JMM 20240510*/
			if totreg > 0 then
				raise exception '%','El UUID ya ha sido registrado para este tipo de Documento ...';
			end if;
		
		end if;
	
	end if;

	--raise exception '%''%''%''%', serie_uuid, folio_uuid, total_uuid, fechatimbrado_uuid;

	--raise exception '%''%''%''%', total_uuid, impuesto_uuid, isrret_uuid, ivaret_uuid;
	--raise exception '%''%', monto_ieps_ret, monto_iva_ret;

	--  * * * * *  End : UUID Info 


	--  * * * * *  Added 20240229 by JMM, Proveedor de Pago  
	clave_provpago := '';

	if xpath_exists('//document/k_clave_pago/text()', dataxml) = true /*false*/ then 
		clave_provpago := coalesce((xpath('//document/k_clave_pago/text()',dataxml))[1]::text,'')::text;
	end if;

	-- Si no existe dato del Proveedor de Pago, se igualara al Proveedor de la Operacion 
	if length(clave_provpago) = 0 then 
		clave_provpago := clave_cteprov; 
	end if;
	--  * * * * *  End : Proveedor de Pago


	--  * * * * *  Added 20240828 by JMM, Grupo de Gasto (Para CR)
	clave_gpogasto := '';
	if xpath_exists('//document/k_gpo_gasto/text()', dataxml) = true /*false*/ then 
		clave_gpogasto := coalesce((xpath('//document/k_gpo_gasto/text()',dataxml))[1]::text,'')::text;
	end if;
	--  * * * * *  End : Grupo de Gastos


	flag_gastos = '';
	if xpath_exists('//document/ambiente/schema/text()', dataxml) = true /*false*/ then 
		flag_gastos := coalesce((xpath('//document/ambiente/schema/text()',dataxml))[1]::text,'')::text;
	end if;


	-- Moved here, se usara tambien como ST de Validacion en los Transfers (Modulo Gastos)
	-- By JMM 20240416 
	cr_st = '';
	ref_compl = '';
	ref_aux = ''; /*Added by JMM 20240905*/


	--  * * * * *  Added 20240322 by JMM, Tipo Transfer 
	transfer_type = '';
	
	if upper(flag_gastos) = 'CXP_TRANSFER' then
	
		transfer_type := coalesce((xpath('//document/cmb_tipo/r1/text()', dataxml))[1]::text,'')::text;
		if length(transfer_type) = 0 then
			raise exception '%', 'No se obtuvo el dato del Tipo de Transferencia ...';
		else
			/*raise exception '%', transfer_type;*/
			if upper(transfer_type) not in ('B', 'I') then 
				raise exception '%', 'Tipo de Transferencia No Valido ...';
			end if;
		end if;
	
		-- Added by JMM 20240416 
		cr_st = 'T'; 
		-- Para Indentificar REGs del Nuevo Esquema que podran Evaluarse para rollback de alguna(s) partidas
	
	end if;

	--  * * * * *  End : Tipo Transfer 


	--  * * * * *  Added 20241008 by JMM, Tipo Deposito Interno (Empleados) 
	
	if upper(flag_gastos) = 'CXP_DEPOSITO_INTERNO' then
	
		cr_st = 'DI'; 
	
		if length(clave_gpogasto) = 0 then
			raise exception '%', 'El Grupo de Gasto No puede ser vacio ...';
		end if;
	
	end if;

	--  * * * * *  End : Deposito Interno 



	--  * * * * *  Added 20241015 by JMM, Tipo Deposito Interno (Empleados) 
	
	if upper(flag_gastos) = 'CXP_CONTR_REC_INTERNO' then
	
		cr_st = 'I'; 
	
		if length(clave_gpogasto) = 0 then
			raise exception '%', 'El Grupo de Gasto No puede ser vacio ...';
		end if;
	
	end if;

	--  * * * * *  End : Deposito Interno 



	--  * * * * *  Added 20240328 by JMM, Tipo Contra-Recibo 
	cr_type = '';
	-- cr_st = ''; /*Moved Up, Se usara tambien como Estatus de los Transfers*/
	-- ref_compl = ''; /*Este campo de inicio siempre ira en blanco*/ /*Moved Up, para posible uso en otros DOC Types : Modulo Gastos*/

	if upper(flag_gastos) = 'CXP_CONTR_REC' then
		cr_type := coalesce((xpath('//document/chk_pc/text()', dataxml))[1]::text,'')::text;
		if length(cr_type) > 0 and cr_type::integer = 1 then
			cr_st = 'S';
		-- For testing ...
		/*
			raise exception '%', 'Es un Gasto por Comprobar ...';
		else
			raise exception '%', 'No es un Gasto por Comprobar ...';
		*/
		end if;
	end if;
	
	--  * * * * *  End : Tipo Contra-Recibo


	--  * * * * *  Added 20240423 by JMM, Tipo Contra-Recibo DEV CLIE
	aux_gen := ''; 
	aux_nat := '';
	aux_gpo := '0'; 
	aux_tip := '0';
	aux_folio := '';

	if upper(flag_gastos) = 'CXP_CONTR_REC_DEVCLI' then
	
		cr_st = 'D';
	
		if xpath_exists('//document/c_gen/text()', dataxml) = true then 
			aux_gen := coalesce((xpath('//document/c_gen/text()',dataxml))[1]::text,'')::text;
		end if;
		if xpath_exists('//document/c_nat/text()', dataxml) = true then 
			aux_nat := coalesce((xpath('//document/c_nat/text()',dataxml))[1]::text,'')::text;
		end if;
		if xpath_exists('//document/c_gpo/text()', dataxml) = true then 
			aux_gpo := coalesce((xpath('//document/c_gpo/text()',dataxml))[1]::text,'')::text;
		end if;
		if xpath_exists('//document/c_tip/text()', dataxml) = true then 
			aux_tip := coalesce((xpath('//document/c_tip/text()',dataxml))[1]::text,'')::text;
		end if;
		if xpath_exists('//document/c_folio/text()', dataxml) = true then 
			aux_folio := coalesce((xpath('//document/c_folio/text()',dataxml))[1]::text,'')::text;
		end if;
		if xpath_exists('//document/c_ref/text()', dataxml) = true then 
			ref_compl := coalesce((xpath('//document/c_ref/text()',dataxml))[1]::text,'')::text;
		end if;
		--Added by JMM 20240905
		if xpath_exists('//document/c_ref_aux/text()', dataxml) = true then 
			ref_aux := coalesce((xpath('//document/c_ref_aux/text()',dataxml))[1]::text,'')::text;
		end if;
	
		if length(aux_gen) = 0 or length(aux_nat) = 0 or length(aux_gpo) = 0 or length(aux_tip) = 0 
			or length(referencia) = 0 or length(aux_folio) = 0 or length(ref_compl) = 0 
			or length(ref_aux) = 0 /*Added by JMM 20240905*/
		then 
			raise exception '%', 'Los Datos de Devolucion estan Incompletos ...';
		else
		
			--Added by JMM 20240424
			totalReg := 0;
			select count(*) into totalReg from keplersc.kdm1 where c1= sucursal_id 
				and gen_aux = aux_gen and nat_aux = aux_nat and gpo_aux = aux_gpo::integer 
				and tip_aux = aux_tip::integer and folio_aux = aux_folio;
			if totalReg > 0 then
				mensajeError := 'La Devolucion ya fue Procesada ... ' || aux_folio;
				raise exception '%', mensajeError;	
			end if;

			-- Actualizar ST de la DEVOLUCION en kdm1 ... ( Documento Referenciado )
			totalReg := 0;
			select count(*) into totalReg from keplersc.kdm1 where c1 = sucursal_id 
				and c2=aux_gen and c3=aux_nat and c4=aux_gpo::integer and c5=aux_tip::integer  
				and c6=aux_folio and c10=ref_compl and st_x_comprobar='O';
			if totalReg = 0 then
				mensajeError := 'Documento de la Devolucion No fue encontrado ...';
				raise exception '%', mensajeError;	
			else
			
				update keplersc.kdm1 
				set st_x_comprobar='P'
				where c1=sucursal_id and c2=aux_gen and c3=aux_nat and c4=aux_gpo::integer and c5=aux_tip::integer  
					and c6=aux_folio and c10=ref_compl and st_x_comprobar='O';
					
				totalReg := 0;
				select count(*) into totalReg from keplersc.kdm1
				where c1=sucursal_id and c2=aux_gen and c3=aux_nat and c4=aux_gpo::integer and c5=aux_tip::integer  
					and c6=aux_folio and c10=ref_compl and st_x_comprobar='P';
				if totalReg = 0 then
					mensajeError := 'Documento de la Devolucion No Encontrado, o Estatus No Actualizado ...';
					raise exception '%', mensajeError;	
				end if;
			
			end if;
		end if;
	
		-- For testing ...
		/*raise exception '%', 'Es un Gasto de Devolucion a Cliente ...';*/
	
	end if;
	
	--  * * * * *  End : Tipo Contra-Recibo DEV CLIE 


	--  * * * * *  Added 20240424 by JMM, Marcar Estatus de Asociacion de las Devoluciones de Clientes
	-- ... Siempre y cuando exista el documento registrado correctamente en los PARAMs Operativos
	doc_gen := '';
	doc_nat := '';
	doc_gpo := '';
	doc_tip := '';
	doc_param := '';

	select (coalesce(valor,'')) into doc_param from keplersc.param_oper 
	where sucursal = sucursal_id and upper(parametro) = upper('Devolucion Clientes Documento');

	doc_param := trim(doc_param);

	if length(doc_param) > 0 then
		
		doc_gen := trim(split_part(doc_param, '|', 1));	
		doc_nat :=  trim(split_part(doc_param, '|', 2)); 
		doc_gpo := trim(split_part(doc_param, '|', 3));	
		doc_tip :=  trim(split_part(doc_param, '|', 4)); 
	
		if doc_gen = genero and doc_nat = naturaleza and doc_gpo = grupo and doc_tip = tipo_clave then
			
			cr_st = 'O'; -- ST que Califica el DOC (DEV CLIENTE) para Generar Contrarecibo (CxP)
		
			-- For testing ...
			/*raise exception '%', 'Es una Devolucion de Clientes ...';*/
	
		end if;
	
	end if;
			
	--  * * * * *  End : Marcar Estatus de Asociacion de las Devoluciones de Clientes


	--  * * * * *  Added 20240705 by JMM, Se marca como Cancelado (C43) un DOC que es Saldado con Contra-Documento
	-- ... Es decir que No pasa por MOV_PRIM_BAJA y que la Poliza No es una Contra-Poliza ... Aplica para New Schema Expenses (Gastos)

		if upper(genero) = upper('X') and (upper(flag_gastos) = 'CXP_CM_RETENCIONES' or upper(flag_anulacion) = 'ANULACION_BONIF_CXP' ) then 		--MSS 25072025 Marcar el c43 de la bonificacion cxp anulada

			totreg := 0;
		
			if length(trim(naturaleza_docto)) > 0 and length(trim(grupo_docto)) > 0 and length(trim(tipo_docto)) > 0 and length(trim(folio_docto)) > 0 then 
			
				select count(c1) into totreg from keplersc.kdm1 w 
				where c1 = sucursal_id and c2 = genero and c3 = naturaleza_docto and c4 = grupo_docto::integer and c5 = tipo_docto::integer 
					and c6 = folio_docto;
				if totreg = 0 then
					raise exception '%','El Documento a dar de Baja No se encontro ...';
				else 
				
					update keplersc.kdm1 
					set c43 = 'C'
					where c1 = sucursal_id and c2 = genero and c3 = naturaleza_docto and c4 = grupo_docto::integer and c5 = tipo_docto::integer  
					and c6 = folio_docto;
				
					totalReg := 0;
					select count(*) into totalReg from keplersc.kdm1
					where c1 = sucursal_id and c2 = genero and c3 = naturaleza_docto and c4 = grupo_docto::integer and c5 = tipo_docto::integer  
						and c6 = folio_docto and c43 = 'C';
					if totalReg = 0 then
						mensajeError := 'Documento a dar de Baja No Encontrado, o Estatus No Actualizado ...';
						raise exception '%', mensajeError;	
					end if;
				
				end if;
		
			end if;
			
		end if;
		--MSS 29012025 Marcar el c43 del cobro anulado
		if upper(genero) = upper('U') and (upper(flag_cobros) in ('ANULACION_COB','ANULACION_APLICA_ANTICIPO') or upper(flag_anulacion) = 'CANCELA_X_SUST') then	--MSS 24022025 Anulacion por sustitucion
		
			totreg := 0;
		
			if length(trim(naturaleza_docto)) > 0 and length(trim(grupo_docto)) > 0 and length(trim(tipo_docto)) > 0 and length(trim(folio_docto)) > 0 then 
			
				select count(c1) into totreg from keplersc.kdm1 w 
				where c1 = sucursal_id and c2 = genero and c3 = naturaleza_docto and c4 = grupo_docto::integer and c5 = tipo_docto::integer 
					and c6 = folio_docto;
				if totreg = 0 then
					raise exception '%','El Documento a dar de Baja No se encontro ...';
				else 
					update keplersc.kdm1 
						set c43 = 'C', c197=to_date(fecha_operacion,'YYYY-MM-DD')				
						where c1 = sucursal_id and c2 = genero and c3 = naturaleza_docto and c4 = grupo_docto::integer and c5 = tipo_docto::integer  
						and c6 = folio_docto;
				end if;
		
			end if;
			
		end if;
	--  * * * * *  End : Marcar Estatus c43 para Contra-Documentos 

	if upper(flag_cobros) in  ('APLICA_ANTICIPO','ANULACION_APLICA_ANTICIPO') then		--MSS 12032025 Aplicacion de anticipos
		forma_de_pago := 30;
	end if;

	numero_cuenta := coalesce((xpath('//document/k_cuenta/text()',dataxml))[1]::text,'')::text;
	metodo_de_pago := coalesce((xpath('//document/k_m_pago/text()',dataxml))[1]::text,'')::text;
	uso_cfdi := coalesce((xpath('//document/k_cfdi/text()',dataxml))[1]::text,'')::text;
	correo := coalesce((xpath('//document/k_correo/text()',dataxml))[1]::text,'')::text;
		
	pedimento := coalesce((xpath('//document/k_pedimento/text()',dataxml))[1]::text,'0')::text;
	
	iva_retpedimento := coalesce((xpath('//document/k_ivaret/text()',dataxml))[1]::text,'0');
	
	--Movimiento
	usuario_movto := (xpath('//document/movimiento/usuario/text()',dataxml))[1];
	fecha_movto := (xpath('//document/movimiento/fecha/text()',dataxml))[1];
	hora_movto := (xpath('//document/movimiento/hora/text()',dataxml))[1];

	--Partidas
	strValor := (xpath('//document/no_partidas/text()',dataxml))[1];
	no_partidas := strValor::integer;	

	--fact taller
	tipo_orden := coalesce((xpath('//document/k_tipo_orden/r1/text()',dataxml))[1]::text,'')::text;
	orden := coalesce((xpath('//document/k_orden/text()',dataxml))[1]::text,'')::text;

	--TO DO: Verificar, los campos 100 al 105 pertenecen a la parte de la primera parida,
	--       es necesario registrarlos en el encabezado del movto?
	
	--especificaciones vehiculo	
	if serie_vehiculo != '' then
		select c2,c3,c5,c6,c7,c8,c11,c12,c13 into 
		marca,modelo,motor,transmision,ejetrasero,placas,anio,kilometraje,fechaventa 
		from keplersc.kdserie where c4=serie_vehiculo;
	
		-- Code Validation Add by JMM to typing SERIE , 221120
		marca := coalesce(marca,'');
		modelo := coalesce(modelo,'');
		motor := coalesce(motor,'');
		transmision := coalesce(transmision,'');
		ejetrasero := coalesce(ejetrasero,'');
		placas := coalesce(placas,'0');
		anio := coalesce(anio,'');
		kilometraje := coalesce(kilometraje,0.00);
		fechaventa := coalesce(fechaventa,'1800-01-01 00:00:00');
	
	end if;

	-- Implemented by JMM 221120 , based on review w/ VCSS & ES 
	if uen = 'VEN' and genero = 'X' and (naturaleza = 'A' or naturaleza = 'D') and grupo::integer in (6,7) then 
		kilometraje := coalesce((xpath('//document/k_kilometraje/text()',dataxml))[1]::text,'0')::integer;
	end if;

	---saltiel Mod 26/09/2022  Folio_operacion = folio_docto
	if genero = 'U' and  naturaleza = 'D' and  grupo= '40' and tipo_clave = '1' then 
			folio_docto = folio_operacion;
	end if;
	---saltiel Implementado 28/Dic/2022  ISAN
	/*if sucursal_id = '01' and  genero = 'U' and  naturaleza = 'D' and  grupo= '6' and tipo_clave = '1' then 
		monto_ieps_ret := coalesce((xpath('//document/k_isan/text()',dataxml))[1]::text,'0')::text;		
	end if;
	*/

	insert into keplersc.kdm1 (
		c1,c2,c3,c4,c5,
		c6,c7,c8,c9,c10,
		c11,c12,c13,c14,c15,
		c16,c17,c18,c19,c20,
		c21,c22,c23,c24,c25,
		c26,c27,c28,c29,c30,		
		c31,c32,c33,c34,c35,
		c36,c37,c38,c39,c40,
		c41,c42,c43,c44,c45,		
		c46,c47,c48,c49,c50,
		c51,c52,c53,c54,c55,
		c56,c57,c58,c59,c60,
		c61,c62,c63,c64,c65,
		c66,c67,c68,c69,c70,		
		c71,c72,c73,c74,c75,
		c76,c77,c78,c79,c80,
		c81,c82,c83,c84,c85,
		c86,c87,c88,c89,c90,
		c91,c92,c93,c94,c95,		
		c96,c97,c98,c99,c100,
		c101,c102,c103,c104,c105,
		c106,c107,c108,c109,c110,
		c111,c112,c113,c114,c115,
		c116,c117,c118,c119,c120,
		c121,c122,c123,c124,c125,
		c126,c127,c128,c129,c130,		
		c131,c132,c133,c134,c135,		
		c136,c137,c138,c139,c140,
		c141,c142,c143,c144,c145,
		c146,c147,c148,c149,c150,
		c151,c152,c153,c154,c155,
		c156,c157,c158,c159,c160,
		c161,c162,c163,c164,c165,
		c166,c167,c168,c169,c170,
		c171,c172,c173,c174,c175,
		c176,c177,c178,c179,c180,
		c181,c182,c183,c184,c185,
		c186,c187,c188,c189,c190,
		c191,c192,c193,c194,c195,
		c196,c197,c198,c199,c200 
		/*Added 20240112 by JMM*/ 
		,uuid_serie, uuid_folio, uuid_fecha, uuid_total, uuid_impuesto
		,cve_prov_pago,tipo_transfer/*Added 20240322*/,st_x_comprobar/*Added 20240328*/, doc_refer_compl/*Added 20240328*/
		/*Added 20240423 by JMM*/
		,gen_aux,nat_aux,gpo_aux,tip_aux,folio_aux 
		/*Added 20240617 by JMM*/
		,uuid_retisr,uuid_retiva
		/*Added 20240828 by JMM*/
		,grupo_id 
		/*Added 20240905 by JMM*/
		,doc_refer_aux,
		tipo_relacion, motivo_cancelacion, /*MSS 24022025*/
		uuid_trasieps,uuid_totalimptotras,uuid_totalimptoret,uuid_subtotal,uuid_otroimptoa,uuid_otroimptob /*VCSS 06 Jul 2025 */
		)
	values (
		sucursal_id,genero,naturaleza,grupo::integer,tipo_clave::integer,
		folio_operacion,moneda,num_almacen::integer,to_date(fecha_operacion,'YYYY-MM-DD'),clave_cteprov,
		referencia,clave_vendedor,monto_desc::decimal,monto_iva::decimal,monto_ieps_ret::decimal,
		monto_total::decimal,plazo,to_date(plazo_vencimiento,'YYYY-MM-DD'),porc_desc1,porc_desc2,
		porc_desc3,rfc_cteprov,monto_iva_ret::decimal,comentarios,comentarios2,
		comentarios3,pedimento ,no_coment_partida::integer,no_caract_coment_part::integer,condiciones,
		tipo_movto,nombre_cteprov,calle_cteprov,colonia_cteprov,poblacion_cteprov,
		naturaleza_docto,grupo_docto::integer,tipo_docto::integer,folio_docto,paridad::decimal,
		to_date(fecha_ref,'YYYY-MM-DD'),saldo_docto::decimal,estado_movto,clave_proyecto,clave_banco_subcta,
		clave_cteprov_sec,destinatario_chq,nombre_pers_solic,monto_anticipo::decimal,porc_comision_vend::decimal,
		monto_extra1::decimal,monto_extra2::decimal,monto_extra3::decimal,monto_extra4::decimal,monto_extra5::decimal,
		monto_extra6::decimal,monto_extra7::decimal,monto_extra8::decimal,monto_extra9::decimal,monto_extra10::decimal,
		clave_depto,substring(hora_pagoentrega from 1 for 5),no_usar_c63,no_usar_c64,no_usar_c65::decimal,
		prov_real,usuario_movto,to_date(fecha_movto,'YYYY-MM-DD'),substring(hora_movto from 1 for 5),no_usar_c70,
		no_usar_c71,no_usar_c72,no_usar_c73,no_usar_c74,no_usar_c75,
		no_usar_c76,no_usar_c77,no_usar_c78,no_usar_c79,uso_libre_c80,
		uso_libre_c81,uso_libre_c82,importe_docto::decimal,to_date(vencimiento_docto,'YYYY-MM-DD'),empresa_cobro,
		dias_retraso::integer,tasa_int_mor_anual::decimal,uso_libre_c88,importe::decimal,desc_mano_obra::decimal,
		desc_refacciones::decimal,desc_tots::decimal,desc_varios::decimal,sin_descrip_c94::decimal,sin_descrip_c95::decimal,
		sin_descrip_c96,tipo_operacion,iva_desglosado,nombre_impresion_fact,clave_inventario,	
		valor_unidad::decimal,porc_enganche::decimal,valor_enganche::decimal,sin_descrip_c104,monto_financiar::decimal,
		interes_porc_anual::decimal,num_pagos::integer,tipo_pagos,valor_pagos::decimal,tipo_auto,
		porc_cobranza::decimal,valor_cobranza::decimal,intereses_mor::decimal,sin_descrip_c114,nombre_aval,
		direccion_aval,colonia_aval,poblacion_aval,rfc_aval,sin_descrip_c120,
		tipo_orden, orden,punto::integer,descrip_tot,sin_descrip_c125,
		sin_descrip_c126,sin_descrip_c127,sin_descrip_c128,sin_descrip_c129,marca,
		modelo, anio ,serie_vehiculo, fechaventa,motor,--c135
		transmision, ejetrasero, kilometraje,placas,bonete,
		color,sin_descrip_c142,sin_descrip_c143,sin_descrip_c144,sin_descrip_c145,
		sin_descrip_c146,sin_descrip_c147,sin_descrip_c148,sin_descrip_c149,clave_cobro1,
		fol_ref_descrip1,monto1::decimal,clave_cobro2,fol_ref_descrip2,monto2::decimal,
		clave_cobro3,fol_ref_descrip3,monto3::decimal,sin_descrip_c159,forma_de_pago,
		numero_cuenta, metodo_de_pago, cp_cteprov,uso_cfdi, correo,
		regfiscal,sin_descrip_c167,sin_descrip_c168,sin_descrip_c169,sin_descrip_c170,
		sin_descrip_c171,sin_descrip_c172,sin_descrip_c173,sin_descrip_c174,sin_descrip_c175,
		sin_descrip_c176,sin_descrip_c177,sin_descrip_c178,sin_descrip_c179,sin_descrip_c180,
		sin_descrip_c181,sin_descrip_c182,sin_descrip_c183,sin_descrip_c184,sin_descrip_c185,
		sin_descrip_c186,sin_descrip_c187,to_date(sin_descrip_c188,'YYYY-MM-DD'),sin_descrip_c189,sin_descrip_c190,
		to_date(sin_descrip_c191,'YYYY-MM-DD'),sin_descrip_c192,sin_descrip_c193,sin_descrip_c194,to_date(sin_descrip_c195,'YYYY-MM-DD'),
		sin_descrip_c196,to_date(sin_descrip_c197,'YYYY-MM-DD'),sin_descrip_c198,sin_descrip_c199,sin_descrip_c200
		/*Added 20240112 JMM*/
		,serie_uuid,folio_uuid,fechatimbrado_uuid,total_uuid,impuesto_uuid 
		,clave_provpago,transfer_type/*Added 20240322 JMM*/,cr_st/*Added 20240328 JMM*/,ref_compl/*Added 20240328 JMM*/
		/*Added 20240423 JMM*/
		,aux_gen,aux_nat,aux_gpo::integer,aux_tip::integer,aux_folio
		/*Added 20240617 JMM*/
		,isrret_uuid,ivaret_uuid
		/*Added 20240828 JMM*/
		, case when length(clave_gpogasto) = 0 then null else clave_gpogasto::integer end 
		/*Added 20240905 JMM*/
		,ref_aux,
		tipo_rel, motivo_cancel, /*MSS 24022025*/
		iepstras_uuid,totalimptotras_uuid,totalimptoret_uuid,subtotal_uuid,otroimptoa_uuid,otroimptob_uuid /*VCSS 06 Jul 2025 */
		);	
	
	resultado := 1;
	mensaje := '';
	adicionales := '';
	return query select resultado, mensaje, adicionales;	

exception
	when others then
		resultado := 0;
		mensaje := 'mov_prim_alta() ' || '['|| sqlstate || '] ' || sqlerrm;
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
	
end;
$function$
