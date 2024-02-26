Installation. 
## Create an new project.
oc new-project stardog-nga --display-name 'Stardog - National Geospatial-Intelligence Agency (NGA)'


## create a license secret

kubectl create secret generic stardog-license --from-file stardog-license-key.bin=./stardog-license-key.bin

