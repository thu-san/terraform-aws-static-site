# PR Preview with SPA Support Example

This example demonstrates how to set up PR preview deployments with full Single Page Application (SPA) support. It builds upon the basic PR preview example by adding intelligent routing that ensures SPA client-side routing works correctly for both the main site and all PR previews.

## 🎯 Key Features

- **SPA-Aware Routing**: Automatically serves `index.html` for all non-static routes
- **Multiple PR Support**: Each PR gets its own isolated SPA at `pr{number}.domain.com`
- **Zero Configuration Per PR**: No need to configure error pages for each PR
- **Framework Agnostic**: Works with React Router, Vue Router, Angular Router, etc.
- **Automatic Cache Invalidation**: Changes are reflected immediately

## 🏗️ How It Works

The CloudFront function intelligently routes requests based on:

1. **Domain Detection**: Identifies if request is for main domain or PR subdomain
2. **File Type Detection**: Checks if the filename contains a dot (.)
   - Has dot = static file (app.js, style.css, logo.png, etc.)
   - No dot = SPA route (about, products, users/123, etc.)
3. **Smart Routing**:
   - Static files → Serve as-is from appropriate folder
   - SPA routes → Serve appropriate `index.html`

### Request Flow Examples

**Main Domain (dev.example.com):**
```
GET /                    → /index.html
GET /about              → /index.html (SPA route)
GET /products/123       → /index.html (SPA route)
GET /assets/logo.png    → /assets/logo.png (static file)
GET /js/app.js          → /js/app.js (static file)
```

**PR Domain (pr123.dev.example.com):**
```
GET /                    → /pr123/index.html
GET /about              → /pr123/index.html (SPA route)
GET /products/123       → /pr123/index.html (SPA route)
GET /assets/logo.png    → /pr123/assets/logo.png (static file)
GET /js/app.js          → /pr123/js/app.js (static file)
```

## 🛡️ Defense in Depth: Function + Error Responses

This example uses a two-layer approach for bulletproof SPA support:

1. **CloudFront Function (Primary)**: Preemptively routes SPA paths to index.html
   - Prevents most 404s from occurring
   - Works for both main site and PR previews

2. **Custom Error Responses (Fallback)**: Catches any errors that still occur
   - Missing static files (e.g., `/assets/missing.png`)
   - Permission errors (403)
   - Any edge cases the function doesn't handle

This ensures your SPA works correctly in ALL scenarios.

## 📁 Required S3 Structure

```
s3://your-bucket/
├── index.html              # Main branch SPA
├── js/
│   └── app.js
├── css/
│   └── style.css
├── assets/
│   └── logo.png
├── pr123/                  # PR #123 complete build
│   ├── index.html
│   ├── js/
│   │   └── app.js
│   ├── css/
│   │   └── style.css
│   └── assets/
│       └── logo.png
└── pr456/                  # PR #456 complete build
    ├── index.html
    ├── js/
    │   └── app.js
    ├── css/
    │   └── style.css
    └── assets/
        └── logo.png
```

## 🚀 Usage

### 1. Configure Your Variables

Create a `terraform.tfvars` file:

```hcl
s3_bucket_name               = "my-spa-pr-preview-bucket"
cloudfront_distribution_name = "My SPA PR Preview Site"
main_domain                  = "dev.example.com"
hosted_zone_name            = "example.com"
enable_cache_invalidation    = true

tags = {
  Project     = "my-spa-app"
  Environment = "development"
}
```

### 2. Deploy the Infrastructure

```bash
terraform init
terraform plan
terraform apply
```

### 3. Deploy Your SPA

**Deploy Main Branch:**
```bash
# Build your SPA
npm run build  # or yarn build

# Deploy to S3 root
aws s3 sync ./dist s3://my-spa-pr-preview-bucket/ --delete

# The site is now available at https://dev.example.com
```

**Deploy PR Preview:**
```bash
# Build your SPA for PR #123
npm run build  # or yarn build

# Deploy to PR-specific folder
aws s3 sync ./dist s3://my-spa-pr-preview-bucket/pr123/ --delete

# The PR preview is now available at https://pr123.dev.example.com
```

## 🔧 Framework-Specific Configuration

### React Router

No special configuration needed! Both `BrowserRouter` and `HashRouter` work out of the box.

```jsx
// App.jsx
import { BrowserRouter, Routes, Route } from 'react-router-dom';

function App() {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/" element={<Home />} />
        <Route path="/about" element={<About />} />
        <Route path="/products/:id" element={<Product />} />
      </Routes>
    </BrowserRouter>
  );
}
```

### Vue Router

Works with default configuration:

```javascript
// router/index.js
import { createRouter, createWebHistory } from 'vue-router'

const router = createRouter({
  history: createWebHistory(),  // HTML5 mode
  routes: [
    { path: '/', component: Home },
    { path: '/about', component: About },
    { path: '/products/:id', component: Product }
  ]
})
```

