--[[
    SPAWNPOINT ROBLOX - Script Fixado para Delta
    Versão: 2.0 - Sem erros de tipo de dados
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local mouse = player:GetMouse()

-- Variáveis principais
local spawnpoint_enabled = false
local spawnpos = nil
local spDelay = 0.1

-- Cores
local COLOR_PRIMARY = Color3.fromRGB(25, 25, 35)
local COLOR_SECONDARY = Color3.fromRGB(35, 35, 45)
local COLOR_SUCCESS = Color3.fromRGB(50, 200, 50)
local COLOR_DISABLED = Color3.fromRGB(100, 100, 100)
local COLOR_TEXT = Color3.fromRGB(255, 255, 255)

-- ═══════════════════════════════════════════════════════════════════
-- FUNÇÕES AUXILIARES
-- ═══════════════════════════════════════════════════════════════════

local function getHumanoidRootPart()
    local character = player.Character
    if not character then return nil end
    return character:FindFirstChild("HumanoidRootPart")
end

local function waitForHumanoidRootPart()
    local character = player.Character
    if not character then return false end
    
    local root = character:FindFirstChild("HumanoidRootPart")
    if root then return true end
    
    for i = 1, 50 do
        wait(0.1)
        root = character:FindFirstChild("HumanoidRootPart")
        if root then return true end
    end
    
    return false
end

local function saveSpawnPoint()
    local root = getHumanoidRootPart()
    if not root then return false end
    
    spawnpos = root.CFrame
    spawnpoint_enabled = true
    print("[Spawnpoint] Posição salva!")
    return true
end

local function removeSpawnPoint()
    spawnpoint_enabled = false
    print("[Spawnpoint] Ponto de spawn removido")
end

local function teleportToSpawnPoint()
    if not spawnpoint_enabled or not spawnpos then return end
    
    local root = getHumanoidRootPart()
    if not root then return end
    
    wait(spDelay)
    
    pcall(function()
        root.CFrame = spawnpos
        print("[Spawnpoint] Teleportado!")
    end)
end

-- ═══════════════════════════════════════════════════════════════════
-- CRIAR GUI SIMPLES E FUNCIONAL
-- ═══════════════════════════════════════════════════════════════════

local function createMainGUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "SpawnpointGUI"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndex = 999
    
    pcall(function()
        screenGui.Parent = player:WaitForChild("PlayerGui", 5)
    end)
    
    -- Frame Principal
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Parent = screenGui
    mainFrame.BackgroundColor3 = COLOR_PRIMARY
    mainFrame.BorderSizePixel = 0
    mainFrame.Position = UDim2.new(0, 20, 0, 100)
    mainFrame.Size = UDim2.new(0, 280, 0, 150)
    mainFrame.Draggable = true  -- USAR O DRAG NATIVO (SEM ERROS)
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = mainFrame
    
    -- BARRA DE TÍTULO
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Parent = mainFrame
    titleBar.BackgroundColor3 = COLOR_SECONDARY
    titleBar.BorderSizePixel = 0
    titleBar.Size = UDim2.new(1, 0, 0, 30)
    titleBar.ZIndex = 1000
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "TitleLabel"
    titleLabel.Parent = titleBar
    titleLabel.BackgroundTransparency = 1
    titleLabel.Position = UDim2.new(0, 10, 0, 0)
    titleLabel.Size = UDim2.new(1, -20, 1, 0)
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 14
    titleLabel.TextColor3 = COLOR_TEXT
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Text = "🎯 Spawnpoint"
    titleLabel.ZIndex = 1000
    
    -- ÁREA DE CONTEÚDO
    local contentArea = Instance.new("Frame")
    contentArea.Name = "ContentArea"
    contentArea.Parent = mainFrame
    contentArea.BackgroundColor3 = COLOR_PRIMARY
    contentArea.BorderSizePixel = 0
    contentArea.Position = UDim2.new(0, 0, 0, 30)
    contentArea.Size = UDim2.new(1, 0, 1, -30)
    contentArea.ZIndex = 999
    
    local contentLayout = Instance.new("UIGridLayout")
    contentLayout.Parent = contentArea
    contentLayout.CellPadding = UDim2.new(0, 5, 0, 5)
    contentLayout.CellSize = UDim2.new(1, -10, 0, 40)
    contentLayout.FillDirection = Enum.FillDirection.Vertical
    
    -- BOTÃO SPAWNPOINT
    local spawnpointButton = Instance.new("TextButton")
    spawnpointButton.Name = "SpawnpointButton"
    spawnpointButton.Parent = contentArea
    spawnpointButton.BackgroundColor3 = COLOR_DISABLED
    spawnpointButton.BorderSizePixel = 0
    spawnpointButton.Font = Enum.Font.GothamBold
    spawnpointButton.TextSize = 12
    spawnpointButton.TextColor3 = COLOR_TEXT
    spawnpointButton.Text = "Spawnpoint\n[OFF]"
    spawnpointButton.ZIndex = 1000
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 6)
    buttonCorner.Parent = spawnpointButton
    
    -- TEXTO DE STATUS
    local statusText = Instance.new("TextLabel")
    statusText.Name = "StatusText"
    statusText.Parent = contentArea
    statusText.BackgroundTransparency = 1
    statusText.Font = Enum.Font.Gotham
    statusText.TextSize = 10
    statusText.TextColor3 = COLOR_TEXT
    statusText.Text = "✕ Desativado"
    statusText.ZIndex = 1000
    
    -- FUNÇÃO PARA ATUALIZAR BOTÃO
    local function updateButtonVisuals()
        if spawnpoint_enabled then
            spawnpointButton.BackgroundColor3 = COLOR_SUCCESS
            spawnpointButton.Text = "Spawnpoint\n[ON]"
            statusText.Text = "✓ Ativo - Posição salva"
        else
            spawnpointButton.BackgroundColor3 = COLOR_DISABLED
            spawnpointButton.Text = "Spawnpoint\n[OFF]"
            statusText.Text = "✕ Desativado"
        end
    end
    
    -- CLIQUE DO BOTÃO
    spawnpointButton.MouseButton1Click:Connect(function()
        if spawnpoint_enabled then
            removeSpawnPoint()
        else
            saveSpawnPoint()
        end
        updateButtonVisuals()
    end)
    
    -- HOVER EFFECTS
    spawnpointButton.MouseEnter:Connect(function()
        if spawnpoint_enabled then
            spawnpointButton.BackgroundColor3 = Color3.fromRGB(40, 220, 40)
        else
            spawnpointButton.BackgroundColor3 = Color3.fromRGB(120, 120, 120)
        end
    end)
    
    spawnpointButton.MouseLeave:Connect(function()
        updateButtonVisuals()
    end)
    
    -- Inicializar visual
    updateButtonVisuals()
    
    return screenGui
end

-- ═══════════════════════════════════════════════════════════════════
-- SISTEMA DE RESPAWN AUTOMÁTICO
-- ═══════════════════════════════════════════════════════════════════

local function setupCharacterRespawn()
    player.CharacterAdded:Connect(function(character)
        if not waitForHumanoidRootPart() then
            return
        end
        
        pcall(function()
            if spawnpoint_enabled and spawnpos ~= nil then
                wait(spDelay)
                
                local root = getHumanoidRootPart()
                if root then
                    root.CFrame = spawnpos
                    print("[Spawnpoint] Você foi teleportado para o spawn point!")
                end
            end
        end)
    end)
end

-- ═══════════════════════════════════════════════════════════════════
-- INICIALIZAÇÃO
-- ═══════════════════════════════════════════════════════════════════

print("[Spawnpoint] Iniciando script...")

-- Aguardar o jogo carregar
if not game:IsLoaded() then
    game.Loaded:Wait()
end

-- Aguardar PlayerGui
if not player:FindFirstChild("PlayerGui") then
    player:WaitForChild("PlayerGui", 10)
end

-- Criar GUI
print("[Spawnpoint] Criando interface...")
pcall(function()
    createMainGUI()
end)

-- Configurar teleporte automático
print("[Spawnpoint] Ativando sistema de teleporte automático...")
setupCharacterRespawn()

print("[Spawnpoint] ✓ Script carregado com sucesso!")

--[[
    COMO USAR:
    1. Clique no botão "Spawnpoint [OFF]" para salvar sua posição
    2. Morra/respawne - você será teleportado automaticamente
    3. Clique novamente para desativar
]]
