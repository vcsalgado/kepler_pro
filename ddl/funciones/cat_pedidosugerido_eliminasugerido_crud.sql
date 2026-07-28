CREATE OR REPLACE FUNCTION keplersc.cat_pedidosugerido_eliminasugerido_crud(dataxml xml)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
--Descripcion: Cursores
--Autor: Saltiel Rc
--Fecha: 23/05/2022
--Bitácora de cambios
declare
v_sucursal_id text = ''; --A1
v_referencia text = ''; --A6 

v_contador numeric = 0;

resultado text= '';
mensaje text = '0';
adicionales text = '';
totreg int = 0;
strtTexto text ='';
v_nocatalogo text =''; 


BEGIN
	v_sucursal_id := upper((xpath('//document/k_sucn/text()', dataxml))[1]::text); --
	v_referencia := upper((xpath('//document/k_numeropedido_a6/text()', dataxml))[1]::text); --
	
	update keplersc.KDPEDESP 
	set c13=10,
		c14 = '',
		c15= ''
	where c14 = v_sucursal_id and c15 = v_referencia;
	
	delete from keplersc.KDPEDREFMOV 
	where c1 = v_sucursal_id and c2 = v_referencia;	
	
	update keplersc.KDPEDREF
	set c4  = 0	
	WHERE c1 = v_sucursal_id and c2 =v_referencia;

	resultado ='1';
	mensaje ='Finalizado';
	adicionales ='';
	

return query select resultado, mensaje, adicionales;

exception
	when others then
		resultado := 0;	
		mensaje := 'cat_pedidosugerido_eliminar_crud() ' || '['|| sqlstate || '] ' || sqlerrm ;
		adicionales := '';
		return query select resultado, mensaje, adicionales;
END;
$function$
