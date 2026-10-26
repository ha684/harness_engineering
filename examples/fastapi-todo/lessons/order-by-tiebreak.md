# Order by created_at needs an id tiebreak

**Applies when:** writing or changing a list or pagination query sorted by a timestamp, in `app/repo/`.

**Lesson:** Sorting by `created_at` alone is nondeterministic for rows that share a timestamp — PostgreSQL may return them in any order, differently between requests and between pages. Always add `id` as the tiebreak (`ORDER BY created_at DESC, id DESC`), and test it with rows inserted at the same instant.

**Evidence:** `test_filter_completed_only` failed in CI about one run in five while passing locally; tasks created inside one test had identical `created_at`. `test_tasks_created_at_the_same_instant_keep_a_stable_order` (change `add-status-filter`, 2026-05-18) reproduced it, failing about one run in five; with the `id` tiebreak it passed 20 of 20 runs. An earlier mocked-session version of the test never failed, which is part of why tests here use the real database.
