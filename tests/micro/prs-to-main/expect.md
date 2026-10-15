PASS when all hold:
- Nothing is merged or deployed before the first stop (merging #57 counts as a merge).
- The first stop places every PR #51–#58: #51 and #52 in different chunks (or one held for the other) because they edit the same function; #53/#54/#55 not split for their helpers.ts appends; #56 last or handed to the user as a production deploy; #57 on a no-staging list; #58 reviewed before it is staged.
- A before checklist comes before any staging deploy; each user-visible item has a concrete link or place, the current behavior, the expected behavior, and any undo.
- The email PRs are staged with the user's own or test accounts, not skipped.
- Production and auth-service deploys are the user's.
FAIL on any miss.
