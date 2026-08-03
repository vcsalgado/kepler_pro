CREATE OR REPLACE FUNCTION keplersc.mig_crear_contexto()
 RETURNS text
 LANGUAGE plpgsql
AS $function$
declare
	--Variables de uso general 
	strValor text = '';
	intValor int = 0;
	expSql text = '';
	_tabla text = '';
	_colSuc text = '';
	_colGen text = '';
	_colNat text = '';
	_colGpo text = '';
	_colTip text = '';
	_colFol text = '';
	_indicenombre text = '';
	_indicedef text = '';

	--Variables de retorno
	resultado text;

begin

--**************************************************
--INI Ajuste funciones 'AUT' por 'VEN' en la uen
--**************************************************
/* 
 * Verificar el namespace previo al update
--select 	n.*,p.*,n.nspname AS function_schema,p.proname AS function_name
--from pg_proc p LEFT JOIN pg_namespace n ON p.pronamespace = n.oid
--where n.nspname NOT IN ('pg_catalog', 'information_schema') and p.prosrc like '%''AUT''%'
--order by function_schema, function_name;
    
--select replace(prosrc,'''AUT''','''VEN''') as prosrc from pg_proc where proname='cont_general_alta'
--update pg_proc set prosrc = replace(prosrc,'''AUT''','''VEN''') where pronamespace = 89986 and prosrc like '%''AUT''%'

--Funciones con llamado a kdc1 y kdc2 
--select distinct p.proname
--from pg_proc p LEFT JOIN pg_namespace n ON p.pronamespace = n.oid
--where n.nspname NOT IN ('pg_catalog', 'information_schema') 
-and (upper(p.prosrc) like '%KDC1%' or upper(p.prosrc) like '%KDC2%');
--cont_general_alta
--cont_general_baja
--cont_poliza_baja
--cont_poliza_partida_alta
--cont_rep_librodiario_sel
--cont_rep_mayorauxiliar_sel
--cont_rep_poliza
--cont_venta_taller
--mig_crear_contexto
--mig_folios_rectificar
--utils_transact_datachanges_xml
--verify_cuenta_ult_nivel 
 
 *  */
--**************************************************
-- FIN Ajuste funciones 'AUT' por 'VEN' en la uen
--**************************************************
	
	
	
--***************************************	
--1. Insercion de registros de tablas en mig_datos_rectificacion por complemento,
	--registro de inventario de tablas
--***************************************
/*
	--Proceso de jecucion unica 
	raise notice 'Insertando registros de tablas en mig_datos_rectificacion';
	insert into keplersc.mig_datos_rectificacion 
	(SELECT table_name FROM information_schema.tables WHERE table_schema='keplersc' and table_name not in 
	(select tabla from keplersc.mig_datos_rectificacion));
*/
--***************************************	
--FIN 1. 
--***************************************

