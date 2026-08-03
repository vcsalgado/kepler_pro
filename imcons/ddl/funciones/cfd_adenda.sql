CREATE OR REPLACE FUNCTION keplersc.cfd_adenda(dataxml xml, xmlkdm1 xml, xmlkdmm xml, cons_cfdi text)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
declare
--Descripcion: Genera informacion para CFDI. Resuelve CFD_ADENDA
--Autor: Miriam Santana
--Fecha: 13/10/2022

	--Variables de definicion de documento	 
	sucursal_id text;
	genero text;
	naturaleza text;
	grupo text;
	tipo text;

	--Variables para xml
	folio_operacion text;
	adenda_id text;
	segmento text;
	variable text;
	valor text;
	cve_cteprov text;

	--Variables de uso general
	totReg int;
	rec_adenda record;
	
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
	folio_operacion := (xpath('//row/c6/text()', xmlKDM1))[1];
	cve_cteprov := (xpath('//document/k_clave/text()', dataxml))[1];
		
    if (xpath('//row/c80/text()', xmlKDMM))[1]::text = 'S' and (xpath('//row/c89/text()', xmlKDMM))[1]::text = 'S' then
		select c1 into adenda_id from keplersc.kdadheader where c3=cve_cteprov;
		if found then
		   	--Detalle adenda
	    	for rec_adenda in select * from keplersc.kdadvariable
	    		where c1=adenda_id
	    	loop
				select count(*) into totReg from keplersc.kdf3adenda 
					where c1=sucursal_id and c2=genero and c3=naturaleza and c4=grupo::integer and c5=tipo::integer and c6=folio_operacion and c7=cons_cfdi::integer
					and c8=adenda_id and c9=rec_adenda.c2 and c10=rec_adenda.c3;
				if totReg>0 then
					delete from keplersc.kdf3adenda 
						where c1=sucursal_id and c2=genero and c3=naturaleza and c4=grupo::integer and c5=tipo::integer and c6=folio_operacion and c7=cons_cfdi::integer
						and c8=adenda_id and c9=rec_adenda.c2 and c10=rec_adenda.c3;
				end if;			

				insert into keplersc.kdf3adenda 
					(c1,c2,c3,c4,c5,
					c6,c7,c8,c9,c10,
					c11)
					values(
					sucursal_id,genero,naturaleza,grupo::integer,tipo::integer,
					folio_operacion,cons_cfdi::integer,rec_adenda.c1,rec_adenda.c2,rec_adenda.c3,
					rec_adenda.c4);
				
			end loop;			
		end if;	
	end if;

	resultado := 1;
	mensaje := '';
	adicionales := '';
	return query select resultado, mensaje, adicionales;
exception
	when others then
		resultado := 0;
		mensaje := 'cfd_adenda() ' || '['|| sqlstate || '] ' || sqlerrm;
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
end;
$function$
