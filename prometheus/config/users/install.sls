# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import prometheus with context %}

{%- if prometheus.wanted != 'prometheus' %}

prometheus-ever-present-as-user:
  group.present:
    - name: prometheus
  user.present:
    - name: prometheus
    - shell: /bin/false
    - createhome: false
    - groups:
      - prometheus

{%- endif %}


  {%- for name in prometheus.wanted %}

prometheus-config-user-install-{{ name }}-user-present:
  group.present:
    - name: {{ name }}
    - require_in:
      - user: prometheus-config-user-install-{{ name }}-user-present
  user.present:
    - name: {{ name }}
    - shell: /bin/false
    - createhome: false
    - groups:
      - {{ name }}
      {%- if grains.os_family == 'MacOS' %}
    - unless: /usr/bin/dscl . list /Users | grep {{ name }} >/dev/null 2>&1
      {%- endif %}

  {%- endfor %}

