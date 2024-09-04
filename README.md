# SUSE Quality Assurance Engineer – Technical Challenge

The repository has the goal to describe the solution of the tests provided by Suse.

## Set up

The next steps were tested using the follow configurations and tools version:

1. __Docker__: 27.0.3
2. __NodeJS__: v20.17.0
3. __NPM__: 10.8.2
4. __Go__: 1.23.0
5. __Google Chrome__: 128.0.6613.113

To run the container locally execute the follow command:
```sh
docker run -d --restart=unless-stopped \
              --privileged \
              -p 8080:80 -p 8443:443 \
              -e CATTLE_BOOTSTRAP_PASSWORD="mypassword123" \
              rancher/rancher:latest
```

To check if the Rancher is running it's possible run follow through the logs `docker logs <container-id> -f` or run the follow script

```sh
curl -sk -X GET -H "Content-Type: application/json" https://localhost:8443 > /dev/null
RANCHER_STATUS=$?

while [[ $RANCHER_STATUS -ne 0 ]]
do
    echo "Rancher starting, waiting..."
    sleep 5
    curl -sk -X GET -H "Content-Type: application/json" https://localhost:8443 > /dev/null
    RANCHER_STATUS=$?
done
```

After Rancher is running, use the password `mypassword123` and set the server URL as `https://localhost:8443`.

## Level 1: UI Automation using Cypress framework

To make the login UI tests was necessary use the [cypress Lauchpad](https://docs.cypress.io/guides/getting-started/opening-the-app#The-Launchpad) to open a browser and check the id of the name and password fields. Once I had the URL and the id field I just wrote the test code. To run the tests just execute the follow commands:

```sh
cd frontend/
npm install
export CYPRESS_RANCHER_USER="admin"
export CYPRESS_RANCHER_PASSWORD="mypassword123"
npm run test
```
The result was:
```sh
  (Results)

  ┌────────────────────────────────────────────────────────────────────────────────────────────────┐
  │ Tests:        1                                                                                │
  │ Passing:      1                                                                                │
  │ Failing:      0                                                                                │
  │ Pending:      0                                                                                │
  │ Skipped:      0                                                                                │
  │ Screenshots:  0                                                                                │
  │ Video:        false                                                                            │
  │ Duration:     27 seconds                                                                       │
  │ Spec Ran:     spec.cy.js                                                                       │
  └────────────────────────────────────────────────────────────────────────────────────────────────┘


====================================================================================================

  (Run Finished)


       Spec                                              Tests  Passing  Failing  Pending  Skipped
  ┌────────────────────────────────────────────────────────────────────────────────────────────────┐
  │ ✔  spec.cy.js                               00:27        1        1        -        -        - │
  └────────────────────────────────────────────────────────────────────────────────────────────────┘
    ✔  All specs passed!                        00:27        1        1        -        -        -
```

# Level 2: API Automation using Go lang (standard test framework or ginkgo)

The second level consists of testing the authentication API. I didn't find any documentation about authentication API using user and password, so I followed the requests made by the IU using the developer tools available in the Chrome. The request mapped was a `POST` using the endpoint `/v3-public/localProviders/local?action=login` and passing the user and password through the body, as described below.

```sh
curl -k -X POST -H "Content-Type: application/json" \
-d '{description: "UI session", responseType: "cookie", username: "admin", password: "mypassword123"}' \
https://localhost:8443/v3-public/localProviders/local?action=login
```

So after mapping the endpoint and parameters was just writing the test code. To run the test just execute the follow commands:

```sh
export RANCHER_USER="admin"
export RANCHER_PASSWORD="mypassword123"
cd backend/
go get github.com/onsi/ginkgo/v2
go get github.com/onsi/gomega/...
ginkgo
```
The result was:
```sh
Running Suite: Backend Suite - /Users/rafaelsvieira/Projects/Challenge/Suse/backend
===================================================================================
Random Seed: 1725404209

Will run 2 of 2 specs
••

Ran 2 of 2 Specs in 0.311 seconds
SUCCESS! -- 2 Passed | 0 Failed | 0 Pending | 0 Skipped
PASS

Ginkgo ran 1 suite in 6.456471643s
Test Suite Passed
```

## Level 3: Deploy a VM on GCP

The last test has the goal to provision a Virtual Machine (VM) on GCP. I chose Terraform as infrastructure as code (IaC) and in addition to creating the instance, the VPC and the subnet were created. To provisioning the infrastructure just execute the follow commands:

```sh
gcloud init
gcloud auth login
cd infra/
terraform init
terraform plan -var="project_id=suse-test-123456"
terraform apply -var="project_id=suse-test-123456" -auto-approve
```

The result was:
```sh
google_compute_network.vpc_network: Creating...
google_compute_network.vpc_network: Still creating... [10s elapsed]
google_compute_network.vpc_network: Still creating... [20s elapsed]
google_compute_network.vpc_network: Creation complete after 23s [id=projects/suse-test-123456/global/networks/my-vpc]
google_compute_subnetwork.subnet: Creating...
google_compute_subnetwork.subnet: Still creating... [10s elapsed]
google_compute_subnetwork.subnet: Still creating... [20s elapsed]
google_compute_subnetwork.subnet: Creation complete after 21s [id=projects/suse-test-123456/regions/us-central1/subnetworks/my-subnet]
google_compute_instance.vm_instance: Creating...
google_compute_instance.vm_instance: Still creating... [10s elapsed]
google_compute_instance.vm_instance: Still creating... [20s elapsed]
google_compute_instance.vm_instance: Creation complete after 23s [id=projects/suse-test-123456/zones/us-central1-a/instances/my-instance]

Apply complete! Resources: 3 added, 0 changed, 0 destroyed.
```

`Improvement point`: The state file was stored locally, because it was just a test. If it was a real project, the state file must be stored in another place, for example, Storage bucket.

## Tear down

The last step is delete/stop every resource that was created, so just execute the follow commands:

```sh
docker rm -f $(docker ps -aq)
cd infra/
terraform destroy -var="project_id=suse-test-123456" -auto-approve
```