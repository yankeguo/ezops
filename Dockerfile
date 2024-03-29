FROM golang:1.21 AS builder
ENV CGO_ENABLED 0
WORKDIR /go/src/app
ADD . .
RUN go build -o /ezops ./cmd/ezops

FROM alpine:3.18

RUN apk add --no-cache ca-certificates tzdata curl && \
    curl -sSL -o /usr/local/bin/kubectl "https://dl.k8s.io/release/v1.24.17/bin/linux/amd64/kubectl" && \
    chmod +x /usr/local/bin/kubectl && \
    curl -sSL -o helm.tar.gz "https://get.helm.sh/helm-v3.12.3-linux-amd64.tar.gz" && \
    mkdir -p helm && \
    tar -xf helm.tar.gz -C helm --strip-components 1 && \
    mv helm/helm /usr/local/bin/helm && \
    rm -rf helm.tar.gz helm

COPY --from=builder /ezops /usr/local/bin/ezops

ENTRYPOINT ["ezops"]

WORKDIR /data
