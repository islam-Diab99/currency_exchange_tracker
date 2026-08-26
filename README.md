# axis_assessment

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Git Hooks

This repo ships a pre-commit hook that runs `dart format` and `flutter analyze`
before each commit. Git does not track `.git/hooks/`, so install it once after
cloning:

```bash
cp tool/hooks/pre-commit .git/hooks/ && chmod +x .git/hooks/pre-commit
```

Skip the hook for a single commit with `git commit --no-verify`.
