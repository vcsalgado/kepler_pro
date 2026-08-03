CREATE OR REPLACE FUNCTION keplersc.cont_nivel_cuentas(anio_cuenta text)
 RETURNS TABLE(anio character varying, cuenta character varying, cuenta_padre character varying, nivel integer)
 LANGUAGE plpgsql
AS $function$
DECLARE
    cuenta_actual RECORD;
    cuenta_padre RECORD;
    nivel_actual INT;
    cuenta_padre_actual VARCHAR;
BEGIN
    CREATE TABLE IF NOT EXISTS keplersc.cuentas_niveles (
        anio VARCHAR,
        cuenta VARCHAR,
        cuenta_padre VARCHAR,
        nivel INT,
        PRIMARY KEY (anio, cuenta)
    );

    DELETE FROM keplersc.cuentas_niveles
    WHERE keplersc.cuentas_niveles.anio = anio_cuenta;

    INSERT INTO keplersc.cuentas_niveles (anio, cuenta, cuenta_padre, nivel)
    SELECT anio_cuenta, c1, '', 0 FROM keplersc.kdc1_view where keplersc.kdc1_view.anio = anio_cuenta
    ON CONFLICT DO NOTHING;

    FOR cuenta_actual IN SELECT keplersc.kdc1_view.anio, c1 as cuenta FROM keplersc.kdc1_view where keplersc.kdc1_view.anio = anio_cuenta ORDER BY LENGTH(c1), c1 LOOP
        nivel_actual := 1;
        cuenta_padre_actual := 'mayor';

        FOR cuenta_padre IN SELECT keplersc.cuentas_niveles.cuenta, keplersc.cuentas_niveles.nivel FROM keplersc.cuentas_niveles WHERE keplersc.cuentas_niveles.anio = anio_cuenta and keplersc.cuentas_niveles.nivel > 0 ORDER BY LENGTH(keplersc.cuentas_niveles.cuenta) DESC LOOP
            IF position(cuenta_padre.cuenta in cuenta_actual.cuenta) = 1 AND LENGTH(cuenta_actual.cuenta) > LENGTH(cuenta_padre.cuenta) THEN
                nivel_actual := cuenta_padre.nivel + 1;
                cuenta_padre_actual := cuenta_padre.cuenta;
                EXIT;
            END IF;
        END LOOP;

        UPDATE keplersc.cuentas_niveles SET nivel = nivel_actual, cuenta_padre = cuenta_padre_actual WHERE keplersc.cuentas_niveles.anio = cuenta_actual.anio and keplersc.cuentas_niveles.cuenta = cuenta_actual.cuenta;
    END LOOP;

    RETURN QUERY SELECT * FROM keplersc.cuentas_niveles WHERE keplersc.cuentas_niveles.anio = anio_cuenta ORDER BY keplersc.cuentas_niveles.anio, keplersc.cuentas_niveles.cuenta;

    --DROP TABLE IF EXISTS keplersc.cuentas_niveles;
END;
$function$
