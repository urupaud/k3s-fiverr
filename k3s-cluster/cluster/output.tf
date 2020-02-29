output "eks_kubeconfig" {
  value = aws_lb.k3s-server-lb.dns_name
}