#Tasks

1. Do any taints exist on the docker-desktop node
2. Create a taint on node01 with key of spray, value of mortein and effect of NoSchedule
3. Create a new pod with the NGINX image, and Pod name as mosquito
4. What is the state of the POD?
5. Why do you think the pod is in a pending state?
* POD Mosquito cannot tolerate tain Mortein
* Image is not available
* Application Error
6. Create another pod named bee with the NGINX image, which has a toleration set to the taint Mortein
7. Notice the bee pod was scheduled on node docker-desktop despite the taint
8. Remove the taint on docker-desktop, which currently has the taint effect of NoSchedule
9. What is the state of the pod mosquito now?