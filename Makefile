# Incantations to tilt up a kubeflow cluster locally
#
# Requirements:
# docker, kubectl, kfctl, kind
#
# References:
# https://www.docker.com/blog/depend-on-docker-for-kubeflow/
# https://morioh.com/p/7c45a5df9034
# https://ubuntu.com/kubeflow/install
# https://towardsdatascience.com/kubeflow-for-poets-a05a5d4158ce?#1fb7

create-cluster:
	# Start a k8s cluster using kind on the local docker
	# kubeflow is tested on 1.14 - some containers fail on 1.15 and up
	# kind create cluster --name kubeflow --image "kindest/node:v1.14.9"
	# kind create cluster --name kubeflow --image "kindest/node:v1.15.7"
	# kind create cluster --name kubeflow --image "kindest/node:v1.17.0"
	kind create cluster --name kubeflow --image \
		kindest/node:v1.15.6@sha256:18c4ab6b61c991c249d29df778e651f443ac4bcd4e6bdd37e0c83c0d33eaae78
		# kindest/node:v1.14.9@sha256:bdd3731588fa3ce8f66c7c22f25351362428964b6bca13048659f68b9e665b72
	kubectl cluster-info --context kind-kubeflow

delete-cluster:
	# Shut down the k8s cluster
	kind delete cluster --name kubeflow

list-clusters:
	# List all kind clusters
	kind get clusters

dump-clusters:
	kubectl cluster-info dump

run-alpine:
	# Run alpine with an interactive shell on the cluster as a test
	kubectl run alpine --rm -it --restart=Never --image=alpine -- /bin/sh

build-kubeflow:
	# Download and build all the yaml files for kubeflow - customize after this
	rm -rf kustomize
	curl -L -o kfctl_k8s_istio.yaml \
		https://raw.githubusercontent.com/kubeflow/kubeflow/v0.6-branch/bootstrap/config/kfctl_k8s_istio.0.6.2.yaml
		# https://raw.githubusercontent.com/kubeflow/manifests/v0.7-branch/kfdef/kfctl_k8s_istio.0.7.1.yaml
		# https://raw.githubusercontent.com/kubeflow/manifests/v0.7-branch/kfdef/kfctl_k8s_istio.0.7.0.yaml
		# https://raw.githubusercontent.com/kubeflow/kubeflow/v0.6-branch/bootstrap/config/kfctl_k8s_istio.yaml
		# https://github.com/kubeflow/kubeflow/blob/v0.6-branch/bootstrap/config/kfctl_k8s_istio.yaml
	kfctl build -V -f kfctl_k8s_istio.yaml                                                                                                                               
apply-kubeflow:
	time kfctl apply -V -f kfctl_k8s_istio.yaml                                                                                                                               
delete-kubeflow:
	time kfctl delete --delete_storage --verbose -f kfctl_k8s_istio.yaml

watch-kubeflow:
	# Watch the status of the kubeflow components as the cluster comes up
	watch -c -n 2 kubectl -n kubeflow get po

forward:
	# On server running the kind based cluster
	kubectl port-forward -n istio-system svc/istio-ingressgateway 31380:80
	# On client where you want to open a browser and access kubeflow
	ssh -N -L 31380:localhost:31380 rcurrie@plaza.gi.ucsc.edu

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
