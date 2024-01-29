![alt text](https://raw.githubusercontent.com/zoocityboy/melos_workspace_cleaner/main/assets/workspace_cleaner.webp "Resoure")

[![Pub](https://img.shields.io/pub/v/mwc.svg)](https://pub.dev/packages/mwc)
[![ci](https://github.com/zoocityboy/melos_workspace_cleaner/actions/workflows/dart.yaml/badge.svg)](https://github.com/zoocityboy/melos_workspace_cleaner/actions)
[![coverage](https://raw.githubusercontent.com/zoocityboy/melos_workspace_cleaner/main/coverage_badge.svg)](https://github.com/zoocityboy/melos_workspace_cleaner/actions)
[![License: MIT](https://img.shields.io/badge/license-MIT-purple.svg)](https://opensource.org/licenses/MIT)

# Melos Workspace Cleaner

Melos Workspace Cleaner is a tool designed for cleaning monorepo workspaces built on the [Melos](https://melos.invertase.dev/~melos-latest).
This tool provides an straightforward solution for maintaining and managing your monorepo project,
especially when dealing with an extensive codebase or a multi-project environment.

Optimize your development process and enhance code management with
this workspace cleaning tool, when you switching between branches.

## Features

- [X] Custom pattern definitions using [glob](https://pub.dev/packages/glob) pattern
- [X] Integration option using Melos Hooks
- [X] Simplification of removal process of dependency_overrides, pubspec.lock and others.

## 🚀  Getting started

### Installation

```bash
dart pub global activate mwc
```

## Usage

```bash
# run command from terminal in root of the project
mwc
```

```yaml
# melos.yaml
name: workspace
command:
  clean:
    hooks:
      pre: mwc --patterns "**/pubspec.lock,**/pubspec_overrides.yaml"
```

## Configuration

By default, the tool will look for `mwc.yaml` file in the root of your project.
You can also specify the path to the configuration file using the `--patterns` option.

**priorities**:
1. nwc.yaml
2. melos.yaml
3. --patterns [string]
4. default values [**/pubspec.lock, **/pubspec_overrides.yaml]


### mwc.yaml

you can specify the patterns to be cleaned in the `mwc.yaml` file. The patterns are defined using [glob](https://pub.dev/packages/glob) pattern.
`mwc.yaml` file should be placed in the root of your project like `melos.yaml`.

```yaml
# mwc.yaml
- **/pubspec.lock
- **/pubspec_overrides.yaml
...   
```

### melos.yaml 

You can also specify the patterns to be cleaned in the `melos.yaml` file. The patterns are defined using [glob](https://pub.dev/packages/glob) pattern.
`melos.yaml` file should be placed in the root of your project like `mwc.yaml`.

```yaml
# melos.yaml
name: workspace
command:
  clean:
    hooks:
      pre: mwc

# optional configuration in `melos.yaml`
mwc:
  - **/pubspec.lock
  - **/pubspec_overrides.yaml
  ...  
```

