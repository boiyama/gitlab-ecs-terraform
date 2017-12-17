## GitLab configuration settings
##! Check out the latest version of this file to know about the different
##! settings that can be configured by this file, which may be found at:
##! https://gitlab.com/gitlab-org/omnibus-gitlab/raw/master/files/gitlab-config-template/gitlab.rb.template

## GitLab URL
##! URL on which GitLab will be reachable.
##! For more details on configuring external_url see:
##! https://docs.gitlab.com/omnibus/settings/configuration.html#configuring-the-external-url-for-gitlab
external_url 'https://${gitlab_host}'

################################################################################
## gitlab.yml configuration
##! Docs: https://gitlab.com/gitlab-org/omnibus-gitlab/blob/master/doc/settings/gitlab.yml.md
################################################################################

gitlab_rails['gitlab_ssh_host'] = '${gitlab_ssh_host}'
gitlab_rails['time_zone'] = 'UTC'

### Email Settings
gitlab_rails['gitlab_email_enabled'] = true
gitlab_rails['gitlab_email_from'] = 'noreply@${gitlab_host}'
gitlab_rails['gitlab_email_display_name'] = 'GitLab'
gitlab_rails['gitlab_email_reply_to'] = 'noreply@${gitlab_host}'
# gitlab_rails['gitlab_email_subject_suffix'] = ''

### Default project feature settings
# gitlab_rails['gitlab_default_projects_features_issues'] = true
# gitlab_rails['gitlab_default_projects_features_merge_requests'] = true
# gitlab_rails['gitlab_default_projects_features_wiki'] = true
# gitlab_rails['gitlab_default_projects_features_snippets'] = true
# gitlab_rails['gitlab_default_projects_features_builds'] = true
# gitlab_rails['gitlab_default_projects_features_container_registry'] = true

### Backup Settings
###! Docs: https://docs.gitlab.com/omnibus/settings/backups.html

gitlab_rails['backup_upload_connection'] = {
  'provider' => 'AWS',
  'region' => '${region}',
  'aws_access_key_id' => '${access_key}',
  'aws_secret_access_key' => '${secret_key}'
}
gitlab_rails['backup_upload_remote_directory'] = '${bucket_name}'

### GitLab database settings
###! Docs: https://docs.gitlab.com/omnibus/settings/database.html
###! **Only needed if you use an external database.**
gitlab_rails['db_adapter'] = 'postgresql'
gitlab_rails['db_database'] = 'gitlabhq_production'
gitlab_rails['db_username'] = 'gitlab'
gitlab_rails['db_password'] = '${db_password}'
gitlab_rails['db_host'] = '${db_host}'
gitlab_rails['db_port'] = 5432

### GitLab Redis settings
###! Connect to your own Redis instance
###! Docs: https://docs.gitlab.com/omnibus/settings/redis.html

#### Redis TCP connection
gitlab_rails['redis_host'] = '${redis_host}'
gitlab_rails['redis_port'] = 6379

### GitLab email server settings
###! Docs: https://docs.gitlab.com/omnibus/settings/smtp.html
###! **Use smtp instead of sendmail/postfix.**

gitlab_rails['smtp_enable'] = true
gitlab_rails['smtp_address'] = '${smtp_address}'
gitlab_rails['smtp_port'] = 587
gitlab_rails['smtp_user_name'] = '${smtp_user_name}'
gitlab_rails['smtp_password'] = '${smtp_password}'
gitlab_rails['smtp_domain'] = '${gitlab_host}'
gitlab_rails['smtp_authentication'] = 'login'
gitlab_rails['smtp_enable_starttls_auto'] = true
# gitlab_rails['smtp_tls'] = false

################################################################################
## GitLab Nginx
##! Docs: https://docs.gitlab.com/omnibus/settings/nginx.html
################################################################################

# nginx['ssl_certificate'] = '/etc/gitlab/ssl/certificate.pem'
# nginx['ssl_certificate_key'] = '/etc/gitlab/ssl/certificate.key'
nginx['listen_port'] = 80
nginx['listen_https'] = false

################################################################################
## Container Registry settings
##! Docs: https://docs.gitlab.com/ce/administration/container_registry.html
################################################################################

registry_external_url 'https://${registry_host}'

### Registry backend storage
###! Docs: https://docs.gitlab.com/ce/administration/container_registry.html#container-registry-storage-driver
# registry['storage'] = {
#   's3' => {
#     'accesskey' => 'AKIAKIAKI',
#     'secretkey' => 'secret123',
#     'bucket' => 'gitlab-registry-bucket-AKIAKIAKI'
#   }
# }

### Registry notifications endpoints
# registry['notifications'] = [
#   {
#     'name' => 'test_endpoint',
#     'url' => 'https://${gitlab_host}/notify2',
#     'timeout' => '500ms',
#     'threshold' => 5,
#     'backoff' => '1s',
#     'headers' => {
#       'Authorization' => ['AUTHORIZATION_EXAMPLE_TOKEN']
#     }
#   }
# ]

################################################################
## GitLab PostgreSQL
################################################################

