-- // CONFIGURACION
SET DEFINE OFF;
SET SERVEROUTPUT ON SIZE UNLIMITED;
WHENEVER SQLERROR EXIT FAILURE ROLLBACK;

PROMPT PASO 1: VERIFICAR O CREAR TABLAS

-- // TABLA: sucursales_automotora
DECLARE
    v_existe NUMBER;
    v_columnas NUMBER;
    v_total NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_existe FROM user_tables
    WHERE table_name = 'SUCURSALES_AUTOMOTORA';
    IF v_existe = 0 THEN
        EXECUTE IMMEDIATE q'~CREATE TABLE sucursales_automotora (
    id_sucursal NUMBER GENERATED ALWAYS AS IDENTITY,
    nombre VARCHAR2(100) NOT NULL,
    direccion VARCHAR2(200) NOT NULL,
    comuna VARCHAR2(80) NOT NULL,
    CONSTRAINT a_pk_sucursal PRIMARY KEY (id_sucursal),
    CONSTRAINT a_uk_sucursal UNIQUE (nombre)
)~';
    ELSE
        SELECT COUNT(*), COUNT(CASE WHEN column_name IN ('ID_SUCURSAL','NOMBRE','DIRECCION','COMUNA') THEN 1 END)
        INTO v_total, v_columnas FROM user_tab_columns
        WHERE table_name = 'SUCURSALES_AUTOMOTORA';
        IF v_total <> 4 OR v_columnas <> 4 THEN
            RAISE_APPLICATION_ERROR(-20090, 'Estructura incompatible: sucursales_automotora');
        END IF;
    END IF;
END;
/

-- // TABLA: clientes_automotora
DECLARE
    v_existe NUMBER;
    v_columnas NUMBER;
    v_total NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_existe FROM user_tables
    WHERE table_name = 'CLIENTES_AUTOMOTORA';
    IF v_existe = 0 THEN
        EXECUTE IMMEDIATE q'~CREATE TABLE clientes_automotora (
    id_cliente NUMBER GENERATED ALWAYS AS IDENTITY,
    documento VARCHAR2(25) NOT NULL,
    nombre VARCHAR2(120) NOT NULL,
    telefono VARCHAR2(25) NOT NULL,
    email VARCHAR2(120),
    CONSTRAINT a_pk_cliente PRIMARY KEY (id_cliente),
    CONSTRAINT a_uk_documento_cliente UNIQUE (documento)
)~';
    ELSE
        SELECT COUNT(*), COUNT(CASE WHEN column_name IN ('ID_CLIENTE','DOCUMENTO','NOMBRE','TELEFONO','EMAIL') THEN 1 END)
        INTO v_total, v_columnas FROM user_tab_columns
        WHERE table_name = 'CLIENTES_AUTOMOTORA';
        IF v_total <> 5 OR v_columnas <> 5 THEN
            RAISE_APPLICATION_ERROR(-20090, 'Estructura incompatible: clientes_automotora');
        END IF;
    END IF;
END;
/

-- // TABLA: vendedores_automotora
DECLARE
    v_existe NUMBER;
    v_columnas NUMBER;
    v_total NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_existe FROM user_tables
    WHERE table_name = 'VENDEDORES_AUTOMOTORA';
    IF v_existe = 0 THEN
        EXECUTE IMMEDIATE q'~CREATE TABLE vendedores_automotora (
    id_vendedor NUMBER GENERATED ALWAYS AS IDENTITY,
    id_sucursal NUMBER NOT NULL,
    documento VARCHAR2(25) NOT NULL,
    nombre VARCHAR2(120) NOT NULL,
    porcentaje_comision NUMBER(5,2) DEFAULT 2 NOT NULL,
    activo CHAR(1) DEFAULT 'S' NOT NULL,

    CONSTRAINT a_pk_vendedor PRIMARY KEY (id_vendedor),
    CONSTRAINT a_uk_documento_vendedor UNIQUE (documento),

    CONSTRAINT a_fk_vendedor_sucursal
        FOREIGN KEY (id_sucursal)
        REFERENCES sucursales_automotora(id_sucursal),

    CONSTRAINT a_ck_comision_vendedor
        CHECK (porcentaje_comision BETWEEN 0 AND 100),

    CONSTRAINT a_ck_vendedor_activo
        CHECK (activo IN ('S', 'N'))
)~';
    ELSE
        SELECT COUNT(*), COUNT(CASE WHEN column_name IN ('ID_VENDEDOR','ID_SUCURSAL','DOCUMENTO','NOMBRE','PORCENTAJE_COMISION','ACTIVO') THEN 1 END)
        INTO v_total, v_columnas FROM user_tab_columns
        WHERE table_name = 'VENDEDORES_AUTOMOTORA';
        IF v_total <> 6 OR v_columnas <> 6 THEN
            RAISE_APPLICATION_ERROR(-20090, 'Estructura incompatible: vendedores_automotora');
        END IF;
    END IF;
END;
/

-- // TABLA: vehiculos_automotora
DECLARE
    v_existe NUMBER;
    v_columnas NUMBER;
    v_total NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_existe FROM user_tables
    WHERE table_name = 'VEHICULOS_AUTOMOTORA';
    IF v_existe = 0 THEN
        EXECUTE IMMEDIATE q'~CREATE TABLE vehiculos_automotora (
    id_vehiculo NUMBER GENERATED ALWAYS AS IDENTITY,
    id_sucursal NUMBER NOT NULL,
    vin VARCHAR2(17) NOT NULL,
    patente VARCHAR2(10),
    marca VARCHAR2(50) NOT NULL,
    modelo VARCHAR2(70) NOT NULL,
    anio NUMBER(4) NOT NULL,
    condicion VARCHAR2(10) NOT NULL,
    kilometraje NUMBER(10) DEFAULT 0 NOT NULL,
    precio NUMBER(12) NOT NULL,
    estado VARCHAR2(12) DEFAULT 'DISPONIBLE' NOT NULL,

    CONSTRAINT a_pk_vehiculo PRIMARY KEY (id_vehiculo),
    CONSTRAINT a_uk_vin UNIQUE (vin),
    CONSTRAINT a_uk_patente UNIQUE (patente),

    CONSTRAINT a_fk_vehiculo_sucursal
        FOREIGN KEY (id_sucursal)
        REFERENCES sucursales_automotora(id_sucursal),

    CONSTRAINT a_ck_vin CHECK (LENGTH(vin) = 17),
    CONSTRAINT a_ck_anio CHECK (anio BETWEEN 1900 AND 2100),
    CONSTRAINT a_ck_kilometraje CHECK (kilometraje >= 0),
    CONSTRAINT a_ck_precio CHECK (precio > 0),

    CONSTRAINT a_ck_condicion
        CHECK (condicion IN ('NUEVO', 'USADO')),

    CONSTRAINT a_ck_estado_vehiculo
        CHECK (estado IN ('DISPONIBLE', 'RESERVADO', 'VENDIDO'))
)~';
    ELSE
        SELECT COUNT(*), COUNT(CASE WHEN column_name IN ('ID_VEHICULO','ID_SUCURSAL','VIN','PATENTE','MARCA','MODELO','ANIO','CONDICION','KILOMETRAJE','PRECIO','ESTADO') THEN 1 END)
        INTO v_total, v_columnas FROM user_tab_columns
        WHERE table_name = 'VEHICULOS_AUTOMOTORA';
        IF v_total <> 11 OR v_columnas <> 11 THEN
            RAISE_APPLICATION_ERROR(-20090, 'Estructura incompatible: vehiculos_automotora');
        END IF;
    END IF;
END;
/

