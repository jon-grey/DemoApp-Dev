
# Todo

Ref:
[Deploy and Run Apps with Docker, Kubernetes, Helm, Rancher](https://www.udemy.com/course/deploy-and-run-apps-with-docker-kubernetes-helm-rancher/learn/lecture/14348750#overview)
[gravitonian - Overview](https://github.com/gravitonian)
## Task 1
- [x] - Contenerize app
- [x] - Automate requirements.txt generation:
  - [x] - script on host
  - [x] - docker container
- [x] - Develop locally with docker-compose 
- [x] - Enable https with letsencrypt certs in docker-compose
  - [x] - Google cloud dns for cert challenge
  - [x] - amce.sh to generate certs
- [x] - GitHub actions for CI (build, test) and push images to Docker Hub

Ref:
[Best practices for writing Dockerfiles](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/)
[301 Moved Permanently](https://www.qovery.com/blog/best-practices-and-tips-for-writing-a-dockerfile)
## Task 2
- [ ] - Deploy to AWS 

Ref:

[https://levelup.gitconnected.com/deploying-a-node-app-to-aws-elastic-beanstalk-using-github-actions-d64c7e486701](https://levelup.gitconnected.com/deploying-a-node-app-to-aws-elastic-beanstalk-using-github-actions-d64c7e486701)
[Deploying a Multi-Container Web Application — AWS Elastic Beanstalk](https://medium.com/analytics-vidhya/deploying-a-multi-container-web-application-aws-elastic-beanstalk-c5f95d266842)
[https://betterprogramming.pub/create-a-running-docker-container-with-gunicorn-and-flask-dcd98fddb8e0](https://betterprogramming.pub/create-a-running-docker-container-with-gunicorn-and-flask-dcd98fddb8e0)
[AWS Elastic Beanstalk infrastructure in code with Terraform](https://medium.com/seamless-cloud/aws-elastic-beanstalk-infrastructure-in-code-with-terraform-658243aeed6a)
[https://aws.plainenglish.io/deploy-multi-container-docker-to-elastic-beanstalk-with-ci-cd-using-codepipeline-and-aws-ecr-d1d5be0aaa20](https://aws.plainenglish.io/deploy-multi-container-docker-to-elastic-beanstalk-with-ci-cd-using-codepipeline-and-aws-ecr-d1d5be0aaa20)
[Beanstalk Deploy - GitHub Marketplace](https://github.com/marketplace/actions/beanstalk-deploy)
[GitHub - Nyior/django-github-actions-aws: demonstrates how to set up a CI/CD Pipeline with GitHub Actions and AWS in a Django project](https://github.com/Nyior/django-github-actions-aws)
[How to Setup a CI/CD Pipeline with GitHub Actions and AWS](https://www.freecodecamp.org/news/how-to-setup-a-ci-cd-pipeline-with-github-actions-and-aws/)
[https://gruntwork.io/infrastructure-as-code-library/](https://gruntwork.io/infrastructure-as-code-library/)
[Deploying Docker containers on ECS](https://docs.docker.com/cloud/ecs-integration/)

## Task 3
- [x] - Deploy kubernetes with kind cluster
- [x] - Deploy kubernetes with minikube (for ingress to work require to write `<IP address> <host>` to /etc/hosts)
- [x] - Enable https with letsencrypt certs in kuberntes: kubed, cert-manager, nginx-ingress
- [ ] - Use kustomization, helm + fluxcd in k8s cluster to sync with github
- [ ] - Add auto update of version of images on push to dockerhub

Ref:
[GitHub - fluxcd/flux2-kustomize-helm-example: A GitOps workflow example for multi-env deployments with Flux, Kustomize and Helm.](https://github.com/fluxcd/flux2-kustomize-helm-example)
[Flux - the GitOps family of projects](https://fluxcd.io/)
[Setting up Flux v2 with KIND Cluster and Github on Your Laptop](https://gengwg.blogspot.com/2021/03/setting-up-flux-v2-with-kind-cluster.html)
# Result

![](.img/2022-01-21-05-51-33.png)

![](.img/2022-01-21-05-51-48.png)

![](.img/2022-01-21-05-53-19.png)

# How to

## Note

Secrets to regenerate ssl certs and that are required: 

## Docker Hub
- .secrets/DOCKER_HUB_ID
- .secrets/DOCKER_HUB_PASSWORD
## Google cloud serivce account to manage cloud dns
- src/acme/secrets/gcloud.json
- helm/cert-manager-resources/secrets/gke-service-accounts/gke-test-dns-key.localtest-pl.json


## Local development with docker-compose

```sh
## Generate api requirements
make docker-gen-api-requirements

## Docker-compose build + up
make dc-upb

## Tests
make tests
```

Go to browser:
- https://api.gke-test.localtest.pl/stats
- https://frontend.gke-test.localtest.pl/

## AWS development with docker-compose

N/A

## Local development with K8s kind cluster

```sh
## Create k8s cluster with infra and app resources
make create-cluster-kindnes 

## OR minikube
make create-cluster-minikube
## then also need to manually help resolve ingress hosts
## grab list of <address> <host>, ie...
## ... 192.168.49.2 api.gke-test.localtest.pl
## ... 192.168.49.2 frontend.gke-test.localtest.pl
kubectl get ing -A | awk '{ print $5" "$4; }' | grep -v 'ADDRESS HOSTS'
## add them to host DNS mapping in form: <address> <host1> <host2>, like...
## ... 192.168.49.2 api.gke-test.localtest.pl frontend.gke-test.localtest.pl
sudo vim /etc/hosts

## Develop app in src/...
## ...
## Change images versions...

## Push changes to github
git add -A
git commit -m "Push changes."
git push

## Redeploy app
make helm-deploy-smartcow

## Tests
make tests
```

Go to browser:
- https://api.gke-test.localtest.pl/stats
- https://frontend.gke-test.localtest.pl/