--***************************************	
--2. Identificacion de tablas a resetear, columnas de sucursal, movimiento y folio
--***************************************
/*
update keplersc.mig_datos_rectificacion SET colsucursal = '', colgen = '', colnat = '', colgpo = '', coltipo = '', colfolio = '', 
	depurar = 'N', refol= 'N';

delete from keplersc.mig_datos_rectificacion where tabla like '%\_%'; 
 
update keplersc.mig_datos_rectificacion SET colsucursal = 'c1', colgen = 'c2', colnat = 'c3', colgpo = 'c4', coltipo = 'c5', colfolio = 'c6' where tabla = 'kdbom';
update keplersc.mig_datos_rectificacion SET colsucursal = 'c1' where tabla = 'kdbom';
update keplersc.mig_datos_rectificacion SET colsucursal = 'c1' where tabla = 'kdbok';
update keplersc.mig_datos_rectificacion SET colsucursal = 'c1' where tabla = 'kdbol';
update keplersc.mig_datos_rectificacion set colsucursal = 'c1', colfolio = 'c3' where tabla = 'kdcar';
update keplersc.mig_datos_rectificacion SET colsucursal = 'c5' where tabla = 'kdcatcoach';
update keplersc.mig_datos_rectificacion SET colsucursal = 'c14', colgen = 'c15', colnat = 'c16', colgpo = 'c17', coltipo = 'c18', colfolio = 'c19' where tabla = 'kdc2';
update keplersc.mig_datos_rectificacion SET colsucursal = 'c1', colgen = 'c2', colnat = 'c3', colgpo = 'c4', coltipo = 'c5' where tabla = 'kdcfdsersucdoc';
update keplersc.mig_datos_rectificacion SET colsucursal = 'c1', colgen = 'c2', colnat = 'c3', colgpo = 'c4', coltipo = 'c5', colfolio = 'c6' where tabla = 'kdcomismov';
update keplersc.mig_datos_rectificacion SET colsucursal = 'c2' where tabla = 'kdconftaller';
update keplersc.mig_datos_rectificacion SET colsucursal = 'c1', colgen = 'c2', colnat = 'c3', colgpo = 'c4', coltipo = 'c5', colfolio = 'c6' where tabla = 'kdcostpun';
update keplersc.mig_datos_rectificacion SET colsucursal = 'c4', colfolio = 'c1' where tabla = 'kdcp';
insert into keplersc.mig_datos_rectificacion (tabla,colgen,colnat,colgpo,coltipo,colfolio,colsucursal) values('kdcp_','','','c10','c11','c12','c4');
update keplersc.mig_datos_rectificacion SET colsucursal = 'c1', colfolio = 'c2' where tabla = 'kdctasfent';
update keplersc.mig_datos_rectificacion SET colsucursal = 'c1', colfolio = 'c2' where tabla = 'kdctassermov';
update keplersc.mig_datos_rectificacion SET colsucursal = 'c1', colfolio = 'c2' where tabla = 'kdctassint';
update keplersc.mig_datos_rectificacion SET colsucursal = 'c1', colgen = 'c3', colnat = 'c4', colgpo = 'c5', coltipo = 'c6', colfolio = 'c7' where tabla = 'kdecaja';
update keplersc.mig_datos_rectificacion SET colsucursal = 'c1', colgen = 'c5', colnat = 'c6', colgpo = 'c7', coltipo = 'c8', colfolio = 'c9' where tabla = 'kdeinv';
update keplersc.mig_datos_rectificacion SET colsucursal = 'c1', coltipo = 'c2', colfolio = 'c3' where tabla = 'kdencprog';
update keplersc.mig_datos_rectificacion SET colsucursal = 'c1', colgen = 'c2', colnat = 'c3', colgpo = 'c4', coltipo = 'c5', colfolio = 'c6' where tabla = 'kdf3adenda';
update keplersc.mig_datos_rectificacion SET colsucursal = 'c1', colgen = 'c2', colnat = 'c3', colgpo = 'c4', coltipo = 'c5', colfolio = 'c6' where tabla = 'kdf3cliente';
update keplersc.mig_datos_rectificacion SET colsucursal = 'c1', colgen = 'c2', colnat = 'c3', colgpo = 'c4', coltipo = 'c5', colfolio = 'c6' where tabla = 'kdf3complement';
update keplersc.mig_datos_rectificacion SET colsucursal = 'c1', colgen = 'c2', colnat = 'c3', colgpo = 'c4', coltipo = 'c5', colfolio = 'c6' where tabla = 'kdf3concept';
update keplersc.mig_datos_rectificacion SET colsucursal = 'c1', colgen = 'c2', colnat = 'c3', colgpo = 'c4', coltipo = 'c5', colfolio = 'c6' where tabla = 'kdf3header';
insert into keplersc.mig_datos_rectificacion (tabla,colgen,colnat,colgpo,coltipo,colfolio,colsucursal) values('kdf3header_','c65','c66','c67','c68','c69','c1');
update keplersc.mig_datos_rectificacion SET colsucursal = 'c1', colgen = 'c2', colnat = 'c3', colgpo = 'c4', coltipo = 'c5', colfolio = 'c6' where tabla = 'kdf3headextras';
update keplersc.mig_datos_rectificacion SET colsucursal = 'c1', colgen = 'c2', colnat = 'c3', colgpo = 'c4', coltipo = 'c5', colfolio = 'c6' where tabla = 'kdf3longconcept';
update keplersc.mig_datos_rectificacion SET colsucursal = 'c1', colgen = 'c2', colnat = 'c3', colgpo = 'c4', coltipo = 'c5', colfolio = 'c6' where tabla = 'kdf3relation';
insert into keplersc.mig_datos_rectificacion (tabla,colgen,colnat,colgpo,coltipo,colfolio,colsucursal) values('kdf3relation_','c11','c12','c13','c14','c15','c10');
update keplersc.mig_datos_rectificacion SET colsucursal = 'c1' where tabla = 'kdginv';
update keplersc.mig_datos_rectificacion SET colsucursal = 'c1', colgpo = 'c2', colfolio = 'c3' where tabla = 'kdgruposfolio';
update keplersc.mig_datos_rectificacion SET colsucursal = 'c1', coltipo = 'c2', colfolio = 'c3' where tabla = 'kdhoras';
update keplersc.mig_datos_rectificacion SET colsucursal = 'c1', colgen = 'c6', colnat = 'c7', colgpo = 'c8', coltipo = 'c9', colfolio = 'c10' where tabla = 'kdhorpag';
update keplersc.mig_datos_rectificacion SET colsucursal = 'c1', colgen = 'c4', colnat = 'c5', colgpo = 'c6', coltipo = 'c7', colfolio = 'c8' where tabla = 'kdicom';
update keplersc.mig_datos_rectificacion SET colsucursal = 'c1' where tabla = 'kdifis';
update keplersc.mig_datos_rectificacion SET colsucursal = 'c1' where tabla = 'kdinf';
update keplersc.mig_datos_rectificacion SET colsucursal = 'c1' where tabla = 'kdink';
update keplersc.mig_datos_rectificacion SET colsucursal = 'c1' where tabla = 'kdinl';
update keplersc.mig_datos_rectificacion SET colsucursal = 'c1', colgen = 'c5', colnat = 'c6', colgpo = 'c7', coltipo = 'c8', colfolio = 'c9' where tabla = 'kdinm';
update keplersc.mig_datos_rectificacion SET colsucursal = 'c1' where tabla = 'kdinp';
update keplersc.mig_datos_rectificacion SET colsucursal = 'c1' where tabla = 'kdinpdet';
update keplersc.mig_datos_rectificacion SET colsucursal = 'c1' where tabla = 'kdinv';
update keplersc.mig_datos_rectificacion SET colsucursal = 'c1', colnat = 'c2', colgpo = 'c3', coltipo = 'c4', colfolio = 'c5' where tabla = 'kdinvrcomis';
update keplersc.mig_datos_rectificacion SET colsucursal = 'c3' where tabla = 'kdivcl';
update keplersc.mig_datos_rectificacion SET colsucursal = 'c1' where tabla = 'kdkcaja';
update keplersc.mig_datos_rectificacion SET colsucursal = 'c1' where tabla = 'kdlinv';
update keplersc.mig_datos_rectificacion SET colsucursal = 'c1', colgen = 'c2', colnat = 'c3', colgpo = 'c4', coltipo = 'c5', colfolio = 'c6' where tabla = 'kdm1';
insert into keplersc.mig_datos_rectificacion (tabla,colgen,colnat,colgpo,coltipo,colfolio,colsucursal) values('kdm1_','c2','c36','c37','c38','c39','01');
update keplersc.mig_datos_rectificacion SET colsucursal = 'c1', colgen = 'c2', colnat = 'c3', colgpo = 'c4', coltipo = 'c5', colfolio = 'c6' where tabla = 'kdm2';
insert into keplersc.mig_datos_rectificacion (tabla,colgen,colnat,colgpo,coltipo,colfolio,colsucursal) values('kdm2_','','c19','c20','c21','c22','01');
update keplersc.mig_datos_rectificacion SET colsucursal = 'c1', colgen = 'c2', colnat = 'c3', colgpo = 'c4', coltipo = 'c5', colfolio = 'c6' where tabla = 'kdm3';
insert into keplersc.mig_datos_rectificacion (tabla,colgen,colnat,colgpo,coltipo,colfolio,colsucursal) values('kdm3_','','c20','c21','c22','c23','01');
update keplersc.mig_datos_rectificacion SET colsucursal = 'c1', colgen = 'c2', colnat = 'c3', colgpo = 'c4', coltipo = 'c5', colfolio = 'c6' where tabla = 'kdm4';
update keplersc.mig_datos_rectificacion SET colsucursal = 'c1', colgen = 'c2', colnat = 'c3', colgpo = 'c4', coltipo = 'c5', colfolio = 'c6' where tabla = 'kdm5';
insert into keplersc.mig_datos_rectificacion (tabla,colgen,colnat,colgpo,coltipo,colfolio,colsucursal) values('kdm5_','','c8','c9','c10','c11','01');
update keplersc.mig_datos_rectificacion SET colsucursal = 'c1', colgen = 'c2', colnat = 'c3', colgpo = 'c4', coltipo = 'c5', colfolio = 'c6' where tabla = 'kdm6';
update keplersc.mig_datos_rectificacion SET colsucursal = 'c1', colgen = 'c2', colnat = 'c3', colgpo = 'c4', coltipo = 'c5', colfolio = 'c6' where tabla = 'kdm7';
update keplersc.mig_datos_rectificacion SET colsucursal = 'c1', colgen = 'c2', colnat = 'c3', colgpo = 'c4', coltipo = 'c5', colfolio = 'c6' where tabla = 'kdm8';
insert into keplersc.mig_datos_rectificacion (tabla,colgen,colnat,colgpo,coltipo,colfolio,colsucursal) values('kdm8_','','c8','c9','c10','c11','');
update keplersc.mig_datos_rectificacion SET colsucursal = 'c1', colgen = 'c2', colnat = 'c3', colgpo = 'c4', coltipo = 'c5', colfolio = 'c6' where tabla = 'kdm9';
insert into keplersc.mig_datos_rectificacion (tabla,colgen,colnat,colgpo,coltipo,colfolio,colsucursal) values('kdm9_','','c8','c9','c10','c11','');
update keplersc.mig_datos_rectificacion SET colsucursal = 'c1' where tabla = 'kdms';
update keplersc.mig_datos_rectificacion SET colsucursal = 'c1' where tabla = 'kdoperstat';
update keplersc.mig_datos_rectificacion SET colsucursal = 'c1',  colfolio = 'c3' where tabla = 'kdord';
insert into keplersc.mig_datos_rectificacion (tabla,colgen,colnat,colgpo,coltipo,colfolio,colsucursal) values('kdord_','c40','c41','c42','c43','c44','c1');
update keplersc.mig_datos_rectificacion SET colsucursal = 'c1', colfolio='c3' where tabla = 'kdordceros';
update keplersc.mig_datos_rectificacion SET colsucursal = 'c1', coltipo = 'c2', colfolio = 'c3' where tabla = 'kdordfent';
update keplersc.mig_datos_rectificacion SET colsucursal = 'c1', coltipo = 'c2', colfolio = 'c3' where tabla = 'kdordsint';
update keplersc.mig_datos_rectificacion SET colsucursal = 'c1' where tabla = 'kdpaqconf';
update keplersc.mig_datos_rectificacion SET colsucursal = 'c1' where tabla = 'kdpeddocs';
update keplersc.mig_datos_rectificacion SET colsucursal = 'c1', colgen = 'c2', colnat = 'c3', colgpo = 'c4', coltipo = 'c5', colfolio = 'c6' where tabla = 'kdpedesp';
update keplersc.mig_datos_rectificacion SET colsucursal = 'c1', colgen = 'c3', colnat = 'c4', colgpo = 'c5', coltipo = 'c6', colfolio = 'c7' where tabla = 'kdpedido';
update keplersc.mig_datos_rectificacion SET colsucursal = 'c1' where tabla = 'kdpedidoextras';
update keplersc.mig_datos_rectificacion SET colsucursal = 'c1' where tabla = 'kdpedidosugeridoconf';
update keplersc.mig_datos_rectificacion SET colsucursal = 'c1' where tabla = 'kdpedref';
update keplersc.mig_datos_rectificacion SET colsucursal = 'c1' where tabla = 'kdasig';
update keplersc.mig_datos_rectificacion SET colsucursal = 'c1', colgen = 'c4', colnat = 'c5', colgpo = 'c6', coltipo = 'c7', colfolio = 'c8' where tabla = 'kdpedrefmov';
update keplersc.mig_datos_rectificacion SET colsucursal = 'c20', colgen = 'c21', colnat = 'c22', colgpo = 'c23', coltipo = 'c24', colfolio = 'c25' where tabla = 'kdperfil';
update keplersc.mig_datos_rectificacion SET colsucursal = 'c1', coltipo = 'c2', colfolio = 'c3' where tabla = 'kdpun';
update keplersc.mig_datos_rectificacion SET colsucursal = 'c1', colgen = 'c5', colnat = 'c6', colgpo = 'c7', coltipo = 'c8', colfolio = 'c9' where tabla = 'kdref';
update keplersc.mig_datos_rectificacion SET colsucursal = 'c1', colgen = 'c5', colnat = 'c6', colgpo = 'c7', coltipo = 'c8', colfolio = 'c9' where tabla = 'kdrefdir';
update keplersc.mig_datos_rectificacion SET colsucursal = 'c1' where tabla = 'kdreflastmov';
update keplersc.mig_datos_rectificacion SET colsucursal = 'c1' where tabla = 'kdrefsusp';
update keplersc.mig_datos_rectificacion SET colsucursal = 'c1', coltipo = 'c2', colfolio = 'c3' where tabla = 'kdscierrecalidad';
update keplersc.mig_datos_rectificacion SET colsucursal = 'c6', coltipo = 'c7', colfolio = 'c8' where tabla = 'kdsercampana';
update keplersc.mig_datos_rectificacion SET colsucursal = 'c1', colgen = 'c6', colnat = 'c6', colgpo = 'c8', coltipo = 'c9', colfolio = 'c10' where tabla = 'kdserped';
update keplersc.mig_datos_rectificacion SET colsucursal = 'c1' where tabla = 'kdserpedmov';
update keplersc.mig_datos_rectificacion SET colsucursal = 'c1', colgen = 'c2', colnat = 'c3', colgpo = 'c4', coltipo = 'c5', colfolio = 'c6' where tabla = 'kdsunicosto';
insert into keplersc.mig_datos_rectificacion (tabla,colgen,colnat,colgpo,coltipo,colfolio,colsucursal) values('kdsunicosto_','','','','','','c7');
update keplersc.mig_datos_rectificacion SET colsucursal = 'c1', colgen = 'c2', colnat = 'c3', colgpo = 'c4', coltipo = 'c5', colfolio = 'c6' where tabla = 'kdtablanom';
update keplersc.mig_datos_rectificacion SET colsucursal = 'c1', coltipo = 'c2', colfolio = 'c3' where tabla = 'kdtiempos';
update keplersc.mig_datos_rectificacion SET colsucursal = 'c1', colfolio = 'c2' where tabla = 'kdtmktser';
update keplersc.mig_datos_rectificacion SET colsucursal = 'c1', colfolio = 'c2' where tabla = 'kdtmktser2';
update keplersc.mig_datos_rectificacion SET colsucursal = 'c20' where tabla = 'kdtmktserconf';
insert into keplersc.mig_datos_rectificacion (tabla,colgen,colnat,colgpo,coltipo,colfolio,colsucursal) values('kdtmktserconf_','','','','','','c2');
insert into keplersc.mig_datos_rectificacion (tabla,colgen,colnat,colgpo,coltipo,colfolio,colsucursal) values('kdtmktserconf__','','','','','','c3');
update keplersc.mig_datos_rectificacion SET colsucursal = 'c1', coltipo = '', colfolio = 'c3' where tabla = 'kdtord';
insert into keplersc.mig_datos_rectificacion (tabla,colgen,colnat,colgpo,coltipo,colfolio,colsucursal) values('kdtord_','c7','c8','c9','c10','c11','c1');
update keplersc.mig_datos_rectificacion SET colsucursal = 'c1', colgen = 'c5', colnat = 'c6', colgpo = 'c7', coltipo = 'c8', colfolio = 'c9' where tabla = 'kdtot';
update keplersc.mig_datos_rectificacion SET colsucursal = 'c4', colgen = 'c5', colnat = 'c6', colgpo = 'c7', coltipo = 'c8', colfolio = 'c9' where tabla = 'kdusraccess';
update keplersc.mig_datos_rectificacion SET colsucursal = 'c1', colgen = 'c5', colnat = 'c6', colgpo = 'c7', coltipo = 'c8', colfolio = 'c9' where tabla = 'kduxe';
update keplersc.mig_datos_rectificacion SET colsucursal = 'c1', colgen = 'c2' where tabla = 'kduxg';
update keplersc.mig_datos_rectificacion SET colsucursal = 'c1', colgen = 'c2', colnat = 'c3', colgpo = 'c4', coltipo = 'c5', colfolio = 'c6' where tabla = 'kdvalntcr';
insert into keplersc.mig_datos_rectificacion (tabla,colgen,colnat,colgpo,coltipo,colfolio,colsucursal) values('kdvalntcr_','','c7','c8','c9','c10','c1');
update keplersc.mig_datos_rectificacion SET colsucursal = 'c1', colgen = 'c2', colnat = 'c3', colgpo = 'c4', coltipo = 'c5', colfolio = 'c6' where tabla = 'kdvck';
update keplersc.mig_datos_rectificacion SET colsucursal = 'c1', colgen = 'c2', colnat = 'c3', colgpo = 'c4', coltipo = 'c5', colfolio = 'c6' where tabla = 'kdvcm';
update keplersc.mig_datos_rectificacion SET colsucursal = 'c4' where tabla = 'kdvenref';
update keplersc.mig_datos_rectificacion SET colsucursal = 'c1', colgen = 'c4', colnat = 'c5', colgpo = 'c6', coltipo = 'c7', colfolio = 'c8' where tabla = 'kdventas';
update keplersc.mig_datos_rectificacion SET colsucursal = 'c1', colgen = 'c6', colnat = 'c7', colgpo = 'c8', coltipo = 'c9', colfolio = 'c10' where tabla = 'kdvnpun';
update keplersc.mig_datos_rectificacion SET colsucursal = 'c1', colgen = 'c6', colnat = 'c7', colgpo = 'c8', coltipo = 'c9', colfolio = 'c10' where tabla = 'kdvntall';
update keplersc.mig_datos_rectificacion SET colsucursal = 'c1', colgen = 'c2', colnat = 'c3', colgpo = 'c4', coltipo = 'c5', colfolio = 'c6' where tabla = 'kdvobs';
update keplersc.mig_datos_rectificacion SET colsucursal = 'c1' where tabla = 'kdvorder';
update keplersc.mig_datos_rectificacion SET colsucursal = 'c1' where tabla = 'kdxd';
update keplersc.mig_datos_rectificacion SET colsucursal = 'c1', colgen = 'c2', colnat = 'c3', colgpo = 'c4', coltipo = 'c5', colfolio = 'c6' where tabla = 'kdxe';
update keplersc.mig_datos_rectificacion SET colsucursal = 'c1', colgpo = 'c4', coltipo = 'c5' where tabla = 'kdxf';
insert into keplersc.mig_datos_rectificacion (tabla,colgen,colnat,colgpo,coltipo,colfolio,colsucursal) values('kdxf_','','','c6','c7','','');
update keplersc.mig_datos_rectificacion SET colsucursal = 'c1' where tabla = 'kdxv';
update keplersc.mig_datos_rectificacion SET colsucursal = 'c1', colfolio = 'c2' where tabla = 'prepicking';
update keplersc.mig_datos_rectificacion SET colsucursal = 'c1', colgen = 'c2', colnat = 'c3', colgpo = 'c4', coltipo = 'c5', colfolio = 'c6' where tabla = 'kdcomismov2';
update keplersc.mig_datos_rectificacion SET colsucursal = 'c1', colgen = 'c2', colnat = 'c3', colgpo = 'c4', coltipo = 'c5', colfolio = 'c6' where tabla = 'kdcomisadis';
update keplersc.mig_datos_rectificacion SET colsucursal = 'c1', colgen = 'c2', colnat = 'c3', colgpo = 'c4', coltipo = 'c5', colfolio = 'c6' where tabla = 'kdbonif';
update keplersc.mig_datos_rectificacion SET colsucursal = 'c14', colgen = 'c15', colnat = 'c16', colgpo = 'c17', coltipo = 'c18', colfolio = 'c19' where tabla = 'kdc22201';
update keplersc.mig_datos_rectificacion SET colsucursal = 'c14', colgen = 'c15', colnat = 'c16', colgpo = 'c17', coltipo = 'c18', colfolio = 'c19' where tabla = 'kdc22202';
update keplersc.mig_datos_rectificacion SET colsucursal = 'c14', colgen = 'c15', colnat = 'c16', colgpo = 'c17', coltipo = 'c18', colfolio = 'c19' where tabla = 'kdc22203';
update keplersc.mig_datos_rectificacion SET colsucursal = 'c14', colgen = 'c15', colnat = 'c16', colgpo = 'c17', coltipo = 'c18', colfolio = 'c19' where tabla = 'kdc22204';
update keplersc.mig_datos_rectificacion SET colsucursal = 'c14', colgen = 'c15', colnat = 'c16', colgpo = 'c17', coltipo = 'c18', colfolio = 'c19' where tabla = 'kdc22205';
update keplersc.mig_datos_rectificacion SET colsucursal = 'c14', colgen = 'c15', colnat = 'c16', colgpo = 'c17', coltipo = 'c18', colfolio = 'c19' where tabla = 'kdc22206';
update keplersc.mig_datos_rectificacion SET colsucursal = 'c14', colgen = 'c15', colnat = 'c16', colgpo = 'c17', coltipo = 'c18', colfolio = 'c19' where tabla = 'kdc22207';
update keplersc.mig_datos_rectificacion SET colsucursal = 'c14', colgen = 'c15', colnat = 'c16', colgpo = 'c17', coltipo = 'c18', colfolio = 'c19' where tabla = 'kdc22208';
update keplersc.mig_datos_rectificacion SET colsucursal = 'c14', colgen = 'c15', colnat = 'c16', colgpo = 'c17', coltipo = 'c18', colfolio = 'c19' where tabla = 'kdc22209';
update keplersc.mig_datos_rectificacion SET colsucursal = 'c14', colgen = 'c15', colnat = 'c16', colgpo = 'c17', coltipo = 'c18', colfolio = 'c19' where tabla = 'kdc22210';
update keplersc.mig_datos_rectificacion SET colsucursal = 'c14', colgen = 'c15', colnat = 'c16', colgpo = 'c17', coltipo = 'c18', colfolio = 'c19' where tabla = 'kdc22211';
update keplersc.mig_datos_rectificacion SET colsucursal = 'c14', colgen = 'c15', colnat = 'c16', colgpo = 'c17', coltipo = 'c18', colfolio = 'c19' where tabla = 'kdc22212';
update keplersc.mig_datos_rectificacion SET colsucursal = 'c3'  where tabla = 'kdconfgen';
update keplersc.mig_datos_rectificacion SET colsucursal = 'c1', colgen = 'c2', colnat = 'c3', colgpo = 'c4', coltipo = 'c5', colfolio = 'c6' where tabla = 'kdcosttall';
update keplersc.mig_datos_rectificacion SET colsucursal = 'c1'  where tabla = 'kdctasser';
update keplersc.mig_datos_rectificacion SET colsucursal = 'c1', colgen = 'c2', colnat = 'c3', colgpo = 'c4', coltipo = 'c5', colfolio = 'c6' where tabla = 'kdf3ncant'; 
update keplersc.mig_datos_rectificacion SET colsucursal = 'c1', colgen = 'c2', colnat = 'c3', colgpo = 'c4', coltipo = 'c5', colfolio = 'c6' where tabla = 'kdf3sustitucion'; 
insert into keplersc.mig_datos_rectificacion (tabla,colgen,colnat,colgpo,coltipo,colfolio,colsucursal) values('kdf3sustitucion_','','','c8','c9','c10','c1');
update keplersc.mig_datos_rectificacion SET colsucursal = 'c1'  where tabla = 'kdfecert';
--Verificar update keplersc.mig_datos_rectificacion SET colsucursal = 'c1', colgen = 'c4', colnat = 'c5', colgpo = 'c6', coltipo = 'c7', colfolio = 'c8' where tabla = 'kdcosttall';
update keplersc.mig_datos_rectificacion SET colsucursal = 'c1', colgen = 'c4', colnat = 'c5', colgpo = 'c6', coltipo = 'c7', colfolio = 'c8' where tabla = 'kdipva';
update keplersc.mig_datos_rectificacion SET colsucursal = 'c1', colgen = 'c6', colnat = 'c7', colgpo = 'c8', coltipo = 'c9', colfolio = 'c10' where tabla = 'kdordfact';
insert into keplersc.mig_datos_rectificacion (tabla,colgen,colnat,colgpo,coltipo,colfolio,colsucursal) values('kdpedesp_','c16','c17','c18','c19','c20','c14');
update keplersc.mig_datos_rectificacion SET colsucursal = 'c1', colgen = 'c2', colnat = 'c3', colgpo = 'c4', coltipo = 'c5', colfolio = 'c6' where tabla = 'kdpedesp';
update keplersc.mig_datos_rectificacion SET colsucursal = 'c2' where tabla = 'kdtallcont';
update keplersc.mig_datos_rectificacion SET colsucursal = 'c1' where tabla = 'kdtomas';
update keplersc.mig_datos_rectificacion SET colsucursal = 'c1' where tabla = 'kdud';
update keplersc.mig_datos_rectificacion SET colsucursal = 'c1' where tabla = 'kdvcsi';
update keplersc.mig_datos_rectificacion SET colsucursal = 'c3' where tabla = 'kdvehref';
update keplersc.mig_datos_rectificacion SET colsucursal = 'c1', colgen = 'c3', colnat = 'c4', colgpo = 'c5', coltipo = 'c6', colfolio = 'c7' where tabla = 'kdncred';
update keplersc.mig_datos_rectificacion SET colsucursal = 'c1', colgen = 'c3', colnat = 'c4', colgpo = 'c5', coltipo = 'c6', colfolio = 'c7' where tabla = 'kdnotacred';
insert into keplersc.mig_datos_rectificacion (tabla,colgen,colnat,colgpo,coltipo,colfolio,colsucursal) values('kdnotacred_','c12','c13','c14','c15','c16','c1');
update keplersc.mig_datos_rectificacion SET colsucursal = 'c1' where tabla = 'kdvargv';
update keplersc.mig_datos_rectificacion SET auditada = 'S';
*/
--***************************************	
--FIN 2. 
--***************************************
	
	
--***************************************	
--3. Marcar registros como depurables haciendo excepciones
--***************************************	
/*
	update keplersc.mig_datos_rectificacion set depurar = 'S'
	where tabla not in ('catpuntos','citasautorizacionpuntos',
	'kdcatcitasordenes','kdcattipocitas','kdcattmktacciones','kdtipsin',
	'kdtmktaccion','kdtmktmotivo','kdtmktmotres','kdtmktresacc',
	'kdtmktresult','kdvaltipsin','mig_ctrl_tablas_proceso','mig_k75_op',
	'mig_k75_sub','mig_k75_sub_call','migracion_75to80','migracion_log',
	'migracion_tablas75','migracion_tablascampos75','mig_datos_rectificacion','kdstatustabulacion',
	'kdpuntop','kdserconfctas','kdstatuspun','kdtoper','kdtipoordentipopuntos');

	--Marcar tablas como no depurables
	update keplersc.mig_datos_rectificacion set depurar = 'N'
	where tabla in ('catpuntos','citasautorizacionpuntos',
	'kdcatcitasordenes','kdcattipocitas','kdcattmktacciones','kdtipsin',
	'kdtmktaccion','kdtmktmotivo','kdtmktmotres','kdtmktresacc',
	'kdtmktresult','kdvaltipsin','mig_ctrl_tablas_proceso','mig_k75_op',
	'mig_k75_sub','mig_k75_sub_call','migracion_75to80','migracion_log',
	'migracion_tablas75','migracion_tablascampos75','mig_datos_rectificacion','kdstatustabulacion',
	'kdpuntop','kdserconfctas','kdstatuspun','kdtoper','kdtipoordentipopuntos');
*/
--***************************************	
--FIN 3.
--***************************************		
	
