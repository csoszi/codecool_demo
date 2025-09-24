Kubernetes
EKS + Terraform Deployment of TodoMVC (JavaScript-ES6)
Required Resources
1. Pod Identity

Kubernetes uses Service Accounts to assign permissions to Pods.

AWS uses IAM Roles to grant access to resources.

Pod Identity allows you to link a Kubernetes Service Account with an AWS IAM Role.

When a Pod uses the linked Service Account, it automatically inherits the IAM Role’s permissions.

A Pod Identity Agent acts as a broker in the background.

It runs in the kube-system namespace.

We don’t manually configure it, but we should know that all service account ↔ IAM Role links pass through it.

For TodoMVC, Pod Identity isn’t strictly required (since the app is static), but if you extend it (e.g., with S3 bucket access for storing tasks), Pod Identity is the secure way to grant those permissions.

2. EBS-CSI (Elastic Block Store Container Storage Interface)

Persistent storage in AWS EKS is managed by the EBS-CSI driver.

The driver runs as a controller pod in the kube-system namespace.

It authenticates with AWS through Pod Identity when creating new volumes.

In our case, TodoMVC is a static web app and can be served statelessly (no EBS required).

If the app evolves into a backend service (with a database or persistent cache), EBS-CSI can provide reliable storage volumes.

Architectures
Monolithic Architecture (TodoMVC as a single Pod)

The entire app is packaged into one container image (static files + web server like nginx).

Deployment is straightforward:

One Deployment resource manages replicas of the TodoMVC container.

One Service (type: LoadBalancer) exposes the app externally via an AWS ELB.

Scaling is possible by increasing the number of replicas.

Since TodoMVC is static and does not need a database, this is the most cost-efficient option.

Limitations:

No modularity.

Any future feature requiring backend logic would force us to rebuild and redeploy the whole monolith.

Microservices Architecture (if we extend TodoMVC)

TodoMVC (frontend) is one service.

Additional services could be introduced:

Auth Service (user login, sessions).

Task Service (API + database for tasks).

Storage Service (e.g., S3 or DynamoDB for persistent data).

Each microservice runs in its own Deployment with a dedicated database (RDS, DynamoDB, etc.).

Communication happens via REST/gRPC between services.

Scaling is more flexible:

Heavy-load services (e.g., Auth) can scale independently.

Costs are higher due to multiple AWS resources (databases, networking, storage).

This setup removes the monolithic database bottleneck and supports long-term extensibility.
