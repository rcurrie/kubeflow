# Incantations to tilt up a kubeflow cluster locally
#
# OSX Installation:
# docker desktop
# brew install kind
#
# References:
# https://www.docker.com/blog/depend-on-docker-for-kubeflow/
# https://morioh.com/p/7c45a5df9034

create-cluster:
	# Start a k8s cluster using kind on the local docker
	kind create cluster --name kubeflow --image "kindest/node:v1.15.6"

delete-cluster:
	# Shut down the k8s cluster
	kind delete cluster --name kubeflow

list-clusters:
	# List all kind clusters
	kind get clusters

run-alpine:
	# Run alpine with an interactive shell on the cluster as a test
	kubectl run alpine --rm -it --restart=Never --image=alpine -- /bin/sh

build-kflow:
	# Download and build all the yaml files for kubeflow - customize after this
	rm -rf kustomize
	curl -L -o kfctl_k8s_istio.yaml \
		https://raw.githubusercontent.com/kubeflow/manifests/v0.7-branch/kfdef/kfctl_k8s_istio.0.7.1.yaml
	kfctl build -V -f kfctl_k8s_istio.yaml                                                                                                                               

apply-kflow:
	time kfctl apply -V -f kfctl_k8s_istio.yaml                                                                                                                               

delete-kflow:
	time kfctl delete --delete_storage --verbose -f kfctl_k8s_istio.yaml

status:
	echo "Cluster health:"
	kubectl get componentstatuses
	echo "Nodes:"
	kubectl get nodes
	echo "Kubeflow health:"
	kubectl get all -n kubeflow

minikube-start:
	minikube start \
		--vm-driver=virtualbox \
		--kubernetes-version 1.15.6 \
		--profile kubeflow \
		--cpus 4 --memory 12288 --disk-size=60g
	# So docker works
	eval $(minikube docker-env)

minikube-stop:
	minikube --profile kubeflow stop


port-forward:
	kubectl port-forward -n istio-system svc/istio-ingressgateway 8080:80
