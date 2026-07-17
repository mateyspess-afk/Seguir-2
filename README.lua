-- ============================================================
--   Follow Nearest Player | Script para Delta Executor
--   Segue por trás do jogador mais próximo
--   GUI arrastável | Slider de distância | Fechar | Minimizar
-- ============================================================

local Players        = game:GetService("Players")
local RunService     = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local Camera      = workspace.CurrentCamera

-- ──────────────────────────────────────────────────────────
-- Configurações padrão
-- ──────────────────────────────────────────────────────────
local followEnabled  = false
local followDistance = 5        -- distância atrás do alvo (studs)
local minDist        = 2
local maxDist        = 20
local currentTarget  = nil

-- ──────────────────────────────────────────────────────────
-- Utilitários
-- ──────────────────────────────────────────────────────────
local function getCharacter(player)
    return player and player.Character
end

local function getRootPart(player)
    local char = getCharacter(player)
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function getNearestPlayer()
    local myRoot = getRootPart(LocalPlayer)
    if not myRoot then return nil end

    local nearest, nearestDist = nil, math.huge
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local root = getRootPart(player)
            if root then
                local dist = (root.Position - myRoot.Position).Magnitude
                if dist < nearestDist then
                    nearest     = player
                    nearestDist = dist
                end
            end
        end
    end
    return nearest
end

-- ──────────────────────────────────────────────────────────
-- Loop de seguir
-- ──────────────────────────────────────────────────────────
RunService.Heartbeat:Connect(function()
    if not followEnabled then return end

    local myRoot = getRootPart(LocalPlayer)
    if not myRoot then return end

    -- Atualiza alvo mais próximo a cada frame
    currentTarget = getNearestPlayer()
    if not currentTarget then return end

    local targetRoot = getRootPart(currentTarget)
    if not targetRoot then return end

    -- Calcula posição atrás do alvo
    local targetCFrame = targetRoot.CFrame
    local behindOffset = targetCFrame * CFrame.new(0, 0, followDistance)

    -- Teleporta suavemente (usando CFrame direto para executor)
    myRoot.CFrame = behindOffset
end)

-- ──────────────────────────────────────────────────────────
-- GUI
-- ──────────────────────────────────────────────────────────
-- Remove GUI antiga se existir
if LocalPlayer.PlayerGui:FindFirstChild("FollowGUI") then
    LocalPlayer.PlayerGui.FollowGUI:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name            = "FollowGUI"
ScreenGui.ResetOnSpawn    = false
ScreenGui.ZIndexBehavior  = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent          = LocalPlayer.PlayerGui

-- ── Janela principal ──
local MainFrame = Instance.new("Frame")
MainFrame.Name            = "MainFrame"
MainFrame.Size            = UDim2.new(0, 280, 0, 180)
MainFrame.Position        = UDim2.new(0.5, -140, 0.5, -90)
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 28)
MainFrame.BorderSizePixel = 0
MainFrame.Active          = true
MainFrame.Parent          = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent       = MainFrame

-- Sombra
local Shadow = Instance.new("ImageLabel")
Shadow.Size              = UDim2.new(1, 20, 1, 20)
Shadow.Position          = UDim2.new(0, -10, 0, -10)
Shadow.BackgroundTransparency = 1
Shadow.Image             = "rbxassetid://5554236805"
Shadow.ImageColor3       = Color3.fromRGB(0, 0, 0)
Shadow.ImageTransparency = 0.5
Shadow.ScaleType         = Enum.ScaleType.Slice
Shadow.SliceCenter       = Rect.new(23, 23, 277, 277)
Shadow.ZIndex            = 0
Shadow.Parent            = MainFrame

-- ── Barra de título ──
local TitleBar = Instance.new("Frame")
TitleBar.Name             = "TitleBar"
TitleBar.Size             = UDim2.new(1, 0, 0, 36)
TitleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 48)
TitleBar.BorderSizePixel  = 0
TitleBar.Parent           = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 10)
TitleCorner.Parent       = TitleBar

