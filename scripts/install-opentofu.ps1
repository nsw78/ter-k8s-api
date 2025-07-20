# install-opentofu.ps1
#
# Este script instala o OpenTofu usando o gerenciador de pacotes winget.
# Ele deve ser executado em um terminal PowerShell com privilégios de Administrador.

# Define cores para as mensagens de status para melhor visualização
$InfoColor = "Cyan"
$SuccessColor = "Green"
$WarningColor = "Yellow"
$ErrorColor = "Red"

# 0. Verifica se o script está sendo executado como Administrador
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "❌ ERRO: Este script precisa ser executado com privilégios de Administrador." -ForegroundColor $ErrorColor
    Write-Host "Por favor, abra um novo PowerShell como Administrador e execute o script novamente." -ForegroundColor $WarningColor
    # Pausa para o usuário ler a mensagem antes de fechar, se executado com um clique duplo.
    if ($Host.Name -eq "ConsoleHost") {
        Read-Host "Pressione Enter para sair"
    }
    exit 1
}

# 1. Verifica se o OpenTofu já está instalado
Write-Host "Verificando a instalação do OpenTofu..." -ForegroundColor $InfoColor
$tofuCommand = Get-Command tofu -ErrorAction SilentlyContinue

if ($tofuCommand) {
    Write-Host "✅ OpenTofu já está instalado no sistema." -ForegroundColor $SuccessColor
    tofu --version
} else {
    Write-Host "OpenTofu não encontrado. Iniciando processo de instalação..." -ForegroundColor $InfoColor
    $installSuccess = $false

    # --- Tentativa 1: Instalação via winget (Método Preferencial) ---
    Write-Host "[1/2] Tentando instalar via winget..." -ForegroundColor $InfoColor
    # Oculta a saída detalhada do 'source update' para um log mais limpo
    winget source update | Out-Null
    winget install --id OpenTofu.OpenTofu --source winget --accept-package-agreements --accept-source-agreements
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Instalação via winget concluída com sucesso." -ForegroundColor $SuccessColor
        $installSuccess = $true
    } else {
        Write-Host "⚠️ A instalação via winget falhou (Código de saída: $LASTEXITCODE)." -ForegroundColor $WarningColor
    }

    # --- Tentativa 2: Instalação Manual (Fallback) ---
    if (-not $installSuccess) {
        Write-Host "[2/2] Tentando instalação manual como alternativa..." -ForegroundColor $InfoColor
        try {
            $tofuVersion = "1.6.2" # Pode ser atualizado para versões futuras
            $downloadUrl = "https://github.com/opentofu/opentofu/releases/download/v$tofuVersion/tofu_${tofuVersion}_windows_amd64.zip"
            # Instala em um local central e padrão para ferramentas
            $installDir = "C:\ProgramData\OpenTofu"
            $zipPath = Join-Path $env:TEMP "tofu.zip"

            Write-Host "Baixando OpenTofu v$tofuVersion..." -ForegroundColor $InfoColor
            Invoke-WebRequest -Uri $downloadUrl -OutFile $zipPath -UseBasicParsing

            # Cria o diretório de destino se ele não existir
            if (-not (Test-Path $installDir)) {
                New-Item -Path $installDir -ItemType Directory -Force | Out-Null
            }

            Write-Host "Extraindo arquivos para '$installDir'..." -ForegroundColor $InfoColor
            Expand-Archive -Path $zipPath -DestinationPath $installDir -Force

            Write-Host "Adicionando '$installDir' ao PATH do sistema..." -ForegroundColor $InfoColor
            $currentMachinePath = [System.Environment]::GetEnvironmentVariable("Path", "Machine")
            if ($currentMachinePath -notlike "*$installDir*") {
                $newMachinePath = $currentMachinePath + ";" + $installDir
                [System.Environment]::SetEnvironmentVariable("Path", $newMachinePath, "Machine")
            }

            Remove-Item $zipPath -ErrorAction SilentlyContinue
            $installSuccess = $true
        } catch {
            Write-Host "❌ ERRO: A instalação manual também falhou." -ForegroundColor $ErrorColor
            Write-Host "Detalhes do erro: $($_.Exception.Message)" -ForegroundColor $ErrorColor
            exit 1
        }
    }

    # --- Verificação Final e Atualização do PATH da Sessão ---
    Write-Host "Atualizando o PATH da sessão atual e verificando a instalação..." -ForegroundColor $InfoColor
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")

    $tofuCommand = Get-Command tofu -ErrorAction SilentlyContinue
    if ($tofuCommand) {
        Write-Host "✅ Sucesso! O comando 'tofu' agora está disponível nesta sessão." -ForegroundColor $SuccessColor
        tofu --version
    } else {
        Write-Host "❌ ERRO: A instalação parece ter sido concluída, mas o comando 'tofu' não foi encontrado." -ForegroundColor $ErrorColor
        Write-Host "Por favor, feche e reabra seu terminal PowerShell (como Administrador) para que a alteração no PATH seja aplicada." -ForegroundColor $WarningColor
    }
}