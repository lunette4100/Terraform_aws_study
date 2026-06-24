# 概要
このリポジトリはTerraformによるAWSインフラ環境構築とGitHubActionsのワークフローを通してCI/CD環境を構築できる構成を記載しています。

## 実装内容
CD環境構築としてアプリケーションの起動までを想定しています。DBの設定は手動で行ってください。
### Terraform
VPC / EC2 / RDS / ALB / CloudWatch Alarm / WAF / CloudWatch Logs 
### Github Actions（CI/CD）
・ワークフロー起動について
Terraformブランチにおけるpushもしくはpull requestで起動します。

・ワークフロー内容について
Ansible_workflow:AWS環境のDeployからAnsibleのPlaybookを起動します。
destroy_workflow:構築したAWS環境を削除します。（手動起動）
Ansible_springboot_kill:EC2で起動するSpringbootの停止を行います。（手動起動）

### Ansible
構築したAWS環境のEC2に接続し、Java21・Gitをインストールし、webアプリケーションをgit colneにて取り込み、実行を行います。

## 構築前準備
1. AWSアカウント・GitHubアカウントを用意
2. IAMロール（CloudWatch/CloudWatch Logs/EC2/ELB/ELB v2/IAM/RDS/S3/SNS/WAF V2 ）作成権限をもつポリシーをアタッチしたもの
3. S3バケット（バックエンドに使用）の作成
4. GitHub OIDCを設定
5. GitHub Secrets（ASSUME_ROLE_ARN/AWS_SSH_PRIVATE_KEY/TF_VAR_KEY_NAME/TF_VAR_RDS_PASSWORD/TF_VAR_SNS_EMAIL_ADDRESS）を設定
6. tfstateファイル保管用S3を事前作成 

## 実行手順
1. Terraformブランチへpushもしくはpull requestを行う。
2. ワークフローterraform_applyとansibleが起動しApply。
3. 仕様変更があり、再度構築する前は必ず手動ワークフローSpringboot_killとDestroyを実行してください。また、Destroy前はコンソール画面でRDSとCloudWatch Logsの削除保護を無効にしてから起動してください。
## ディレクトリ構成

```
.
├─README.md
├─.github/
│  └─workflows/
│      ├─Ansible_springboot_kill.yaml
│      ├─Ansible_workflow.yaml
│      └─destroy_workflow.yaml
├─Study-Ansible/
│  └─Ansible/
│      ├─inventory.ini
│      └─playbook.yaml
└─Terraform_aws/
    └─Terraform_code/
        ├─alb.tf
        ├─backend.tf
        ├─cloudwatch.tf
        ├─cloudwatchlogs.tf
        ├─ec2.tf
        ├─outputs.tf
        ├─provider.tf
        ├─rds.tf
        ├─sg2.tf
        ├─test.auto.tfvars
        ├─testcode.tftest.hcl
        ├─variables.tf
        ├─vpc.tf
        └─waf.tf
```
## インフラ構成

