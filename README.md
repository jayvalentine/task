# task

A simple command-line task-tracking app for busy programmers.

## How task works

`task` categorizes the things you need to do into four categories:

* `now` - this is the thing you're doing _right now_. You can only be doing one thing _right now_.
* `next` - this is the thing you're doing after `now` - the next highest-priority task to be done after whatever you're currently doing.
* `soon` - these are things you're doing after `next` - they need to be done in the near-future but not _right now_.
* `later` - these are the "back-burner" tasks - those things bouncing around in the back of your head that are not too important
  but also don't want to be forgotten.

`task` provides these four keywords to allow you to add new tasks. For example, the following command adds a new task `next`:

```
task next write a ticket for that bug
```

`task` automatically ensures that your task list always meets the criteria above - so for example if you add a new task `now`
then your existing `now` task is shifted to `next`, the existing `next` is then shifted to `soon`. This enables you to respond to
interrupts without losing track of your original plan of action.

In addition to the four commands listed above, `task` provides the following commands for interacting with your existing tasks:

`status` lists the current tasks, organized by category.

`done` marks a task as done. This is done by keyword-matching against the task-list. For example, the following command would mark
the task described above as done:

```
task done bug ticket
```

because the task contains the words `bug` and `ticket` - the order of keywords provided to `done` does not have to be the same
as in the task wording. If there is any ambiguity `done` will instead print all matching tasks so that you can select one.

### Storing task list

`task` stores your tasks in a YAML file located in the path indicated by environment variable `TASKDIR`.

## What task doesn't do

`task` is designed as a lightweight way to track your "plan of action" - for this reason there are some features it intentionally
does _not_ implement:

* `task` does not split tasks across projects - all tasks exist in one list.
* `task` does not prioritize tasks (outside of the implicit priority of the four categories).
* `task` does not track time (e.g. deadlines).