postgresql['enable'] = false

################################################################################
## GitLab Redis
##! **Can be disabled if you are using your own Redis instance.**
##! Docs: https://docs.gitlab.com/omnibus/settings/redis.html
################################################################################

redis['enable'] = false

################################################################################
## Registry NGINX
################################################################################

# registry_nginx['ssl_certificate'] = '/etc/gitlab/ssl/certificate.pem'
# registry_nginx['ssl_certificate_key'] = '/etc/gitlab/ssl/certificate.key'
registry_nginx['listen_port'] = 80
registry_nginx['listen_https'] = false

################################################################################
## GitLab Pages
##! Docs: https://docs.gitlab.com/ce/pages/administration.html
################################################################################

##! Define to enable GitLab Pages
pages_external_url 'https://${pages_host}/'

################################################################################
## GitLab Pages NGINX
################################################################################

# pages_nginx['ssl_certificate'] = '/etc/gitlab/ssl/certificate.pem'
# pages_nginx['ssl_certificate_key'] = '/etc/gitlab/ssl/certificate.key'
pages_nginx['listen_port'] = 80
pages_nginx['listen_https'] = false

################################################################################
## GitLab Mattermost
##! Docs: https://docs.gitlab.com/omnibus/gitlab-mattermost
################################################################################

mattermost_external_url 'https://${mattermost_host}'

mattermost['service_site_url'] = 'https://${mattermost_host}'
mattermost['service_enable_incoming_webhooks'] = true
mattermost['service_enable_outgoing_webhooks'] = true
mattermost['service_enable_link_previews'] = true
mattermost['service_enable_custom_emoji'] = true

mattermost['team_enable_team_creation'] = false
mattermost['team_enable_user_creation'] = false

mattermost['sql_driver_name'] = 'postgres'
mattermost['sql_data_source'] = 'user=gitlab_mattermost password=${mattermost_db_password} host=${mattermost_db_host} port=5432 dbname=mattermost_production'

# mattermost['aws'] = {'S3AccessKeyId' => '123', 'S3SecretAccessKey' => '123', 'S3Bucket' => 'aa', 'S3Region' => 'bb'}

mattermost['email_send_email_notifications'] = true
mattermost['email_smtp_username'] = '${smtp_user_name}'
mattermost['email_smtp_password'] = '${smtp_password}'
mattermost['email_smtp_server'] = '${smtp_address}'
mattermost['email_smtp_port'] = 587
# mattermost['email_send_push_notifications'] = true
# mattermost['email_push_notification_server'] = ""
# mattermost['email_push_notification_contents'] = "generic"
mattermost['email_enable_batching'] = true
mattermost['email_smtp_auth'] = true

# mattermost['file_amazon_s3_access_key_id'] = nil
# mattermost['file_amazon_s3_bucket'] = nil
# mattermost['file_amazon_s3_secret_access_key'] = nil
# mattermost['file_amazon_s3_region'] = nil
# mattermost['file_amazon_s3_endpoint'] = nil
# mattermost['file_amazon_s3_bucket_endpoint'] = nil
# mattermost['file_amazon_s3_location_constraint'] = false
# mattermost['file_amazon_s3_lowercase_bucket'] = false
# mattermost['file_amazon_s3_ssl'] = true

# mattermost['localization_server_locale'] = 'en'
# mattermost['localization_client_locale'] = 'en'
# mattermost['localization_available_locales'] = 'en,es,fr,ja,pt-BR'

mattermost['webrtc_enable'] = true
mattermost['webrtc_gateway_websocket_url'] = 'wss://${webrtc_gateway_websocket_host}'
mattermost['webrtc_gateway_admin_url'] = 'https://${webrtc_gateway_admin_host}/admin'
mattermost['webrtc_gateway_admin_secret'] = 'janusoverlord'
# mattermost['webrtc_gateway_stun_uri'] = nil
# mattermost['webrtc_gateway_turn_uri'] = nil
# mattermost['webrtc_gateway_turn_username'] = nil
# mattermost['webrtc_gateway_turn_shared_key'] = nil

################################################################################
## Mattermost NGINX
################################################################################

# mattermost_nginx['ssl_certificate'] = '/etc/gitlab/ssl/certificate.pem'
# mattermost_nginx['ssl_certificate_key'] = '/etc/gitlab/ssl/certificate.key'
mattermost_nginx['listen_port'] = 80
mattermost_nginx['listen_https'] = false

################################################################################
## Prometheus
##! Docs: https://docs.gitlab.com/ce/administration/monitoring/prometheus/
################################################################################

# prometheus['enable'] = true
# prometheus['monitor_kubernetes'] = true

################################################################################
## Prometheus Gitlab monitor
##! Docs: https://docs.gitlab.com/ce/administration/monitoring/prometheus/gitlab_monitor_exporter.html
################################################################################

# gitlab_monitor['enable'] = true

# To completely disable prometheus, and all of it's exporters, set to false
# prometheus_monitoring['enable'] = true

################################################################################
## Gitaly
##! Docs:
################################################################################

gitaly['enable'] = true
