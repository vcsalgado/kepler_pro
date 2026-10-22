CREATE OR REPLACE FUNCTION keplersc.refacciones_paquetes_utilizados()
 RETURNS integer
 LANGUAGE plpgsql
AS $function$
--Descripcion: refacciones_paquetes_utilizados
--Autor: Miriam Santana
--Fecha: 01/09/2025
--Bitacora de cambios

declare
	--Variables de definicion de documento
	sucursal_id text = '';
	tipo_orden text = '';
	orden text = '';
	serie_vehiculo text = '';	

	num_punto numeric;
	cve_kit text = '';
	tipo_punto text = '';
	cve_marca text = '';
	cve_modelo text = '';
	num_anio  text = '';
	clave_ref text = '';
	cantidad decimal;

	desc_refacc text = '';
	refacc_w1 text = '';
	refacc_w2 text = '';
	refacc_w3 text = '';
	comilla text = '''';
	signo text = '%';
	refValor text = '';
	descValor text = '';

	duplicadaValor  text = '';
	refacc_duplicadaValor text = '';

	existe int = 0;
	expXml text = '';
	expSql text = '';
	duplicada text = '0';

begin
	for sucursal_id,tipo_orden,orden,num_punto,cve_kit,tipo_punto in 
		select c1,c2,c3,c4,c5,c6 from keplersc.kdpun order by c1,c2,c3,c4
	loop 
		if tipo_punto = 'S'  then 			
			select c6 into serie_vehiculo from keplersc.kdord where c1=sucursal_id and c2=tipo_orden and c3=orden;
			select c2,c3,c11 into cve_marca,cve_modelo,num_anio from keplersc.kdserie where c1=serie_vehiculo;
				if not found then
					raise notice 'Suc:% Tipo:% Orden;% sin Número de Serie ',sucursal_id,tipo_orden,orden;
					continue;
				end if;		
		 --------------------CARGADAS------------------
			for clave_ref,cantidad in select c11,c13 from keplersc.kdref where c1=sucursal_id
			and c2=tipo_orden and c3=orden and c4=num_punto order by c1,c2,c3,c4
			loop 
				select count(*) into existe 
					from keplersc.kdspaqutil
					where marca=cve_marca and modelo=cve_modelo and anio=num_anio and paquete=cve_kit and refaccion=clave_ref;
							
					if existe = 0 then
						select c2 into desc_refacc from keplersc.kdini where c1=clave_ref;
						refacc_w1 = split_part(desc_refacc,' ',1);
						refacc_w2 = split_part(desc_refacc,' ',2);
						refacc_w3 = refacc_w1||' '||refacc_w2;
						
						if refacc_w1 = 'FILTRO' then
							expSql = format('select paq.refaccion, ini.c2,paq.duplicada,paq.refacc_duplicada
									from keplersc.kdspaqutil paq
									inner join keplersc.kdini ini on ini.c1=paq.refaccion
									where marca=%2$L and modelo=%3$L and anio=%4$L and paquete=%5$L and ini.c2 like %6$s%7$s%8$s%9$s
									order by marca ,modelo ,anio, paquete',sucursal_id,cve_marca,cve_modelo,num_anio,cve_kit,comilla,refacc_w3,signo,comilla);						
						else
							expSql = format('select paq.refaccion, ini.c2,paq.duplicada,paq.refacc_duplicada
									from keplersc.kdspaqutil paq
									inner join keplersc.kdini ini on ini.c1=paq.refaccion
									where marca=%2$L and modelo=%3$L and anio=%4$L and paquete=%5$L and ini.c2 like %6$s%7$s%8$s%9$s
									order by marca ,modelo ,anio, paquete',sucursal_id,cve_marca,cve_modelo,num_anio,cve_kit,comilla,refacc_w1,signo,comilla);
						end if;		
raise notice 'cve_marca:% cve_modelo:% num_anio:% cve_kit:% clave_ref:% desc_refacc:% refacc_w1:%',cve_marca,cve_modelo,num_anio,cve_kit,clave_ref,desc_refacc,refacc_w1; 							
										
						execute expSql into refValor,descValor,duplicadaValor,refacc_duplicadaValor;			--Datos refaccion que ya se dio de alta y es parecida a la que se intenta insertar
						--Guarda todo en kdspaqutil e indica cual esta duplicada con cual							
						if length(refValor)>0 then
							if desc_refacc = descValor then 			--desc_refacc-Desc refacc intenta insertar descValor-Desc refacc que ya existe en la tabla--- Descripcion de refaccion = duplicada insertar en kdspaq_poxref
								if duplicadaValor = '1' then				--Si esta duplicada toma el valor de la primera que se duplico	
									refValor = refacc_duplicadaValor;
								end if;
								select count(*) into existe  
									from keplersc.kdspaq_posxref 
									where marca=cve_marca and modelo=cve_modelo and anio=num_anio and paquete=cve_kit and refaccion=refValor and posible_refacc=clave_ref;
								if existe = 0 then
									insert into keplersc.kdspaq_posxref (
										marca,modelo,anio,paquete,refaccion,posible_refacc)
									values(
										cve_marca,cve_modelo,num_anio,cve_kit,refValor,clave_ref);
								end if;
								duplicada = '1';
--raise notice 'refacc_w1:% refacc_w2:% refacc_w3:% refacc:% desc:% refaccdup:% desc:%',refacc_w1,refacc_w2,refacc_w3,clave_ref,desc_refacc,refValor,descValor;	
raise notice 'orden:% pto:% refacc:% desc:% refaccdup:% desc:%',orden,num_punto,clave_ref,desc_refacc,refValor,descValor;
							else 
								duplicada = '0';
								refValor='';
								descValor='';
							end if; 						
						else 
							duplicada = '0';
							refValor='';
							descValor='';
						end if;
					
						insert into keplersc.kdspaqutil  (
							marca,modelo,anio,
							paquete,refaccion,cantidad,duplicada,refacc_duplicada)
						values(
							cve_marca,cve_modelo,num_anio,
							cve_kit,clave_ref,cantidad,duplicada,coalesce(refValor,'')
						);
										
						refValor='';
						descValor='';
					
					end if;
			
			end loop;
		end if;

	end loop;
return 1;
	exception
	when others then
		raise exception '%', sqlerrm;	
end;
$function$
