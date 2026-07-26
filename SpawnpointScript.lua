--[[
    ═════════════════════════════════════════════════════════════════
    SPAWNPOINT ROBLOX - Script LocalScript Completo
    ═════════════════════════════════════════════════════════════════
    
    Autor: Sistema de Teleporte Automático
    Descrição: Reimplementação do comando Spawnpoint do Infinite Yield
    
    Features:
    ✓ GUI moderna e responsiva
    ✓ Drag and drop em mobile e PC
    ✓ Botão minimizável
    ✓ Toggle ON/OFF visual
    ✓ Teleporte automático ao respawnar
    ✓ Sem dependências externas
    ✓ Funciona em mobile e desktop
    
    ═════════════════════════════════════════════════════════════════
]]

-- ═══════════════════════════════════════════════════════════════════
-- CONFIGURAÇÕES E VARIÁVEIS GLOBAIS
-- ═══════════════════════════════════════════════════════════════════

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local mouse = player:GetMouse()

-- Variáveis do Spawnpoint (mesma lógica do Infinite Yield)
local spawnpoint_enabled = false  -- Flag de ativação
local spawnpos = nil              -- Posição salva (CFrame)
local spDelay = 0.1               -- Delay antes de teleportar (em segundos)

-- Variáveis da GUI
local gui_parent = nil
local main_gui = nil
local is_dragging = false
local drag_offset = Vector2.new(0, 0)
local is_minimized = false

-- Cores da interface
local COLOR_PRIMARY = Color3.fromRGB(25, 25, 35)      -- Fundo principal (escuro)
local COLOR_SECONDARY = Color3.fromRGB(35, 35, 45)   -- Fundo secundário (mais claro)
local COLOR_ACCENT = Color3.fromRGB(0, 150, 255)     -- Azul (ativo/destaque)
local COLOR_ACCENT_HOVER = Color3.fromRGB(0, 180, 255) -- Azul mais claro
local COLOR_SUCCESS = Color3.fromRGB(50, 200, 50)    -- Verde (quando ativado)
local COLOR_DISABLED = Color3.fromRGB(100, 100, 100) -- Cinza (desativado)
local COLOR_TEXT = Color3.fromRGB(255, 255, 255)     -- Texto branco

-- ═══════════════════════════════════════════════════════════════════
-- FUNÇÕES AUXILIARES
-- ═══════════════════════════════════════════════════════════════════

-- Obter HumanoidRootPart de forma segura
local function getHumanoidRootPart()
    local character = player.Character
    if not character then return nil end
    return character:FindFirstChild("HumanoidRootPart")
end

-- Esperar o HumanoidRootPart estar pronto
local function waitForHumanoidRootPart()
    local character = player.Character
    if not character then return false end
    
    local root = character:FindFirstChild("HumanoidRootPart")
    if root then return true end
    
    -- Aguarda até 5 segundos
    for i = 1, 50 do
        wait(0.1)
        root = character:FindFirstChild("HumanoidRootPart")
        if root then return true end
    end
    
    return false
end

-- Notificação na tela
local function showNotification(title, message)
    print("[Spawnpoint] " .. title .. ": " .. message)
    -- Aqui você pode expandir para uma notificação visual melhorada se desejar
end

-- ═══════════════════════════════════════════════════════════════════
-- FUNÇÕES DO SPAWNPOINT
-- ═══════════════════════════════════════════════════════════════════

-- Salvar a posição atual como spawn point
local function saveSpawnPoint()
    local root = getHumanoidRootPart()
    if not root then
        showNotification("Erro", "Personagem não encontrado")
        return false
    end
    
    spawnpos = root.CFrame
    spawnpoint_enabled = true
    showNotification("Spawn Point", "Posição salva em: " .. tostring(math.floor(spawnpos.X)) .. ", " .. 
                     tostring(math.floor(spawnpos.Y)) .. ", " .. tostring(math.floor(spawnpos.Z)))
    
    return true
end

-- Remover spawn point (desativar)
local function removeSpawnPoint()
    spawnpoint_enabled = false
    showNotification("Spawn Point", "Ponto de spawn removido")
end

-- Teleportar para spawn point (com proteção)
local function teleportToSpawnPoint()
    if not spawnpoint_enabled or not spawnpos then return end
    
    local root = getHumanoidRootPart()
    if not root then return end
    
    -- Aguarda o delay configurado (padrão 0.1 segundos)
    -- Isso garante que o personagem foi completamente carregado
    wait(spDelay)
    
    -- Usar pcall (Protected Call) para evitar erros
    local success = pcall(function()
        root.CFrame = spawnpos
    end)
    
    if success then
        showNotification("Teleporte", "Teleportado para spawn point")
    end
