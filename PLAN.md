# fzaudio Plan

## Product Thesis

- [ ] Build `fzaudio` as a language-agnostic audio plugin build and release system implemented in Fzy.
- [ ] Keep the product identity focused on shipping release-ready native audio plugin artifacts, not on being a general build system.
- [ ] Optimize for the painful release layer: build orchestration, bundle correctness, signing, notarization, validation, packaging, and CI outputs.
- [ ] Position the tool as release infrastructure for plugin teams using existing frameworks and toolchains.

## Core Promise

- [ ] One clean workflow to build, sign, validate, and package audio plugins for release.
- [ ] Great diagnostics for the failures teams actually hit in production.
- [ ] Deterministic, machine-readable outputs for local use and CI use.
- [ ] Support existing plugin codebases without forcing users onto a new DSP framework.

## Product Scope

### In Scope

- [ ] Audio plugin release workflows.
- [ ] Existing JUCE and CMake-based plugin projects first.
- [ ] Artifact assembly and release packaging.
- [ ] Plugin bundle verification and release validation.
- [ ] Environment inspection and setup diagnostics.
- [ ] CI-friendly commands and JSON output.

### Out Of Scope

- [ ] Building a new plugin SDK.
- [ ] Replacing JUCE, iPlug2, CMake, Xcode, Visual Studio, or DAW tooling.
- [ ] Becoming a generic build system for all native software.
- [ ] Becoming a linker.
- [ ] Owning DSP authoring or plugin UI authoring.

## First Niche

- [ ] Start with audio plugins rather than a generic native builder.
- [ ] Prioritize workflows where post-build and distribution pain is highest.
- [ ] Treat audio as the proving ground for a future artifact-builder platform.

## Primary Users

- [ ] Indie audio plugin developers shipping one or more plugins.
- [ ] Small plugin companies with painful release processes.
- [ ] DSP teams maintaining cross-platform plugin SKUs.
- [ ] Teams with working build systems but fragile release pipelines.

## MVP Formats

- [ ] Support `vst3` in v1.
- [ ] Support `au` on macOS in v1.
- [ ] Evaluate `clap` early and include if implementation complexity stays reasonable.
- [ ] Defer legacy formats unless a clear customer pull emerges.

## MVP Platforms

- [ ] macOS first.
- [ ] Windows second.
- [ ] Linux third.
- [ ] Design the product model so cross-platform expansion does not require a rewrite.

## Inputs

- [ ] Existing JUCE project roots.
- [ ] Existing CMake-based plugin project roots.
- [ ] Config file describing plugin metadata, target formats, build settings, signing settings, and packaging policy.
- [ ] Optional per-machine secrets/config for signing and notarization credentials.

## Outputs

- [ ] Release-ready plugin bundles.
- [ ] Signed artifacts where configured.
- [ ] Notarized macOS artifacts where configured.
- [ ] Packaged distribution outputs in a deterministic `dist/` layout.
- [ ] Validation reports.
- [ ] Machine-readable release manifest.
- [ ] Structured JSON logs and summary result files.

## UX Principles

- [ ] Default to one obvious release path.
- [ ] Keep the config file small, explicit, and production-oriented.
- [ ] Make diagnostics actionable, not vague.
- [ ] Distinguish environment/setup errors from project errors from artifact validation failures.
- [ ] Prefer stable subcommands over magical hidden behavior.
- [ ] Treat `doctor` as a first-class feature, not an afterthought.
- [ ] Make CI and local usage equally good.
- [ ] Preserve deterministic artifact layout and stable JSON schemas.
- [ ] Never hide signing/notarization side effects from the user.
- [ ] Make dry-run and explain modes easy to use.

## CLI Surface

- [ ] `fzaudio init`
- [ ] `fzaudio doctor`
- [ ] `fzaudio inspect`
- [ ] `fzaudio build`
- [ ] `fzaudio validate`
- [ ] `fzaudio sign`
- [ ] `fzaudio package`
- [ ] `fzaudio release`
- [ ] `fzaudio clean`

### Command Semantics

- [ ] `init` should scaffold a minimal config for an existing plugin project.
- [ ] `doctor` should verify toolchains, signing identities, notarization prerequisites, and supported project layout.
- [ ] `inspect` should detect project type, targets, formats, and inferred release risks.
- [ ] `build` should orchestrate framework-native build steps and normalize outputs.
- [ ] `validate` should verify bundle structure, metadata, format-specific expectations, and host/plugin validation hooks where available.
- [ ] `sign` should perform platform signing steps with precise status reporting.
- [ ] `package` should create release archives/installers/layouts.
- [ ] `release` should compose build + validate + sign + package and emit a final manifest.
- [ ] `clean` should remove tool-generated artifacts only.

## Config Design

