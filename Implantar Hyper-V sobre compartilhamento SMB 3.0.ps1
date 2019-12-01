## Implantar Hyper-V sobre SMB 3.0 - Créditos Gabriel Luiz - www.gabrielluiz.com e www.cooperati.com.br ##


$Servers = 'FILE' # Hostname do servidor de arquivos.

$Servers | ForEach { Install-WindowsFeature -ComputerName $_ -Name File-Services -IncludeManagementTools }


# Observação: Este comando pode ser executado de qualquer servidor ingressado em seu domínio.


# Criação do compartilhamento SMB 3.0.

MD C:\VMS # Cria a pasta com nome VMs

New-SmbShare -Name VMS -Path C:\VMS -FullAccess "Contoso\NO3$", "Contoso\NO4$", "Contoso\Administrador" # Cria o comportilhamento SMB 3.0 com as permissões de acesso total para os hostnames NO3 e NO4 e usuário administrador do domínio contoso.local.

Set-SmbPathAcl -ShareName VMS # Define as mesmas permissões de compartilhamento de arquivos (SMB) nas permissões de segurança (NTFS).


# Observação: Este comando pode ser executado no servidor que será utilizado como File Service.


# Instalação da função de Hyper-V.

$Servers = 'NO3','NO4' # Hostsnames dos servidores.

$Servers | ForEach { Install-WindowsFeature -ComputerName $_ -Name Hyper-V, Hyper-V-PowerShell -IncludeManagementTools -restart } # Instalação da função de Hyper-V no servidores.


Restart-Computer -ComputerName NO3, NO4 -force # Força a renicialização dos servidores.

# Observação: Este comando pode ser executado de qualquer servidor ingressado em seu domínio.


# Criação da máquina virtual armazenada em compartilhamento SMB 3.0.

New-VHD -Path \\FILE\VMS\VM.VHDX -SizeBytes 127GB -Dynamic

New-VM -Name VM -Path \\FILE\VMS -Memory 1GB -VHDPath \\FILE\VMS\VM.VHDX

# Observação: Execute este comando em um dos servidores de host de Hyper-V.


# Habilita a migração ao vivo nos servidores hosts de Hyper-V.


$Servers = 'NO3','NO4' # Hostsnames dos servidores.

$Servers | ForEach {Enable-VMMigration -ComputerName $_} # Habilita a migração ao vivo.

$Servers | ForEach {Set-VMHost -MaximumStorageMigrations 2 -MaximumVirtualMachineMigrations 2 -UseAnyNetworkForMigration $true -VirtualMachineMigrationAuthenticationType Kerberos -VirtualMachineMigrationPerformanceOption Compression -ComputerName $_} # Habilita várias configurações da migração ao vivo.


# Explicação do comando Set-VMHost.

# -VirtualMachineMigrationAuthenticationType Kerberos - Habilita a migração ao vivo utilizando Kerberos.

# -VirtualMachineMigrationPerformanceOption Compression - Habilta a opção de desempenho a ser usada para migração ao vivo, neste caso será Compressão. Compactar dados para acelerar a migração ao vivo em redes restritas.

# -MaximumVirtualMachineMigrations 10 -MaximumStorageMigrations 10 - Habilta o número  máximo de migrações ao vivo simultâneas e migrações de armazenamento. Neste exemplo será apenas dois.

# -UseAnyNetworkForMigration $true - Habilita a migração ao vivo para qualquer rede.


# Habilta a migração ao vivo na rede especificar.r


$Servers = 'NO3','NO4' # Hostsnames dos servidores.

$Servers | ForEach {Add-VMMigrationNetwork 192.168.1.0/24 -Priority 1 -ComputerName $_} # Habilta a rede 192.168.1.0/24 com prioridade 1 para a migração ao vivo.

Get-VMMigrationNetwork # Verfica a rede habilta para a migração ao vivo.

# Observação: Configuração opcional.


# Habilitar a delegação.


# Toda parte da delegação será demostrada em vídeo.


# Migração ao vivo da máquina virtual.


Move-VM "VM" NO4 # Move a máquina virtual com o nome VM para um servidor remoto NO4 quando a máquina virtual é armazenada em um compartilhamento SMB 3.0.

# Observação: Este comando deve ser executada aonde a máquina virtual foi criada.


# Observações: Todos os servidores envolvidos neste laboratório estão ingressados em domínio. Utilizamos o Windows Server 2019 para fazer o nosso laboratório.


# Referências: 

# https://docs.microsoft.com/en-us/powershell/module/hyper-v/add-vmmigrationnetwork?view=win10-ps

# https://docs.microsoft.com/en-us/powershell/module/hyper-v/get-vmmigrationnetwork?view=win10-ps

# https://docs.microsoft.com/en-us/powershell/module/hyper-v/set-vmhost?view=win10-ps

# https://docs.microsoft.com/en-us/powershell/module/hyper-v/move-vm?view=win10-ps

# https://docs.microsoft.com/en-us/powershell/module/servermanager/install-windowsfeature?view=winserver2012r2-ps

# https://docs.microsoft.com/en-us/previous-versions/windows/it-pro/windows-server-2012-r2-and-2012/jj134187(v%3Dws.11)

# https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/foreach-object?view=powershell-6

# https://docs.microsoft.com/en-us/powershell/module/hyper-v/new-vhd?view=win10-ps

# https://docs.microsoft.com/en-us/powershell/module/hyper-v/new-vm?view=win10-ps

# https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.management/restart-computer?view=powershell-6

# https://docs.microsoft.com/en-us/powershell/module/smbshare/new-smbshare?view=win10-ps

# https://docs.microsoft.com/en-us/powershell/module/smbshare/set-smbpathacl?view=win10-ps

# https://docs.microsoft.com/pt-br/windows-server/virtualization/hyper-v/deploy/set-up-hosts-for-live-migration-without-failover-clustering


# Para maior entendimento deste script acesse o link do artigo abaixo: http://cooperati.com.br/2019/11/migracao-ao-vivo-live-migration-hyper-v
