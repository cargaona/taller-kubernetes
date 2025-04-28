package main

import (
	"encoding/json"
	"fmt"
	"net/http"
	"os"

	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/s3"
	"github.com/gorilla/mux"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	"k8s.io/client-go/kubernetes"
	"k8s.io/client-go/rest"
)

// Handler para el endpoint whoami
func WhoAmIHandler(w http.ResponseWriter, r *http.Request) {
	response := map[string]interface{}{
		"method":     r.Method,
		"path":       r.URL.Path,
		"headers":    r.Header,
		"remoteAddr": r.RemoteAddr,
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(response)
}

// Handler para listar objetos en S3
func ListS3ObjectsHandler(w http.ResponseWriter, r *http.Request) {
	bucket := r.URL.Query().Get("bucket")
	if bucket == "" {
		http.Error(w, "Parámetro bucket requerido", http.StatusBadRequest)
		return
	}

	// Crea sesión de AWS (usa credenciales automáticas o IAM role)
	sess, err := session.NewSession(&aws.Config{})
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	svc := s3.New(sess)
	result, err := svc.ListObjectsV2(&s3.ListObjectsV2Input{
		Bucket: aws.String(bucket),
	})
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(result.Contents)
}

// Handler para listar pods de Kubernetes
func ListPodsHandler(w http.ResponseWriter, r *http.Request) {
	// Configuración para cluster Kubernetes
	config, err := rest.InClusterConfig()
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	clientset, err := kubernetes.NewForConfig(config)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	pods, err := clientset.CoreV1().Pods("").List(r.Context(), metav1.ListOptions{})
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(pods.Items)
}

func main() {
	r := mux.NewRouter()

	// Endpoints
	r.HandleFunc("/whoami", WhoAmIHandler).Methods("GET")
	r.HandleFunc("/s3-objects", ListS3ObjectsHandler).Methods("GET")
	r.HandleFunc("/pods", ListPodsHandler).Methods("GET")

	// Middleware de logging
	r.Use(func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			fmt.Printf("%s %s\n", r.Method, r.URL.Path)
			next.ServeHTTP(w, r)
		})
	})

	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	fmt.Printf("Servidor iniciado en el puerto %s\n", port)
	http.ListenAndServe(":"+port, r)
}
