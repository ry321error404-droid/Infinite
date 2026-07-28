--[[
    ═════════════════════════════════════════════════════════════════
    SPAWNPOINT + INVISIBLE/VISIBLE - VERSÃO PARA EXECUTORES
    ═════════════════════════════════════════════════════════════════
    
    Compatível com: Delta, Synapse, Solara, e outros executores
    Funciona: Direto no executor (não precisa de LocalScript)
    
    ═════════════════════════════════════════════════════════════════
]]

-- ═══════════════════════════════════════════════════════════════════
-- IMPORTAÇÕES E SETUP INICIAL
-- ═══════════════════════════════════════════════════════════════════

print("[Spawnpoint] Iniciando script...")

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
if not player then
    print("[Erro] Player não encontrado!")
    return
end

print("[Spawnpoint] Player encontrado: " .. player.Name)

-- Aguardar game estar carregado
if not game:IsLoaded() then
    print("[Spawnpoint] Aguardando game carregar...")
    game.Loaded:Wait()
    print("[Spawnpoint] Game carregado!")
end

-- Aguardar PlayerGui
local PlayerGui = player:WaitForChild("PlayerGui", 10)
if not PlayerGui then
    print("[Erro] PlayerGui não encontrado!")
    return
end

print("[Spawnpoint] PlayerGui encontrado!")

local mouse = player:GetMouse()

-- ═══════════════════════════════════════════════════════════════════
-- VARIÁVEIS GLOBAIS
-- ═══════════════════════════════════════════════════════════════════

local spawnpoint_enabled = false
local spawnpos = nil
local spDelay = 0.1

local invisible_enabled = false
local visible_enabled = false

local is_dragging = false
local drag_offset = Vector2.new(0, 0)
local is_minimized = false

-- Cores
local COLOR_PRIMARY = Color3.fromRGB(25, 25, 35)
local COLOR_SECONDARY = Color3.fromRGB(35, 35, 45)
local COLOR_ACCENT = Color3.fromRGB(0, 150, 255)
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

local function getCharacter()
    return player.Character
end

local function showNotification(title, message)
    print("[Spawnpoint] " .. title .. ": " .. message)
end

-- ═══════════════════════════════════════════════════════════════════
-- FUNÇÕES DO SPAWNPOINT
-- ═══════════════════════════════════════════════════════════════════

local function saveSpawnPoint()
    local root = getHumanoidRootPart()
    if not root then
        showNotification("Erro", "Personagem não encontrado")
        return false
    end
    
    spawnpos = root.CFrame
    spawnpoint_enabled = true
    showNotification("Spawn Point", "Posição salva!")
    return true
end

local function removeSpawnPoint()
    spawnpoint_enabled = false
    showNotification("Spawn Point", "Ponto de spawn removido")
end

local function teleportToSpawnPoint()
    if not spawnpoint_enabled or not spawnpos then return end
    
    local root = getHumanoidRootPart()
    if not root then return end
    
    wait(spDelay)
    
    local success = pcall(function()
        root.CFrame = spawnpos
    end)
    
    if success then
        showNotification("Teleporte", "Teleportado para spawn point")
    end
end

-- ═══════════════════════════════════════════════════════════════════
-- FUNÇÕES DE INVISIBILIDADE
-- ═══════════════════════════════════════════════════════════════════

local function makeCharacterInvisible()
    local character = getCharacter()
    if not character then return false end
    
    local success = pcall(function()
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Transparency = 1
            end
            
            if part:IsA("Decal") then
                part.Transparency = 1
            end
        end
    end)
    
    if success then
        invisible_enabled = true
        visible_enabled = false
        showNotification("Invisibilidade", "Você ficou invisível!")
        return true
    end
    
    return false
end

local function makeCharacterVisible()
    local character = getCharacter()
    if not character then return false end
    
    local success = pcall(function()
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Transparency = 0
            end
            
            if part:IsA("Decal") then
                part.Transparency = 0
            end
        end
    end)
    
    if success then
        invisible_enabled = false
        visible_enabled = true
        showNotification("Visibilidade", "Você ficou visível novamente!")
        return true
    end
    
    return false
