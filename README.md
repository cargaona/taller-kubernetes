# Taller de Kubernetes

Este taller combina teoría y práctica para entender y trabajar con Kubernetes sobre AWS. A lo largo de los ejercicios, iremos introduciendo conceptos fundamentales. Además, durante el recorrido, tendrán que investigar cómo realizar algunas tareas.

## Índice

1. [Desplegar cluster de Kubernetes con Terraform](#1-desplegar-cluster-de-kubernetes-con-terraform)
2. [Dockerizar la Aplicación de Ejemplo](#2-dockerizar-la-aplicación-de-ejemplo)
3. [Desplegar Aplicación Ejemplo](#3-desplegar-la-aplicación-de-ejemplo)
4. [Exponer la aplicación públicamente](#4-exponer-la-aplicación-públicamente)
5. [Asignar permisos a la aplicación](#5-asignar-permisos-a-la-aplicación)
6. [Desplegar segunda aplicación y probar network policies](#6-desplegar-segunda-aplicación-y-probar-network-policies)
7. [Prueba de Gatekeeper](#7-prueba-de-gatekeeper)
8. [Borrar Todo](#8-Borrar-Todo)
---

## 1. Desplegar cluster de Kubernetes con Terraform

- Comandos básicos de terraform ([Terraform CLI documentation](https://developer.hashicorp.com/terraform/cli))
  - `terraform init`
  - `terraform plan`
  - `terraform apply`
  
- Utilizar módulo de AWS terraform EKS ([AWS EKS Terraform module](https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/latest))
Revisar la sección de examples

- Definir VPC con configuración recomendada ([AWS VPC Best Practices](https://docs.aws.amazon.com/vpc/latest/userguide/VPC_Scenarios.html))
  - Subnets públicas y privadas, IGW, NAT Gateway.

- Configurar Access Entries para acceso con kubectl ([Managing EKS Cluster access](https://docs.aws.amazon.com/eks/latest/userguide/access-control.html))

- Habilitar el endpoint público del EKS, restringido a IPs seguras.

- Comandos básicos de kubectl ([kubectl Cheat Sheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/))
  - `kubectl get pods`
  - `kubectl describe pod <pod-name>`
  - `kubectl apply -f <manifest>.yaml`
  - `kubectl delete -f <manifest>.yaml`

- Preguntas para profundizar:
    - Qué es el Cluster API? Cómo interactúa kubectl? ([Kubernetes Cluster API](https://cluster-api.sigs.k8s.io/))
    - Qué objetos existen el cluste recién creado? 

---
## 2. Dockerizar la Aplicación de Ejemplo. 

- Dockerizar la aplicación y subirla a un registry. Pueden usar Dockerhub o ECR en la misma cuenta de AWS. 

--- 
## 3. Desplegar la Aplicación de Ejemplo.  

- Antes de empezar: ¿Qué es un manifest? ([Kubernetes Objects](https://kubernetes.io/docs/concepts/overview/working-with-objects/kubernetes-objects/))
- Desplegar creando los recursos a mano para entender lo que tenemos que hacer
Vamos a necesitar un Deployment y un Service. 
- Probar pegarle a la aplicación utilizando port-forward

```bash 

kubectl port-forward deployment/app1 8080:80  
curl http://localhost:8080/whoami  
```

- Preguntas para profundizar:
    - Por qué necesitamos un Deployment y no desplegamos un pod directamente?
    - Cómo funciona un Service? 
    - Para qué sirve el kube-proxy?


---

## 4. Exponer la aplicación públicamente

- Utilizar un Service Load Balancer y exponer la app. [Ejemplo](https://docs.aws.amazon.com/eks/latest/userguide/auto-configure-nlb.html#_sample_service)
- Asignar un dominio y SSL usando Route53 y ACM
  - Crear un certificado en ACM.
  - Si tienen dominio propio pueden usarlo. Si no, pueden pedirme y les doy un subdominio propio. 

- Entender la diferencia entre Service Load Balancer y Ingress + Ingress Controller
  - Service LoadBalancer: un Load Balancer dedicado por aplicación.
  - Ingress Controller: un Load Balancer compartido que enruta tráfico según host/path.  
    [Ingress Controllers Documentation](https://kubernetes.io/docs/concepts/services-networking/ingress-controllers/)  
    [AWS ALB Ingress Controller](https://kubernetes-sigs.github.io/aws-load-balancer-controller/latest/)

- Probar la aplicación en su endpoint público

- Preguntas para profundizar:
    - Qué tipos de Service existen? 
    - Qué es un Ingress? Qué diferencia tiene de un Service Load Balancer? Y en particular con el [AWS Load Balancer Controller](https://kubernetes-sigs.github.io/aws-load-balancer-controller/latest/)?
    - Qué es un Ingress Controller?


---

## 5. Asignar permisos a la aplicación

- Utilizar RoleBindings para permitirle a nuestra aplicación hacer uso de la API de Kubernetes
  - Crear un Role + RoleBinding con permisos de lectura sobre pods.
  - Desde la aplicación probar el endpoint que liste los pods. `GET /pods`  

- Utilizar [IRSA](https://docs.aws.amazon.com/eks/latest/userguide/iam-roles-for-service-accounts.html) o [Pod Identity](https://docs.aws.amazon.com/eks/latest/userguide/pod-identities.html) para permitirle a la aplicación hacer uso de un bucket S3
  - Crear un IAM Role asociado al ServiceAccount.
  - Probar endpoint que lista los archivos dentro de un bucket. `GET /s3-objects`
  - Para completar esta tarea, van a tener que crear un bucket y cargarle algunos archivos. 

- Preguntas para profundizar:
    - Qué diferencias existen entre Pod Identity e IRSA?
    - Qué es y para qué sirve un Service Account?  

---

## 6. Desplegar segunda aplicación y probar network policies

- Desplegar una aplicación/pod en otro namespace, [busybox](https://github.com/ipedrazas/k8s-lskp-demo/blob/master/busybox-pod.yaml) es una buena candidata
- Instalar [Calico](https://docs.tigera.io/calico/latest/getting-started/kubernetes/managed-public-cloud/eks);
- Aplicar una NetworkPolicy para limitar el tráfico entre namespaces

- Probar acceso entre pods
  - Usar `kubectl exec` para intentar acceder al otro pod.
  - Debería fallar el request inicialmente.

- Modificar la NetworkPolicy para permitir el tráfico
  - Volver a probar y validar que ahora funciona.

- Preguntas para profundizar:
    -  Qué es es un [CNI](https://kubernetes.io/docs/concepts/extend-kubernetes/compute-storage-net/network-plugins/)? Cómo es el [Kubernetes Network Model](https://kubernetes.io/docs/concepts/services-networking/#the-kubernetes-network-model)? 
    -  Cómo resuelve DNS internamente Kubernetes? [Docs](https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/)
---

## 7. Prueba de Gatekeeper

- Desplegar Gatekeeper  
  - Utilizar manifests oficiales de [Gatekeeper](https://open-policy-agent.github.io/gatekeeper/website/docs/install).

- Instalar alguna constraint template y constraint  
  - Ejemplo: prohibir la creación de pods como root.

- Entender el modo de funcionamiento
  - Admission Controller: intercepta requests antes de ser persistidos.

- Probar bloqueos
  - Crear un recurso que viole la política y verificar que se rechaza.

- Ver logs de Gatekeeper
  - Explorar logs del pod de Gatekeeper para entender los errores.

- Probar modo "audit"
  - Auditar el estado actual del clúster frente a las políticas instaladas.

---
## 8. Borrar Todo 

terraform destroy, y lo que esté manual, también. 
