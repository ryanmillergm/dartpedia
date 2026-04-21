# dartpedia

`dartpedia` is a Dart workspace for exploring Wikipedia from the command line.

The repo is split into three packages:

- `cli`: the runnable command-line application
- `wikipedia`: a small Wikipedia API client plus response models
- `command_runner`: a lightweight command parser and dispatch layer used by the CLI

## Workspace Layout

```text
dartpedia/
├── cli/
├── command_runner/
├── wikipedia/
└── pubspec.yaml
```

High-level flow:

1. `cli/bin/cli.dart` starts the app and registers commands.
2. `command_runner` parses user input into a command, argument, and options.
3. CLI commands call the `wikipedia` package to fetch data from Wikipedia.
4. Errors are logged to files under `cli/logs/`.

## Requirements

- Dart SDK `^3.11.4`
- Internet access for Wikipedia-backed commands such as `search` and `article`

## Setup

This repo uses a Dart workspace at the root:

```yaml
workspace:
  - cli
  - command_runner
  - wikipedia
```

Install dependencies before running commands:

```powershell
dart pub get
cd cli
dart pub get
```

The root `dart pub get` installs the dependencies needed for the workspace-level test runner. If you plan to work inside the package folders directly, it is also reasonable to run `dart pub get` in `cli`, `command_runner`, and `wikipedia`.

## Running the CLI

The executable entrypoint is [cli/bin/cli.dart](C:/laragon/www/flutter/dartpedia/cli/bin/cli.dart:1).

From the `cli` directory:

```powershell
dart run bin/cli.dart help
```

Example output:

```text
Usage: dart bin/cli.dart <command> [commandArg?] [...options?]
help:  Prints usage information to the command line.
search:  Search for Wikipedia articles.
article:  Read an article from Wikipedia
```

Useful commands:

```powershell
dart run bin/cli.dart help --verbose
dart run bin/cli.dart search "Dart programming language"
dart run bin/cli.dart search "Dart" --im-feeling-lucky
dart run bin/cli.dart article Cat
dart run bin/cli.dart article
```

## Available Commands

### `help`

Prints general usage information for the CLI.

Examples:

```powershell
dart run bin/cli.dart help
dart run bin/cli.dart help --verbose
dart run bin/cli.dart help --command search
dart run bin/cli.dart help -c article
```

Supported options:

- `--verbose`, `-v`: print each command with its details and options
- `--command`, `-c`: print verbose help for a specific command

### `search <term>`

Searches Wikipedia using the OpenSearch endpoint and prints matching article titles and URLs.

Examples:

```powershell
dart run bin/cli.dart search "Dart"
dart run bin/cli.dart search "Flutter"
```

Supported options:

- `--im-feeling-lucky`: fetch the summary of the top result before listing all results

Behavior notes:

- A nonsense or very narrow search term can return zero results without raising an error.
- A successful search with no matches currently prints `Search results:` and nothing else.

### `article [title]`

Fetches the article extract for a Wikipedia page title and prints the beginning of the article body.

Examples:

```powershell
dart run bin/cli.dart article Cat
dart run bin/cli.dart article Dart_(programming_language)
```

Behavior notes:

- If no title is provided, the command defaults to `cat`.
- The implementation asks Wikipedia for article extracts by title and prints the first returned article.
- Results are best when the provided title is exact or close to Wikipedia's canonical title.

## Logging

The CLI initializes a file logger in [cli/lib/src/logger.dart](C:/laragon/www/flutter/dartpedia/cli/lib/src/logger.dart:1).

Current behavior:

- Logs are written under `cli/logs/`
- The log filename format is `YYYY_M_D_errors.txt`
- The logger is created in [cli/bin/cli.dart](C:/laragon/www/flutter/dartpedia/cli/bin/cli.dart:1)
- The file is created when a log record is actually written

Current log coverage is mostly error-oriented:

- invalid commands and parser failures are logged
- caught exceptions in `search` and `article` are logged
- successful commands do not currently emit much informational logging

Example error run:

```powershell
dart run bin/cli.dart not_a_real_command
```

That should create or append to a file similar to:

```text
cli/logs/2026_4_21_errors.txt
```

## Package Overview

### `cli`

The CLI package wires the application together.

Key pieces:

