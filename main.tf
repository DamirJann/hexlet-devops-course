// main.tf - имя файла выбрано произвольно, важно только расширение
terraform {
  required_providers {
    // Здесь указываются все провайдеры, которые будут использоваться
    digitalocean = {
      source  = "digitalocean/digitalocean"
      // Версия может обновиться
      version = "~> 2.0"
    }
    datadog = {
      source = "DataDog/datadog"
    }
  }
}

// Terraform должен знать ключ, для выполнения команд по API

// Определение переменной, которую нужно будет задать
variable "do_token" {}

// Установка значения переменной
provider "digitalocean" {
  token = var.do_token
}

// Пример взят из документации
// web - произвольное имя ресурса
resource "digitalocean_droplet" "web1" {
  image  = "ubuntu-22-04-x64"
  // Имя внутри Digital Ocean
  // Задается для удобства просмотра в веб-интерфейсе
  name   = "web-1"
  // Регион, в котором располагается датацентр
  // Выбирается по принципу близости к клиентам
  region = "ams3"
  // Тип сервера, от этого зависит его мощность и стоимость
  size   = "s-1vcpu-1gb"
}

#resource "digitalocean_droplet" "web2" {
#  image  = "ubuntu-22-04-x64"
#  name   = "web-2"
#  region = "ams3"
#  size   = "s-1vcpu-1gb"
#}


variable "datadog_api_key" {
  type      = string
  sensitive = true
}

variable "datadog_app_key" {
  type      = string
  sensitive = true
}

variable "datadog_api_url" {
  type      = string
#  default = "https://api.datadoghq.com/"
}

# Configure the Datadog provider
provider "datadog" {
  api_key = var.datadog_api_key
  app_key = var.datadog_app_key
  api_url = var.datadog_api_url
}

resource "datadog_monitor" "process_alert_example" {
  name    = "Process Alert Monitor"
  type    = "process alert"
  message = "Multiple Java processes running on example-tag"
  query   = "processes('java').over('example-tag').rollup('count').last('10m') > 1"
  monitor_thresholds {
    critical          = 1.0
    critical_recovery = 0.0
  }

  notify_no_data    = false
  renotify_interval = 60
}