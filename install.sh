#!/bin/bash

git pull
ansible-playbook install.yml --ask-become-pass
