Import-Module devtoolbox
Import-Module posh-git -DisableNameChecking
Import-Module oh-my-posh -DisableNameChecking
Set-Theme Powerlevel10k-Lean

# Load the BASH profile (enable socat for GPG socket forwarding)
sh ~/.bashrc
