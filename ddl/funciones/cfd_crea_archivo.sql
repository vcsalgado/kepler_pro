CREATE OR REPLACE FUNCTION keplersc.cfd_crea_archivo(dataxml xml, xmlkdm1 xml, xmlkdmm xml, folio_operacion text)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
declare
--Descripcion: Obtiene información para generar el archivo para el CFD 
--			   Resuelve CFD_CREA_ARCHIVO
--Autor: Miriam Santana
--Fecha: 18/10/2022
	--Variables para xml 
	sucursal_id text;
	genero text;
	naturaleza text;
	grupo text;
	tipo text;
	usuario text;

	--variables de uso general
	cons_cfdi text;
	strValor text = '';
	intValor decimal = 0;
	expSql text='';
	nombre_archivo text;
	strDocumento text;
	strDocumento2 text;
	strVehiculo text;
	strEmisor text;
	strReceptor text;
	strImpuesto text;
	strCliente text;
	strConcepto text;
	strLongconcepto text;
	strRelacion text;
	strComplemento text;
	strAdenda text;
	strExtras text;
	dat_cfdi text = '';	--Pantalla validacion cfdi
	rec record;

	--Variables de retorno
	resultado text;
	mensaje text;
	adicionales text;
	
begin
	sucursal_id := (xpath('//document/k_sucn/r1/text()', dataxml))[1];
	genero := (xpath('//document/k_tipon/r1/text()', dataxml))[1];
	naturaleza := (xpath('//document/k_tipon/r2/text()', dataxml))[1];
	grupo := (xpath('//document/k_tipon/r3/text()', dataxml))[1];
	tipo := (xpath('//document/k_tipon/r4/text()', dataxml))[1];
	dat_cfdi := (xpath('//document/datcfdi/text()', dataxml))[1];			--Pantalla validacion cfdi

/***********Se comenta hasta que se ponga el dato <datcfdi> a todas las pantallas que kdmm.c80='S'(generen CFDI)**********	
	--Pantalla validacion cfdi
	if xpath_exists('//document/datcfdi', dataxml) = false then 
		raise exception 'No tiene pantalla de validacion, avisar al área de sistemas';
	else 
		if dat_cfdi='N' then 
			raise exception 'No se ha Validado la información del cfdi';
		end if;
	end if;
	--
**********Se comenta hasta que se ponga el dato <datcfdi> a todas las pantallas que kdmm.c80='S'(generen CFDI)***********/
	
	drop table if exists tmpResultados;
	create temp table tmpResultados (
		cfdi text);
--raise notice '%', 'INcicia crea_archivo cfd';	
	--CALL CFD_HEADER  
    select * into resultado, mensaje, adicionales from keplersc.cfd_header(dataxml,xmlkdm1,xmlkdmm,folio_operacion); 
	if resultado = '0' then
		raise exception '%',mensaje;
	end if; 
--raise notice '%','termino header';
	cons_cfdi:= mensaje;		--Consecutivo CFDI
--raise notice 'consecutivo cfdi:%', cons_cfdi;
	--CALL CFD_CONCEPT   
    select * into resultado, mensaje, adicionales from keplersc.cfd_concept(dataxml,xmlkdm1, xmlkdmm,cons_cfdi); 
	if resultado = '0' then
		raise exception '%',mensaje;
	end if;    
--raise notice '%','Inicia relat';
	--CALL CFD_RELATION         
	select * into resultado, mensaje, adicionales from keplersc.cfd_relation(dataxml,xmlkdm1,xmlkdmm,cons_cfdi); 
	if resultado = '0' then
		raise exception '%',mensaje;
	end if; 
--raise notice '%','Inicia adenda';
	--CALL CFD_ADENDA    
	select * into resultado, mensaje, adicionales from keplersc.cfd_adenda(dataxml,xmlkdm1,xmlkdmm,cons_cfdi); 
	if resultado = '0' then
		raise exception '%',mensaje;
	end if; 
--raise notice '%','Inicia armado cadenas';
	--Nombre de archivo
--trim(cf.c3) tiene  Ruta del servidor en lugar de 'c:\k80_data\cfd\' 
	select concat(trim(cf.c3),trim(cf.c2),'-',trim(hd.c1),'-',trim(hd.c2),trim(hd.c3),lpad(hd.c4::text,2,'0'),lpad(hd.c5::text,3,'0'),'-',hd.c6,'.F33') 
		into nombre_archivo
		from keplersc.kdcfdconfig cf, keplersc.kdf3header hd
		where hd.c1=sucursal_id and hd.c2=genero and hd.c3=naturaleza and hd.c4=grupo::integer and hd.c5=tipo::integer and hd.c6=folio_operacion and hd.c7=cons_cfdi::integer and cf.c1=hd.c1;
