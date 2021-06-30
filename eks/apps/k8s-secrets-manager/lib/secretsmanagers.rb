require "aws-sdk-secretsmanager"
require "kubeclient"

class AWSSecretsManager
  def initialize
    credentials = Aws::AssumeRoleCredentials.new(
      client: Aws::STS::Client.new,
      role_arn: ENV["ASSUME_ROLE_ARN"],
      role_session_name: "wait-for-#{application}-#{variant}-secrets",
    )
    @secrets_client = Aws::SecretsManager::Client.new(
      region: ENV["AWS_REGION"],
      credentials: credentials,
    )
  end

  def get_secret_value(secret_name:)
    @secrets_client.get_secret_value(
      secret_id: secret_name,
      version_stage: "AWSCURRENT",
    )
  end

  def put_secret_value(secret_name:, secret_value:)
    @secrets_client.put_secret_value(
      secret_id: secret_name,
      secret_string: secret_value,
      version_stages: %w[AWSCURRENT],
    )
  end
end

class K8sSecretsManager
  def initialize
    auth_options = {
      bearer_token_file: '/var/run/secrets/kubernetes.io/serviceaccount/token'
    }
    ssl_options = {}
    if File.exist?("/var/run/secrets/kubernetes.io/serviceaccount/ca.crt")
      ssl_options[:ca_file] = "/var/run/secrets/kubernetes.io/serviceaccount/ca.crt"
    end
    @secrets_client = Kubeclient::Client.new(
      'https://kubernetes.default.svc',
      'v1',
      auth_options: auth_options,
      ssl_options:  ssl_options
    )
    @namespace = File.read('/var/run/secrets/kubernetes.io/serviceaccount/namespace')
  end

  def get_secret_value(secret_name:)
    secret = @secrets_client.get_secret(
      secret_name,
      @namespace
      )
    Base64.decode64(secret.data[secret_name])
  end

  def put_secret_value(secret_name:, secret_value:)
    secret = Kubeclient::Resource.new
    secret.metadata = {}
    secret.metadata.name = secret_name
    secret.metadata.namespace = @namespace
    secret.data = {}
    secret.data[secret_name] = Base64.encode64(secret_value)

    @secrets_client.create_secret(secret)
  end
end
