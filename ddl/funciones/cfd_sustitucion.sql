CREATE OR REPLACE FUNCTION keplersc.cfd_sustitucion(xmlkdm1 xml, xmlkdmm xml, folio_operacion text)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$

--Descripcion: Realiza alta de sustitucion en KDF3SUSTITUCION. Resuelve CFD_SUSTITUCION
--Autor: Miriam Santana
--Fecha: 11/11/2022
--29/10/2024 Miriam Santana: Ya no habra sustituciones seran anulaciones y se cambia c86='O' para manejarla como cancelacion

declare
	--Variables de definicion de documento
	sucursal_id text;
	genero text;
	naturaleza text;
	grupo text;
	fecha_operacion text; --yyyy-mm-dd
	tipo text;
	nat_docto_anx text;
	gpo_docto_anx text;
	tipo_docto_anx text;
	folio_docto_anx text;
	fec_docto_anx text;
	
	--Variables de uso general
	totReg int;

	--Variables de retorno
	resultado text;
	mensaje text;
	adicionales text;

begin
	sucursal_id := (xpath('//row/c1/text()',xmlKDM1))[1];
	genero := (xpath('//row/c2/text()',xmlKDM1))[1];
	naturaleza := (xpath('//row/c3/text()',xmlKDM1))[1];
	grupo := (xpath('//row/c4/text()',xmlKDM1))[1];
	tipo := (xpath('//row/c5/text()',xmlKDM1))[1];
	fecha_operacion := (xpath('//row/c9/text()',xmlKDM1))[1];
	nat_docto_anx := (xpath('//row/c36/text()',xmlKDM1))[1];
	gpo_docto_anx := (xpath('//row/c37/text()',xmlKDM1))[1];
	tipo_docto_anx := (xpath('//row/c38/text()',xmlKDM1))[1];
	folio_docto_anx := (xpath('//row/c39/text()',xmlKDM1))[1];

	if (xpath('//row/c80/text()',xmlKDMM))[1]::text ='S' and (xpath('//row/c86/text()',xmlKDMM))[1]::text ='O' then
		select c9 into fec_docto_anx from keplersc.kdm1
			where c1=sucursal_id and c2=genero and c3=nat_docto_anx and c4=gpo_docto_anx::integer and c5=tipo_docto_anx::integer and c6=folio_docto_anx;
		if found then
			select count(*) into totReg
				from keplersc.kdf3sustitucion
				where c1=sucursal_id and c2=genero and c3=nat_docto_anx and c4=gpo_docto_anx::integer and c5=tipo_docto_anx::integer and c6=folio_docto_anx;
			if totReg=0 then
				insert into keplersc.kdf3sustitucion  (
					c1,c2,c3,c4,c5,
					c6,c7,c8,c9,c10,
					c11)
				values(
					sucursal_id,genero,nat_docto_anx,gpo_docto_anx::integer,tipo_docto_anx::integer,
					folio_docto_anx,to_date(fec_docto_anx,'YYYY-MM-DD'),grupo::integer,tipo::integer,folio_operacion,
					to_date(fecha_operacion,'YYYY-MM-DD'));
			end if;
		end if;
	end if;

	resultado := 1;
	mensaje := '';
	adicionales := '';
	return query select resultado, mensaje, adicionales;	

exception
	when others then
		resultado := 0;
		mensaje := 'cfd_sustitucion() ' || '['|| sqlstate || '] ' || sqlerrm;
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
	
end;
$function$
