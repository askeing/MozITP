#!/bin/bash

#pushd vm
vagrant destroy
#popd

# remove the onceaday cache config files
./bin/reset_onceaday.sh