-- // TABLA: reservas_automotora
DECLARE
    v_existe NUMBER;
    v_columnas NUMBER;
    v_total NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_existe FROM user_tables
    WHERE table_name = 'RESERVAS_AUTOMOTORA';
    IF v_existe = 0 THEN
        EXECUTE IMMEDIATE q'~CREATE TABLE reservas_automotora (
    id_reserva NUMBER GENERATED ALWAYS AS IDENTITY,
    id_cliente NUMBER NOT NULL,
    id_vehiculo NUMBER NOT NULL,
    fecha_reserva DATE DEFAULT SYSDATE NOT NULL,
    fecha_vencimiento DATE NOT NULL,
    estado VARCHAR2(12) DEFAULT 'ACTIVA' NOT NULL,

    CONSTRAINT a_pk_reserva PRIMARY KEY (id_reserva),

    CONSTRAINT a_fk_reserva_cliente
        FOREIGN KEY (id_cliente)
        REFERENCES clientes_automotora(id_cliente),

    CONSTRAINT a_fk_reserva_vehiculo
        FOREIGN KEY (id_vehiculo)
        REFERENCES vehiculos_automotora(id_vehiculo),

    CONSTRAINT a_ck_fechas_reserva
        CHECK (fecha_vencimiento > fecha_reserva),

    CONSTRAINT a_ck_estado_reserva
        CHECK (
            estado IN ('ACTIVA', 'VENCIDA', 'CONCRETADA', 'CANCELADA')
        )
)~';
    ELSE
        SELECT COUNT(*), COUNT(CASE WHEN column_name IN ('ID_RESERVA','ID_CLIENTE','ID_VEHICULO','FECHA_RESERVA','FECHA_VENCIMIENTO','ESTADO') THEN 1 END)
        INTO v_total, v_columnas FROM user_tab_columns
        WHERE table_name = 'RESERVAS_AUTOMOTORA';
        IF v_total <> 6 OR v_columnas <> 6 THEN
            RAISE_APPLICATION_ERROR(-20090, 'Estructura incompatible: reservas_automotora');
        END IF;
    END IF;
END;
/

-- // TABLA: ventas_vehiculos
DECLARE
    v_existe NUMBER;
    v_columnas NUMBER;
    v_total NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_existe FROM user_tables
    WHERE table_name = 'VENTAS_VEHICULOS';
    IF v_existe = 0 THEN
        EXECUTE IMMEDIATE q'~CREATE TABLE ventas_vehiculos (
    id_venta NUMBER GENERATED ALWAYS AS IDENTITY,
    id_cliente NUMBER NOT NULL,
    id_vehiculo NUMBER NOT NULL,
    id_vendedor NUMBER NOT NULL,
    id_sucursal NUMBER NOT NULL,
    fecha DATE DEFAULT SYSDATE NOT NULL,
    modalidad VARCHAR2(8) NOT NULL,
    precio_lista NUMBER(12) NOT NULL,
    descuento NUMBER(12) DEFAULT 0 NOT NULL,
    total NUMBER(12) NOT NULL,
    pie NUMBER(12) NOT NULL,
    numero_cuotas NUMBER(3) DEFAULT 0 NOT NULL,
    porcentaje_comision NUMBER(5,2) NOT NULL,
    estado VARCHAR2(8) DEFAULT 'VIGENTE' NOT NULL,

    CONSTRAINT a_pk_venta PRIMARY KEY (id_venta),

    CONSTRAINT a_fk_venta_cliente
        FOREIGN KEY (id_cliente)
        REFERENCES clientes_automotora(id_cliente),

    CONSTRAINT a_fk_venta_vehiculo
        FOREIGN KEY (id_vehiculo)
        REFERENCES vehiculos_automotora(id_vehiculo),

    CONSTRAINT a_fk_venta_vendedor
        FOREIGN KEY (id_vendedor)
        REFERENCES vendedores_automotora(id_vendedor),

    CONSTRAINT a_fk_venta_sucursal
        FOREIGN KEY (id_sucursal)
        REFERENCES sucursales_automotora(id_sucursal),

    CONSTRAINT a_ck_modalidad
        CHECK (modalidad IN ('CONTADO', 'CREDITO')),

    CONSTRAINT a_ck_montos_venta
        CHECK (
            precio_lista > 0
            AND descuento >= 0
            AND descuento < precio_lista
            AND total = precio_lista - descuento
            AND pie BETWEEN 0 AND total
        ),

    CONSTRAINT a_ck_financiamiento
        CHECK (
            (
                modalidad = 'CONTADO'
                AND pie = total
                AND numero_cuotas = 0
            )
            OR
            (
                modalidad = 'CREDITO'
                AND pie < total
                AND numero_cuotas BETWEEN 1 AND 60
                AND total - pie >= numero_cuotas
            )
        ),

    CONSTRAINT a_ck_comision_venta
        CHECK (porcentaje_comision BETWEEN 0 AND 100),

    CONSTRAINT a_ck_estado_venta
        CHECK (estado IN ('VIGENTE', 'ANULADA'))
)~';
    ELSE
        SELECT COUNT(*), COUNT(CASE WHEN column_name IN ('ID_VENTA','ID_CLIENTE','ID_VEHICULO','ID_VENDEDOR','ID_SUCURSAL','FECHA','MODALIDAD','PRECIO_LISTA','DESCUENTO','TOTAL','PIE','NUMERO_CUOTAS','PORCENTAJE_COMISION','ESTADO') THEN 1 END)
        INTO v_total, v_columnas FROM user_tab_columns
        WHERE table_name = 'VENTAS_VEHICULOS';
        IF v_total <> 14 OR v_columnas <> 14 THEN
            RAISE_APPLICATION_ERROR(-20090, 'Estructura incompatible: ventas_vehiculos');
        END IF;
    END IF;
END;
/

-- // TABLA: cuotas_automotora
DECLARE
    v_existe NUMBER;
    v_columnas NUMBER;
    v_total NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_existe FROM user_tables
    WHERE table_name = 'CUOTAS_AUTOMOTORA';
    IF v_existe = 0 THEN
        EXECUTE IMMEDIATE q'~CREATE TABLE cuotas_automotora (
    id_cuota NUMBER GENERATED ALWAYS AS IDENTITY,
    id_venta NUMBER NOT NULL,
    numero NUMBER(3) NOT NULL,
    vencimiento DATE NOT NULL,
    monto NUMBER(12) NOT NULL,

    CONSTRAINT a_pk_cuota PRIMARY KEY (id_cuota),

    CONSTRAINT a_fk_cuota_venta
        FOREIGN KEY (id_venta)
        REFERENCES ventas_vehiculos(id_venta),

    CONSTRAINT a_uk_numero_cuota UNIQUE (id_venta, numero),
    CONSTRAINT a_uk_cuota_venta UNIQUE (id_cuota, id_venta),
    CONSTRAINT a_ck_numero_cuota CHECK (numero > 0),
    CONSTRAINT a_ck_monto_cuota CHECK (monto > 0)
)~';
    ELSE
        SELECT COUNT(*), COUNT(CASE WHEN column_name IN ('ID_CUOTA','ID_VENTA','NUMERO','VENCIMIENTO','MONTO') THEN 1 END)
        INTO v_total, v_columnas FROM user_tab_columns
        WHERE table_name = 'CUOTAS_AUTOMOTORA';
        IF v_total <> 5 OR v_columnas <> 5 THEN
            RAISE_APPLICATION_ERROR(-20090, 'Estructura incompatible: cuotas_automotora');
        END IF;
    END IF;
END;
/

