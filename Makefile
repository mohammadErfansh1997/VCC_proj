INVENTORY ?= inventory

#
# Python environment
#

.venv:
	python3 -m venv $@

.PHONY: python-setup
python-setup: .venv
	. ~/venv/bin/activate && \
		pip install --upgrade pip && \
		pip install -r requirements.txt && \
		ansible-galaxy collection install -r requirements.yml

#
# Targets
#

.PHONY: setup-all
setup-all: .venv
	. ~/venv/bin/activate && \
		ansible-playbook -i $(INVENTORY) -v playbook.yml

.PHONY: setup-from-images-onwards
setup-from-images-onwards: .venv
	. ~/venv/bin/activate && \
		ansible-playbook -i $(INVENTORY) -v playbook.yml \
		--start-at-task='Create /opt/container-images'

.PHONY: setup-from-service-onwards
setup-from-service-onwards: .venv
	. ~/venv/bin/activate && \
		ansible-playbook -i $(INVENTORY) -v playbook.yml \
		--start-at-task='Repull images'

.PHONY: nuke-data
nuke-data: .venv
	. ~/venv/bin/activate && \
		ansible-playbook -i $(INVENTORY) -v playbook.yml --tags "nuke-data"

.PHONY: nuke-data-hard
nuke-data-hard: .venv
	. ~/venv/bin/activate && \
		ansible-playbook -i $(INVENTORY) -v playbook.yml --tags "nuke-data-hard"

.PHONY: restart-stack
restart-stack: .venv
	. ~/venv/bin/activate && \
		ansible-playbook -i $(INVENTORY) -v playbook.yml --tags "restart-stack"
