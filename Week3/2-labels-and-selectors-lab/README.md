#Setup

Run `kubectl create -f setup-pods`

#Tasks

1. We have deployed a number of PODs. They are labelled with tier, env and bu. How many PODs exist in the dev environment?  Use selectors to filter the output
2. How many PODs are in the finance business unit (bu)?
3. How many objects are in the prod environment including PODs, ReplicaSets and any other objects?
4. Identify the POD which is part of the prod environment, the finance BU and of frontend tier?
5. A ReplicaSet definition file is given replicaset-definition-1.yaml. Try to create the replicaset. There is an issue with the file. Try to fix it.