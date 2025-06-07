# Contributing to Terraform AWS Static Site Module

Thank you for your interest in contributing to this Terraform module! This document provides guidelines and instructions for contributing.

## Code of Conduct

By participating in this project, you agree to abide by our code of conduct: be respectful, inclusive, and constructive in all interactions.

## How to Contribute

### Reporting Issues

- Check if the issue already exists in the GitHub issues
- Provide a clear description of the problem
- Include Terraform version, AWS provider version, and module version
- Add steps to reproduce the issue
- Include relevant error messages and logs

### Suggesting Features

- Open an issue with the "enhancement" label
- Clearly describe the feature and its use case
- Explain why this feature would be valuable

### Submitting Pull Requests

1. **Fork the repository** and create a new branch:
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Make your changes**:
   - Follow the existing code style
   - Update documentation as needed
   - Add tests for new functionality
   - Update examples if applicable

3. **Test your changes**:
   ```bash
   # Run validation
   cd test
   ./validate.sh
   
   # Run Terraform tests
   terraform test -test-directory=test
   ```

4. **Format your code**:
   ```bash
   terraform fmt -recursive
   ```

5. **Commit your changes**:
   - Use clear, descriptive commit messages
   - Follow conventional commits format (e.g., `feat:`, `fix:`, `docs:`)

6. **Push and create a Pull Request**:
   - Provide a clear description of the changes
   - Reference any related issues
   - Ensure all checks pass

## Development Guidelines

### Code Style

- Use Terraform formatting (`terraform fmt`)
- Follow Terraform naming conventions
- Add comments for complex logic
- Keep resource names descriptive and consistent

### Documentation

- Update README.md for user-facing changes
- Add inline comments for complex configurations
- Update examples to demonstrate new features
- Document all variables and outputs

### Testing

- Add tests for new functionality
- Ensure existing tests pass
- Test with different Terraform versions
- Validate examples work correctly

### Module Structure

```
.
├── main.tf              # Main resource definitions
├── variables.tf         # Input variables
├── outputs.tf          # Output values
├── versions.tf         # Version constraints
├── README.md           # User documentation
├── CHANGELOG.md        # Version history
├── examples/           # Usage examples
│   └── */
│       ├── main.tf
│       ├── outputs.tf
│       └── README.md
└── test/              # Test files
    ├── main.tftest.hcl
    └── validate.sh
```

### Commit Message Format

We follow the Conventional Commits specification:

- `feat:` New features
- `fix:` Bug fixes
- `docs:` Documentation changes
- `style:` Code style changes (formatting, etc.)
- `refactor:` Code refactoring
- `test:` Test additions or modifications
- `chore:` Maintenance tasks

Example:
```
feat: add support for S3 bucket lifecycle rules

- Added lifecycle_rules variable
- Updated S3 bucket resource configuration
- Added example demonstrating lifecycle rules
```

## Release Process

1. Update version in `module.json`
2. Update CHANGELOG.md with release notes
3. Create a git tag: `git tag v1.0.0`
4. Push the tag: `git push origin v1.0.0`
5. Create a GitHub release

## Getting Help

- Open an issue for bugs or feature requests
- Check existing documentation and examples
- Review closed issues for similar problems

## License

By contributing to this repository, you agree that your contributions will be licensed under the Apache License 2.0.