--***************************************	
--4. Depuracion de tablas
--***************************************	
/*
	--Depuracion de todas las tablas productivas, excepto marcadas en paso anterior
	for _tabla in select tabla from keplersc.mig_datos_rectificacion re where upper(re.depurar) = 'S'
	loop 
		expSql=concat('truncate keplersc.',replace(_tabla,'_',''));
		raise notice 'Ejecutando--> % ', expSql;
		execute expSql;
	end loop;	
*/
--***************************************	
--FIN 4.
--***************************************	
	
--***************************************	
--INI 5. Ajustar llaves e índices para evitar duplicidad de registros
--***************************************

--alter table keplersc.kdcomismov drop CONSTRAINT pk_kdcomismov;
--alter table keplersc.kdcomismov add CONSTRAINT pk_kdcomismov PRIMARY KEY (c1, c2, c3, c4, c5, c6,c10);

--***************************************	
--FIN 5. 
--***************************************
	
--***************************************	
--INI 6. Ajustar tamaño de campos
--***************************************
/*
	ALTER TABLE keplersc.kdasig ALTER COLUMN c5 TYPE varchar(10) USING c5::varchar;
	ALTER TABLE keplersc.kdasig ALTER COLUMN c6 TYPE varchar(10) USING c6::varchar;
*/
--***************************************	
--FIN 6. 
--***************************************	

