CREATE OR REPLACE FUNCTION keplersc.com_catesquemas_crud(dataxml xml)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
--Descripcion: Realiza crud en KDVESQ
--Autor: Miriam Santana
--Fecha: 17/01/2023
declare
	--Variables de definicion de documento
	sucursal_id text = '';
	esquema text = '';
	descripcion text ='';
	sueldobase text ='';
	adicionales1 text ='';
	adicionales2 text ='';
	desctotraspaso text ='';
	aumentoinvent text ='';
	bonotoma text ='';
	diasbonovta text ='';
	bonovta text ='';
	cveseminvo text = '';
	bonoseminvo text ='';
	activo text = '';
	bonosem1 text ='';
	bonosem2 text ='';
	bonosem3 text ='';
	bonosem4 text ='';

   --Variables de retorno
	resultado text;
	mensaje text;
	adicionales text;

begin
	sucursal_id := (xpath('//document/k_sucn/r1/text()', dataxml))[1];
	esquema := (xpath('//document/k_esquema/text()', dataxml))[1];
	descripcion := (xpath('//document/k_descripcion/text()', dataxml))[1];
	sueldobase := coalesce((xpath('//document/k_sueldobase/text()', dataxml))[1],'0');
	adicionales1 := coalesce((xpath('//document/k_adicionales1/text()', dataxml))[1],'0');
	adicionales2 := coalesce((xpath('//document/k_adicionales2/text()', dataxml))[1],'0');
	desctotraspaso := coalesce((xpath('//document/k_desctotraspaso/text()', dataxml))[1],'0');
	aumentoinvent := coalesce((xpath('//document/k_aumentoinvent/text()', dataxml))[1],'0');
	bonotoma := coalesce((xpath('//document/k_bonotoma/text()', dataxml))[1],'0');
	diasbonovta := coalesce((xpath('//document/k_diasbonovta/text()', dataxml))[1],'0');
	bonovta := coalesce((xpath('//document/k_bonovta/text()', dataxml))[1],'0');
	cveseminvo := coalesce((xpath('//document/k_cveseminvo/text()', dataxml))[1],'');
	bonoseminvo := coalesce((xpath('//document/k_bonoseminvo/text()', dataxml))[1],'0');
	activo := coalesce((xpath('//document/k_activo/text()', dataxml))[1],'I');
	bonosem1 := coalesce((xpath('//document/k_bonosem1/text()', dataxml))[1],'0');
	bonosem2 := coalesce((xpath('//document/k_bonosem2/text()', dataxml))[1],'0');
	bonosem3 := coalesce((xpath('//document/k_bonosem3/text()', dataxml))[1],'0');
	bonosem4 := coalesce((xpath('//document/k_bonosem4/text()', dataxml))[1],'0');

	if esquema ='' or esquema is null then
		raise exception 'Falta especificar el esquema';
	end if;

	if descripcion ='' or descripcion is null then
		raise exception 'Falta especificar la descripción del esquema';
	end if;
   	--Eliminar registros del esquema
	delete from keplersc.kdvesq 
		where c1=esquema and c29=sucursal_id;

	--Insertar nuevos registros
	insert into keplersc.kdvesq  (
		c1,c2,c3,c4,c5,
		c7,c8,c10,
		c11,c12,c14,c15,
		c19,
		c25,
		c26,c27,c28,c29)
	values(
		esquema,descripcion,sueldobase::decimal,adicionales1::decimal,adicionales2::decimal,
		desctotraspaso::decimal,aumentoinvent::decimal,bonotoma::decimal,
		diasbonovta::integer,bonovta::decimal,cveseminvo,bonoseminvo::decimal,
		activo,
		bonosem1::decimal,
		bonosem2::decimal,bonosem3::decimal,bonosem4::decimal,sucursal_id);		
	
	resultado := 1;
	mensaje := '';
	adicionales := '';
	return query select resultado, mensaje, adicionales;	

exception
	when others then
		resultado := 0;
		mensaje := 'com_catesquemas_crud() ' || '['|| sqlstate || '] ' || sqlerrm ;
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
end;
$function$
