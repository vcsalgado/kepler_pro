CREATE OR REPLACE FUNCTION keplersc.pld_escribe_lineas(dataxml xml)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
declare
--Descripcion: Genera archivo PDL (prevencion lavado de dinero)
--Autor: Miriam Santana
--Fecha: 24/05/2023
--17/09/2024 Miriam Santana: Agregar datos folio de anulacion o nc y tipo anulacion o nc.
--18/09/2024 Miriam Santana: Agregar validacion en pagos BUS(G,2,0,K1,K5...K9)=0, G es KDVENTAS y K es KDUXE
--07/03/2024 Miriam Santana: Obtener la baja del docto relacionado (folio_anx,desc_docto_anx) de kdm1

	suc_vtas text = '';
	inv_vtas text = '';
	gen_vtas text = '';
	nat_vtas text = '';
	gpo_vtas text = '';
	tpo_vtas text = '';
	folio_vtas text = '';
	fecha_factura date;
	cve_cliente text = '';
	cve_vehiculo text = '';
	tipope_vtas text = '';
	marca text = '';
	nvo_us text = '';
	anio text = '';
	partida_vtas text = '';

	folio_vtas_norm text = '';
	str_folio text = '';
	fecha text = '';
	sujeto_obligado text = '';
	codigo_postal text = '';
	str_tipo_ope text = '';
	desc_marca text = '';
	desc_vehiculo text = '';
	vin text = '';
	repuve text = '';
	rfc text = '';
	nombre_imp text = '';
	nombre text = '';
	ap_paterno text = '';			
	ap_materno text = '';
	colonia text = '';
	calle text = '';
	num_ext text = '';
	cod_postal text = '';
	correo text = '';
	telefono text = '';
	placas text = '';
	m_pago text = '';
	f_pago text = '';
	str_moneda text = '';
  	cfg_fecha_migracion date;
  	importe text = '';

	gen_xe text = '';
	nat_xe text = '';
	gpo_xe text = '';
	tpo_xe text = '';
	folio_xe  text = '';
	str_folio_xe  text = '';

	par_anx int;
	folio_anx text = '';
	desc_docto_anx text = '';
	totReg int;
	strPld text = '';
	cont_linea int =0;
	rec record;
	
	--Variables de retorno
	resultado text;
	mensaje text;
	adicionales text;	
begin
	--raise notice 'Entro escribw lineas';
	suc_vtas := (xpath('//document/suc_vtas/text()', dataxml))[1];
	inv_vtas := (xpath('//document/inv_vtas/text()', dataxml))[1];
	gen_vtas := (xpath('//document/gen_vtas/text()', dataxml))[1];
	nat_vtas := (xpath('//document/nat_vtas/text()', dataxml))[1];
	gpo_vtas := (xpath('//document/gpo_vtas/text()', dataxml))[1];
	tpo_vtas := (xpath('//document/tpo_vtas/text()', dataxml))[1];
	folio_vtas := (xpath('//document/folio_vtas/text()', dataxml))[1];
	fecha_factura := (xpath('//document/fecha_factura/text()', dataxml))[1];
	cve_cliente := (xpath('//document/cve_cliente/text()', dataxml))[1];
	cve_vehiculo := (xpath('//document/cve_vehiculo/text()', dataxml))[1];
	tipope_vtas := (xpath('//document/tipope_vtas/text()', dataxml))[1];
	marca := (xpath('//document/marca/text()', dataxml))[1];
	nvo_us := (xpath('//document/nvo_us/text()', dataxml))[1];
	anio := (xpath('//document/anio/text()', dataxml))[1];
	partida_vtas := coalesce((xpath('//document/partida_vtas/text()', dataxml))[1],'0');

	--INICIO ESCRIBE
	if tipope_vtas = 'TRAS' then 
		str_tipo_ope := concat(nvo_us,' Intercambio');
	else
		str_tipo_ope := nvo_us;
	end if;

	fecha := to_char(cast(fecha_factura as date),'DD/MM/YYYY');
--raise notice 'fecha:% marca:% inv:%',fecha,marca,inv_vtas;
	placas := 'SP';
