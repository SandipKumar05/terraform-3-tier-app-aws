## Packer Script to Create a New AMI with Recent Code Changes

```bash
# Export GitLab access token
export GITLAB_ACCESS_TOKEN="<token>"

# Build AMI for the 'api' application
export APP_NAME='api'
packer build -var gitlab_access_token=$GITLAB_ACCESS_TOKEN $APP_NAME-aws-ami.pkr.hcl

# Build AMI for the 'web' application
export APP_NAME='web'
packer build -var gitlab_access_token=$GITLAB_ACCESS_TOKEN $APP_NAME-aws-ami.pkr.hcl
