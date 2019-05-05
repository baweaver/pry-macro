# Changelog

## v 2.0.0

API changes:
1. change macro names to `macro-start`, `macro-stop`, `macro-save`, more easy to remember.
2. Remove highline dependency, don't ask macro name when run `macro-stop`, instead, need provide macro name when run `macro-start`
3. `macro-save` save macro to ~/.pry-macro instead of ~/.pryrc, still will autoload all macros too.
4. when recording macro, will skip `edit` command, this will permit you use your favorited editor to edit macro!

Bugfix:
1. Fix for work with newest Pry.

## v 1.0.1 - Bug fix

Removed dependency on pry-plus

## v 1.0.0

Changed names to prevent collisions:

* record -> record-macro
* stop -> stop-macro

No more name changes to core methods.

## v 0.0.3

Variable fix: @name -> name

## v 0.0.2

Changed name: save -> save-macro

Added options

* stop
  * n / name - name of macro
  * d / desc - description of macro
  * v - verbose, output macro text

## v 0.0.1

Initial release
