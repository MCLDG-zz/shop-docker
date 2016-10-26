echo 'kubectl run hello-node --image=asia.gcr.io/mean-app-1328/hello-node:v2 --port=80'
kubectl run hello-node --image=asia.gcr.io/mean-app-1328/hello-node:v2 --port=80
kubectl get pods
echo 'kubectl autoscale deployment hello-node --min=2 --max=5 --cpu-percent=80'
kubectl autoscale deployment hello-node --min=2 --max=5 --cpu-percent=80
kubectl get pods
read -n1 -r -p "Now clean up" key
kubectl delete hpa hello-node
kubectl delete deployment hello-node
