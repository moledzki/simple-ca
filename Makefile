BUILDDIR = .build
VPATH=$(BUILDDIR)
SHELL := /bin/bash
DOCKER_IMAGE_NAME=moledzki/simple-ca:dev

$(BUILDDIR):
	mkdir -p $(BUILDDIR)
	echo "mkdir"


build: build-npm build-python

build-npm: package.json | $(BUILDDIR)
	npm install
	rm -rfv static/node_modules
	cp -rv node_modules static/
	touch $(BUILDDIR)/build-npm

build-python: .virtualenv build-pip
	source .virtualenv/bin/activate && python manage.py collectstatic --noinput

.virtualenv:
	virtualenv .virtualenv

build-pip: requirements.txt 
	source .virtualenv/bin/activate && pip install -r requirements.txt
	touch $(BUILDDIR)/build-pip

run-server: build
	source .virtualenv/bin/activate && python manage.py migrate
	source .virtualenv/bin/activate && python manage.py runserver

docker:
	docker build . -t $(DOCKER_IMAGE_NAME)

docker-run: docker
	docker run -e SECRET_KEY=dupa -e ALLOWED_HOST=localhost -p 8080:80 --name simple-ca-dev --rm $(DOCKER_IMAGE_NAME)