end

-- ═══════════════════════════════════════════════════════════════════
-- CRIAÇÃO DA GUI
-- ═══════════════════════════════════════════════════════════════════

print("[Spawnpoint] Criando GUI...")

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SpawnpointGUI_" .. math.random(1, 9999)
screenGui.ResetOnSpawn = false
screenGui.ZIndex = 999
screenGui.Parent = PlayerGui

print("[Spawnpoint] ScreenGui criada!")

-- Frame principal
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Parent = screenGui
mainFrame.BackgroundColor3 = COLOR_PRIMARY
mainFrame.BorderSizePixel = 0
mainFrame.Position = UDim2.new(0, 20, 0, 100)
mainFrame.Size = UDim2.new(0, 280, 0, 280)
mainFrame.ZIndex = 999
mainFrame.Active = true
mainFrame.Draggable = false

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = mainFrame

local stroke = Instance.new("UIStroke")
stroke.Color = COLOR_SECONDARY
stroke.Thickness = 1
stroke.Parent = mainFrame

-- Barra de título
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
titleLabel.Text = "🎯 Controles"
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

-- Área de conteúdo
local contentArea = Instance.new("Frame")
contentArea.Name = "ContentArea"
contentArea.Parent = mainFrame
contentArea.BackgroundColor3 = COLOR_PRIMARY
contentArea.BorderSizePixel = 0
contentArea.Position = UDim2.new(0, 0, 0, 30)
contentArea.Size = UDim2.new(1, 0, 1, -30)
contentArea.ZIndex = 999

-- ═══════════════════════════════════════════════════════════════════
-- CRIAR BOTÕES
-- ═══════════════════════════════════════════════════════════════════

local function criarBotao(parent, nome, posicao, texto)
    local botao = Instance.new("TextButton")
    botao.Name = nome .. "Button"
    botao.Parent = parent
    botao.BackgroundColor3 = COLOR_DISABLED
    botao.BorderSizePixel = 0
    botao.Position = posicao
    botao.Size = UDim2.new(1, -20, 0, 45)
    botao.Font = Enum.Font.GothamBold
    botao.TextSize = 13
    botao.TextColor3 = COLOR_TEXT
    botao.Text = texto
    botao.ZIndex = 1000
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 6)
    buttonCorner.Parent = botao
    
    local buttonStroke = Instance.new("UIStroke")
    buttonStroke.Color = COLOR_SECONDARY
    buttonStroke.Thickness = 1
    buttonStroke.Parent = botao
    
    return botao
end

local spawnpointButton = criarBotao(contentArea, "Spawnpoint", UDim2.new(0, 10, 0, 8), "Spawnpoint\n[OFF]")
local invisibleButton = criarBotao(contentArea, "Invisible", UDim2.new(0, 10, 0, 58), "Invisible\n[OFF]")
local visibleButton = criarBotao(contentArea, "Visible", UDim2.new(0, 10, 0, 108), "Visible\n[OFF]")

print("[Spawnpoint] Botões criados!")

-- ═══════════════════════════════════════════════════════════════════
-- LÓGICA DOS BOTÕES
-- ═══════════════════════════════════════════════════════════════════

local function updateButtonVisuals()
    if spawnpoint_enabled then
        spawnpointButton.BackgroundColor3 = COLOR_SUCCESS
        spawnpointButton.Text = "Spawnpoint\n[ON]"
    else
        spawnpointButton.BackgroundColor3 = COLOR_DISABLED
        spawnpointButton.Text = "Spawnpoint\n[OFF]"
    end
    
    if invisible_enabled then
        invisibleButton.BackgroundColor3 = COLOR_SUCCESS
        invisibleButton.Text = "Invisible\n[ON]"
    else
        invisibleButton.BackgroundColor3 = COLOR_DISABLED
        invisibleButton.Text = "Invisible\n[OFF]"
    end
    
    if visible_enabled then
        visibleButton.BackgroundColor3 = COLOR_SUCCESS
        visibleButton.Text = "Visible\n[ON]"
    else
        visibleButton.BackgroundColor3 = COLOR_DISABLED
        visibleButton.Text = "Visible\n[OFF]"
    end
