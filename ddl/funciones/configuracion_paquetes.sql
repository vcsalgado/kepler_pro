CREATE OR REPLACE FUNCTION keplersc.configuracion_paquetes(dataxml xml)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
--Descripcion: Configura paquetes
--Autor: Luis Leal
--Fecha: 01/02/2023
--Bitacora de cambios
--18/03/2025 Victor Salgado, se agrega validacion de usuario para registro de mano de obra a precio menor
declare
	marca text;
	modelo text;
	paquete text;
	descr text;
	mano_obra numeric;
	refacciones numeric;
	varios  numeric;
	horas  numeric;
	precio_paquete numeric;
	fuera_garantia text;
	min_mano_obra_horas numeric = 0;
	usuario_movto text = '';

	--loop--
	parte text;
	cantidad numeric;

	no_partidas int = 0;
	strValor text = '';
	intValor int = 0;

	--Variables de retorno
	resultado text;
	mensaje text;
	adicionales text;
begin
	
	marca:=coalesce((xpath('//document/marca/text()', dataxml))[1],'');
	modelo:=coalesce((xpath('//document/modelo/text()', dataxml))[1],'');
	paquete:=coalesce((xpath('//document/paquete/text()', dataxml))[1],'');
	descr:=coalesce((xpath('//document/descripcion/text()', dataxml))[1],'');
	mano_obra :=coalesce((xpath('//document/mano_obra/text()', dataxml))[1],'0');
	refacciones :=coalesce((xpath('//document/refacciones/text()', dataxml))[1],'0');
	varios :=coalesce((xpath('//document/varios/text()', dataxml))[1],'0');
	horas :=coalesce((xpath('//document/horas/text()', dataxml))[1],'1');
	precio_paquete :=coalesce((xpath('//document/precio_paquete/text()', dataxml))[1],'0');
	fuera_garantia :=coalesce((xpath('//document/fuera_garantia/text()', dataxml))[1],'');
	usuario_movto := coalesce((xpath('//document/movimiento/usuario/text()',dataxml))[1],'');


	select count(*) into min_mano_obra_horas from keplersc.param_oper po where po.sucursal = '00' and po.parametro ='minimo horas mano obra';
	if min_mano_obra_horas =0 then
		raise exception 'No se ha configurado el minimo de horas de mano de obra';
	end if;

	select coalesce(valor,'0') into min_mano_obra_horas from keplersc.param_oper po where po.sucursal = '00' and po.parametro ='minimo horas mano obra';	
	if min_mano_obra_horas <= 0 then
		raise exception 'No se ha configurado correctamente el minimo de horas de mano de obra, no pueden ser 0 o menor';
	end if;


	if horas = 0 then
		raise exception '%', 'Las horas no pueden ser 0';
	end if;

	if mano_obra/horas < min_mano_obra_horas then
		select count(*) into intValor from keplersc.param_opc_usr_sec where sucursal='00' and opcion='Autoriza mano de obra menor' and usuario=usuario_movto;
		if intValor=0 then
			raise exception 'El precio minimo valido por hora de venta al publico es de % pesos',min_mano_obra_horas;
		end if;
	end if;

	delete from keplersc.kdspaq where c1=marca and c2=modelo and c4=paquete;
	delete from keplersc.kdspaqm where c1=marca and c2=modelo and c4=paquete;

	insert into keplersc.kdspaq(c1,c2,c4,c5,c6, c7, c8, c9, c10,c11)
	values (marca, modelo, paquete, descr, mano_obra, refacciones,
	varios, horas,precio_paquete, fuera_garantia);

	strValor:=coalesce((xpath('//document/k_partidas/no_partidas/text()', dataxml))[1],'0');
	no_partidas:=strValor::int;

	for cont in 0..no_partidas loop
		
		parte := coalesce((xpath('//document/k_mov/r' ||cont||'/k_parte/text()',dataxml))[1],'');
		cantidad := coalesce((xpath('//document/k_mov/r' ||cont||'/k_Q/text()',dataxml))[1],'0');
		
		if cont = 0 then
			if parte = '' then 
				raise exception '%' , 'Debes seleccionar una clave.';
			end if;
		else
			if parte = '' then 
				continue; 
			end if;
		end if;
		
	
		insert into keplersc.kdspaqm(c1,c2,c4,c6, c7)
		values (marca, modelo, paquete,parte, cantidad );
	
	end loop;

	resultado := 1;
	mensaje := '';
	adicionales := '';
	return query select resultado, mensaje, adicionales;	

exception
	when others then
		resultado := 0;
		mensaje := 'configuracion_paquetes() ' || '['|| sqlstate || '] ' || sqlerrm ;
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
end;
$function$
