# Jenkins and Gitea boilerplate

## What a hell?

Whenever I want to setup a new project on my homelab with Jenkins and Gitea, I need to click on Jenkins console to configure the Git repository, SSH keys, plugins and a bunch of stuff. Also, I need to create a Gitea repository and configure webhook (pain in the ass :'().

## How it works?

Simple: Sequential API calls to Jenkins and Gitea with the same project name (lol).

## How can I use?

Open the script and fill these variables:

```
GITEA_TOKEN=""
GITEA_ADDRESS="<scm.domain.com>"
GITEA_ORGANIZATION="<organization>"
GIT_SERVER="git@${GITEA_ADDRESS}:${GITEA_ORGANIZATION}"
JENKINS_TOKEN="<user>:<token>"
JENKINS_ADDRESS="<jenkins.domain.com>"
JENKINS_PAYLOAD="repo_config.xml"
PROJECT_NAME="${1}"
WEBHOOK_URL="http://jenkins.jenkins.svc.cluster.local:8080"
```

## Ok, but how to get these tokens?

#### Jenkins

1. Dashboard.
2. Manage Jenkins.
3. Manage Users.
4. Select the user.
5. Configure.
6. API Token.
7. There should be a `Generate` or `Add new Token` button.

#### Gitea

1. User Settings.
2. Applications.
3. Managed Access Tokens, click on `Generate Token`.

## Example

```
GITEA_TOKEN="jdsa98dud8a919d23"
GITEA_ADDRESS="scm.yourdomain.com"
GITEA_ORGANIZATION="yourcompany"
GIT_SERVER="git@${GITEA_ADDRESS}:${GITEA_ORGANIZATION}"
JENKINS_TOKEN="youruser:jdsa98dasu9asdj"
JENKINS_ADDRESS="jenkins.yourdomain.com"
JENKINS_PAYLOAD="repo_config.xml"
PROJECT_NAME="${1}"
WEBHOOK_URL="http://jenkins.jenkins.svc.cluster.local:8080"
```

Of course, don't forget changing the webhook URL to be configured under `WEBHOOK_URL`.

## What about config.xml?

The `config.xml` is the "template" I use to create the same kind of pipeline configuration always.

You can create a new pipeline, adjust to your needs and then get the XML to build your own kind of template.

Let's say your pipeline is under `https://jenkins.yourdomain.com/job/some-pipeline/`.

In order to get the config.xml, just access `https://jenkins.yourdomain.com/job/some-pipeline/config.xml`.

Don't bother if you see the message `XML Parsing Error: XML declaration not well-formed`. Right click on the browser -> View Page Source.