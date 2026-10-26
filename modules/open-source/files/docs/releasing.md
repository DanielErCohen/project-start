# Releasing

The owner approves every publish, tag and release, each time. Core settings ask before the commands below.

## Version numbers

- `MAJOR.MINOR.PATCH`. A breaking change raises MAJOR, a feature MINOR, a fix PATCH, because users read the number to decide whether upgrading is safe.
- In 0.x anything may change between minor versions. Say so in the README and still note each breaking change in the changelog.
- For a command-line tool, these break users and raise MAJOR (or MINOR in 0.x): renaming or removing a flag or command, changing a flag's meaning, changing the output format scripts parse, changing an exit code, and raising the minimum runtime version.

## Steps

1. The checks pass on `{{DEFAULT_BRANCH}}` and CI is green.
2. Move the lines under "Unreleased" in `CHANGELOG.md` to a new heading with the version and date. Leave an empty "Unreleased".
3. Bump the version where the build reads it, and commit both changes together.
4. Dry-run the publish and read what it would upload: `npm publish --dry-run`, `cargo publish --dry-run` or `twine check dist/*`. Fix stray files before going on.
5. Scrub on the first release: search files and history for secrets, personal data and private URLs (a scanner such as gitleaks, or `git log --all -p -G 'secret|token|password'`), and log the result in `project/decisions.md`.
6. Tag from `{{DEFAULT_BRANCH}}`: `git tag vX.Y.Z`, then push the tag after the owner's yes.
7. Publish the package after the owner's yes.
8. Create the host's release from the tag, with the changelog lines as its notes.
9. Install the published version in a clean folder and run its smallest example. A release nobody installed is unverified.
