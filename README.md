# Elastic Stack

## Logstash 

### Directory Layout of Docker Images

The Docker images are created from the .tar.gz packages, and follow a similar directory layout.

Type|Description|Default Location|Setting
---|---|---|---
home|Home directory of the Logstash installation.|/usr/share/logstash
bin|Binary scripts, including logstash to start Logstash and logstash-plugin to install plugins|/usr/share/logstash/bin
settings|Configuration files, including logstash.yml and jvm.options|/usr/share/logstash/config|path.settings
conf|Logstash pipeline configuration files|/usr/share/logstash/pipeline|path.config
plugins|Local, non Ruby-Gem plugin files. Each plugin is contained in a subdirectory. Recommended for development only.|/usr/share/logstash/plugins|path.plugins
data|Data files used by logstash and its plugins for any persistence needs.|/usr/share/logstash/data|path.data

Logstash Docker containers do not create log files by default. They log to standard output.
