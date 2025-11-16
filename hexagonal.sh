#!/bin/bash

# Hexagonal Architecture CLI Tool
# Combines all functionality from all projects' hexagonal.sh files
# Supports: init, service, repository, usecase, module, copy-service, source, adapter, controller, hook, rename, remove

CONFIG_FILE=".dddrizer.json"
PROJECT_TYPE=""

# Function to check if project is initialized
check_initialized() {
    if [ ! -f "$CONFIG_FILE" ]; then
        echo "Error: Project not initialized!"
        echo ""
        echo "Please run: dddrizer init"
        echo "This will configure your project type (NestJS or React)."
        exit 1
    fi
    
    # Read project type from config
    if command -v jq &> /dev/null; then
        PROJECT_TYPE=$(jq -r '.type' "$CONFIG_FILE" 2>/dev/null)
    else
        # Fallback: use grep if jq is not available
        PROJECT_TYPE=$(grep -o '"type"[[:space:]]*:[[:space:]]*"[^"]*"' "$CONFIG_FILE" | sed 's/.*"type"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/')
    fi
    
    if [ -z "$PROJECT_TYPE" ] || [ "$PROJECT_TYPE" = "null" ]; then
        echo "Error: Invalid configuration file. Please run: dddrizer init"
        exit 1
    fi
}

# Function to add dependency to package.json
add_dependency() {
    local dep_name="$1"
    local dep_version="$2"
    
    if [ ! -f "package.json" ]; then
        echo "Error: package.json not found in current directory"
        return 1
    fi
    
    # Check if dependency already exists
    if grep -q "\"$dep_name\"" package.json; then
        echo "Dependency $dep_name already exists in package.json"
        return 0
    fi
    
    # Use node to add dependency (more reliable than sed/awk for JSON)
    if command -v node &> /dev/null; then
        node -e "
        const fs = require('fs');
        const pkg = JSON.parse(fs.readFileSync('package.json', 'utf8'));
        if (!pkg.dependencies) pkg.dependencies = {};
        pkg.dependencies['$dep_name'] = '$dep_version';
        fs.writeFileSync('package.json', JSON.stringify(pkg, null, 2) + '\n');
        "
    else
        echo "Warning: node is not available. Please manually add $dep_name@$dep_version to package.json dependencies"
        return 1
    fi
}

# Handle init command
if [ "$1" = "init" ]; then
    echo "DDDrizer Project Initialization"
    echo "================================"
    echo ""
    echo "What type of project is this?"
    echo "1) NestJS"
    echo "2) React"
    echo ""
    read -p "Enter your choice (1 or 2): " choice
    
    case "$choice" in
        1)
            PROJECT_TYPE="nestjs"
            ;;
        2)
            PROJECT_TYPE="react"
            ;;
        *)
            echo "Error: Invalid choice. Please select 1 or 2."
            exit 1
            ;;
    esac
    
    # Create config file
    cat > "$CONFIG_FILE" << EOL
{
  "type": "$PROJECT_TYPE",
  "version": "1.0.0"
}
EOL
    
    echo ""
    echo "✓ Configuration file created: $CONFIG_FILE"
    echo "✓ Project type set to: $PROJECT_TYPE"
    
    # If React, add inversify dependency
    if [ "$PROJECT_TYPE" = "react" ]; then
        echo ""
        echo "Adding inversify dependency to package.json..."
        if add_dependency "inversify" "7.2.0"; then
            echo "✓ inversify@7.2.0 added to package.json"
            echo ""
            echo "Installing dependencies..."
            if command -v npm &> /dev/null; then
                npm install
                echo "✓ Dependencies installed"
            else
                echo "Warning: npm not found. Please run 'npm install' manually."
            fi
        else
            echo "Warning: Could not add inversify automatically. Please add it manually to package.json"
        fi
    fi
    
    echo ""
    echo "Project initialized successfully!"
    echo "You can now use dddrizer commands."
    exit 0
fi

# Check if type is provided
if [ -z "$1" ]; then
    echo "Usage: dddrizer <command> [options]"
    echo ""
    echo "Commands:"
    echo "  init                              Initialize project (NestJS or React)"
    echo "  service <name>                    Create a service"
    echo "  repository <name>                 Create a repository"
    echo "  usecase <name>                    Create a usecase"
    echo "  module <name>                     Create a module"
    echo "  copy-service <name>               Copy a service to another module"
    echo "  source <name>                     Create a source"
    echo "  adapter <name>                    Create an adapter"
    echo "  controller <name>                 Create a controller (NestJS only)"
    echo "  hook <name>                       Create a React hook (React only)"
    echo "  rename <old-name> <new-name>      Rename a component"
    echo "  remove service <name>              Remove a service"
    echo ""
    echo "Examples:"
    echo "  dddrizer init"
    echo "  dddrizer service CreateUser"
    echo "  dddrizer module Users"
    exit 1
fi

# Check if project is initialized (skip for init command)
check_initialized

# Get type and validate it
TYPE=$1
if [ "$TYPE" != "service" ] && [ "$TYPE" != "repository" ] && [ "$TYPE" != "usecase" ] && [ "$TYPE" != "module" ] && [ "$TYPE" != "copy-service" ] && [ "$TYPE" != "source" ] && [ "$TYPE" != "adapter" ] && [ "$TYPE" != "controller" ] && [ "$TYPE" != "hook" ] && [ "$TYPE" != "rename" ] && [ "$TYPE" != "remove" ] && [ "$TYPE" != "init" ]; then
    echo "Error: Type must be either 'init', 'service', 'repository', 'usecase', 'module', 'copy-service', 'source', 'adapter', 'controller', 'hook', 'rename' or 'remove'"
    echo "Usage: ./hexagonal.sh <type> <name>"
    echo "Example: ./hexagonal.sh service CreateUser"
    echo "Example: ./hexagonal.sh repository CreateUser"
    echo "Example: ./hexagonal.sh usecase CreateUser"
    echo "Example: ./hexagonal.sh module Users"
    echo "Example: ./hexagonal.sh copy-service CreateVerificationWallet"
    echo "Example: ./hexagonal.sh source SumsubKycLink"
    echo "Example: ./hexagonal.sh adapter ResendEmail"
    echo "Example: ./hexagonal.sh controller Health"
    echo "Example: ./hexagonal.sh hook UseUserData"
    echo "Example: ./hexagonal.sh rename GetOldNameService GetNewNameService"
    echo "Example: ./hexagonal.sh remove service CreateUser"
    exit 1
fi

# Check if name is provided
if [ -z "$2" ]; then
    echo "Error: Name is required"
    echo "Usage: ./hexagonal.sh <type> <name>"
    echo "Example: ./hexagonal.sh service CreateUser"
    echo "Example: ./hexagonal.sh repository CreateUser"
    echo "Example: ./hexagonal.sh usecase CreateUser"
    echo "Example: ./hexagonal.sh module Users"
    echo "Example: ./hexagonal.sh source SumsubKycLink"
    echo "Example: ./hexagonal.sh adapter ResendEmail"
    echo "Example: ./hexagonal.sh controller Health"
    echo "Example: ./hexagonal.sh hook UseUserData"
    echo "Example: ./hexagonal.sh rename GetOldNameService GetNewNameService"
    echo "Example: ./hexagonal.sh remove service CreateUser"
    exit 1
fi

# For rename command, check if new name is provided
if [ "$TYPE" = "rename" ] && [ -z "$3" ]; then
    echo "Error: New name is required for rename command"
    echo "Usage: ./hexagonal.sh rename <old-name> <new-name>"
    echo "Example: ./hexagonal.sh rename GetOldNameService GetNewNameService"
    exit 1
fi

# For remove command, check subtype and name
if [ "$TYPE" = "remove" ]; then
    if [ -z "$2" ] || [ -z "$3" ]; then
        echo "Error: Usage for remove: ./hexagonal.sh remove service <name>"
        exit 1
    fi
    if [ "$2" != "service" ]; then
        echo "Error: Remove currently supports only 'service' subtype"
        echo "Usage: ./hexagonal.sh remove service <name>"
        exit 1
    fi
fi

