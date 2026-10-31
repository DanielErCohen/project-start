# Contributing to {{PROJECT_NAME}}

Thank you for helping. This page covers how to propose a change and what a maintainer checks.

## Before you start

- Open an issue first for anything beyond a small fix: say what is wrong, what you expect and one check that shows it. A short agreement saves a rewrite.
- There is no `project/` folder in this repository. Everything a contributor needs is in this file and `README.md`.

## Set up and check

> ADAPT: write the real install, test and run commands, and the language version needed.

Run `sh scripts/check.sh` before you open a pull request. It runs the same steps as CI.

## The pull request

- One change per pull request, with a test that fails without it.
- A change to behavior adds a line under "Unreleased" in `CHANGELOG.md`, in the user's words.
- The description says what changed, why and how you checked it. Link the issue.
- Keep commit subjects imperative and about 50 characters.

## Review

A maintainer reviews every pull request and decides. Expect questions rather than silence; a review may ask for changes or decline a change that does not fit the project. Contributions are accepted under the repository's license.

## Security

Report a vulnerability as described in `SECURITY.md`; a public issue would expose users before a fix exists.
