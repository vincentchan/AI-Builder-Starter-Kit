---
name: test
description: Write tests for existing untested code before refactoring. 
Use when the user wants to add test coverage to an existing file, 
run reverse TDD, or establish a safety net before a refactor.
---

Read docs/SPEC.md for project context and testing conventions.

For the file I specify:

1. **Analyze** — read the file and identify:
   - All exported functions and their current behavior
   - Happy paths, edge cases, and failure modes worth covering
   - External dependencies that need mocking

2. **Propose** — list the test cases you plan to write as a checklist.
   Do not write any test code yet. Wait for my approval.

3. **Write** — after approval, write the tests.
   Rules:
   - Use the existing test framework in this project
   - Mirror behavior exactly — do not improve or fix the source code
   - Each test must have a clear failure message
   - Mock all external dependencies (DB, API, email)

4. **Run** — execute the full test suite and show me the output.
   Required result: all existing tests still pass + new tests pass.
   If anything is red: stop, report exactly what failed, wait for instruction.

5. **Confirm** — show me the final test count before and after.
   Only mark this done when the number has gone up and nothing has gone down.

Do not touch the source file under any circumstances.
