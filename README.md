# Cross-platform build tools for GNUstep

This repository contains [vcpkg](https://vcpkg.io/) support for building [GNUstep](https://gnustep.github.io/)
on Windows and Linux.

It contains:
- [vcpkg ports](https://learn.microsoft.com/en-us/vcpkg/concepts/ports) for building [libobjc2](https://github.com/gnustep/libobjc2), [libdispatch](https://github.com/apple/swift-corelibs-libdispatch/), [gnustep-make](https://github.com/gnustep/tools-make), [gnustep-base](https://github.com/gnustep/libs-base), [gnustep-gui](https://github.com/gnustep/libs-gui), [gnustep-back](https://github.com/gnustep/libs-back) and selected dependencies
- [vcpkg triplets](https://learn.microsoft.com/en-us/vcpkg/concepts/triplets), `x64-windows-llvm` and `x64-linux-llvm` for building using clang on Windows and Linux
- A [CMake package](https://cmake.org/cmake/help/latest/manual/cmake-packages.7.html), gnustep, which allows applications to link with libobjc2, gnustep-base and gnustep-gui using [CMake import libraries](https://cmake.org/cmake/help/latest/guide/importing-exporting/index.html).
- A tutorial application which shows how you can use vcpkg, CMake, VS Code, CodeLLDB and clangd to get a rich Objective C editing experience on Windows

On Windows, this repository takes the approach of building GNUstep using the Windows-native LLVM (clang) compiler.
While it uses MSYS2 to get a Bash shell, which allows running the scripts required to configure and build GNUstep,
it does not use the MSYS2 compiler toolchain.

## Getting started on Windows

On Windows, you'll need to download the Windows SDK and the LLVM toolchain.  Optionally, you can use Visual Studio Code
as an editor and Git for source code interations.

- [Visual Studio 2022 Build Tools (Windows SDK)](https://visualstudio.microsoft.com/downloads/)
- [LLVM](https://releases.llvm.org/download.html)
- [Git for Windows](https://git-scm.com/download/win)

You'll need a version of LLVM which includes [support for referencing instance variables which are in an external module](https://github.com/llvm/llvm-project/commit/7c25ae87f7378f38aa49a92b9cf8092deb95a1f4).  In practice, that means LLVM 20.0 or later, which you can download at https://releases.llvm.org/.

To get started, run the following commands:

```pwsh
git clone https://github.com/qmfrederik/vcpkg-gnustep
cd vcpkg-gnustep
git clone https://github.com/microsoft/vcpkg/
./vcpkg/bootstrap-vcpkg.bat
./vcpkg/vcpkg install gnustep-gui:x64-windows-llvm --overlay-ports=ports --overlay-triplets=triplets
```

This will configure GNUstep gui and all of its dependencies.  You can then find the binaries, link libraries and headers
in `./vcpkg/installed/x64-windows-llvm`.

## Building your Objective C application on Windows

To build an Objective C application on Windows (and Linux), you'll need [Visual Studio Code](https://code.visualstudio.com/Download).
For the best support, install the [CMake](https://github.com/microsoft/vscode-cmake-tools), [CodeLLDB](https://github.com/vadimcn/codelldb/)
and [clangd](https://github.com/clangd/vscode-clangd) extensions.

The easiest way to explore Objective C code editing on Windows and Linux is to open the tutorial folder in VS Code.  It is pre-configured and
includes code editing and debugging support.

![Objective C code editing in VS Code, on Windows](images/vscode-editor-support.png)

![Objective C code debugging in VS Code, on Windows](images/vscode-debugger-support.png)

To build your own application, create a CMake project and pass the following configuration parameters when configuring your project.
[CMake presets](https://cmake.org/cmake/help/latest/manual/cmake-presets.7.html) are a great way to store this configuration.

| CMake variable                   | Description                               | Example 
|----------------------------------|-------------------------------------------|---------------------------
| `CMAKE_TOOLCHAIN_FILE`           | Set to the [vcpkg toolchain file](https://learn.microsoft.com/en-us/vcpkg/users/buildsystems/cmake-integration)  | `vcpkg/scripts/buildsystems/vcpkg.cmake`
| `VCPKG_CHAINLOAD_TOOLCHAIN_FILE` | Set to your platform-specific toolchain file, forcing the use of Clang as the compiler | `../triplets/toolchains/x64-windows-llvm.toolchain.cmake`
| `VCPKG_TARGET_TRIPLET`           | Set to the platform-specific triplet      | `x64-windows-llvm`
| `CMAKE_EXPORT_COMPILE_COMMANDS`  | Causes CMake to generate a [JSON Compilation Database](https://clang.llvm.org/docs/JSONCompilationDatabase.html), enabling [clangd](https://clangd.llvm.org/) | `ON`

Then, open VS Code and configure the CMake integration in VS Code.  Clangd should automatically pick up your compiler settings and start
providing editor support.

To debug your application, create a `launch.json` file which uses the `lldb` debugger.  Then, you can launch and debug your application:

### Automatic Updates with Renovate

This repository uses Renovate to automatically check for dependency updates. The configuraiton can be found in `renovate.json`.  Roughly, the `customManagers` section allows Renovate to identify which packages are being used in this project.  The `packageRules` section defines how to get the latest version information from the upstream systems, such as GitHub.

Pay special attention to the `version` regular expressions, as they need to match both the version number as it appears in `vcpkg.json` and the tag used by the equivalent GitHub release.  These can vary wildly, here are a couple of examples:

| Package      | `vcpkg.json` | GitHub release tag  | regex
|--------------|--------------|---------------------|---------
| gnustep-base | `1.31.1`     | `base-1_31_1`       | `^(Release |\w*-|v)?(?<major>\d+)[\._](?<minor>\d+)([\._](?<patch>\d+))?$`
| libdispatch  | `6.1`        | `swift-6.1-RELEASE` | `^(swift-)?(?<major>\d+).(?<minor>\d+)(.(?<patch>\d+))?(-RELEASE)?$`

To test Renovate, you may want to consider cloning this repository into a new repo (as to not to clutter this repo with misconfigured Renovate pull requests).  Push an updated `renovate.json` to main of the cloned repo, and then run:

```
set RENOVATE_TOKEN=ghp_{your_token}
set GITHUB_COM_TOKEN=ghp_{your_token}
set LOG_LEVEL=debug
npx renovate {owner}/{repo}
```

### Fixes for specific ports

#### Using clang-cl
Some ports should be compiled with [clang-cl](https://clang.llvm.org/docs/UsersManual.html#clang-cl), which uses a msvc-compatible command line syntax.

Often, these ports fail to compile with a command-line invocation which appears to be a mix of clang and Visual C++ arguments, such as:

```
libtool: compile:  llvm-rc.exe -DPACKAGE_VERSION_STRING=\\\"0.22.5\\\" -DPACKAGE_VERSION_MAJOR=0 -DPACKAGE_VERSION_MINOR=22 -DPACKAGE_VERSION_SUBMINOR=5 -i ./../src/gettext-0-5775b97cd5.clean/gettext-runtime/intl/libintl.rc --output-format=coff  -o .libs/libintl.res.o
```

or

```
Detecting linker via: `"C:/Program Files/LLVM/bin/clang.exe" -O0 -g -Xclang -gcodeview -Wl,--version /LIBPATH:C:/Users/vagrant/Source/Repos/vcpkg-gnustep/vcpkg/installed/x64-windows-llvm/debug/lib "-fuse-ld=C:/Program Files/LLVM/bin/lld-link.exe"` -> 1
stderr:
clang: error: no such file or directory: '/LIBPATH:C:/Users/vagrant/Source/Repos/vcpkg-gnustep/vcpkg/installed/x64-windows-llvm/debug/lib'
```

To account for this, add the name of the port to the exception list in `triplets/x64-windows-llvm.cmake`.

#### Compiling gettext-libintl

This is a dependency of `cairo` but not `cairo[core]`.  Skip this dependency by building `cairo[core]`.

#### Meson build errors

If a Meson build fails with the the following error:

```
FileNotFoundError: [WinError 2] The system cannot find the file specified
```

Then this is most likely because Meson is looking for `lld-link` without specifying an explicit path (https://github.com/mesonbuild/meson/issues/9727).

To account for this, add the name of the port to the exception list in `triplets/x64-windows-llvm.cmake`.
