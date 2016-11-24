default_environment "staging"
case environment
when 'prod'
  env "DOMAIN_NAMES" => "festivalfanatic.com www.festivalfanatic.com",
      "RAILS_ENV" => "production",
      "REDIS_URL" => "redis://docker0/1",
      "SECRET_KEY_BASE" => secret("fest_prod/secret_key_base"),
      "SMTP_PASSWORD" => secret("fest_prod/festfan_smtp"),
      "NEWRELIC_LICENSE_KEY" => secret("fest_prod/newrelic_license_key")
  port 80 => 8111
when 'staging'
  env "DOMAIN_NAMES" => "staging.festivalfanatic.com www.staging.festivalfanatic.com",
      "RAILS_ENV" => "staging",
      "REDIS_URL" => "redis://docker0/2",
      "SECRET_KEY_BASE" => secret("fest_staging/secret_key_base"),
      "NEWRELIC_LICENSE_KEY" => secret("fest_prod/newrelic_license_key") # staging same as prod
  port 80 => 8112
else
  abort "Invalid fest environment: #{environment.inspect}"
end

setup postgres: [
    "drop database if exists fest_#{environment}",
    "drop role fest_#{environment}",
    "create role fest_#{environment} with superuser login createdb password 'fest_#{environment}'",
    "create database fest_#{environment};",
    "grant all privileges on database fest_#{environment} to fest_#{environment};"
  ],
  container: ["/app/config/docker_db_setup"]

volumes "/data/dnsmasq/dnsmasq" => "/dnsmasq",
        "/data/nginx/etc_nginx_site-files" => "/nginx/site-files",
        "/data/nginx/etc_nginx_sites-enabled" => "/nginx/sites-enabled",
        "/data/fest_#{environment}/data_nightlybackup" => "/data/nightlybackup"

depends_on :dnsmasq, :nginx, :postgres, :redis