-- // TABLA: pagos_automotora
DECLARE
    v_existe NUMBER;
    v_columnas NUMBER;
    v_total NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_existe FROM user_tables
    WHERE table_name = 'PAGOS_AUTOMOTORA';
    IF v_existe = 0 THEN
        EXECUTE IMMEDIATE q'~CREATE TABLE pagos_automotora (
    id_pago NUMBER GENERATED ALWAYS AS IDENTITY,
    id_venta NUMBER NOT NULL,
    id_cuota NUMBER,
    fecha DATE DEFAULT SYSDATE NOT NULL,
    monto NUMBER(12) NOT NULL,
    concepto VARCHAR2(8) NOT NULL,
    medio VARCHAR2(15) NOT NULL,

    CONSTRAINT a_pk_pago PRIMARY KEY (id_pago),

    CONSTRAINT a_fk_pago_venta
        FOREIGN KEY (id_venta)
        REFERENCES ventas_vehiculos(id_venta),

    CONSTRAINT a_fk_pago_cuota
        FOREIGN KEY (id_cuota, id_venta)
        REFERENCES cuotas_automotora(id_cuota, id_venta),

    CONSTRAINT a_ck_monto_pago CHECK (monto > 0),

    CONSTRAINT a_ck_concepto_pago
        CHECK (
            (
                concepto IN ('CONTADO', 'PIE')
                AND id_cuota IS NULL
            )
            OR
            (
                concepto = 'CUOTA'
                AND id_cuota IS NOT NULL
            )
        ),

    CONSTRAINT a_ck_medio_pago
        CHECK (medio IN ('EFECTIVO', 'TRANSFERENCIA', 'TARJETA'))
)~';
    ELSE
        SELECT COUNT(*), COUNT(CASE WHEN column_name IN ('ID_PAGO','ID_VENTA','ID_CUOTA','FECHA','MONTO','CONCEPTO','MEDIO') THEN 1 END)
        INTO v_total, v_columnas FROM user_tab_columns
        WHERE table_name = 'PAGOS_AUTOMOTORA';
        IF v_total <> 7 OR v_columnas <> 7 THEN
            RAISE_APPLICATION_ERROR(-20090, 'Estructura incompatible: pagos_automotora');
        END IF;
    END IF;
END;
/

-- // TABLA: auditoria_automotora
DECLARE
    v_existe NUMBER;
    v_columnas NUMBER;
    v_total NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_existe FROM user_tables
    WHERE table_name = 'AUDITORIA_AUTOMOTORA';
    IF v_existe = 0 THEN
        EXECUTE IMMEDIATE q'~CREATE TABLE auditoria_automotora (
    id_auditoria NUMBER GENERATED ALWAYS AS IDENTITY,
    fecha TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL,
    usuario VARCHAR2(128) DEFAULT USER NOT NULL,
    tabla VARCHAR2(30) NOT NULL,
    operacion VARCHAR2(10) NOT NULL,
    nivel VARCHAR2(10) NOT NULL,
    id_registro NUMBER,
    detalle VARCHAR2(1000),

    CONSTRAINT a_pk_auditoria PRIMARY KEY (id_auditoria),

    CONSTRAINT a_ck_operacion_auditoria
        CHECK (operacion IN ('INSERT', 'UPDATE', 'DELETE')),

    CONSTRAINT a_ck_nivel_auditoria
        CHECK (nivel IN ('FILA', 'SENTENCIA'))
)~';
    ELSE
        SELECT COUNT(*), COUNT(CASE WHEN column_name IN ('ID_AUDITORIA','FECHA','USUARIO','TABLA','OPERACION','NIVEL','ID_REGISTRO','DETALLE') THEN 1 END)
        INTO v_total, v_columnas FROM user_tab_columns
        WHERE table_name = 'AUDITORIA_AUTOMOTORA';
        IF v_total <> 8 OR v_columnas <> 8 THEN
            RAISE_APPLICATION_ERROR(-20090, 'Estructura incompatible: auditoria_automotora');
        END IF;
    END IF;
END;
/

DECLARE
    v_existe NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_existe FROM user_indexes
    WHERE index_name = 'A_UK_RESERVA_ACTIVA';
    IF v_existe = 0 THEN
        EXECUTE IMMEDIATE q'~CREATE UNIQUE INDEX a_uk_reserva_activa
ON reservas_automotora (
    CASE WHEN estado = 'ACTIVA' THEN id_vehiculo END
)~';
    END IF;
END;
/

DECLARE
    v_existe NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_existe FROM user_indexes
    WHERE index_name = 'A_UK_VENTA_VIGENTE';
    IF v_existe = 0 THEN
        EXECUTE IMMEDIATE q'~CREATE UNIQUE INDEX a_uk_venta_vigente
ON ventas_vehiculos (
    CASE WHEN estado = 'VIGENTE' THEN id_vehiculo END
)~';
    END IF;
END;
/

DECLARE
    v_existe NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_existe FROM user_indexes
    WHERE index_name = 'A_UK_PAGO_INICIAL';
    IF v_existe = 0 THEN
        EXECUTE IMMEDIATE q'~CREATE UNIQUE INDEX a_uk_pago_inicial
ON pagos_automotora (
    CASE WHEN concepto IN ('CONTADO', 'PIE') THEN id_venta END
)~';
    END IF;
END;
/

-- // DATOS DE PRUEBA
INSERT INTO sucursales_automotora (nombre, direccion, comuna)
SELECT 'Automotora Centro', 'Avenida Central 1500', 'Santiago'
FROM dual
WHERE NOT EXISTS (SELECT 1 FROM sucursales_automotora WHERE nombre = 'Automotora Centro');

INSERT INTO sucursales_automotora (nombre, direccion, comuna)
SELECT 'Automotora Norte', 'Avenida Norte 2500', 'Quilicura'
FROM dual
WHERE NOT EXISTS (SELECT 1 FROM sucursales_automotora WHERE nombre = 'Automotora Norte');

INSERT INTO clientes_automotora (documento, nombre, telefono, email)
SELECT 'CLIENTE-001', 'Carlos Perez',
    '900000001', 'carlos@example.com'
FROM dual
WHERE NOT EXISTS (SELECT 1 FROM clientes_automotora WHERE documento = 'CLIENTE-001');

INSERT INTO clientes_automotora (documento, nombre, telefono, email)
SELECT 'CLIENTE-002', 'Maria Soto',
    '900000002', 'maria@example.com'
FROM dual
WHERE NOT EXISTS (SELECT 1 FROM clientes_automotora WHERE documento = 'CLIENTE-002');

INSERT INTO clientes_automotora (documento, nombre, telefono, email)
SELECT 'CLIENTE-003', 'Pedro Gonzalez',
    '900000003', 'pedro@example.com'
FROM dual
WHERE NOT EXISTS (SELECT 1 FROM clientes_automotora WHERE documento = 'CLIENTE-003');

INSERT INTO vendedores_automotora (id_sucursal, documento, nombre, porcentaje_comision)
SELECT
    id_sucursal, 'VENDEDOR-001', 'Ana Torres', 2
FROM sucursales_automotora
WHERE nombre = 'Automotora Centro'
AND NOT EXISTS (SELECT 1 FROM vendedores_automotora WHERE documento = 'VENDEDOR-001');

INSERT INTO vendedores_automotora (id_sucursal, documento, nombre, porcentaje_comision)
SELECT
    id_sucursal, 'VENDEDOR-002', 'Luis Rojas', 1.5
FROM sucursales_automotora
WHERE nombre = 'Automotora Norte'
AND NOT EXISTS (SELECT 1 FROM vendedores_automotora WHERE documento = 'VENDEDOR-002');

INSERT INTO vehiculos_automotora (id_sucursal, vin, patente, marca, modelo, anio, condicion, kilometraje, precio)
SELECT
    id_sucursal, 'TESTVIN0000000001', 'BBCC11',
    'Toyota', 'Corolla', 2022, 'USADO', 45000, 15000000
FROM sucursales_automotora
WHERE nombre = 'Automotora Centro'
AND NOT EXISTS (SELECT 1 FROM vehiculos_automotora WHERE vin = 'TESTVIN0000000001');

INSERT INTO vehiculos_automotora (id_sucursal, vin, patente, marca, modelo, anio, condicion, kilometraje, precio)
SELECT
    id_sucursal, 'TESTVIN0000000002', 'DDFF22',
    'Kia', 'Rio', 2021, 'USADO', 60000, 10000000
FROM sucursales_automotora
WHERE nombre = 'Automotora Centro'
AND NOT EXISTS (SELECT 1 FROM vehiculos_automotora WHERE vin = 'TESTVIN0000000002');

INSERT INTO vehiculos_automotora (id_sucursal, vin, patente, marca, modelo, anio, condicion, kilometraje, precio)
SELECT
    id_sucursal, 'TESTVIN0000000003', 'GGHH33',
    'Hyundai', 'Accent', 2023, 'USADO', 25000, 13000000
