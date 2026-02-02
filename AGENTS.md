# Repository Guidelines

## Project Structure & Module Organization
- `specs/`: Primary documentation for this repository.
  - `specs/business_specs.md`: Product and business requirements.
  - `specs/technical_specs.md`: Technical requirements and implementation notes.
- `mobile/learny_app/`: Flutter mobile application (screens + navigation scaffolding).

No application source code, tests, or assets are currently present. If new code is added, keep it organized under a clear top-level folder (for example, `src/`, `tests/`, `assets/`) and update this document accordingly.

## Build, Test, and Development Commands
- Flutter app (from repo root):
  - Run app: `cd mobile/learny_app && flutter run`
  - Fetch dependencies: `cd mobile/learny_app && flutter pub get`
  - Run tests: `cd mobile/learny_app && flutter test`

## Coding Style & Naming Conventions
No coding standards are defined yet. If you add code:
- Prefer consistent indentation (2 or 4 spaces) and document which you choose.
- Follow language-idiomatic naming (for example, `camelCase` for JS/TS, `snake_case` for Python).
- Add a formatter/linter and record the commands (for example, `npm run lint`, `ruff check .`).

## Testing Guidelines
No testing framework or coverage targets are defined. If tests are added:
- Place them in a dedicated folder (for example, `tests/` or alongside modules).
- Use descriptive naming (for example, `module_name.test.ext`).
- Document how to run the test suite from the repo root.

## Commit & Pull Request Guidelines
No commit message conventions or PR templates are present in this repository. Until guidelines are established:
- Use concise, imperative commit messages (for example, “Add technical specification draft”).
- Provide PR descriptions that summarize changes, reference related issues, and include relevant screenshots or logs when applicable.

## Agent-Specific Instructions
This repository currently centers on specifications. When implementing features, align changes with:
- `specs/business_specs.md` for product intent.
- `specs/technical_specs.md` for architecture and technical constraints.
