---
name: google-dev-style
description: Write or rewrite developer-facing prose — docs, READMEs, tutorials, API references, release notes, error messages — following the Google developer documentation style guide. Use when the user asks for documentation in "Google style", wants dev docs written or reviewed for style, or asks to make technical writing clear, consistent, and friendly.
---

# Google developer documentation style

Apply the [Google developer documentation style guide](https://developers.google.com/style)
to developer-facing prose. The guide's own framing: these are guidelines, not
rules — depart from them when it makes the content clearer, and let a
project's existing style win over this skill.

Reference hierarchy (from the guide): project-specific style first, then this
guide, then Merriam-Webster / Chicago Manual of Style / Microsoft Writing
Style Guide for anything not covered.

## When to use

- Writing new developer documentation: READMEs, tutorials, how-to guides,
  API references, release notes, changelogs, error messages, CLI help text.
- Reviewing or rewriting existing docs for style, tone, or consistency.
- The user says "Google style", "dev docs style", or asks for documentation
  that reads clear and friendly.

Not for: marketing copy, creative writing, or agent-facing text where
machine-parseability beats readability — ASD-STE100 simplified English is the
better standard there (the `asd-ste100` skill, if you have it installed).

## Voice and tone

Aim for **a knowledgeable friend**: conversational, friendly, respectful —
never frivolous. Clarity beats personality; many readers are not native
English speakers.

| Too informal | Right | Too formal |
|---|---|---|
| "Dude! This API is totally awesome!" | "This API lets you collect data about what your users like." | "The API may enable acquisition of information pertaining to user preferences." |
| "Just garbage-collect, and you're golden." | "To clean up, call the `collectGarbage` method." | "Completion requires executing an automated memory management function." |

Avoid:

- "simply", "easily", "just", "quickly" — false simplicity; if it were
  simple, the reader wouldn't need the doc.
- Placeholder phrases: "please note", "at this time".
- Exclamation marks, pop-culture references, metaphors, internet slang
  (tl;dr, ymmv), buzzwords.
- Overusing "please" in instructions — "Click **Save**", not "Please click
  **Save**".
- Pre-announcing features ("coming soon").

## Language and grammar

- **Second person**: "you", not "we" or "the user".
- **Active voice**: make the actor explicit. "The server returns an error",
  not "an error is returned".
- **Present tense**: "the command creates a file", not "will create".
- **Conditions before instructions**: "If you want logs, set `--verbose`",
  not "Set `--verbose` if you want logs" — readers act as they read.
- Standard American spelling and punctuation.

## Formatting

- **Sentence case** for all titles and headings ("Set up the client", not
  "Set Up The Client").
- **Numbered lists** for sequences; **bulleted lists** for unordered items;
  description lists for term/definition pairs.
- **Serial comma** ("a, b, and c").
- **Code font** for code, commands, filenames, paths, API names, and
  anything the reader types verbatim.
- **Bold** for UI elements the reader interacts with ("click **Save**").
- **Descriptive link text** — the linked words say where the link goes;
  never "click here" or a bare URL in prose.
- Unambiguous dates: "August 18, 2026", never 08/18/26.
- Alt text for every image.

## Procedure

1. Identify the audience and the doc type; check for an existing project
   style (glossary, docs/ conventions, house terms). Project style wins.
2. Write or rewrite applying the rules above.
3. For a rewrite, keep every fact, constraint, and caveat — style changes
   must not change meaning. Flag anything you deliberately left alone.
4. For word-level questions (e.g. "allowlist" vs "whitelist", "sign in" vs
   "login"), check the guide's word list:
   https://developers.google.com/style/word-list — do not guess from memory.

## Boundaries

**Will:** write and rewrite developer prose in this style; explain which
guideline motivated a change when reviewing.

**Will not:** reproduce the full guide or word list from memory — link to
them; restyle text whose project has its own conflicting conventions without
saying so; change technical meaning to satisfy a style rule.

## Credit

Prompted by [a post from Nate B. Jones](https://x.com/natebjones/status/2089457435459404093).