FROM sucursales_automotora
WHERE nombre = 'Automotora Norte'
AND NOT EXISTS (SELECT 1 FROM vehiculos_automotora WHERE vin = 'TESTVIN0000000003');

INSERT INTO vehiculos_automotora (id_sucursal, vin, patente, marca, modelo, anio, condicion, kilometraje, precio)
SELECT
    id_sucursal, 'TESTVIN0000000004', NULL,
    'Suzuki', 'Swift', 2026, 'NUEVO', 0, 14000000
FROM sucursales_automotora
WHERE nombre = 'Automotora Norte'
AND NOT EXISTS (SELECT 1 FROM vehiculos_automotora WHERE vin = 'TESTVIN0000000004');

COMMIT;
PROMPT PASO 3: FUNCIONES

-- // FUNCION: fn_saldo_automotora
CREATE OR REPLACE FUNCTION fn_saldo_automotora (
    p_id_venta IN ventas_vehiculos.id_venta%TYPE
)
RETURN NUMBER
IS
    v_total  ventas_vehiculos.total%TYPE;
    v_estado ventas_vehiculos.estado%TYPE;
    v_pagado NUMBER;
BEGIN
    SELECT v.total, v.estado,
           NVL((SELECT SUM(p.monto) FROM pagos_automotora p
                WHERE p.id_venta = v.id_venta), 0)
    INTO v_total, v_estado, v_pagado
    FROM ventas_vehiculos v
    WHERE v.id_venta = p_id_venta;

    IF v_estado <> 'VIGENTE' THEN
        RAISE_APPLICATION_ERROR(
            -20010,
            'La venta no esta vigente.'
        );
    END IF;

    RETURN v_total - v_pagado;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(
            -20011,
            'La venta indicada no existe.'
        );
END fn_saldo_automotora;
/

-- // FUNCION: fn_total_automotora
CREATE OR REPLACE FUNCTION fn_total_automotora
RETURN NUMBER
IS
    v_total NUMBER;
BEGIN
    SELECT NVL(SUM(total), 0)
    INTO v_total
    FROM ventas_vehiculos
    WHERE estado = 'VIGENTE';

    RETURN v_total;
END fn_total_automotora;
/

-- // FUNCION: fn_comision_automotora
CREATE OR REPLACE FUNCTION fn_comision_automotora (
    p_id_venta IN ventas_vehiculos.id_venta%TYPE
)
RETURN NUMBER
IS
    v_porcentaje ventas_vehiculos.porcentaje_comision%TYPE;
    v_estado     ventas_vehiculos.estado%TYPE;
    v_cobrado    NUMBER;
BEGIN
    SELECT v.porcentaje_comision, v.estado,
           NVL((SELECT SUM(p.monto) FROM pagos_automotora p
                WHERE p.id_venta = v.id_venta), 0)
    INTO v_porcentaje, v_estado, v_cobrado
    FROM ventas_vehiculos v
    WHERE v.id_venta = p_id_venta;

    IF v_estado <> 'VIGENTE' THEN
        RAISE_APPLICATION_ERROR(
            -20010,
            'La venta no esta vigente.'
        );
    END IF;

    RETURN ROUND(v_cobrado * v_porcentaje / 100, 0);

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(
            -20011,
            'La venta indicada no existe.'
        );
END fn_comision_automotora;
/

PROMPT PASO 4: PROCEDIMIENTOS Y CURSORES
-- // PROCEDIMIENTO: sp_deuda_cliente
CREATE OR REPLACE PROCEDURE sp_deuda_cliente (
    p_id_cliente IN clientes_automotora.id_cliente%TYPE
)
IS
    v_nombre clientes_automotora.nombre%TYPE;
    v_saldo NUMBER;
    v_deuda_total NUMBER := 0;
    v_cantidad NUMBER := 0;

    -- // CURSOR: c_ventas
    CURSOR c_ventas (
        p_cliente clientes_automotora.id_cliente%TYPE
    ) IS
        SELECT id_venta, fecha, total
        FROM ventas_vehiculos
        WHERE id_cliente = p_cliente
          AND estado = 'VIGENTE'
        ORDER BY id_venta;
BEGIN
    SELECT nombre
    INTO v_nombre
    FROM clientes_automotora
    WHERE id_cliente = p_id_cliente;

    DBMS_OUTPUT.PUT_LINE('CLIENTE: ' || v_nombre);

    FOR venta IN c_ventas(p_id_cliente) LOOP
        v_saldo := fn_saldo_automotora(venta.id_venta);
        v_deuda_total := v_deuda_total + v_saldo;
        v_cantidad := v_cantidad + 1;

        DBMS_OUTPUT.PUT_LINE(
            'Venta: ' || venta.id_venta ||
            ' | Total: $' || venta.total ||
            ' | Saldo: $' || v_saldo
        );
    END LOOP;

    IF v_cantidad = 0 THEN
        DBMS_OUTPUT.PUT_LINE('El cliente no tiene ventas vigentes.');
    END IF;

    DBMS_OUTPUT.PUT_LINE(
        'DEUDA TOTAL: $' || v_deuda_total
    );

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(
            -20012,
            'El cliente indicado no existe.'
        );
END sp_deuda_cliente;
/

-- // PROCEDIMIENTO: sp_resumen_sucursales
CREATE OR REPLACE PROCEDURE sp_resumen_sucursales
IS
    -- // CURSOR: c_sucursales
    CURSOR c_sucursales IS
        SELECT id_sucursal, nombre
        FROM sucursales_automotora
        ORDER BY id_sucursal;

    v_cantidad NUMBER;
    v_vendido NUMBER;
    v_cobrado NUMBER;
BEGIN
    DBMS_OUTPUT.PUT_LINE('RESUMEN POR SUCURSAL');

    FOR sucursal IN c_sucursales LOOP
        SELECT COUNT(*), NVL(SUM(total), 0)
        INTO v_cantidad, v_vendido
        FROM ventas_vehiculos
        WHERE id_sucursal = sucursal.id_sucursal
          AND estado = 'VIGENTE';

        SELECT NVL(SUM(p.monto), 0)
        INTO v_cobrado
        FROM pagos_automotora p
        JOIN ventas_vehiculos v
            ON v.id_venta = p.id_venta
        WHERE v.id_sucursal = sucursal.id_sucursal
          AND v.estado = 'VIGENTE';

        DBMS_OUTPUT.PUT_LINE(
            'Sucursal: ' || sucursal.nombre
        );

        DBMS_OUTPUT.PUT_LINE(
            'Ventas: ' || v_cantidad ||
            ' | Vendido: $' || v_vendido ||
            ' | Cobrado: $' || v_cobrado ||
            ' | Pendiente: $' || (v_vendido - v_cobrado)
        );
    END LOOP;
END sp_resumen_sucursales;
/

PROMPT PASO 5: ESPECIFICACION DEL PACKAGE
-- // PACKAGE: pkg_automotora
CREATE OR REPLACE PACKAGE pkg_automotora AS

    -- // PROCEDIMIENTO: reservar_vehiculo
    PROCEDURE reservar_vehiculo (
        p_id_cliente  IN clientes_automotora.id_cliente%TYPE,
        p_id_vehiculo IN vehiculos_automotora.id_vehiculo%TYPE,
        p_dias        IN NUMBER,
        p_id_reserva  OUT reservas_automotora.id_reserva%TYPE
    );

    -- // PROCEDIMIENTO: liberar_reservas_vencidas
    PROCEDURE liberar_reservas_vencidas;

    -- // PROCEDIMIENTO: registrar_venta
    PROCEDURE registrar_venta (
        p_id_cliente  IN clientes_automotora.id_cliente%TYPE,
        p_id_vehiculo IN vehiculos_automotora.id_vehiculo%TYPE,
        p_id_vendedor IN vendedores_automotora.id_vendedor%TYPE,
        p_modalidad   IN ventas_vehiculos.modalidad%TYPE,
        p_descuento   IN NUMBER,
        p_pie         IN NUMBER,
        p_num_cuotas  IN NUMBER,
        p_medio_pago  IN pagos_automotora.medio%TYPE,
        p_id_venta    OUT ventas_vehiculos.id_venta%TYPE
    );

    -- // PROCEDIMIENTO: registrar_pago
    PROCEDURE registrar_pago (
        p_id_cuota IN cuotas_automotora.id_cuota%TYPE,
        p_monto    IN NUMBER,
        p_medio    IN pagos_automotora.medio%TYPE
    );

    -- // FUNCION: consultar_saldo
    FUNCTION consultar_saldo (
        p_id_venta IN ventas_vehiculos.id_venta%TYPE
    )
    RETURN NUMBER;

    -- // FUNCION: total_vendido
    FUNCTION total_vendido
    RETURN NUMBER;

