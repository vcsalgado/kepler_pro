CREATE OR REPLACE FUNCTION keplersc.ifz_carga_piezas_embarque(k_embarque text, sucursal text)
 RETURNS TABLE(piezas xml)
 LANGUAGE plpgsql
AS $function$
DECLARE
    _xml text := '';
BEGIN
    -- Construcción segura de la consulta SQL dinámica con ambas variables
    _xml := format($f$
        SELECT 
            pz.item_id AS k_parte,
            COALESCE(ini.c2, 'No se encuentra la refaccion') AS k_descr,
            pz.order_quantity AS k_qo,
            pz.backorder_quantity AS k_qb,
            pz.shipped_quantity AS k_q,
            COALESCE(ini.c19, '') AS k_unidad,
            COALESCE(pz.charge_amount, 0) AS k_precio,
            COALESCE(pz.charge_amount, 0) * pz.shipped_quantity AS k_monto,
            coalesce((SELECT pcl.clave_original 
                FROM keplersc.prod_consulta_lista(%L, pz.item_id, 'CLAVE') pcl
                LIMIT 1
            ),'')  AS k_partesel,
            coalesce((SELECT pc2.descripcion 
                FROM keplersc.prod_consulta_lista(%L, pz.item_id, 'CLAVE') pc2
                LIMIT 1
            ),'') AS k_parteseldesc
        FROM keplersc.ifz_parts_shipper_embarque ipse
        JOIN keplersc.ifz_parts_shipper_piezas pz ON ipse.id = pz.shipment_id
        LEFT JOIN keplersc.kdini ini ON ini.c1 = pz.item_id
        WHERE ipse.documento_id = %L
    $f$, sucursal, sucursal, k_embarque);  -- 👈 Aquí inyectamos sucursal y k_embarque

    RAISE NOTICE 'SQL ejecutado: %', _xml;

    SELECT query_to_xml(_xml, false, true, '''')::xml INTO piezas;

    RETURN QUERY SELECT piezas;

EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY SELECT xmlelement(name error, 
            'ifz_carga_piezas_embarque() [' || SQLSTATE || '] ' || SQLERRM)::xml;
END;
$function$
