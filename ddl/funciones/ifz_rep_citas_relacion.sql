CREATE OR REPLACE FUNCTION keplersc.ifz_rep_citas_relacion(dataxml xml)
 RETURNS TABLE(fecha_cita text, id_cita text, folio_cita text, vin text, cliente text, estatus text)
 LANGUAGE plpgsql
AS $function$
DECLARE 
    sucursal_id text := '';
    fecha_ini text := '';
    fecha_fin text := '';
    
    f_ini_ts timestamp;
    f_fin_ts timestamp;
    transaccion_id text := '';
    error text := '';

BEGIN
    transaccion_id := keplersc.log_tran_id_gen();    

    sucursal_id := COALESCE((xpath('//document/sucursal_id/text()', dataxml))[1]::text, '');
    fecha_ini   := COALESCE((xpath('//document/fecha_ini/text()', dataxml))[1]::text, '');
    fecha_fin   := COALESCE((xpath('//document/fecha_fin/text()', dataxml))[1]::text, '');

    IF fecha_ini LIKE '%/%' THEN
        f_ini_ts := to_timestamp(fecha_ini || ' 00:00:00', 'DD/MM/YYYY HH24:MI:SS');
        f_fin_ts := to_timestamp(fecha_fin || ' 23:59:59', 'DD/MM/YYYY HH24:MI:SS');
    ELSE
        f_ini_ts := to_timestamp(fecha_ini || ' 00:00:00', 'YYYY-MM-DD HH24:MI:SS');
        f_fin_ts := to_timestamp(fecha_fin || ' 23:59:59', 'YYYY-MM-DD HH24:MI:SS');
    END IF;

    RETURN QUERY
    WITH CitasEnRango AS (
        SELECT 
            c.id_cita,
            k.c2::text AS folio_cita,
            k.c4::text AS cliente,
            k.c9::text AS vin,
            to_char(k.c16, 'YYYY-MM-DD HH24:MI:SS') AS fecha_cita
        FROM keplersc.kdctasser k
        LEFT JOIN keplersc.ifz_bp_citas c 
            ON k.c1 = c.sucursal 
           AND k.c2 = c.folio_cita
        WHERE k.c16 >= f_ini_ts
          AND k.c16 <= f_fin_ts
          AND (sucursal_id IS NULL OR sucursal_id = '' OR k.c1 = sucursal_id)
    ),
    SecuenciaIDs AS (
        SELECT generate_series(
            COALESCE((SELECT MIN(cr.id_cita) FROM CitasEnRango cr WHERE cr.id_cita IS NOT NULL), 1),
            COALESCE((SELECT MAX(cr.id_cita) FROM CitasEnRango cr WHERE cr.id_cita IS NOT NULL), 1)
        ) AS id_esperado
    ),
    Unificacion AS (
        SELECT 
            cr.fecha_cita,
            s.id_esperado::text AS id_cita,
            cr.folio_cita,
            cr.vin,
            cr.cliente,
            CASE 
                WHEN cr.folio_cita IS NULL THEN 'SALTO DE CONSECUTIVO (SIN REGISTRO)'
                ELSE 'ASIGNADO'
            END AS estatus,
            s.id_esperado AS orden_id
        FROM SecuenciaIDs s
        LEFT JOIN CitasEnRango cr ON s.id_esperado = cr.id_cita

        UNION ALL

        SELECT 
            cr.fecha_cita,
            ''::text AS id_cita,
            cr.folio_cita,
            cr.vin,
            cr.cliente,
            'NO ASIGNADA EN IFZ_BP_CITAS' AS estatus,
            NULL::integer AS orden_id
        FROM CitasEnRango cr
        WHERE cr.id_cita IS NULL
    )
    SELECT 
        COALESCE(u.fecha_cita, '') AS fecha_cita,
        u.id_cita,
        COALESCE(u.folio_cita, '') AS folio_cita,
        COALESCE(u.vin, '') AS vin,
        COALESCE(u.cliente, '') AS cliente,
        u.estatus
    FROM Unificacion u
    ORDER by u.fecha_cita, u.orden_id ASC, u.folio_cita ASC;

EXCEPTION
    WHEN OTHERS THEN
        error := 'keplersc.ifz_rep_citas_relacion() ' || '[' || SQLSTATE || '] ' || SQLERRM;
        RAISE EXCEPTION '%', error; 
END;
$function$
