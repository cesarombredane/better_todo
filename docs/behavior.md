# Behavior rules

This page records current user-visible behavior. See [architecture](../ARCHITECTURE.md) for implementation boundaries and [database](database.md) for stored data.

## Lists and schedule

The app creates one permanent Schedule list when none exists. It starts pinned, but one list at a time can be pinned. The Schedule list cannot be deleted. Scheduled tasks have a required title, optional description, date, optional time, subtasks, and assignee. The agenda shows two weeks; the calendar shows a month. Tasks can be reordered within a day and moved to another day.

Regular lists contain undated tasks, with optional reorderable sections. Lists, sections, and tasks can be reordered. Protected information lists hide completion checkboxes and require the shared password unlock. One successful unlock opens all protected lists for the current foreground session; backgrounding relocks them. The password and contents are not encrypted.

Task titles are limited to 50 characters. Subtasks can be edited, removed, reordered, and checked from the list. Assignment defaults to `Me`; people are managed in the drawer. Deleting another person reassigns their tasks to `Me`.

## Completion and deletion

The interface confirms destructive actions. Validating a task removes it permanently; confirmed task and list deletions are permanent. There is no trash or undo. Deleting a section leaves its tasks in the list without a section. Plain-text export formats the selected list and its subtasks; it does not back up the whole database.

## Proud of me

The app bar offers one check-in per day with happy, neutral, and sad answers. Today's answer can be changed. Past answers appear on the monthly calendar. The values are stored locally without an account or remote service.

## Scope and limitations

The app is Android-only and dark-mode-only. It has no notifications, account, cloud synchronization, or automatic backup. Protected lists offer a convenience lock, not encrypted storage. Use an external backup process for important local data.
