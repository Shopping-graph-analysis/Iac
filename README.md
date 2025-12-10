# IaC Shopping Graph Analysis

## Terraform Modules Structure

This project uses a modular Terraform architecture to manage AWS infrastructure efficiently and reusably.

### Directory Structure

The project follows a structured organization with modules and resource-specific folders:

```
.
├── .gitignore
├── README.md
├── modules/
│   ├── lambda/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── terraform.tf
│   ├── s3/
│   ├── ec2/          # Neo4j graph database on EC2
│   ├── api-gateway/
│   └── sqs/
├── lambda/
│   ├── main.tf
│   └── .terraform.lock.hcl
└── ec2/              # Neo4j deployment
    ├── main.tf
    ├── variables.tf
    └── terraform.tf
```

**Structure explanation:**
- **`modules/`**: Contains reusable module definitions
  - **`modules/lambda/`**: Lambda module with complete implementation
    - `main.tf`: Defines the Lambda function resource and IAM execution role
    - `variables.tf`: Input variables for the module (function_name, runtime, region, env, tags)
    - `terraform.tf`: Terraform version and AWS provider requirements
  - Other modules (s3, ec2, api-gateway, sqs) provide reusable infrastructure components
- **`lambda/`**: Contains the actual Lambda function implementation that uses the lambda module
  - `main.tf`: Instantiates the lambda module with specific configuration
- **`ec2/`**: Contains the Neo4j graph database deployment on EC2
  - `main.tf`: Deploys EC2 instance with Neo4j using the ec2 module
  - `variables.tf`: Configuration for SSH key and Neo4j password
  - `terraform.tf`: Provider and version configuration
  - `.terraform.lock.hcl`: Locks provider versions for reproducibility
- **`.gitignore`**: Specifies files to ignore in version control
- **`README.md`**: This documentation file

> [!IMPORTANT]
> The separation between `modules/` and resource folders is crucial. Modules contain **reusable templates**, while resource folders contain **specific implementations** that consume those modules.

### What are Terraform Modules?

Terraform modules are containers for multiple resources that are used together. They serve to **abstract how we implement a series of resources** in Terraform and allow us to **encapsulate the creation logic** of different AWS resources.

> [!NOTE]
> Think of modules as reusable blueprints. Just like a blueprint can be used to build multiple houses, a Terraform module can be used to create multiple instances of the same infrastructure pattern.

### Advantages of Using Modules

#### 1. **Code Reusability**
By having a module, we can create **multiple instances of a resource in the same way** without duplicating code. This is especially useful when we need the same type of resource for different use cases.