END pkg_automotora;
/

PROMPT PASO 6: CUERPO DEL PACKAGE
-- // PACKAGE BODY: pkg_automotora
CREATE OR REPLACE PACKAGE BODY pkg_automotora AS

    -- // PROCEDIMIENTO: validar_cliente
    PROCEDURE validar_cliente (
        p_id_cliente IN clientes_automotora.id_cliente%TYPE
    )
    IS
        v_cantidad NUMBER;
    BEGIN
        SELECT COUNT(*)
        INTO v_cantidad
        FROM clientes_automotora
        WHERE id_cliente = p_id_cliente;

        IF v_cantidad = 0 THEN
            RAISE_APPLICATION_ERROR(
                -20020, 'El cliente no existe.'
            );
        END IF;
    END validar_cliente;

    -- // PROCEDIMIENTO: validar_medio
    PROCEDURE validar_medio (
        p_medio IN VARCHAR2
    )
    IS
    BEGIN
        IF p_medio IS NULL
           OR p_medio NOT IN (
               'EFECTIVO', 'TRANSFERENCIA', 'TARJETA'
           )
        THEN
            RAISE_APPLICATION_ERROR(
                -20021, 'Medio de pago no permitido.'
            );
        END IF;
    END validar_medio;

    -- // PROCEDIMIENTO: depurar_reserva
    PROCEDURE depurar_reserva (
        p_id_vehiculo IN vehiculos_automotora.id_vehiculo%TYPE
    )
    IS
        v_actualizadas NUMBER;
    BEGIN
        UPDATE reservas_automotora
        SET estado = 'VENCIDA'
        WHERE id_vehiculo = p_id_vehiculo
          AND estado = 'ACTIVA'
          AND fecha_vencimiento <= SYSDATE;

        v_actualizadas := SQL%ROWCOUNT;

        IF v_actualizadas > 0 THEN
            UPDATE vehiculos_automotora
            SET estado = 'DISPONIBLE'
            WHERE id_vehiculo = p_id_vehiculo
              AND estado = 'RESERVADO'
              AND NOT EXISTS (
                  SELECT 1
                  FROM reservas_automotora
                  WHERE id_vehiculo = p_id_vehiculo
                    AND estado = 'ACTIVA'
              );
        END IF;
    END depurar_reserva;

    -- // PROCEDIMIENTO: generar_cuotas
    PROCEDURE generar_cuotas (
        p_id_venta IN ventas_vehiculos.id_venta%TYPE,
        p_saldo    IN NUMBER,
        p_cantidad IN NUMBER,
        p_fecha    IN DATE
    )
    IS
        v_base  NUMBER;
        v_monto NUMBER;
    BEGIN
        v_base := TRUNC(p_saldo / p_cantidad);

        FOR i IN 1 .. p_cantidad LOOP
            IF i = p_cantidad THEN
                v_monto := p_saldo -
                           v_base * (p_cantidad - 1);
            ELSE
                v_monto := v_base;
            END IF;

            INSERT INTO cuotas_automotora (
                id_venta, numero, vencimiento, monto
            )
            VALUES (
                p_id_venta,
                i,
                ADD_MONTHS(TRUNC(p_fecha), i),
                v_monto
            );
        END LOOP;
    END generar_cuotas;

    -- // PROCEDIMIENTO: reservar_vehiculo
    PROCEDURE reservar_vehiculo (
        p_id_cliente  IN clientes_automotora.id_cliente%TYPE,
        p_id_vehiculo IN vehiculos_automotora.id_vehiculo%TYPE,
        p_dias        IN NUMBER,
        p_id_reserva  OUT reservas_automotora.id_reserva%TYPE
    )
    IS
        v_estado vehiculos_automotora.estado%TYPE;
        v_fecha DATE := SYSDATE;
    BEGIN
        SAVEPOINT inicio_reserva;
        p_id_reserva := NULL;

        validar_cliente(p_id_cliente);

        IF p_dias IS NULL
           OR p_dias <> TRUNC(p_dias)
           OR p_dias NOT BETWEEN 1 AND 30
        THEN
            RAISE_APPLICATION_ERROR(
                -20022, 'La reserva debe durar entre 1 y 30 dias enteros.'
            );
        END IF;

        BEGIN
            SELECT estado
            INTO v_estado
            FROM vehiculos_automotora
            WHERE id_vehiculo = p_id_vehiculo
            FOR UPDATE;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                RAISE_APPLICATION_ERROR(
                    -20023, 'El vehiculo no existe.'
                );
        END;

        v_fecha := SYSDATE;
        depurar_reserva(p_id_vehiculo);

        SELECT estado
        INTO v_estado
        FROM vehiculos_automotora
        WHERE id_vehiculo = p_id_vehiculo;

        IF v_estado <> 'DISPONIBLE' THEN
            RAISE_APPLICATION_ERROR(
                -20024, 'El vehiculo no esta disponible para reservar.'
            );
        END IF;

        INSERT INTO reservas_automotora (
            id_cliente, id_vehiculo,
            fecha_reserva, fecha_vencimiento, estado
        )
        VALUES (
            p_id_cliente, p_id_vehiculo,
            v_fecha, v_fecha + p_dias, 'ACTIVA'
        )
        RETURNING id_reserva INTO p_id_reserva;

        UPDATE vehiculos_automotora
        SET estado = 'RESERVADO'
        WHERE id_vehiculo = p_id_vehiculo;

    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK TO inicio_reserva;
            p_id_reserva := NULL;
            RAISE;
    END reservar_vehiculo;

    -- // PROCEDIMIENTO: liberar_reservas_vencidas
    PROCEDURE liberar_reservas_vencidas
    IS
        -- // CURSOR: c_vencidas
        CURSOR c_vencidas IS
            SELECT DISTINCT id_vehiculo
            FROM reservas_automotora
            WHERE estado = 'ACTIVA'
              AND fecha_vencimiento <= SYSDATE
            ORDER BY id_vehiculo;

        v_estado vehiculos_automotora.estado%TYPE;
        v_procesados NUMBER := 0;
    BEGIN
        SAVEPOINT inicio_liberacion;

        FOR reserva IN c_vencidas LOOP
            SELECT estado
            INTO v_estado
            FROM vehiculos_automotora
            WHERE id_vehiculo = reserva.id_vehiculo
            FOR UPDATE;

            depurar_reserva(reserva.id_vehiculo);
            v_procesados := v_procesados + 1;
        END LOOP;

        DBMS_OUTPUT.PUT_LINE(
            'Vehiculos revisados por reservas vencidas: ' ||
            v_procesados
        );

    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK TO inicio_liberacion;
            RAISE;
    END liberar_reservas_vencidas;

    -- // PROCEDIMIENTO: registrar_venta
    PROCEDURE registrar_venta (
        p_id_cliente  IN clientes_automotora.id_cliente%TYPE,
        p_id_vehiculo IN vehiculos_automotora.id_vehiculo%TYPE,
        p_id_vendedor IN vendedores_automotora.id_vendedor%TYPE,
        p_modalidad   IN ventas_vehiculos.modalidad%TYPE,
        p_descuento   IN NUMBER,
        p_pie         IN NUMBER,
        p_num_cuotas  IN NUMBER,
        p_medio_pago  IN pagos_automotora.medio%TYPE,
        p_id_venta    OUT ventas_vehiculos.id_venta%TYPE
    )
    IS
        -- // RECORD: vehiculo y vendedor
        v_vehiculo vehiculos_automotora%ROWTYPE;
        v_vendedor vendedores_automotora%ROWTYPE;
        v_reserva reservas_automotora.id_reserva%TYPE;
        v_cliente_reserva reservas_automotora.id_cliente%TYPE;
        v_total NUMBER;
        v_fecha DATE := SYSDATE;
        v_concepto pagos_automotora.concepto%TYPE;
    BEGIN
        SAVEPOINT inicio_venta;
        p_id_venta := NULL;

        validar_cliente(p_id_cliente);
        validar_medio(p_medio_pago);

        IF p_modalidad IS NULL
           OR p_modalidad NOT IN ('CONTADO', 'CREDITO')
        THEN
            RAISE_APPLICATION_ERROR(
                -20025, 'Modalidad de venta no permitida.'
            );
        END IF;

        BEGIN
            SELECT *
            INTO v_vehiculo
            FROM vehiculos_automotora
            WHERE id_vehiculo = p_id_vehiculo
            FOR UPDATE;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                RAISE_APPLICATION_ERROR(
                    -20023, 'El vehiculo no existe.'
                );
        END;

        v_fecha := SYSDATE;
        depurar_reserva(p_id_vehiculo);

        SELECT *
        INTO v_vehiculo
        FROM vehiculos_automotora
        WHERE id_vehiculo = p_id_vehiculo;

        IF v_vehiculo.estado = 'VENDIDO' THEN
            RAISE_APPLICATION_ERROR(
                -20026, 'El vehiculo ya esta vendido.'
            );
        END IF;

        BEGIN
            SELECT *
            INTO v_vendedor
            FROM vendedores_automotora
            WHERE id_vendedor = p_id_vendedor;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                RAISE_APPLICATION_ERROR(
                    -20027, 'El vendedor no existe.'
                );
        END;

        IF v_vendedor.activo <> 'S'
           OR v_vendedor.id_sucursal <> v_vehiculo.id_sucursal
        THEN
            RAISE_APPLICATION_ERROR(
                -20028,
                'El vendedor debe estar activo y pertenecer a la sucursal del vehiculo.'
            );
        END IF;

        BEGIN
            SELECT id_reserva, id_cliente
            INTO v_reserva, v_cliente_reserva
            FROM reservas_automotora
            WHERE id_vehiculo = p_id_vehiculo
              AND estado = 'ACTIVA';

            IF v_cliente_reserva <> p_id_cliente THEN
                RAISE_APPLICATION_ERROR(
                    -20029, 'El vehiculo esta reservado para otro cliente.'
                );
            END IF;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                v_reserva := NULL;

                IF v_vehiculo.estado <> 'DISPONIBLE' THEN
                    RAISE_APPLICATION_ERROR(
                        -20030, 'El estado del vehiculo requiere revision.'
                    );
                END IF;
        END;

        IF p_descuento IS NULL
           OR p_descuento <> TRUNC(p_descuento)
           OR p_descuento < 0
           OR p_descuento >= v_vehiculo.precio
        THEN
            RAISE_APPLICATION_ERROR(
                -20031, 'El descuento debe ser un monto entero valido.'
            );
        END IF;

        v_total := v_vehiculo.precio - p_descuento;

        IF p_pie IS NULL
           OR p_pie <> TRUNC(p_pie)
           OR p_pie < 0
           OR p_pie > v_total
        THEN
            RAISE_APPLICATION_ERROR(
                -20032, 'El pie debe ser un monto entero entre cero y el total.'
            );
        END IF;

        IF p_num_cuotas IS NULL
           OR p_num_cuotas <> TRUNC(p_num_cuotas)
        THEN
            RAISE_APPLICATION_ERROR(
                -20033, 'La cantidad de cuotas debe ser un numero entero.'
            );
        END IF;

        IF p_modalidad = 'CONTADO' THEN
            IF p_pie <> v_total OR p_num_cuotas <> 0 THEN
                RAISE_APPLICATION_ERROR(
                    -20034, 'Al contado debe pagar el total y registrar cero cuotas.'
                );
            END IF;

            v_concepto := 'CONTADO';
        ELSE
            IF p_pie >= v_total
               OR p_num_cuotas NOT BETWEEN 1 AND 60
               OR v_total - p_pie < p_num_cuotas
            THEN
                RAISE_APPLICATION_ERROR(
                    -20035, 'Revise el saldo financiado y la cantidad de cuotas.'
                );
            END IF;

            v_concepto := 'PIE';
        END IF;

        INSERT INTO ventas_vehiculos (
            id_cliente, id_vehiculo, id_vendedor,
            id_sucursal, fecha, modalidad,
            precio_lista, descuento, total,
            pie, numero_cuotas, porcentaje_comision, estado
        )
        VALUES (
            p_id_cliente, p_id_vehiculo, p_id_vendedor,
            v_vehiculo.id_sucursal, v_fecha, p_modalidad,
            v_vehiculo.precio, p_descuento, v_total,
            p_pie, p_num_cuotas,
            v_vendedor.porcentaje_comision, 'VIGENTE'
        )
        RETURNING id_venta INTO p_id_venta;

        IF p_pie > 0 THEN
            INSERT INTO pagos_automotora (
                id_venta, monto, concepto, medio
            )
            VALUES (
                p_id_venta, p_pie, v_concepto, p_medio_pago
            );
        END IF;

        IF p_modalidad = 'CREDITO' THEN
            generar_cuotas(
                p_id_venta,
                v_total - p_pie,
                p_num_cuotas,
                v_fecha
            );
        END IF;

        IF v_reserva IS NOT NULL THEN
            UPDATE reservas_automotora
            SET estado = 'CONCRETADA'
            WHERE id_reserva = v_reserva;
        END IF;

        UPDATE vehiculos_automotora
        SET estado = 'VENDIDO'
        WHERE id_vehiculo = p_id_vehiculo;

    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK TO inicio_venta;
            p_id_venta := NULL;
            RAISE;
    END registrar_venta;

    -- // PROCEDIMIENTO: registrar_pago
    PROCEDURE registrar_pago (
        p_id_cuota IN cuotas_automotora.id_cuota%TYPE,
        p_monto    IN NUMBER,
        p_medio    IN pagos_automotora.medio%TYPE
    )
    IS
        v_id_venta ventas_vehiculos.id_venta%TYPE;
        v_estado ventas_vehiculos.estado%TYPE;
        v_monto cuotas_automotora.monto%TYPE;
        v_pagado NUMBER;
    BEGIN
        SAVEPOINT inicio_pago;

        validar_medio(p_medio);

        IF p_monto IS NULL
           OR p_monto <= 0
           OR p_monto <> TRUNC(p_monto)
        THEN
            RAISE_APPLICATION_ERROR(
                -20036, 'El pago debe ser un monto entero mayor que cero.'
            );
        END IF;

        BEGIN
            SELECT id_venta
            INTO v_id_venta
            FROM cuotas_automotora
            WHERE id_cuota = p_id_cuota;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                RAISE_APPLICATION_ERROR(
                    -20037, 'La cuota no existe.'
                );
        END;

        SELECT estado
        INTO v_estado
        FROM ventas_vehiculos
        WHERE id_venta = v_id_venta
        FOR UPDATE;

        IF v_estado <> 'VIGENTE' THEN
            RAISE_APPLICATION_ERROR(
                -20038, 'No puede pagar una venta anulada.'
            );
        END IF;

        SELECT monto
        INTO v_monto
        FROM cuotas_automotora
        WHERE id_cuota = p_id_cuota
          AND id_venta = v_id_venta
        FOR UPDATE;

        SELECT NVL(SUM(monto), 0)
        INTO v_pagado
        FROM pagos_automotora
        WHERE id_cuota = p_id_cuota;

        IF p_monto > v_monto - v_pagado THEN
            RAISE_APPLICATION_ERROR(
                -20039, 'El pago supera el saldo pendiente de la cuota.'
            );
        END IF;

        INSERT INTO pagos_automotora (
            id_venta, id_cuota, monto, concepto, medio
        )
        VALUES (
            v_id_venta, p_id_cuota, p_monto, 'CUOTA', p_medio
        );

    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK TO inicio_pago;
            RAISE;
    END registrar_pago;

    -- // FUNCION: consultar_saldo
    FUNCTION consultar_saldo (
        p_id_venta IN ventas_vehiculos.id_venta%TYPE
    )
    RETURN NUMBER
    IS
    BEGIN
        RETURN fn_saldo_automotora(p_id_venta);
    END consultar_saldo;

    -- // FUNCION: total_vendido
    FUNCTION total_vendido
    RETURN NUMBER
    IS
    BEGIN
        RETURN fn_total_automotora();
    END total_vendido;