end

-- ═══════════════════════════════════════════════════════════════════
-- FUNÇÕES DA GUI
-- ═══════════════════════════════════════════════════════════════════

-- Criar a interface principal
local function createMainGUI()
    -- Screen GUI (container principal)
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "SpawnpointGUI"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndex = 999
    
    -- Detectar se é mobile
    local isMobile = UserInputService:GetPlatform() == Enum.Platform.IOS or 
                     UserInputService:GetPlatform() == Enum.Platform.Android
    
    if isMobile then
        screenGui.Parent = player:WaitForChild("PlayerGui")
    else
        screenGui.Parent = player:WaitForChild("PlayerGui")
    end
    
    -- ───────────────────────────────────────────────────────────────
    -- FRAME PRINCIPAL (Holder/Janela)
    -- ───────────────────────────────────────────────────────────────
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Parent = screenGui
    mainFrame.BackgroundColor3 = COLOR_PRIMARY
    mainFrame.BorderSizePixel = 0
    mainFrame.Position = UDim2.new(0, 20, 0, 100)  -- Posição inicial (canto superior esquerdo)
    mainFrame.Size = UDim2.new(0, 280, 0, 150)
    mainFrame.ZIndex = 999
    mainFrame.Active = true
    mainFrame.Draggable = false  -- Desabilitar drag padrão para implementar custom
    
    -- Adicionar sombra/borda
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = mainFrame
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = COLOR_SECONDARY
    stroke.Thickness = 1
    stroke.Parent = mainFrame
    
    -- ───────────────────────────────────────────────────────────────
    -- BARRA DE TÍTULO (Title Bar)
    -- ───────────────────────────────────────────────────────────────
    
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Parent = mainFrame
    titleBar.BackgroundColor3 = COLOR_SECONDARY
    titleBar.BorderSizePixel = 0
    titleBar.Size = UDim2.new(1, 0, 0, 30)
    titleBar.ZIndex = 1000
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 8)
    titleCorner.Parent = titleBar
    
    -- Texto da barra de título
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "TitleLabel"
    titleLabel.Parent = titleBar
    titleLabel.BackgroundTransparency = 1
    titleLabel.Position = UDim2.new(0, 10, 0, 0)
    titleLabel.Size = UDim2.new(1, -60, 1, 0)
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 14
    titleLabel.TextColor3 = COLOR_TEXT
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Text = "🎯 Spawnpoint"
    titleLabel.ZIndex = 1000
    
    -- Botão Minimizar
    local minimizeButton = Instance.new("TextButton")
    minimizeButton.Name = "MinimizeButton"
    minimizeButton.Parent = titleBar
    minimizeButton.BackgroundColor3 = COLOR_SECONDARY
    minimizeButton.BorderSizePixel = 0
    minimizeButton.Position = UDim2.new(1, -50, 0, 0)
    minimizeButton.Size = UDim2.new(0, 25, 1, 0)
    minimizeButton.Font = Enum.Font.GothamBold
    minimizeButton.TextSize = 16
    minimizeButton.TextColor3 = COLOR_TEXT
    minimizeButton.Text = "−"
    minimizeButton.ZIndex = 1001
    minimizeButton.MouseEnter:Connect(function()
        minimizeButton.BackgroundColor3 = COLOR_ACCENT
    end)
    minimizeButton.MouseLeave:Connect(function()
        minimizeButton.BackgroundColor3 = COLOR_SECONDARY
    end)
    
    -- Botão Fechar
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Parent = titleBar
    closeButton.BackgroundColor3 = COLOR_SECONDARY
    closeButton.BorderSizePixel = 0
    closeButton.Position = UDim2.new(1, -25, 0, 0)
    closeButton.Size = UDim2.new(0, 25, 1, 0)
    closeButton.Font = Enum.Font.GothamBold
    closeButton.TextSize = 16
    closeButton.TextColor3 = COLOR_TEXT
    closeButton.Text = "✕"
    closeButton.ZIndex = 1001
    closeButton.MouseEnter:Connect(function()
        closeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    end)
    closeButton.MouseLeave:Connect(function()
        closeButton.BackgroundColor3 = COLOR_SECONDARY
    end)
    
    -- ───────────────────────────────────────────────────────────────
    -- ÁREA DE CONTEÚDO
    -- ───────────────────────────────────────────────────────────────
    
    local contentArea = Instance.new("Frame")
    contentArea.Name = "ContentArea"
    contentArea.Parent = mainFrame
    contentArea.BackgroundColor3 = COLOR_PRIMARY
    contentArea.BorderSizePixel = 0
    contentArea.Position = UDim2.new(0, 0, 0, 30)
    contentArea.Size = UDim2.new(1, 0, 1, -30)
    contentArea.ZIndex = 999
    
    -- ───────────────────────────────────────────────────────────────
    -- BOTÃO SPAWNPOINT (Toggle Button)
    -- ───────────────────────────────────────────────────────────────
    
    local spawnpointButton = Instance.new("TextButton")
    spawnpointButton.Name = "SpawnpointButton"
    spawnpointButton.Parent = contentArea
    spawnpointButton.BackgroundColor3 = COLOR_DISABLED
    spawnpointButton.BorderSizePixel = 0
    spawnpointButton.Position = UDim2.new(0, 10, 0, 10)
    spawnpointButton.Size = UDim2.new(1, -20, 0, 50)
    spawnpointButton.Font = Enum.Font.GothamBold
    spawnpointButton.TextSize = 14
    spawnpointButton.TextColor3 = COLOR_TEXT
    spawnpointButton.Text = "Spawnpoint\n[OFF]"
    spawnpointButton.ZIndex = 1000
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 6)
    buttonCorner.Parent = spawnpointButton
    
    local buttonStroke = Instance.new("UIStroke")
    buttonStroke.Color = COLOR_SECONDARY
    buttonStroke.Thickness = 1
    buttonStroke.Parent = spawnpointButton
    
    -- ───────────────────────────────────────────────────────────────
    -- STATUS TEXT (para feedback)
    -- ───────────────────────────────────────────────────────────────
    
    local statusText = Instance.new("TextLabel")
    statusText.Name = "StatusText"
    statusText.Parent = contentArea
    statusText.BackgroundTransparency = 1
    statusText.Position = UDim2.new(0, 10, 0, 65)
    statusText.Size = UDim2.new(1, -20, 0, 40)
    statusText.Font = Enum.Font.Gotham
    statusText.TextSize = 11
    statusText.TextColor3 = Color3.fromRGB(200, 200, 200)
    statusText.TextWrapped = true
    statusText.TextXAlignment = Enum.TextXAlignment.Left
    statusText.Text = "Clique para ativar o spawn point"
    statusText.ZIndex = 999
    
    -- ═══════════════════════════════════════════════════════════════════
    -- EVENTOS E LÓGICA DA GUI
    -- ═══════════════════════════════════════════════════════════════════
    
    -- Atualizar visual do botão baseado no estado
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
    
    -- Lógica do botão Spawnpoint (Toggle)
    spawnpointButton.MouseButton1Click:Connect(function()
        if spawnpoint_enabled then
            removeSpawnPoint()
        else
            saveSpawnPoint()
        end
        updateButtonVisuals()
    end)
    
    -- Hover effects no botão
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
    
    -- ───────────────────────────────────────────────────────────────
    -- DRAG AND DROP (Mobile e Desktop)
    -- ───────────────────────────────────────────────────────────────
    
    -- Drag para PC (Mouse)
    titleBar.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            is_dragging = true
            drag_offset = mouse.Position - mainFrame.AbsolutePosition
        end
    end)
    
    titleBar.InputEnded:Connect(function(input, gameProcessed)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            is_dragging = false
        end
    end)
    
    -- Drag para Mobile (Touch)
    local touchConnection = nil
    titleBar.TouchBegan:Connect(function(touch, gameProcessed)
        if gameProcessed then return end
        is_dragging = true
        drag_offset = Vector2.new(touch.Position.X, touch.Position.Y) - mainFrame.AbsolutePosition
        
        -- Desconectar conexão anterior se existir
        if touchConnection then
            touchConnection:Disconnect()
        end
        
        -- Atualizar posição enquanto toca
        touchConnection = RunService.InputChanged:Connect(function(input, gameProcessed)
            if is_dragging and input.UserInputType == Enum.UserInputType.Touch then
                local newPos = Vector2.new(input.Position.X, input.Position.Y) - drag_offset
                mainFrame.Position = UDim2.new(0, newPos.X, 0, newPos.Y)
            end
        end)
    end)
    
    titleBar.TouchEnded:Connect(function(touch, gameProcessed)
        is_dragging = false
        if touchConnection then
            touchConnection:Disconnect()
        end
    end)
    
    -- Atualizar posição ao arrastar com mouse
    RunService.InputChanged:Connect(function(input, gameProcessed)
        if not is_dragging then return end
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            local newPos = mouse.Position - drag_offset
            mainFrame.Position = UDim2.new(0, newPos.X, 0, newPos.Y)
        end
    end)
    
    -- ───────────────────────────────────────────────────────────────
    -- MINIMIZAR/RESTAURAR
    -- ───────────────────────────────────────────────────────────────
    
    minimizeButton.MouseButton1Click:Connect(function()
        if is_minimized then
            -- Restaurar
            contentArea:TweenSize(
                UDim2.new(1, 0, 1, -30),
                Enum.EasingDirection.Out,
                Enum.EasingStyle.Quad,
                0.2,
                true
            )
            mainFrame:TweenSize(
                UDim2.new(0, 280, 0, 150),
                Enum.EasingDirection.Out,
                Enum.EasingStyle.Quad,
                0.2,
                true
            )
            minimizeButton.Text = "−"
            is_minimized = false
        else
            -- Minimizar
            contentArea:TweenSize(
                UDim2.new(1, 0, 0, 0),
                Enum.EasingDirection.Out,
                Enum.EasingStyle.Quad,
                0.2,
                true
            )
            mainFrame:TweenSize(
                UDim2.new(0, 280, 0, 30),
                Enum.EasingDirection.Out,
                Enum.EasingStyle.Quad,
                0.2,
                true
            )
            minimizeButton.Text = "+"
            is_minimized = true
        end
    end)
    
    -- ───────────────────────────────────────────────────────────────
    -- FECHAR GUI
    -- ───────────────────────────────────────────────────────────────
    
    closeButton.MouseButton1Click:Connect(function()
        screenGui:Destroy()
        removeSpawnPoint()
    end)
    
    -- Inicializar visual
    updateButtonVisuals()
    
    return screenGui, mainFrame
