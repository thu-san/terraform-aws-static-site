# AWS 静的サイト Terraform モジュール

[English](README.md) | [日本語](README-ja.md)

[![Terraform CI](https://github.com/thu-san/terraform-aws-static-site/workflows/Terraform%20CI/badge.svg)](https://github.com/thu-san/terraform-aws-static-site/actions)
[![Terraform Registry](https://img.shields.io/badge/Terraform%20Registry-thu--san%2Fstatic--site%2Faws-blue.svg)](https://registry.terraform.io/modules/thu-san/static-site/aws)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![Terraform Version](https://img.shields.io/badge/Terraform-%3E%3D%201.0-623CE4.svg)](https://www.terraform.io)

この Terraform モジュールは、S3 をストレージとして使用し、CloudFront でグローバルコンテンツ配信を行う、完全な静的ウェブサイトホスティングソリューションを AWS 上に作成します。

## 🎯 主な差別化要因

1. **自動キャッシュ無効化** - S3 コンテンツが変更されたときに CloudFront を自動的に更新する、組み込みの Lambda ベースのキャッシュ無効化システム。手動無効化や別ツールが必要な他の静的サイトモジュールとは異なり、この機能は柔軟なパスマッピングオプションと共にモジュールに直接統合されています。

2. **クロスアカウント CloudFront ログ配信** - CloudFront アクセスログを**異なる AWS アカウント**に配信できるため、集中ログアーキテクチャやエンタープライズセキュリティ要件に最適です。

3. **組み込みサブフォルダルートオブジェクト** - カスタム CloudFront 関数を書くことなく、サブディレクトリからインデックスファイルを自動的に提供。`subfolder_root_object`を設定するだけで、モジュールが残りを処理し、ルートとサブフォルダで異なるデフォルトファイルを使用できます。

4. **ワイルドカードドメインサポート** - 自動 ACM 証明書検証付きのワイルドカードドメインを完全サポート。PR プレビューデプロイメントやマルチテナントアーキテクチャに最適です。

## 機能

- 🪣 **S3 バケット** - バージョニング有効化とセキュリティベストプラクティス
- 🌐 **CloudFront ディストリビューション** - Origin Access Control (OAC)付き
- 🔒 **ACM 証明書** - カスタムドメイン用に DNS 検証で自動作成
- 🌍 **Route53 DNS レコード** - ドメイン用の A および AAAA レコードを自動作成
- 📊 **クロスアカウント CloudWatch ログ** - CloudFront ログを別の AWS アカウントに配信
- 🛡️ **セキュリティファースト** - CloudFront のみアクセス可能なプライベート S3 バケット
- ⚡ **最適化されたパフォーマンス** - 圧縮、キャッシング、HTTP/2 有効
- 🔄 **自動キャッシュ無効化** - S3 アップロード時に CloudFront キャッシュを無効化する組み込み機能（柔軟なパスマッピング付き）
- 🎯 **CloudFront 関数サポート** - リクエスト/レスポンス操作用のカスタム関数をアタッチ
- 📁 **サブフォルダルートオブジェクト** - サブディレクトリ用に異なるインデックスファイルを提供する組み込み機能
- 🔗 **ワイルドカードドメインサポート** - ワイルドカード証明書とドメインの完全サポート

## 使用方法

### Terraform Registry から（推奨）

```hcl
provider "aws" {
  region = "us-east-1"
}

provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}

module "static_site" {
  source  = "thu-san/static-site/aws"
  version = "~> 2.0"

  s3_bucket_name               = "my-awesome-site-bucket"
  cloudfront_distribution_name = "my-awesome-site"

  tags = {
    Environment = "production"
    Project     = "my-awesome-site"
  }

  providers = {
    aws           = aws
    aws.us_east_1 = aws.us_east_1
  }
}
```

### GitHub から

```hcl
provider "aws" {
  region = "us-east-1"
}

provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}

module "static_site" {
  source = "git::https://github.com/thu-san/terraform-aws-static-site.git?ref=v2.0.0"

  s3_bucket_name               = "my-awesome-site-bucket"
  cloudfront_distribution_name = "my-awesome-site"

  tags = {
    Environment = "production"
    Project     = "my-awesome-site"
  }

  providers = {
    aws           = aws
    aws.us_east_1 = aws.us_east_1
  }
}
```

### カスタムドメイン使用時

```hcl
provider "aws" {
  region = "us-east-1"
}

provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}

module "static_site" {
  source = "path/to/terraform-aws-static-site"

  s3_bucket_name               = "my-awesome-site-bucket"
  cloudfront_distribution_name = "my-awesome-site"
  domain_names                 = ["example.com", "www.example.com"]

  tags = {
    Environment = "production"
    Project     = "my-awesome-site"
  }

  providers = {
    aws           = aws
    aws.us_east_1 = aws.us_east_1
  }
}
```

### Route53 DNS レコード使用時

```hcl
provider "aws" {
  region = "us-east-1"
}

provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}

module "static_site" {
  source = "path/to/terraform-aws-static-site"

  s3_bucket_name               = "my-awesome-site-bucket"
  cloudfront_distribution_name = "my-awesome-site"
  domain_names                 = ["example.com", "www.example.com"]
  hosted_zone_name             = "example.com"  # あなたのRoute53ホストゾーン名

  tags = {
    Environment = "production"
    Project     = "my-awesome-site"
  }

  providers = {
    aws           = aws
    aws.us_east_1 = aws.us_east_1
  }
}
```

### クロスアカウント CloudWatch ログ使用時

```hcl
provider "aws" {
  region = "us-east-1"
}

provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}

module "static_site" {
  source = "path/to/terraform-aws-static-site"

  s3_bucket_name               = "my-awesome-site-bucket"
  cloudfront_distribution_name = "my-awesome-site"
  domain_names                 = ["example.com"]

  # 集中ログアカウント（CloudFrontアカウントとは異なる）にログを配信
  log_delivery_destination_arn = "arn:aws:logs:us-east-1:ACCOUNT-ID:delivery-destination:central-logs"

  tags = {
    Environment = "production"
    Project     = "my-awesome-site"
  }

  providers = {
    aws           = aws
    aws.us_east_1 = aws.us_east_1
  }
}
```

### ワイルドカードドメインと CloudFront 関数使用時（PR プレビュー）

この例では、PR プレビューデプロイメント用のワイルドカードドメインと CloudFront 関数の使用方法を示します：

```hcl
provider "aws" {
  region = "us-east-1"
}

provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}

# PRルーティング用CloudFront関数
resource "aws_cloudfront_function" "pr_router" {
  name    = "pr-router"
  runtime = "cloudfront-js-2.0"
  comment = "PRサブドメインリクエストをS3サブフォルダにルーティング"
  publish = true

  code = <<-EOT
    function handler(event) {
      var request = event.request;
      var host = request.headers.host.value;

      // サブドメインからPR番号を抽出（例：pr123.dev.example.com）
      var prMatch = host.match(/^pr(\d+)\./);

      if (prMatch) {
        var prNumber = prMatch[1];
        // URIの前にPRフォルダを追加
        request.uri = '/pr' + prNumber + request.uri;
      }

      // URIが'/'で終わる場合、'index.html'を追加
      if (request.uri.endsWith('/')) {
        request.uri += 'index.html';
      }

      return request;
    }
  EOT
}

module "static_site" {
  source = "path/to/terraform-aws-static-site"

  s3_bucket_name               = "my-pr-preview-bucket"
  cloudfront_distribution_name = "my-pr-preview-site"

  # PRプレビュー用ワイルドカードを含む複数ドメイン
  domain_names = [
    "dev.example.com",
    "*.dev.example.com"  # pr123.dev.example.com用ワイルドカード
  ]

  hosted_zone_name = "example.com"

  # PRルーティング用CloudFront関数をアタッチ
  cloudfront_function_associations = [{
    event_type   = "viewer-request"
    function_arn = aws_cloudfront_function.pr_router.arn
  }]

  tags = {
    Environment = "development"
    Project     = "pr-preview"
  }

  providers = {
    aws           = aws
    aws.us_east_1 = aws.us_east_1
  }
}
```

この設定により：

- メインブランチのコンテンツは S3 ルートへ → `dev.example.com`でアクセス可能
- PR #123 のコンテンツは S3 `/pr123/`フォルダへ → `pr123.dev.example.com`でアクセス可能
- PR #456 のコンテンツは S3 `/pr456/`フォルダへ → `pr456.dev.example.com`でアクセス可能

### サブフォルダルートオブジェクト使用時

CloudFront がサブフォルダから自動的にデフォルトオブジェクトを提供する必要がある場合（例：`/about/` → `/about/index.html`）、組み込みのサブフォルダルートオブジェクト機能を使用できます：

```hcl
module "static_site" {
  source = "path/to/terraform-aws-static-site"

  s3_bucket_name               = "my-site-bucket"
  cloudfront_distribution_name = "my-site"

  # サブフォルダリクエストのデフォルトオブジェクトとしてindex.htmlを自動的に提供
  subfolder_root_object = "index.html"

  # オプションで異なるルートオブジェクトを使用（例：ルートは"home.html"、サブフォルダは"index.html"）
  default_root_object = "index.html"

  providers = {
    aws           = aws
    aws.us_east_1 = aws.us_east_1
  }
}
```

これにより、指定されたルートオブジェクトをサブディレクトリパス（ルートパスを除く）に自動的に追加する CloudFront 関数が作成されます：

- `/` → CloudFront の`default_root_object`を使用（例：`/index.html`）
- `/about/` → `/about/index.html`（`subfolder_root_object`を使用）
- `/products/` → `/products/index.html`（`subfolder_root_object`を使用）
- `/blog/post-1/` → `/blog/post-1/index.html`（`subfolder_root_object`を使用）

これにより、必要に応じてルートとサブフォルダで異なるデフォルトファイルを使用できます。

### CloudFront キャッシュポリシー

このモジュールは、`cache_policy_id` が指定されていない場合、デフォルトで AWS マネージド「CachingOptimized」キャッシュポリシーを使用します。データソースを使用して名前で AWS マネージドポリシーを参照することで、異なるポリシーを指定することができます：

```hcl
# 例：デフォルトの動作を使用（CachingOptimized）
module "static_site" {
  source = "path/to/terraform-aws-static-site"

  s3_bucket_name               = "my-site-bucket"
  cloudfront_distribution_name = "my-site"

  # cache_policy_id はオプション - デフォルトで CachingOptimized を使用

  providers = {
    aws           = aws
    aws.us_east_1 = aws.us_east_1
  }
}
```

```hcl
# 例：キャッシュを無効化
data "aws_cloudfront_cache_policy" "caching_disabled" {
  name = "Managed-CachingDisabled"
}

module "static_site" {
  source = "path/to/terraform-aws-static-site"

  s3_bucket_name               = "my-site-bucket"
  cloudfront_distribution_name = "my-site"

  cache_policy_id = data.aws_cloudfront_cache_policy.caching_disabled.id

  providers = {
    aws           = aws
    aws.us_east_1 = aws.us_east_1
  }
}
```

```hcl
# 例：カスタムキャッシュおよびオリジンリクエストポリシー
data "aws_cloudfront_cache_policy" "caching_optimized" {
  name = "Managed-CachingOptimized"
}

data "aws_cloudfront_origin_request_policy" "cors_s3_origin" {
  name = "Managed-CORS-S3Origin"
}

module "static_site" {
  source = "path/to/terraform-aws-static-site"

  s3_bucket_name               = "my-site-bucket"
  cloudfront_distribution_name = "my-site"

  cache_policy_id          = data.aws_cloudfront_cache_policy.caching_optimized.id
  origin_request_policy_id = data.aws_cloudfront_origin_request_policy.cors_s3_origin.id

  providers = {
    aws           = aws
    aws.us_east_1 = aws.us_east_1
  }
}
```

利用可能な AWS マネージドポリシー：
- **キャッシュポリシー**：
  - `Managed-CachingDisabled` - キャッシュなし、すべてのリクエストがオリジンに送信される
  - `Managed-CachingOptimized` - キャッシュヒット率に最適化（デフォルト）
  - `Managed-CachingOptimizedForUncompressedObjects` - すでに圧縮されたコンテンツ用

- **オリジンリクエストポリシー**：
  - `Managed-CORS-S3Origin` - S3 オリジンへの CORS リクエスト用
  - `Managed-AllViewer` - すべてのヘッダー、Cookie、クエリ文字列を転送
  - `Managed-CORS-CustomOrigin` - カスタムオリジンへの CORS リクエスト用

- **レスポンスヘッダーポリシー**：
  - `Managed-CORS-With-Preflight` - プリフライトリクエスト用の CORS ヘッダー
  - `Managed-CORS-with-preflight-and-SecurityHeadersPolicy` - CORS + セキュリティヘッダー
  - `Managed-SecurityHeadersPolicy` - 一般的なセキュリティヘッダー

### カスタムエラーページ使用時（SPAサポート）

シングルページアプリケーション（SPA）のクライアントサイドルーティングに不可欠な、CloudFront のカスタムエラーレスポンスを設定できます：

```hcl
module "static_site" {
  source = "path/to/terraform-aws-static-site"

  s3_bucket_name               = "my-spa-bucket"
  cloudfront_distribution_name = "my-spa-site"

  # SPA クライアントサイドルーティング用のエラーレスポンス設定
  custom_error_responses = [
    {
      error_code         = 403
      response_code      = 200
      response_page_path = "/index.html"
    },
    {
      error_code         = 404
      response_code      = 200
      response_page_path = "/index.html"
    }
  ]

  providers = {
    aws           = aws
    aws.us_east_1 = aws.us_east_1
  }
}
```

より良いユーザーエクスペリエンスのためにカスタムエラーページを設定することもできます：

```hcl
custom_error_responses = [
  {
    error_code            = 404
    response_code         = 404
    response_page_path    = "/errors/404.html"
    error_caching_min_ttl = 300  # 5分間キャッシュ
  },
  {
    error_code         = 500
    response_code      = 500
    response_page_path = "/errors/500.html"
    error_caching_min_ttl = 60   # 1分間キャッシュ
  }
]
```

### 自動キャッシュ無効化使用時

キャッシュ無効化機能はメインモジュールに直接組み込まれています - サブモジュールは不要です。有効にすると、Lambda 関数、SQS キュー、IAM ロールを含む必要なすべての AWS リソースが自動的に作成されます。

```hcl
provider "aws" {
  region = "us-east-1"
}

provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}

module "static_site" {
  source = "path/to/terraform-aws-static-site"

  s3_bucket_name               = "my-awesome-site-bucket"
  cloudfront_distribution_name = "my-awesome-site"

  # 自動キャッシュ無効化を有効化
  enable_cache_invalidation = true

  # オプション1：ダイレクトモード（正確なパスを無効化）
  invalidation_mode = "direct"

  # オプション2：正規表現マッピングを使用したカスタムモード
  invalidation_mode = "custom"
  invalidation_path_mappings = [
    {
      source_pattern     = "^images/.*"
      invalidation_paths = ["/images/*"]
      description        = "画像アップロード時にすべての画像を無効化"
    },
    {
      source_pattern     = "^(index\\.html|home\\.html)$"
      invalidation_paths = ["/*"]
      description        = "ホームページ変更時にルートを無効化"
    }
  ]

  tags = {
    Environment = "production"
    Project     = "my-awesome-site"
  }

  providers = {
    aws           = aws
    aws.us_east_1 = aws.us_east_1
  }
}
```

## 要件

| 名前      | バージョン |
| --------- | ---------- |
| terraform | >= 1.0     |
| aws       | >= 5.0     |

## プロバイダー

このモジュールには 2 つの AWS プロバイダー設定が必要です：

| 名前          | バージョン | 目的                                       |
| ------------- | ---------- | ------------------------------------------ |
| aws           | >= 5.0     | すべてのリソース用のプライマリプロバイダー |
| aws.us_east_1 | >= 5.0     | ACM 証明書に必要（CloudFront 要件）        |

**重要**: このモジュールを使用する際は、両方のプロバイダーを設定する必要があります：

```hcl
provider "aws" {
  region = "your-region"
}

provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}

module "static_site" {
  source = "thu-san/static-site/aws"

  # ... 設定内容 ...

  providers = {
    aws           = aws
    aws.us_east_1 = aws.us_east_1
  }
}
```

## 入力変数

| 名前                             | 説明                                                                                                     | 型             | デフォルト     |  必須  |
| -------------------------------- | -------------------------------------------------------------------------------------------------------- | -------------- | -------------- | :----: |
| s3_bucket_name                   | 静的サイトホスティング用 S3 バケット名                                                                   | `string`       | n/a            |  はい  |
| cloudfront_distribution_name     | CloudFront ディストリビューションの名前/コメント                                                         | `string`       | n/a            |  はい  |
| domain_names                     | CloudFront ディストリビューション用ドメイン名リスト                                                      | `list(string)` | `[]`           | いいえ |
| hosted_zone_name                 | DNS レコード作成用 Route53 ホストゾーン名（例："example.com"）                                           | `string`       | `""`           | いいえ |
| log_delivery_destination_arn     | CloudWatch ログ配信先の ARN                                                                              | `string`       | `""`           | いいえ |
| s3_delivery_configuration        | CloudWatch ログ用 S3 配信設定                                                                            | `list(object)` | 下記参照       | いいえ |
| log_record_fields                | 含める CloudWatch ログレコードフィールドのリスト                                                         | `list(string)` | `[]`           | いいえ |
| enable_cache_invalidation        | S3 アップロード時の自動キャッシュ無効化を有効化                                                          | `bool`         | `false`        | いいえ |
| invalidation_mode                | キャッシュ無効化モード：'direct'または'custom'                                                           | `string`       | `"direct"`     | いいえ |
| invalidation_path_mappings       | キャッシュ無効化用カスタムパスマッピング                                                                 | `list(object)` | `[]`           | いいえ |
| invalidation_sqs_config          | バッチ処理用 SQS 設定                                                                                    | `object`       | 下記参照       | いいえ |
| invalidation_lambda_config       | Lambda 関数設定                                                                                          | `object`       | 下記参照       | いいえ |
| invalidation_dlq_arn             | DLQ として使用する既存の SQS キューの ARN                                                                | `string`       | `""`           | いいえ |
| cloudfront_function_associations | デフォルトキャッシュ動作用 CloudFront 関数アソシエーションのリスト                                       | `list(object)` | `[]`           | いいえ |
| default_root_object              | ルート URL へのリクエスト時に CloudFront が返すオブジェクト                                              | `string`       | `"index.html"` | いいえ |
| subfolder_root_object            | 設定時、サブフォルダリクエストのデフォルトオブジェクトとしてこのファイルを提供する CloudFront 関数を作成 | `string`       | `""`           | いいえ |
| custom_error_responses           | CloudFront のカスタムエラーレスポンス設定のリスト（SPA ルーティング用の例を参照）                       | `list(object)` | `[]`           | いいえ |
| skip_certificate_validation      | ACM 証明書の DNS 検証レコードをスキップ（テスト用に便利）                                                | `bool`         | `false`        | いいえ |
| tags                             | すべてのリソースに適用するタグ                                                                           | `map(string)`  | `{}`           | いいえ |

## 出力変数

| 名前                                      | 説明                                          |
| ----------------------------------------- | --------------------------------------------- |
| bucket_id                                 | S3 バケットの名前                             |
| bucket_arn                                | S3 バケットの ARN                             |
| bucket_regional_domain_name               | S3 バケットのリージョナルドメイン名           |
| cloudfront_distribution_id                | CloudFront ディストリビューションの ID        |
| cloudfront_distribution_arn               | CloudFront ディストリビューションの ARN       |
| cloudfront_distribution_domain_name       | CloudFront ディストリビューションのドメイン名 |
| cloudfront_distribution_hosted_zone_id    | CloudFront Route 53 ゾーン ID                 |
| cloudfront_oac_id                         | CloudFront Origin Access Control の ID        |
| acm_certificate_arn                       | ACM 証明書の ARN                              |
| acm_certificate_domain_validation_options | ACM 証明書のドメイン検証オプション            |
| route53_record_names                      | 作成された Route53 A レコードの名前           |
| route53_record_fqdns                      | 作成された Route53 A レコードの FQDN          |
| lambda_function_arn                       | キャッシュ無効化 Lambda 関数の ARN            |
| lambda_log_group_arn                      | Lambda CloudWatch ロググループの ARN          |
| sqs_queue_url                             | キャッシュ無効化用 SQS キューの URL           |
| sqs_queue_arn                             | キャッシュ無効化用 SQS キューの ARN           |

## アーキテクチャ

このモジュールは以下の AWS リソースを作成します：

1. **S3 バケット** - 以下を備えたプライベートバケット：

   - バージョニング有効
   - パブリックアクセスブロック
   - CloudFront のみアクセスを許可するバケットポリシー

2. **CloudFront ディストリビューション** - 以下を備えた：

   - セキュアな S3 アクセスのための Origin Access Control (OAC)
   - ACM 証明書によるカスタムドメインサポート
   - 最適化されたキャッシングポリシー
   - 圧縮有効
   - TLS 1.2 最小

3. **ACM 証明書** （domain_names 提供時）：

   - us-east-1 で自動作成
   - 自動 Route53 レコード作成による DNS 検証（hosted_zone_name 提供時）
   - 複数ドメイン/サブドメインサポート
   - **ワイルドカードドメインサポート**（例：`*.dev.example.com`）
   - 最初のドメインがプライマリ、その他は Subject Alternative Names (SANs)

4. **CloudWatch ログ** （log_delivery_destination_arn 提供時）：

   - 利用可能なすべてのフィールドを含むアクセスログ
   - **クロスアカウント配信サポート** - 異なる AWS アカウントへログ送信
   - 集中ログとコンプライアンス要件に最適

5. **Route53 DNS レコード** （hosted_zone_name と domain_names 提供時）：

   - 各ドメイン用の A レコード（IPv4）を自動作成
   - 各ドメイン用の AAAA レコード（IPv6）を自動作成
   - CloudFront ディストリビューションを指すエイリアスレコード使用

6. **キャッシュ無効化** （enable_cache_invalidation が true の場合）：
   - **SQS キュー**：効率的な処理のため S3 イベントをバッチ処理（`sqs_invalidation.tf`に作成）
   - **Lambda 関数**：イベントを処理し CloudFront 無効化を作成（`lambda_invalidation.tf`に作成）
   - **Lambda コード**：`./lambda_code/cache_invalidation/index.py`にある Python 関数
   - **柔軟なパスマッピング**：ダイレクトモードまたはカスタム正規表現ベースのマッピング
   - **コスト最適化**：パスの重複排除とワイルドカード使用
   - **モニタリング**：デバッグ用 CloudWatch ログと DLQ サポート

## セキュリティ考慮事項

- S3 バケットは完全にプライベート - 直接パブリックアクセスなし
- CloudFront はセキュアなバケットアクセスのため Origin Access Control (OAC)を使用
- 最小 TLS 1.2 を強制
- すべての S3 パブリックアクセス設定をブロック
- データ保護のためバージョニング有効

## テスト

このモジュールには、すべての機能が正しく動作することを確認する包括的なテストが含まれています。

### テストの実行

1. **クイック検証**：

   ```bash
   cd test
   ./validate.sh
   ```

2. **Terraform ネイティブテスト**：

   ```bash
   terraform test
   ```

3. **手動テスト**：

   ```bash
   # フォーマットチェック
   terraform fmt -check -recursive

   # モジュール検証
   terraform init
   terraform validate

   # テスト値でプラン
   terraform plan -var="s3_bucket_name=test-bucket" -var="cloudfront_distribution_name=test-dist"
   ```

### テストカバレッジ

テストスイートは以下をカバーします：

- ✅ 基本的な S3 と CloudFront 設定
- ✅ ACM 証明書を使用したカスタムドメイン
- ✅ Route53 DNS レコード作成
- ✅ クロスアカウント CloudWatch ログ配信
- ✅ リソースタグ付け
- ✅ セキュリティ設定（プライベートバケット、OAC）
- ✅ 出力検証
- ✅ ネガティブテストケース

## デフォルト値

### S3 配信設定

CloudWatch ログ用のデフォルト S3 配信設定：

```hcl
s3_delivery_configuration = [
  {
    suffix_path                 = "/{account-id}/{DistributionId}/{yyyy}/{MM}/{dd}/{HH}"
    enable_hive_compatible_path = false
  }
]
```

これにより以下のようなフォルダ構造が作成されます：

- `/123456789012/E1ABCD23EFGH/2024/01/15/10/` - アカウント 123456789012、ディストリビューション E1ABCD23EFGH、2024 年 1 月 15 日 10 時のログ

独自の設定を提供してカスタマイズできます：

```hcl
provider "aws" {
  region = "us-east-1"
}

provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}

module "static_site" {
  source = "path/to/terraform-aws-static-site"

  # ... その他の変数 ...

  s3_delivery_configuration = [
    {
      suffix_path                 = "/cloudfront/{DistributionId}/{yyyy}-{MM}-{dd}"
      enable_hive_compatible_path = false
    }
  ]

  providers = {
    aws           = aws
    aws.us_east_1 = aws.us_east_1
  }
}
```

### キャッシュ無効化設定

キャッシュ無効化機能は、すべての SQS および Lambda 設定に対して適切なデフォルト値を使用します。すべての属性はオプションです - 指定されない場合、以下のデフォルトが適用されます：

#### SQS 設定のデフォルト

```hcl
invalidation_sqs_config = {
  batch_window_seconds   = # デフォルト：60秒 - メッセージバッチの時間ウィンドウ
  batch_size             = # デフォルト：100 - バッチで処理する最大メッセージ数
  message_retention_days = # デフォルト：4日 - キューでメッセージを保持する期間
  visibility_timeout     = # デフォルト：300秒 - メッセージ可視性タイムアウト
}
```

#### Lambda 設定のデフォルト

```hcl
invalidation_lambda_config = {
  memory_size          = # デフォルト：128 MB - Lambdaメモリ割り当て
  timeout              = # デフォルト：300秒 - Lambda関数タイムアウト
  reserved_concurrency = # デフォルト：null - 同時実行制限なし（アカウント制限を使用）
  log_retention_days   = # デフォルト：7日 - CloudWatchログ保持期間
}
```

デフォルトを維持しながら特定の値をオーバーライドできます：

```hcl
provider "aws" {
  region = "us-east-1"
}

provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}

module "static_site" {
  source = "path/to/terraform-aws-static-site"

  # ... その他の変数 ...

  enable_cache_invalidation = true

  # 特定のSQS設定のみオーバーライド
  invalidation_sqs_config = {
    batch_size = 50  # より小さなバッチを処理
    # その他の値はデフォルトを使用
  }

  # 特定のLambda設定のみオーバーライド
  invalidation_lambda_config = {
    memory_size = 256  # メモリを増やす
    timeout     = 600  # タイムアウトを増やす
    # その他の値はデフォルトを使用
  }

  providers = {
    aws           = aws
    aws.us_east_1 = aws.us_east_1
  }
}
```

## 例

完全な例については、[examples](./examples/)ディレクトリを参照してください：

- [基本的な使用法](./examples/basic/) - シンプルな静的ウェブサイトホスティング
- [カスタムドメイン使用例](./examples/with-custom-domain/) - ACM 証明書付きカスタムドメインの使用
- [SPAエラーハンドリング例](./examples/spa-with-error-handling/) - クライアントサイドルーティング付きシングルページアプリケーション
- [キャッシュ無効化使用例](./examples/with-cache-invalidation/) - 自動 CloudFront キャッシュ無効化
- [CloudWatch ログ使用例](./examples/with-logging/) - クロスアカウントログ配信
- [サブフォルダルートオブジェクト使用例](./examples/with-subfolder-root-object/) - サブディレクトリからインデックスファイルを提供
- [PR プレビュー環境](./examples/with-pr-preview/) - PR プレビュー用ワイルドカードドメイン
- [SPAサポート付きPRプレビュー](./examples/with-pr-spa-preview/) - フル SPA ルーティングサポート付き PR プレビュー

## ライセンス

Apache License 2.0

## 著者

モジュールは[Thu San]により管理されています。
