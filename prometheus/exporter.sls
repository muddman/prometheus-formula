   
#!jinja|yaml

# SLS includes/ excludes
include: 
  - ._user

{%- for name, params in salt['pillar.get']('prometheus:exporter', {}).iteritems() %}

{%- set source = params.source %}
{%- set version= params.version %}
{%- set hash = params.hash %}
{%- set switches = params.switches|default() %}
{%- set env = params.env|default() %}


node_version_{{ name }}:
  archive:
    - extracted
    - name: /opt/prometheus/
    - source: {{ source }}
    - source_hash: {{ hash }}
    - user: prometheus
    - group: prometheus




{{ name }}_service_script:
  file:
    - managed
    - name: /usr/lib/systemd/system/{{ name }}.service
    - user: root
    - group: root
    - makedirs: True
    - contents: |
        [Unit]
        Description={{ name }} service
        Wants=network-online.target
        After=

        [Service]
        {%- if env  %}
        Environment={{ env }}
        {%- endif %}
        Type=simple
        RemainAfterExit=no
        WorkingDirectory=/var/lib/prometheus
        User=prometheus
        Group=prometheus
        ExecStart=/opt/prometheus/{{ name }}-{{ version }}.linux-amd64/{{ name }} {{ switches }}
        PIDFile=/var/run/node_exporter.pid

        [Install]
        WantedBy=multi-user.target

{{ name }}_reload_systemd:
  module.wait:
    - name: service.systemctl_reload
    - watch:
      - file: /usr/lib/systemd/system/{{ name }}.service

{{ name }}_service:
  service:
    - running
    - name: {{ name }}
    - enable: True

{% endfor %}