END pkg_automotora;
/

PROMPT PASO 7: TRIGGERS

-- // TRIGGER: trg_auto_estado_vehiculo
CREATE OR REPLACE TRIGGER trg_auto_estado_vehiculo
AFTER UPDATE OF estado ON vehiculos_automotora
FOR EACH ROW
BEGIN
    IF :OLD.estado <> :NEW.estado THEN
        INSERT INTO auditoria_automotora (
            tabla, operacion, nivel, id_registro, detalle
        ) VALUES (
            'VEHICULOS_AUTOMOTORA', 'UPDATE', 'FILA', :NEW.id_vehiculo,
            'Estado anterior: ' || :OLD.estado ||
            ' | Estado nuevo: ' || :NEW.estado
        );
    END IF;
END;
/

-- // TRIGGER: trg_auto_auditoria_ventas
CREATE OR REPLACE TRIGGER trg_auto_auditoria_ventas
AFTER INSERT OR UPDATE OR DELETE ON ventas_vehiculos
DECLARE
    v_operacion VARCHAR2(10);
BEGIN
    IF INSERTING THEN v_operacion := 'INSERT';
    ELSIF UPDATING THEN v_operacion := 'UPDATE';
    ELSE v_operacion := 'DELETE';
    END IF;
    INSERT INTO auditoria_automotora (
        tabla, operacion, nivel, detalle
    ) VALUES (
        'VENTAS_VEHICULOS', v_operacion, 'SENTENCIA',
        'Sentencia ejecutada: ' || v_operacion
    );
