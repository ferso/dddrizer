# Guía de Instalación - DDDrizer

Esta guía te mostrará paso a paso cómo instalar y usar `dddrizer` en tus proyectos.

## Instalación Rápida

### Paso 1: Instalar desde GitHub

En la raíz de tu proyecto (NestJS o React), ejecuta:

```bash
npm install --save-dev git+https://github.com/ferso/dddrizer.git
```

**Alternativa con SSH** (si tienes claves SSH configuradas):

```bash
npm install --save-dev git+ssh://git@github.com:ferso/dddrizer.git
```

### Paso 2: Verificar la instalación

```bash
npx dddrizer
```

Deberías ver el mensaje de ayuda con todos los comandos disponibles.

### Paso 3: Inicializar tu proyecto

**IMPORTANTE:** Debes inicializar el proyecto antes de usar cualquier otro comando:

```bash
npx dddrizer init
```

El comando te preguntará:

1. **¿Es un proyecto nuevo?** (y/n)

   - Si es nuevo: Se creará la estructura base del proyecto
   - Si no es nuevo: Solo se creará el archivo de configuración

2. **Tipo de proyecto:**
   - `1` para NestJS
   - `2` para React

**Para proyectos nuevos:**

- **NestJS**: Se creará `src/core/`, `src/features/`, `src/gateways/` con su estructura completa
- **React**: Se creará `src/assets/`, `src/core/`, `src/features/` con su estructura completa

Si seleccionas React, se instalará automáticamente `inversify@7.2.0`.

### Paso 4: Usar el CLI

Ahora puedes crear componentes:

```bash
# Crear un módulo
npx dddrizer module Users

# Crear un servicio (te preguntará la capa: application o domain)
npx dddrizer service CreateUser

# Crear un usecase
npx dddrizer usecase CreateUser

# Crear otros componentes
npx dddrizer repository UserRepository
npx dddrizer source ApiClient
npx dddrizer adapter EmailAdapter
```

## Configuración Avanzada

### Agregar script a package.json

Para evitar escribir `npx` cada vez, agrega esto a tu `package.json`:

```json
{
  "scripts": {
    "dddrizer": "dddrizer",
    "ddd": "dddrizer"
  }
}
```

Luego puedes usar:

```bash
npm run dddrizer init
npm run dddrizer service CreateUser
# O el alias corto
npm run ddd init
npm run ddd service CreateUser
```

### Instalación Global (Opcional)

Si quieres usar `dddrizer` en todos tus proyectos sin instalarlo en cada uno:

```bash
npm install -g git+https://github.com/ferso/dddrizer.git
```

Luego puedes usar directamente:

```bash
dddrizer init
dddrizer service CreateUser
```

**Nota:** La instalación global no es recomendada si trabajas en equipo, ya que cada desarrollador necesitaría instalarlo globalmente.

## Actualización

Para actualizar a la última versión:

```bash
npm update @mettal/dddrizer
```

O reinstalar:

```bash
npm install --save-dev git+https://github.com/ferso/dddrizer.git
```

## Solución de Problemas

### El comando no se encuentra

Si después de instalar no puedes ejecutar `npx dddrizer`:

1. Verifica que esté en `node_modules/.bin/`:

   ```bash
   ls node_modules/.bin/dddrizer
   ```

2. Si no está, reinstala:
   ```bash
   npm install --save-dev git+https://github.com/ferso/dddrizer.git
   ```

### Error de permisos

Si el script no tiene permisos de ejecución:

```bash
chmod +x node_modules/@mettal/dddrizer/hexagonal.sh
```

### Error al instalar desde GitHub

Si tienes problemas con la autenticación de GitHub:

1. **Usa HTTPS en lugar de SSH:**

   ```bash
   npm install --save-dev git+https://github.com/ferso/dddrizer.git
   ```

2. **O configura un token de acceso personal:**
   ```bash
   npm install --save-dev git+https://TU_TOKEN@github.com/ferso/dddrizer.git
   ```

## Ejemplo Completo

```bash
# 1. Crear un nuevo proyecto NestJS
nest new mi-proyecto
cd mi-proyecto

# 2. Instalar dddrizer
npm install --save-dev git+https://github.com/ferso/dddrizer.git

# 3. Inicializar el proyecto
npx dddrizer init
# Selecciona: 1 (NestJS)

# 4. Crear un módulo
npx dddrizer module Users
# Selecciona: feature

# 5. Crear un servicio
npx dddrizer service CreateUser
# Selecciona la capa: 1 (application) o 2 (domain)

# 6. Crear un usecase
npx dddrizer usecase CreateUser

# 7. Crear un controller
npx dddrizer controller Users
```

¡Listo! Ya tienes `dddrizer` instalado y funcionando en tu proyecto.