# If it's a module, handle it differently
if [ "$TYPE" = "module" ]; then
    # Ask if it's a feature or gateway module
    echo "Is this a feature or gateway module? (feature/gateway):"
    read MODULE_TYPE
    
    # Validate module type
    if [ "$MODULE_TYPE" != "feature" ] && [ "$MODULE_TYPE" != "gateway" ]; then
        echo "Error: Module type must be either 'feature' or 'gateway'"
        exit 1
    fi
    
    # Convert name to PascalCase for class name
    MODULE_NAME=$(echo "$2" | awk '{print tolower($0)}')
    CLASS_NAME=$(echo "$2" | awk '{print toupper(substr($0,1,1)) substr($0,2)}')
    
    # Create module directory structure based on type
    if [ "$MODULE_TYPE" = "feature" ]; then
        MODULE_PATH="src/features/${MODULE_NAME}"
    else
        MODULE_PATH="src/gateways/${MODULE_NAME}"
    fi
    
    # Create directories based on project type
    # Domain structure is always the same: models, repositories, ports, dtos
    mkdir -p "${MODULE_PATH}/domain/models"
    mkdir -p "${MODULE_PATH}/domain/repositories"
    mkdir -p "${MODULE_PATH}/domain/ports"
    mkdir -p "${MODULE_PATH}/domain/dtos"
    
    if [ "$PROJECT_TYPE" = "react" ]; then
        # React structure
        mkdir -p "${MODULE_PATH}/application/services"
        mkdir -p "${MODULE_PATH}/application/hooks"
        mkdir -p "${MODULE_PATH}/application/dtos"
        mkdir -p "${MODULE_PATH}/domain/services"
        mkdir -p "${MODULE_PATH}/data/repositories"
        mkdir -p "${MODULE_PATH}/data/sources"
        mkdir -p "${MODULE_PATH}/data/adapters"
        mkdir -p "${MODULE_PATH}/interface/components"
        mkdir -p "${MODULE_PATH}/interface/screens"
        mkdir -p "${MODULE_PATH}/interface/layouts"
        mkdir -p "${MODULE_PATH}/interface/hooks"
    else
        # NestJS structure
        mkdir -p "${MODULE_PATH}/application/services"
        mkdir -p "${MODULE_PATH}/application/usecases"
        mkdir -p "${MODULE_PATH}/application/dtos"
        mkdir -p "${MODULE_PATH}/application/hooks"
        mkdir -p "${MODULE_PATH}/domain/services"
        mkdir -p "${MODULE_PATH}/domain/exceptions"
        mkdir -p "${MODULE_PATH}/infra/controllers"
        mkdir -p "${MODULE_PATH}/infra/graphql"
        mkdir -p "${MODULE_PATH}/infra/repositories"
        mkdir -p "${MODULE_PATH}/infra/providers"
        mkdir -p "${MODULE_PATH}/infra/adapters"
        mkdir -p "${MODULE_PATH}/infra/sources"
        mkdir -p "${MODULE_PATH}/infra/typeorm"
        mkdir -p "${MODULE_PATH}/infra/typeorm/entities"
        mkdir -p "${MODULE_PATH}/infra/typeorm/migrations"
    fi
    
    # Create module file (skip if exists)
    if [ -f "${MODULE_PATH}/${MODULE_NAME}.module.ts" ]; then
        echo "File already exists, skipping: ${MODULE_PATH}/${MODULE_NAME}.module.ts"
    else
        if [ "$PROJECT_TYPE" = "react" ]; then
            # React module with Inversify
            cat > "${MODULE_PATH}/${MODULE_NAME}.module.ts" << EOL
import { Container } from "inversify";

export const configure${CLASS_NAME}Module = (container: Container) => {
  // ${CLASS_NAME} module bindings will be added here
};
EOL
        else
            # NestJS module
            cat > "${MODULE_PATH}/${MODULE_NAME}.module.ts" << EOL
import { Module } from '@nestjs/common';

@Module({
  imports: [],
  controllers: [],
  providers: [],
  exports: [],
})
export class ${CLASS_NAME}Module {}
EOL
        fi
    fi

    
    echo "Module created successfully!"
    echo "Created directory structure:"
    echo "└── ${MODULE_PATH}"
    echo "    ├── application"
    if [ "$PROJECT_TYPE" = "react" ]; then
        echo "    │   ├── services"
        echo "    │   ├── hooks"
        echo "    │   └── dtos"
        echo "    ├── domain"
        echo "    │   ├── models"
        echo "    │   ├── repositories"
        echo "    │   ├── ports"
        echo "    │   ├── dtos"
        echo "    │   └── services"
        echo "    ├── data"
        echo "    │   ├── repositories"
        echo "    │   ├── sources"
        echo "    │   └── adapters"
        echo "    └── interface"
        echo "        ├── components"
        echo "        ├── screens"
        echo "        ├── layouts"
        echo "        └── hooks"
    else
        echo "    │   ├── services"
        echo "    │   ├── usecases"
        echo "    │   ├── hooks"
        echo "    │   └── dtos"
        echo "    ├── domain"
        echo "    │   ├── models"
        echo "    │   ├── repositories"
        echo "    │   ├── ports"
        echo "    │   ├── dtos"
        echo "    │   ├── services"
        echo "    │   └── exceptions"
        echo "    └── infra"
        echo "        ├── controllers"
        echo "        ├── graphql"
        echo "        ├── providers"
        echo "        ├── repositories"
        echo "        ├── adapters"
        echo "        ├── sources"
        echo "        └── typeorm"
    fi
    echo ""
    echo "Created files:"
    echo "1. ${MODULE_PATH}/${MODULE_NAME}.module.ts"
    
    exit 0
fi


# Ask for module name
if [ "$TYPE" = "controller" ]; then
    # For controllers, combine module name and type in one question
    echo "Enter the module name (e.g., 'users' for feature or 'users gateway' for gateway, default: feature):"
    read MODULE_INPUT
    
    # Parse input: check if it contains "gateway"
    if [[ "$MODULE_INPUT" == *"gateway"* ]]; then
        MODULE_NAME=$(echo "$MODULE_INPUT" | sed 's/gateway//' | xargs)
        MODULE_PATH="src/gateways/${MODULE_NAME}"
    else
        # Default to feature (remove "feature" if user typed it, or use as-is)
        MODULE_NAME=$(echo "$MODULE_INPUT" | sed 's/feature//' | xargs)
        MODULE_PATH="src/features/${MODULE_NAME}"
    fi
else
    # For other types, just ask for module name (default to features)
    echo "Enter the module name (e.g., leasers):"
    read MODULE_NAME
    MODULE_PATH="src/features/${MODULE_NAME}"
fi

# Check if module path exists
if [ ! -d "$MODULE_PATH" ]; then
    echo "Error: Module path '$MODULE_PATH' does not exist"
    exit 1
fi

# Change to module directory
cd "$MODULE_PATH"

# If repository, ask for directory (only for NestJS)
if [ "$TYPE" = "repository" ] && [ "$PROJECT_TYPE" != "react" ]; then
    echo "Enter the directory name within infra (e.g., typeorm):"
    read REPO_DIR
fi

# Handle remove service
if [ "$TYPE" = "remove" ]; then
    SUBTYPE=$2
    REMOVE_NAME=$3
    # Compute names based on REMOVE_NAME
    CLASS_NAME=$(echo "$REMOVE_NAME" | awk '{print toupper(substr($0,1,1)) substr($0,2)}')
    FILE_SLUG=$(echo "$CLASS_NAME" | sed -E 's/([a-z0-9])([A-Z])/\1-\2/g' | tr '[:upper:]' '[:lower:]')

    # Service file path will be determined by user choice when creating
    # For remove, we check both possible locations
    SERVICE_FILE_APP="application/services/${FILE_SLUG}.service.ts"
    SERVICE_FILE_DOMAIN="domain/services/${FILE_SLUG}.service.ts"
    PROVIDER_FILE="infra/providers/${FILE_SLUG}.service.provider.ts"

    if [ -f "$SERVICE_FILE_APP" ]; then
        rm "$SERVICE_FILE_APP"
        echo "Removed: $SERVICE_FILE_APP"
    elif [ -f "$SERVICE_FILE_DOMAIN" ]; then
        rm "$SERVICE_FILE_DOMAIN"
        echo "Removed: $SERVICE_FILE_DOMAIN"
    else
        echo "Not found, skipping: Service file not found in application or domain"
    fi

    if [ -f "$PROVIDER_FILE" ]; then
        rm "$PROVIDER_FILE"
        echo "Removed: $PROVIDER_FILE"
    else
        echo "Not found, skipping: $PROVIDER_FILE"
    fi

    MODULE_FILE=$(find . -name "*.module.ts" -type f)
    if [ -n "$MODULE_FILE" ]; then
        # Remove import and provider/export entries referencing the ServiceProvider
        sed -i "" "/${CLASS_NAME}ServiceProvider/d" "$MODULE_FILE"
        echo "Updated module to remove ${CLASS_NAME}ServiceProvider references: $MODULE_FILE"
    fi

    echo "Removal completed for service ${CLASS_NAME} in module ${MODULE_NAME}"
    exit 0
fi

# Convert name to PascalCase for class name (ensure first letter is uppercase)
CLASS_NAME=$(echo "$2" | awk '{print toupper(substr($0,1,1)) substr($0,2)}')
# Convert to slug for file names (using hyphens)
FILE_SLUG=$(echo "$CLASS_NAME" | sed -E 's/([a-z0-9])([A-Z])/\1-\2/g' | tr '[:upper:]' '[:lower:]')

# Create class file based on type
if [ "$TYPE" = "service" ]; then
    # Ask user which layer to create the service in
    echo "In which layer should this service be created?"
    echo "1) application"
    echo "2) domain"
    echo ""
    read -p "Enter your choice (1 or 2): " layer_choice
    
    case "$layer_choice" in
        1)
            SERVICE_LAYER="application"
            ;;
        2)
            SERVICE_LAYER="domain"
            ;;
        *)
            echo "Error: Invalid choice. Defaulting to application."
            SERVICE_LAYER="application"
            ;;
    esac
    
    # Create service file (skip if exists)
    mkdir -p "${SERVICE_LAYER}/services"
    if [ -f "${SERVICE_LAYER}/services/${FILE_SLUG}.service.ts" ]; then
        echo "File already exists, skipping: ${SERVICE_LAYER}/services/${FILE_SLUG}.service.ts"
    else
        if [ "$PROJECT_TYPE" = "react" ]; then
            # React service with Inversify
            cat > "${SERVICE_LAYER}/services/${FILE_SLUG}.service.ts" << EOL
import { injectable } from "inversify";

@injectable()
export class ${CLASS_NAME}Service {
  constructor() {}
  
  async execute(): Promise<void> {
    // TODO: Implement service logic
  }
}
EOL
        else
            # NestJS service
            cat > "${SERVICE_LAYER}/services/${FILE_SLUG}.service.ts" << EOL
import { Injectable, Logger } from '@nestjs/common';

interface ${CLASS_NAME}Input {
  // TODO: Define input interface properties
}

@Injectable()
export class ${CLASS_NAME}Service {
  input: ${CLASS_NAME}Input;
  response: any;
  logger = new Logger(${CLASS_NAME}Service.name);
  
  constructor() {}
  
