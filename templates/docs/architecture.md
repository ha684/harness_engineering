# Architecture

<!-- The map an agent uses to find where a change belongs without scanning the
     repo. Stay at the level of "where responsibility lives" — function lists go
     stale within days. Update the map when files are added, moved or removed. -->

## Overview

TODO: three to five sentences — the main components and how they talk to each other.

## Module map

```
TODO — for example:
src/
├── api/       # HTTP layer: parse and validate input, shape responses
├── service/   # business rules
└── repo/      # persistence; the only code that talks to the database
```

## Boundaries

- TODO: dependency direction, e.g. `api → service → repo`. Name the tool that enforces it, if one does.

## If this doc and the code disagree

Point it out rather than quietly aligning one to the other — which one is right is the user's call.
