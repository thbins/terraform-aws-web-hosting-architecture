# AWS Web Hosting Architecture with Terraform

> AWS 웹 애플리케이션 호스팅 모범 사례를 Terraform으로 구현한 3-tier 아키텍처

## 📋 개요

[AWS 웹 애플리케이션 호스팅 모범 사례](https://docs.aws.amazon.com/ko_kr/whitepapers/latest/web-application-hosting-best-practices/an-aws-cloud-architecture-for-web-hosting.html) 백서를 기반으로 한 확장 가능하고 안전한 웹 호스팅 인프라입니다.

## 🏗️ 아키텍처

![AWS Web Hosting Architecture](docs/images/architecture.png)

## 🚀 빠른 시작

### 1. 사전 요구사항
- Terraform >= 1.0
- AWS CLI 구성
- S3 버킷 (Terraform 상태 저장용)

### 2. 배포
```bash
cd env/prod
terraform init
terraform plan
terraform apply
```

### 3. 설정 파일 수정
`env/prod/prod.auto.tfvars`에서 환경별 값 조정:
```hcl
name   = "web3tier"
region = "ap-northeast-2"
vpc_cidr = "10.10.0.0/16"
enable_nat_gateway = false  # 비용 절약
```

## 📁 디렉터리 구조

```
├── env/prod/              # 배포 환경
│   ├── main.tf           # 모듈 조합
│   ├── variables.tf      # 입력 변수
│   ├── prod.auto.tfvars  # 실제 값
│   └── outputs.tf        # 출력 값
├── modules/              # 재사용 모듈
│   ├── network/          # VPC, 서브넷, 라우팅
│   ├── security/         # 보안 그룹
│   ├── compute-web/      # 웹 계층 (ALB + ASG)
│   ├── compute-app/      # 앱 계층 (Internal ALB + ASG)
│   ├── data-rds/         # RDS 데이터베이스
│   ├── data-redis/       # ElastiCache Redis
│   ├── data-efs/         # EFS 파일 시스템
│   └── edge-cf/          # CloudFront + WAF
└── user_data/            # 인스턴스 초기화 스크립트
```

## 🔧 주요 기능

- **고가용성**: Multi-AZ 배포
- **확장성**: Auto Scaling Group
- **보안**: 계층별 보안 그룹, WAF
- **성능**: CloudFront CDN
- **모니터링**: VPC Flow Logs
- **비용 최적화**: NAT Gateway 토글

## 💰 비용 고려사항

- NAT Gateway: `enable_nat_gateway = false`로 시작
- RDS: 개발 시 `db.t3.micro` 사용
- ElastiCache: `cache.t3.micro` 권장

## 🔒 보안 모범 사례

- 모든 서브넷 계층별 분리
- 최소 권한 보안 그룹
- WAF 웹 애플리케이션 방화벽
- VPC Flow Logs 활성화

## 📊 모니터링

배포 후 확인할 주요 지표:
- ALB 상태 확인
- ASG 인스턴스 상태
- RDS 연결성
- CloudFront 캐시 히트율

## 🤝 기여

1. Fork 프로젝트
2. Feature 브랜치 생성
3. 변경사항 커밋
4. Pull Request 생성

## 📄 라이선스

MIT License