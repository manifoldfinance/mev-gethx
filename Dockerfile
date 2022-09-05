# Support setting various labels on the final image
ARG COMMIT=""
ARG VERSION=""
ARG BUILDNUM=""

# Build Geth in a stock Go builder container
FROM golang:1.18.5-alpine3.16@sha256:5f764dacf0f5430271346709cfb28272ac013e30b0b2f9d23cf8ee12bfa98dbc AS builder

# Disable usage of googles golang proxy cache, this is done to ensure deterministic build deps resolution 
ENV GOPROXY=direct

WORKDIR /go-ethereum

RUN apk add --no-cache gcc musl-dev linux-headers git
COPY go.mod go.sum /go-ethereum/

RUN set -eux; \
    go mod download; \
    go mod verify;

ADD . /go-ethereum
RUN cd /go-ethereum && go run build/ci.go install ./cmd/geth

# Pull Geth into a second stage deploy alpine container

FROM alpine:3.16.2@sha256:1304f174557314a7ed9eddb4eab12fed12cb0cd9809e4c28f29af86979a3c870

RUN apk add --no-cache ca-certificates iptables iproute2 ip6tables

COPY --from=builder /go-ethereum/build/bin/geth /usr/local/bin/

EXPOSE 8545 8546 8547 30303 30303/udp
ENTRYPOINT ["geth"]

# Add some metadata labels to help programatic image consumption
ARG COMMIT=""
ARG VERSION=""
ARG BUILDNUM=""

LABEL org.label-schema.build-date=$BUILDNUM \
      org.label-schema.name="Go-Ethereum" \
      org.label-schema.description="MEV GethX" \
      org.label-schema.url="https://github.com/manifoldfinance/mev-gethx" \
      org.label-schema.vcs-ref=$COMMIT \
      org.label-schema.vcs-url="https://github.com/manifoldfinance/mev-gethx.git" \
      org.label-schema.vendor="Manifold Finance, Inc" \
      org.label-schema.version=$VERSION \
      org.label-schema.schema-version="1.0"