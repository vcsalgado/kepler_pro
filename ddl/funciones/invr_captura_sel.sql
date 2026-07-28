CREATE OR REPLACE FUNCTION keplersc.invr_captura_sel(dataxml xml)
 RETURNS text
 LANGUAGE plpgsql
AS $function$
--Descripcion: invr_captura_costoprom_sel
--Autor: Luis Leal
--Fecha: 15/01/2022
--Bitacora de cambios
declare
	--Variables de definicion de documento
	sucursal_id text = '';
	producto text = '';

	exist numeric = 0;
	existencia_real numeric = 0;
	valor_inv numeric = 0;
	ultimo_costo numeric = 0;
	penultimo_costo numeric = 0;
	costo_promedio numeric = 0;
	costo_promedio_real numeric = 0;
	precio_GM numeric = 0;

	valor_inv_real numeric = 0;
	diferencia_existencia numeric = 0;
	diferencia_valor_inventario numeric = 0;

	transaccion_id text='';
	usuario_movto text = '';
	error text = '';
	xmlResultado text='';

begin
	--raise notice '%', dataxml;
	
	transaccion_id := keplersc.log_tran_id_gen();	
	sucursal_id := (xpath('//document/sucursal_id/text()', dataxml))[1];
	producto := (xpath('//document/k_parte/text()', dataxml))[1];
	existencia_real := (xpath('//document/existencia_real/text()', dataxml))[1];
	costo_promedio_real := (xpath('//document/costo_promedio_real/text()', dataxml))[1];

	usuario_movto := (xpath('//document/movimiento/usuario/text()', dataxml))[1];

	select nl.c5-nl.c6,nl.c8-nl.c9,nl.c14,nl.c15,gm.c5 into exist,valor_inv,ultimo_costo,
	penultimo_costo,precio_GM from keplersc.kdinl as nl left outer join keplersc.kdigm as gm 
	on nl.c2=gm.c1 where nl.c1= sucursal_id  and nl.c2= producto;
	if found then

		if valor_inv <> 0 and exist <> 0 then
			costo_promedio := valor_inv/exist;
		end if;
	
		if costo_promedio > 0 then 
			costo_promedio_real := costo_promedio;
		else
			if ultimo_costo > 0 then
				costo_promedio_real := ultimo_costo;
			else
				if penultimo_costo > 0 then
					costo_promedio_real := penultimo_costo;
				else
					if precio_GM > 0 then
						costo_promedio_real :=precio_GM;
	
					end if;
				end if;
			end if;
		end if;
	
	else 
	
		exist := 0;
		valor_inv := 0;
		ultimo_costo := 0;
		penultimo_costo := 0;
		precio_GM := 0;
	
	end if;

	if existencia_real = 0 then
	
		costo_promedio_real := 0;
		
	end if;

	valor_inv_real := existencia_real*costo_promedio_real;

	diferencia_existencia := existencia_real - exist;
	
	diferencia_valor_inventario := valor_inv_real - valor_inv;

	if precio_GM is null then
		precio_GM := 0;
	end if;
	
	xmlResultado :=  xmlforest(exist as exist,valor_inv as valor_inv,costo_promedio as costo_promedio,
	ultimo_costo as ultimo_costo,penultimo_costo as penultimo_costo, precio_GM as precio_GM,
	costo_promedio_real as costo_promedio_real,valor_inv_real as valor_inv_real,
	diferencia_existencia as diferencia_existencia, diferencia_valor_inventario as diferencia_valor_inventario );

	return xmlResultado;

exception
	when others then
			error := 'keplersc.invr_captura_sel() ' || '['|| sqlstate || '] ' || sqlerrm ;
			call keplersc.log_transac_insert(transaccion_id, usuario_movto, '0', 'keplersc.invr_captura_sel', false, SQLERRM, 'ERR', dataxml);
			raise exception '%', error;	
end;
$function$
