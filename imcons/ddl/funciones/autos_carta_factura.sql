CREATE OR REPLACE FUNCTION keplersc.autos_carta_factura(dataxml xml)
 RETURNS xml
 LANGUAGE plpgsql
AS $function$
declare
--Descripcion: Obtener la info para elaborar la carta factur de un auto
--Autor: Victor Salgado
--Fecha: 25/Abril/2024
--Bitacora de cambios
--23/05/2024 LGLG obtener vendedor y tipo de operacion  
--17/06/2024 MSS Obtener datos de vehiculos usados de las mismas columnas que se obtienen en la factura y empresa de KDCONC 

--Variables de definicion de documento
	sucursal text = '';
	inventario text = '';

	--Variables de uso general 
	strValor text = '';
	intValor int = 0;
	expSql text = '';
	espacio text = ' ';
	cero text = '0';
	totReg int = 0;
	recInf record;
	recRes record;


	ven_status numeric;
	ven_precio numeric; 
	ven_folio text;
	ven_fecha date;
	ven_cli text;

	k_clave_vendedor text;
	k_nombre_vendedor text;
	k_clave_operacion text;
	k_nombre_operacion text;

	--Variables de retorno
	xmlFactura xml;

begin	
	sucursal := (xpath('//document/sucursal_id/text()', dataxml))[1];
	inventario := (xpath('//document/inventario/text()', dataxml))[1];

	--Validar que el inventario existe
	select count(*) into totReg from keplersc.kdinf where c1=sucursal and c2=inventario;
	if totReg=0 then
		raise exception 'El inventario no existe en la sucursal.';
	end if;
	
	select * into recInf from keplersc.kdinf where c1=sucursal and c2=inventario;

	--Validar que vehiculo este facturado
	if recInf.c32 <20 then
		raise exception 'No se puede crear una carta factura de un vehículo no facturado';
	end if;

	--Validar que el ultimo movto en venta no sea de cancelacion
	select count(*) into totReg from keplersc.kdventas where c1=sucursal and c2=inventario;
	if totReg=0 then
		raise exception 'El inventario no está facturado.';
	end if;	

	select vn.c10,vn.c26,vn.c8,vn.c9,vn.c11 into ven_status, ven_precio,ven_folio,ven_fecha,ven_cli
	from keplersc.kdventas as vn inner join keplersc.kdm1 as m1 on m1.c1=vn.c1 and m1.c2=vn.c4
	and m1.c3=vn.c5 and m1.c4=vn.c6 and m1.c5=vn.c7 and m1.c6=vn.c8
	where vn.c1=sucursal and vn.c2=inventario order by vn.c9 desc, m1.c69 desc limit 1;

	if ven_status=10 then
		raise exception 'No se puede crear una carta factura de un vehiculo con su ultima factura cancelada.';
	end if;

	--obtener vendedor y tipo de operacion LGLG 23/05/2024
	select vn.c16, uv.c3, vn.c17, top.c2 
	into k_clave_vendedor, k_nombre_vendedor, k_clave_operacion, k_nombre_operacion
	from keplersc.kdventas as vn
	inner join keplersc.kduv as uv on uv.c1=vn.c1 and uv.c2=vn.c16
	inner join keplersc.kdtop as top on top.c1=vn.c17
	where vn.c1=sucursal and vn.c2=inventario
	and vn.c10=0 order by vn.c8 desc limit 1;
	
	drop table if exists tmpResultados;
	--Obtener datos de vehiculos usados de las mismas columnas que se obtienen en la factura y empresa de KDCONC MSS 17/06/2024  
	create temp table tmpResultados as
	select inf.c1 as sucursal, inf.c2 as inventario,
	current_date as k_fecha, ud.c3 as k_comprador, 
	case when ud.c45<>'' then
		case when ud.c46<>'' then
			ud.c4 || ' NO. ' || ud.c45 || ' INT. ' || ud.c46
		else
			ud.c4 || ' NO. ' || ud.c45
		end
	else
		ud.c4
	end k_calle,
	ud.c5 as k_colonia,
	case when ud.c47<>'' then 
		case when ud.c48<>'' then
			case when ud.c27<>'' then 
				ud.c6 || ' ' ||ud.c47 || ', ' || ud.c48 || ' C.P. ' || ud.c27
			else
				ud.c6 || ' ' ||ud.c47 || ', ' || ud.c48
			end
		else
			case when ud.c27<>'' then 
				ud.c6 || ' ' || ud.c47 || ' C.P. ' || ud.c27
			else
				ud.c6 || ' ' || ud.c47
			end		
		end
	else
		case when ud.c48<>'' then
			case when ud.c27<>'' then 
				ud.c6 ||  ', ' || ud.c48 || ' C.P. ' || ud.c27
			else
				ud.c6 ||  ', ' || ud.c48
			end
		else
			case when ud.c27<>'' then 
				ud.c6 || ' C.P. ' || ud.c27
			else
				ud.c6
			end		
		end
	end as k_ciudad,
	ud.c7 || '        ' || ud.c8 as k_telefono,
	case when substring(trim(inventario),8,1)='N' then 
		marca.c2 
	else	
		upper(inf.c85)
	end as k_marca,
	case when substring(trim(inventario),8,1)='N' then 
		inf.c15
	else
		inf.c87
	end as k_modelo,
	inf.c3 as k_opcion,
	upper(inf.c4) as k_tipo,
	inf.c6 as k_motor,
	inf.c5 as k_serie,
	ce.c4 as k_color,
	inf.c8 as k_transmision,
	inf.c14 as k_rfv,
	inf.c13 as k_clavevehi,
	case when substring(trim(inventario),8,1)='N' then
		iv.c53 
	else
		inf.c94
	end as k_combustible,
	case when substring(trim(inventario),8,1)='N' then
		iv.c50 
	else
		inf.c92
	end as k_cilindros,
	case when substring(trim(inventario),8,1)='N' then
		iv.c51 
	else
		inf.c91
	end as k_pasajeros,
	case when substring(trim(inventario),8,1)='N' then
		iv.c54 
	else 
		inf.c93
	end as k_puertas,
	case when substring(trim(inventario),8,1)='N' then 
		iv.c52 
	else 
		inf.c90
	end as k_procedencia,
	inf.c26 as k_pedimento,
	ven_precio as k_precio,
	ven_folio as k_factura,
	ven_fecha as k_fecha_venta,
	k_clave_vendedor as k_clave_vendedor,
	k_nombre_vendedor as k_nombre_vendedor,
	ce3.c4 as k_int,
	cn.c2 as k_empresa,
	k_clave_operacion as k_clave_operacion,
	k_nombre_operacion as k_nombre_operacion,
	ms.c5 as k_num_distribuidor,
	ms.col_telefono as k_tel_distribuidor,
	ms.col_direccion || ' ' || ms.c4 as k_direccion_distribuidor,
	'Tel. '|| ms.col_telefono || '   Fax.' ||ms.col_fax || '   ' || ms.col_paginaweb as k_adicionales_distribuidor,
	nombre_firma_atn_ctes as k_firma_atn_ctes
	from keplersc.kdinf inf inner join keplersc.kdud ud on ud.c2=ven_cli
	inner join keplersc.kdmarca marca on marca.c1=inf.c17
	left outer join keplersc.kdice2 ce on ce.c1=inf.c3 and ce.c3=inf.c10
	left outer join keplersc.kdice3 ce3 on ce3.c1=inf.c3 and ce3.c3=inf.c11
	inner join keplersc.kdiv iv on iv.c1=inf.c3
	inner join keplersc.kdms ms on ms.c1=inf.c1
	inner join keplersc.kdconc cn on cn.c1=ms.c5
	where inf.c1=sucursal and inf.c2=inventario;

	expSql='select * from tmpResultados'; 


	select query_to_xml(expSql,false,true,'') into xmlFactura;
	--raise notice '%', xmlFactura

	return xmlFactura;

END;
$function$
