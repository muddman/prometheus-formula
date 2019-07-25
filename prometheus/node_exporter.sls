
    
#!jinja|yaml

{%- set version = salt['pillar.get']('prometheus:node_exporter:version') %}
{%- set hash = salt['pillar.get']('prometheus:node_exporter:hash') %}

# SLS includes/ excludes
include: 
  - ._user



node_version_{{ version }}:
  archive:
    - extracted
    - name: /opt/prometheus/node_exporter
    - source: https://github.com/prometheus/node_exporter/releases/download/v{{ version }}/node_exporter-{{ version }}.linux-amd64.tar.gz
    - source_hash: {{ hash }}
    - user: prometheus
    - group: prometheus
    - clean: True



node_exporter_service_script:
  file:
    - managed
    - name: /usr/lib/systemd/system/node_exporter.service
    - user: root
    - group: root
    - makedirs: True
    - contents: |
        [Unit]
        Description=node_exporter service
        Wants=network-online.target
        After=

        [Service]
        Type=simple
        RemainAfterExit=no
        WorkingDirectory=/var/lib/prometheus/node_exporter
        User=prometheus
        Group=prometheus
        ExecStart=/opt/prometheus/node_exporter/node_exporter-{{ version }}.linux-amd64/node_exporter 
        PIDFile=/var/run/node_exporter.pid

        [Install]
        WantedBy=multi-user.target

node_service:
  service:
    - running
    - name: node_exporter
    - enable: True