### Angular Router

No changes needed to your routing configuration:

```typescript
// app-routing.module.ts
const routes: Routes = [
  { path: '', component: HomeComponent },
  { path: 'about', component: AboutComponent },
  { path: 'products/:id', component: ProductComponent }
];

@NgModule({
  imports: [RouterModule.forRoot(routes)],
  exports: [RouterModule]
})
export class AppRoutingModule { }
```

## 🤖 CI/CD Integration

### GitHub Actions Example

```yaml
name: Deploy PR Preview

on:
  pull_request:
    types: [opened, synchronize]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '18'
          
      - name: Install dependencies
        run: npm ci
        
      - name: Build SPA
        run: npm run build
        env:
          PUBLIC_URL: https://pr${{ github.event.pull_request.number }}.dev.example.com
          
      - name: Deploy to S3
        run: |
          aws s3 sync ./dist s3://${{ secrets.S3_BUCKET }}/pr${{ github.event.pull_request.number }}/ --delete
        env:
          AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
          AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          AWS_REGION: us-east-1
          
      - name: Comment PR
        uses: actions/github-script@v6
        with:
          script: |
            github.rest.issues.createComment({
              issue_number: context.issue.number,
              owner: context.repo.owner,
              repo: context.repo.name,
              body: '🚀 PR Preview deployed to: https://pr${{ github.event.pull_request.number }}.dev.example.com'
            })
```

### Cleanup Workflow

```yaml
name: Cleanup PR Preview

on:
  pull_request:
    types: [closed]

jobs:
  cleanup:
    runs-on: ubuntu-latest
    steps:
      - name: Delete PR preview from S3
        run: |
          aws s3 rm s3://${{ secrets.S3_BUCKET }}/pr${{ github.event.pull_request.number }}/ --recursive
        env:
          AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
          AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          AWS_REGION: us-east-1
```

## 🎨 Customization

### File Detection Logic

By default, the function treats any path with a dot in the filename as a static file. This simple approach works for all file types automatically.

If you need to restrict to specific file types only, you can modify the CloudFront function:

```javascript
// Option 1: Simple dot detection (default - works for all files)
var isFile = filename.indexOf('.') !== -1;

// Option 2: Specific extensions only
var allowedExtensions = /\.(css|js|json|png|jpg|jpeg|gif|svg|ico|woff|woff2|ttf)$/i;
var isFile = allowedExtensions.test(filename);

// Option 3: Exclude certain patterns that have dots but aren't files
var isFile = filename.indexOf('.') !== -1 && !filename.match(/^v\d+\.\d+$/);
```

This flexibility allows you to adapt the routing logic to your specific needs.

### Custom Error Handling

While not needed for SPA routing, you can add custom error pages:

```hcl
module "static_site" {
  # ... other configuration ...
  
  custom_error_responses = [
    {
      error_code         = 500
      response_code      = 500
      response_page_path = "/error.html"
      error_caching_min_ttl = 60
    }
  ]
}
```

## 🧪 Testing Your Setup

1. **Test Main Site SPA Routing:**
   ```bash
   # Should all return 200 and show your SPA
   curl -I https://dev.example.com/
   curl -I https://dev.example.com/about
   curl -I https://dev.example.com/products/123
   ```

2. **Test PR Preview SPA Routing:**
   ```bash
   # Should all return 200 and show PR-specific SPA
   curl -I https://pr123.dev.example.com/
   curl -I https://pr123.dev.example.com/about
   curl -I https://pr123.dev.example.com/products/123
   ```

3. **Test Static Assets:**
   ```bash
   # Should return actual files
   curl -I https://dev.example.com/js/app.js
   curl -I https://pr123.dev.example.com/css/style.css
   ```

4. **Test Missing Static Files (Error Handling):**
   ```bash
   # Should return 200 with index.html content (not 404)
   curl -I https://dev.example.com/assets/does-not-exist.png
   curl -I https://pr123.dev.example.com/images/missing.jpg
   ```

## 🔍 Debugging

### CloudWatch Logs

The CloudFront function logs can be viewed in CloudWatch Logs (if enabled):

1. Go to CloudWatch Logs in AWS Console
2. Look for log group: `/aws/cloudfront/function/your-function-name`

### Common Issues

1. **404 on SPA Routes**: Check that the CloudFront function is attached to viewer-request
2. **Wrong Content Served**: Verify S3 folder structure matches expectations
3. **Cache Issues**: CloudFront caches responses. Use cache invalidation or wait for TTL

## 📚 Additional Resources

- [CloudFront Functions Documentation](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/cloudfront-functions.html)
- [React Router Deployment](https://create-react-app.dev/docs/deployment/#serving-apps-with-client-side-routing)
- [Vue Router HTML5 History Mode](https://router.vuejs.org/guide/essentials/history-mode.html)
- [Angular Deployment](https://angular.io/guide/deployment)