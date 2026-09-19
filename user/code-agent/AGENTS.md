## User Preferences
- Always respond in Chinese
- Write code comments and documentation in English
- Don't copy user preferences to project `AGENTS.md`
- Never modify anything out of the project dir; Never install dependencies globally or system-wide.
- Never use trailing spaces in code
- Offensive programming. Reduce unnecessary validations.

## Language Specific
### Rust
- When introducing dependencies, use `cargo add <dep>`. Don't edit `Cargo.toml` directly
- Prefer zero-overhead and functional programming
- Reduce unnecessary allocations and runtime checks. Limit mutability.
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

## Environment & VCS
- You are on `NixOS`. Use nix and `direnv` to configure develop environment.
- When project uses `jj`, decide whether to create a new commit or which existing commit to squash into
- Commit messages should follow [Conventional Commits](https://www.conventionalcommits.org) specification
