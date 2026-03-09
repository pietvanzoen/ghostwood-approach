Prepare and publish a versioned release of Ghostwood Approach.

## Steps

1. **Find the last release tag** with `git tag --sort=-v:refname | grep '^v' | head -1`. If no tags exist, treat everything since the first commit as new.

2. **Review changes since the last tag** with `git log <last-tag>..HEAD --oneline`. Summarise them for the user.

3. **Determine the version bump** based on the changes:
   - **patch** (0.0.x) — bug fixes, copy/text changes, tooling, docs only
   - **minor** (0.x.0) — new features, new mechanics, new UI (most milestone completions)
   - **major** (x.0.0) — breaking save-data changes, complete redesigns (rare)
   Present the recommendation with a one-line rationale and ask the user to confirm or override.

4. **Update `source/pdxinfo`** — increment the `version=` field to the new version. Also increment `buildNumber=` by 1.

5. **Commit the version bump** with message `Release vX.Y.Z`.

6. **Tag the commit** with `git tag vX.Y.Z`.

7. **Push branch and tag** with `git push origin HEAD && git push origin vX.Y.Z`.

The push will trigger the release workflow, which builds the `.pdx` and publishes a GitHub release.

## Notes
- Always confirm the version bump with the user before making any changes.
- Do not skip the confirmation step even if the bump seems obvious.
- The version in `source/pdxinfo` must match the tag (without the `v` prefix).
