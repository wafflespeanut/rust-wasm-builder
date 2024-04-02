# `rust-wasm-builder`: Building Rust Wasm modules using docker

[![Docker pulls](https://img.shields.io/docker/pulls/wafflespeanut/rust-wasm-builder.svg)](https://hub.docker.com/r/wafflespeanut/rust-wasm-builder/)

> **NOTE:** This is inspired and modified from [`ekidd/rust-musl-builder`](https://github.com/emk/rust-musl-builder).

## Building wasm

Let's say you've setup an alias like so:

```
alias rust-wasm-builder='docker run --rm -it -v "$(pwd)":/home/rust/src wafflespeanut/rust-wasm-builder:stable'
```

Now, you can:

 - Use `cargo-generate` to generate a template:
    ```
    rust-wasm-builder cargo generate --git https://github.com/rustwasm/wasm-pack-template
    ```
 - Make changes and use `wasm-pack` to build your node module:
    ```
    rust-wasm-builder wasm-pack build
    ```
 - And finally, use `wasm-opt` to [shrink the size of your wasm module](https://rustwasm.github.io/docs/book/reference/code-size.html) (aggressively, in this case):
    ```
    rust-wasm-builder wasm-opt -Oz -o stripped.wasm input.wasm
    ```

> All executables from [binaryen](https://github.com/WebAssembly/binaryen) are also available in `$PATH`.

## Available tags

Currently, the following tags are supported and are built everyday:

 - `stable` (also `latest`)
 - `beta`
 - `nightly`
