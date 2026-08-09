# New Feature Skill

Step-by-step procedure for adding a new feature to the IntelliHouse project.

## Pre-flight

1. Read `PLAN.md` to understand current architecture and status
2. Read `CLAUDE.md` for conventions and project structure
3. Read `LEARNINGS.md` for known gotchas relevant to this feature
4. Verify the feature doesn't already exist

## Steps

### 1. Design (architect)

- Identify which layer(s) the feature touches (app / dockerfile / configuration)
- List all files that need creating or modifying
- Define the interfaces between layers
- Update `PLAN.md` with the design decision

### 2. Write failing tests (tester)

- Create or update test files for affected modules
- Write tests that describe the expected behaviour
- Run tests — they should fail (red)

### 3. Implement (implementer)

- Start at the lowest layer affected 
- Follow conventions from `CLAUDE.md`:
  - Type hints on all signatures
- Run tests after each layer — they should progressively pass

### 4. Review (reviewer)

- Check code against the reviewer checklist
- Verify layer boundaries are respected
- Confirm tests cover happy path, edge cases, and errors

### 5. Update plan and learnings

- Move the feature from Backlog → Done in `PLAN.md`
- Note any follow-up work or technical debt
- If you discovered anything non-obvious during implementation, add an entry to `LEARNINGS.md`
