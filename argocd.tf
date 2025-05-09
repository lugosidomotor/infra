resource "helm_release" "argocd" {
  name       = "argocd"
  namespace  = "argocd"
  chart      = "argo-cd"
  repository = "https://argoproj.github.io/argo-helm"
  version    = "5.3.4"

  create_namespace = true

  values = [
    <<EOF
server:
  service:
    type: LoadBalancer
EOF
  ]
}

# NOTE: I’m fully aware that this `null_resource` + `local-exec` block is a quick‑and‑dirty
# “redneck” workaround. In a cleaner, fully declarative Terraform setup we would:
#   • use `kubernetes_manifest` resources, or
#   • define the apps via the `argocd_application` resource from the Argo CD provider, or
#   • bootstrap them through Helm values in an “app‑of‑apps” pattern.

resource "local_file" "kubeconfig" {
  content  = azurerm_kubernetes_cluster.aks.kube_config_raw
  filename = "${path.module}/kubeconfig"
}

resource "null_resource" "argocd_applications" {
  triggers = {
    always_run = "${timestamp()}"
  }

  provisioner "local-exec" {
    command = <<EOT
      kubectl apply -f ./argo/${var.environment}/argocd-app-1.yml --kubeconfig=${local_file.kubeconfig.filename} --validate=false --namespace=argocd
      kubectl apply -f ./argo/${var.environment}/argocd-app-2.yml --kubeconfig=${local_file.kubeconfig.filename} --validate=false --namespace=argocd
    EOT
  }

  depends_on = [
    helm_release.argocd
  ]
}
