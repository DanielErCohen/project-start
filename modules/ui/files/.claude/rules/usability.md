---
paths: ["src/**", "app/**", "ui/**", "components/**", "cli/**"]
---
# Usability and accessibility

> ADAPT: set `paths` to the folders holding what a person sees or runs, rewrite the next paragraph for the real user (a desk web app, a one-handed phone app, a scripted command, an API whose error messages are the interface), and delete rules tagged for surfaces the project lacks.

The user is busy and not reading the manual. Correct code that makes the user work is a defect. On each interaction and again on the diff, ask how the user knows it worked and whether the next step is now manual.

Tags: **[all]**, **[screen]** (web, mobile), **[terminal]**.

## Usability

1. [all] An action changes something the user is already looking at. A hidden state or log line is no feedback.
2. [all] Confirmation outlives the moment: half a minute and two actions later it is still visible. A toast alone is gone.
3. [all] A no-op never looks like nothing. Duplicate, already done and nothing to do show the wanted state.
4. [all] Removing or overwriting keeps an undo within reach where it happened.
5. [screen] Nothing moves under the pointer or finger, during the gesture or as its result.
6. [all] A hold on background data exempts the person's own actions, so their undo and input show at once.
7. [terminal] Output reads at 80 columns. Output to a pipe carries no colour, progress bars or prompts; data goes to stdout, messages to stderr.
8. [terminal] Exit 0 means success, non-zero failure, and a usage error differs from a runtime failure, because scripts branch on the code.

## Accessibility

9. [screen] Every control has a role, an accessible name and its state; targets meet the platform's minimum size.
10. [screen] Text scales with the user's setting, with no fixed heights or clipping; motion has a static alternative under reduced motion.
11. [screen] Focus and reading order match the visual order; dialogs trap and return focus; errors are announced once.
12. [all] Colour never carries meaning alone: pair it with a word or symbol, because pipes and colour-blind readers lose it.
13. [screen] Compute contrast from the current design tokens for light, dark and pressed states; never quote it from memory.

Before calling a change done, use the flow twice in a row and check the failure branch of every write (duplicate, empty, failed, offline, already done): each lands somewhere visible.