--MSS 07032025 Obtener la baja del docto relacionado (folio_anx,desc_docto_anx) de kdm1	
	select cfg.c2,dm1.c163,mar.c2,inf.c4,inf.c5,
		inf.c14,dm1.c22,ud.c30,ud.c35,ud.c33,
		ud.c34,ud.c5,ud.c4,ud.c45,ud.c27,
		ud.c11,ud.c7,mp.c2,fp.c2,cfg.c6,round(dm1.c16-dm1.c15-dm1.c14,2)::text,
		coalesce(concat(m1bj.c2,m1bj.c3,lpad(m1bj.c4::text,2,'0'),lpad(m1bj.c5::text,3,'0'),'-',m1bj.c6),''),coalesce(mm.c5,'')
		into sujeto_obligado,codigo_postal,desc_marca,desc_vehiculo,vin,
		repuve,rfc,nombre_imp,nombre,ap_paterno,
		ap_materno,colonia,calle,num_ext,cod_postal,
		correo,telefono,m_pago,f_pago,cfg_fecha_migracion,importe,
		folio_anx,desc_docto_anx
		from keplersc.kdud ud
		inner join keplersc.kdcfdconfig cfg on cfg.c1=suc_vtas
		inner join keplersc.kdm1 dm1 on dm1.c1=cfg.c1 and dm1.c2=gen_vtas and dm1.c3=nat_vtas and dm1.c4=gpo_vtas::integer and dm1.c5=tpo_vtas::integer and dm1.c6=folio_vtas
		left join  keplersc.kdm1 m1bj on m1bj.c1=dm1.c1 and m1bj.c2=dm1.c2 and m1bj.c36=dm1.c3 and m1bj.c37=dm1.c4 and m1bj.c38=dm1.c5 and m1bj.c39=dm1.c6 and m1bj.c2 = 'U' and m1bj.c3 = 'A' and m1bj.c4 in ('70', '60', '63', '22', '21')
		left join keplersc.kdmm mm on mm.c1=m1bj.c2 and mm.c2=m1bj.c3 and mm.c3=m1bj.c4 and mm.c4=m1bj.c5
		inner join keplersc.kdmarca mar on mar.c1=marca
		inner join keplersc.kdinf inf on inf.c1=cfg.c1 and inf.c2=inv_vtas
		inner join keplersc.kdf3mp mp on mp.c1=dm1.c162
		inner join keplersc.kdf3fp fp on fp.c1=dm1.c160
		where ud.c2=cve_cliente;
--raise notice 'cliente:%',cve_cliente;
--raise notice 'sujeto_obligado:%,codigo_postal:%,desc_marca:%,desc_vehiculo:%,vin:%,
--		repuve:%,rfc:%,nombre_imp:%,nombre:%,ap_paterno:%,
--		ap_materno:%,colonia:%,calle:%,num_ext:%,cod_postal:%,
--		correo:%,telefono:%,m_pago:%,f_pago:%',sujeto_obligado,codigo_postal,desc_marca,desc_vehiculo,vin,
--		repuve,rfc,nombre_imp,nombre,ap_paterno,
--		ap_materno,colonia,calle,num_ext,cod_postal,
--		correo,telefono,m_pago,f_pago;
	folio_vtas_norm := '';
   	if fecha_factura::date < cfg_fecha_migracion then
   		folio_vtas_norm = substring(folio_vtas from 2 for 2) || substring(folio_vtas from 6 for 5);
    else
    	folio_vtas_norm := folio_vtas;
    end if;
