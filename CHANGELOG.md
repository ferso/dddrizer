# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2024-12-19

### Added
- **Initial project setup** with support for NestJS and React projects
- **`init` command**: Initialize project with type selection (NestJS or React)
  - Creates `.dddrizer.json` configuration file
  - Automatically installs `inversify@7.2.0` for React projects
  - Runs `npm install` automatically after adding dependencies
- **React project support**:
  - Services with Inversify `@injectable()` decorator
  - Repositories in `data/repositories/` directory
  - Sources in `data/sources/` directory
  - Adapters in `data/adapters/` directory
  - Hooks with `useInjection` from Inversify
  - Module bindings using `container.bind()` instead of providers
- **NestJS project support** (maintained):
  - Services with NestJS `@Injectable()` decorator
  - Usecases with proper NestJS structure
  - Repositories in `infra/` directory with providers
  - Controllers (NestJS only)
  - Module providers and exports
- **Project type detection**: Automatically reads project type from `.dddrizer.json`
- **Multi-project code generation**: All commands adapt based on project type
- **Enhanced `copy-service` command**: Works with both NestJS and React projects
  - Automatically converts NestJS imports to Inversify for React projects
- **Comprehensive README**: Documentation with examples for both project types

### Features
- ✅ Project initialization with `dddrizer init`
- ✅ Automatic dependency management for React projects
- ✅ Type-safe code generation based on project type
- ✅ Support for both NestJS and React hexagonal architecture
- ✅ Module structure generation for both project types
- ✅ Service, repository, usecase, source, adapter generation
- ✅ Hook generation (React only)
- ✅ Controller generation (NestJS only)
- ✅ Service copying between modules
- ✅ Component renaming
- ✅ Service removal

### Technical Details
- Configuration file: `.dddrizer.json` with project type
- React projects use Inversify for dependency injection
- NestJS projects use NestJS providers and modules
- Automatic file structure generation based on project type
- Duplicate prevention for imports, providers, and bindings

