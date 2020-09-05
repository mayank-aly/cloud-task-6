provider "kubernetes" {
  config_context_cluster = "minikube"
}
resource "null_resource" "minikube" {

 provisioner "local-exec" {
        command = "minikube start"

   }

}
resource "kubernetes_deployment" "mywp" {
 metadata {
   name = "wordpress"
 }
 spec {
   replicas = 2
   selector {
     match_labels = {
       env = "production"
       dc = "In"
       App = "wordpress"
     }
     match_expressions {
       key = "env"
       operator = "In"
       values = ["production","Dev"]
     }
   }
 template{
   metadata {
     labels = {
       env = "production"
       dc = "In"
       App = "wordpress" 
     }
   }
   spec {
     container {
       image = "wordpress:4.8-apache"
       name = "mywordpress"
               }
       }
 }
}
}
output "mywpout" {
  value = "${kubernetes_deployment.mywp.spec[0].template[0].metadata[0].labels.App}"
} 
resource "kubernetes_service" "myservice" {
  metadata {
    name = "mywpservice"
  }
  spec {
    selector = {
      App =  "${kubernetes_deployment.mywp.spec[0].template[0].metadata[0].labels.App}"
    }
    port {
      node_port = 32514
      target_port = "80"
      port = 80
    }
    type = "NodePort"
  }
}

provider "aws" {
  region = "ap-south-1"
  profile = "mayank"

}
resource "aws_db_instance" "mydb" {
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t2.micro"
  name                 = "mayankdatabase"
  username             = "mayank"
  password             = "redhatmayank"
  publicly_accessible = true
  port = 3306
  parameter_group_name = "default.mysql5.7"
  skip_final_snapshot = true
  tags = {
    Name = "mywpdatabase"
  }
}
output "mydnsdb" {
  value = "${aws_db_instance.mydb.address}"
}