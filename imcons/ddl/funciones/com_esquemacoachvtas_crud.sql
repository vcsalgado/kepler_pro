CREATE OR REPLACE FUNCTION keplersc.com_esquemacoachvtas_crud(dataxml xml)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
--Descripcion: Realiza crud en KDESQGV
--Autor: Miriam Santana
--Fecha: 17/01/2023
declare
	--Variables de definicion de documento
	sucursal_id text = '';
	esquema text = '';
	bono1objent_nvos text = '';
    bono2objent_nvos text = '';
    bonobjmar_util text = '';
    bonobjsh_fin1 text = '';
    bonobjsh_fin2 text = '';
    bonobj1_csi text = '';
    bonobj2_csi text = '';
    desctounid_atras_nvos text = '';
    desctounid_atras_seminvos text = '';
    bonocomb text = '';
    bonobjfact_nvos text = '';
    bonobj_tomas text = '';
    bonobjvta_gext text = '';
    bonoent_trim text = '';
    bonobj_acces text = '';
    bonobjseg_contado text = '';
    bonocomb_seminvos text = '';
    bonofact_seminvos text = '';
    bonobj1ent_seminvos text = '';
    bonobj2ent_seminvos text = '';
    bonobj1finan_seminvos text = '';
    bonobj2finan_seminvos text = '';
    pagar_flotilla text ='';

   --Variables de retorno
	resultado text;
	mensaje text;
	adicionales text;

begin
	sucursal_id := (xpath('//document/k_sucn/r1/text()', dataxml))[1];
	esquema := (xpath('//document/k_esquema/text()', dataxml))[1];
	bono1objent_nvos := coalesce((xpath('//document/bono1objent_nvos/text()', dataxml))[1],'0');
    bono2objent_nvos := coalesce((xpath('//document/bono2objent_nvos/text()', dataxml))[1],'0');
    bonobjmar_util := coalesce((xpath('//document/bonobjmar_util/text()', dataxml))[1],'0');
    bonobjsh_fin1 := coalesce((xpath('//document/bonobjsh_fin1/text()', dataxml))[1],'0');
    bonobjsh_fin2 := coalesce((xpath('//document/bonobjsh_fin2/text()', dataxml))[1],'0');
    bonobj1_csi := coalesce((xpath('//document/bonobj1_csi/text()', dataxml))[1],'0');
    bonobj2_csi := coalesce((xpath('//document/bonobj2_csi/text()', dataxml))[1],'0');
    desctounid_atras_nvos := coalesce((xpath('//document/desctounid_atras_nvos/text()', dataxml))[1],'0');
    desctounid_atras_seminvos := coalesce((xpath('//document/desctounid_atras_seminvos/text()', dataxml))[1],'0');
    bonocomb := coalesce((xpath('//document/bonocomb/text()', dataxml))[1],'0');
    bonobjfact_nvos := coalesce((xpath('//document/bonobjfact_nvos/text()', dataxml))[1],'0');
    bonobj_tomas := coalesce((xpath('//document/bonobj_tomas/text()', dataxml))[1],'0');
    bonobjvta_gext := coalesce((xpath('//document/bonobjvta_gext/text()', dataxml))[1],'0');
    bonoent_trim := coalesce((xpath('//document/bonoent_trim/text()', dataxml))[1],'0');
    bonobj_acces := coalesce((xpath('//document/bonobj_acces/text()', dataxml))[1],'0');
    bonobjseg_contado := coalesce((xpath('//document/bonobjseg_contado/text()', dataxml))[1],'0');
    bonocomb_seminvos := coalesce((xpath('//document/bonocomb_seminvos/text()', dataxml))[1],'0');
    bonofact_seminvos := coalesce((xpath('//document/bonofact_seminvos/text()', dataxml))[1],'0');
    bonobj1ent_seminvos := coalesce((xpath('//document/bonobj1ent_seminvos/text()', dataxml))[1],'0');
    bonobj2ent_seminvos := coalesce((xpath('//document/bonobj2ent_seminvos/text()', dataxml))[1],'0');
    bonobj1finan_seminvos := coalesce((xpath('//document/bonobj1finan_seminvos/text()', dataxml))[1],'0');
    bonobj2finan_seminvos := coalesce((xpath('//document/bonobj2finan_seminvos/text()', dataxml))[1],'0');
    pagar_flotilla := coalesce((xpath('//document/pagar_flotilla/text()', dataxml))[1],'N');
	
  	if esquema ='' or esquema is null then
		raise exception 'Falta especificar el esquema';
	end if;

   	--Eliminar registros del esquema
	delete from keplersc.kdesqgv 
		where c1=esquema and c25=sucursal_id;

	--Insertar nuevos registros
	insert into keplersc.kdesqgv (
		c1,c2,c3,c4,c5,
		c6,c7,c8,c9,c10,
		c11,c12,c13,c14,c15,
		c16,c17,c18,c19,c20,
		c21,c22,c23,c24,c25)
	values(
		esquema,bono1objent_nvos::decimal,bono2objent_nvos::decimal,bonobjmar_util::decimal,bonobjsh_fin1::decimal,
		bonobjsh_fin2::decimal,bonobj1_csi::decimal,bonobj2_csi::decimal,desctounid_atras_nvos::decimal,desctounid_atras_seminvos::decimal,
		bonocomb::decimal,bonobjfact_nvos::decimal,bonobj_tomas::decimal,bonobjvta_gext::decimal,bonoent_trim::decimal,
		bonobj_acces::decimal,bonobjseg_contado::decimal,bonocomb_seminvos::decimal,bonofact_seminvos::decimal,bonobj1ent_seminvos::decimal,
		bonobj2ent_seminvos::decimal,bonobj1finan_seminvos::decimal,bonobj2finan_seminvos::decimal,pagar_flotilla,sucursal_id);		
	
	resultado := 1;
	mensaje := '';
	adicionales := '';
	return query select resultado, mensaje, adicionales;	

exception
	when others then
		resultado := 0;
		mensaje := 'com_esquemacoachvtas_crud() ' || '['|| sqlstate || '] ' || sqlerrm ;
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
end;
$function$
