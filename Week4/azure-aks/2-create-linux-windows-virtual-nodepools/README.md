# Create Azure AKS Linux, Windows and Virtual Node Pools

## Step-01: Introduction
- Enable Virtual Nodes (Serverless)
- Create Linux User Node pool
- Create Windows User Node pool


## Step-02: Enable Virtual Nodes on our AKS Cluster
### Step-02-01: Enable Virtual Nodes Add-On on our AKS Cluster
```
# Verify Environment Variables
echo ${AKS_RESOURCE_GROUP} ${AKS_CLUSTER}, ${AKS_VNET_SUBNET_VIRTUALNODES}

# Enable Virtual Nodes on AKS Cluster
az aks enable-addons \
    --resource-group ${AKS_RESOURCE_GROUP} \
    --name ${AKS_CLUSTER} \
    --addons virtual-node \
    --subnet-name ${AKS_VNET_SUBNET_VIRTUALNODES}

# List Nodes
kubectl get nodes   

# List Virtual Nodes ACI Pods
kubectl get pods -n kube-system

# Sample Output for Reference
kubectl get pods -n kube-system
NAME                                   READY   STATUS    RESTARTS   AGE
aci-connector-linux-5954b7964d-9pwhh   1/1     Running   0          51s
azure-cni-networkmonitor-d4qx2         1/1     Running   0          45m
azure-cni-networkmonitor-n22zk         1/1     Running   0          44m
azure-ip-masq-agent-hjxfw              1/1     Running   0          44m
azure-ip-masq-agent-nql27              1/1     Running   0          45m
coredns-autoscaler-5b6cbd75d7-sm25f    1/1     Running   0          45m
coredns-b94d8b788-8xh5f                1/1     Running   0          41s
coredns-b94d8b788-9q2qw                1/1     Running   0          41s
coredns-b94d8b788-lmkjr                1/1     Running   0          46m
coredns-b94d8b788-sd9tv                1/1     Running   0          41s
coredns-b94d8b788-srlpl                1/1     Running   0          44m
kube-proxy-52xhr                       1/1     Running   0          44m
kube-proxy-58wfr                       1/1     Running   0          45m
metrics-server-77c8679d7d-jgllt        1/1     Running   0          46m
omsagent-8gjsx                         1/1     Running   0          44m
omsagent-frsbx                         1/1     Running   0          45m
omsagent-rs-658965b675-fkdrh           1/1     Running   0          46m
tunnelfront-5d44747fb8-jj8dm           1/1     Running   0          45m

# Verify Logs ACI Connector
If you are seeing an error for the pod run the following commands if you want to investigate

kubectl get pods -n kube-system
kubectl -n kube-system logs -f $(kubectl get po -n kube-system | egrep -o 'aci-connector-linux-[A-Za-z0-9-]+')
```
### Step-02-02: Fix ACI Connector CrashLoopBackOff Issue (skip if everything is fine and following substeps as well)
- Go to Services -> Managed Identities -> aciconnectorlinux-aksprod1 
- Azure Role Assignments
    - Add Role Assignment
    - Scope: Resource Group
    - Subscription: Pay-As-You-Go
    - Resource Group: aks-prod
    - Role: Contributor
- Click on **SAVE**

### Step-02-03: Delete ACI Connector Pod to recreate it 
```
# List Pods
kubectl get pods -n kube-system

# Delete aci-connector-linux pod to recreate it
kubectl -n kube-system delete pod <ACI-Connector-Pod-Name>
kubectl -n kube-system delete pod $(kubectl get po -n kube-system | egrep -o 'aci-connector-linux-[A-Za-z0-9-]+')

# List Pods (ACI Connector Pod should be running)
kubectl get pods -n kube-system
```