-- Corrige canto inferior da barra (deixa reto embaixo)
local TitleFix = Instance.new("Frame")
TitleFix.Size             = UDim2.new(1, 0, 0, 10)
TitleFix.Position         = UDim2.new(0, 0, 1, -10)
TitleFix.BackgroundColor3 = Color3.fromRGB(30, 30, 48)
TitleFix.BorderSizePixel  = 0
TitleFix.Parent           = TitleBar

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size               = UDim2.new(1, -80, 1, 0)
TitleLabel.Position           = UDim2.new(0, 12, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text               = "⚡ Follow Player"
TitleLabel.TextColor3         = Color3.fromRGB(200, 200, 255)
TitleLabel.TextSize           = 15
TitleLabel.Font               = Enum.Font.GothamBold
TitleLabel.TextXAlignment     = Enum.TextXAlignment.Left
TitleLabel.Parent             = TitleBar

-- ── Botão Minimizar (-) ──
local MinBtn = Instance.new("TextButton")
MinBtn.Size               = UDim2.new(0, 28, 0, 22)
MinBtn.Position           = UDim2.new(1, -62, 0, 7)
MinBtn.BackgroundColor3   = Color3.fromRGB(255, 190, 50)
MinBtn.Text               = "−"
MinBtn.TextColor3         = Color3.fromRGB(30, 30, 30)
MinBtn.TextSize           = 18
MinBtn.Font               = Enum.Font.GothamBold
MinBtn.BorderSizePixel    = 0
MinBtn.Parent             = TitleBar

local MinCorner = Instance.new("UICorner")
MinCorner.CornerRadius = UDim.new(0, 6)
MinCorner.Parent       = MinBtn

-- ── Botão Fechar (X) ──
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size             = UDim2.new(0, 28, 0, 22)
CloseBtn.Position         = UDim2.new(1, -30, 0, 7)
CloseBtn.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
CloseBtn.Text             = "✕"
CloseBtn.TextColor3       = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize         = 14
CloseBtn.Font             = Enum.Font.GothamBold
CloseBtn.BorderSizePixel  = 0
CloseBtn.Parent           = TitleBar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent       = CloseBtn

-- ── Conteúdo (minimizável) ──
local Content = Instance.new("Frame")
Content.Name             = "Content"
Content.Size             = UDim2.new(1, 0, 1, -36)
Content.Position         = UDim2.new(0, 0, 0, 36)
Content.BackgroundTransparency = 1
Content.Parent           = MainFrame

-- ── Botão Toggle Follow ──
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size             = UDim2.new(1, -24, 0, 38)
ToggleBtn.Position         = UDim2.new(0, 12, 0, 10)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 80)
ToggleBtn.Text             = "▶  Seguir: OFF"
ToggleBtn.TextColor3       = Color3.fromRGB(180, 180, 255)
ToggleBtn.TextSize         = 14
ToggleBtn.Font             = Enum.Font.GothamBold
ToggleBtn.BorderSizePixel  = 0
ToggleBtn.Parent           = Content

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0, 8)
ToggleCorner.Parent       = ToggleBtn

-- ── Label distância ──
local DistLabel = Instance.new("TextLabel")
DistLabel.Size               = UDim2.new(1, -24, 0, 20)
DistLabel.Position           = UDim2.new(0, 12, 0, 58)
DistLabel.BackgroundTransparency = 1
DistLabel.Text               = "Distância: " .. followDistance .. " studs"
DistLabel.TextColor3         = Color3.fromRGB(180, 180, 220)
DistLabel.TextSize           = 13
DistLabel.Font               = Enum.Font.Gotham
DistLabel.TextXAlignment     = Enum.TextXAlignment.Left
DistLabel.Parent             = Content

-- ── Trilha do Slider ──
local SliderTrack = Instance.new("Frame")
SliderTrack.Size             = UDim2.new(1, -24, 0, 8)
SliderTrack.Position         = UDim2.new(0, 12, 0, 84)
SliderTrack.BackgroundColor3 = Color3.fromRGB(50, 50, 75)
SliderTrack.BorderSizePixel  = 0
SliderTrack.Parent           = Content

local TrackCorner = Instance.new("UICorner")
TrackCorner.CornerRadius = UDim.new(1, 0)
TrackCorner.Parent       = SliderTrack

-- Preenchimento do slider
local SliderFill = Instance.new("Frame")
SliderFill.Size             = UDim2.new((followDistance - minDist) / (maxDist - minDist), 0, 1, 0)
SliderFill.BackgroundColor3 = Color3.fromRGB(100, 100, 255)
SliderFill.BorderSizePixel  = 0
SliderFill.Parent           = SliderTrack

local FillCorner = Instance.new("UICorner")
FillCorner.CornerRadius = UDim.new(1, 0)
FillCorner.Parent       = SliderFill

