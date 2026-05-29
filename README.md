# fzaudio

`fzaudio` is an audio plugin build and release system built in Fzy.

It is designed for the painful part of plugin shipping rather than DSP authoring: build orchestration, artifact discovery, signing, notarization, packaging, and release reporting for existing native plugin projects.

## Current shape

- CMake-backed audio plugin projects are supported today.
- The release pipeline can build, validate, sign, package, and summarize `vst3`, `au`, and `clap` fixture outputs.
- Machine-readable JSON is available for all major commands.
- Release outputs include bundle manifests, archive metadata, and archive checksums.

## Commands

```text
fzaudio init
fzaudio doctor
fzaudio inspect
fzaudio build
fzaudio validate
fzaudio sign
fzaudio package
fzaudio release
fzaudio clean
```

The main path is:

```bash
fzaudio release --project /path/to/plugin --config /path/to/fzaudio.toml
```

## Config

Example:

```toml
[plugin]
name = "ExamplePlugin"
vendor = "ExampleVendor"
version = "0.1.0"
formats = ["vst3", "au", "clap"]

[project]
type = "cmake"
path = "."

[build]
config = "release"
universal_macos = true

[signing.macos]
enabled = false
notarize = false
team_id = ""
developer_id_application = ""
notarytool_profile = ""

[package]
output = "dist"
```

## Release outputs

A successful release writes a deterministic output layout under the configured `dist/` directory, including:

- `release.manifest.json`
- `release.summary.json`
- `bundle-layout.json`
- `checksums.txt`
- staged plugin artifacts
- packaged zip archives

## Development

Build and run locally:

```bash
cargo run -q -p fz -- check /Users/deepsaint/Desktop/fzaudio --json
cargo run -q -p fz -- build /Users/deepsaint/Desktop/fzaudio --backend cranelift --json
/Users/deepsaint/Desktop/fzaudio/.fz/build/fzaudio release --project /Users/deepsaint/Desktop/fzaudio/fixtures/cmake-plugin --config /Users/deepsaint/Desktop/fzaudio/fixtures/cmake-plugin/fzaudio.signed.toml --json
```

The fixture project under `fixtures/cmake-plugin` is the current production-style validation target.

## Notes

- This repo is intentionally focused on audio plugin release workflows, not on becoming a general build system.
- `PLAN.md` captures the broader product direction and roadmap.
