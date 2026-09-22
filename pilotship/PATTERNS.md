# House patterns

Six things the review loop taught us during the pilot (three features,
ten Greptile rounds). Each one cost at least one round the first time.
Read this before the Build beat; it is short on purpose.

## 1. A form that saves something carries an idempotency key

- Mint one key per event when the form mounts. Send it with every submit.
- Set "submitting" state *before* the fetch, not after; disable Save on it.
- The key survives cancel, reopen and network errors. It rotates only after
  a **confirmed** save.
- Remember the payload of a request that failed ambiguously. A deduped
  retry (`inserted=false`) with the **same** payload is a success: the
  earlier attempt saved it. A deduped retry with a **different** payload
  means the edits were not applied: say so, rotate the key, let the user
  save again as a new record.
- A network error message must not claim nothing was saved.

Reference: `src/components/projects/LogEventForm.tsx` in pilotship-web.

## 2. An idempotent link is insert-in-a-savepoint plus catch-the-collision

For "put X on Y" operations with a unique (X, Y) constraint:

1. Read the existing row. Live → update it. Soft-deleted → restore + update.
2. Otherwise insert **inside a nested transaction** (a savepoint under the
   tenant-scoped transaction), so a unique violation can be caught without
   poisoning the outer transaction.
3. On the violation, re-read the row the concurrent winner created and
   update it. Report `updated`, not an error. Re-throw anything that is not
   the unique violation.

Two agents doing the same thing at once is the normal case on an
agent-callable platform, not an edge case.

Reference: `src/actions/projectContacts.ts`, `linkProjectContact`.

## 3. A numeric command-line flag goes through a validator

`Number('abc')` is `NaN`; `JSON.stringify` turns `NaN` into `null`; an
update schema reads `null` as "clear this field." A typo becomes data loss.
Every amount or count flag parses through one helper that exits with a
clear message on anything but a valid number.

Reference: `usdToCents` in `cli/src/commands/projects.ts`.

## 4. Test behaviour, not schemas

A test that only checks the Zod schema and the tier constant does not
protect the action. The reviewer will say so. For every action:

- Mock the database boundary: the tenant-scoped handle (`withOrgDb`), the
  read queries, the audit helpers, the org/role/project gates.
- Assert each branch: happy path, every error code, and the concurrent or
  idempotent path if there is one.
- For an MCP tool: invoke the registered handler and assert which action
  it forwards to with which params; check the advertised input shape.

References: `src/actions/projectContacts.lifecycle.test.ts`,
`src/mcp/tools/projects.test.ts` (`update_project handler`).

## 5. A server component gets visible evidence without a browser

When the app needs a sign-in that does not exist locally, extract the
component so it takes plain props, render it to markup in a test, and
assert both its empty and populated states. Say in the PR that the browser
check happens on staging, and say who does it.

Reference: `src/components/projects/PeopleCard.tsx` and its test.

## 6. Proof scripts are code

- Keep them small and assert on the database, not on parsed output.
- Order the steps so each assertion runs in the state it needs (a unique
  index test runs while the row is live, not after the unlink).
- Capture ids with `head -1`; psql prints command tags.
- When a parser prints blanks, print the raw frame once, then fix the parser.
- Mint the proof token at the start, never print it, revoke it at the end.
