ClangFormatForXcode
===================

Xcode 5 plugin for clang-format.

**Disclaimer**: This is a work in progress, use at your own risk.

**Installation**:

* Change the path to clang-format in `ClangFormatPlugin.m` (in the top portion of the file).
* Build the project. This will automatically install the plugin in `~/Library/Application Support/Developer/Shared/Xcode/Plug-ins`.
* Restart Xcode.

**Usage**: After successfully installing the plugin, you should see a new `Clang Format` menu under the `Edit` menu in Xcode. Simply select the line(s) in your source window and click on `Clang Format`->`Format Selected Text`. Alternatively you can use the keyboard shortcut <kbd>⌘</kbd> +<kbd>⇧</kbd> +<kbd>X</kbd> to have the same effect.

**Status**: alpha quality.