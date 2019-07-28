

#!jinja|yaml

{%- set version = salt['pillar.get']('prometheus:server:version') %}
{%- set hash = salt['pillar.get']('prometheus:server:hash') %}

# SLS includes/ excludes
include:
  - ._user


prometheus_server_version_{{ version }}:
  archive:
    - extracted
    - name: /opt/prometheus/server
    - source: https://github.com/prometheus/prometheus/releases/download/v{{ version }}/prometheus-{{ version }}.linux-amd64.tar.gz
    - source_hash: {{ hash }}
    - user: prometheus
    - group: prometheus
    - clean: True


prometheus_server_config:
  file:
    - serialize
    - name: /etc/prometheus/prometheus.yml
    - user: prometheus
    - group: prometheus
    - mode: 640
    - dataset_pillar: prometheus:server:config
    - watch_in:
      - service: prometheus


prometheus_server_service_script:
  file:
    - managed
    - name: /usr/lib/systemd/system/prometheus.service
    - user: root
    - group: root
    - makedirs: True
    - contents: |
        [Unit]
        Description=prometheus - prometheus service
        Wants=network-online.target
        After=

        [Service]
        Type=simple
        RemainAfterExit=no
        WorkingDirectory=/var/lib/prometheus/prometheus
        User=prometheus
        Group=prometheus
        ExecStart=/opt/prometheus/server/prometheus-{{ version }}.linux-amd64/prometheus --config.file=/etc/prometheus/prometheus.yml --log.level info
        PIDFile=/var/run/prometheus.pid

        [Install]
        WantedBy=multi-user.target

prometheus_server_service:
  service:
    - running
    - name: prometheus
    - enable: True