--raise notice 'nombre_archivo:%',nombre_archivo;	
	--Arma cadena de Documento
	strDocumento='DOCUMENTO|3.3|';
	select concat(strDocumento,c10,'|',c11,'|',c12,'|',trim(c1),'-',trim(c2),trim(c3),lpad(c4::text,2,'0'),lpad(c5::text,3,'0'),'-',c6,'|',
			c13,'|',c14,'|',c15,'|',c16,'|',round(c17,2),'|',round(c18,2),'|',c19,'|',c20,'|',c21,'|',c22,'|'),round(c18,2)  
		into strDocumento, intValor 
		from keplersc.kdf3header
		where c1=sucursal_id and c2=genero and c3=naturaleza and c4=grupo::integer and c5=tipo::integer and c6=folio_operacion and c7=cons_cfdi::integer;
	select * into strValor from keplersc.conv_numero_letra(intValor);
	select concat(strValor,'|',c9,'|',c64,'|',c1,'-',c65,c66,lpad(c67::text,2,'0'),lpad(c68::text,3,'0'),'-',c69,'|.') 
		into strDocumento2
		from keplersc.kdf3header
		where c1=sucursal_id and c2=genero and c3=naturaleza and c4=grupo::integer and c5=tipo::integer and c6=folio_operacion and c7=cons_cfdi::integer;	
	strDocumento := concat(strDocumento,strDocumento2);
	insert into tmpResultados (cfdi)
		values(strDocumento);
--raise notice '%','Termina Documento';	
	--Arma cadena de Vehículo
	strVehiculo := 'VEHICULO|';
	select concat(strVehiculo,c27,'|',c28,'|',c29,'|',c30,'|',c31,'|',c32,'|',c33,'|',c34,'|',c35,'|',
			c36,'|',c37,'|',c38,'|',c39,'|',c40,'|',c41,'|',c42,'|',c43,'|',c44,'|',c45,'|',c46,'|',
			c47,'|',c48,'|',c49,'|',c50,'|',c51,'|',c52,'|.')  
		into strVehiculo
		from keplersc.kdf3header
		where c1=sucursal_id and c2=genero and c3=naturaleza and c4=grupo::integer and c5=tipo::integer and c6=folio_operacion and c7=cons_cfdi::integer;
	insert into tmpResultados (cfdi)
		values(strVehiculo);
--raise notice '%','Termina Vehiculo';	
	--Arma cadena de Emisor
	strEmisor := 'EMISOR|';
	select concat(strEmisor,c2,'|.') into strEmisor
		from keplersc.kdcfdconfig
 		where c1=sucursal_id;	
	insert into tmpResultados (cfdi)
		values(strEmisor);
--raise notice '%','Termina emisor';	
	--Arma cadena de Receptor
	strReceptor := 'RECEPTOR|';
	select concat(strReceptor,c23,'|',c24,'|',c25,'|.') into strReceptor
		from keplersc.kdf3header
		where c1=sucursal_id and c2=genero and c3=naturaleza and c4=grupo::integer and c5=tipo::integer and c6=folio_operacion and c7=cons_cfdi::integer;
	insert into tmpResultados (cfdi)
	 	values(strReceptor);
--raise notice '%','Termina receptor';	
	--Arma cadena de Impuesto
	strImpuesto := 'IMPUESTO|';
	select concat(strImpuesto,c54,'|',c55,'|',round(c56,6),'|',round(c57,2),'|',round(c58,6),'|.') into strImpuesto
		from keplersc.kdf3header
		where c1=sucursal_id and c2=genero and c3=naturaleza and c4=grupo::integer and c5=tipo::integer and c6=folio_operacion and c7=cons_cfdi::integer;
	insert into tmpResultados (cfdi)
	 	values(strImpuesto);
--raise notice '%','Termina impuesto';	
	--Arma cadena de Cliente		-->Pueden ser mas de 1 cliente?? UA2901
	strCliente :=  'CLIENTE|';
	select concat(strCliente,c8,'|',c9,'|',c10,'|',c11,'|',c12,'|',c13,'|',c14,'|',c15,'|',c16,'|',c17,'|',c18,'|',c19,'|',c20,'|.')
		into strCliente
		from keplersc.kdf3cliente
		where c1=sucursal_id and c2=genero and c3=naturaleza and c4=grupo::integer and c5=tipo::integer and c6=folio_operacion and c7=cons_cfdi::integer;
	insert into tmpResultados (cfdi)
	 	values(strCliente);
