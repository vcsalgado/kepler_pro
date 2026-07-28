CREATE OR REPLACE FUNCTION keplersc.notif_registrar_movto()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
declare
	--Variables de uso general 
	strValor text = '';
	intValor int = 0;
	sucursal_id text='';
	rec_NACONF record;
	expSql text='';

	--Variables control_envios
	strOem text = '';
	strApi_id text ='';
	strDatos_interfaz text = '';
	intTransaction int = 0;
	procesar text = 'N';
	estatus text = 'C';	

	--variables trigger
	entidad text = '';
	operacion text = '';

begin
	entidad:=upper(TG_TABLE_NAME);
	operacion:=upper(TG_OP);
	
	raise notice 'Entidad:%; Operacion:%', entidad,operacion;
	
	--Ordenes de servicio
	if entidad='KDORD' then --Ordenes de venta
		sucursal_id:=new.c1;
		--Obtener OEM
		select interfaz_oem into strOem from keplersc.kdms ms where ms.c1=sucursal_id; 			
		
		if strOem='GWM' then
			strApi_id := 'APIDMSServicio';
		end if;

		if operacion='INSERT' then
			estatus:='W';
			procesar:='S';
		end if;

		if operacion='UPDATE' then
--			if old.c7 <> new.c7 and new.c7=10 then --Orden cambia a cerrada
				estatus:='C';
				procesar:='S';
--			end if;
		end if;

		if operacion='DELETE' then
			procesar:='N';
		end if;

		if procesar='S' then
			--Crear cadena con datos de registro de orden
			strDatos_interfaz:=concat('{"sucursal_id":"',sucursal_id,'",','"tipo":"',new.c2,'",','"orden":"',new.c3,'"}');
			
			--Obtener consecutivo
			select coalesce(max(id_transaccion),0) + 1 into intTransaction from keplersc.notif_api_control_envios;
			
			--Insertar registro
			insert into keplersc.notif_api_control_envios (id_transaccion,api_id,datos_interfaz) values(intTransaction,strApi_id,strDatos_interfaz);

		end if;
	end if;

	--Ordenes de servicio
	if entidad='KDINM' then --Ordenes de venta
		sucursal_id:=new.c1;
		
	end if;


	if procesar='S' then
		strValor:=intTransaction;
		expSql = format('notify gwm, ''%s''',strValor );
raise notice 'expSql:% ',expSql;
		execute expSql;
		raise notice 'Enviado...';		
	end if;

	--resultado='Procesado';
--	raise notice 'Entidad:%; Operacion:%', entidad,operacion;
	return new;
end;
$function$