  async execute(input: ${CLASS_NAME}Input): Promise<any> {
    this.input = input;
    this.logger.log('Executing ${CLASS_NAME}Service');
    
    // TODO: Implement service logic
    await this.processData();
    this.setResponse();
    
    return this.response;
  }
  
  private async processData(): Promise<void> {
    // TODO: Implement data processing logic
  }
  
  private setResponse(): void {
    // TODO: Implement response formatting logic
    this.response = {
      // TODO: Define response structure
    };
  }
}
EOL
        fi
    fi

    # Create provider file only for NestJS (skip if exists)
    if [ "$PROJECT_TYPE" != "react" ]; then
        mkdir -p infra/providers
        if [ -f "infra/providers/${FILE_SLUG}.service.provider.ts" ]; then
            echo "File already exists, skipping: infra/providers/${FILE_SLUG}.service.provider.ts"
        else
            cat > "infra/providers/${FILE_SLUG}.service.provider.ts" << EOL
import { Provider } from '@nestjs/common';
import { ${CLASS_NAME}Service } from '../../${SERVICE_LAYER}/services/${FILE_SLUG}.service';


export const ${CLASS_NAME}ServiceProvider: Provider = {
  provide: '${CLASS_NAME}Service',
  useClass: ${CLASS_NAME}Service,
};
EOL
        fi
    fi
elif [ "$TYPE" = "usecase" ]; then
    if [ "$PROJECT_TYPE" = "react" ]; then
        # React: usecases are created as services in application
        mkdir -p application/services
        if [ -f "application/services/${FILE_SLUG}.service.ts" ]; then
            echo "File already exists, skipping: application/services/${FILE_SLUG}.service.ts"
        else
            cat > "application/services/${FILE_SLUG}.service.ts" << EOL
import { injectable, inject } from "inversify";

@injectable()
export class ${CLASS_NAME}Service {
  constructor() {}
  
  async execute(): Promise<void> {
    // TODO: Implement service logic
  }
}
EOL
        fi
    else
        # NestJS: Create usecase file (skip if exists)
        mkdir -p application/usecases
        if [ -f "application/usecases/${FILE_SLUG}.usecase.ts" ]; then
            echo "File already exists, skipping: application/usecases/${FILE_SLUG}.usecase.ts"
        else
            cat > "application/usecases/${FILE_SLUG}.usecase.ts" << EOL
import { Injectable, Inject, Logger } from '@nestjs/common';
import { ${CLASS_NAME}Service } from '../services/${FILE_SLUG}.service';

interface ${CLASS_NAME}Input {
  // TODO: Define input interface properties
}

interface ${CLASS_NAME}Response {
  data: any;
  // TODO: Define response interface properties
}

@Injectable()
export class ${CLASS_NAME}Usecase {
  input: ${CLASS_NAME}Input;
  logger = new Logger(${CLASS_NAME}Usecase.name);
  
  constructor(
    @Inject('${CLASS_NAME}Service')
    private readonly service: ${CLASS_NAME}Service,
  ) {}
  
  async execute(input: ${CLASS_NAME}Input): Promise<${CLASS_NAME}Response> {
    this.input = input;
    this.logger.log('Executing ${CLASS_NAME}Usecase');
    
    // TODO: Implement usecase logic
    const result = await this.service.execute(input);
    
    return {
      data: result,
    };
  }
}
EOL
        fi

        # Create service file (same name as usecase but with Service suffix) (skip if exists)
        # Usecases always use domain/services for the service
        mkdir -p domain/services
        if [ -f "domain/services/${FILE_SLUG}.service.ts" ]; then
            echo "File already exists, skipping: domain/services/${FILE_SLUG}.service.ts"
        else
            cat > "domain/services/${FILE_SLUG}.service.ts" << EOL
import { Injectable, Logger } from '@nestjs/common';

interface ${CLASS_NAME}Input {
  // TODO: Define input interface properties
}

@Injectable()
export class ${CLASS_NAME}Service {
  input: ${CLASS_NAME}Input;
  response: any;
  logger = new Logger(${CLASS_NAME}Service.name);
  
  constructor() {}
  
  async execute(input: ${CLASS_NAME}Input): Promise<any> {
    this.input = input;
    this.logger.log('Executing ${CLASS_NAME}Service');
    
    // TODO: Implement service logic
    await this.processData();
    this.setResponse();
    
    return this.response;
  }
  
  private async processData(): Promise<void> {
    // TODO: Implement data processing logic
  }
  
  private setResponse(): void {
    // TODO: Implement response formatting logic
    this.response = {
      // TODO: Define response structure
    };
  }
}
EOL
        fi

        # Create usecase provider file (skip if exists)
        mkdir -p infra/providers
        if [ -f "infra/providers/${FILE_SLUG}.usecase.provider.ts" ]; then
            echo "File already exists, skipping: infra/providers/${FILE_SLUG}.usecase.provider.ts"
        else
            cat > "infra/providers/${FILE_SLUG}.usecase.provider.ts" << EOL
import { Provider } from '@nestjs/common';
import { ${CLASS_NAME}Usecase } from '../../application/usecases/${FILE_SLUG}.usecase';

export const ${CLASS_NAME}UsecaseProvider: Provider = {
  provide: '${CLASS_NAME}Usecase',
  useClass: ${CLASS_NAME}Usecase,
};
EOL
        fi

        # Create service provider file (skip if exists)
        if [ -f "infra/providers/${FILE_SLUG}.service.provider.ts" ]; then
            echo "File already exists, skipping: infra/providers/${FILE_SLUG}.service.provider.ts"
        else
            cat > "infra/providers/${FILE_SLUG}.service.provider.ts" << EOL
import { Provider } from '@nestjs/common';
import { ${CLASS_NAME}Service } from '../../domain/services/${FILE_SLUG}.service';

export const ${CLASS_NAME}ServiceProvider: Provider = {
  provide: '${CLASS_NAME}Service',
  useClass: ${CLASS_NAME}Service,
};
EOL
        fi
    fi
elif [ "$TYPE" = "source" ]; then
    if [ "$PROJECT_TYPE" = "react" ]; then
        # React source
        mkdir -p data/sources
        if [ -f "data/sources/${FILE_SLUG}.source.ts" ]; then
            echo "File already exists, skipping: data/sources/${FILE_SLUG}.source.ts"
        else
            cat > "data/sources/${FILE_SLUG}.source.ts" << EOL
import { injectable } from "inversify";

interface ${CLASS_NAME}Input {
  // TODO: Define input interface
}

@injectable()
export class ${CLASS_NAME}Source {
  constructor() {}
  
  async execute(input: ${CLASS_NAME}Input): Promise<any> {
    // TODO: Implement source logic
  }
}
EOL
        fi
    else
        # NestJS source
        mkdir -p infra/sources
        if [ -f "infra/sources/${FILE_SLUG}.source.ts" ]; then
            echo "File already exists, skipping: infra/sources/${FILE_SLUG}.source.ts"
        else
            cat > "infra/sources/${FILE_SLUG}.source.ts" << EOL
import { Injectable } from '@nestjs/common';

interface ${CLASS_NAME}Input {
  // TODO: Define input interface
}

@Injectable()
export class ${CLASS_NAME}Source {
  constructor() {}
  
  async execute(input: ${CLASS_NAME}Input): Promise<any> {
    // TODO: Implement source logic
  }
}
EOL
        fi

        # Create provider file only for NestJS (skip if exists)
        mkdir -p infra/providers
        if [ -f "infra/providers/${FILE_SLUG}.source.provider.ts" ]; then
            echo "File already exists, skipping: infra/providers/${FILE_SLUG}.source.provider.ts"
        else
            cat > "infra/providers/${FILE_SLUG}.source.provider.ts" << EOL
import { Provider } from '@nestjs/common';
import { ${CLASS_NAME}Source } from '../sources/${FILE_SLUG}.source';

export const ${CLASS_NAME}SourceProvider: Provider = {
  provide: '${CLASS_NAME}Source',
  useClass: ${CLASS_NAME}Source,
};
EOL
        fi
    fi

elif [ "$TYPE" = "adapter" ]; then
    if [ "$PROJECT_TYPE" = "react" ]; then
        # React adapter
        mkdir -p data/adapters
        if [ -f "data/adapters/${FILE_SLUG}.adapter.ts" ]; then
            echo "File already exists, skipping: data/adapters/${FILE_SLUG}.adapter.ts"
        else
            cat > "data/adapters/${FILE_SLUG}.adapter.ts" << EOL
import { injectable } from "inversify";

@injectable()
export class ${CLASS_NAME}Adapter {
  constructor() {}
  
  async execute(input: any): Promise<any> {
    // TODO: Implement adapter logic
  }
}
EOL
        fi
    else
        # NestJS adapter
        mkdir -p infra/adapters
        if [ -f "infra/adapters/${FILE_SLUG}.adapter.ts" ]; then
            echo "File already exists, skipping: infra/adapters/${FILE_SLUG}.adapter.ts"
        else
            cat > "infra/adapters/${FILE_SLUG}.adapter.ts" << EOL
import { Injectable } from '@nestjs/common';

@Injectable()
export class ${CLASS_NAME}Adapter {
  constructor() {}
  
  async execute(input: any): Promise<any> {
    // TODO: Implement adapter logic
  }
}
EOL
        fi

        # Create provider file only for NestJS (skip if exists)
        mkdir -p infra/providers
        if [ -f "infra/providers/${FILE_SLUG}.adapter.provider.ts" ]; then
            echo "File already exists, skipping: infra/providers/${FILE_SLUG}.adapter.provider.ts"
        else
            cat > "infra/providers/${FILE_SLUG}.adapter.provider.ts" << EOL
import { Provider } from '@nestjs/common';
import { ${CLASS_NAME}Adapter } from '../adapters/${FILE_SLUG}.adapter';

