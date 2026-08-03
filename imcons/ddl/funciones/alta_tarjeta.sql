CREATE OR REPLACE FUNCTION keplersc.alta_tarjeta(dataxml xml)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
--Descripcion: Alta Tarjeta de Lealtad
--Autor: Luis Leal
--Fecha: 18/10/2024
--Bitacora de cambios
declare
	--Variables de definicion de documento
	k_suc text = '';
	vin text;
	usr text;
	fol_lealtad text;
	ult_fol_lealtad text;
	nuevo_fol_lealtad text;
	totReg numeric;
	
   --Variables de retorno
	resultado text = '';
	mensaje text = '0';
    adicionales text = '';
	
begin 
	
	k_suc := (xpath('//document/k_sucN/r1/text()', dataxml))[1];
	vin := coalesce((xpath('//document/vin/text()', dataxml))[1], '');
	usr := coalesce((xpath('//document/usuario/text()', dataxml))[1], '');

	if vin = '' then
		raise exception  'Debes proporcionar una Serie.';
	end if;

	select count(*) into totReg from keplersc.kdserie where c4=vin;
	if totReg = 0 then
		raise exception 'El numero de Serie no esta registrado en el Sistema.';
	end if;

	select c2 into fol_lealtad from keplersc.kdfoliotarjetalealtad where c1=vin;
	if found then
		raise exception 'El VIN ya tiene un numero asignado %', fol_lealtad;
	end if;

	select count(*) into totReg from keplersc.param_oper
	where sucursal=k_suc and parametro='Tarjeta Lealtad' and valor='S';
	if totReg = 0 then
		raise exception 'La Sucursal no esta habilitada para dar de Alta tarjetas de Lealtad.';
	end if;

	select count(*) into totReg from keplersc.param_opc_usr_sec
	where sucursal=k_suc and opcion='Tarjeta Lealtad' and usuario=usr;
	if totReg = 0 then
		raise exception 'El Usuario no tiene privilegios para dar de Alta tarjetas de Lealtad.';
	end if;

	ult_fol_lealtad:='0';
	select count(*) into totReg from keplersc.kdfoliotarjetalealtad;
	if totReg > 0 then
		select c2 into ult_fol_lealtad from keplersc.kdfoliotarjetalealtad order by c2 desc limit 1;
	end if;

	nuevo_fol_lealtad := lpad((ult_fol_lealtad::int + 1)::text , 10, '0');

	insert into keplersc.kdfoliotarjetalealtad(c1,c2) values(vin, nuevo_fol_lealtad);

	resultado := 1;
	mensaje := 'Tarjeta de Lealtad agregada: ' || nuevo_fol_lealtad ;
	adicionales := '';
	return query select resultado, mensaje, adicionales;	

exception
	when others then
		resultado := 0;
		mensaje := 'alta_tarjeta() ' || '['|| sqlstate || '] ' || sqlerrm ;		
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
	
end;
$function$
