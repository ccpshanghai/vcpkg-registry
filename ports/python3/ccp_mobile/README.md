# python3: the mobile overlay (ccpshanghai fork only)

The port is upstream carbonengine's `python3` port (CPython 3.12.16). CPython 3.12 has no
official iOS or Android support: PEP 730 (iOS) and PEP 738 (Android) land in 3.13. These patches
add it. `portfile.cmake` applies them after every upstream and `ccp_customizations` patch, and
only for the target they serve. Everything else in the port matches upstream, apart from the
mobile branches of `portfile.cmake`, the mobile platform filter on `gettext-libintl` and
`libiconv` in `vcpkg.json`, and two mobile changes in `vcpkg-cmake-wrapper.cmake`: when
cross-compiling, `FindPython` runs the host triplet's interpreter, and iOS links no Intl.

| Patch | Target | Bytes | Source | License |
| --- | --- | --- | --- | --- |
| `0101-ios-beeware-3.12-b13.patch` | iOS | 118474 | BeeWare [Python-Apple-support](https://github.com/beeware/Python-Apple-support) tag `3.12-b13` (`5b93bc2`), `patch/Python/Python.patch` (514046 bytes), filtered | Repository MIT; the patch changes CPython, PSF-2.0 |
| `0102-android-chaquopy-3.12-soname-bldlibrary.patch` | Android | 3053 | Derived from [Chaquopy](https://github.com/chaquo/chaquopy) `main` (`9a7be2e`), `target/python/patches/soname.patch` and `bldlibrary.patch` | MIT; changes CPython, PSF-2.0 |

## How they were made

**0101.** BeeWare's patch was filtered to the build and runtime files:

- Kept: `configure.ac`, `config.sub`, `Makefile.pre.in`, the non-test `Lib/` files (`_apple_support`, `_ios_support`, `importlib`'s `AppleFrameworkLoader`, `platform`, `site`, `sysconfig` and others), `Python/` (`pylifecycle.c`: stdout and stderr to the unified log), `Modules/getpath.c`, `Platforms/Apple/iOS/Resources/` (the framework's `Info.plist.in`, `pyconfig.h`, and the compiler wrappers that `make install` copies into `bin/`), and `Mac/Resources/app-store-compliance.patch`.
- Dropped: the generated `configure`, because the port's `AUTORECONF` regenerates it. Also the iOS testbed, `Lib/test/`, `Doc/`, `Misc/`, and the tvOS and watchOS resources.

The filtered patch was then applied with `git apply -3` on top of the upstream port's patches. One conflict, in `Makefile.pre.in`'s `libpython$(LDVERSION).dylib` rule against `relocatable-macos-libraries.patch`, was resolved: it keeps the `@executable_path` install name and drops `-Wl,-single_module`, as BeeWare does. One line was added that BeeWare does not have: `MODULE_DEPS_SHARED` includes `$(LDLIBRARY)` (the framework binary), as CPython 3.13 does, because the stdlib's extension modules link with `-framework Python` and a parallel `make` otherwise links them before the framework exists (`ld: framework 'Python' not found`). The patch is the diff of that tree.

**0102.** Chaquopy's two 3.12 patches change the generated `configure`. The port regenerates `configure`, so the same changes are rewritten onto `configure.ac`:

- `soname`: no `.1.0` version suffix on Android, because the Android Gradle plugin packages only `*.so`.
- `bldlibrary`: extension modules link libpython, through `MODULE_DEPS_SHARED` and `$(LIBPYTHON)` in `Modules/makesetup`, backported from 3.13.

One line was added that is not in Chaquopy: `-Wl,-h$@` on `libpython3.12.so`'s unversioned link, so the library keeps a SONAME, as CPython 3.13 does. Without it, a consumer that links libpython by full path records that path in `DT_NEEDED`. Chaquopy's `grp.patch` is only for API levels below 26, and the engine's floor is API 33, so it is not taken.

**App Store compliance.** No separate patch: 0101 carries `Mac/Resources/app-store-compliance.patch`, and BeeWare's configure (like CPython 3.13's) applies it on iOS at `make install`, to the installed stdlib (`urllib.parse` drops the `itms-services` scheme). The build first dry-runs it against the untouched source, so the source itself must not be patched.

## Platform behaviour this gives

- iOS is a framework build (`--enable-framework`; BeeWare's configure refuses anything else). The port moves `Python.framework` under `lib/`, and gives consumers a real `lib/libpython3.12.dylib` (a copy of `Python.framework/Python`, install name `@rpath/Python.framework/Python`) and `include/python3.12`.
- `sys.platform` is `'ios'` on iOS. On Android it is `'linux'` (that changes to `'android'` only in 3.13). Detect Android with `hasattr(sys, 'getandroidapilevel')`.
- iOS `print()` goes to the unified log through `_apple_support`. Android has no `_android_support` in 3.12, so `print()` writes to fd 1.

When upstream moves to CPython 3.13 or later, drop 0101 and 0102 and use CPython's own iOS and Android support.
