# Lecture 9: Group Findings and Discussion
This files include the content of the group findings and discussions for lecture 9.
## **Ad Point 1:** implemented adding at least one environment value and prove it is being read by the application
TODO

## **Ad Point 2:** discuss for what env should be used (think about the 12-factor)
TODO

## **Ad Point 3:** delete or modify mongo's pvc and explain what happens (check the pv)
Deleting the mongo PVC puts the PVC in the "Terminating" state and it cannot be fully terminated as long as the mongo pod is running. This is because the mongo pod still uses this PVC while it is running. Once the mongo pod deployment is deleted, the PVC finishes terminating and is successfully deleted. Deleting the PVC also deletes the corresponding PV that was dynamically created during the creation of the PVC. No PV was specified for the PVC in the deployment. Thus, by default, the storage class `csi-cinder-sc-delete` creates a PV, in our case `pvc-988d79f7-5bd7-483a-86b2-96237c607e62`, bound to this claim (and therefore it also got deleted with the claim). Below is the PVC `config.yaml` after creation, which shows the storage class used and the PV created for this claim.

```
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  ...
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
  storageClassName: csi-cinder-sc-delete
  volumeMode: Filesystem
  volumeName: pvc-988d79f7-5bd7-483a-86b2-96237c607e62
status:
  accessModes:
    - ReadWriteOnce
  capacity:
    storage: 1Gi
  phase: Bound
```


## **Ad Point 4:** explain the difference between a pv and a pvc
A PV (Persistent Volume) represent a piece of storage in Kubernetes. A PV has an own lifecycle and can be used by multiple Pods for data storage until its deleted. Therefore deleting a Pod will not delete the PV its using. To access and use a PV for storage, the Pod will need a PVC (Persistent Volume Claim) which is more or less a request for storage that can be then be used by specific pod. By deploying a PVC, Kubernetes searches for a PV maching the PVC requirements and provides the Pod using that Claim with this storage. 

## **Ad Point 5:** inspect mongodb contents without using any ingress to the mongo-pod: write down how you achieved that
Access to the Mongo database can be obtained through the pod's shell using either kubectl or rancher-ui. Using kubectl, this can be done using the `exec` method: `kubectl exec -it mongo-6fdcf86d66-bm577 -- bash`.

The credentials such as database name, user, and password used in the mongo deployment are read from the `mongodb-users-secret` secret store. Therefore, this information can be obtained directly from the `secret.yaml` deployment file. However, the secrets are stored in base64 encoded format and must be decoded:

```
database-name: cGFjbWFu -> pacman
database-user: Ymxpbmt5 -> blinky
database-password: cGlua3k= -> pinky
```

By executing `I have no name!@mongo-6fdcf86d66-bm577:/$ mongo -u blinky -p --authenticationDatabase pacman`, we can now access the database:

```
connecting to: mongodb://127.0.0.1:27017/?authSource=pacman&compressors=disabled&gssapiServiceName=mongodb
Implicit session: session { "id" : UUID("9157c0ee-5b9f-4192-a73f-25a885114838") }
MongoDB server version: 4.4.14
> show dbs
pacman  0.000GB
```

## **Ad Point 6:** try to alter the secret, explain what happened
After changing the secrets in `mongodb-users-secret`, nothing happens because the secrets are only read and stored in the environment variables once during the initial deployment of the MongoDB pods. To make use of the new secrets, the MongoDB deployment needs to be redeployed so that the new secrets are picked up and used.

## **Ad Point 7:** modify the replication factor while altering the deployment strategy , what happens ? (did this make sense?, discuss)
TODO

## **Ad Point 8:** redeploy the application after some minor change, alter the deployment strategy , decide which deployment strategy is best for mongodb vs which is best for pacman ? Why did you make this choice?
For pacman the canary deployment strategy would be a good choice as it would give you the possibility to deploy a newer pacman version for a subset of users, while the rest are still able to access the older version of pacman. This way you the team can fix issues in the newer version before rolled out to user. In the meantime all user are able to enjoy the game without any downtime or issues. 

For the database the best deployment strategy would be the rolling update as it is currently set up: This way the database remains avaibale and the data is consistent throughout the deployment process. This way risk of losing data is minimized and furthermore, it does not come to downtimes. Another reason for using this strategy is that we can easily roll back the new version if there are any issues.

## **Ad Point 9:** explain the difference between liveness health and readiness probe, modify the manifests and show clearly how they behave. Is it like you expected? Discuss how having them (or some of them) is differently important for the mongodb vs pacman deployment strategy (see point above)
The liveness probe checks if the container is still running. If the check fails Kubernetes restarts the container. The rediness probe, on the other hand, checks if the container is fully initialized and ready to recieve requests.

The pacman deployment uses the same request for chekcing the readiness and liveness of the pacman container, namely the root endpoint `/`. This works well for checking the readiness since this endpoint will only be available after the database initiialsaition:
```
Database.connect(app, function(err) {
    if (err) {
        console.log('Failed to connect to database server');
    } else {
        console.log('Connected to database server successfully');
    }

});
```
Furthermore , this enpoint can be used for liveness probe to check weather the app is still running.

The mongo deployment uses bitnami scripts for checking the liveness and readiness of the mongo container. Bitnami provides appropriate scripts for these probes:
- `ping-mongodb.sh` for liveness check
- `readiness-probe.sh` for readiness check
## **Ad Point 10:** what use case do you see for a post start hook for a database deployment? 
There are many use cases for using the Kubernetes post start hook:
- initialize/ populate the database with default tables, data and contrains
- change database configurations for performance boost (index strategies, cache, engine, etc..)
- test the database health and database integrity, ...
- start other services or databases

## **Ad Point 11:** last but not least: make the pod die from a OOM (out of memory) by setting resource limits and resource requests . Discuss which setting does what and how to calculate the memory limit
By setting the ressoruces for the pacman deployment as followed, we achieve the pod to die due to lack of memory:
```
   spec:TODO
      containers:
      - image: ghcr.io/austriandatalab/pacman:v0.0.6
        name: pacman
        resources:
          limits:
            cpu: "200m"
            memory: "1Gi"
          requests:
            cpu: "100m"
            memory: "100Gi"
        ....
```
In this example, we try to request 100GB of memory from Kubernetes for this container. Since this goes beyond the avaibale memory, the redeployment will cause a 'Insufficient memory' error.

```
   spec:
      containers:
      - image: ghcr.io/austriandatalab/pacman:v0.0.6
        name: pacman
        resources:
          limits:
            cpu: "20000m"
            memory: "100Gi"
          requests:
            cpu: "100m"
            memory: "1Gi"
        ....
```
Here, on the other hand, we set the resoruce limits to 100GB memory and 200 CPU and the redeployement worked fine. This ressoruce setup may, however, cause out of memory errors while runtime, since the limits are now set to a number of memory and cpu that goes beyond the nodes ressoruces.

The difference between `limits` and `requests` is that, `limits` defines how much ressources CPU and memory the container is allowed to use. Kubernetes checks and keeps its limit below this configuration. The `requests` ressoruces tells how much the container requests (claims for himself) on deployment. Therefore this ressoruce will be reserved for this container. If the container needs more than the requested resorces and the node has enough ressoruces, it will allocate more ressoruces until it reaches the ressoruces set in `limits`.

You can check the availabe ressoruces by checking the avaible ressoruces on the worker nodes. With `kubectl get nodes` you will know which nodes are worker nodes. By running `kubectl bescribe node worker_node_name` you will get lots of infomration including the available ressoruces.