- [ ] Use a small declarative config file, likely `fzaudio.toml`.
- [ ] Include plugin metadata: name, vendor, version, formats.
- [ ] Include project adapter metadata: type, path, build entrypoint.
- [ ] Include platform build settings: config, arch policy, universal binary flags.
- [ ] Include signing and notarization config.
- [ ] Include packaging output config.
- [ ] Include validation policy toggles.
- [ ] Include CI/reporting options.

## Internal Architecture

### Top-Level Modules

- [ ] `cli`
- [ ] `model`
- [ ] `services`
- [ ] `runtime`
- [ ] `tests`
- [ ] `util`

### Core Domain Areas

- [ ] Config loading and validation.
- [ ] Project adapters for JUCE and generic CMake.
- [ ] Process orchestration for native tool invocations.
- [ ] Filesystem/path handling for artifact discovery and output normalization.
- [ ] Artifact model for built bundles and release packages.
- [ ] Validation engine for structure and policy checks.
- [ ] Signing/notarization workflows.
- [ ] Reporting/logging/manifest generation.

## Project Adapters

- [ ] JUCE adapter for common project layouts and exporter/build flows.
- [ ] CMake adapter for generic plugin projects.
- [ ] Adapter contract should normalize source project differences into one internal artifact model.
- [ ] Keep the adapter model extensible for future iPlug2 or custom recipes.

## Validation Surface

- [ ] Verify expected plugin output exists for each requested format.
- [ ] Verify bundle/layout correctness.
- [ ] Verify required metadata and version fields.
- [ ] Verify architecture expectations on macOS universal outputs.
- [ ] Verify signing state when signing is required.
- [ ] Verify notarization results when notarization is enabled.
- [ ] Verify package completeness before declaring release success.
- [ ] Add hooks for host/plugin validation commands where feasible.

## Signing And Notarization

- [ ] macOS signing support is a first-class workflow.
- [ ] Notarization support should be built into the release pipeline, not left to user scripts.
- [ ] Signing credentials should be configured clearly and validated with `doctor`.
- [ ] Failure output should identify whether the issue is identity lookup, entitlements, notarization submission, or staple/finalization.

## Packaging

- [ ] Create deterministic `dist/` outputs.
- [ ] Produce stable archive naming.
- [ ] Emit release manifest with artifact metadata, hashes, platform info, and validation/signing status.
- [ ] Keep package layouts predictable enough for CI publishing and support debugging.

## Reporting

- [ ] Human-readable logs by default.
- [ ] `--json` output for every important command.
- [ ] Stable result schema for CI integrations.
- [ ] Preserve enough structure to separate warnings from blockers.
- [ ] Include artifact paths in final summaries.

## Fzy Implementation Constraints

- [ ] Implement the product idiomatically in Fzy using the production-native standard library surface.
- [ ] Prefer structured process APIs over shell-string hacks.
- [ ] Prefer explicit filesystem and path helpers over ad hoc string operations.
- [ ] Keep runtime services small and composable.
- [ ] Keep control flow explicit and operationally legible.
- [ ] Write the tool as serious production software, not as a toy showcase.

## Testing Strategy

- [ ] Build deterministic scenario coverage with Fozzy from the start.
- [ ] Add CLI surface tests for command dispatch and JSON output.
- [ ] Add adapter tests for JUCE/CMake detection and normalization.
- [ ] Add artifact layout validation tests.
- [ ] Add signing/notarization failure classification tests where possible.
- [ ] Add host-backed integration tests where feasible.
- [ ] Record and verify at least one real trace for release workflows.

## Early Milestones

### Milestone 1: Foundation

- [ ] Create project skeleton.
- [ ] Implement config model and CLI entry.
- [ ] Implement logging and report scaffolding.
- [ ] Implement `doctor`.
- [ ] Implement `inspect`.

### Milestone 2: Build Core

- [ ] Implement JUCE adapter.
- [ ] Implement CMake adapter.
- [ ] Implement `build`.
- [ ] Normalize artifact discovery and output model.

### Milestone 3: Validation And Packaging

- [ ] Implement `validate`.
- [ ] Implement `package`.
- [ ] Emit release manifests.

### Milestone 4: macOS Release Workflow

- [ ] Implement signing support.
- [ ] Implement notarization support.
- [ ] Implement full `release`.

### Milestone 5: CI And Production Hardening

- [ ] Add deterministic Fozzy coverage.
- [ ] Add host-backed release checks.
- [ ] Harden diagnostics and output schemas.
- [ ] Document operational workflow.

## Success Criteria

- [ ] A JUCE plugin project can be turned into a signed, validated macOS release artifact with one top-level command.
- [ ] The output folder and manifest are deterministic and CI-friendly.
- [ ] Failures point clearly to setup, build, signing, validation, or packaging stages.
- [ ] The product is clearly better than glueing together CMake, IDE exporters, post-build scripts, and manual signing steps by hand.
