CREATE OR REPLACE FUNCTION keplersc.cat_pedidosugerido_eliminasugerido_crud(dataxml xml)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
--Descripcion: Cursores
--Autor: Saltiel Rc
--Fecha: 23/05/2022
--Bitacora de cambios
--Fecha: 13/11/2023 Revisado, Modificado y Probado por JMM 
--                  (Se desarrollo el KPL en K80 que corre este proceso)
declare
suc text = ''; --A1
refer text = ''; --A6 

totreg int = 0;
pedst int;

resultado text= '';
mensaje text = '0';
adicionales text = '';

begin
	
	suc := upper((xpath('//document/k_sucn/r1/text()', dataxml))[1]::text); 
	refer := upper((xpath('//document/k_refer/text()', dataxml))[1]::text); --
	
	totreg := 0;
	select count(*) into totreg from keplersc.kdpedref   
	where c1 = suc and c2 = refer; 
	if totreg = 0 then
		raise exception '%', 'El Pedido Sugerido ' || '[ '|| refer || ' ]  No Existe ...';
	else
		pedst = -100;
		select coalesce(c4,-1) into pedst from keplersc.kdpedref 
		where c1 = suc and c2 = refer;
		if pedst <> 10 then
			raise exception '%', 'El Estatus del Pedido Sugerido ' || '[ '|| refer || ' , ' || pedst::text || ' ] No es Valido para realizar esta operacion ...';
		end if;
	end if;
	

	update keplersc.kdpedesp  
	set c13 = 10,
		c14 = '',
		c15 = ''
	where c14 = suc and c15 = refer;
	

	delete from keplersc.kdpedrefmov  
	where c1 = suc and c2 = refer;	
	

	update keplersc.kdpedref 
	set c4 = 0	
	WHERE c1 = suc and c2 = refer;


	-- 4 Testing ...
	/* 
	raise exception '%', 'El Pedido Sugerido ' || '['|| refer || '] Sera Eliminado ...';
	*/


	resultado ='1';
	mensaje = refer;
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
