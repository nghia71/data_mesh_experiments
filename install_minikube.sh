# !/bin/sh

# Update/Upgrade Ubuntu
sudo apt update -y
sudo apt upgrade -y

# Install Minikube dependencies
sudo apt install -y curl wget apt-transport-https

# Install Minicube from binary download
wget https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo cp minikube-linux-amd64 /usr/local/bin/minikube
sudo chmod +x /usr/local/bin/minikube
minikube version

# Install Kubectl utility from binary download
curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl
chmod +x kubectl
sudo mv kubectl /usr/local/bin/
kubectl version -o yaml

# Start minikube
minikube start --driver=docker
minikube status

# Managing add-ons
minikube addons list
minikube addons enable ingress
#minikube dashboard

# Verify Minikube Installation
kubectl create deployment my-nginx --image=nginx
kubectl get deployments.apps my-nginx
kubectl get pods
kubectl expose deployment my-nginx --name=my-nginx-svc --type=NodePort --port=80
kubectl get svc my-nginx-svc
minikube service my-nginx-svc --url
#curl http://192.168.49.2:31895

# Manging Minikube cluster
minikube stop
minikube delete
minikube start

# minikube config set cpus 4
# minikube config set memory 8192
# minikube delete
# minikube start
