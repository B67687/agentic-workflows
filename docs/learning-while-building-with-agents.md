# Learning While Building With Agents

Use this file when the work is moving faster than your understanding and you want to keep learning without stopping progress.

For the shared practical doctrine behind this, start with:

- [core-agent-doctrine.md](core-agent-doctrine.md)

## Core Rule

Do not make learning a separate someday task.

Build and learning should alternate in a loop:

1. let the agent do useful work
2. extract the worked example
3. force active understanding
4. try a small independent step
5. only then move on

## What The Best Sources Point To

The principles in this section are source-backed.
The practical loops later in this file are inferences built from those principles for day-to-day agent work.

### 1. Guided learning beats answer dumping

OpenAI's study mode guidance emphasizes:

- scaffolding
- guided questions
- checks for understanding
- guided practice
- breaking complexity into manageable sections

That is a strong pattern for agent collaboration too: do not only ask for the answer. Ask the agent to help you build the mental model in steps.

### 2. Worked examples help novices

Learning science on worked examples consistently finds that novices learn more effectively from studying worked solutions than from unsupported problem solving alone.

For agent workflows, that means:

- the agent's completed task can act as the worked example
- you should study the example before trying to do the next one alone

### 3. Self-explanation is one of the highest-leverage learning moves

Research on self-explanation shows that learners understand more deeply when they explain steps to themselves rather than just rereading them.

For agent work, this means the explanation should not be the endpoint.
The real learning move is:

1. read the explanation
2. restate it in your own words
3. identify what you still do not understand

### 4. Guidance should fade as your skill grows

The expertise reversal literature shows that heavy guidance helps novices more than experts, and can become wasteful or counterproductive later.

So the goal is not to stay dependent on the agent's full walkthrough forever.
The goal is to move from:

- full worked example
- to partial hints
- to independent attempt with review

## The Best Practical Loop

### Loop A: Work First, Then Learn Fast

Use this when the task still needs to get done now.

1. Let the agent do the task.
2. Ask for a 60-second summary.
3. Ask for the mental model and key decision points.
4. Ask what tiny follow-up you should do yourself next time.
5. Do that smaller follow-up yourself with review.

### Loop B: Worked Example, Then Independent Attempt

Use this when you want faster skill growth.

1. Let the agent solve one concrete example.
2. Ask it to label the major steps and why each step exists.
3. Hide the final answer from yourself.
4. Try to reproduce the same kind of change on a similar small case.
5. Ask the agent to compare your attempt against the worked example.

### Loop C: Repo Learning Without Overwhelm

Use this when entering a new repo.

1. Ask for the architecture map.
2. Ask for the best reading order.
3. Ask for one real path through the system.
4. Ask for one small task in that path you can own.
5. Review your attempt with the agent.

## Prompts That Help

### Build and keep me learning

```text
Do the task normally, but keep me learning while we move.

After finishing:
1. give me a 60-second summary
2. show me the mental model behind the change
3. turn your work into one worked example
4. tell me one small similar task I should try myself next
5. after I try it, review my reasoning, not just the final answer

Optimize for fast skill growth, not exhaustive teaching.
```

### Teach with scaffolding, not answer dumping

```text
Teach me this in a scaffolded way.

Start simple, add complexity gradually, check my understanding, and give me one small practice step before moving to the next level.
```

### Use the agent as a worked example

```text
Treat what you just did as a worked example for me.

Show:
- the goal
- the starting clues
- the key steps
- why each step mattered
- what signals told you the path was correct

Then give me one similar but smaller case to try myself.
```

## Anti-Patterns

### 1. Letting the agent outrun your mental model for too long

If this keeps happening, slow down every few tasks and force a teaching pass.

### 2. Reading explanations passively

Explanations help less if you do not restate them, question them, or apply them.

### 3. Asking for "explain everything"

This often creates a wall of text rather than a usable learning sequence.

### 4. Staying at full guidance forever

Move toward hints and partial ownership as soon as you can.

## Best Short Rule

```text
Use the agent's work as a worked example, then force active learning with self-explanation, a small independent attempt, and a review of your reasoning.
```

## Sources

- [OpenAI: Introducing study mode](https://openai.com/blog/chatgpt-study-mode/)
- [OpenAI: New tools for understanding AI and learning outcomes](https://openai.com/index/understanding-ai-and-learning-outcomes/)
- [OpenAI Help: ChatGPT Study Mode FAQ](https://help.openai.com/en/articles/11780217-chatgpt-study-mode-faq)
- [Renkl 1999: Learning mathematics from worked-out examples](https://link.springer.com/article/10.1007/BF03172974)
- [Van Gog, Paas, Sweller 2010: Cognitive Load Theory review](https://link.springer.com/article/10.1007/s10648-010-9145-4)
- [Chi et al. 1989: Self-explanations and learning from examples](https://asu.elsevierpure.com/en/publications/self-explanations-how-students-study-and-use-examples-in-learning/)
- [Chi et al. 1994: Eliciting self-explanations improves understanding](https://asu.elsevierpure.com/en/publications/eliciting-self-explanations-improves-understanding)
- [Kalyuga 2007: Expertise reversal effect](https://link.springer.com/article/10.1007/s10648-007-9054-3)
