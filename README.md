<p align='center'><b>Symbolicator</b></p>
<p align='center'>Convert numeric addresses to symbols with callStackSymbols and dSYM files.</p>

## Installation

Supports Swift Package Manager.

## Dependent libraries

- [CallStackSymbols](https://github.com/naru-jpn/CallStackSymbols)

## Usage

### Create Symbolicator

```swift
let path: String = {path_of_dsyms_directory_on_your_mac}
let symbolicator = try Symbolicator(dSYMsDirectoryPath: path)
```

### Prepare records from device architecture and call stack as dladdr array

```swift
let architecture: String = {arm64_or_arm64e}
let callStack: Record<DLADDR> = ...
let Record(architecture: architecture, callStack: callStack)
```

See also [example project](https://github.com/naru-jpn/Symbolicator/tree/main/Example). Records is created in [CSVParser.swift](https://github.com/naru-jpn/Symbolicator/blob/main/Example/Example/CSV/CSVParser.swift).

### Symbolicate records

```swift
let result: [Record<SymbolicatedDLADDR>] = symbolicator.symbolicate(records: records)
```

### Aggregate records (Sum up same kind crashes and sort)

```swift
let aggregated: [(count: Int, callStack: String)] = result.aggregate()
```

## Example Project

<kbd><img width="500" alt="Example" src="https://user-images.githubusercontent.com/5572875/133911911-1ad7a087-910e-4ae1-ad72-65bfe2b81804.gif">
</kbd>

- Drag & Drop appDsyms directory and csv file describing crash call stack.
- Sample csv file and appDsyms is in `Assets` at Releases of this repository.
