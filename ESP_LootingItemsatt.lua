--[[ 
    ESP Menu por yato
    Ative/desative ESPs de LootingItems, Zonas e CHAIN
--]]

-- Cores
local cores = {
    Artifact = Color3.fromRGB(0, 170, 255),
    ScrapNormal = Color3.fromRGB(255, 140, 0),
}
local corZona = Color3.fromRGB(0, 255, 100)
local corChain = Color3.fromRGB(170, 0, 255)

-- Variáveis de controle
local ativoLoot = true
local ativoZona = true
local ativoChain = true

-- Função para criar ESP de texto
local function criarESP(obj, texto, cor)
    if not obj or (not obj:IsA("BasePart") and not obj:IsA("Model")) then return end
    local adornee = obj
    if obj:IsA("Model") then
        adornee = obj:FindFirstChildWhichIsA("BasePart")
        if not adornee then return end
    end
    if adornee:FindFirstChild("ESP") then return end
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ESP"
    billboard.Adornee = adornee
    billboard.Size = UDim2.new(0, 100, 0, 30)
    billboard.StudsOffset = Vector3.new(0, 2, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = adornee
    local label = Instance.new("TextLabel", billboard)
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = texto
    label.TextColor3 = cor
    label.TextStrokeTransparency = 0.5
    label.TextScaled = true
    label.Font = Enum.Font.SourceSansBold
end

-- Função para remover ESPs
local function removerESP(obj)
    if not obj then return end
    if obj:IsA("Model") then
        for _, part in ipairs(obj:GetChildren()) do
            if part:IsA("BasePart") and part:FindFirstChild("ESP") then
                part.ESP:Destroy()
            end
        end
    elseif obj:IsA("BasePart") and obj:FindFirstChild("ESP") then
        obj.ESP:Destroy()
    end
end

-- LootingItems
local function atualizarLoot()
    local lootFolder = workspace:FindFirstChild("LootingItems")
    if not lootFolder then return end
    for _, categoria in ipairs(lootFolder:GetChildren()) do
        for _, item in ipairs(categoria:GetChildren()) do
            if cores[item.Name] then
                if ativoLoot then
                    criarESP(item, item.Name, cores[item.Name])
                else
                    removerESP(item)
                end
            end
        end
    end
end

-- Zonas
local function atualizarZonas()
    local zonasFolder = workspace:FindFirstChild("ExtraDetails")
    if not zonasFolder then return end
    for _, zona in ipairs(zonasFolder:GetChildren()) do
        if ativoZona then
            criarESP(zona, zona.Name, corZona)
        else
            removerESP(zona)
        end
    end
end

-- CHAIN
local function atualizarChain()
    local chain = workspace:FindFirstChild("CHAIN")
    if chain then
        if ativoChain then
            criarESP(chain, "CHAIN", corChain)
        else
            removerESP(chain)
        end
    end
end

-- Funções para conectar eventos de ChildAdded
local function conectarEventosLootingItems()
    local lootFolder = workspace:FindFirstChild("LootingItems")
    if lootFolder then
        lootFolder.ChildAdded:Connect(atualizarLoot)
        for _, categoria in ipairs(lootFolder:GetChildren()) do
            categoria.ChildAdded:Connect(atualizarLoot)
        end
    end
end

local function conectarEventosZonas()
    local zonasFolder = workspace:FindFirstChild("ExtraDetails")
    if zonasFolder then
        zonasFolder.ChildAdded:Connect(atualizarZonas)
    end
end

-- Monitorar criação futura das pastas
workspace.ChildAdded:Connect(function(obj)
    if obj.Name == "LootingItems" then
        conectarEventosLootingItems()
        atualizarLoot()
    elseif obj.Name == "ExtraDetails" then
        conectarEventosZonas()
        atualizarZonas()
    elseif obj.Name == "CHAIN" then
        atualizarChain()
    end
end)

-- Atualização inicial e conexão de eventos
atualizarLoot()
conectarEventosLootingItems()
atualizarZonas()
conectarEventosZonas()
atualizarChain()

-- GUI
local player = game:GetService("Players").LocalPlayer
local guiParent = player:FindFirstChild("PlayerGui") or player:WaitForChild("PlayerGui")
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "YatoESPMenu"
ScreenGui.Parent = guiParent

local frame = Instance.new("Frame", ScreenGui)
frame.Size = UDim2.new(0, 220, 0, 180)
frame.Position = UDim2.new(0, 20, 0, 100)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true

local titulo = Instance.new("TextLabel", frame)
titulo.Size = UDim2.new(1, 0, 0, 30)
titulo.Position = UDim2.new(0, 0, 0, 0)
titulo.BackgroundTransparency = 1
titulo.Text = "ESP Menu - by yato"
titulo.TextColor3 = Color3.fromRGB(255, 255, 255)
titulo.Font = Enum.Font.SourceSansBold
titulo.TextSize = 18

local lootBtn, zonaBtn, chainBtn

local function atualizarBotoes()
    lootBtn.Text = "ESP LootingItems: " .. (ativoLoot and "ON" or "OFF")
    zonaBtn.Text = "ESP Zonas: " .. (ativoZona and "ON" or "OFF")
    chainBtn.Text = "ESP CHAIN: " .. (ativoChain and "ON" or "OFF")
end

local function criarBotao(texto, ordem, callback)
    local btn = Instance.new("TextButton", frame)
    btn.Size = UDim2.new(1, -20, 0, 32)
    btn.Position = UDim2.new(0, 10, 0, 35 + (ordem-1)*38)
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.SourceSans
    btn.TextSize = 16
    btn.Text = texto
    btn.AutoButtonColor = true
    btn.MouseButton1Click:Connect(callback)
    return btn
end

lootBtn = criarBotao("ESP LootingItems: ON", 1, function()
    ativoLoot = not ativoLoot
    atualizarLoot()
    atualizarBotoes()
end)

zonaBtn = criarBotao("ESP Zonas: ON", 2, function()
    ativoZona = not ativoZona
    atualizarZonas()
    atualizarBotoes()
end)

chainBtn = criarBotao("ESP CHAIN: ON", 3, function()
    ativoChain = not ativoChain
    atualizarChain()
    atualizarBotoes()
end)

local creditos = Instance.new("TextLabel", frame)
creditos.Size = UDim2.new(1, 0, 0, 30)
creditos.Position = UDim2.new(0, 0, 1, -30)
creditos.BackgroundTransparency = 1
creditos.Text = "Créditos: yato"
creditos.TextColor3 = Color3.fromRGB(120, 200, 255)
creditos.Font = Enum.Font.SourceSansItalic
creditos.TextSize = 16

atualizarBotoes() 
