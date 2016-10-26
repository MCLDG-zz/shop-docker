echo 'kubectl run hello-node --image=asia.gcr.io/mean-app-1328/hello-node:v2 --port=80'
kubectl run hello-node --image=asia.gcr.io/mean-app-1328/hello-node:v2 --port=80
echo 'kubectl scale deployment hello-node --replicas=4'
kubectl scale deployment hello-node --replicas=4
kubectl get deployment
kubectl get pods
read -n1 -r -p "Now delete a pod and clean up" key
echo 'run: kubectl delete pod hello-node-315264902-e4cw6'
echo 'kubectl get pods'
echo 'kubectl delete deployment hello-node'