end

-- Spawnpoint
spawnpointButton.MouseButton1Click:Connect(function()
    if spawnpoint_enabled then
        removeSpawnPoint()
    else
        saveSpawnPoint()
    end
    updateButtonVisuals()
end)

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

-- Invisible
invisibleButton.MouseButton1Click:Connect(function()
    if invisible_enabled then
        makeCharacterVisible()
    else
        makeCharacterInvisible()
    end
    updateButtonVisuals()
end)

invisibleButton.MouseEnter:Connect(function()
    if invisible_enabled then
        invisibleButton.BackgroundColor3 = Color3.fromRGB(40, 220, 40)
    else
        invisibleButton.BackgroundColor3 = Color3.fromRGB(120, 120, 120)
    end
end)

invisibleButton.MouseLeave:Connect(function()
    updateButtonVisuals()
end)

-- Visible
visibleButton.MouseButton1Click:Connect(function()
    if visible_enabled then
        invisible_enabled = false
        visible_enabled = false
    else
        makeCharacterVisible()
    end
    updateButtonVisuals()
end)

visibleButton.MouseEnter:Connect(function()
    if visible_enabled then
        visibleButton.BackgroundColor3 = Color3.fromRGB(40, 220, 40)
    else
        visibleButton.BackgroundColor3 = Color3.fromRGB(120, 120, 120)
    end
end)

visibleButton.MouseLeave:Connect(function()
    updateButtonVisuals()
end)

-- ═══════════════════════════════════════════════════════════════════
-- DRAG AND DROP
-- ═══════════════════════════════════════════════════════════════════

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

RunService.InputChanged:Connect(function(input, gameProcessed)
    if not is_dragging then return end
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        local newPos = mouse.Position - drag_offset
        mainFrame.Position = UDim2.new(0, newPos.X, 0, newPos.Y)
    end
end)

-- ═══════════════════════════════════════════════════════════════════
-- MINIMIZE
-- ═══════════════════════════════════════════════════════════════════

minimizeButton.MouseButton1Click:Connect(function()
    if is_minimized then
        contentArea:TweenSize(
            UDim2.new(1, 0, 1, -30),
            Enum.EasingDirection.Out,
            Enum.EasingStyle.Quad,
            0.2,
            true
        )
        mainFrame:TweenSize(
            UDim2.new(0, 280, 0, 280),
            Enum.EasingDirection.Out,
            Enum.EasingStyle.Quad,
            0.2,
            true
        )
        minimizeButton.Text = "−"
        is_minimized = false
    else
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

-- ═══════════════════════════════════════════════════════════════════
-- FECHAR
-- ═══════════════════════════════════════════════════════════════════

closeButton.MouseButton1Click:Connect(function()
    screenGui:Destroy()
    removeSpawnPoint()
    invisible_enabled = false
    visible_enabled = false
end)

updateButtonVisuals()

print("[Spawnpoint] GUI criada com sucesso!")

-- ═══════════════════════════════════════════════════════════════════
-- TELEPORTE AUTOMÁTICO
-- ═══════════════════════════════════════════════════════════════════

player.CharacterAdded:Connect(function(character)
    print("[Spawnpoint] Personagem spawned!")
    
    if not waitForHumanoidRootPart() then
        print("[Spawnpoint] Falha ao aguardar HumanoidRootPart")
        return
    end
    
    local success = pcall(function()
        if spawnpoint_enabled and spawnpos ~= nil then
            print("[Spawnpoint] Teleportando...")
            wait(spDelay)
            
            local root = getHumanoidRootPart()
            if root then
                root.CFrame = spawnpos
                showNotification("Teleporte", "Teleportado!")
            end
        end
    end)
end)

print("[Spawnpoint] ✓ Script totalmente carregado!")
print("[Spawnpoint] ✓ GUI disponível no jogo!")
print("[Spawnpoint] Clique nos botões para testar!")

-- ═══════════════════════════════════════════════════════════════════
-- FIM
-- ═══════════════════════════════════════════════════════════════════

