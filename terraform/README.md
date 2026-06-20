# ECS Fargate Web 三層基盤 (Terraform)

AWS 上に ECS Fargate ベースの Web 三層アーキテクチャを、Terraform のモジュール構成で構築するための設計リポジトリです。

## 1. 要件サマリ

### AWS アーキテクチャ

| 項目 | 内容 |
| --- | --- |
| コンピュート | ECS Fargate |
| アーキテクチャ | 基本的な Web 三層 (web / app / data) |
| ネットワーク区分 | `public` / `dmz` / `private` の 3 サブネット階層 |
| Fargate 配置 | `dmz` サブネット |
| ECR イメージ取得 | VPC エンドポイント経由 (ECR api/dkr, S3 Gateway, CloudWatch Logs) |
| 外向き通信 | NAT Gateway 経由 (`private` 経路) |
| アクセスログ | CloudWatch Logs に出力 |
| CDN | CloudFront なし。SSL 終端は ALB |
| 証明書 | ACM (ALB にアタッチ) |
| WAF | ALB に AWS マネージドルール (無料の Web 用ルール) を適用 |
| DB | PostgreSQL (RDS。Aurora ではない) |
| DNS | 既存 Route53 ホストゾーンを利用。ALB / ACM の CNAME を登録 |
| CI/CD | CodePipeline (main プッシュで自動起動) → CodeBuild → CodeDeploy(ECS Blue/Green) |
| GitHub 接続 | CodeStar Connections Connection を利用 |

### ネットワーク階層の役割

- **public**: Internet Gateway / ALB / NAT Gateway を配置。インターネットからの受信口。
- **dmz**: ECS Fargate (web/app タスク) を配置。VPC CIDR 範囲からの通信をすべて許可。外向きは NAT 経由。
- **private**: RDS (PostgreSQL) を配置。dmz からのみ受信。インターネット経路なし。

### 通信フロー

```
Internet
  │ (HTTPS:443 本番 / HTTPS:8443 テスト)
  ▼
[ALB (public)] ── WAF (AWS Managed Rules) / ACM 証明書で SSL 終端
  │   ├─ 443  → blue TG  (本番)
  │   └─ 8443 → green TG (Blue/Green 検証)
  ▼
[ECS Fargate (dmz)]  ← VPC CIDR 範囲からの通信をすべて許可
  ├─ ECR / Logs / S3 へ ──► VPC Endpoint (Interface / Gateway)
  ├─ その他外部通信 ──► NAT Gateway (public) ──► IGW
  └─ DB アクセス ──► [RDS PostgreSQL (private)]

GitHub(main push) ─► CodePipeline ─► CodeBuild(ECR push) ─► CodeDeploy(B/G) ─► ECS
```

## 2. Terraform 設計方針

- **リソースは全てモジュール化**。モジュールは AWS リソース単位で作成する。
- **ルートモジュールは環境ごとに分割** (`environments/dev`, `stg`, `prod`)。
- 各環境ルートが必要なモジュールを呼び出し、環境固有値を `terraform.tfvars` で注入する。
- State はリモートバックエンド (S3 + DynamoDB Lock) を想定。環境ごとに key を分離。
- **IAM は独立モジュールにしない**。各 AWS リソースが必要とする IAM ロール/ポリシーは、そのリソースのモジュール内に定義してアタッチする。
  - ECS の実行ロール/タスクロール → `modules/ecs/ecs.tf`
  - CodeBuild / CodePipeline のロール → `modules/codepipeline/codepipeline.tf`
  - CodeDeploy のロール → `modules/codedeploy/codedeploy.tf`
- **モジュール内ファイルはリソース単位のディレクトリ構成**とし、メインファイルは `<resource>.tf`、加えて `variables.tf` / `outputs.tf` を置く。

  ```
  modules/ecs/
  ├── ecs.tf          # ECS リソース + ECS 用 IAM
  ├── variables.tf
  └── outputs.tf
  ```

### ディレクトリ構成

```
terraform-ecs/
├── README.md
├── examples/github-repo-files/   # GitHub リポジトリ側に置く CI/CD 定義サンプル
│   ├── buildspec.yml             # CodeBuild: docker build & ECR push
│   ├── appspec.yaml              # CodeDeploy(ECS B/G) 定義
│   └── taskdef.json              # CodeDeploy 用タスク定義テンプレート
├── modules/                      # AWS リソース単位のモジュール (IAM は各モジュールに内包)
│   ├── network/                  # network.tf       VPC, Subnet(public/dmz/private), IGW, NATGW, RT
│   ├── security_group/           # security_group.tf ALB / ECS / RDS / VPCE 用 SG
│   ├── vpc_endpoint/             # vpc_endpoint.tf   ECR(api/dkr), S3(Gateway), Logs, STS
│   ├── alb/                      # alb.tf            ALB, Listener(443/8443/80), TG blue/green
│   ├── acm/                      # acm.tf            ACM 証明書 (DNS 検証)
│   ├── waf/                      # waf.tf            WAFv2 WebACL + AWS Managed Rules
│   ├── route53/                  # route53.tf        既存ホストゾーンへの ALIAS レコード
│   ├── ecs/                      # ecs.tf            ECS + ECS 用 IAM ロール
│   ├── ecr/                      # ecr.tf            ECR リポジトリ
│   ├── rds/                      # rds.tf            RDS PostgreSQL
│   ├── cloudwatch_logs/          # cloudwatch_logs.tf ロググループ
│   ├── codestar_connection/      # codestar_connection.tf GitHub 接続
│   ├── codedeploy/               # codedeploy.tf     CodeDeploy(B/G) + CodeDeploy 用 IAM
│   └── codepipeline/             # codepipeline.tf   CodePipeline/CodeBuild + 各 IAM, S3
└── environments/                 # 環境ごとのルートモジュール
    ├── dev/
    ├── stg/
    └── prod/
```