> [!TIP]
> **Example:** If we need 3 Lambda functions with similar configurations, instead of writing the code three times, we simply call the module three times with different parameters. This follows the DRY (Don't Repeat Yourself) principle.

#### 2. **Maintainability**
Configuration changes are made in a single place (the module), and automatically propagate to all instances that use it.

#### 3. **Consistency**
Ensures that all resources of the same type are created following the same best practices and configuration standards.

#### 4. **Abstraction**
Hides implementation complexity, allowing module users to focus on the specific parameters of their use case.

### Included Modules

#### **Lambda**
Module for creating AWS Lambda functions, including runtime configuration, environment variables, IAM roles, and triggers.

#### **S3**
Module for S3 buckets with versioning, encryption, access policies, and lifecycle configurations.

#### **EC2 (Neo4j)**
Module for deploying Neo4j graph database on EC2 instances, including security groups, IAM roles, automated Neo4j installation via user_data, and connection endpoints for Bolt protocol and Browser interface.

#### **API Gateway**
Module for creating REST or HTTP APIs with AWS API Gateway, including resources, methods, integrations, and deployments.

#### **SQS**
Module for Amazon SQS message queues, with dead-letter queue configurations, retention policies, and encryption.

### VPC (Virtual Private Cloud)

All resources for this project will be deployed within a **VPC (Virtual Private Cloud)** to ensure network isolation and security.

> [!NOTE]
> AWS automatically generates a **default VPC** in each region, which can be used for initial deployments and testing.

> [!WARNING]
> For production environments, it's **strongly recommended** to create a custom VPC with specific network configurations tailored to the project's security and connectivity requirements. The default VPC may not meet your security standards.

## Docker Compose - Local Development with LocalStack

This project includes a Docker Compose configuration that uses **LocalStack** to emulate AWS services locally, enabling development and testing without connecting to real AWS infrastructure.

### Architecture

![Architecture Diagram](architecture.png)

### Available Services

- **S3**: Object storage for data and results
- **Lambda**: Serverless function execution
- **EC2 with Neo4j**: Graph database for relationship analysis

### Quick Start

```bash
# Start LocalStack services
docker-compose up -d

# View logs
docker-compose logs -f localstack

# Stop services
docker-compose down
```


> [!TIP]
> For detailed documentation on using the Docker Compose setup, including troubleshooting and advanced examples, see [DOCKER_SETUP.md](file:///Users/giselabelmontecruz/IaC-shopping-graph-analysis/DOCKER_SETUP.md).

## Integración S3-SQS-Lambda

Este proyecto implementa una arquitectura orientada a eventos que conecta **S3**, **SQS** y **Lambda** para el procesamiento automático de datos.

### Arquitectura de la Integración

```
┌─────────────┐
│   S3 Bucket │  (Archivo subido)
│   (Origen)  │
└──────┬──────┘
       │ Notificación de Evento
       ▼
┌─────────────┐
│  Cola SQS   │  (Mensaje encolado)
│   (Buffer)  │
└──────┬──────┘
       │ Event Source Mapping
       ▼
┌─────────────┐
│   Lambda    │  (Procesa archivo)
│ (Procesador)│
└─────────────┘
```

### Componentes Implementados

#### 1. **Bucket S3** (`data_ingestion_bucket`)
- Recibe archivos para procesamiento
- Envía notificaciones de eventos `s3:ObjectCreated:*` a SQS
- Versionado habilitado para protección de datos

#### 2. **Cola SQS** (`event_queue`)
- Almacena temporalmente las notificaciones de S3
- Política de cola que permite a S3 enviar mensajes
- Retención de mensajes: 4 días
- Long polling habilitado (10 segundos)

#### 3. **Función Lambda** (`event_processor_lambda`)
- Procesa archivos de S3 cuando es notificada vía SQS
- Runtime: Python 3.11
- Permisos:
  - Lectura de objetos S3
  - Consumo de mensajes SQS
  - Escritura de logs en CloudWatch
- Event Source Mapping con tamaño de lote: 10 mensajes

### Flujo de Datos

1. Un archivo se sube al bucket S3
2. S3 envía una notificación de evento a la cola SQS
3. SQS almacena el mensaje en la cola
4. Lambda es invocada automáticamente por el Event Source Mapping
5. Lambda lee el mensaje, obtiene el archivo de S3 y lo procesa
6. Los resultados se registran en CloudWatch Logs

### Despliegue

Para desplegar la integración:

```bash
cd sqs
terraform init
terraform plan
terraform apply
```

### Prueba de la Integración

1. **Subir un archivo a S3**:
```bash
aws s3 cp test-file.json s3://shopping-graph-data-ingestion/
```

2. **Ver logs de Lambda**:
```bash
aws logs tail /aws/lambda/s3-event-processor --follow
```

### Configuración

Las variables principales se encuentran en `sqs/variables.tf`:

| Variable | Descripción | Valor por Defecto |
|----------|-------------|-------------------|
| `aws_region` | Región de AWS | `us-east-1` |
| `s3_bucket_name` | Nombre del bucket S3 | `shopping-graph-data-ingestion` |
| `sqs_queue_name` | Nombre de la cola SQS | `s3-event-notification-queue` |
| `lambda_function_name` | Nombre de la función Lambda | `s3-event-processor` |

> [!NOTE]
> El nombre del bucket S3 debe ser globalmente único. Actualiza la variable `s3_bucket_name` si el valor por defecto ya está en uso.

## EC2 con Neo4j - Base de Datos de Grafos

Este proyecto utiliza **Neo4j** como base de datos de grafos, desplegada en una instancia **EC2** para análisis de relaciones en datos de compras.

### ¿Por qué Neo4j?

Neo4j es una base de datos de grafos nativa que permite:
- **Modelar relaciones complejas** entre productos, clientes y transacciones
- **Consultas eficientes** de patrones de compra y recomendaciones
- **Análisis de grafos** como detección de comunidades y centralidad
- **Lenguaje Cypher** intuitivo para consultas de grafos

### Arquitectura EC2 + Neo4j

```
┌─────────────────┐
│   S3 Bucket     │  (Datos de compras)
│                 │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│     Lambda      │  (Procesa y carga datos)
│                 │
└────────┬────────┘
         │ Bolt Protocol (puerto 7687)
         ▼
┌─────────────────┐
│  EC2 Instance   │
│   + Neo4j       │  (Base de datos de grafos)
│                 │
└─────────────────┘
         ▲
         │ HTTP (puerto 7474)
         │
  Neo4j Browser
  (Interfaz web)
```

### Componentes Implementados

#### 1. **Módulo EC2** (`modules/ec2/`)
- **Security Group**: Permite acceso a puertos 7474 (HTTP), 7687 (Bolt), y 22 (SSH)
- **IAM Role**: Permisos para CloudWatch Logs
- **User Data Script**: Instalación automática de Neo4j 5.15.0
- **Configuración Neo4j**: 
  - Escucha en todas las interfaces de red
  - Memoria heap: 512MB-1GB
  - Page cache: 512MB

#### 2. **Despliegue EC2** (`ec2/`)
- Utiliza Amazon Linux 2023 (última AMI)
- Tipo de instancia: `t3.medium` (2 vCPU, 4GB RAM)
- Volumen EBS: 30GB cifrado
- Configuración automática de contraseña inicial

### Despliegue

Para desplegar Neo4j en EC2:

```bash
cd ec2

# Inicializar Terraform
terraform init

# Revisar el plan de despliegue
terraform plan \
  -var="key_name=tu-ssh-key" \
  -var="neo4j_password=TuPasswordSeguro123!"

# Aplicar la configuración
terraform apply \
  -var="key_name=tu-ssh-key" \
  -var="neo4j_password=TuPasswordSeguro123!"
```

> [!IMPORTANT]
> Necesitas tener un **par de claves SSH** creado en AWS antes del despliegue. Crea uno en la consola de EC2 o usa:
> ```bash
> aws ec2 create-key-pair --key-name neo4j-key --query 'KeyMaterial' --output text > neo4j-key.pem
> chmod 400 neo4j-key.pem
> ```

### Conexión a Neo4j

Después del despliegue, Terraform mostrará las URLs de conexión:

```bash
# Ver outputs
terraform output
```

#### **Neo4j Browser (Interfaz Web)**
1. Abre la URL mostrada en `neo4j_browser_url` (ej: `http://54.123.45.67:7474`)
2. Credenciales:
   - **Usuario**: `neo4j`
   - **Password**: La contraseña que configuraste
3. Tipo de conexión: `bolt://54.123.45.67:7687`

#### **Conexión desde Aplicaciones**

Python (usando `neo4j` driver):
```python
from neo4j import GraphDatabase

uri = "bolt://54.123.45.67:7687"
driver = GraphDatabase.driver(uri, auth=("neo4j", "tu_password"))

with driver.session() as session:
    result = session.run("MATCH (n) RETURN count(n) as count")
    print(result.single()["count"])
```

JavaScript (usando `neo4j-driver`):
```javascript
const neo4j = require('neo4j-driver');

const driver = neo4j.driver(
  'bolt://54.123.45.67:7687',
  neo4j.auth.basic('neo4j', 'tu_password')
);

const session = driver.session();
const result = await session.run('MATCH (n) RETURN count(n) as count');
console.log(result.records[0].get('count'));
```

### Ejemplos de Consultas Cypher

#### Crear nodos de ejemplo
```cypher
// Crear productos
CREATE (p1:Product {id: 'P001', name: 'Laptop', price: 999.99})
CREATE (p2:Product {id: 'P002', name: 'Mouse', price: 29.99})
CREATE (p3:Product {id: 'P003', name: 'Keyboard', price: 79.99})

// Crear clientes
CREATE (c1:Customer {id: 'C001', name: 'Juan Pérez'})
CREATE (c2:Customer {id: 'C002', name: 'María García'})

// Crear relaciones de compra
MATCH (c:Customer {id: 'C001'}), (p:Product {id: 'P001'})
CREATE (c)-[:PURCHASED {date: '2024-01-15', quantity: 1}]->(p)

MATCH (c:Customer {id: 'C001'}), (p:Product {id: 'P002'})
CREATE (c)-[:PURCHASED {date: '2024-01-15', quantity: 2}]->(p)
```

#### Consultas de análisis
```cypher
// Productos más comprados
MATCH (c:Customer)-[r:PURCHASED]->(p:Product)
RETURN p.name, count(r) as purchases
ORDER BY purchases DESC
LIMIT 10

// Clientes que compraron productos similares
MATCH (c1:Customer)-[:PURCHASED]->(p:Product)<-[:PURCHASED]-(c2:Customer)
WHERE c1 <> c2
RETURN c1.name, c2.name, collect(p.name) as common_products

// Recomendaciones basadas en compras
MATCH (c:Customer {id: 'C001'})-[:PURCHASED]->(:Product)<-[:PURCHASED]-(other:Customer)
MATCH (other)-[:PURCHASED]->(recommendation:Product)
WHERE NOT (c)-[:PURCHASED]->(recommendation)
RETURN recommendation.name, count(*) as score
ORDER BY score DESC
LIMIT 5
```

### Seguridad

> [!WARNING]
> La configuración por defecto permite acceso desde cualquier IP (`0.0.0.0/0`). Para producción:
> 1. Restringe `ssh_cidr_blocks` a tu IP específica
> 2. Restringe `neo4j_cidr_blocks` al CIDR de tu VPC
> 3. Usa contraseñas fuertes y rota credenciales regularmente
> 4. Habilita cifrado SSL/TLS para conexiones Bolt

### Mantenimiento

**Acceso SSH a la instancia:**
```bash
ssh -i tu-key.pem ec2-user@<public_ip>
```

**Ver logs de Neo4j:**
```bash
sudo journalctl -u neo4j -f
```

**Reiniciar Neo4j:**
```bash
sudo systemctl restart neo4j
```

**Backup de la base de datos:**
```bash
sudo neo4j-admin database dump neo4j --to-path=/tmp/backups
```

### Variables de Configuración

| Variable | Descripción | Valor por Defecto |
|----------|-------------|-------------------|
| `aws_region` | Región de AWS | `us-east-1` |
| `key_name` | Nombre del par de claves SSH | (requerido) |
| `neo4j_password` | Password para Neo4j | (requerido) |
| `instance_type` | Tipo de instancia EC2 | `t3.medium` |
| `volume_size` | Tamaño del volumen EBS (GB) | `30` |


> [!TIP]
> This modular structure facilitates project scalability and allows multiple developers to work more efficiently on different infrastructure components. Each team member can work on different resource folders without conflicts.