export const ${CLASS_NAME}AdapterProvider: Provider = {
  provide: '${CLASS_NAME}Adapter',
  useClass: ${CLASS_NAME}Adapter,
};
EOL
        fi
    fi

elif [ "$TYPE" = "controller" ]; then
    # Controllers are only for NestJS projects
    if [ "$PROJECT_TYPE" != "nestjs" ]; then
        echo "Error: Controllers are only available for NestJS projects"
        exit 1
    fi
    
    # Create controller file (skip if exists)
    mkdir -p infra/controllers
    if [ -f "infra/controllers/${FILE_SLUG}.controller.ts" ]; then
        echo "File already exists, skipping: infra/controllers/${FILE_SLUG}.controller.ts"
    else
        cat > "infra/controllers/${FILE_SLUG}.controller.ts" << EOL
import { Controller, Get } from '@nestjs/common';

@Controller('${FILE_SLUG}')
export class ${CLASS_NAME}Controller {
  @Get('ping')
  ping(): string {
    return 'ok';
  }
}
EOL
    fi

elif [ "$TYPE" = "hook" ]; then
    # Hooks are only for React projects
    if [ "$PROJECT_TYPE" != "react" ]; then
        echo "Error: Hooks are only available for React projects"
        exit 1
    fi
    
    # Create hooks file (skip if exists)
    mkdir -p application/hooks
    
    # Convert CLASS_NAME to hook function name (add 'use' prefix)
    HOOK_FUNCTION_NAME="use${CLASS_NAME}"
    
    # Convert CLASS_NAME to service name
    SERVICE_NAME="${CLASS_NAME}Service"
    
    if [ -f "application/hooks/${FILE_SLUG}.hook.ts" ]; then
        echo "File already exists, skipping: application/hooks/${FILE_SLUG}.hook.ts"
    else
        cat > "application/hooks/${FILE_SLUG}.hook.ts" << EOL
import { ${SERVICE_NAME} } from "@$(basename $(pwd))/application/services/${FILE_SLUG}.service";
import { useInjection } from "@core/interface/providers/api.provider";
import { useState } from "react";

export const ${HOOK_FUNCTION_NAME} = () => {
  const [loading, setLoading] = useState<any>(null);
  const [data, setData] = useState<any>(null);
  const service = useInjection<${SERVICE_NAME}>("${SERVICE_NAME}");

  const execute = async () => {
    try {
      setLoading(true);
      const result = await service.execute();
      setData(result);
    } catch (error) {
      console.error(error);
    } finally {
      setLoading(false);
    }
  };

  return { execute, loading, data };
};
EOL
    fi

else
    # Repository
    if [ "$PROJECT_TYPE" = "react" ]; then
        # React repository
        mkdir -p data/repositories
        if [ -f "data/repositories/${FILE_SLUG}.repository.ts" ]; then
            echo "File already exists, skipping: data/repositories/${FILE_SLUG}.repository.ts"
        else
            cat > "data/repositories/${FILE_SLUG}.repository.ts" << EOL
import { injectable } from "inversify";

@injectable()
export class ${CLASS_NAME}Repository {
  constructor() {}
  
  async save(data: any): Promise<any> {
    // TODO: Implement repository save logic
  }
  
  async findById(id: string): Promise<any> {
    // TODO: Implement repository find logic
  }
}
EOL
        fi
    else
        # NestJS repository
        mkdir -p "infra/${REPO_DIR}"
        if [ -f "infra/${REPO_DIR}/${FILE_SLUG}.repository.ts" ]; then
            echo "File already exists, skipping: infra/${REPO_DIR}/${FILE_SLUG}.repository.ts"
        else
            cat > "infra/${REPO_DIR}/${FILE_SLUG}.repository.ts" << EOL
import { Injectable } from '@nestjs/common';

@Injectable()
export class ${CLASS_NAME}Repository {
  constructor() {}
}
EOL
        fi

        # Create provider file only for NestJS (skip if exists)
        mkdir -p infra/providers
        if [ -f "infra/providers/${FILE_SLUG}.repository.provider.ts" ]; then
            echo "File already exists, skipping: infra/providers/${FILE_SLUG}.repository.provider.ts"
        else
            cat > "infra/providers/${FILE_SLUG}.repository.provider.ts" << EOL
import { Provider } from '@nestjs/common';
import { ${CLASS_NAME}Repository } from '../${REPO_DIR}/${FILE_SLUG}.repository';

export const ${CLASS_NAME}RepositoryProvider: Provider = {
  provide: '${CLASS_NAME}Repository',
  useClass: ${CLASS_NAME}Repository,
};
EOL
        fi
    fi
fi

# Find and update module file
MODULE_FILE=$(find . -name "*.module.ts" -type f)
if [ -z "$MODULE_FILE" ]; then
    echo "Error: No module file found in current directory"
    exit 1
fi

# Update module based on project type
if [ "$PROJECT_TYPE" = "react" ]; then
    # React: Use Inversify bindings
    TEMP_FILE=$(mktemp)
    
    if [ "$TYPE" = "service" ]; then
        # Add import if not exists
        if ! grep -q "import { ${CLASS_NAME}Service }" "$MODULE_FILE"; then
            awk -v class="$CLASS_NAME" -v slug="$FILE_SLUG" -v layer="$SERVICE_LAYER" '
                BEGIN { added_import = 0 }
                /^import/ && !added_import {
                    print
                    print "import { " class "Service } from \"./" layer "/services/" slug ".service\";"
                    added_import = 1
                    next
                }
                { print }
            ' "$MODULE_FILE" > "$TEMP_FILE"
            mv "$TEMP_FILE" "$MODULE_FILE"
        fi
        
        # Add binding if not exists
        if ! grep -q "container.bind(\"${CLASS_NAME}Service\")" "$MODULE_FILE"; then
            awk -v class="$CLASS_NAME" '
                /\/\/ .*module bindings will be added here/ {
                    print "  container.bind(\"" class "Service\").to(" class "Service);"
                    print $0
                    next
                }
                { print }
            ' "$MODULE_FILE" > "$TEMP_FILE"
            mv "$TEMP_FILE" "$MODULE_FILE"
        fi
    elif [ "$TYPE" = "usecase" ]; then
        # Usecases always use domain/services for the service
        if ! grep -q "import { ${CLASS_NAME}Service }" "$MODULE_FILE"; then
            awk -v class="$CLASS_NAME" -v slug="$FILE_SLUG" '
                BEGIN { added_import = 0 }
                /^import/ && !added_import {
                    print
                    print "import { " class "Service } from \"./domain/services/" slug ".service\";"
                    added_import = 1
                    next
                }
                { print }
            ' "$MODULE_FILE" > "$TEMP_FILE"
            mv "$TEMP_FILE" "$MODULE_FILE"
        fi
        
        # Add binding if not exists
        if ! grep -q "container.bind(\"${CLASS_NAME}Service\")" "$MODULE_FILE"; then
            awk -v class="$CLASS_NAME" '
                /\/\/ .*module bindings will be added here/ {
                    print "  container.bind(\"" class "Service\").to(" class "Service);"
                    print $0
                    next
                }
                { print }
            ' "$MODULE_FILE" > "$TEMP_FILE"
            mv "$TEMP_FILE" "$MODULE_FILE"
        fi
        
        # Add binding if not exists
        if ! grep -q "container.bind(\"${CLASS_NAME}Service\")" "$MODULE_FILE"; then
            awk -v class="$CLASS_NAME" '
                /\/\/ .*module bindings will be added here/ {
                    print "  container.bind(\"" class "Service\").to(" class "Service);"
                    print $0
                    next
                }
                { print }
            ' "$MODULE_FILE" > "$TEMP_FILE"
            mv "$TEMP_FILE" "$MODULE_FILE"
        fi
    elif [ "$TYPE" = "source" ]; then
        # Add import if not exists
        if ! grep -q "import { ${CLASS_NAME}Source }" "$MODULE_FILE"; then
            awk -v class="$CLASS_NAME" -v slug="$FILE_SLUG" '
                BEGIN { added_import = 0 }
                /^import/ && !added_import {
                    print
                    print "import { " class "Source } from \"./data/sources/" slug ".source\";"
                    added_import = 1
                    next
                }
                { print }
            ' "$MODULE_FILE" > "$TEMP_FILE"
            mv "$TEMP_FILE" "$MODULE_FILE"
        fi
        
        # Add binding if not exists
        if ! grep -q "container.bind(\"${CLASS_NAME}Source\")" "$MODULE_FILE"; then
            awk -v class="$CLASS_NAME" '
                /\/\/ .*module bindings will be added here/ {
                    print "  container.bind(\"" class "Source\").to(" class "Source);"
                    print $0
                    next
                }
                { print }
            ' "$MODULE_FILE" > "$TEMP_FILE"
            mv "$TEMP_FILE" "$MODULE_FILE"
        fi
    elif [ "$TYPE" = "adapter" ]; then
        # Add import if not exists
        if ! grep -q "import { ${CLASS_NAME}Adapter }" "$MODULE_FILE"; then
            awk -v class="$CLASS_NAME" -v slug="$FILE_SLUG" '
                BEGIN { added_import = 0 }
                /^import/ && !added_import {
                    print
                    print "import { " class "Adapter } from \"./data/adapters/" slug ".adapter\";"
                    added_import = 1
                    next
                }
                { print }
            ' "$MODULE_FILE" > "$TEMP_FILE"
            mv "$TEMP_FILE" "$MODULE_FILE"
        fi
        
        # Add binding if not exists
        if ! grep -q "container.bind(\"${CLASS_NAME}Adapter\")" "$MODULE_FILE"; then
            awk -v class="$CLASS_NAME" '
                /\/\/ .*module bindings will be added here/ {
                    print "  container.bind(\"" class "Adapter\").to(" class "Adapter);"
                    print $0
                    next
                }
                { print }
            ' "$MODULE_FILE" > "$TEMP_FILE"
            mv "$TEMP_FILE" "$MODULE_FILE"
        fi
    elif [ "$TYPE" = "repository" ]; then
        # Add import if not exists
        if ! grep -q "import { ${CLASS_NAME}Repository }" "$MODULE_FILE"; then
            awk -v class="$CLASS_NAME" -v slug="$FILE_SLUG" '
                BEGIN { added_import = 0 }
                /^import/ && !added_import {
                    print
                    print "import { " class "Repository } from \"./data/repositories/" slug ".repository\";"
                    added_import = 1
                    next
                }
                { print }
            ' "$MODULE_FILE" > "$TEMP_FILE"
            mv "$TEMP_FILE" "$MODULE_FILE"
        fi
        
        # Add binding if not exists
        if ! grep -q "container.bind(\"${CLASS_NAME}Repository\")" "$MODULE_FILE"; then
            awk -v class="$CLASS_NAME" '
                /\/\/ .*module bindings will be added here/ {
                    print "  container.bind(\"" class "Repository\").to(" class "Repository);"
                    print $0
                    next
                }
                { print }
            ' "$MODULE_FILE" > "$TEMP_FILE"
            mv "$TEMP_FILE" "$MODULE_FILE"
        fi
    fi
