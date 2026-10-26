# Sistema de venta de vehículos

Proyecto de Oracle PL/SQL para la asignatura BDY1103 Taller de Base de Datos.

## Integrantes

- Gefmy
- Odens

## Problema de negocio

La automotora necesita controlar la disponibilidad de sus vehículos, las reservas, las ventas y las deudas de sus clientes.

Sin validaciones comunes, se puede intentar vender un vehículo reservado o vendido y registrar pagos incorrectos.

## Solución

Centralizar la información en Oracle y aplicar reglas mediante procedimientos, funciones, cursores, un package y triggers.

## Funcionalidades

- Consultar vehículos y su disponibilidad.
- Reservar vehículos y liberar reservas vencidas.
- Registrar ventas al contado o a crédito.
- Generar cuotas y registrar abonos.
- Consultar deudas por cliente.
- Mostrar ventas y cobros por sucursal.
- Registrar auditoría y proteger los pagos.

## Tablas

El proyecto contiene 9 tablas:

- sucursales_automotora
- clientes_automotora
- vendedores_automotora
- vehiculos_automotora
- reservas_automotora
- ventas_vehiculos
- cuotas_automotora
- pagos_automotora
- auditoria_automotora

## Objetos PL/SQL

### Procedimientos independientes

- sp_deuda_cliente: muestra las ventas vigentes y la deuda de un cliente.
- sp_resumen_sucursales: muestra ventas, cobros y deuda por sucursal.

### Funciones independientes

- fn_saldo_automotora: calcula el saldo pendiente de una venta.
- fn_total_automotora: suma las ventas vigentes.
- fn_comision_automotora: calcula la comisión sobre los pagos recibidos.

### Package

pkg_automotora agrupa las operaciones de reserva, venta y pago, junto con sus validaciones.

### Cursores explícitos

- c_ventas: recorre las ventas de un cliente.
- c_sucursales: recorre las sucursales.
- c_vencidas: revisa vehículos con reservas vencidas.

### Triggers

- trg_auto_estado_vehiculo: audita cambios de estado del vehículo.
- trg_auto_auditoria_ventas: registra operaciones sobre ventas por sentencia.
- trg_auto_proteger_pagos: impide modificar o eliminar pagos registrados.

### Registros

registrar_venta utiliza variables %ROWTYPE para almacenar los datos completos del vehículo y del vendedor.

## Ejecución

1. Descargar el archivo SQL del repositorio.
2. Abrirlo en Oracle SQL Developer.
3. Seleccionar una conexión con permisos para crear los objetos.
4. Ejecutar el script completo con F5.
5. Revisar la salida del script y los resultados de las pruebas.

El script incluye tablas, datos de prueba, objetos PL/SQL y comprobaciones integradas.

Las pruebas integradas revierten sus datos temporales mediante ROLLBACK.

## Ejemplo de venta a crédito

- Precio del vehículo: $15.000.000 CLP.
- Pie: $3.000.000 CLP.
- Financiamiento: 12 cuotas de $1.000.000 CLP.
- Abono posterior: $500.000 CLP.
- Saldo pendiente después del abono: $11.500.000 CLP.

## Alcance

El proyecto implementa la lógica de base de datos y crédito sin intereses.

Las operaciones de venta y pago deben ejecutarse mediante el package para aplicar sus validaciones.

Como mejoras futuras se proponen una interfaz, permisos por rol, alertas de cuotas vencidas y un proceso de reversos.
