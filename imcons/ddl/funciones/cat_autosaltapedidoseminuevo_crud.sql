CREATE OR REPLACE FUNCTION keplersc.cat_autosaltapedidoseminuevo_crud(dataxml xml)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
--Descripcion: Alta Pedido Seminuevos
--Autor: Saltiel Rc
--Fecha: 15/09/2022
--KDTOMAS (AltaPedido_Seminuevos)
--Bitacora:
--20 Jul 2023, Gad Miranda, se corrige crud

declare
v_sucursal_id text = ''; 
v_inventario text = ''; 
v_consecutivo numeric(5);
v_clave_vehicular text = '';
v_Tipo_vehiculo text = '';
v_anio_modelo text = '';
v_vin text = '';
v_niv text = '';
v_monto_adq  numeric(15,2);
v_monto_ena  numeric(15,2);
v_num_motor text = '';
v_num_importacion text = '';
v_fecha_importacion timestamp;
v_aduana text = '';
v_marca text = '';	
v_valor_libro_azul numeric(15,2);	
v_contador numeric = 0;

resultado text= '';
mensaje text = '0';
adicionales text = '';
totreg int = 0;
v_nocatalogo text =''; 
k_accion text = '';
 

BEGIN
				v_sucursal_id := upper((xpath('//document/k_suc/text()', dataxml))[1]::text); --
				v_inventario := upper((xpath('//document/k_inventario/text()', dataxml))[1]::text); --
				v_consecutivo:= upper((xpath('//document/k_consecutivo/text()', dataxml))[1]::text); --
				v_clave_vehicular := upper((xpath('//document/k_clave_vehicular/text()', dataxml))[1]::text); --
				v_Tipo_vehiculo:= upper((xpath('//document/k_tipo_vehiculo/text()', dataxml))[1]::text); --
				v_anio_modelo:= upper((xpath('//document/k_anio_modelo/text()', dataxml))[1]::text); --
				v_vin:= upper((xpath('//document/k_vin/text()', dataxml))[1]::text); --
				v_niv:= upper((xpath('//document/k_niv/text()', dataxml))[1]::text); --
				v_monto_adq:= upper((xpath('//document/k_monto_adq/text()', dataxml))[1]::text); --
				v_monto_ena:= upper((xpath('//document/k_monto_ena/text()', dataxml))[1]::text); --
				v_num_motor:= upper((xpath('//document/k_num_motor/text()', dataxml))[1]::text); --
				v_num_importacion:= upper((xpath('//document/k_num_importacion/text()', dataxml))[1]::text); --
				v_fecha_importacion:= upper((xpath('//document/k_fecha_importacion/text()', dataxml))[1]::text); --
				v_aduana:= upper((xpath('//document/k_aduana/text()', dataxml))[1]::text); --
				v_marca:= upper((xpath('//document/k_marca/text()', dataxml))[1]::text); --	
				v_valor_libro_azul := upper((xpath('//document/k_valor_libro_azul/text()', dataxml))[1]::text); --
				k_accion := upper((xpath('//document/k_accion/text()', dataxml))[1]::text); --		

		if ((select count(*) from keplersc.kdtomas k where c1=v_sucursal_id and c2 = v_inventario and c3 = v_consecutivo) > 0) then
			if k_accion = 'EDITAR' then
				update keplersc.kdtomas  
				set c4 = v_clave_vehicular,
					c5 = v_Tipo_vehiculo,
					c6 = v_anio_modelo,
					c7 = v_vin,
					c8 = v_niv,			
					c9 = v_monto_adq,
					c10 = v_monto_ena,
					c11 = v_num_motor,
					c12 = v_num_importacion,			
					c13 = v_fecha_importacion,
					c14 = v_aduana,
					c16 = v_marca,
					c17 = v_valor_libro_azul
					 where c1=v_sucursal_id and c2 = v_inventario and c3 = v_consecutivo;

				resultado ='1';
				mensaje ='Registro Actualizado.';
				adicionales ='';
			end if;
		
			if k_accion = 'ELIMINAR' then
				delete from keplersc.kdtomas
				where c1=v_sucursal_id and c2 = v_inventario and c3 = v_consecutivo;
				resultado ='1';
				mensaje ='Registro Eliminado.';
				adicionales ='';			
			end if;

		else 
		
			insert into keplersc.kdtomas (c1,c2,c3,c4,c5,c6,c7,c8,c9,c10,c11,c12,c13,c14,c16,c17) 
			values (v_sucursal_id,
				v_inventario,
				v_consecutivo::numeric,
				v_clave_vehicular,
				v_Tipo_vehiculo,
				v_anio_modelo,
				v_vin,
				v_niv,			
				v_monto_adq::numeric,
				v_monto_ena::numeric,
				v_num_motor,
				v_num_importacion,			
				v_fecha_importacion::timestamp,
				v_aduana,
				v_marca,
				v_valor_libro_azul::numeric);		

			resultado ='1';
			mensaje ='Toma Registrada.';
			adicionales ='';
		end if; 

return query select resultado, mensaje, adicionales;

exception
	when others then
		resultado := 0;	
		mensaje := 'cat_AltaPedido_seminuevos_crud() ' || '['|| sqlstate || '] ' || sqlerrm ;
		adicionales := '';
		return query select resultado, mensaje, adicionales;
END;
$function$
