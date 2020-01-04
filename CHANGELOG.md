## [1.1]
### Added
- Added Update() for auto-update

## [1.2]
### Added
- extra flag or option `-a` to use __aapt2__ instead of __aapt__.
- Issue template
### Changed
- use getopts for parameters handling
### Fixed
- fix update()

## [1.3]
### Added
- add aapt2 to bind()
### Fixed
- set `LD_LIBRARY_PATH` to avoid libraries access from termux i.e `$PREFIX/lib`

## [1.4]
### Added
- patched binaries of aapt2 to skip invalid names while recompiling
### Fixed
- fixes #10

## [1.5]
### Changed
- stick to alpine v3.10.2 instead of latest one

## [1.6]
### Added
- custom path of framework directory
- new flag `-V` to enable verbose mode for decompiling & recompiling only
### Changed
- update apktool to 2.4.1 
- remove framework app __1.apk__ after each decompiling

## [1.7]
### Added
- new option `--no-res` to decompile app except resources.
- new option `--no-smali` to prevent disassembly of the dex file(s)