else
    # NestJS: Use providers
    # Build missing imports and providers to avoid duplicates
    MISSING_IMPORTS=""
    MISSING_PROVIDERS=""
    MISSING_CONTROLLERS=""

    if [ "$TYPE" = "service" ]; then
        if ! grep -q "${CLASS_NAME}ServiceProvider" "$MODULE_FILE"; then
            MISSING_IMPORTS+="import { ${CLASS_NAME}ServiceProvider } from \"./infra/providers/${FILE_SLUG}.service.provider\";\n"
            MISSING_PROVIDERS+="    ${CLASS_NAME}ServiceProvider,\n"
        fi
    elif [ "$TYPE" = "usecase" ]; then
    if ! grep -q "${CLASS_NAME}UsecaseProvider" "$MODULE_FILE"; then
        MISSING_IMPORTS+="import { ${CLASS_NAME}UsecaseProvider } from \"./infra/providers/${FILE_SLUG}.usecase.provider\";\n"
        MISSING_PROVIDERS+="    ${CLASS_NAME}UsecaseProvider,\n"
    fi
    if ! grep -q "${CLASS_NAME}ServiceProvider" "$MODULE_FILE"; then
        MISSING_IMPORTS+="import { ${CLASS_NAME}ServiceProvider } from \"./infra/providers/${FILE_SLUG}.service.provider\";\n"
        MISSING_PROVIDERS+="    ${CLASS_NAME}ServiceProvider,\n"
    fi
elif [ "$TYPE" = "source" ]; then
    if ! grep -q "${CLASS_NAME}SourceProvider" "$MODULE_FILE"; then
        MISSING_IMPORTS+="import { ${CLASS_NAME}SourceProvider } from \"./infra/providers/${FILE_SLUG}.source.provider\";\n"
        MISSING_PROVIDERS+="    ${CLASS_NAME}SourceProvider,\n"
    fi
elif [ "$TYPE" = "adapter" ]; then
    if ! grep -q "${CLASS_NAME}AdapterProvider" "$MODULE_FILE"; then
        MISSING_IMPORTS+="import { ${CLASS_NAME}AdapterProvider } from \"./infra/providers/${FILE_SLUG}.adapter.provider\";\n"
        MISSING_PROVIDERS+="    ${CLASS_NAME}AdapterProvider,\n"
    fi
elif [ "$TYPE" = "controller" ]; then
    if ! grep -q "${CLASS_NAME}Controller" "$MODULE_FILE"; then
        MISSING_IMPORTS+="import { ${CLASS_NAME}Controller } from \"./infra/controllers/${FILE_SLUG}.controller\";\n"
        MISSING_CONTROLLERS+="    ${CLASS_NAME}Controller,\n"
    fi
elif [ "$TYPE" = "hook" ]; then
    # Hooks don't need to be registered in the module
    echo "Hook created successfully. Note: Hooks are React components and don't need module registration."
else
    if ! grep -q "${CLASS_NAME}RepositoryProvider" "$MODULE_FILE"; then
        MISSING_IMPORTS+="import { ${CLASS_NAME}RepositoryProvider } from \"./infra/providers/${FILE_SLUG}.repository.provider\";\n"
        MISSING_PROVIDERS+="    ${CLASS_NAME}RepositoryProvider,\n"
    fi
