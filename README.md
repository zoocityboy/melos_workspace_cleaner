[![Pub Version](https://img.shields.io/pub/v/melos_workspace_cleaner)](https://pub.dev/packages/melos_workspace_cleaner)
[![Pub Likes](https://badgen.net/pub/likes/melos_workspace_cleaner)](https://pub.dev/packages/melos_workspace_cleaner)
[![Pub Points](https://badgen.net/pub/points/melos_workspace_cleaner)](https://pub.dev/packages/melos_workspace_cleaner)
[![Pub Popularity](https://badgen.net/pub/popularity/melos_workspace_cleaner)](https://pub.dev/packages/melos_workspace_cleaner/score)
[![GitHub stars](https://badgen.net/github/stars/Workiva/melos_workspace_cleaner)](https://pub.dev/packages/melos_workspace_cleaner/)

# Melos Workspace Cleaner

---

Melos Workspace Cleaner is a tool designed for cleaning monorepo workspaces built on the [Melos](https://melos.invertase.dev/~melos-latest). 
This tool provides an straightforward solution for maintaining and managing your monorepo project, 
especially when dealing with an extensive codebase or a multi-project environment.

Optimize your development process and enhance code management with 
this workspace cleaning tool, when you switching between branches.

## Features

- [X] Custom pattern definitions using [glob](https://pub.dev/packages/glob) pattern
- [X] Integration option using Melos Hooks
- [X] Simplification of dependency_overrides removal process

## Getting started

```bash
dart pub global activate melos_workspace_cleaner
```

## Usage

```bash
mwc
```

```yaml
# melos.yaml
name: workspace
command:
  clean:
    hooks:
      pre: mwc
  
```

## Additional information

TODO: Tell users more about the package: where to find more information, how to
contribute to the package, how to file issues, what response they can expect
from the package authors, and more.
