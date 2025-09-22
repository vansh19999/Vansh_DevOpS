# AWS Infra & Kubernetes Flow

```mermaid
flowchart TB
  %% Styles
  classDef aws fill:#f0f7ff,stroke:#1f6feb,stroke-width:1px;
  classDef k8s fill:#f7fff7,stroke:#2da44e,stroke-width:1px;
  classDef ext fill:#fff7f0,stroke:#d29922,stroke-width:1px;
  classDef dim fill:#fafbfc,stroke:#d0d7de,color:#57606a;

  Internet[(User / Internet)]:::ext

  subgraph VPC["AWS VPC 10.0.0.0/16"]:::aws
    IGW[Internet Gateway]:::aws
    subgraph Public["Public Subnets"]:::aws
      ALB[ALB/NLB (Ingress Service)]:::aws
      NAT[NAT Gateway]:::aws
    end
    subgraph Private["Private Subnets"]:::aws
      subgraph EKS["Amazon EKS Cluster"]:::k8s
        CP[(EKS Control Plane\n(Managed by AWS))]:::dim
        N1[(Managed Node Group\nEC2)]:::k8s
        subgraph WK["Kubernetes Workloads"]:::k8s
          Ingress[Ingress]:::k8s
          Svc[Service (ClusterIP)]:::k8s
          Deploy[Deployment]:::k8s
          Pods[(Pods)]:::k8s
          Cfg[(ConfigMap / Secret)]:::k8s
        end
      end
    end
  end

  ECR[(Amazon ECR\nContainer Images)]:::aws
  CW[(CloudWatch / Container Insights)]:::aws
  CI[(CI/CD: GitHub Actions)]:::ext

  %% Traffic & control flow
  Internet --> IGW --> ALB
  ALB -->|HTTP/HTTPS| Ingress
  Ingress --> Svc --> Deploy --> Pods
  Cfg -.-> Pods
  CP -.manages.-> N1
  CP -.schedules.-> Pods
  NAT --> Private
  Pods -.pull images.-> ECR
  Pods -.logs/metrics.-> CW
  CI -->|build & push| ECR