/*  MSS 07032025 Obtener la baja del docto relacionado (folio_anx,desc_docto_anx) de kdm1
	par_anx := partida_vtas::integer+1;
	folio_anx := '';
	desc_docto_anx := '';

	select coalesce(concat(vt.c4,vt.c5,lpad(vt.c6::text,2,'0'),lpad(vt.c7::text,3,'0'),'-',vt.c8),''),coalesce(mm.c5,'')
		from keplersc.kdventas vt
		into folio_anx,desc_docto_anx
		left join keplersc.kdmm mm on mm.col_sucursal = vt.c1 and mm.c1=vt.c4 and mm.c2=vt.c5 and mm.c3=vt.c6 and mm.c4=vt.c7
		where vt.c1=suc_vtas and vt.c2=inv_vtas and vt.c3=par_anx and vt.c10=10;
*/	
--raise notice 'ESCRIBE suc_vtas:% inv_vtas:% partida_vtas:% par_anx:% folio_anx:%,desc_docto_anx:%',suc_vtas,inv_vtas,partida_vtas,par_anx,folio_anx,desc_docto_anx; 	
  
	str_folio= concat(trim(gen_vtas),trim(nat_vtas),lpad(gpo_vtas::text,2,'0'),lpad(tpo_vtas::text,3,'0'),'-',folio_vtas_norm);
	strPld := concat(
				'"',inv_vtas,'",',
				'"',str_folio,'",',
				'"',inv_vtas,'",',
				'"',sujeto_obligado,'",',
				'"',suc_vtas,'",',
				'"',fecha,'",',
				'"',codigo_postal,'",',
				'"',str_tipo_ope,'",',
				'"',desc_marca,'",',
				'"',desc_vehiculo,'",',
				'"',anio,'",',
				'"',vin,'",',
				'"',placas,'",',
				'"',repuve,'",',
				'"',rfc,'",',
				'"',nombre_imp,'",',
				'"',nombre,'",',
				'"',ap_paterno,'",',
				'"',ap_materno,'",',
				'"',colonia,'",',
				'"',calle,'",',
				'"',num_ext,'",',
				'"',cod_postal,'",',
				'"',correo,'",',
				'"',telefono,'",',
				'"',importe,'",',
				'"',folio_anx,'",',
				'"',desc_docto_anx,'"');
		select coalesce(max(num_linea),0)+1 into cont_linea from tmpResultados;			
--raise notice 'strPld:%',strPld;			
		insert into tmpResultados (num_linea,linea)
			values(cont_linea,strPld);

		str_moneda := 'MXN';

		for rec 
			in select * from keplersc.kduxe 
				where c1=suc_vtas and c2=cve_cliente and c3=folio_vtas and c6='A'
		loop 
			select count(*) into totReg
				from keplersc.kdventas
				where c1=rec.c1 and c4=rec.c5 and c5=rec.c6 and c6=rec.c7 and c7=rec.c8 and c8=rec.c9;
			if totReg=0 then	
				select dm1.c2,dm1.c3,dm1.c4,dm1.c5,dm1.c6,fp.c2,mp.c2
					into gen_xe,nat_xe,gpo_xe,tpo_xe,folio_xe,f_pago,m_pago
					from keplersc.kdm1 dm1
					inner join keplersc.kdf3mp mp on mp.c1=dm1.c162
					inner join keplersc.kdf3fp fp on fp.c1=dm1.c160
					where dm1.c1=rec.c1 and dm1.c2=rec.c5 and dm1.c3=rec.c6 and dm1.c4=rec.c7 and dm1.c5=rec.c8 and dm1.c6=rec.c9;
			    str_folio_xe := '';
			    if rec.c11 < cfg_fecha_migracion then
			    	str_folio_xe = substring(folio_xe from 2 for 2) || substring(folio_xe from 6 for 5);
			    else
			        str_folio_xe := folio_xe;
			    end if;
				str_folio := '';
				str_folio= concat(trim(gen_xe),trim(nat_xe),lpad(gpo_xe::text,2,'0'),lpad(tpo_xe::text,3,'0'),'-',str_folio_xe);
				strPld := concat(
				 		'"',inv_vtas,'",',
						'"',str_folio,'",',
						'"',to_char(cast(rec.c11 as date),'DD/MM/YYYY'),'",',
						'"',f_pago,'",',
						'"',str_moneda,'",',
						'"',rec.c13,'",',
						'"',m_pago,'"');
				select coalesce(max(num_linea),0)+1 into cont_linea from tmpResultados;	
--raise notice 'strPld_2:%',strPld;		
				insert into tmpResultados (num_linea,linea)
					values(cont_linea,strPld);	
			end if;
		end loop;
		--FIN ESCRIBE
							
	resultado := 1;
	mensaje := '';
	adicionales := '';
	return query select resultado, mensaje, adicionales;		
	
exception
	when others then
		resultado := 0;
		mensaje := 'pld_escribe_lineas() ' || '['|| sqlstate || '] ' || sqlerrm;
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
end;
$function$
