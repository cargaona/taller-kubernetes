Taller de Kubernetes
- Desplegar cluster de Kubernetes con Terraform
    - Comandos básicos de terraform
    - Utilizar módulo de AWS terraform EKS 
    - Definir VPC con configuración recomendada. Subnets, IGW y Nat GW
    - Configurar Access Entries para acceso con kubectl. 
    - Comandos básicos de kubectl
    - Qué es el cluster API? Cómo interactua con kubectl. 
    - Dejar endpoint público para mayor practicidad.
- Desplegar la tool x. 
    - Antes de empezar: Qué es un manifest?
    - Desplegar creando los recursos a mano para entender lo que tenemos que hacer.
    - Necesitamos un Deployment y un Service.
    - Probar pegarle a la aplicación utilizando port-forward. 
- Exponer la aplicación públicamente.
    - Utilizar un Service Load Balancer y exponer la app. Asignar un dominio y SSL (utilizar route53 y ACM). 
    - Entender la diferencia entre un Service Load Balancer y un Ingress + Ingress Controller
    - Probar la aplicación en su primer endpoint. 
- Asignar permisos a la aplicación.
    - Utilizar RoleBindings para permitirle a nuestra aplicación hacer uso de la API de Kubernetes. 
        - Probar endpoint de GetPods desde la app expuesta.
    - Utilizar IRSA o Pod Identity para permitirle a la aplicación hacer uso de un bucket S3. 
        - Probar endpoint que lista los archivos dentro de un bucket. 
- Desplegar segunda aplicación y probar network policies.
    - Desplegar una aplicación / pod en un container en otro namespace
    - Aplicar una network policy para limitar el tráfico entre namespaces. 
    - Entrar a ese pod con exec como ya vimos e intentar hacer un request al otro pod/service. Ver que falle el request.
    - Habilitar el tráfico entre los dos namespaces. 
    - Volver a probar. 
- Prueba de Gatekeeper.
    - Desplegar Gatekeeper con alguna policy (a elegir) 
    - Entender como funciona el modo de Admission Controller, cuáles son sus componentes. 
    - Probar como Gatekeeper bloquea creación o cambios en un recurso. 



