# .vcpkg-history

Port trees that a `versions/` entry names but that no commit's `ports/` holds.
vcpkg reads a version entry by its `git-tree` object; the object must be reachable
in this repository, or `vcpkg install` fails with "failed to unpack tree object".

Each directory here is one such tree, byte for byte, named `<port>-<version>-<port-version>`.
Nothing reads these directories by path, and `ports/` is unaffected.

| Directory | git-tree | Source |
|---|---|---|
| `curl-7.78.0-0` | `0be4cff4d8e1d37a9ddf9ab264682771c69c0d72` | microsoft/vcpkg `ports/curl` at `6a9ecfd57f` ("[curl] Update (#18971)", 2021-08-12); entry added by `3664c2f` |
