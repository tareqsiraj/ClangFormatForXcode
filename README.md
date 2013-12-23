ClangFormatForXcode
===================

Xcode 5 plugin for [clang-format](http://clang.llvm.org/docs/ClangFormat.html).

**Disclaimer**: This is a work in progress, use at your own risk.

**Installation**:

1. Install clang-format (if you don't have it already)  
  1.1 If you have [homebrew](http://brew.sh/), use the command `brew install llvm35 --HEAD --with-clang`. You can replace llvm35 with whatever version that is recent. Note that HEAD only builds are not linked in `/usr/local/bin` in homebrew thus you will need to create a symlink in your `~/bin` directory. You can use the command line: ``ln -s `brew info llvm35 | grep Cellar | awk '{print $1;}'`/bin/clang-format-3.5 ~/bin/clang-format``.  
  1.2 Alternatively you can build clang-format from souce. Follow the [official documentation](http://clang.llvm.org/get_started.html) to checkout llvm and clang and use the build target `clang-format`. After building, create a symlink to your `~/bin` directory e.g. `ln -s path/to/build/bin/clang-format ~/bin/clang-format`.
2. In case you have clang-format installed and decided not to create a symlink in `~/bin`, change the path to clang-format in `PluginPreferences.m`. Right now it defaults to `~/bin/clang-format`.
3. Build the project. This will automatically install the plugin in `~/Library/Application Support/Developer/Shared/Xcode/Plug-ins`.
4. Restart Xcode.

**Usage**: After successfully installing the plugin, you should see a new `Clang Format` menu under the `Edit` menu in Xcode. Simply select the line(s) in your source window and click on `Clang Format`->`Format Selected Text`. Alternatively you can use the keyboard shortcut <kbd>⌘</kbd>+<kbd>⇧</kbd>+<kbd>X</kbd> to have the same effect.

Users can select between built-in styles from `Clang Format`->`Format Style` menu. Note that the selection is global for all projects.

**Status**: alpha quality.
