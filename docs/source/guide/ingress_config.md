---
title: Set up an Ingress Controller for Label Studio Enterprise Kubernetes Deployments
short: Set up an Ingress Controller for Kubernetes Deployments
badge: <i class='ent'/></i>
type: guide
order: 207
meta_title: Set up an Ingress Controller for Label Studio Enterprise Kubernetes Deployments
meta_description: Set up an Ingress Controller to manage load balancing and access to Label Studio Enterprise Kubernetes deployments for your data science and machine learning projects.
---

Set up an Ingress Controller to manage Ingress, the Kubernetes resource that exposes HTTP and HTTPS routes from outside your Kubernetes cluster to the services within the cluster, such as Label Studio Enterprise rqworkers and others.  

Select the best option for your deployment:
- Ingress for Amazon Elastic Kubernetes Service (EKS)
- Ingress for Google Kubernetes Engine (GKE)
- Ingress for Microsoft Azure Kubernetes Service (AKS)
- Ingress using nginx

Configure ingress before or after setting up [persistent storage](persistent_storage.html), but before you [deploy Label Studio Enterprise](install_enterprise.html).

> You only need to set up an ingress controller if you plan to deploy Label Studio Enterprise on Kubernetes. 

## Configure ingress for Amazon EKS

If you plan to deploy Label Studio Enterprise onto Amazon EKS, configure ingress. 

1. Install the AWS Load Balancer Controller to install an ingress controller with default options. See the documentation for [AWS Load Balancer Controller](https://docs.aws.amazon.com/eks/latest/userguide/aws-load-balancer-controller.html) in the Amazon EKS user guide.
2. After installing the AWS Load Balancer Controller, configure SSL certificates using the AWS Certificate Manager (ACM). See [Requesting a public certificate](https://docs.aws.amazon.com/acm/latest/userguide/gs-acm-request-public.html) in the ACM user guide.
3. Update your `lse-values.yaml` file with the ingress details like the following example. Replace `"your_domain_name"` with your hostname.
```yaml
app:
  ingress:
    path: /*
    host: "your_domain_name"
    className: alb
    annotations: 
      alb.ingress.kubernetes.io/scheme: internet-facing
      alb.ingress.kubernetes.io/target-type: ip
```

> Note: If you want to configure a certificate that you create in the ACM for the load balancer, add this annotation (updated for your certificate) to your `lse-values.yaml` file:  
```
alb.ingress.kubernetes.io/certificate-arn: arn:aws:acm:region:account-id:certificate/aaaa-bbbb-cccc
```

For more details about annotations that you can configure with ingress, see the guide on [Ingress annotations](https://kubernetes-sigs.github.io/aws-load-balancer-controller/latest/guide/ingress/annotations/) in the AWS Load Balancer Controller documentation on GitHub.

## Configure ingress for GKE

Google Kubernetes Engine (GKE) contains two pre-installed Ingress classes:
- The `gce` class deploys an external load balancer
- The `gce-internal` class deploys an internal load balancer

Label Studio Enterprise is considered an external service, so you want to use the `gce` class to deploy an external load balancer.

1. Update your `lse-values.yaml` file with the ingress details like the following example. Replace `"your_domain_name"` with your hostname.
```yaml
app:
  service:
    type: nodePort
  ingress:
    path: /*
    host: "your_domain_name"
    className: gce
```

> Note: You can also request Google-managed SSL certificates to use on the load balancer. See the details on [Using Google-managed SSL certificates](https://cloud.google.com/kubernetes-engine/docs/how-to/managed-certs) in the Google Kubernetes Engine how-to guide. If you use a managed certificate, add an annotation to your `lse-values.yaml` file like the following example, replacing `"managed-cert"` with your ManagedCertificate object name:
```yaml
​​"networking.gke.io/managed-certificates": "managed-cert"
```

For more details about annotations and ingress in GKE, see [Configuring Ingress for external load balancing](https://cloud.google.com/kubernetes-engine/docs/how-to/load-balance-ingress) in the Google Kubernetes Engine how-to guide.

## Configure ingress for Microsoft Azure Kubernetes Service

Configure ingress for Microsoft Azure Kubernetes Service (AKS).

1. Deploy an Application Gateway Ingress Controller (AGIC) using a new Application Gateway. See [How to Install an Application Gateway Ingress Controller (AGIC) Using a New Application Gateway](https://docs.microsoft.com/en-us/azure/application-gateway/ingress-controller-install-new) in the Microsoft Azure Ingress for AKS how-to guide. 
2. Update your `lse-values.yaml` file with the ingress details like the following example. Replace `"your_domain_name"` with your hostname.
```yaml
app:
  ingress:
    host: "your_domain_name"
    className: azure/application-gateway
```

> Note: You can create a self-signed certificate to use in AGIC. Follow the steps to [Create a self-signed certificate](https://docs.microsoft.com/en-us/azure/application-gateway/create-ssl-portal#create-a-self-signed-certificate) in the Microsoft Azure Networking Tutorial: Configure an application gateway with TLS termination using the Azure portal. 

For more details about using AGIC with Microsoft Azure, see [What is Application Gateway Ingress Controller?](https://docs.microsoft.com/en-us/azure/application-gateway/ingress-controller-overview) and [Annotations for Application Gateway Ingress Controller](https://docs.microsoft.com/en-us/azure/application-gateway/ingress-controller-annotations) in the Microsoft Azure Application Gateway documentation.

## Set up a cloud-agnostic ingress configuration

For advanced Kubernetes administrators, you can use the NGINX Ingress Controller to set up a cloud-agnostic ingress controller.

1. Deploy NGINX Ingress Controller following the relevant steps for your cloud deployment. See [Cloud deployments](https://kubernetes.github.io/ingress-nginx/deploy/#cloud-deployments) in the NGINX Ingress Controller Installation Guide. 
2. In order to terminate SSL certificates in the ingress controller, install cert-manager. See [Installation](https://cert-manager.io/docs/installation/) on the cert-manager documentation site.  
3. You must synchronize the ingress hosts with DNS. Install [ExternalDNS](https://github.com/kubernetes-sigs/external-dns#readme) and choose the relevant cloud provider for your deployment.
   1. Finally, update your `lse-values.yaml` file with the ingress details like the following example. Replace `"your_domain_name"` with your hostname and `<CERTIFICATE_NAME>` with the name of the resource that you created with ExternalDNS.
```yaml
app:
  ingress:
    host: "your_domain_name"
    className: nginx
    annotations:
      nginx.ingress.kubernetes.io/proxy-body-size: "200m"
    tls:
      - secretName: <CERTIFICATE_NAME>
        hosts:
          - "your_domain_name"
```