-- Botão do slider (bolinha)
local SliderKnob = Instance.new("TextButton")
SliderKnob.Size             = UDim2.new(0, 18, 0, 18)
SliderKnob.AnchorPoint      = Vector2.new(0.5, 0.5)
SliderKnob.Position         = UDim2.new((followDistance - minDist) / (maxDist - minDist), 0, 0.5, 0)
SliderKnob.BackgroundColor3 = Color3.fromRGB(160, 160, 255)
SliderKnob.Text             = ""
SliderKnob.BorderSizePixel  = 0
SliderKnob.ZIndex           = 3
SliderKnob.Parent           = SliderTrack

local KnobCorner = Instance.new("UICorner")
KnobCorner.CornerRadius = UDim.new(1, 0)
KnobCorner.Parent       = SliderKnob

-- ── Label do alvo atual ──
local TargetLabel = Instance.new("TextLabel")
TargetLabel.Size               = UDim2.new(1, -24, 0, 20)
TargetLabel.Position           = UDim2.new(0, 12, 0, 104)
TargetLabel.BackgroundTransparency = 1
TargetLabel.Text               = "Alvo: nenhum"
TargetLabel.TextColor3         = Color3.fromRGB(140, 220, 140)
TargetLabel.TextSize           = 12
TargetLabel.Font               = Enum.Font.Gotham
TargetLabel.TextXAlignment     = Enum.TextXAlignment.Left
TargetLabel.Parent             = Content

-- ──────────────────────────────────────────────────────────
-- Lógica dos botões
-- ──────────────────────────────────────────────────────────

-- Toggle Follow
ToggleBtn.MouseButton1Click:Connect(function()
    followEnabled = not followEnabled
    if followEnabled then
        ToggleBtn.Text             = "⏹  Seguir: ON"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(40, 80, 40)
        ToggleBtn.TextColor3       = Color3.fromRGB(100, 255, 100)
    else
        ToggleBtn.Text             = "▶  Seguir: OFF"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 80)
        ToggleBtn.TextColor3       = Color3.fromRGB(180, 180, 255)
        TargetLabel.Text           = "Alvo: nenhum"
        currentTarget              = nil
    end
end)

-- Atualiza label do alvo
RunService.Heartbeat:Connect(function()
    if followEnabled and currentTarget then
        TargetLabel.Text = "Alvo: " .. currentTarget.Name
    elseif not followEnabled then
        TargetLabel.Text = "Alvo: nenhum"
    end
end)

-- Fechar
CloseBtn.MouseButton1Click:Connect(function()
    followEnabled = false
    ScreenGui:Destroy()
end)

-- Minimizar / Restaurar
local minimized = false
MinBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        Content.Visible   = false
        MainFrame.Size    = UDim2.new(0, 280, 0, 36)
        MinBtn.Text       = "+"
    else
        Content.Visible   = true
        MainFrame.Size    = UDim2.new(0, 280, 0, 180)
        MinBtn.Text       = "−"
    end
end)

-- ──────────────────────────────────────────────────────────
-- Arrastar a GUI
-- ──────────────────────────────────────────────────────────
local dragging, dragInput, dragStart, startPos

TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        dragging  = true
        dragStart = input.Position
        startPos  = MainFrame.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

TitleBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement
    or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

-- ──────────────────────────────────────────────────────────
-- Slider de distância
-- ──────────────────────────────────────────────────────────
local slidingDist = false

local function updateSlider(inputPos)
    local trackPos  = SliderTrack.AbsolutePosition
    local trackSize = SliderTrack.AbsoluteSize
    local relX      = math.clamp((inputPos.X - trackPos.X) / trackSize.X, 0, 1)

    followDistance = math.floor(minDist + relX * (maxDist - minDist) + 0.5)
    local fill     = (followDistance - minDist) / (maxDist - minDist)

    SliderFill.Size     = UDim2.new(fill, 0, 1, 0)
    SliderKnob.Position = UDim2.new(fill, 0, 0.5, 0)
    DistLabel.Text      = "Distância: " .. followDistance .. " studs"
end

SliderKnob.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        slidingDist = true
    end
end)

SliderTrack.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        slidingDist = true
        updateSlider(input.Position)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if slidingDist and (
        input.UserInputType == Enum.UserInputType.MouseMovement or
        input.UserInputType == Enum.UserInputType.Touch
    ) then
        updateSlider(input.Position)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        slidingDist = false
    end
end)

-- ──────────────────────────────────────────────────────────
print("[FollowPlayer] Script carregado com sucesso!")