END;
/

-- // TRIGGER: trg_auto_proteger_pagos
CREATE OR REPLACE TRIGGER trg_auto_proteger_pagos
BEFORE UPDATE OR DELETE ON pagos_automotora
FOR EACH ROW
BEGIN
    RAISE_APPLICATION_ERROR(-20040,
        'No puede modificar ni eliminar un pago registrado.');
END;
/

PROMPT PASO 8: VERIFICAR COMPILACION
SELECT object_name, object_type, status
FROM user_objects
WHERE object_name IN (
    'FN_SALDO_AUTOMOTORA','FN_TOTAL_AUTOMOTORA','FN_COMISION_AUTOMOTORA',
    'SP_DEUDA_CLIENTE','SP_RESUMEN_SUCURSALES','PKG_AUTOMOTORA',
    'TRG_AUTO_ESTADO_VEHICULO','TRG_AUTO_AUDITORIA_VENTAS',
    'TRG_AUTO_PROTEGER_PAGOS'
)
AND object_type IN ('FUNCTION','PROCEDURE','PACKAGE','PACKAGE BODY','TRIGGER')
ORDER BY object_type, object_name;

SELECT name, type, line, text FROM user_errors
WHERE name IN (
    'FN_SALDO_AUTOMOTORA','FN_TOTAL_AUTOMOTORA','FN_COMISION_AUTOMOTORA',
    'SP_DEUDA_CLIENTE','SP_RESUMEN_SUCURSALES','PKG_AUTOMOTORA',
    'TRG_AUTO_ESTADO_VEHICULO','TRG_AUTO_AUDITORIA_VENTAS',
    'TRG_AUTO_PROTEGER_PAGOS'
) ORDER BY name, sequence;

DECLARE
    v_validos NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_validos FROM user_objects
    WHERE status = 'VALID' AND (
        (object_type = 'FUNCTION' AND object_name IN (
            'FN_SALDO_AUTOMOTORA','FN_TOTAL_AUTOMOTORA','FN_COMISION_AUTOMOTORA'))
        OR (object_type = 'PROCEDURE' AND object_name IN (
            'SP_DEUDA_CLIENTE','SP_RESUMEN_SUCURSALES'))
        OR (object_type IN ('PACKAGE','PACKAGE BODY')
            AND object_name = 'PKG_AUTOMOTORA')
        OR (object_type = 'TRIGGER' AND object_name IN (
            'TRG_AUTO_ESTADO_VEHICULO','TRG_AUTO_AUDITORIA_VENTAS',
            'TRG_AUTO_PROTEGER_PAGOS'))
    );
    IF v_validos <> 10 THEN
        RAISE_APPLICATION_ERROR(-20091,
            'Hay objetos ausentes o invalidos. Revise USER_ERRORS.');
    END IF;
END;
/

PROMPT PASO 9: PRUEBAS INTEGRADAS CON ROLLBACK
DECLARE
    v_sucursal NUMBER;
    v_cliente NUMBER;
    v_otro NUMBER;
    v_vendedor NUMBER;
    v_vehiculo NUMBER;
    v_reserva NUMBER;
    v_venta NUMBER;
    v_rechazada NUMBER;
    v_cuota NUMBER;
    v_pago NUMBER;
    v_n NUMBER;
    v_monto NUMBER;
    v_saldo NUMBER;
    v_antes NUMBER;
    v_estado VARCHAR2(12);
    v_ok BOOLEAN;

    -- // PROCEDIMIENTO: comprobar
    PROCEDURE comprobar(p_ok BOOLEAN, p_mensaje VARCHAR2) IS
    BEGIN
        IF p_ok IS NULL OR NOT p_ok THEN
            RAISE_APPLICATION_ERROR(-20092, p_mensaje);
        END IF;
        DBMS_OUTPUT.PUT_LINE('OK: ' || p_mensaje);
    END;