- [cli/bin/cli.dart](C:/laragon/www/flutter/dartpedia/cli/bin/cli.dart:1): entrypoint
- [cli/lib/src/commands/search.dart](C:/laragon/www/flutter/dartpedia/cli/lib/src/commands/search.dart:1): `search` command
- [cli/lib/src/commands/get_article.dart](C:/laragon/www/flutter/dartpedia/cli/lib/src/commands/get_article.dart:1): `article` command
- [cli/lib/src/logger.dart](C:/laragon/www/flutter/dartpedia/cli/lib/src/logger.dart:1): file logger setup

`cli` depends on the local `command_runner` and `wikipedia` packages through path dependencies.

### `wikipedia`

The `wikipedia` package contains the HTTP layer and response models.

Exported functions:

- `search(String searchTerm)`
- `getArticleByTitle(String title)`
- `getArticleSummaryByTitle(String articleTitle)`
- `getRandomArticleSummary()`

Exported models:

- `SearchResults`
- `Article`
- `Summary`
- `TitlesSet`

Implemented API modules:

- [wikipedia/lib/src/api/search.dart](C:/laragon/www/flutter/dartpedia/wikipedia/lib/src/api/search.dart:1)
- [wikipedia/lib/src/api/get_article.dart](C:/laragon/www/flutter/dartpedia/wikipedia/lib/src/api/get_article.dart:1)
- [wikipedia/lib/src/api/summary.dart](C:/laragon/www/flutter/dartpedia/wikipedia/lib/src/api/summary.dart:1)

Notes:

- search uses `https://en.wikipedia.org/w/api.php?action=opensearch`
- article extract uses `https://en.wikipedia.org/w/api.php?action=query`
- summary uses the REST summary endpoints under `/api/rest_v1/page/...`

### `command_runner`

The `command_runner` package is a small custom command framework.

Core concepts:

- `Argument`: abstract base type for things with names/help/usage
- `Option`: represents a flag or option
- `Command`: abstract base class for executable commands
- `ArgResults`: parsed command, positional arg, and options
- `CommandRunner`: parser and dispatcher
- `HelpCommand`: built-in help command that must be registered manually

Key files:

- [command_runner/lib/src/arguments.dart](C:/laragon/www/flutter/dartpedia/command_runner/lib/src/arguments.dart:1)
- [command_runner/lib/src/command_runner_base.dart](C:/laragon/www/flutter/dartpedia/command_runner/lib/src/command_runner_base.dart:1)
- [command_runner/lib/src/help_command.dart](C:/laragon/www/flutter/dartpedia/command_runner/lib/src/help_command.dart:1)

## Development Notes

### Current test status

Verified from this workspace:

- root workspace: `dart test` passes and runs all package test suites
- `cli`: `dart test` passes
- `command_runner`: `dart test` passes
- `wikipedia`: `dart test` passes

### Commands verified locally

These were verified locally in the current repo state:

- `dart run bin/cli.dart help`
- `dart run bin/cli.dart help --verbose`

The Wikipedia-backed commands are implemented, but they depend on runtime network access to Wikipedia.

## Known Limitations

- `wikipedia/bin/wikipedia.dart` still appears to be scaffold output and is not the main user-facing executable for this project.
- Logging is focused on warnings and failures rather than full request tracing.
- Some package descriptions and package-level READMEs are still template text.

## Suggested Workflow

For normal use:

```powershell
cd cli
dart pub get
dart run bin/cli.dart help
dart run bin/cli.dart search "Dart"
dart run bin/cli.dart article Cat
```

For running all tests at once from the repo root:

```powershell
dart pub get
dart test
```

The root test runner streams each package test suite to the console and prefixes the output with the package name, for example `[cli]`, `[command_runner]`, and `[wikipedia]`.

For package development:

```powershell
cd cli
dart test
```

```powershell
cd command_runner
dart test
```

```powershell
cd wikipedia
dart test
```

## Repository Status

This project is already usable as a CLI prototype for Wikipedia searches and article reads, but it still includes a few tutorial scaffold leftovers. The core command flow and Wikipedia integration are present; the main cleanup items are documentation polish, better success-path logging, and cleaning up remaining scaffold files such as `wikipedia/bin/wikipedia.dart`.