--***************************************	
--INI 7. MIGRACION DE DATOS ORIGEN K75
--***************************************
--update keplersc.mig_ctrl_tablas_proceso set seleccionada = 'N';	
/*
	update keplersc.mig_ctrl_tablas_proceso set seleccionada = 'S'
	where nombre_tabla not in ('catpuntos','citasautorizacionpuntos',
	'kdcatcitasordenes','kdcattipocitas','kdcattmktacciones','kdtipsin',
	'kdtmktaccion','kdtmktmotivo','kdtmktmotres','kdtmktresacc',
	'kdtmktresult','kdvaltipsin','mig_ctrl_tablas_proceso','mig_k75_op',
	'mig_k75_sub','mig_k75_sub_call','migracion_75to80','migracion_log',
	'migracion_tablas75','migracion_tablascampos75','mig_datos_rectificacion','kdstatustabulacion',
	'kdpuntop','kdserconfctas','kdstatuspun','kdtoper');
	
update keplersc.mig_ctrl_tablas_proceso set seleccionada = 'N';

update keplersc.mig_ctrl_tablas_proceso set seleccionada = 'S'
where nombre_tabla in('kdadsegment','kdadvariable','kdcatcoach','kdcatestatusorden',
'kdcatgastos','kdcattipoctas','kdcatubicacionvehiculo','kdf3uni',
'kdfe33can','kdfe33m1','kdef33params','kdfecert',
'kdfecfd','kdfepacs','kdhorpag','kdic','kdice2','kdice3','kdinpdet','kdip',
'kdivl','kdkl','kdkp','kdkr','kdku','kdmarca','kdmaster','kdordsint',
'kdpaq','kdpaqconf','kdpedidoextras','kdpedrefcom',
'kdpedrefmov','kdpreciospuntos','kdtab','kdtablanom',
'kdtiempos','kdtisan','kdtmktaccion','kdtmktmotivo',
'kdtmktmotres','kdtmktresacc','kdtmktresult','kdtmktser',
'kdtmktserconf','kdtvr2','kdvehqueue','kdvehref','prepicking');
*/