各モジュールは `<resource>.tf` / `variables.tf` / `outputs.tf` の 3 ファイル構成。IAM ロール/ポリシーは独立モジュールを作らず、それを必要とするリソースの `<resource>.tf` 内に定義する。

各環境ディレクトリの構成:

```
environments/<env>/
├── backend.tf       # リモート State 設定
├── providers.tf     # provider aws 設定
├── versions.tf      # required_version / required_providers
├── main.tf          # 各モジュール呼び出し
├── variables.tf     # 入力変数定義
├── outputs.tf       # 出力
└── terraform.tfvars # 環境固有の値
```

## 3. モジュール依存関係

```
network ──► security_group ──► vpc_endpoint
   │                │
   │                ├──► alb ◄── acm ◄── route53(検証)
   │                │      └──► waf
   │                ├──► ecs (ECS用IAM内包) ◄── ecr / cloudwatch_logs
   │                └──► rds
   │
route53 ◄── alb (ALIAS 登録)
codestar_connection ─┐
ecs / alb ──► codedeploy (CodeDeploy用IAM内包)
       └──► codepipeline (CodeBuild/Pipeline用IAM内包) ◄── ecr / codedeploy / codestar_connection
```

※ IAM は独立モジュールではなく、各モジュール内に内包。

## 4. 主要な設計上の判断

### AWSリソースの命名規則
<PROJECT>-<ENV>-<RESOURCE>
- <PROJECT> と <ENV> はルートモジュールのvariables.tfに記載する。
- <RESOURCE> は各AWSリソース名を記入する。

### VPC エンドポイント
ECR からのイメージ取得を NAT に頼らずプライベート完結させるため、以下を作成する。
- Interface Endpoint: `ecr.api`, `ecr.dkr`, `logs` (CloudWatch Logs), 必要に応じて `sts`
- Gateway Endpoint: `s3` (ECR のレイヤ実体は S3 上にあるため必須)

その他の外向き通信 (パッケージ取得, 外部 API 等) は NAT Gateway 経由とする。

### SSL / WAF
CloudFront を使わないため、ALB の HTTPS:443 Listener に ACM 証明書をアタッチして SSL 終端する。WAFv2 WebACL は ALB に関連付け、`AWSManagedRulesCommonRuleSet` など無料のマネージドルールを適用する。

### DNS / 証明書検証
ACM は DNS 検証を採用し、検証用 CNAME を既存 Route53 ホストゾーンに登録する。サービス公開用には ALB への ALIAS (A) レコードを同ホストゾーンに登録する。

### 秘匿情報の取り扱い
Terraformの実行に利用するIAMユーザー情報, ドメイン名, DBパスワード などはterraform.tfvarsに記載し、GitHub上には上がらないようにする

### ECSのタスク定義について
タスク定義内の"image"にはECRのレポジトリURLを指定する

### CI/CD

GitHub の `main` ブランチへのプッシュを CodePipeline が検知して自動起動する (CodeStar Connections 経由、`DetectChanges=true`)。フローは Source → Build → Deploy:

1. **Source**: CodeStar Connections で接続した GitHub から `main` を取得。
2. **Build (CodeBuild)**: `buildspec.yml` に従い Docker イメージをビルドして ECR に push。`taskdef.json` / `appspec.yaml` を成果物として出力。
3. **Deploy (CodeDeploy / ECS Blue/Green)**: 新タスクを green Target Group に起動 → テストリスナー(8443)で検証 → 本番リスナー(443)を green に切替 → 旧 blue を一定時間後に終了。失敗時は自動ロールバック。

ECS サービスは `deployment_controller = CODE_DEPLOY` とし、ALB には blue/green の Target Group 2 系統と本番(443)リスナーを用意する。GitHub リポジトリ側には `examples/github-repo-files/` のサンプル(`buildspec.yml` / `appspec.yaml` / `taskdef.json`)を配置する。

### CI/CD ロールの所在
CodeBuild・CodePipeline 用ロールは `modules/codepipeline` 内、CodeDeploy 用ロールは `modules/codedeploy` 内で定義する (IAM 単独モジュールは作らない)。

## 5. 前提・手動作業

- 既存の Route53 ホストゾーン (zone_id) が存在すること。
- 既存の GitHub リポジトリへのアクセス権があること。
- CodeStar Connections の接続承認は **初回のみ AWS コンソールで手動承認** が必要。
- GitHub リポジトリのルートに `buildspec.yml` / `appspec.yaml` / `taskdef.json` を配置する (`examples/github-repo-files/` 参照)。`taskdef.json` 内の `<EXECUTION_ROLE_ARN>` / `<TASK_ROLE_ARN>` は ECS モジュールの出力値に、`family`・ロググループ名は環境に合わせて差し替える。
- State 用の S3 バケット / DynamoDB テーブルは事前に作成しておく (またはブートストラップ用構成を別途用意)。
- RDS のマスターパスワードは tfvars に直書きせず、`TF_VAR_` 環境変数または Secrets Manager 参照を推奨。