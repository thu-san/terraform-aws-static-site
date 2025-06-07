# Quick Publishing Guide

## 🚀 First Time Setup

1. Go to https://registry.terraform.io
2. Sign in with GitHub
3. Click "Publish" → "Module" → Select `terraform-aws-static-site`
4. Done! The registry will watch for new tags

## 📦 Publishing a New Version

```bash
# 1. Update version in module.json
# 2. Update CHANGELOG.md
# 3. Commit and push
git add .
git commit -m "chore: release v1.0.1"
git push

# 4. Create and push tag
git tag v1.0.1
git push origin v1.0.1
```

## ✅ What Happens Automatically

1. ✅ GitHub Actions runs tests
2. ✅ GitHub release is created
3. ✅ Terraform Registry detects new tag (via API polling)
4. ✅ Module published (~5-30 minutes)
5. ✅ Module available at: `thu-san/static-site/aws`

**Note**: No webhook needed - Registry polls GitHub API automatically!

## 📋 Pre-Release Checklist

- [ ] All tests pass (`terraform test -test-directory=test`)
- [ ] Version updated in `module.json`
- [ ] CHANGELOG.md updated
- [ ] Examples work correctly
- [ ] Documentation is current

## 🔗 Module URL

Once published: https://registry.terraform.io/modules/thu-san/static-site/aws