# Support setting various labels on the final image
ARG COMMIT=""
ARG VERSION=""
ARG BUILDNUM=""

# Build Geth in a stock Go builder container
FROM golang:1.18-alpine as builder

ENV GOPROXY=direct

WORKDIR /go-ethereum

RUN apk add --no-cache gcc musl-dev linux-headers git
COPY go.mod go.sum /go-ethereum/

RUN set -eux; \
  go mod download; \
	go mod verify
  
ADD . /go-ethereum
RUN cd /go-ethereum && go run build/ci.go install ./cmd/geth

# Pull Geth into a second stage deploy alpine container
FROM alpine:3.16

RUN apk add --no-cache ca-certificates iptables iproute2 ip6tables

COPY --from=builder /go-ethereum/build/bin/geth /usr/local/bin/

EXPOSE 8545 8546 30303 30303/udp
ENTRYPOINT ["geth"]

# Add some metadata labels to help programatic image consumption
ARG COMMIT=""
ARG VERSION=""
ARG BUILDNUM=""

LABEL commit="$COMMIT" version="$VERSION" buildnum="$BUILDNUM"