| 分類 | リソース名 | Terraform リソース | 主な役割 / 設定値 |
|---|---|---|---|
| Terraform設定 | Terraform本体 | `terraform` | Terraform バージョンは `>= 1.6.0`、AWS Provider は `hashicorp/aws ~> 6.0`。 |
| Provider | AWS Provider | `provider "aws"` | リージョンは `ap-northeast-1`（東京リージョン）。 |
| 変数 | VPC CIDR | `variable "cidr_block"` | VPC の CIDR はデフォルト `10.0.0.0/16`。 |
| 変数 | EC2キーペア名 | `variable "key_name"` | EC2 に設定するキーペア名を文字列で受け取る。 |
| 変数 | Availability Zones | `variable "default_az"` | 使用 AZ は `ap-northeast-1a` と `ap-northeast-1c` の2つ。 |
| 変数 | RDSパスワード | `variable "rds_password"` | RDS 用パスワードを機密値として受け取る。 |
| 変数 | SNS通知先メール | `variable "sns_email_address"` | CloudWatch Alarm 通知先メールアドレスを受け取る。 |
| ネットワーク | VPC | `aws_vpc.vpc` | DNS Hostname / DNS Support を有効化した VPC。Name タグは `terraform-study-vpc`。 |
| ネットワーク | Internet Gateway | `aws_internet_gateway.igw` | VPC にアタッチする IGW。Name タグは `terraform-study-igw`。 |
| ネットワーク | Public Subnet A | `aws_subnet.publicsubnet_A` | `10.0.1.0/24`、AZ は `ap-northeast-1a`、パブリック IP 自動付与あり。 |
| ネットワーク | Public Subnet B | `aws_subnet.publicsubnet_B` | `10.0.2.0/24`、AZ は `ap-northeast-1c`、パブリック IP 自動付与あり。 |
| ネットワーク | Private Subnet A | `aws_subnet.privatesubnet_A` | `10.0.11.0/24`、AZ は `ap-northeast-1a` のプライベートサブネット。 |
| ネットワーク | Private Subnet B | `aws_subnet.privatesubnet_B` | `10.0.12.0/24`、AZ は `ap-northeast-1c` のプライベートサブネット。 |
| ルーティング | Route Table | `aws_route_table.routetable` | VPC 用のルートテーブル。 |
| ルーティング | Default Route | `aws_route.route` | `0.0.0.0/0` を Internet Gateway に向けるルート。 |
| ルーティング | Public Subnet A 関連付け | `aws_route_table_association.public-routetable-a` | Public Subnet A をルートテーブルに関連付け。 |
| ルーティング | Public Subnet B 関連付け | `aws_route_table_association.public-routetable-b` | Public Subnet B をルートテーブルに関連付け。 |
| コンピュート | EC2 | `aws_instance.tf_ec2` | `t3.micro` の EC2 を Public Subnet A に配置、AMI は `ami-0f18986364089c4ab`。 |
| コンピュート | EC2接続設定 | `aws_instance.tf_ec2` | セキュリティグループは `ec2_sg` と `ec2_ssh` を使用し、キーペアは `var.key_name`。 |
| IAM | EC2用IAMロール | `aws_iam_role.ssm_ec2_iam_role` | EC2 が引き受ける SSM 用 IAM ロール `ssm_ec2`。 |
| IAM | SSMポリシー付与 | `aws_iam_role_policy_attachment.ssm_ec2_core` | `AmazonSSMManagedInstanceCore` を IAM ロールにアタッチ。 |
| IAM | インスタンスプロファイル | `aws_iam_instance_profile.ec2_instance_profile_ssm` | EC2 用インスタンスプロファイル `ec2_instance_profile_ssm`。 |
| セキュリティ | EC2アプリ用SG | `aws_security_group.ec2_sg` | ALB からの 80/8080 を許可する EC2 用 SG。 |
| セキュリティ | EC2 HTTP受信 | `aws_vpc_security_group_ingress_rule.ec2_in_http` | ALB の SG から 80/TCP を許可。 |
| セキュリティ | EC2 App受信 | `aws_vpc_security_group_ingress_rule.ec2_in_application` | ALB の SG から 8080/TCP を許可。 |
| セキュリティ | EC2送信 | `aws_vpc_security_group_egress_rule.ec2_eg` | EC2 アプリ用 SG から全送信を許可。 |
| セキュリティ | EC2 SSH用SG | `aws_security_group.ec2_ssh` | SSH 接続専用 SG。 |
| セキュリティ | SSH受信 | `aws_vpc_security_group_ingress_rule.ec2_in_ssh` | `153.175.16.24/32` から 22/TCP を許可。 |
| セキュリティ | SSH送信 | `aws_vpc_security_group_egress_rule.ec2_eg_ssh` | SSH 用 SG から全送信を許可。 |
| セキュリティ | RDS用SG | `aws_security_group.rds_sg` | RDS 向けセキュリティグループ。 |
| セキュリティ | RDS受信 | `aws_vpc_security_group_ingress_rule.rds_in` | EC2 アプリ用 SG から 3306/TCP を許可。 |
| セキュリティ | RDS送信 | `aws_vpc_security_group_egress_rule.rds_eg` | RDS 用 SG から全送信を許可。 |
| セキュリティ | ALB用SG | `aws_security_group.alb_sg` | ALB 向けセキュリティグループ。 |
| セキュリティ | ALB受信 | `aws_vpc_security_group_ingress_rule.alb_in` | `0.0.0.0/0` から 80/TCP を許可。 |
| セキュリティ | ALB送信 | `aws_vpc_security_group_egress_rule.alb_eg` | ALB 用 SG から全送信を許可。 |
| データベース | RDS Subnet Group | `aws_db_subnet_group.rds-subnet` | プライベートサブネット A / B をまとめた RDS 用サブネットグループ。 |
| データベース | RDSインスタンス | `aws_db_instance.rds` | MySQL 8.0 / `db.t3.micro` / 10GB / マルチAZ構成、パブリックアクセス無効、削除保護有効。 |
| データベース | RDS接続設定 | `aws_db_instance.rds` | DB名 `terraform_rds`、ユーザー `admin`、パスワードは `var.rds_password` から取得、SG は `rds_sg` を使用。 |
| ロードバランサ | ALB本体 | `aws_lb.alb` | Internet 向け Application Load Balancer。Public Subnet A/B に配置し、SG は `alb_sg` を使用。削除保護有効。 |
| ロードバランサ | ALBリスナー | `aws_lb_listener.alb_li` | ポート 80 / HTTP で待ち受け、ターゲットグループ `alb_tg` にフォワード。 |
| ロードバランサ | ターゲットグループ | `aws_lb_target_group.alb_tg` | ポート 8080 / HTTP、ターゲットタイプは `instance`。ヘルスチェックは `/`、HTTP 200/300/301 を正常判定。 |
| ロードバランサ | ターゲット登録 | `aws_lb_target_group_attachment.alb_at` | EC2 インスタンスをポート 8080 でターゲットグループに登録。 |
| 監視 / 通知 | EC2 CPUアラーム | `aws_cloudwatch_metric_alarm.alarm_ec2` | EC2 の CPU 使用率が平均 50% 以上（60 秒 × 1 回）で SNS トピックへ通知。 |
| 監視 / 通知 | SNSトピック | `aws_sns_topic.sns_topic` | CloudWatch アラーム通知用の SNS トピック `aws-study-alarm-topic`。 |
| 監視 / 通知 | SNS購読（メール） | `aws_sns_topic_subscription.sns_subscription` | 変数 `sns_email_address` で指定したメールアドレスを SNS トピックに購読（プロトコル `email`）。 |
| ログ / WAF | CloudWatch Log Group | `aws_cloudwatch_log_group.tf_cloudwatch_logs` | WAF ログ出力用のロググループ。削除保護有効、保持期間 3 日。 |
| ログ / WAF | WAFログ設定 | `aws_wafv2_web_acl_logging_configuration.tf_cloudwatch_logs_cf` | WAF Web ACL のログを前述の CloudWatch Log Group に送信。 |
| ログ / WAF | WAF Web ACL | `aws_wafv2_web_acl.tf_waf` | スコープ `REGIONAL` の WAF。デフォルト許可、AWS マネージドルール `AWSManagedRulesCommonRuleSet` を適用。 |
| ログ / WAF | WAF-ALB関連付け | `aws_wafv2_web_acl_association.waf_association` | 作成した WAF Web ACL を ALB に関連付け。 |
| ステート管理 | Terraform Backend(S3) | `terraform { backend "s3" ... }` | S3 バケット `terraform-study-momo` に `terraform.tfstate` を保存（リージョン `ap-northeast-1`）。 |
| Output | VPC ID | `output "vpc_id"` | 作成した VPC の ID を出力。 |
| Output | Public Subnet A ID | `output "aws_subnet_id"` | Public Subnet A の ID を出力。 |
| Output | EC2 ID | `output "ec2_instance_id"` | EC2 インスタンス ID を出力。 |
| Output | EC2 Public IP | `output "ec2_public_ip"` | EC2 インスタンスのパブリック IP を出力。 |
| Output | RDS エンドポイント | `output "rds_endpoint"` | RDS インスタンスのエンドポイントアドレスを出力。 |
| Output | RDS ポート | `output "rds_port"` | RDS インスタンスのポート番号を出力。 |
| Output | ALB URL | `output "alb_url"` | ALB の DNS 名を元にした `http://<ALB DNS 名>` の URL を出力。 |
