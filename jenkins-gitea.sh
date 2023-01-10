#!/bin/bash

GITEA_TOKEN=""
GITEA_ADDRESS="<scm.domain.com>"
GITEA_ORGANIZATION="<organization>"
GIT_SERVER="git@${GITEA_ADDRESS}:${GITEA_ORGANIZATION}"
JENKINS_TOKEN="<user>:<token>"
JENKINS_ADDRESS="<jenkins.domain.com>"
JENKINS_PAYLOAD="repo_config.xml"
PROJECT_NAME="${1}"
WEBHOOK_URL="http://jenkins.jenkins.svc.cluster.local:8080"

function generate_config_xml() {
  sed "s/PROJECT_NAME/${PROJECT_NAME}/g;s/GIT_SERVER/${GIT_SERVER}/g" config.xml > ${JENKINS_PAYLOAD}
}

function clear_config_xml() {
  rm -f ${JENKINS_PAYLOAD}
}

function create_pipeline() {
  echo "Creating Jenkins pipeline..."
  curl -X POST https://${JENKINS_TOKEN}@${JENKINS_ADDRESS}/createItem?name=${PROJECT_NAME} \
       -H "Content-Type:text/xml" \
       -d @${JENKINS_PAYLOAD} &> /dev/null
}

function create_repository() {
  echo "Creating Gitea repository..."
  curl -X POST https://${GITEA_ADDRESS}/api/v1/orgs/${GITEA_ORGANIZATION}/repos \
       -H 'accept: application/json' \
       -H 'Content-Type: application/json' \
       -H "Authorization: token ${GITEA_TOKEN}" \
       -d "{
            \"auto_init\": true,
            \"default_branch\": \"master\",
            \"description\": \"First version of project ${PROJECT_NAME}\",
            \"name\": \"${PROJECT_NAME}\",
            \"private\": false
          }" &> /dev/null
}

function create_webhook() {
  echo "Creating webhook..."
  curl -X POST https://${GITEA_ADDRESS}/api/v1/repos/${GITEA_ORGANIZATION}/${PROJECT_NAME}/hooks \
       -H 'accept: application/json' \
       -H 'Content-Type: application/json' \
       -H "Authorization: token ${GITEA_TOKEN}" \
       -d "{
            \"active\": true,
            \"branch_filter\": \"*\",
            \"config\": {
              \"content_type\": \"json\",
              \"url\": \"${WEBHOOK_URL}/multibranch-webhook-trigger/invoke?token=${PROJECT_NAME}\",
              \"http_method\": \"post\"
            },
            \"events\": [
              \"push\",
              \"create\"
            ],
            \"type\": \"gitea\"
          }" &> /dev/null
  }

function main() {
  generate_config_xml
  create_pipeline
  clear_config_xml
  create_repository
  create_webhook
}

main