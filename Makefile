BACKEND_PATH := ./backend/
FRONTEND_PATH := ./frontend/
BACKEND_IMG_NAME := backend-app
FRONTEND_IMG_NAME := frontend-app
DB_NAME := pgdb
BACKEND_HELM_CHART := apps-repo/backend
FRONTEND_HELM_CHART := apps-repo/frontend
DB_HELM_CHART := apps-repo/db


helm-install-backend:
# 	Not needed when image is already built and saved to k3s images dir
	rm /var/lib/rancher/k3s/agent/images/$(BACKEND_IMG_NAME).tar || true
	docker build -t $(BACKEND_IMG_NAME):latest $(BACKEND_PATH)
	docker save -o /var/lib/rancher/k3s/agent/images/$(BACKEND_IMG_NAME).tar $(BACKEND_IMG_NAME):latest
	sleep 2
# 	---------------------------------------------------
# 	helm dependency update backend
	helm install $(BACKEND_IMG_NAME) $(BACKEND_HELM_CHART) -n test-app --create-namespace -f values/backend-values.yaml
helm-install-frontend:
# 	Not needed when image is already built and saved to k3s images dir
	rm /var/lib/rancher/k3s/agent/images/$(FRONTEND_IMG_NAME).tar || true
	docker build -t $(FRONTEND_IMG_NAME):latest $(FRONTEND_PATH)
	docker save -o /var/lib/rancher/k3s/agent/images/$(FRONTEND_IMG_NAME).tar $(FRONTEND_IMG_NAME):latest
	sleep 2

# 	helm dependency update frontend
	helm install $(FRONTEND_IMG_NAME) $(FRONTEND_HELM_CHART) -n test-app --create-namespace -f values/frontend-values.yaml
helm-install-db:
# 	helm dependency update db
	helm install $(DB_NAME) $(DB_HELM_CHART) -n test-app --create-namespace -f values/db-values.yaml
helm-install-all: helm-install-backend helm-install-frontend helm-install-db


helm-upgrade-backend:
	rm /var/lib/rancher/k3s/agent/images/$(BACKEND_IMG_NAME).tar || true
	docker build -t $(BACKEND_IMG_NAME):latest $(BACKEND_PATH)
	docker save -o /var/lib/rancher/k3s/agent/images/$(BACKEND_IMG_NAME).tar $(BACKEND_IMG_NAME):latest
	sleep 2
	helm upgrade $(BACKEND_IMG_NAME) $(BACKEND_HELM_CHART) -n test-app -f values/backend-values.yaml
helm-upgrade-frontend:
	rm /var/lib/rancher/k3s/agent/images/$(FRONTEND_IMG_NAME).tar || true
	docker build -t $(FRONTEND_IMG_NAME):latest $(FRONTEND_PATH)
	docker save -o /var/lib/rancher/k3s/agent/images/$(FRONTEND_IMG_NAME).tar $(FRONTEND_IMG_NAME):latest
	sleep 2
	helm upgrade $(FRONTEND_IMG_NAME) $(FRONTEND_HELM_CHART) -n test-app -f values/frontend-values.yaml
helm-upgrade-db:
	helm upgrade $(DB_NAME) $(DB_HELM_CHART) -n test-app -f values/db-values.yaml
helm-upgrade-all: helm-upgrade-backend helm-upgrade-frontend helm-upgrade-db

helm-delete-backend:
	helm uninstall $(BACKEND_IMG_NAME) -n test-app
	sleep 2
	docker rmi $(BACKEND_IMG_NAME):latest || true
	rm /var/lib/rancher/k3s/agent/images/$(BACKEND_IMG_NAME).tar || true
	sudo k3s crictl rmi $(BACKEND_IMG_NAME):latest || true
helm-delete-frontend:
	helm uninstall $(FRONTEND_IMG_NAME) -n test-app
	sleep 2
	docker rmi $(FRONTEND_IMG_NAME):latest || true
	rm /var/lib/rancher/k3s/agent/images/$(FRONTEND_IMG_NAME).tar || true
	sudo k3s crictl rmi $(FRONTEND_IMG_NAME):latest || true
helm-delete-db:
	helm uninstall $(DB_NAME) -n test-app
helm-delete-all: helm-delete-backend helm-delete-frontend helm-delete-db
	sudo k3s crictl rmi --prune  #remove all unused images in k3s


helm-pkg:
	helm package backend
	helm package frontend
	helm package db
	mkdir -p docs
	mv -f *.tgz docs/
	cd docs && helm repo index .

git-change-url:
	git remote set-url origin https://github.com/SirMac/apps-helm-repo.git

git-push:
	git add .
	git commit -m "$(m)"
	git push






helm-init:
	mkdir -p charts
	touch Chart.yaml
	touch values.yaml

helm-create-backend: helm-init
	helm create charts/backend
	rm -rf charts/backend/*
	rm -rf charts/backend/templates/*.yaml 
	rm -rf charts/backend/templates/*.txt 
	rm -rf charts/backend/templates/tests
	cp -r ~/Documents/Projects/go_app/zdeploy/Kubernetes/s10/backend/* charts/backend/templates

helm-create-frontend: helm-init
	helm create charts/frontend
	rm -rf charts/frontend/charts
	rm -rf charts/frontend/templates/*.yaml
	rm -rf charts/frontend/templates/*.txt 
	rm -rf charts/frontend/templates/tests
	cp -r ~/Documents/Projects/go_app/zdeploy/Kubernetes/s10/frontend/* charts/frontend/templates

helm-create-db:
	helm create charts/db
	rm -rf charts/db/charts
	rm -rf charts/db/templates/*.yaml
	rm -rf charts/db/templates/*.txt 
	rm -rf charts/db/templates/tests
	cp -r ~/Documents/Projects/go_app/zdeploy/Kubernetes/s10/db/* charts/db/templates

helm-create-all: helm-create-backend helm-create-frontend helm-create-db

helm-rm-backend:
	rm -rf charts/backend
helm-rm-frontend:
	rm -rf charts/frontend
helm-rm-db:
	rm -rf charts/db
helm-rm-all:
	rm -rf charts
