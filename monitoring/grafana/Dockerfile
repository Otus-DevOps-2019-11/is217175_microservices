FROM grafana/grafana:6.6.2
LABEL imagename="grafana" version="latest"

COPY datasource.yml  /etc/grafana/provisioning/datasources/
COPY dashboards.yml /etc/grafana/provisioning/dashboards/
COPY dashboards/*.json /var/lib/grafana/dashboards/
