# Taller de Kubernetes

Este taller combina teoría y práctica para entender y trabajar con Kubernetes sobre AWS. A lo largo de los ejercicios, iremos introduciendo conceptos fundamentales. Además, durante el recorrido, tendrán que investigar cómo realizar algunas tareas.

## Índice

1. [Introducción a Infrastructure as Code (IaC)](#1-introducción-a-infrastructure-as-code-iac)
2. [Desplegar cluster de Kubernetes con Terraform](#2-desplegar-cluster-de-kubernetes-con-terraform)
3. [Desplegar la Tool A](#3-desplegar-la-tool-A)
4. [Exponer la aplicación públicamente](#4-exponer-la-aplicación-públicamente)
5. [Asignar permisos a la aplicación](#5-asignar-permisos-a-la-aplicación)
6. [Desplegar segunda aplicación y probar network policies](#6-desplegar-segunda-aplicación-y-probar-network-policies)
7. [Prueba de Gatekeeper](#7-prueba-de-gatekeeper)

---

## 1. Introducción a Infrastructure as Code (IaC)

**¿Qué es IaC?**  
Es el proceso de gestionar y aprovisionar infraestructura mediante archivos de configuración legibles por máquina, en lugar de procesos manuales.  
Más información: [What is Infrastructure as Code?](https://learn.microsoft.com/en-us/devops/deliver/what-is-infrastructure-as-code)

Herramientas populares: Terraform, Pulumi, AWS CloudFormation.

---

## 2. Desplegar cluster de Kubernetes con Terraform

- **Comandos básicos de terraform** ([Terraform CLI documentation](https://developer.hashicorp.com/terraform/cli))
  - `terraform init`
  - `terraform plan`
  - `terraform apply`
  
- **Utilizar módulo de AWS terraform EKS** ([AWS EKS Terraform module](https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/latest))

- **Definir VPC con configuración recomendada** ([AWS VPC Best Practices](https://docs.aws.amazon.com/vpc/latest/userguide/VPC_Scenarios.html))
  - Subnets públicas y privadas, IGW, NAT Gateway.

- **Configurar Access Entries para acceso con kubectl** ([Managing EKS Cluster access](https://docs.aws.amazon.com/eks/latest/userguide/access-control.html))

- **Habilitar el endpoint público** del EKS, restringido a IPs seguras.

- **Comandos básicos de kubectl** ([kubectl Cheat Sheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/))
  - `kubectl get pods`
  - `kubectl describe pod <pod-name>`
  - `kubectl apply -f <manifest>.yaml`
  - `kubectl delete -f <manifest>.yaml`

- **¿Qué es el Cluster API? ¿Cómo interactúa kubectl?** ([Kubernetes Cluster API](https://cluster-api.sigs.k8s.io/))
  - `kubectl` se comunica con el API Server, que actúa como front-end del clúster.

---

## 3. Desplegar la Tool X

- **Antes de empezar: ¿Qué es un manifest?** ([Kubernetes Objects](https://kubernetes.io/docs/concepts/overview/working-with-objects/kubernetes-objects/))

- **Desplegar creando los recursos a mano para entender lo que tenemos que hacer**

- **Necesitamos un Deployment y un Service**

    - Por qué necesitamos un deployment y no desplegamos un pod directamente?
    - Cómo funciona un Service? 


---

- **Probar pegarle a la aplicación utilizando port-forward**

kubectl port-forward deployment/example-app 8080:80  
curl http://localhost:8080  

---

## 4. Exponer la aplicación públicamente

- **Utilizar un Service Load Balancer y exponer la app**

apiVersion: v1  
kind: Service  
metadata:  
  name: example-lb  
spec:  
  type: LoadBalancer  
  ports:  
    - port: 80  
      targetPort: 80  
  selector:  
    app: example  

---

- **Asignar un dominio y SSL usando Route53 y ACM**
  - Crear un record en Route53 apuntando al Load Balancer.
  - Crear un certificado en ACM.
  - (Opcional) Usar [ExternalDNS](https://github.com/kubernetes-sigs/external-dns) y [cert-manager](https://cert-manager.io/).

- **Entender la diferencia entre Service Load Balancer y Ingress + Ingress Controller**
  - *Service LoadBalancer*: un Load Balancer dedicado por aplicación.
  - *Ingress Controller*: un Load Balancer compartido que enruta tráfico según host/path.  
    [Ingress Controllers Documentation](https://kubernetes.io/docs/concepts/services-networking/ingress-controllers/)  
    [AWS ALB Ingress Controller](https://kubernetes-sigs.github.io/aws-load-balancer-controller/latest/)

- **Probar la aplicación en su primer endpoint público**

---

## 5. Asignar permisos a la aplicación

- **Utilizar RoleBindings para permitirle a nuestra aplicación hacer uso de la API de Kubernetes**
  - Crear un Role + RoleBinding con permisos de lectura sobre pods.
  - Desde la aplicación probar un endpoint que liste los pods.

- **Utilizar IRSA o Pod Identity para permitirle a la aplicación hacer uso de un bucket S3**
  - Crear un IAM Role asociado al ServiceAccount.
  - Probar endpoint que lista los archivos dentro de un bucket.

---

## 6. Desplegar segunda aplicación y probar network policies

- **Desplegar una aplicación/pod en otro namespace**

- **Aplicar una NetworkPolicy para limitar el tráfico entre namespaces**

- **Probar acceso entre pods**
  - Usar `kubectl exec` para intentar acceder al otro pod.
  - Debería fallar el request inicialmente.

- **Modificar la NetworkPolicy para permitir el tráfico**
  - Volver a probar y validar que ahora funciona.

---

## 7. Prueba de Gatekeeper

- **Desplegar Gatekeeper**  
  - Utilizar manifests oficiales de [Gatekeeper](https://open-policy-agent.github.io/gatekeeper/website/docs/install).

- **Instalar alguna constraint template y constraint**  
  - Ejemplo: prohibir la creación de pods como root.

- **Entender el modo de funcionamiento**
  - Admission Controller: intercepta requests antes de ser persistidos.

- **Probar bloqueos**
  - Crear un recurso que viole la política y verificar que se rechaza.

- **Ver logs de Gatekeeper**
  - Explorar logs del pod de Gatekeeper para entender los errores.

- **Probar modo "audit"**
  - Auditar el estado actual del clúster frente a las políticas instaladas.

---

