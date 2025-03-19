# Solidity @ Bridge

## Overview

This is a template for Solidity development with [Forge](https://github.com/foundry-rs/foundry).

It includes
- Recommended VSCode extensions for Solidity development
- Recommended Solidity extension settings
- CI for `forge fmt` and `forge test`
  - Standardized `forge fmt` formatter settings
- Optional CI for HardHat tests if it detects a `package.json
- [Soldeer](https://github.com/mario-eth/soldeer) for dependency management
- `.cursor/rules` for advice to help [Cursor](https://www.cursor.com/) write better Solidity

## Usage

This assumes you have already installed Foundry: `curl -L https://foundry.paradigm.xyz | bash && foundryup`

- Initialize a new project with this template: `forge init <project> --template withbridge/bridge-forge-template`
- Install dependencies with `soldeer`: `forge soldeer install`
- Install additional dependencies from the [Soldeer registry](https://soldeer.xyz): `forge soldeer install @openzeppelin-contracts-upgradeable~5.2.0`
- Update remappings in `foundry.toml` as needed, eg 
```toml
[profile.default]
...
remappings = [
    "forge-std/=dependencies/forge-std-1.9.6/src/",
    "@openzeppelin-contracts-upgradeable/=dependencies/@openzeppelin-contracts-upgradeable-5.2.0/",
]
```
- Build, run, etc, with `forge build`, `forge test`, etc

## Philosophy

- Prefer `forge` over `hardhat` (when possible)
- Prefer `foundry.toml` over `remappings.txt`
- Prefer `soldeer` over `.gitmodules` and `node_modules`
- Prefer upgrade-safe [EIP-7201: Namespaced Storage Layout](https://eips.ethereum.org/EIPS/eip-7201) over standard storage variables
- Extensions (included in `.vscode/extensions.json`):
    - [Nomic Solidity](https://marketplace.cursorapi.com/items?itemName=NomicFoundation.hardhat-solidity)
    - [Solidity Visual Developer](https://marketplace.cursorapi.com/items?itemName=tintinweb.solidity-visual-auditor)


Included also are [solidity.mdc](.cursor/rules/solidity.mdc) and [solidity-test.mdc](.cursor/rules/solidity-test.mdc) with human-readable advice to help [Cursor](https://www.cursor.com/) write better Solidity.