end

-- ═══════════════════════════════════════════════════════════════════
-- SISTEMA DE TELEPORTE AUTOMÁTICO
-- ═══════════════════════════════════════════════════════════════════

-- Conectar ao evento CharacterAdded (quando o personagem respawna)
-- ESTE É O CORAÇÃO DO SISTEMA: Teleporta automaticamente ao respawnar
local function setupCharacterRespawn()
    player.CharacterAdded:Connect(function(character)
        -- Aguardar o HumanoidRootPart ser criado
        if not waitForHumanoidRootPart() then
            return  -- Falha ao carregar
        end
        
        -- Proteger com pcall para evitar erros
        local success = pcall(function()
            -- Verificar todas as condições
            if spawnpoint_enabled and spawnpos ~= nil then
                -- Aguardar o delay configurado (padrão 0.1 segundos)
                wait(spDelay)
                
                -- TELEPORTE REAL ACONTECE AQUI
                local root = getHumanoidRootPart()
                if root then
                    root.CFrame = spawnpos
                    showNotification("Teleporte", "Você foi teleportado para o spawn point!")
                end
            end
        end)
    end)
end

-- ═══════════════════════════════════════════════════════════════════
-- INICIALIZAÇÃO
-- ═══════════════════════════════════════════════════════════════════

