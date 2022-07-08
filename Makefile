BUILDDIR = .build
VPATH = $(BUILDDIR)
SHELL = /bin/bash
DOCKER_IMAGE_NAME = moledzki/simple-ca:dev

$(BUILDDIR):
	mkdir -p $(BUILDDIR)

build: build-npm build-python

build-npm: package.json | $(BUILDDIR)
	npm install
	rm -rfv static/node_modules
	cp -rv node_modules static/
	touch $(BUILDDIR)/$@

build-python: .virtualenv build-pip
	source .virtualenv/bin/activate && python manage.py collectstatic --noinput

.virtualenv:
	virtualenv .virtualenv

build-pip: requirements.txt 
	source .virtualenv/bin/activate && pip install -r requirements.txt
	touch $(BUILDDIR)/$@

run-server: build
	source .virtualenv/bin/activate && python manage.py migrate
	source .virtualenv/bin/activate && python manage.py runserver

docker-build:
	docker build . -t $(DOCKER_IMAGE_NAME)

docker-run: docker-build
	docker run -e SECRET_KEY=dupa -e ALLOWED_HOST=localhost -e ADMIN_NAME=admin -e ADMIN_PASSWORD=admin -e ADMIN_EMAIL=admin@local.network -p 8080:80 --name simple-ca-dev --rm $(DOCKER_IMAGE_NAME)

docker-run-persistent: docker-build
	docker run -e DB_PATH=/data/db.sqlite3 -e SECRET_KEY=dupa -e ALLOWED_HOST=localhost -e ADMIN_NAME=admin -e ADMIN_PASSWORD=admin -e ADMIN_EMAIL=admin@local.network -p 8888:80 --name simple-ca-persistent -v simple-ca-data:/data --rm $(DOCKER_IMAGE_NAME)
