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
