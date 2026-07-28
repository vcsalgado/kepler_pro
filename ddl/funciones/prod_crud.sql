CREATE OR REPLACE FUNCTION keplersc.prod_crud(dataxml xml)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
--Descripcion: crud refacciones
--Autor: Luis Leal
--Fecha: 07/12/2021
--Bitacora de cambios
declare
	--Variables de definicion de documento
	clave text = '';
	descripcion text = '';
	localizacion1 text = '';
	localizacion2 text = '';
	localizacion3 text = '';
	clase text = '0';
    linea text = '';
   	precio1 numeric = 0;
   	precio2 numeric = 0;
  	precio3 numeric = 0;
 	precio4 numeric = 0;
	convrsion numeric = 0;

    unidad text = '';
	claveSAT text = '0';
	agrupador text = '';

    minimo numeric = 0;
	maximo numeric = 0;


	isclaveSAT bool;
	isminimo bool;
	ismaximo bool;

	crud text = '';

	sucursal text='';
	totReg int=0;

	resultado text = '';
	mensaje text = '0';
    adicionales text = '';
	
begin 

	
	clave := (xpath('//document/input_clave/text()', dataxml))[1];
	descripcion := (xpath('//document/input_desc/text()', dataxml))[1];
	localizacion1 := coalesce((xpath('//document/input_loc1/text()', dataxml))[1]::text,'')::text;
	localizacion2 := coalesce((xpath('//document/input_loc2/text()', dataxml))[1]::text,'')::text;
	localizacion3 := coalesce((xpath('//document/input_loc3/text()', dataxml))[1]::text,'')::text;
	--grupo
	clase := coalesce((xpath('//document/input_clas/r1/text()', dataxml))[1]::text,'')::text;
	--subgrupo
	linea := coalesce((xpath('//document/input_linea/text()', dataxml))[1]::text,'')::text;

	precio1 := (xpath('//document/input_precio1/text()', dataxml))[1];
	precio2 := coalesce((xpath('//document/input_precio2/text()', dataxml))[1]::text,'0')::decimal;
	precio3 := coalesce((xpath('//document/input_precio3/text()', dataxml))[1]::text,'0')::decimal;
	precio4 := coalesce((xpath('//document/input_precio4/text()', dataxml))[1]::text,'0')::decimal;
	
	convrsion := coalesce((xpath('//document/input_conversion/text()', dataxml))[1]::text,'0')::integer;
	unidad := (xpath('//document/input_unidad/r1/text()', dataxml))[1];

	agrupador := coalesce((xpath('//document/input_agrupador/text()', dataxml))[1]::text,'')::text;
	
	claveSAT := coalesce((xpath('//document/input_claveSAT/text()', dataxml))[1]::text,'0')::integer;
	--Existencias
	minimo := coalesce((xpath('//document/input_minimo/text()', dataxml))[1]::text,'0')::integer;
	maximo := coalesce((xpath('//document/input_maximo/text()', dataxml))[1]::text,'0')::integer;

	crud := (xpath('//document/input_crud/text()', dataxml))[1];
	
	sucursal := coalesce((xpath('//document/k_sucN/r1/text()', dataxml))[1]::text,'')::text;
	--raise exception '%', precio2;	
	
	if crud = 'Nuevo' then			
		insert into keplersc.kdini(c1,c2,c4,c5,c6,c8,c9,c11,c12,c13,c14,c16,c19,c21,c22,c33) 
		values(clave,descripcion,localizacion1,localizacion2,localizacion3,clase,linea,precio1,precio2,precio3,
		precio4,convrsion,unidad,minimo,maximo,claveSAT);
	end if;

	if crud = 'Modificar' then
		update keplersc.kdini set c2=descripcion,c4=localizacion1,c5=localizacion2,
		c6=localizacion3,c8=clase,c9=linea,c11=precio1,c12=precio2,c13=precio3,
		c14=precio4,c16=convrsion,c19=unidad,c21=minimo,c22=maximo,c33=claveSAT,c32=agrupador
		where c1=clave;
	end if;
	
	--Actualizar localizacion 
	if crud = 'Nuevo' or crud = 'Modificar' then
		if sucursal='' then
			raise exception 'No se proporcionó la sucursal';
		end if;
		select count(*) into totReg from keplersc.kdlocref where c1=sucursal and c2=clave;
		if totReg = 0 then
			insert into keplersc.kdlocref (c1,c2,c3,c4,c5,c6) values(sucursal,clave,'','','','');
		end if;
		update keplersc.kdlocref set c4=localizacion1, c5=localizacion2, c6=localizacion3 where c1=sucursal and c2=clave;
	end if;

	if crud = 'Eliminar' then
		raise exception 'Operación no permitida.';
		delete from keplersc.kdini where c1 = clave;	
	end if;


	resultado := 1;
	mensaje := 'Producto agregado:' || clave;
	adicionales := '';
	return query select resultado, mensaje, adicionales;	

exception
	when others then
		resultado := 0;
	
		mensaje := 'prod_crud() ' || '['|| sqlstate || '] ' || sqlerrm ;		

		adicionales := '';
		return query select resultado, mensaje, adicionales;	
	
end;
$function$
