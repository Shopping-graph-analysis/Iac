# Infraestructura como Código (IaC) - Shopping Graph Analysis

Este repositorio contiene la definición de la infraestructura como código (IaC) para el proyecto **Shopping Graph Analysis**, una plataforma de análisis de relaciones entre productos y clientes utilizando bases de datos de grafos y una arquitectura orientada a eventos.

## Arquitectura del Sistema

![Architecture Diagram](architecture.png)

El sistema utiliza una arquitectura **Event-Driven** para procesar la ingesta de datos y **Neo4j** para el análisis de grafos, todo desplegado de forma segura en AWS.

## Estructura del Proyecto

El proyecto sigue una organización modular de Terraform para maximizar la reutilización y mantenibilidad.

```
.
├── modules/            # Módulos reutilizables (Blueprints)
│   ├── lambda/         # Configuración de funciones Serverless
│   ├── s3/             # Buckets de almacenamiento
│   ├── ec2/            # Instancias para base de datos
│   ├── api-gateway/    # Puntos de entrada HTTP
│   └── sqs/            # Colas de mensajería
├── s3-tfstate/         # Configuración del Backend Remoto (S3)
├── oidc/               # Configuración de autenticación GitHub <-> AWS
├── ssm/                # Almacén de parámetros y secretos
├── lambda_search/      # Implementación de Lambda de búsqueda de tickets
├── sqs/                # Implementación de integración S3-SQS-Lambda
├── ec2/                # Despliegue de Neo4j en EC2
├── workflow/           # Quality Gates y automatización de pruebas
└── docker-compose.yml  # Entorno de desarrollo local (LocalStack)
```

---

## Funcionalidades de Infraestructura

### 1. Estado Remoto (Remote State)
Utilizamos **S3 como backend** para almacenar el archivo `terraform.tfstate`. Esto permite la colaboración entre equipos y evita conflictos de estado.
-   **Bucket**: `tfstate-aws-shopping-graph-analysis`
-   **Configuración**: Versionado habilitado para permitir la recuperación ante errores.

### 2. Gestión de Secretos (SSM Parameter Store)
Los datos sensibles y configuraciones compartidas se gestionan en **AWS Systems Manager (SSM)** utilizando `SecureString`.
-   `/ticket/neo4j/uri`: URI de conexión para Neo4j.
-   `/ticket/neo4j/user`: Usuario administrador.
-   `/ticket/neo4j/password`: Contraseña cifrada.

### 3. Autenticación OIDC (GitHub Actions)
Implementamos **OpenID Connect (OIDC)** para permitir que las GitHub Actions se autentiquen con AWS de forma segura sin necesidad de almacenar `AWS_ACCESS_KEY_ID` permanentes.
-   **Rol**: `github-oidc-provider-role` con `AdministratorAccess` (restringido al repositorio del proyecto).

---

## Componentes Clave

### Ingestión Orientada a Eventos (S3-SQS-Lambda)
Arquitectura que procesa archivos subidos a S3 automáticamente.
1.  **S3 (`data_ingestion_bucket`)**: Detecta nuevos archivos.
2.  **SQS (`event_queue`)**: Actúa como buffer de eventos.
3.  **Lambda (`event_processor_lambda`)**: Procesa los datos del archivo.

> [!TIP]
> Despliega esta integración desde la carpeta `sqs/` para habilitar el procesamiento automático de tickets.

### Base de Datos de Grafos (EC2 + Neo4j)
Despliegue automatizado de Neo4j 5.15.0 en una instancia `t3.medium`.
-   **Puerto Bolt (7687)**: Para conexiones de aplicaciones.
-   **Puerto HTTP (7474)**: Interfaz web (Neo4j Browser).
-   **Seguridad**: Reglas de Security Group específicas y contraseñas gestionadas vía variables de Terraform.

### Lambda de Búsqueda (Search Ticket)
Ubicada en `lambda_search/`, esta función permite realizar consultas directas a Neo4j.
-   **Runtime**: Python 3.12
-   **Integración**: Lee credenciales directamente desde SSM en tiempo de ejecución.

---

## Calidad y Flujo de Trabajo (Quality Gates)

Ubicados en `workflow/`, estos procesos garantizan la integridad del código:
-   **Unit Quality Gate**: Pruebas unitarias y cobertura.
-   **Integration Quality Gate**: Valida interacciones entre servicios.
-   **Performance Quality Gate**: Pruebas de carga con **Locust**.

```bash
# Ejecutar pruebas de rendimiento
./workflow/performance_quality_gate/run_load_test.sh
```

---

## Desarrollo Local con LocalStack

Simula servicios de AWS localmente usando Docker.

```bash
docker-compose up -d
```

> [!NOTE]
> Para más detalles sobre la configuración de Docker, consulta [DOCKER_SETUP.md](DOCKER_SETUP.md).

---

## Guía de Despliegue

1.  **Requisitos**: AWS CLI configurado, Terraform instalado, Par de claves SSH creado.
2.  **Inicialización**:
    ```bash
    cd <carpeta-componente>
    terraform init
    ```
3.  **Aplicación**:
    ```bash
    terraform apply -var="neo4j_password=..." -var="key_name=..."
    ```

> [!IMPORTANT]
> Recuerda que el nombre del bucket de S3 debe ser único globalmente.

---

## Ejemplos de Consultas (Cypher)

```cypher
// Recomendaciones basadas en compras
MATCH (c:Customer {id: 'C001'})-[:PURCHASED]->(:Product)<-[:PURCHASED]-(other:Customer)
MATCH (other)-[:PURCHASED]->(recommendation:Product)
WHERE NOT (c)-[:PURCHASED]->(recommendation)
RETURN recommendation.name, count(*) as score
ORDER BY score DESC
LIMIT 5
```
