#!/bin/bash
echo "Bootstrapping software layer....."
#vagrant destroy
#vagrant up
ansible-playbook -i inventory -b playbook.yml
ansible-playbook -i inventory -b install-bamboo.yml
ansible-playbook -i inventory -b install-bitbucket.yml