FROM golang:1.13-alpine

# Install Terraform. This comes from https://gist.github.com/kaikousa/1a951df681ad2f11b5b0b77180238c44.

RUN wget --quiet https://releases.hashicorp.com/terraform/0.12.20/terraform_0.12.20_linux_amd64.zip \
  && unzip terraform_0.12.20_linux_amd64.zip \
  && mv terraform /usr/bin \
  && rm terraform_0.12.20_linux_amd64.zip

# Install k8s terraform provider (unofficial, but used to support manifests in terraform https://github.com/banzaicloud/terraform-provider-k8s)

RUN GO111MODULE=on go get github.com/banzaicloud/terraform-provider-k8s
# ADD ./backend/terraformrc ~/.terraformrc
RUN mkdir -p ~/.terraform.d/plugins/
RUN mv /$GOPATH/bin/terraform-provider-k8s ~/.terraform.d/plugins/

ADD ./ .

RUN terraform init
RUN terraform plan -input=false