--raise notice '%','Termina cliente';	
	--Arma cadena de Concepto
	for rec in select * from keplersc.kdf3concept
		where c1=sucursal_id and c2=genero and c3=naturaleza and c4=grupo::integer and c5=tipo::integer and c6=folio_operacion and c7=cons_cfdi::integer
	loop
		strConcepto :=  'CONCEPTO|';
		strConcepto := concat(strConcepto,rec.c9,'|',rec.c10,'|',rec.c11,'|',trim(rec.c12));
		select concat(' ',c9,' ',c10,' ',c11,' ',c12,' ',c13,' ',c14,' ',c15,' ',c16,' ',c17,' ',c18,' ',c19,' ',c20,' ',c21,' ',c22,' ',c23,' ',c24,' ',c25,' ',c26,' ',c27,' ',c28) into strlongconcepto
			from keplersc.kdf3longconcept kl 
			where c1=sucursal_id and c2=genero and c3=naturaleza and c4=grupo::integer and c5=tipo::integer and c6=folio_operacion and c7=cons_cfdi::integer and c8=rec.c8;
		if found then
			strConcepto := concat(strConcepto,strlongconcepto);
		end if;
--2dec		strConcepto := concat(strConcepto,'|',round(rec.c13,2),'|',round(rec.c14,2),'|',rec.c15,'|',rec.c16,'|',round(rec.c17,2),'|',rec.c18,'|',rec.c19,'|',round(rec.c20,2),'|.');
		strConcepto := concat(strConcepto,'|',rec.c13,'|',rec.c14,'|',rec.c15,'|',rec.c16,'|',round(rec.c17,2),'|',rec.c18,'|',rec.c19,'|',rec.c20,'|.');
		insert into tmpResultados (cfdi)
		 	values(strConcepto);
	end loop;
--raise notice '%','Termina concepto';		
	--Arma cadena de Relacion
	for rec in select * from keplersc.kdf3relation
		where c1=sucursal_id and c2=genero and c3=naturaleza and c4=grupo::integer and c5=tipo::integer and c6=folio_operacion and c7=cons_cfdi::integer		
	loop	
		strRelacion	:=concat('RELACION|',rec.c9,'|',rec.c10,'-',rec.c11,rec.c12,lpad(rec.c13::text,2,'0'),lpad(rec.c14::text,3,'0'),'-',rec.c15,'|',rec.c16,'|',rec.c17,'|',rec.c18,'|',rec.c19,'|.');
		insert into tmpResultados (cfdi)
		 	values(strRelacion);
	end loop;
--raise notice '%','Termina relacion';
	--Arma cadena de Complemento
	for rec in select * from keplersc.kdf3complement
		where c1=sucursal_id and c2=genero and c3=naturaleza and c4=grupo::integer and c5=tipo::integer and c6=folio_operacion and c7=cons_cfdi::integer
	loop
		strComplemento := 'COMPLEMENTO|';
		strComplemento := concat(strComplemento,rec.c9,'|',rec.c10,'|',rec.c11,'|',rec.c12,'|',rec.c13,'|',rec.c14,'|',rec.c15,'|',rec.c16,'|',rec.c17,'|',rec.c18,'|',rec.c19,'|',rec.c20,'|',rec.c21,'||.'); 
		insert into tmpResultados (cfdi)
		values(strComplemento);
	end loop;
--raise notice '%','Termina complemento';	
	--Arma cadena de Adenda
	for rec in select * from keplersc.kdf3adenda
		where c1=sucursal_id and c2=genero and c3=naturaleza and c4=grupo::integer and c5=tipo::integer and c6=folio_operacion and c7=cons_cfdi::integer
	loop
		strAdenda := 'ADENDA|';
		strAdenda := concat(strAdenda,rec.c8,'/',rec.c9,'/',rec.c10,'/',rec.c11,'||.'); 
		insert into tmpResultados (cfdi)
			values(strAdenda);
	end loop;
	if strAdenda is null then
		strAdenda := 'ADENDA||.';
		insert into tmpResultados (cfdi)
			values(strAdenda);
	end if;
--raise notice '%','Termina adenda';
		--Arma cadena de Extras
	for rec in select * from keplersc.kdf3headextras
		where c1=sucursal_id and c2=genero and c3=naturaleza and c4=grupo::integer and c5=tipo::integer and c6=folio_operacion and c7=cons_cfdi::integer
	loop
		strExtras := 'EXTRAS|';
		strExtras := concat(strExtras,rec.c8,'|',rec.c9,'|',rec.c10,'|',rec.c11,'|',rec.c12,'|',rec.c13,'|',rec.c14,'|',rec.c15,'|',rec.c16,'|',rec.c17,'|',rec.c18,'|',rec.c19,'|',rec.c20,'|'); 
	end loop;
	strExtras := concat(strExtras,'|.');
	insert into tmpResultados (cfdi)
		values(strExtras);

	expSql:= format('copy (select * from tmpresultados) to %1$L',nombre_archivo);
	execute expSql;

		resultado := 1;
		mensaje := '';
		adicionales := '';
		--return query select * from tmpResultados;
		

exception
	when others then
		resultado := 0;
		mensaje := 'cfd_crea_archivo() ' || '['|| sqlstate || '] ' || sqlerrm;
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
end;
$function$