### Step-02-04: List Virtual Nodes and See if listed
```
# List Nodes
kubectl get nodes

# Sample Output
kubectl get nodes
NAME                                 STATUS   ROLES   AGE     VERSION
aks-linux101-11453984-vmss000000     Ready    agent   10m     v1.19.9
aks-linux101-11453984-vmss000001     Ready    agent   9m55s   v1.19.9
aks-linux101-11453984-vmss000002     Ready    agent   9m58s   v1.19.9
aks-systempool-11453984-vmss000000   Ready    agent   67m     v1.19.9
aks-systempool-11453984-vmss000001   Ready    agent   67m     v1.19.9
virtual-node-aci-linux               Ready    agent   23m     v1.18.4-vk-azure-aci-v1.3.5
```

## Step-03: Create Linux User Node Pool

### Step-03-01: Create Linux User Node Pool
```
# Create New Linux Node Pool 
az aks nodepool add --resource-group ${AKS_RESOURCE_GROUP} \
                    --cluster-name ${AKS_CLUSTER} \
                    --name linux101 \
                    --node-count 1 \
                    --enable-cluster-autoscaler \
                    --max-count 5 \
                    --min-count 1 \
                    --mode User \
                    --node-vm-size Standard_DS2_v2 \
                    --os-type Linux \
                    --labels nodepool-type=user environment=production nodepoolos=linux app=java-apps \
                    --tags nodepool-type=user environment=production nodepoolos=linux app=java-apps \
                    --zones 3

```
### Step-03-02: List Node Pools & Nodes
```
# List Node Pools
az aks nodepool list --cluster-name ${AKS_CLUSTER} --resource-group ${AKS_RESOURCE_GROUP} -o table
Note: Understand the mode System vs User

# List Nodes using Labels
kubectl get nodes -o wide -l nodepoolos=linux
kubectl get nodes -o wide -l app=java-apps
```


## Step-04: Create a Node Pool for Windows Apps
- To run an AKS cluster that supports node pools for Windows Server containers, your cluster needs to use a network policy that uses [Azure CNI](https://docs.microsoft.com/en-us/azure/aks/concepts-network#azure-cni-advanced-networking) (advanced) network plugin
- Default windows Node size is Standard_D2s_v3 as on today
- The following limitations apply to Windows Server node pools:
  - The AKS cluster can have a maximum of 10 node pools.
  - The AKS cluster can have a maximum of 100 nodes in each node pool.
  - The Windows Server node pool name has a limit of 6 characters.

### Step-04-01: Create Windows Node Pool
```
# Create New Windows Node Pool 
az aks nodepool add --resource-group ${AKS_RESOURCE_GROUP} \
                    --cluster-name ${AKS_CLUSTER} \
                    --os-type Windows \
                    --name win101 \
                    --node-count 1 \
                    --enable-cluster-autoscaler \
                    --max-count 5 \
                    --min-count 1 \
                    --mode User \
                    --node-vm-size Standard_DS2_v2 \
                    --labels environment=production nodepoolos=windows app=dotnet-apps nodepool-type=user \
                    --tags environment=production nodepoolos=windows app=dotnet-apps nodepool-type=user \
                    --zones 3
```
### Step-04-02: List Node Pools & Nodes
```
# List Node Pools
az aks nodepool list --cluster-name ${AKS_CLUSTER} --resource-group ${AKS_RESOURCE_GROUP} --output table

# List Nodes using Labels
kubectl get nodes -o wide
kubectl get nodes -o wide -l nodepoolos=linux
kubectl get nodes -o wide -l nodepoolos=windows
kubectl get nodes -o wide -l environment=production
```

```
# List Node Pools
az aks nodepool list --cluster-name ${AKS_CLUSTER} --resource-group ${AKS_RESOURCE_GROUP} --output table

# Sample Output (for reference)
Name        OsType    KubernetesVersion    VmSize           Count    MaxPods    ProvisioningState    Mode
----------  --------  -------------------  ---------------  -------  ---------  -------------------  ------
linux101    Linux     1.19.9               Standard_DS2_v2  3        30         Succeeded            User
systempool  Linux     1.19.9               Standard_DS2_v2  2        30         Succeeded            System
win101      Windows   1.19.9               Standard_DS2_v2  1        30         Succeeded            User

```


## References
- [Windows Node Pools](https://docs.microsoft.com/en-us/azure/aks/windows-container-cli)