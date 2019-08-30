# elastic-on-gke

Following the instructions here: https://github.com/GoogleCloudPlatform/click-to-deploy/tree/master/k8s/elastic-gke-logging. Tweaks highlighted where relevant.

---

## Installation

1. Installation steps from the above are wrapped up in the bash script `./install.sh`. Check the variables at the top before executing!

    This uses the Helm Chart from the link above. This will generate k8s yaml in `./k8s/`. The resource limits for this are too heavyweight for my small personal-use GKE cluster, so we need to do some shrinking:

    - `resource` was declared twice for Elastic - delete one
    - set CPU / memory request/limits to lower values. I tried my luck with 0.1/1 CPU, then 500Mb/1Gb
    - ES_JAVA_OPTS needs changing to be under your memory value

2. `export NAMESPACE=${NAMESPACE} && ./deploy.sh` will apply the generated manifest

I also encountered an issue with the volume claim - as far as I can tell, the PVC was binding to a node that didn't have space for the pod to run. I managed to work around this problem by defining a separate storageClass (rather than relying on default) and specifying `volumeBindingMode: WaitForFirstConsumer`, then updating the `volumeClaimTemplate` to use this.

## To Do

- [ ] Make resource changes permanent
