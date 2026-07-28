CREATE OR REPLACE FUNCTION keplersc.cat_pedidosugerido_altamod_insert_crud(dataxml xml)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
--Descripcion: Cursores
--Autor: Saltiel Rc
--Fecha: 25/03/2022
--Bitacora de cambios
--RVW & Fixed Struct By JMM 24/08/2023 

declare

v_sucursal_id text = ''; --A1
v_referencia text = ''; --A6 
v_FechaC_A2 text = '';
v_DiasVenBus_A4 text = '';
v_Formula_A7 text = '';

v_contador numeric = 0;

resultado text= '';
mensaje text = '0';
adicionales text = '';
totreg int = 0;
strtTexto text ='';
v_nocatalogo text =''; 

begin
	
	v_sucursal_id := upper((xpath('//document/k_sucn/text()', dataxml))[1]::text); --
	v_referencia := upper((xpath('//document/k_referencia_a6/text()', dataxml))[1]::text); --
	v_FechaC_A2:= upper((xpath('//document/k_fechac_a2/text()', dataxml))[1]::text); --
	v_DiasVenBus_A4:= upper((xpath('//document/k_diasvenbus_a4/text()', dataxml))[1]::text); --
	v_Formula_A7:= upper((xpath('//document/k_formula_a7/text()', dataxml))[1]::text); --
	
	insert into keplersc.KDPEDREF (c1,c2,c3,c4,c5) 
	values (v_sucursal_id,v_referencia,v_FechaC_A2::timestamp,10/*v_DiasVenBus_A4::numeric*/,v_Formula_A7);
	
	resultado ='1';
	mensaje ='Finalizado';
	adicionales ='';
	

return query select resultado, mensaje, adicionales;

exception
	when others then
		resultado := 0;	
		mensaje := 'cat_pedidosugerido_altamod_insert_crud() ' || '['|| sqlstate || '] ' || sqlerrm ;
		adicionales := '';
		return query select resultado, mensaje, adicionales;
end;
$function$