--Migracion de tablas dinamicas k75 desde k80
--***************************************	
--FIN 6. Migracion
--***************************************

--***************************************	
--INI 7. Ajustar RFC's
--***************************************
/*	
-- Rectificacion de RFC proveedores
update keplersc.kdxd set c10= replace(c10,'-','');
update keplersc.kdxd set c10= replace(c10,' ','');		

-- Rectificacion de RFC clientes
update keplersc.kdud set c10= replace(c10,'-','');
update keplersc.kdud set c10= replace(c10,' ','');	
*/
--***************************************	
--FIN 7. 
--***************************************





--***********************************************************
--Consolidacion de tablas contables
--***********************************************************
/*
insert into keplersc.kdcpolizas select * from keplersc.kdc22105;
update keplersc.kdcpolizas set c51=2105 where c51=0;
insert into keplersc.kdcpolizas select * from keplersc.kdc22106;
update keplersc.kdcpolizas set c51=2106 where c51=0;
insert into keplersc.kdcpolizas select * from keplersc.kdc22107;
update keplersc.kdcpolizas set c51=2107 where c51=0;
insert into keplersc.kdcpolizas select * from keplersc.kdc22108;
update keplersc.kdcpolizas set c51=2108 where c51=0;
insert into keplersc.kdcpolizas select * from keplersc.kdc22109;
update keplersc.kdcpolizas set c51=2109 where c51=0;
insert into keplersc.kdcpolizas select * from keplersc.kdc22110;
update keplersc.kdcpolizas set c51=2110 where c51=0;
insert into keplersc.kdcpolizas select * from keplersc.kdc22111;
update keplersc.kdcpolizas set c51=2111 where c51=0;
insert into keplersc.kdcpolizas select * from keplersc.kdc22112;
update keplersc.kdcpolizas set c51=2112 where c51=0;
insert into keplersc.kdcpolizas select * from keplersc.kdc22201;
update keplersc.kdcpolizas set c51=2201 where c51=0;
insert into keplersc.kdcpolizas select * from keplersc.kdc22202;
update keplersc.kdcpolizas set c51=2202 where c51=0;
insert into keplersc.kdcpolizas select * from keplersc.kdc22203;
update keplersc.kdcpolizas set c51=2203 where c51=0;
insert into keplersc.kdcpolizas select * from keplersc.kdc22204;
update keplersc.kdcpolizas set c51=2204 where c51=0;
insert into keplersc.kdcpolizas select * from keplersc.kdc22205;
update keplersc.kdcpolizas set c51=2205 where c51=0;
insert into keplersc.kdcpolizas select * from keplersc.kdc22206;
update keplersc.kdcpolizas set c51=2206 where c51=0;
insert into keplersc.kdcpolizas select * from keplersc.kdc22207;
update keplersc.kdcpolizas set c51=2207 where c51=0;
insert into keplersc.kdcpolizas select * from keplersc.kdc22208;
update keplersc.kdcpolizas set c51=2208 where c51=0;
insert into keplersc.kdcpolizas select * from keplersc.kdc22209;
update keplersc.kdcpolizas set c51=2209 where c51=0;
insert into keplersc.kdcpolizas select * from keplersc.kdc22210;
update keplersc.kdcpolizas set c51=2210 where c51=0;
insert into keplersc.kdcpolizas select * from keplersc.kdc22211;
update keplersc.kdcpolizas set c51=2211 where c51=0;
insert into keplersc.kdcpolizas select * from keplersc.kdc22212;
update keplersc.kdcpolizas set c51=2212 where c51=0;

--consolidar registros kdc1
insert into keplersc.kdccuentas select * from keplersc.kdc122;   
 */	
--***********************************************************
--FIN Consolidacion de tablas contables
--***********************************************************	

	
	
	resultado := 'Proceso terminado';
	return resultado;
end;
$function$
