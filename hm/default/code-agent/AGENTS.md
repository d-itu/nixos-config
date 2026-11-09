## User Preferences
- Respond in Chinese.
- Write code comments and documentation in English.
- Don't edit project `AGENTS.md` if not required.
- Never modify anything out of the project directory.
- Never install dependencies globally or system-wide.

## Language Specific
### Rust
- When introducing dependencies, use `cargo add`. Don't edit `Cargo.toml` directly.
1. Don't use paths begin with `std::` or `core::`. Always import them. E.g.
    ```rust
        use std::io;

        enum Error {
            Io(io::Error);
        }
    ```
- Use `tombi` to lint and format `toml` files.

### Nix
- Use `nixfmt` to format nix files.

### Python
- Use `ruff` to format and `ruff check` `ty check` to lint.

## Version Control
- Use `jj` command if project directory contains `.jj`.
- Prefer `jj` for new projects.
- Commit messages should follow [Conventional Commits](https://www.conventionalcommits.org) specification.

## CI
- Never generate hash in GitHub Actions build.
- Do not compress output if it contains only 1 file.
