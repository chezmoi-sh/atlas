mod ansible 'src/infrastructure/ansible/.justfile'
mod crossplane 'src/infrastructure/crossplane/.justfile'

# -- Variables -----------------------------------------------------------------
kubernetes_host := "kubernetes.maison.chezmoi.sh"

[private]
@default:
  just --list --list-submodules


# -- Documentation related tasks -----------------------------------------------
[doc("Generates the architecture diagram for nex·rpi")]
[group("documentation")]
generate_diagram:
  d2 --layout elk --sketch architecture.d2 "assets/architecture.svg"
