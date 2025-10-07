# Repository Guidelines

## Project Structure & Module Organization
- Solution: `Hirebot-TFI.sln` orchestrates six layers: `Hirebot-TFI/Hirebot-TFI` (Web Forms UI), `Security`, `BLL`, `DAL`, `ABSTRACTIONS`, and `SERVICES`.
- UI assets: styles in `Hirebot-TFI/Content/`, scripts in `Hirebot-TFI/Scripts/`, localization in `Hirebot-TFI/App_GlobalResources/GlobalResources*.resx`.
- Contracts/DTOs live in `ABSTRACTIONS`; business rules in `BLL`; stored‑procedure gateways in `DAL`; cross‑cutting/auth in `Security`; service wrappers in `SERVICES`.
- Call flow: UI → Security → BLL → DAL. Never embed SQL outside `DAL` or skip a layer hop.

## Build, Test, and Development Commands
- Restore packages: `nuget restore Hirebot-TFI.sln`.
- Build (Debug/Release): `cmd.exe /c "\"C:\Program Files\Microsoft Visual Studio\2022\Community\MSBuild\Current\Bin\MSBuild.exe\" Hirebot-TFI.sln /p:Configuration=Debug /verbosity:minimal"` (swap `Release` for deploy builds).
- Clean + Rebuild (refresh designers/resources): `cmd.exe /c "\"C:\Program Files\Microsoft Visual Studio\2022\Community\MSBuild\Current\Bin\MSBuild.exe\" Hirebot-TFI.sln /t:Clean,Rebuild /verbosity:minimal"`.
- Run locally (IIS Express): press F5 in Visual Studio → `https://localhost:44383/`.

## Coding Style & Naming Conventions
- Indentation: 4 spaces. Namespace files under `Hirebot_TFI.<Layer>`.
- Naming: PascalCase for classes/methods; camelCase for locals/parameters.
- Suffixes: use `Service`/`Repository` only in matching layers.
- UI strings: externalize to resource files (`GlobalResources*.resx`).
- Credentials: always call `EncryptionService.EncryptPassword` before storage/transport.

## Testing Guidelines
- Automated suites are not yet committed. When adding tests, create MSTest or NUnit projects beside the target layer and add them to the solution.
- Test names: `MethodUnderTest_Scenario_Expectation`.
- Build tests with the same `msbuild` commands as the app; document bilingual manual passes until automation is in place.

## Commit & Pull Request Guidelines
- Commits: short, present tense, and layer‑scoped when relevant (e.g., `BLL: enforce comment limits`).
- PRs: state scope, confirm architectural compliance (UI → Security → BLL → DAL), list manual test notes, and attach UI screenshots or SQL diffs as needed.
- Link tracking issues and call out any schema or stored‑procedure updates with matching `DAL` parameter changes.

## Security & Configuration Tips
- Keep secrets out of `web.config`; prefer user secrets or `Web.Debug.config`/`Web.Release.config` transforms.
- Align stored‑procedure changes with `DAL` parameters and refresh scripts under `Database/`.
- Build `Release` before deploying to ensure debug‑only assets remain local.

