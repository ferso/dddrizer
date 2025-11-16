# DDDrizer - Hexagonal Architecture CLI

Herramienta CLI para generar componentes de arquitectura hexagonal en proyectos NestJS.

**Repositorio:** [github.com/ferso/dddrizer](https://github.com/ferso/dddrizer)

## Instalación

### Opción 1: Instalación desde GitHub

```bash
npm install --save-dev git+ssh://git@github.com:ferso/dddrizer.git
```

O usando HTTPS:

```bash
npm install --save-dev https://github.com/ferso/dddrizer.git
```

### Opción 2: Instalación local en cada proyecto

En cada proyecto donde quieras usar esta herramienta, ejecuta:

```bash
npm install --save-dev file:../dddrizer
```

O si prefieres usar la ruta absoluta:

```bash
npm install --save-dev /Volumes/MSavior/Projects/mettal/dddrizer
```

### Opción 3: Usar directamente sin instalar

Puedes copiar el script `hexagonal.sh` a cada proyecto y ejecutarlo directamente:

```bash
cp /Volumes/MSavior/Projects/mettal/dddrizer/hexagonal.sh ./hexagonal.sh
chmod +x ./hexagonal.sh
./hexagonal.sh <type> <name>
```

### Opción 4: Crear un symlink

```bash
ln -s /Volumes/MSavior/Projects/mettal/dddrizer/hexagonal.sh ./hexagonal.sh
chmod +x ./hexagonal.sh
```

## Inicialización

**IMPORTANTE:** Antes de usar cualquier comando, debes inicializar el proyecto:

```bash
dddrizer init
```

O si lo copiaste directamente:

```bash
./hexagonal.sh init
```

Esto te pedirá seleccionar el tipo de proyecto:
- **NestJS**: Para proyectos backend con NestJS
- **React**: Para proyectos frontend con React (requiere Inversify)

Si seleccionas React, el script automáticamente:
- Agregará `inversify@7.2.0` a las dependencias del `package.json`
- Ejecutará `npm install` para instalar las dependencias

Se creará un archivo `.dddrizer.json` en la raíz del proyecto con la configuración.

## Uso

Una vez inicializado, puedes usar el comando:

```bash
npx dddrizer <type> <name>
```

O si lo copiaste directamente:

```bash
./hexagonal.sh <type> <name>
```

## Tipos de componentes soportados

### 0. Init (Primer paso obligatorio)
Inicializa el proyecto y configura el tipo (NestJS o React):

```bash
dddrizer init
```

### 1. Module
Crea un nuevo módulo con toda la estructura de directorios:

```bash
dddrizer module Users
```

**Nota:** La estructura de directorios varía según el tipo de proyecto:
- **NestJS**: `infra/` con providers, controllers, etc.
- **React**: `data/` con repositories, sources, adapters y `interface/` con components, screens, etc.

### 2. Service
Crea un servicio con su provider:

```bash
./hexagonal.sh service CreateUser
```

### 3. Usecase
Crea un caso de uso con su servicio asociado:

```bash
./hexagonal.sh usecase CreateUser
```

### 4. Repository
Crea un repositorio con su provider:

```bash
./hexagonal.sh repository UserRepository
```

### 5. Source
Crea una fuente de datos externa:

```bash
./hexagonal.sh source SumsubKycLink
```

### 6. Adapter
Crea un adaptador:

```bash
./hexagonal.sh adapter ResendEmail
```

### 7. Controller
Crea un controlador (solo para proyectos NestJS):

```bash
dddrizer controller Health
```

### 8. Hook
Crea un hook de React (solo para proyectos React):

```bash
dddrizer hook UseUserData
```

### 9. Copy Service
Copia un servicio existente a otro módulo:

```bash
./hexagonal.sh copy-service CreateVerificationWallet
```

### 10. Rename
Renombra un componente existente:

```bash
./hexagonal.sh rename GetOldNameService GetNewNameService
```

### 11. Remove
Elimina un servicio:

```bash
./hexagonal.sh remove service CreateUser
```

## Estructura generada

El CLI genera diferentes estructuras según el tipo de proyecto:

### NestJS Projects:
```
src/
  features/ o gateways/
    <module-name>/
      application/
        services/
        usecases/
        hooks/
        dtos/
      domain/
        models/
        repositories/
        ports/
        dtos/
        exceptions/
      infra/
        controllers/
        graphql/
        repositories/
        providers/
        adapters/
        sources/
        typeorm/
          entities/
          migrations/
```

### React Projects:
```
src/
  features/ o gateways/
    <module-name>/
      application/
        services/
        hooks/
        dtos/
      domain/
        models/
        repositories/
        ports/
        dtos/
      data/
        repositories/
        sources/
        adapters/
      interface/
        components/
        screens/
        layouts/
        hooks/
```

**Nota importante:** El directorio `domain` siempre contiene los mismos subdirectorios en ambos tipos de proyecto:
- `models/` - Modelos de dominio
- `repositories/` - Interfaces de repositorios
- `ports/` - Puertos de la arquitectura hexagonal
- `dtos/` - Data Transfer Objects del dominio

## Características

- ✅ **Soporte multi-proyecto**: NestJS y React
- ✅ **Inicialización automática**: Comando `init` para configurar el proyecto
- ✅ **Instalación automática**: Agrega inversify automáticamente para proyectos React
- ✅ Genera código siguiendo arquitectura hexagonal
- ✅ Actualiza automáticamente los módulos (NestJS providers o React Inversify bindings)
- ✅ Evita duplicados en imports, providers y exports
- ✅ Soporta renombrado de componentes
- ✅ Soporta eliminación de servicios
- ✅ Soporta copia de servicios entre módulos
- ✅ Valida que los archivos no existan antes de crearlos
- ✅ Soporta módulos feature y gateway
- ✅ Estructura de directorios adaptada según el tipo de proyecto

## Requisitos

- Bash
- Node.js y npm (para instalación automática de dependencias)
- macOS o Linux (usa `sed -i ""` que es específico de macOS)
- Proyecto NestJS o React con estructura hexagonal

## Notas

- **IMPORTANTE**: Debes ejecutar `dddrizer init` antes de usar cualquier otro comando
- El script asume que estás ejecutándolo desde la raíz del proyecto
- Los módulos deben existir antes de crear componentes dentro de ellos
- El script detecta automáticamente si los archivos ya existen y los omite
- Para proyectos React, el script requiere inversify (se instala automáticamente con `init`)
- Controllers solo están disponibles para proyectos NestJS
- Hooks solo están disponibles para proyectos React

