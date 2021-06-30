#! /usr/bin/env ruby

require "../lib/secretsmanagers"

secrets_manager=K8sSecretsManager.new
secrets_manager.put_secret_value(secret_name: "test", secret_value: "secret_value")
