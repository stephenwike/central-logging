# Elastic Stack

## Settup up Ubuntu VM Environment

Install java, get elastic GPG-KEY, add elastic packages, increase the max_map_count.

```
apt update && apt install -y openjdk-11-jre-headless
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | apt-key add -
echo "deb https://artifacts.elastic.co/packages/7.x/apt stable main" | tee /etc/apt/sources.list.d/elastic-7.x.list
sysctl -w vm.max_map_count=262144
```

## Setting up elasticsearch on Ubuntu VM

Install **elasticsearch**.  

```
apt update && apt install -y elasticsearch
```

Configure the elasticsearch yaml file `/etc/elasticsearch/elasticsearch.yml`
* cluster.name: central-logging
* node.name: localhost
* network.host: 127.0.0.1
* discovery.seed_hosts: ["127.0.0.1"]
* discovery.type: single-node

Start and check elasticssearch

```
service elasticsearch start
systemctl enable elasticsearch
curl localhost:9200
```

## Setting up logstash on Ubuntu VM

Install **logstash**.

```
apt update && apt install -y logstash
```

Add a new `beats.conf` file inside `/etc/logstash/conf.d/`

``` file
input{
    beats{
        port => "5043"
    }
}

filter{
    if [type] == "syslog"{
        grok {
            match => { "message" => "%SYSLOGTIMESTAMP:syslog_timestamp} %{SYSLOGHOST:syslog_hostname} %{DATA:syslog_program}(?:\[%{POSINT:syslog_pid}\])?: %{GREEDYDATA:syslog_message}" }
        }
        date {
            match => [ "syslog_timestamp", "MMM  d HH:mm:ss", "MMM dd HH:mm:ss" ]
        }
    }
}

output{
    elasticsearch{
        hosts => ["127.0.0.1:9200"]
        index => "%{[@metadata][beat]}-%{+YYYY.MM.dd}"
        document_type => "%{[@metadata][type]}"
    }
}
```

Start and check logstash

```
service logstash start
systemctl enable logstash
```

TODO:  Add check example here...

## Setting up kibana on Ubuntu VM

Install **kibana**.

```
apt update && apt install -y kibana
```

Configure Kibana yaml file `/etc/kibana/kibana.yml`
* server.host: "\<inet ip address\>"
* server.name: "localhost"
* elasticsearch.url: "http://127.0.0.1:9200"

> inet ip address can be found using `ifconfig` command.

Start and check kibana

```
service kibana start
systemctl enable kibana
```

Navigate to `http://<inet ip address>:5601` and check that kibana starts.

## Setting up filebeat

Install **filebeat**.

```
apt update && apt install -y filebeat
```

Configure filebeat yaml file `/etc/filebeat/filebeat.yml`

```
filebeat.inputs:
- type: log
  enabled: true
    paths:
    - /var/log/syslog
    document_type: syslog
  tags: ["<host name>"]
  fields:
    env: staging
  # Comment these  
  #output.elasticsearch:  
    #hosts: ["localhost:9200"]
  # Uncomment these
  output.logstash:
    hosts: ["localhost:5043"]
```

Start filebeat

```
service filebeat start
systemctl enable filebeat
```

### Configure filebeat in Kibana

Navigate to **Stack Management > Kibana > Index Patterns**. Click on **Create Index Pattern**.
* Index Pattern Name: `filebeat-*`
* Time field: `@timestamp`

Navigate to **Discover** and select `filebeat-*` to veiw logs.

Navigate to **Dashboard** to  work with visualizing data.

## Setting up metricbeat

Install **metricbeat**.

```
apt update && apt install -y metricbeat
```

Configure filebeat yaml file `/etc/filebeat/filebeat.yml`

```
tags: ["<hostname>"]
# Comment these
#output.elasticsearch:
  #hosts: ["localhost:9200"]
# Uncomment tests
output.logstash:
  hosts: ["localhost:5043"]
```

Start and check metricbeat

```
service metricbeat start
systemctl enable metricbeat
```

## Setting up firewall

```
ufw allow 22/tcp
ufw allow 9200/tcp // <- Maybe not??
ufw allow 9600/tcp 
ufw allow 5601/tcp
ufw enable
```

## Importing Dashboards

// TODO:  Add steps for importing dashboards.
