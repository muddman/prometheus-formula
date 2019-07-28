#!jinja|yaml

group_prometheus:
  group:
    - present
    - name: prometheus
    - system: True

user_prometheus:
  user:
    - present
    - name: prometheus
    - groups:
      - prometheus
    - home: /opt/prometheus
    - createhome: True
    - shell: /bin/false
    - system: True

file-basedir-file-directory:
  file.directory:
    - name: /opt/prometheus
    - user: prometheus
    - group: prometheus
    - mode: 755
    - makedirs: True

file-basedir-config-directory:
  file.directory:
    - name: /etc/prometheus
    - user: prometheus
    - group: prometheus
    - mode: 755
    - makedirs: True

create_working_dir:
  file.directory:
    - name: /var/lib/prometheus
    - user: prometheus
    - group: prometheus
    - mode: 755
    - makedirs: True