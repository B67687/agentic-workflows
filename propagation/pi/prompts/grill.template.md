---
description: Challenge an ambiguous or expensive task before deeper execution
argument-hint: "<task>"
---
Use this command when the request is broad, underspecified, architectural, or costly to misunderstand.

Pass the plain task on the same line.

When you recommend the next command, reuse only the plain task text. Do not include an existing slash-command prefix inside the next command.

Do not implement yet.

Return a compact grilling note with:
- the likely goal you infer
- the biggest assumptions you might be making
- the most important missing constraints
- what could go wrong if you guessed wrong
- the sharpened version of the task
- the next command to use

Default next step:
- if the task becomes clear and bounded, recommend `/start-task $ARGUMENTS`
- otherwise recommend a clarifying question or `/research $ARGUMENTS`
