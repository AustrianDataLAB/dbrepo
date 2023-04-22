# Lecture 9: Group Findings and Discussion
This files include the content of the group findings and discussions for lecture 9.
## **Ad Point 1:** implemented adding at least one environment value and prove it is being read by the application

## **Ad Point 2:** discuss for what env should be used (think about the 12-factor)

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

## **Ad Point 5:** inspect mongodb contents without using any ingress to the mongo-pod:** write down how you achieved that
Auf die Mongo Datenbank kann über die Shell des Pods zugegriffen werden. Das kann sowohl mittels kubectl oder rancher-ui durchgeführt werden. Über kubectl geht das über die `exec` methode: `kubectl exec -it mongo-6fdcf86d66-bm577 -- bash`.

Die Credentials wie Datenbank Name, User und Password werden im mongo depoyment aus dem `mongodb-users-secret` secret store gelesen. Daher kann diese Information direkt aus dem `secret.yaml` deployment rausgelesen werden. Die secrets sind dort jedoch base64 encoded gespeichert und müssen decoded werden:

```
database-name: cGFjbWFu -> pacman
database-user: Ymxpbmt5 -> blinky
database-password: cGlua3k= -> pinky
```

Durch das Ausführen von `I have no name!@mongo-6fdcf86d66-bm577:/$ mongo -u blinky -p --authenticationDatabase pacman` bekommen wir nun zugang auf die Datenbank:

```
connecting to: mongodb://127.0.0.1:27017/?authSource=pacman&compressors=disabled&gssapiServiceName=mongodb
Implicit session: session { "id" : UUID("9157c0ee-5b9f-4192-a73f-25a885114838") }
MongoDB server version: 4.4.14
> show dbs
pacman  0.000GB
```

## **Ad Point 6:** try to alter the secret, explain what happened

## **Ad Point 7:** modify the replication factor while altering the deployment strategy , what happens ? (did this make sense?, discuss)

## **Ad Point 8:** redeploy the application after some minor change, alter the deployment strategy , decide which deployment strategy is best for mongodb vs which is best for pacman ? Why did you make this choice?

## **Ad Point 9:** explain the difference between liveness health and readiness probe, modify the manifests and show clearly how they behave. Is it like you expected? Discuss how having them (or some of them) is differently important for the mongodb vs pacman deployment strategy (see point above)

## **Ad Point 10:** what use case do you see for a post start hook for a database deployment? 

## **Ad Point 11:** last but not least: make the pod die from a OOM (out of memory) by setting resource limits and resource requests . Discuss which setting does what and how to calculate the memory limit