-- Aguardar o jogo carregar completamente
if not game:IsLoaded() then
    game.Loaded:Wait()
end

-- Aguardar o player estar pronto
if not player:FindFirstChild("PlayerGui") then
    player:WaitForChild("PlayerGui")
end

-- Criar a GUI
print("[Spawnpoint] Criando interface...")
main_gui, _ = createMainGUI()

-- Configurar o sistema de teleporte automático
print("[Spawnpoint] Ativando sistema de teleporte automático...")
setupCharacterRespawn()

-- Mensagem de inicialização
showNotification("Spawnpoint", "Sistema iniciado com sucesso! v1.0")
print("[Spawnpoint] ✓ Script carregado e pronto para usar!")

-- ═══════════════════════════════════════════════════════════════════
-- FIM DO SCRIPT
-- ═══════════════════════════════════════════════════════════════════

--[[
    COMO USAR:
    
    1. Clique no botão "Spawnpoint [OFF]" para salvar sua posição atual
       └─ O botão ficará verde e mostrará "[ON]"
    
    2. Morra ou respawne (o que acontecer primeiro)
       └─ Você será automaticamente teleportado para o ponto salvo
    
    3. Clique novamente para desativar
       └─ O botão voltará para cinza e mostrará "[OFF]"
    
    DICA: Você pode arrastar a janela pela barra de título em qualquer dispositivo
          e usar o botão "−" para minimizar a GUI
    
    LIMITAÇÕES:
    - Este é um LocalScript, portanto funciona apenas para você (não é explorador)
    - O teleporte acontece automaticamente ao respawnar, não será "invisível"
    - Alguns jogos podem detectar teleportes frequentes como suspeito
]]

