FROM golang:1.13-alpine

# Install Terraform. This comes from https://gist.github.com/kaikousa/1a951df681ad2f11b5b0b77180238c44.

RUN wget --quiet https://releases.hashicorp.com/terraform/0.12.21/terraform_0.12.21_linux_amd64.zip \
  && unzip terraform_0.12.21_linux_amd64.zip \
  && mv terraform /usr/bin \
  && rm terraform_0.12.21_linux_amd64.zip

# Install k8s terraform provider (unofficial, but used to support manifests in terraform https://github.com/banzaicloud/terraform-provider-k8s)

ADD ./ .
RUN mv ./k8s-provider-linux ./terraform-provider-k8s_v0.7.2

RUN terraform init
RUN terraform plan -input=false
