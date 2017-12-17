docker run -it --rm -v /mnt/efs/gitlab-runner:/etc/gitlab-runner
gitlab/gitlab-runner unregister --name autoscale-runner
