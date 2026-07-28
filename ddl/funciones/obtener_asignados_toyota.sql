CREATE OR REPLACE FUNCTION keplersc.obtener_asignados_toyota()
 RETURNS TABLE(modelo text, invent text, anio text, serie text, color text, vest text)
 LANGUAGE plpgsql
AS $function$
declare 

	--Variables de proceso
	error text = '';

	recAsig record;
begin
	drop table if exists tmpAsig;
	create temp table tmpAsig (
		modelo text, 
		invent text, 
		anio text,
		serie text,
		color text,
		vest text
	);
	insert into tmpAsig 
	select distinct on (ds."VehicleID") 
	ds."Model", 
	'' , 
	ds."ModelYear", 
	ds."VehicleID", 
	ds."ManufacturerColorCode_Ex", 
	ds."ManufacturerColorCode_In"
	from keplersc.ddoa_showvehicleinventorydetail ds
	where ds."VehicleID" not in (select inf.c5 as serie from keplersc.kdinf inf where inf.c5=ds."VehicleID" and inf.c21='NUEVO')
	order by ds."VehicleID";

--	Completar dato de inventario y anio
	update tmpAsig asig set invent= (select inv.c1 from keplersc.kddinv inv where inv.c3 = asig.anio and inv.c7='N');	

	return query select * from tmpAsig; 
exception
	when others then
		error := 'keplersc.obtener_asignados_toyota() ' || '['|| sqlstate || '] ' || sqlerrm ;
		raise exception '%', error;	
end;
$function$
