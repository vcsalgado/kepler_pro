CREATE OR REPLACE FUNCTION keplersc.util_auditoria_cont()
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
declare
	--Reporta polizas huerfanas, moviimentos sin polzas, polizas descuadradas, evalua estado de resultados y balanza de comprobacion

	--Variables de uso general 
	strValor text = ''; 
	intValor int = 0;
	tabla_kdc1 text = '';
	kdc1_campo_base_saldo_ini int = 14;
	kdc1_campo_base_aniomes_anterior int = 15;
	kdc1_campo_base_cargos int = 27;
	kdc1_campo_base_abonos int = 63;
	kdc1_col_saldo_aniomes_anterior text= '';
	kdc1_col_cargos text = '';
	kdc1_col_abonos text = '';
	tabla_kdc2 text = '';
	expSql text = '';
	campo_cuentas text = '';
	poliza numeric = 0;
	fecha timestamp;
	cuenta varchar(20) = '';
	asiento varchar(1);
	monto numeric(15,2);
	tipo varchar(1);
	mes int;
	cont int = 0;
	ctas record;
	cta_upd record;
	fec_ini timestamp;
	fec_fin timestamp;
	totCargos numeric = 0.00;
	totAbonos numeric = 0.00;
	movtos int;
	anio_ini int;
	tabla_ctas_anterior text = '';
	existeAnioAnt int;
	cont_anio int;
	anio_proceso int;
	anio_fin int;
	cuentares_prim text = ''; --'400';
	cuentares_ult text = ''; --'899';
	cuentautil_ant text = ''; --'380-001';
	cuentaUtilMayAnt text = ''; --'380';
	totalResultados numeric =0.00;
	totalAcumulado numeric = 0.00;
	tabla_cuentas text = '';

	--Variables de retorno
	resultado text;
	mensaje text;
	adicionales text;
begin
	raise exception 'NO AUTORIZADO';
	cont_anio='24';
	tabla_cuentas:='keplersc.kdc124';
	--Cuentas huerfanas, sin padre, sin hijos y empiezan con string > 3
	--Validar si la cuenta es de ultimo nivel y no es de perimer nivel
	--Hay niveles arriba 
	expSql = format('select count(*) from %1$s where position(c1 in %2$L) > 0 and substring(c1,1,1) = substring(%2$L,1,1) 
		and c1<>%2$L',tabla_cuentas,cuenta);
	execute expSql into intValor;
--raise exception '1. Sql: %, Valor:%', expSql,intValor;	
	if intValor = 0 then --
		raise exception '%', concat('Imposible agregar la cuenta ', cuenta, ', falta cuenta de primer nivel.');
	end if;	

	--No hay niveles abajo
	expSql = format('select count(*) from %1$s where position( %2$L in c1) > 0 and substring(c1,1,1) = substring(%2$L,1,1)
		and c1<>%2$L',tabla_cuentas,cuenta);
	execute expSql into intValor;
--raise exception '2. Sql: %, Valor:%', expSql,intValor;	
	if intValor > 0 then --
		raise exception '%', concat('Imposible agregar la cuenta ', cuenta, ', no es de �ltimo nivel.');
	end if ;
		

	resultado := 1;
	mensaje := '';
	adicionales := '';
	return query select resultado, mensaje, adicionales;	

exception
	when others then
	--Habilitar trigger
		if tabla_kdc1<>'' then
			expSql := concat('create trigger kdc1_upd_nivel_after_crud after insert or delete or update on keplersc.', tabla_kdc1 ,' for each row execute function keplersc.cont_upd_nivel()');
			execute expSql;
		end if;
		resultado := 0;
		mensaje := 'base_function() ' || '['|| sqlstate || '] ' || sqlerrm ;
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
end;
$function$