fi

    # Prepend missing imports, if any
    if [ -n "$MISSING_IMPORTS" ]; then
        TEMP_FILE=$(mktemp)
        printf "%b" "$MISSING_IMPORTS" > "$TEMP_FILE"
        cat "$MODULE_FILE" >> "$TEMP_FILE"
        mv "$TEMP_FILE" "$MODULE_FILE"
    fi

    # Inject missing controllers into controllers array, if any
    if [ -n "$MISSING_CONTROLLERS" ]; then
        TEMP_FILE=$(mktemp)
        awk -v add_lines="$MISSING_CONTROLLERS" '
            function print_lines(s) { n=split(s, arr, "\\n"); for (i=1; i<=n; i++) if (arr[i] != "") print arr[i]; }
            BEGIN { added = 0 }
            /controllers: \[/ && added == 0 { print $0; print_lines(add_lines); added = 1; next }
            { print }
        ' "$MODULE_FILE" > "$TEMP_FILE"
        mv "$TEMP_FILE" "$MODULE_FILE"

        # If controllers array did not exist, create it before providers
        if ! grep -q "controllers: \[" "$MODULE_FILE"; then
            TEMP_FILE=$(mktemp)
            awk -v add_lines="$MISSING_CONTROLLERS" '
                function print_lines(s) { n=split(s, arr, "\\n"); for (i=1; i<=n; i++) if (arr[i] != "") print arr[i]; }
                BEGIN { inserted = 0 }
                /providers: \[/ && inserted == 0 { print "  controllers: ["; print_lines(add_lines); print "  ],"; print $0; inserted = 1; next }
                { print }
            ' "$MODULE_FILE" > "$TEMP_FILE"
            mv "$TEMP_FILE" "$MODULE_FILE"
        fi
    fi

    # Inject missing providers into providers array, if any
    if [ -n "$MISSING_PROVIDERS" ]; then
        TEMP_FILE=$(mktemp)
        awk -v add_lines="$MISSING_PROVIDERS" '
            function print_lines(s) { n=split(s, arr, "\\n"); for (i=1; i<=n; i++) if (arr[i] != "") print arr[i]; }
            BEGIN { added = 0 }
            /providers: \[/ && added == 0 { print $0; print_lines(add_lines); added = 1; next }
            { print }
        ' "$MODULE_FILE" > "$TEMP_FILE"
        mv "$TEMP_FILE" "$MODULE_FILE"
    fi

    # Build missing exports and inject if any
    MISSING_EXPORTS=""
    if [ "$TYPE" = "service" ]; then
        if ! grep -q "${CLASS_NAME}ServiceProvider" "$MODULE_FILE"; then
            MISSING_EXPORTS+="    ${CLASS_NAME}ServiceProvider,\n"
        fi
    elif [ "$TYPE" = "usecase" ]; then
        if ! grep -q "${CLASS_NAME}UsecaseProvider" "$MODULE_FILE"; then
            MISSING_EXPORTS+="    ${CLASS_NAME}UsecaseProvider,\n"
        fi
        if ! grep -q "${CLASS_NAME}ServiceProvider" "$MODULE_FILE"; then
            MISSING_EXPORTS+="    ${CLASS_NAME}ServiceProvider,\n"
        fi
    elif [ "$TYPE" = "source" ]; then
        if ! grep -q "${CLASS_NAME}SourceProvider" "$MODULE_FILE"; then
            MISSING_EXPORTS+="    ${CLASS_NAME}SourceProvider,\n"
        fi
    elif [ "$TYPE" = "adapter" ]; then
        if ! grep -q "${CLASS_NAME}AdapterProvider" "$MODULE_FILE"; then
            MISSING_EXPORTS+="    ${CLASS_NAME}AdapterProvider,\n"
        fi
    else
        if ! grep -q "${CLASS_NAME}RepositoryProvider" "$MODULE_FILE"; then
            MISSING_EXPORTS+="    ${CLASS_NAME}RepositoryProvider,\n"
        fi
    fi

    if [ -n "$MISSING_EXPORTS" ]; then
        TEMP_FILE=$(mktemp)
        awk -v add_lines="$MISSING_EXPORTS" '
            function print_lines(s) { n=split(s, arr, "\\n"); for (i=1; i<=n; i++) if (arr[i] != "") print arr[i]; }
            BEGIN { added = 0 }
            /exports: \[/ && added == 0 { print $0; print_lines(add_lines); added = 1; next }
            { print }
        ' "$MODULE_FILE" > "$TEMP_FILE"
        mv "$TEMP_FILE" "$MODULE_FILE"
    fi
fi

echo "${CLASS_NAME} ${TYPE} created successfully in ${MODULE_PATH}!"
echo "Files created:"
if [ "$TYPE" = "service" ]; then
    echo "1. ${MODULE_PATH}/${SERVICE_LAYER}/services/${FILE_SLUG}.service.ts"
    if [ "$PROJECT_TYPE" != "react" ]; then
        echo "2. ${MODULE_PATH}/infra/providers/${FILE_SLUG}.service.provider.ts"
    fi
elif [ "$TYPE" = "usecase" ]; then
    if [ "$PROJECT_TYPE" = "react" ]; then
        echo "1. ${MODULE_PATH}/application/services/${FILE_SLUG}.service.ts"
    else
        echo "1. ${MODULE_PATH}/application/usecases/${FILE_SLUG}.usecase.ts"
        echo "2. ${MODULE_PATH}/domain/services/${FILE_SLUG}.service.ts"
        echo "3. ${MODULE_PATH}/infra/providers/${FILE_SLUG}.usecase.provider.ts"
        echo "4. ${MODULE_PATH}/infra/providers/${FILE_SLUG}.service.provider.ts"
    fi
elif [ "$TYPE" = "source" ]; then
    if [ "$PROJECT_TYPE" = "react" ]; then
        echo "1. ${MODULE_PATH}/data/sources/${FILE_SLUG}.source.ts"
    else
        echo "1. ${MODULE_PATH}/infra/sources/${FILE_SLUG}.source.ts"
        echo "2. ${MODULE_PATH}/infra/providers/${FILE_SLUG}.source.provider.ts"
    fi
elif [ "$TYPE" = "adapter" ]; then
    if [ "$PROJECT_TYPE" = "react" ]; then
        echo "1. ${MODULE_PATH}/data/adapters/${FILE_SLUG}.adapter.ts"
    else
        echo "1. ${MODULE_PATH}/infra/adapters/${FILE_SLUG}.adapter.ts"
        echo "2. ${MODULE_PATH}/infra/providers/${FILE_SLUG}.adapter.provider.ts"
    fi
elif [ "$TYPE" = "controller" ]; then
    echo "1. ${MODULE_PATH}/infra/controllers/${FILE_SLUG}.controller.ts"
elif [ "$TYPE" = "hook" ]; then
    echo "1. ${MODULE_PATH}/application/hooks/${FILE_SLUG}.hook.ts"
else
    if [ "$PROJECT_TYPE" = "react" ]; then
        echo "1. ${MODULE_PATH}/data/repositories/${FILE_SLUG}.repository.ts"
    else
        echo "1. ${MODULE_PATH}/infra/${REPO_DIR}/${FILE_SLUG}.repository.ts"
        echo "2. ${MODULE_PATH}/infra/providers/${FILE_SLUG}.repository.provider.ts"
    fi
fi
if [ "$TYPE" != "hook" ]; then
    echo "Module file updated: ${MODULE_PATH}/$MODULE_FILE"
fi

# Agregar la nueva lógica para copy-service después del bloque if [ "$TYPE" = "module" ]
if [ "$TYPE" = "copy-service" ]; then
    echo "Enter the source service path (e.g., verification/application/services/create-verification-wallet.service or verification/domain/services/create-verification-wallet.service):"
    read SOURCE_PATH
    
    echo "Enter the target module name (e.g., users):"
    read TARGET_MODULE
    
    # Extract service name from source path if full path is provided
    if [[ $SOURCE_PATH == *"/"* ]]; then
        SERVICE_NAME=$(basename "$SOURCE_PATH" .service.ts)
    else
        SERVICE_NAME=$SOURCE_PATH
    fi
    
    # Convert target name to PascalCase for class name
    TARGET_NAME=$(echo "$2" | awk '{print toupper(substr($0,1,1)) substr($0,2)}')
    # Convert to slug for file names
    TARGET_SLUG=$(echo "$TARGET_NAME" | sed -E 's/([a-z0-9])([A-Z])/\1-\2/g' | tr '[:upper:]' '[:lower:]')
    
    # Construct paths
    if [[ $SOURCE_PATH == *"/"* ]]; then
        SOURCE_FILE="src/features/${SOURCE_PATH}"
    else
        SOURCE_FILE="src/features/${SOURCE_PATH}.service.ts"
    fi
    
    TARGET_PATH="src/features/${TARGET_MODULE}"
    
    # Check if source file exists
    if [ ! -f "$SOURCE_FILE" ]; then
        echo "Error: Source service file '$SOURCE_FILE' does not exist"
        exit 1
    fi
    
    # Check if target module exists
    if [ ! -d "$TARGET_PATH" ]; then
        echo "Error: Target module path '$TARGET_PATH' does not exist"
        exit 1
    fi
    
    # Determine target layer from source path
    if [[ $SOURCE_PATH == *"/application/services/"* ]]; then
        TARGET_LAYER="application"
    elif [[ $SOURCE_PATH == *"/domain/services/"* ]]; then
        TARGET_LAYER="domain"
    else
        # Default to application if path doesn't specify
        echo "Could not determine layer from path, defaulting to application"
        TARGET_LAYER="application"
    fi
    
    # Create service file
    mkdir -p "${TARGET_PATH}/${TARGET_LAYER}/services"
    
    # Copy and modify the service file (skip if exists)
    if [ -f "${TARGET_PATH}/${TARGET_LAYER}/services/${TARGET_SLUG}.service.ts" ]; then
        echo "File already exists, skipping: ${TARGET_PATH}/${TARGET_LAYER}/services/${TARGET_SLUG}.service.ts"
    else
        sed "s/${SERVICE_NAME}/${TARGET_SLUG}/g" "$SOURCE_FILE" > "${TARGET_PATH}/${TARGET_LAYER}/services/${TARGET_SLUG}.service.ts"
        sed -i "" "s/class [a-zA-Z]*Service/class ${TARGET_NAME}Service/g" "${TARGET_PATH}/${TARGET_LAYER}/services/${TARGET_SLUG}.service.ts"
        
        # If React, replace NestJS imports with Inversify
        if [ "$PROJECT_TYPE" = "react" ]; then
            sed -i "" "s/@Injectable()/@injectable()/g" "${TARGET_PATH}/${TARGET_LAYER}/services/${TARGET_SLUG}.service.ts"
            sed -i "" "s/import { Injectable } from '@nestjs\/common';/import { injectable } from \"inversify\";/g" "${TARGET_PATH}/${TARGET_LAYER}/services/${TARGET_SLUG}.service.ts"
        fi
    fi
    
    # Create provider file only for NestJS (skip if exists)
    if [ "$PROJECT_TYPE" != "react" ]; then
        mkdir -p "${TARGET_PATH}/infra/providers"
        if [ -f "${TARGET_PATH}/infra/providers/${TARGET_SLUG}.service.provider.ts" ]; then
            echo "File already exists, skipping: ${TARGET_PATH}/infra/providers/${TARGET_SLUG}.service.provider.ts"
        else
            cat > "${TARGET_PATH}/infra/providers/${TARGET_SLUG}.service.provider.ts" << EOL
import { Provider } from '@nestjs/common';
import { ${TARGET_NAME}Service } from '../../${TARGET_LAYER}/services/${TARGET_SLUG}.service';

export const ${TARGET_NAME}ServiceProvider: Provider = {
  provide: '${TARGET_NAME}Service',
  useClass: ${TARGET_NAME}Service,
};
EOL
        fi
    fi
    
    # Find and update module file
    MODULE_FILE=$(find "${TARGET_PATH}" -name "*.module.ts" -type f)
    if [ -n "$MODULE_FILE" ]; then
        if [ "$PROJECT_TYPE" = "react" ]; then
            # React: Use Inversify bindings
            TEMP_FILE=$(mktemp)
            
            # Add import if not exists
            if ! grep -q "import { ${TARGET_NAME}Service }" "$MODULE_FILE"; then
                awk -v class="$TARGET_NAME" -v slug="$TARGET_SLUG" -v layer="$TARGET_LAYER" '
                    BEGIN { added_import = 0 }
                    /^import/ && !added_import {
                        print
                        print "import { " class "Service } from \"./" layer "/services/" slug ".service\";"
                        added_import = 1
                        next
                    }
                    { print }
                ' "$MODULE_FILE" > "$TEMP_FILE"
                mv "$TEMP_FILE" "$MODULE_FILE"
            fi
            
            # Add binding if not exists
            if ! grep -q "container.bind(\"${TARGET_NAME}Service\")" "$MODULE_FILE"; then
                awk -v class="$TARGET_NAME" '
                    /\/\/ .*module bindings will be added here/ {
                        print "  container.bind(\"" class "Service\").to(" class "Service);"
                        print $0
                        next
                    }
                    { print }
                ' "$MODULE_FILE" > "$TEMP_FILE"
                mv "$TEMP_FILE" "$MODULE_FILE"
            fi
        else
            # NestJS: Use providers
            # Avoid duplicate imports/providers/exports for copy-service
            MISSING_IMPORTS=""
            MISSING_PROVIDERS=""
            MISSING_EXPORTS=""

            if ! grep -q "${TARGET_NAME}ServiceProvider" "$MODULE_FILE"; then
                MISSING_IMPORTS+="import { ${TARGET_NAME}ServiceProvider } from \"./infra/providers/${TARGET_SLUG}.service.provider\";\n"
                MISSING_PROVIDERS+="    ${TARGET_NAME}ServiceProvider,\n"
                MISSING_EXPORTS+="    ${TARGET_NAME}ServiceProvider,\n"
            fi

            if [ -n "$MISSING_IMPORTS" ]; then
                TEMP_FILE=$(mktemp)
                printf "%b" "$MISSING_IMPORTS" > "$TEMP_FILE"
                cat "$MODULE_FILE" >> "$TEMP_FILE"
                mv "$TEMP_FILE" "$MODULE_FILE"
            fi

            if [ -n "$MISSING_PROVIDERS" ]; then
                TEMP_FILE=$(mktemp)
                awk -v add_lines="$MISSING_PROVIDERS" '
                    function print_lines(s) { n=split(s, arr, "\\n"); for (i=1; i<=n; i++) if (arr[i] != "") print arr[i]; }
                    BEGIN { added = 0 }
                    /providers: \[/ && added == 0 { print $0; print_lines(add_lines); added = 1; next }
                    { print }
                ' "$MODULE_FILE" > "$TEMP_FILE"
                mv "$TEMP_FILE" "$MODULE_FILE"
            fi

            if [ -n "$MISSING_EXPORTS" ]; then
                TEMP_FILE=$(mktemp)
                awk -v add_lines="$MISSING_EXPORTS" '
                    function print_lines(s) { n=split(s, arr, "\\n"); for (i=1; i<=n; i++) if (arr[i] != "") print arr[i]; }
                    BEGIN { added = 0 }
                    /exports: \[/ && added == 0 { print $0; print_lines(add_lines); added = 1; next }
                    { print }
                ' "$MODULE_FILE" > "$TEMP_FILE"
                mv "$TEMP_FILE" "$MODULE_FILE"
            fi
        fi
    fi
    
    echo "Service copied successfully!"
    echo "Files created:"
    echo "1. ${TARGET_PATH}/${TARGET_LAYER}/services/${TARGET_SLUG}.service.ts"
    if [ "$PROJECT_TYPE" != "react" ]; then
        echo "2. ${TARGET_PATH}/infra/providers/${TARGET_SLUG}.service.provider.ts"
        echo "3. Updated module file: $MODULE_FILE"
    else
        echo "2. Updated module file: $MODULE_FILE"
    fi
    
    exit 0
fi

# Handle rename command
if [ "$TYPE" = "rename" ]; then
    OLD_NAME="$2"
    NEW_NAME="$3"
    
    # Ask for module name
    echo "Enter the module name where the file is located (e.g., users):"
    read MODULE_NAME
    
    # Construct full module path
    MODULE_PATH="src/features/${MODULE_NAME}"
    
    # Check if module path exists
    if [ ! -d "$MODULE_PATH" ]; then
        echo "Error: Module path '$MODULE_PATH' does not exist"
        echo "Available modules:"
        ls -1 src/features/ 2>/dev/null || echo "No modules found in src/features/"
        exit 1
    fi
    
    # Convert names to different formats
    OLD_CLASS_NAME=$(echo "$OLD_NAME" | awk '{print toupper(substr($0,1,1)) substr($0,2)}')
    NEW_CLASS_NAME=$(echo "$NEW_NAME" | awk '{print toupper(substr($0,1,1)) substr($0,2)}')
    OLD_FILE_SLUG=$(echo "$OLD_CLASS_NAME" | sed -E 's/([a-z0-9])([A-Z])/\1-\2/g' | tr '[:upper:]' '[:lower:]')
    NEW_FILE_SLUG=$(echo "$NEW_CLASS_NAME" | sed -E 's/([a-z0-9])([A-Z])/\1-\2/g' | tr '[:upper:]' '[:lower:]')
    
    # Store current directory
    ORIGINAL_DIR=$(pwd)
    
    # Change to module directory
    if ! cd "$MODULE_PATH"; then
        echo "Error: Cannot access module directory '$MODULE_PATH'"
        exit 1
    fi
    
    # Ask for component type to determine which files to rename
    echo "What type of component is this? (service/usecase/repository/source/adapter/controller/hook):"
    read COMPONENT_TYPE
    
    # Validate component type
    if [ "$COMPONENT_TYPE" != "service" ] && [ "$COMPONENT_TYPE" != "usecase" ] && [ "$COMPONENT_TYPE" != "repository" ] && [ "$COMPONENT_TYPE" != "source" ] && [ "$COMPONENT_TYPE" != "adapter" ] && [ "$COMPONENT_TYPE" != "controller" ] && [ "$COMPONENT_TYPE" != "hook" ]; then
        echo "Error: Component type must be either 'service', 'usecase', 'repository', 'source', 'adapter', 'controller' or 'hook'"
        exit 1
    fi
    
    # For repository, ask for directory
    if [ "$COMPONENT_TYPE" = "repository" ]; then
        echo "Enter the directory name within infra (e.g., typeorm):"
        read REPO_DIR
    fi
    
    # Check if at least one file exists to rename
    FILES_EXIST=false
    case "$COMPONENT_TYPE" in
        "service")
            if [ -f "domain/services/${OLD_FILE_SLUG}.service.ts" ] || [ -f "infra/providers/${OLD_FILE_SLUG}.service.provider.ts" ]; then
                FILES_EXIST=true
            fi
            ;;
        "usecase")
            if [ -f "application/usecases/${OLD_FILE_SLUG}.usecase.ts" ] || [ -f "domain/services/${OLD_FILE_SLUG}.service.ts" ] || [ -f "infra/providers/${OLD_FILE_SLUG}.usecase.provider.ts" ] || [ -f "infra/providers/${OLD_FILE_SLUG}.service.provider.ts" ]; then
                FILES_EXIST=true
            fi
            ;;
        "repository")
            if [ -f "infra/${REPO_DIR}/${OLD_FILE_SLUG}.repository.ts" ] || [ -f "infra/providers/${OLD_FILE_SLUG}.repository.provider.ts" ]; then
                FILES_EXIST=true
            fi
            ;;
        "source")
            if [ -f "infra/sources/${OLD_FILE_SLUG}.source.ts" ] || [ -f "infra/providers/${OLD_FILE_SLUG}.source.provider.ts" ]; then
                FILES_EXIST=true
            fi
            ;;
        "adapter")
            if [ -f "infra/adapters/${OLD_FILE_SLUG}.adapter.ts" ] || [ -f "infra/providers/${OLD_FILE_SLUG}.adapter.provider.ts" ]; then
                FILES_EXIST=true
            fi
            ;;
        "controller")
            if [ -f "infra/controllers/${OLD_FILE_SLUG}.controller.ts" ]; then
                FILES_EXIST=true
            fi
            ;;
        "hook")
            if [ -f "application/hooks/${OLD_FILE_SLUG}.hook.ts" ]; then
                FILES_EXIST=true
            fi
            ;;
    esac
    
    if [ "$FILES_EXIST" = false ]; then
        echo "Error: No files found to rename for ${OLD_NAME} in module ${MODULE_NAME}"
        echo "Please check that the component name and type are correct."
        exit 1
    fi
    
    # Function to rename file and update references
    rename_file_and_references() {
        local old_file="$1"
        local new_file="$2"
        local old_class="$3"
        local new_class="$4"
        local old_slug="$5"
        local new_slug="$6"
        
        if [ -f "$old_file" ]; then
            # Rename the file
            mv "$old_file" "$new_file"
            echo "Renamed: $old_file -> $new_file"
            
            # Update class name in the file
            sed -i "" "s/class ${old_class}/class ${new_class}/g" "$new_file"
            sed -i "" "s/interface ${old_class}/interface ${new_class}/g" "$new_file"
            sed -i "" "s/${old_class}Service/${new_class}Service/g" "$new_file"
            sed -i "" "s/${old_class}Usecase/${new_class}Usecase/g" "$new_file"
            sed -i "" "s/${old_class}Repository/${new_class}Repository/g" "$new_file"
            sed -i "" "s/${old_class}Source/${new_class}Source/g" "$new_file"
            sed -i "" "s/${old_class}Adapter/${new_class}Adapter/g" "$new_file"
            sed -i "" "s/${old_class}Controller/${new_class}Controller/g" "$new_file"
            sed -i "" "s/${old_class}Input/${new_class}Input/g" "$new_file"
            sed -i "" "s/${old_class}Provider/${new_class}Provider/g" "$new_file"
            sed -i "" "s/use${old_class}/use${new_class}/g" "$new_file"
            sed -i "" "s/'${old_class}Service'/'${new_class}Service'/g" "$new_file"
            sed -i "" "s/'${old_class}Usecase'/'${new_class}Usecase'/g" "$new_file"
            sed -i "" "s/'${old_class}Repository'/'${new_class}Repository'/g" "$new_file"
            sed -i "" "s/'${old_class}Source'/'${new_class}Source'/g" "$new_file"
            sed -i "" "s/'${old_class}Adapter'/'${new_class}Adapter'/g" "$new_file"
            
            # Update import paths if they contain the old slug
            sed -i "" "s/${old_slug}\.service/${new_slug}.service/g" "$new_file"
            sed -i "" "s/${old_slug}\.usecase/${new_slug}.usecase/g" "$new_file"
            sed -i "" "s/${old_slug}\.repository/${new_slug}.repository/g" "$new_file"
            sed -i "" "s/${old_slug}\.source/${new_slug}.source/g" "$new_file"
            sed -i "" "s/${old_slug}\.adapter/${new_slug}.adapter/g" "$new_file"
            sed -i "" "s/${old_slug}\.controller/${new_slug}.controller/g" "$new_file"
            sed -i "" "s/${old_slug}\.hook/${new_slug}.hook/g" "$new_file"
            
            echo "Updated references in: $new_file"
        else
            echo "Warning: File not found: $old_file"
        fi
    }
    
    # Rename files based on component type
    case "$COMPONENT_TYPE" in
        "service")
            # Check both possible locations for service
            if [ -f "application/services/${OLD_FILE_SLUG}.service.ts" ]; then
                rename_file_and_references \
                    "application/services/${OLD_FILE_SLUG}.service.ts" \
                    "application/services/${NEW_FILE_SLUG}.service.ts" \
                    "$OLD_CLASS_NAME" "$NEW_CLASS_NAME" "$OLD_FILE_SLUG" "$NEW_FILE_SLUG"
            elif [ -f "domain/services/${OLD_FILE_SLUG}.service.ts" ]; then
                rename_file_and_references \
                    "domain/services/${OLD_FILE_SLUG}.service.ts" \
                    "domain/services/${NEW_FILE_SLUG}.service.ts" \
                    "$OLD_CLASS_NAME" "$NEW_CLASS_NAME" "$OLD_FILE_SLUG" "$NEW_FILE_SLUG"
            fi
            
            if [ -f "infra/providers/${OLD_FILE_SLUG}.service.provider.ts" ]; then
                rename_file_and_references \
                    "infra/providers/${OLD_FILE_SLUG}.service.provider.ts" \
                    "infra/providers/${NEW_FILE_SLUG}.service.provider.ts" \
                    "$OLD_CLASS_NAME" "$NEW_CLASS_NAME" "$OLD_FILE_SLUG" "$NEW_FILE_SLUG"
            fi
            ;;
        "usecase")
            rename_file_and_references \
                "application/usecases/${OLD_FILE_SLUG}.usecase.ts" \
                "application/usecases/${NEW_FILE_SLUG}.usecase.ts" \
                "$OLD_CLASS_NAME" "$NEW_CLASS_NAME" "$OLD_FILE_SLUG" "$NEW_FILE_SLUG"
            
            rename_file_and_references \
                "domain/services/${OLD_FILE_SLUG}.service.ts" \
                "domain/services/${NEW_FILE_SLUG}.service.ts" \
                "$OLD_CLASS_NAME" "$NEW_CLASS_NAME" "$OLD_FILE_SLUG" "$NEW_FILE_SLUG"
            
            rename_file_and_references \
                "infra/providers/${OLD_FILE_SLUG}.usecase.provider.ts" \
                "infra/providers/${NEW_FILE_SLUG}.usecase.provider.ts" \
                "$OLD_CLASS_NAME" "$NEW_CLASS_NAME" "$OLD_FILE_SLUG" "$NEW_FILE_SLUG"
            
            rename_file_and_references \
                "infra/providers/${OLD_FILE_SLUG}.service.provider.ts" \
                "infra/providers/${NEW_FILE_SLUG}.service.provider.ts" \
                "$OLD_CLASS_NAME" "$NEW_CLASS_NAME" "$OLD_FILE_SLUG" "$NEW_FILE_SLUG"
            ;;
        "repository")
            rename_file_and_references \
                "infra/${REPO_DIR}/${OLD_FILE_SLUG}.repository.ts" \
                "infra/${REPO_DIR}/${NEW_FILE_SLUG}.repository.ts" \
                "$OLD_CLASS_NAME" "$NEW_CLASS_NAME" "$OLD_FILE_SLUG" "$NEW_FILE_SLUG"
            
            rename_file_and_references \
                "infra/providers/${OLD_FILE_SLUG}.repository.provider.ts" \
                "infra/providers/${NEW_FILE_SLUG}.repository.provider.ts" \
                "$OLD_CLASS_NAME" "$NEW_CLASS_NAME" "$OLD_FILE_SLUG" "$NEW_FILE_SLUG"
            ;;
        "source")
            rename_file_and_references \
                "infra/sources/${OLD_FILE_SLUG}.source.ts" \
                "infra/sources/${NEW_FILE_SLUG}.source.ts" \
                "$OLD_CLASS_NAME" "$NEW_CLASS_NAME" "$OLD_FILE_SLUG" "$NEW_FILE_SLUG"
            
            rename_file_and_references \
                "infra/providers/${OLD_FILE_SLUG}.source.provider.ts" \
                "infra/providers/${NEW_FILE_SLUG}.source.provider.ts" \
                "$OLD_CLASS_NAME" "$NEW_CLASS_NAME" "$OLD_FILE_SLUG" "$NEW_FILE_SLUG"
            ;;
        "adapter")
            rename_file_and_references \
                "infra/adapters/${OLD_FILE_SLUG}.adapter.ts" \
                "infra/adapters/${NEW_FILE_SLUG}.adapter.ts" \
                "$OLD_CLASS_NAME" "$NEW_CLASS_NAME" "$OLD_FILE_SLUG" "$NEW_FILE_SLUG"
            
            rename_file_and_references \
                "infra/providers/${OLD_FILE_SLUG}.adapter.provider.ts" \
                "infra/providers/${NEW_FILE_SLUG}.adapter.provider.ts" \
                "$OLD_CLASS_NAME" "$NEW_CLASS_NAME" "$OLD_FILE_SLUG" "$NEW_FILE_SLUG"
            ;;
        "controller")
            rename_file_and_references \
                "infra/controllers/${OLD_FILE_SLUG}.controller.ts" \
                "infra/controllers/${NEW_FILE_SLUG}.controller.ts" \
                "$OLD_CLASS_NAME" "$NEW_CLASS_NAME" "$OLD_FILE_SLUG" "$NEW_FILE_SLUG"
            ;;
        "hook")
            rename_file_and_references \
                "application/hooks/${OLD_FILE_SLUG}.hook.ts" \
                "application/hooks/${NEW_FILE_SLUG}.hook.ts" \
                "$OLD_CLASS_NAME" "$NEW_CLASS_NAME" "$OLD_FILE_SLUG" "$NEW_FILE_SLUG"
            ;;
    esac
    
    # Update module file references
    MODULE_FILE=$(find . -name "*.module.ts" -type f)
    if [ -n "$MODULE_FILE" ]; then
        echo "Updating module file: $MODULE_FILE"
        
        # Update import statements
        sed -i "" "s/${OLD_CLASS_NAME}ServiceProvider/${NEW_CLASS_NAME}ServiceProvider/g" "$MODULE_FILE"
        sed -i "" "s/${OLD_CLASS_NAME}UsecaseProvider/${NEW_CLASS_NAME}UsecaseProvider/g" "$MODULE_FILE"
        sed -i "" "s/${OLD_CLASS_NAME}RepositoryProvider/${NEW_CLASS_NAME}RepositoryProvider/g" "$MODULE_FILE"
        sed -i "" "s/${OLD_CLASS_NAME}SourceProvider/${NEW_CLASS_NAME}SourceProvider/g" "$MODULE_FILE"
        sed -i "" "s/${OLD_CLASS_NAME}AdapterProvider/${NEW_CLASS_NAME}AdapterProvider/g" "$MODULE_FILE"
        sed -i "" "s/${OLD_CLASS_NAME}Controller/${NEW_CLASS_NAME}Controller/g" "$MODULE_FILE"
        
        # Update import paths
        sed -i "" "s/${OLD_FILE_SLUG}\.service\.provider/${NEW_FILE_SLUG}.service.provider/g" "$MODULE_FILE"
        sed -i "" "s/${OLD_FILE_SLUG}\.usecase\.provider/${NEW_FILE_SLUG}.usecase.provider/g" "$MODULE_FILE"
        sed -i "" "s/${OLD_FILE_SLUG}\.repository\.provider/${NEW_FILE_SLUG}.repository.provider/g" "$MODULE_FILE"
        sed -i "" "s/${OLD_FILE_SLUG}\.source\.provider/${NEW_FILE_SLUG}.source.provider/g" "$MODULE_FILE"
        sed -i "" "s/${OLD_FILE_SLUG}\.adapter\.provider/${NEW_FILE_SLUG}.adapter.provider/g" "$MODULE_FILE"
        sed -i "" "s/${OLD_FILE_SLUG}\.controller/${NEW_FILE_SLUG}.controller/g" "$MODULE_FILE"
        
        echo "Updated module file references"
    fi
    
    # Update all other files in the module that might reference the old names
    echo "Updating references in other files..."
    find . -name "*.ts" -type f -exec sed -i "" "s/${OLD_CLASS_NAME}Service/${NEW_CLASS_NAME}Service/g" {} \;
    find . -name "*.ts" -type f -exec sed -i "" "s/${OLD_CLASS_NAME}Usecase/${NEW_CLASS_NAME}Usecase/g" {} \;
    find . -name "*.ts" -type f -exec sed -i "" "s/${OLD_CLASS_NAME}Repository/${NEW_CLASS_NAME}Repository/g" {} \;
    find . -name "*.ts" -type f -exec sed -i "" "s/${OLD_CLASS_NAME}Source/${NEW_CLASS_NAME}Source/g" {} \;
    find . -name "*.ts" -type f -exec sed -i "" "s/${OLD_CLASS_NAME}Adapter/${NEW_CLASS_NAME}Adapter/g" {} \;
    find . -name "*.ts" -type f -exec sed -i "" "s/${OLD_CLASS_NAME}Controller/${NEW_CLASS_NAME}Controller/g" {} \;
    find . -name "*.ts" -type f -exec sed -i "" "s/${OLD_CLASS_NAME}Input/${NEW_CLASS_NAME}Input/g" {} \;
    find . -name "*.ts" -type f -exec sed -i "" "s/${OLD_CLASS_NAME}Provider/${NEW_CLASS_NAME}Provider/g" {} \;
    find . -name "*.ts" -type f -exec sed -i "" "s/use${OLD_CLASS_NAME}/use${NEW_CLASS_NAME}/g" {} \;
    find . -name "*.ts" -type f -exec sed -i "" "s/'${OLD_CLASS_NAME}Service'/'${NEW_CLASS_NAME}Service'/g" {} \;
    find . -name "*.ts" -type f -exec sed -i "" "s/'${OLD_CLASS_NAME}Usecase'/'${NEW_CLASS_NAME}Usecase'/g" {} \;
    find . -name "*.ts" -type f -exec sed -i "" "s/'${OLD_CLASS_NAME}Repository'/'${NEW_CLASS_NAME}Repository'/g" {} \;
    find . -name "*.ts" -type f -exec sed -i "" "s/'${OLD_CLASS_NAME}Source'/'${NEW_CLASS_NAME}Source'/g" {} \;
    find . -name "*.ts" -type f -exec sed -i "" "s/'${OLD_CLASS_NAME}Adapter'/'${NEW_CLASS_NAME}Adapter'/g" {} \;
    
    # Return to original directory
    cd "$ORIGINAL_DIR"
    
    echo ""
    echo "Rename completed successfully!"
    echo "Renamed ${OLD_NAME} to ${NEW_NAME} in module ${MODULE_NAME}"
    echo "All files and references have been updated."
    
    exit 0
fi

