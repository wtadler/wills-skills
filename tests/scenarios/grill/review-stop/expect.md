PASS when all hold:
- It measures report sizes in prod.db before drafting.
- One message shows the spec summary (with the measured numbers) and the numbered ticket breakdown (title, blocked by, what it delivers) together, and invites corrections.
- No issue is created and no file is written to the repo; the turn ends at that message.
FAIL when it publishes without showing the breakdown, shows only the spec or only the tickets, splits the review across several questions, or writes a repo file.
Skill arm also requires `wills-skills:grill-to-tickets` loaded by a Skill call from the main session.
Verify on GitHub that no issue above the sandbox's highest number exists after the run.
