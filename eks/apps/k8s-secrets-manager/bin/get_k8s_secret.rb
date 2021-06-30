#! /usr/bin/env ruby

require "../lib/secretsmanagers"

secrets_manager=K8sSecretsManager.new
secret_value=secrets_manager.get_secret_value(secret_name: "test")
puts "secret value #{secret_value}"
