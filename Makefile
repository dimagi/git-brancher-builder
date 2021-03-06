.PHONY: clean clean-pyc clean-build help requirements upgrade-requirements
.DEFAULT_GOAL := help

define PRINT_HELP_PYSCRIPT
import re, sys

for line in sys.stdin:
	match = re.match(r'^([a-zA-Z_-]+):.*?## (.*)$$', line)
	if match:
		target, help = match.groups()
		print("%-20s %s" % (target, help))
endef
export PRINT_HELP_PYSCRIPT

BROWSER := python -c "$$BROWSER_PYSCRIPT"

help:
	@python -c "$$PRINT_HELP_PYSCRIPT" < $(MAKEFILE_LIST)

clean: clean-build clean-pyc ## remove all build, test, coverage and Python artifacts

clean-build: ## remove build artifacts
	rm -fr build/
	rm -fr dist/
	rm -fr .eggs/
	find . -name '*.egg-info' -exec rm -fr {} +
	find . -name '*.egg' -exec rm -f {} +

clean-pyc: ## remove Python file artifacts
	find . -name '*.pyc' -exec rm -f {} +
	find . -name '*.pyo' -exec rm -f {} +
	find . -name '*~' -exec rm -f {} +
	find . -name '__pycache__' -exec rm -fr {} +

lint: ## check style with flake8
	flake8 git_build_branch

release-test: dist ## package and upload a release
	twine upload dist/* --repository-url=https://test.pypi.org/legacy/

release: dist ## package and upload a release
	twine upload dist/*

dist: clean ## builds source and wheel package
	python setup.py sdist
	python setup.py bdist_wheel
	ls -l dist

install: clean ## install the package to the active Python's site-packages
	python setup.py install

requirements: export CUSTOM_COMPILE_COMMAND=`make requirements` or `make upgrade-requirements`
requirements:
	pip-compile -o requirements_dev.txt setup.py requirements_dev.in

requirements2: export CUSTOM_COMPILE_COMMAND=`make requirements2` or `make upgrade-requirements2`
requirements2:
	pip-compile -o requirements_dev_py2.txt setup.py requirements_dev.in

upgrade-requirements: export CUSTOM_COMPILE_COMMAND=`make requirements` or `make upgrade-requirements`
upgrade-requirements:
	pip-compile --upgrade -o requirements_dev.txt setup.py requirements_dev.in --allow-unsafe

upgrade-requirements2: export CUSTOM_COMPILE_COMMAND=`make requirements2` or `make upgrade-requirements2`
upgrade-requirements2:
	pip-compile --upgrade -o requirements_dev_py2.txt setup.py requirements_dev.in --allow-unsafe