BEGIN
    SAVEPOINT inicio_pruebas;
    SELECT id_sucursal INTO v_sucursal FROM sucursales_automotora
    WHERE nombre = 'Automotora Centro';
    SELECT id_cliente INTO v_cliente FROM clientes_automotora
    WHERE documento = 'CLIENTE-001';
    SELECT id_cliente INTO v_otro FROM clientes_automotora
    WHERE documento = 'CLIENTE-002';
    SELECT id_vendedor INTO v_vendedor FROM vendedores_automotora
    WHERE documento = 'VENDEDOR-001';
    v_antes := fn_total_automotora();

    INSERT INTO vehiculos_automotora (
        id_sucursal,vin,marca,modelo,anio,condicion,kilometraje,precio
    ) VALUES (
        v_sucursal,'DEMOAUTO000000001','Toyota','Prueba credito',
        2022,'USADO',45000,15000000
    ) RETURNING id_vehiculo INTO v_vehiculo;

    pkg_automotora.reservar_vehiculo(v_cliente,v_vehiculo,3,v_reserva);
    SELECT estado INTO v_estado FROM vehiculos_automotora
    WHERE id_vehiculo = v_vehiculo;
    comprobar(v_estado = 'RESERVADO','Reserva creada');

    v_ok := FALSE;
    BEGIN
        pkg_automotora.registrar_venta(v_otro,v_vehiculo,v_vendedor,
            'CREDITO',0,3000000,12,'TRANSFERENCIA',v_rechazada);
    EXCEPTION WHEN OTHERS THEN
        IF SQLCODE = -20029 THEN v_ok := TRUE; ELSE RAISE; END IF;
    END;
    comprobar(v_ok,'Rechazo de venta a otro cliente');

    pkg_automotora.registrar_venta(v_cliente,v_vehiculo,v_vendedor,
        'CREDITO',0,3000000,12,'TRANSFERENCIA',v_venta);
    SELECT estado INTO v_estado FROM vehiculos_automotora
    WHERE id_vehiculo = v_vehiculo;
    comprobar(v_estado = 'VENDIDO','Vehiculo vendido');
    SELECT estado INTO v_estado FROM reservas_automotora
    WHERE id_reserva = v_reserva;
    comprobar(v_estado = 'CONCRETADA','Reserva concretada');
    SELECT COUNT(*), SUM(monto) INTO v_n,v_monto FROM cuotas_automotora
    WHERE id_venta = v_venta;
    comprobar(v_n = 12 AND v_monto = 12000000,'12 cuotas suman 12000000');
    comprobar(pkg_automotora.consultar_saldo(v_venta) = 12000000,
        'Saldo inicial 12000000');

    SELECT id_cuota INTO v_cuota FROM cuotas_automotora
    WHERE id_venta = v_venta AND numero = 1;
    pkg_automotora.registrar_pago(v_cuota,500000,'TRANSFERENCIA');
    comprobar(fn_saldo_automotora(v_venta) = 11500000,'Saldo tras abono 11500000');
    SELECT porcentaje_comision INTO v_monto FROM ventas_vehiculos
    WHERE id_venta = v_venta;
    comprobar(fn_comision_automotora(v_venta) = ROUND(3500000*v_monto/100),
        'Comision calculada sobre 3500000 efectivamente cobrados');

    v_ok := FALSE;
    BEGIN
        pkg_automotora.registrar_pago(v_cuota,600000,'EFECTIVO');
    EXCEPTION WHEN OTHERS THEN
        IF SQLCODE = -20039 THEN v_ok := TRUE; ELSE RAISE; END IF;
    END;
    comprobar(v_ok,'Sobrepago rechazado');
    comprobar(fn_saldo_automotora(v_venta) = 11500000,
        'El pago rechazado no cambia la deuda');

    v_ok := FALSE;
    BEGIN
        pkg_automotora.registrar_venta(v_cliente,v_vehiculo,v_vendedor,
            'CONTADO',0,15000000,0,'EFECTIVO',v_rechazada);
    EXCEPTION WHEN OTHERS THEN
        IF SQLCODE = -20026 THEN v_ok := TRUE; ELSE RAISE; END IF;
    END;
    comprobar(v_ok,'Segunda venta del mismo vehiculo rechazada');
    SELECT COUNT(*) INTO v_n FROM ventas_vehiculos
    WHERE id_vehiculo = v_vehiculo;
    comprobar(v_n = 1,'Solo existe una venta del vehiculo');

    SELECT MIN(id_pago) INTO v_pago FROM pagos_automotora
    WHERE id_venta = v_venta;
    v_ok := FALSE;
    BEGIN
        UPDATE pagos_automotora SET monto = monto + 1 WHERE id_pago = v_pago;
    EXCEPTION WHEN OTHERS THEN
        IF SQLCODE = -20040 THEN v_ok := TRUE; ELSE RAISE; END IF;
    END;
    comprobar(v_ok,'Trigger bloquea modificar pagos');
    v_ok := FALSE;
    BEGIN
        DELETE FROM pagos_automotora WHERE id_pago = v_pago;
    EXCEPTION WHEN OTHERS THEN
        IF SQLCODE = -20040 THEN v_ok := TRUE; ELSE RAISE; END IF;
    END;
    comprobar(v_ok,'Trigger bloquea eliminar pagos');

    SELECT COUNT(*) INTO v_n FROM auditoria_automotora
    WHERE tabla = 'VEHICULOS_AUTOMOTORA' AND nivel = 'FILA'
      AND id_registro = v_vehiculo;
    comprobar(v_n = 2,'Auditoria por fila: reserva y venta');
    SELECT COUNT(*) INTO v_n FROM auditoria_automotora
    WHERE tabla = 'VENTAS_VEHICULOS' AND nivel = 'SENTENCIA';
    UPDATE ventas_vehiculos SET total = total WHERE 1 = 0;
    SELECT COUNT(*) INTO v_monto FROM auditoria_automotora
    WHERE tabla = 'VENTAS_VEHICULOS' AND nivel = 'SENTENCIA';
    comprobar(v_monto = v_n + 1,'Trigger por sentencia incluso con cero filas');

    sp_deuda_cliente(v_cliente);
    sp_resumen_sucursales;

    INSERT INTO vehiculos_automotora (
        id_sucursal,vin,marca,modelo,anio,condicion,kilometraje,precio
    ) VALUES (
        v_sucursal,'DEMOAUTO000000002','Kia','Prueba contado',
        2023,'USADO',10000,10000000
    ) RETURNING id_vehiculo INTO v_vehiculo;
    pkg_automotora.reservar_vehiculo(v_cliente,v_vehiculo,1,v_reserva);
    UPDATE reservas_automotora SET fecha_reserva = SYSDATE-3,
        fecha_vencimiento = SYSDATE-1 WHERE id_reserva = v_reserva;
    pkg_automotora.liberar_reservas_vencidas;
    SELECT estado INTO v_estado FROM vehiculos_automotora
    WHERE id_vehiculo = v_vehiculo;
    comprobar(v_estado = 'DISPONIBLE','Reserva vencida libera vehiculo');
    SELECT estado INTO v_estado FROM reservas_automotora
    WHERE id_reserva = v_reserva;
    comprobar(v_estado = 'VENCIDA','Reserva marcada vencida');
    pkg_automotora.registrar_venta(v_cliente,v_vehiculo,v_vendedor,
        'CONTADO',0,10000000,0,'EFECTIVO',v_venta);
    comprobar(fn_saldo_automotora(v_venta) = 0,'Venta contado sin deuda');
    SELECT COUNT(*) INTO v_n FROM cuotas_automotora WHERE id_venta = v_venta;
    comprobar(v_n = 0,'Venta contado no genera cuotas');
    comprobar(pkg_automotora.total_vendido() = v_antes + 25000000,
        'Funcion total suma ambas ventas');

    ROLLBACK TO inicio_pruebas;
    comprobar(fn_total_automotora() = v_antes,'Pruebas revertidas sin alterar ventas previas');
    DBMS_OUTPUT.PUT_LINE('PRUEBAS COMPLETADAS. Datos temporales revertidos.');
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK TO inicio_pruebas;
        DBMS_OUTPUT.PUT_LINE('PRUEBA FALLIDA: ' || SQLERRM);
        RAISE;
END;
/

PROMPT PASO 10: CONSULTAS DE NEGOCIO
-- // CONSULTA: inventario
SELECT v.id_vehiculo,v.marca,v.modelo,v.precio,v.estado,s.nombre AS sucursal
FROM vehiculos_automotora v
JOIN sucursales_automotora s ON s.id_sucursal = v.id_sucursal
ORDER BY v.id_vehiculo;

-- // CONSULTA: total vendido
SELECT pkg_automotora.total_vendido() AS total_vendido FROM dual;

-- // CONSULTA: cuotas y saldos
SELECT c.id_cuota,c.id_venta,c.numero,c.vencimiento,c.monto,
       NVL(p.pagado,0) AS pagado,c.monto-NVL(p.pagado,0) AS saldo,
       CASE WHEN c.monto-NVL(p.pagado,0) = 0 THEN 'PAGADA'
            WHEN c.vencimiento < TRUNC(SYSDATE) THEN 'VENCIDA'
            ELSE 'PENDIENTE' END AS estado_cuota
FROM cuotas_automotora c
JOIN ventas_vehiculos v ON v.id_venta = c.id_venta
LEFT JOIN (SELECT id_cuota,SUM(monto) AS pagado FROM pagos_automotora
           WHERE id_cuota IS NOT NULL GROUP BY id_cuota) p
ON p.id_cuota = c.id_cuota
WHERE v.estado = 'VIGENTE'
ORDER BY c.id_venta,c.numero;

WHENEVER SQLERROR CONTINUE NONE;
PROMPT FIN DEL SCRIPT
