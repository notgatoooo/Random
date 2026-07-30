-- Obsidian Ui

-- Carregamento da biblioteca e addons
local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()

-- Referências globais para Toggles e Options (criadas automaticamente pela biblioteca)
local Toggles = Library.Toggles
local Options = Library.Options

-- Library:CreateWindow(WindowInfo) - Cria a janela principal
-- Parâmetros:
--   Title: string - Título da janela
--   Footer: string - Texto no rodapé
--   Position: UDim2 - Posição inicial (ignorada se Center=true)
--   Size: UDim2 - Tamanho da janela
--   Center: boolean - Centraliza na tela
--   AutoShow: boolean - Mostra automaticamente ao carregar
--   Resizable: boolean - Permite redimensionar arrastando o canto
--   ToggleKeybind: Enum.KeyCode - Tecla para mostrar/esconder
--   UnlockMouseWhileOpen: boolean - Libera cursor enquanto aberta
--   EnableSidebarResize: boolean - Permite redimensionar sidebar
--   EnableCompacting: boolean - Permite modo compacto da sidebar
--   DisableCompactingSnap: boolean - Desabilita snap ao redimensionar
--   SidebarCompacted: boolean - Inicia com sidebar compactada
--   MinContainerWidth: number - Largura mínima do container
--   MinSidebarWidth: number - Largura mínima da sidebar
--   SidebarCompactWidth: number - Largura quando compactada
--   SidebarCollapseThreshold: number - Threshold para colapsar (0-1)
--   CompactWidthActivation: number - Largura para ativar modo compacto
--   SearchbarSize: UDim2 - Tamanho da barra de pesquisa
--   GlobalSearch: boolean - Pesquisa em todas as abas
--   IconSize: UDim2 - Tamanho do ícone no header
--   CornerRadius: number - Raio das bordas (máx: 20)
--   Font: Enum.Font - Fonte da UI
--   NotifySide: string - "Right" ou "Left" para notificações
--   ShowCustomCursor: boolean - Mostra cursor customizado
--   MobileButtonsSide: string - "Left" ou "Right" para botões mobile
--   BackgroundImage: string - URL/AssetId de imagem de fundo
--   Icon: string/number - Ícone no header (URL ou AssetId)
--   DisableSearch: boolean - Desabilita barra de pesquisa
local Window = Library:CreateWindow({
    Title = "Title",
    Footer = "Footer",
    Center = true,
    Size = UDim2.fromOffset(720, 600),
    AutoShow = true,
    Resizable = true,
    ToggleKeybind = Enum.KeyCode.RightControl,
    UnlockMouseWhileOpen = true,
    EnableSidebarResize = true,
    EnableCompacting = true,
    SidebarCompacted = false,
    MinContainerWidth = 256,
    MinSidebarWidth = 128,
    SidebarCompactWidth = 48,
    GlobalSearch = false,
    CornerRadius = 4,
    Font = Enum.Font.Code,
    NotifySide = "Right",
    ShowCustomCursor = true,
    MobileButtonsSide = "Left",
})

-- Window:AddTab(Name, Icon, Description) - Cria uma aba
-- Parâmetros:
--   Name: string - Nome exibido na sidebar
--   Icon: string - Nome do ícone Lucide (https://lucide.dev) ou URL de imagem
--   Description: string (opcional) - Descrição/tooltip da aba
-- Retorna: objeto Tab
local MainTab = Window:AddTab("Principal", "home", "Elementos básicos da UI")
local CombatTab = Window:AddTab("Combate", "sword", "Configurações de combate")
local VisualsTab = Window:AddTab("Visuais", "eye", "ESP e configurações visuais")
local MiscTab = Window:AddTab("Misc", "wrench", "Utilidades diversas")
local SettingsTab = Window:AddTab("Configurações", "settings", "Temas e configs")

-- Window:AddKeyTab(Name, Icon, Description) - Cria uma aba especial para key system
-- Mesmos parâmetros que AddTab
-- Método especial: Tab:AddKeyBox(callback) - Adiciona input de key com botão execute
-- local KeyTab = Window:AddKeyTab("Key System", "key", "Sistema de verificação")

-- Tab:AddLeftGroupbox(Name, IconName) / Tab:AddRightGroupbox(Name, IconName)
-- Parâmetros:
--   Name: string - Título da groupbox
--   IconName: string (opcional) - Ícone Lucide
-- Retorna: objeto Groupbox
local ToggleBox = MainTab:AddLeftGroupbox("Toggles", "toggle-left")
local SliderBox = MainTab:AddRightGroupbox("Sliders", "sliders-horizontal")
local DropdownBox = MainTab:AddLeftGroupbox("Dropdowns", "chevrons-up-down")
local ButtonBox = MainTab:AddRightGroupbox("Botões & Labels", "square")

local AimbotBox = CombatTab:AddLeftGroupbox("Aimbot", "crosshair")
local SilentAimBox = CombatTab:AddRightGroupbox("Silent Aim", "target")

local ESPBox = VisualsTab:AddLeftGroupbox("ESP", "scan-eye")
local ChamsBox = VisualsTab:AddRightGroupbox("Chams", "palette")

local MiscBox = MiscTab:AddLeftGroupbox("Utilidades", "toolbox")
local ViewportBox = MiscTab:AddRightGroupbox("Viewport", "box")

local ThemeBox = SettingsTab:AddLeftGroupbox("Temas", "paintbrush")
local ConfigBox = SettingsTab:AddRightGroupbox("Configuração", "folder-cog")

-- Groupbox:AddToggle(Idx, Info) - Cria um toggle/switch
-- Parâmetros Idx: string - Identificador único (acessado via Toggles[Idx])
-- Parâmetros Info:
--   Text: string - Texto do toggle
--   Default: boolean - Valor inicial
--   Callback: function(value) - Chamado quando muda
--   Changed: function(value) - Alias do Callback
--   Tooltip: string - Tooltip ao passar mouse
--   DisabledTooltip: string - Tooltip quando desabilitado
--   Risky: boolean - Texto vermelho (indica função perigosa)
--   Disabled: boolean - Começa desabilitado
--   Visible: boolean - Visibilidade inicial
-- Métodos do Toggle:
--   Toggle:SetValue(boolean) - Define valor
--   Toggle:SetDisabled(boolean) - Habilita/desabilita
--   Toggle:SetVisible(boolean) - Mostra/esconde
--   Toggle:SetText(string) - Altera texto
--   Toggle:OnChanged(function) - Define callback
--   Toggle:AddKeyPicker(...) - Adiciona KeyPicker
--   Toggle:AddColorPicker(...) - Adiciona ColorPicker
ToggleBox:AddToggle("MainToggle", {
    Text = "Toggle Básico",
    Default = false,
    Tooltip = "Este é um toggle simples",
    Callback = function(Value)
        print("[Toggle] MainToggle:", Value)
    end
})

ToggleBox:AddToggle("RiskyToggle", {
    Text = "Toggle Arriscado",
    Default = false,
    Risky = true,
    Tooltip = "Opção perigosa - texto fica vermelho",
    Callback = function(Value)
        print("[Toggle] RiskyToggle:", Value)
    end
})

ToggleBox:AddToggle("DisabledToggle", {
    Text = "Toggle Desabilitado",
    Default = false,
    Disabled = true,
    DisabledTooltip = "Este toggle está desabilitado temporariamente",
})

-- Groupbox:AddCheckbox(Idx, Info) - Alternativa visual ao toggle (checkbox)
-- Mesmos parâmetros que AddToggle
-- Library.ForceCheckbox = true força todos toggles a serem checkboxes
ToggleBox:AddCheckbox("MyCheckbox", {
    Text = "Checkbox Exemplo",
    Default = false,
    Tooltip = "Visual de checkbox ao invés de switch",
    Callback = function(Value)
        print("[Checkbox] MyCheckbox:", Value)
    end
})

-- Groupbox:AddSlider(Idx, Info) - Cria um slider
-- Parâmetros Info:
--   Text: string - Label do slider
--   Default: number - Valor inicial
--   Min: number - Valor mínimo
--   Max: number - Valor máximo
--   Rounding: number - Casas decimais (0 = inteiro)
--   Prefix: string - Texto antes do valor (ex: "$")
--   Suffix: string - Texto após o valor (ex: "%", "studs")
--   Compact: boolean - Label e valor na mesma linha
--   HideMax: boolean - Esconde valor máximo na exibição
--   FormatDisplayValue: function(slider, value) - Formatação customizada
--   Callback/Changed: function(value) - Chamado quando muda
--   Tooltip/DisabledTooltip: string - Tooltips
--   Disabled/Visible: boolean - Estados
-- Métodos:
--   Slider:SetValue(number) - Define valor
--   Slider:SetMin(number) / Slider:SetMax(number) - Define limites
--   Slider:SetDisabled/SetVisible/SetText/SetPrefix/SetSuffix
--   Slider:OnChanged(function) - Define callback
SliderBox:AddSlider("BasicSlider", {
    Text = "Slider Básico",
    Default = 50,
    Min = 0,
    Max = 100,
    Rounding = 0,
    Callback = function(Value)
        print("[Slider] BasicSlider:", Value)
    end
})

SliderBox:AddSlider("DecimalSlider", {
    Text = "Velocidade",
    Default = 16.0,
    Min = 1.0,
    Max = 100.0,
    Rounding = 1,
    Suffix = " studs/s",
    Callback = function(Value)
        print("[Slider] Velocidade:", Value)
    end
})

SliderBox:AddSlider("MoneySlider", {
    Text = "Preço",
    Default = 500,
    Min = 0,
    Max = 10000,
    Rounding = 0,
    Prefix = "R$ ",
})

SliderBox:AddSlider("CompactSlider", {
    Text = "FOV",
    Default = 90,
    Min = 30,
    Max = 120,
    Rounding = 0,
    Compact = true,
    Suffix = "°",
})

SliderBox:AddSlider("CustomFormatSlider", {
    Text = "Transparência",
    Default = 0.5,
    Min = 0,
    Max = 1,
    Rounding = 2,
    FormatDisplayValue = function(slider, value)
        return string.format("%.0f%%", value * 100)
    end,
})

-- Groupbox:AddInput(Idx, Info) - Cria caixa de texto
-- Parâmetros Info:
--   Text: string - Label/título
--   Default: string - Valor inicial
--   Placeholder: string - Texto placeholder
--   Finished: boolean - Callback só ao pressionar Enter
--   Numeric: boolean - Aceita apenas números
--   ClearTextOnFocus: boolean - Limpa ao clicar
--   AllowEmpty: boolean - Permite vazio
--   EmptyReset: string - Valor se AllowEmpty=false e ficar vazio
--   MaxLength: number - Máximo de caracteres
--   Callback/Changed: function(value)
--   Disabled/Visible: boolean
-- Métodos: SetValue, SetDisabled, SetVisible, SetText, OnChanged
SliderBox:AddInput("BasicInput", {
    Text = "Input Básico",
    Default = "",
    Placeholder = "Digite algo...",
    Callback = function(Value)
        print("[Input] BasicInput:", Value)
    end
})

SliderBox:AddInput("NumericInput", {
    Text = "Input Numérico",
    Default = "100",
    Numeric = true,
    Placeholder = "Apenas números",
})

SliderBox:AddInput("FinishedInput", {
    Text = "Pressione Enter",
    Default = "",
    Finished = true,
    Placeholder = "Enter para confirmar",
    Callback = function(Value)
        Library:Notify("Input confirmado: " .. Value, 3)
    end
})

SliderBox:AddInput("LimitedInput", {
    Text = "Máx 10 chars",
    Default = "",
    MaxLength = 10,
    Placeholder = "Máximo 10",
})

-- Groupbox:AddDropdown(Idx, Info) - Cria menu dropdown
-- Parâmetros Info:
--   Text: string - Label (nil para sem label)
--   Values: table - Lista de valores
--   Default: any - Valor inicial (string para single, table para multi)
--   Multi: boolean - Múltiplas seleções
--   AllowNull: boolean - Permite desmarcar tudo
--   Searchable: boolean - Caixa de busca
--   MaxVisibleDropdownItems: number - Máx itens visíveis (padrão: 8)
--   DisabledValues: table - Valores desabilitados
--   SpecialType: string - "Player" ou "Team" para listas especiais
--   ExcludeLocalPlayer: boolean - Exclui jogador local (SpecialType="Player")
--   FormatDisplayValue: function(value) - Formata exibição
--   Callback/Changed: function(value)
--   Disabled/Visible: boolean
-- Métodos:
--   Dropdown:SetValue(value) - Define valor
--   Dropdown:SetValues(table) - Redefine lista
--   Dropdown:AddValues(table/string) - Adiciona valores
--   Dropdown:SetDisabledValues(table) - Define desabilitados
--   Dropdown:AddDisabledValues(table/string) - Adiciona desabilitados
--   Dropdown:GetActiveValues() - Retorna selecionados
--   Dropdown:SetDisabled/SetVisible/SetText/OnChanged
DropdownBox:AddDropdown("BasicDropdown", {
    Text = "Dropdown Básico",
    Values = {"Opção 1", "Opção 2", "Opção 3", "Opção 4"},
    Default = "Opção 1",
    Callback = function(Value)
        print("[Dropdown] BasicDropdown:", Value)
    end
})

DropdownBox:AddDropdown("MultiDropdown", {
    Text = "Multi-Seleção",
    Values = {"Maçã", "Banana", "Laranja", "Uva", "Manga"},
    Default = {"Maçã", "Banana"},
    Multi = true,
    Callback = function(Value)
        for item, selected in pairs(Value) do
            if selected then
                print("  -", item)
            end
        end
    end
})

DropdownBox:AddDropdown("SearchableDropdown", {
    Text = "Com Busca",
    Values = {"Alpha", "Beta", "Gamma", "Delta", "Epsilon", "Zeta"},
    Default = "Alpha",
    Searchable = true,
})

DropdownBox:AddDropdown("NoLabelDropdown", {
    Values = {"Valor A", "Valor B", "Valor C"},
    Default = "Valor A",
})

DropdownBox:AddDropdown("DisabledValuesDropdown", {
    Text = "Itens Desabilitados",
    Values = {"Disponível 1", "Indisponível", "Disponível 2", "Bloqueado"},
    DisabledValues = {"Indisponível", "Bloqueado"},
    Default = "Disponível 1",
})

DropdownBox:AddDropdown("PlayerDropdown", {
    Text = "Selecionar Jogador",
    SpecialType = "Player",
    ExcludeLocalPlayer = true,
    AllowNull = true,
    Callback = function(Value)
        if Value then
            print("[Dropdown] Jogador:", Value.Name)
        end
    end
})

DropdownBox:AddDropdown("TeamDropdown", {
    Text = "Selecionar Time",
    SpecialType = "Team",
    AllowNull = true,
})

DropdownBox:AddDropdown("FormattedDropdown", {
    Text = "Com Formatação",
    Values = {1, 2, 3, 4, 5},
    Default = 1,
    FormatDisplayValue = function(value)
        return "Nível " .. tostring(value)
    end,
})

-- Groupbox:AddButton(Text, Callback, Idx) - Sintaxe simples
-- Groupbox:AddButton(Info) - Sintaxe com tabela
-- Parâmetros Info:
--   Text: string - Texto do botão
--   Func/Callback: function - Executada ao clicar
--   DoubleClick: boolean - Requer confirmação
--   Tooltip/DisabledTooltip: string
--   Risky: boolean - Texto vermelho
--   Disabled/Visible: boolean
-- Métodos:
--   Button:SetDisabled/SetVisible/SetText
--   Button:AddButton(Info) - Adiciona sub-botão na mesma linha
ButtonBox:AddButton("Botão Simples", function()
    Library:Notify("Botão clicado!", 2)
end)

ButtonBox:AddButton({
    Text = "Com Tooltip",
    Tooltip = "Clique para fazer algo",
    Func = function()
        print("[Button] Clicado!")
    end
})

ButtonBox:AddButton({
    Text = "Confirmar Ação",
    DoubleClick = true,
    Func = function()
        Library:Notify("Ação confirmada!", 3)
    end
})

ButtonBox:AddButton({
    Text = "Ação Perigosa",
    Risky = true,
    DoubleClick = true,
    Func = function()
        print("[Button] Ação perigosa executada!")
    end
})

local DualButton = ButtonBox:AddButton({
    Text = "Esquerdo",
    Func = function() print("Esquerdo!") end
})
DualButton:AddButton({
    Text = "Direito",
    Func = function() print("Direito!") end
})

-- Groupbox:AddLabel(Text, DoesWrap, Idx) - Sintaxe simples
-- Groupbox:AddLabel(Info) - Sintaxe com tabela
-- Parâmetros Info:
--   Text: string - Texto
--   DoesWrap: boolean - Quebra em múltiplas linhas
--   Size: number - Tamanho da fonte (padrão: 14)
--   Visible: boolean
-- Métodos: SetText, SetVisible, AddColorPicker, AddKeyPicker
ButtonBox:AddLabel("Label simples")

ButtonBox:AddLabel({
    Text = "Label com quebra de linha que será exibido em múltiplas linhas quando necessário.",
    DoesWrap = true
})

ButtonBox:AddLabel({
    Text = "Texto Grande",
    Size = 18
})

-- Groupbox:AddDivider(Text) - Linha divisória
-- Parâmetros:
--   Text: string (opcional) - Texto centralizado
-- Também aceita tabela: { Text = "...", MarginTop = 0, MarginBottom = 0, Margin = 0 }
ButtonBox:AddDivider()
ButtonBox:AddDivider("Seção")

-- Label/Toggle:AddColorPicker(Idx, Info) - Seletor de cor
-- Parâmetros Info:
--   Default: Color3 - Cor inicial
--   Title: string - Título do popup
--   Transparency: number - Transparência inicial (nil para desabilitar)
--   Callback/Changed: function(color)
-- Métodos:
--   ColorPicker:SetValue(Color3) - Define cor
--   ColorPicker:SetValueRGB(Color3, transparency) - Cor e transparência
--   ColorPicker:OnChanged(function)
-- Propriedades: ColorPicker.Value, ColorPicker.Transparency
local ColorLabel = ButtonBox:AddLabel("Cor do ESP")
ColorLabel:AddColorPicker("ESPColor", {
    Default = Color3.fromRGB(255, 0, 0),
    Title = "Selecione a cor",
    Callback = function(Color)
        print("[ColorPicker] ESPColor:", Color)
    end
})

local TransLabel = ButtonBox:AddLabel("Cor com Alpha")
TransLabel:AddColorPicker("AlphaColor", {
    Default = Color3.fromRGB(0, 255, 0),
    Title = "Cor com Transparência",
    Transparency = 0.5,
})

ToggleBox:AddToggle("ColoredToggle", {
    Text = "Toggle com Cor",
    Default = true
}):AddColorPicker("ToggleColor", {
    Default = Color3.fromRGB(0, 170, 255),
})

-- Label/Toggle:AddKeyPicker(Idx, Info) - Seletor de tecla/keybind
-- Parâmetros Info:
--   Text: string - Nome na lista de keybinds
--   Default: string - Tecla padrão ("None", "MB1", "MB2", "MB3", ou KeyCode.Name)
--   DefaultModifiers: table - Modificadores padrão ({"LAlt"}, {"LCtrl"}, etc.)
--   Mode: string - "Toggle", "Hold", "Always", ou "Press"
--   Modes: table - Modos disponíveis
--   SyncToggleState: boolean - Sincroniza com toggle pai
--   NoUI: boolean - Não mostra na lista de keybinds
--   Callback/Clicked: function(isActive) - Quando ativado
--   ChangedCallback/Changed: function(key, modifiers) - Quando tecla muda
-- Métodos:
--   KeyPicker:SetValue({key, mode, modifiers}) - Define tecla/modo
--   KeyPicker:GetState() - Retorna se ativo
--   KeyPicker:OnClick/OnChanged(function)
-- Propriedades: Value, Mode, Toggled, Modifiers
AimbotBox:AddToggle("AimbotToggle", {
    Text = "Ativar Aimbot",
    Default = false,
}):AddKeyPicker("AimbotKey", {
    Text = "Aimbot",
    Default = "MB2",
    Mode = "Hold",
    SyncToggleState = true,
    Callback = function(IsActive)
        print("[KeyPicker] Aimbot:", IsActive)
    end,
})

local SpeedLabel = AimbotBox:AddLabel("Speed Hack")
SpeedLabel:AddKeyPicker("SpeedKey", {
    Text = "Speed Hack",
    Default = "V",
    Mode = "Toggle",
    Modes = {"Toggle", "Hold"},
})

local FlyLabel = AimbotBox:AddLabel("Voar")
FlyLabel:AddKeyPicker("FlyKey", {
    Text = "Fly",
    Default = "F",
    DefaultModifiers = {"LCtrl"},
    Mode = "Toggle",
})

-- Groupbox:AddDependencyBox() - Container condicional
-- Elementos só aparecem quando condições são verdadeiras
-- Método: Depbox:SetupDependencies(dependencies)
-- dependencies = { {Toggle/Dropdown, valorEsperado}, ... }
AimbotBox:AddToggle("EnableAdvanced", {
    Text = "Configurações Avançadas",
    Default = false
})

local AimbotDepbox = AimbotBox:AddDependencyBox()
AimbotDepbox:SetupDependencies({
    {Toggles.EnableAdvanced, true}
})

AimbotDepbox:AddSlider("AimbotFOV", {
    Text = "FOV do Aimbot",
    Default = 90,
    Min = 10,
    Max = 360,
    Rounding = 0,
    Suffix = "°"
})

AimbotDepbox:AddSlider("AimbotSmooth", {
    Text = "Suavização",
    Default = 5,
    Min = 1,
    Max = 20,
    Rounding = 1
})

AimbotDepbox:AddDropdown("AimbotBone", {
    Text = "Parte do Corpo",
    Values = {"Head", "Torso", "Random"},
    Default = "Head"
})

AimbotBox:AddDropdown("AimbotMode", {
    Text = "Modo do Aimbot",
    Values = {"Desligado", "Silencioso", "Legit", "Rage"},
    Default = "Desligado"
})

local RageDepbox = AimbotBox:AddDependencyBox()
RageDepbox:SetupDependencies({
    {Options.AimbotMode, "Rage"}
})

RageDepbox:AddToggle("RageAntiAim", {
    Text = "Anti-Aim",
    Default = false
})

-- Groupbox:AddDependencyGroupbox() - Groupbox condicional inteira
-- Mesma lógica do DependencyBox mas para toda a groupbox

-- Tab:AddLeftTabbox(Name) / Tab:AddRightTabbox(Name) - Abas dentro de groupbox
-- Parâmetros: Name: string (opcional)
-- Tabbox:AddTab(Name, IconName) - Adiciona aba no tabbox
local ESPTabbox = VisualsTab:AddLeftTabbox("ESP Settings")

local ESPPlayersTab = ESPTabbox:AddTab("Players", "users")
ESPPlayersTab:AddToggle("ESPPlayers", {
    Text = "ESP de Jogadores",
    Default = false
})
ESPPlayersTab:AddToggle("ESPBox", {
    Text = "Caixa 2D",
    Default = true
})
ESPPlayersTab:AddToggle("ESPName", {
    Text = "Nome",
    Default = true
})
ESPPlayersTab:AddToggle("ESPHealth", {
    Text = "Vida",
    Default = true
})

local ESPNPCsTab = ESPTabbox:AddTab("NPCs", "bot")
ESPNPCsTab:AddToggle("ESPNPCs", {
    Text = "ESP de NPCs",
    Default = false
})
ESPNPCsTab:AddSlider("NPCsDistance", {
    Text = "Distância Máx",
    Default = 500,
    Min = 100,
    Max = 2000,
    Rounding = 0,
    Suffix = " studs"
})

local ESPItemsTab = ESPTabbox:AddTab("Items", "package")
ESPItemsTab:AddToggle("ESPItems", {
    Text = "ESP de Items",
    Default = false
})
ESPItemsTab:AddDropdown("ItemsFilter", {
    Text = "Filtrar",
    Values = {"Todos", "Armas", "Consumíveis"},
    Default = "Todos",
    Multi = true
})

-- Groupbox:AddViewport(Idx, Info) - Visualização 3D
-- Parâmetros Info:
--   Object: Instance - BasePart ou Model
--   Camera: Camera (opcional)
--   Clone: boolean - Clona o objeto (padrão: true)
--   AutoFocus: boolean - Ajusta câmera automaticamente
--   Interactive: boolean - Permite rotacionar com mouse
--   Height: number - Altura em pixels
--   Visible: boolean
-- Métodos: SetObject, SetCamera, Focus, SetInteractive, SetVisible, SetHeight
local examplePart = Instance.new("Part")
examplePart.Size = Vector3.new(4, 4, 4)
examplePart.Color = Color3.fromRGB(0, 170, 255)
examplePart.Material = Enum.Material.Neon

ViewportBox:AddViewport("DemoViewport", {
    Object = examplePart,
    Clone = true,
    AutoFocus = true,
    Interactive = true,
    Height = 150,
})

ViewportBox:AddLabel("Arraste (botão direito) para rotacionar")

-- Groupbox:AddImage(Idx, Info) - Exibe imagem
-- Parâmetros Info:
--   Image: string - URL ou AssetId
--   Transparency: number
--   BackgroundTransparency: number
--   Color: Color3 - Tingimento
--   RectOffset/RectSize: Vector2 - Para sprite sheets
--   ScaleType: Enum.ScaleType
--   Height: number
--   Visible: boolean
-- Métodos: SetImage, SetColor, SetTransparency, SetVisible, SetHeight
ViewportBox:AddImage("DemoImage", {
    Image = "rbxassetid://6031075938",
    Height = 80,
    Color = Color3.new(1, 1, 1),
    ScaleType = Enum.ScaleType.Fit
})

-- Groupbox:AddVideo(Idx, Info) - Reproduz vídeo
-- Parâmetros Info:
--   Video: string - AssetId
--   Looped: boolean
--   Playing: boolean
--   Volume: number (0-1)
--   Height: number
--   Visible: boolean
-- Métodos: SetVideo, Play, Pause, SetLooped, SetVolume, SetVisible, SetHeight

-- Groupbox:AddUIPassthrough(Idx, Info) - Passa instância GUI customizada
-- Parâmetros Info:
--   Instance: GuiBase2d - Instância GUI
--   Height: number
--   Visible: boolean
-- Métodos: SetHeight, SetInstance, SetVisible

-- Tab:UpdateWarningBox(Info) - Caixa de aviso no topo da aba
-- Parâmetros Info:
--   Visible: boolean
--   Title: string
--   Text: string
--   IsNormal: boolean - false = tema vermelho
--   LockSize: boolean - Limita altura e adiciona scroll
MiscBox:AddButton("Mostrar Aviso", function()
    MainTab:UpdateWarningBox({
        Visible = true,
        Title = "INFORMAÇÃO",
        Text = "Mensagem informativa importante.",
        IsNormal = true
    })
end)

MiscBox:AddButton("Aviso Vermelho", function()
    MainTab:UpdateWarningBox({
        Visible = true,
        Title = "AVISO",
        Text = "Mensagem de alerta!",
        IsNormal = false
    })
end)

MiscBox:AddButton("Esconder Aviso", function()
    MainTab:UpdateWarningBox({ Visible = false })
end)

-- Library:Notify(Text, Time, SoundId) - Sintaxe simples
-- Library:Notify(Info) - Sintaxe com tabela
-- Parâmetros Info:
--   Title: string - Título
--   Description: string - Texto
--   Time: number/Instance - Duração ou Instance (fecha quando destruída)
--   SoundId: number/string - Som
--   Icon: string - Ícone pequeno (Lucide)
--   BigIcon: string - Ícone grande
--   IconColor: Color3
--   Steps: number - Total de passos (barra de progresso)
--   Persist: boolean - Não fecha automaticamente
-- Retorno:
--   Notification:ChangeTitle(string)
--   Notification:ChangeDescription(string)
--   Notification:ChangeStep(number)
--   Notification:Destroy()
MiscBox:AddDivider("Notificações")

MiscBox:AddButton("Notificação Simples", function()
    Library:Notify("Notificação simples!", 3)
end)

MiscBox:AddButton("Com Título", function()
    Library:Notify({
        Title = "Título",
        Description = "Descrição da notificação.",
        Time = 5
    })
end)

MiscBox:AddButton("Com Ícone", function()
    Library:Notify({
        Title = "Sucesso!",
        Description = "Operação concluída.",
        Time = 4,
        Icon = "check-circle",
        IconColor = Color3.fromRGB(0, 255, 0)
    })
end)

MiscBox:AddButton("Com BigIcon", function()
    Library:Notify({
        Title = "Alerta",
        Description = "Algo requer atenção.",
        Time = 4,
        BigIcon = "alert-triangle",
        IconColor = Color3.fromRGB(255, 200, 0)
    })
end)

local persistentNotif
MiscBox:AddButton("Persistente", function()
    if persistentNotif then persistentNotif:Destroy() end
    persistentNotif = Library:Notify({
        Title = "Carregando...",
        Description = "Não fecha automaticamente.",
        Persist = true
    })
end)

MiscBox:AddButton("Fechar Persistente", function()
    if persistentNotif then persistentNotif:Destroy() end
end)

MiscBox:AddButton("Com Progresso", function()
    local totalSteps = 5
    local notif = Library:Notify({
        Title = "Processando",
        Description = "Passo 0/" .. totalSteps,
        Steps = totalSteps,
        Persist = true
    })
    
    for i = 1, totalSteps do
        task.wait(0.5)
        notif:ChangeDescription("Passo " .. i .. "/" .. totalSteps)
        notif:ChangeStep(i)
    end
    
    task.wait(0.5)
    notif:ChangeTitle("Concluído!")
    notif:ChangeDescription("Todos os passos completados.")
    task.wait(2)
    notif:Destroy()
end)

-- Window:AddDialog(Idx, Info) - Cria diálogo modal
-- Parâmetros Info:
--   Title: string
--   Description: string
--   Icon: string - Ícone no título
--   TitleColor/DescriptionColor: Color3
--   AutoDismiss: boolean - Fecha ao clicar botões
--   OutsideClickDismiss: boolean - Fecha ao clicar fora
--   FooterButtons: table de botões
-- Cada botão:
--   Id: string
--   Title: string
--   Variant: "Primary"/"Secondary"/"Destructive"/"Ghost"
--   Order: number
--   WaitTime: number - Tempo antes de poder clicar
--   Callback: function(dialog)
-- Métodos Dialog:
--   SetTitle, SetDescription, AddFooterButton, RemoveFooterButton
--   SetButtonDisabled, SetButtonOrder, Dismiss
-- Dialog também suporta AddToggle, AddSlider, etc.
MiscBox:AddDivider("Diálogos")

MiscBox:AddButton("Diálogo Confirmação", function()
    Window:AddDialog("ConfirmDialog", {
        Title = "Confirmação",
        Description = "Deseja continuar?",
        AutoDismiss = true,
        OutsideClickDismiss = true,
        FooterButtons = {
            {
                Id = "cancel",
                Title = "Cancelar",
                Variant = "Secondary",
                Order = 1,
            },
            {
                Id = "confirm",
                Title = "Confirmar",
                Variant = "Primary",
                Order = 2,
                Callback = function(dialog)
                    Library:Notify("Confirmado!", 2)
                end
            }
        }
    })
end)

MiscBox:AddButton("Diálogo Destrutivo", function()
    Window:AddDialog("DestructiveDialog", {
        Title = "Deletar Dados",
        Description = "Ação irreversível. Aguarde 3 segundos.",
        AutoDismiss = true,
        OutsideClickDismiss = false,
        FooterButtons = {
            {
                Id = "cancel",
                Title = "Cancelar",
                Variant = "Ghost",
                Order = 1
            },
            {
                Id = "delete",
                Title = "Deletar",
                Variant = "Destructive",
                WaitTime = 3,
                Order = 2,
                Callback = function(dialog)
                    Library:Notify("Deletado!", 3)
                end
            }
        }
    })
end)

MiscBox:AddButton("Diálogo com Inputs", function()
    local dialog = Window:AddDialog("InputDialog", {
        Title = "Configuração Rápida",
        Description = "Configure opções:",
        AutoDismiss = false,
        OutsideClickDismiss = false,
        FooterButtons = {
            {
                Id = "apply",
                Title = "Aplicar",
                Variant = "Primary",
                Callback = function(dlg)
                    local speed = Options.DialogSpeed.Value
                    local enabled = Toggles.DialogEnabled.Value
                    Library:Notify("Speed: " .. speed .. ", Enabled: " .. tostring(enabled), 2)
                    dlg:Dismiss()
                end
            }
        }
    })
    
    dialog:AddToggle("DialogEnabled", {
        Text = "Ativar Recurso",
        Default = true
    })
    
    dialog:AddSlider("DialogSpeed", {
        Text = "Velocidade",
        Default = 50,
        Min = 0,
        Max = 100,
        Rounding = 0
    })
end)

-- Funções utilitárias da Library
MiscBox:AddDivider("Utilitários")

-- Library:Toggle(boolean?) - Mostra/esconde UI
MiscBox:AddButton("Esconder UI (2s)", function()
    Library:Toggle(false)
    task.wait(2)
    Library:Toggle(true)
end)

-- Library:SetNotifySide(side) - "Left" ou "Right"
MiscBox:AddButton("Notificações Esquerda", function()
    Library:SetNotifySide("Left")
    Library:Notify("Notificações à esquerda!", 2)
end)

MiscBox:AddButton("Notificações Direita", function()
    Library:SetNotifySide("Right")
    Library:Notify("Notificações à direita!", 2)
end)

-- Library:SetFont(Font) - Muda fonte global
MiscBox:AddDropdown("FontDropdown", {
    Text = "Mudar Fonte",
    Values = {"Code", "Gotham", "SourceSans", "Roboto", "RobotoMono", "BuilderSans"},
    Default = "Code",
    Callback = function(Value)
        Library:SetFont(Enum.Font[Value])
    end
})

-- Library:SetDPIScale(scale) - Escala da UI (100 = normal)
MiscBox:AddSlider("DPIScale", {
    Text = "Escala UI",
    Default = 100,
    Min = 50,
    Max = 150,
    Rounding = 0,
    Suffix = "%",
    Callback = function(Value)
        Library:SetDPIScale(Value)
    end
})

-- Acesso a elementos
-- Toggles[Idx] para toggles
-- Options[Idx] para sliders, dropdowns, inputs, colorpickers, keypickers
-- Library.Labels[Idx] para labels
-- Library.Buttons[Idx] para botões
MiscBox:AddButton("Ler Valores", function()
    print("=== Valores ===")
    print("MainToggle:", Toggles.MainToggle.Value)
    print("BasicSlider:", Options.BasicSlider.Value)
    print("BasicDropdown:", Options.BasicDropdown.Value)
    print("ESPColor:", Options.ESPColor.Value)
end)

MiscBox:AddButton("Alterar Toggle", function()
    Toggles.MainToggle:SetValue(not Toggles.MainToggle.Value)
end)

MiscBox:AddButton("Alterar Slider", function()
    Options.BasicSlider:SetValue(math.random(0, 100))
end)

-- Library:GiveSignal(connection) - Registra conexão para desconectar no unload
Library:GiveSignal(game:GetService("RunService").Heartbeat:Connect(function()
    -- Código que roda todo frame
    -- Desconectado automaticamente em Library:Unload()
end))

-- Library:OnUnload(callback) - Callback quando UI for descarregada
Library:OnUnload(function()
    print("UI descarregada!")
end)

-- Library:Unload() - Descarrega UI completamente
MiscBox:AddButton({
    Text = "Descarregar UI",
    DoubleClick = true,
    Risky = true,
    Func = function()
        Library:Unload()
    end
})

-- Window:ChangeTitle(title) - Muda título da janela
-- Window:SetFooter(footer) - Muda rodapé
-- Window:SetBackgroundImage(image) - Muda imagem de fundo (se habilitado)
-- Window:IsSidebarCompacted() - Retorna se sidebar está compactada
-- Window:SetCompact(boolean) - Define modo compacto
-- Window:GetSidebarWidth() - Largura atual da sidebar
-- Window:SetSidebarWidth(number) - Define largura da sidebar
-- Window:ShowTabInfo(name, description) - Mostra info da aba atual
-- Window:HideTabInfo() - Esconde info da aba

-- Library:AddDraggableLabel(Text) - Label arrastável independente
-- Retorna: { Label, SetText(string), SetVisible(boolean) }
local dragLabel = Library:AddDraggableLabel("Label Arrastável")
dragLabel:SetVisible(false)

-- Library:AddDraggableButton(Text, Callback, ExcludeScaling) - Botão arrastável
-- Retorna: { Button, SetText(string) }

-- Library:AddDraggableMenu(Name) - Menu arrastável com container
-- Retorna: Holder, Container

-- Library:AddContextMenu(Holder, Size, Offset, List, ActiveCallback)
-- Menu de contexto que aparece relativo a um elemento

-- Library.ImageManager - Gerenciador de assets customizados
-- Library.ImageManager.AddAsset(name, robloxId, url, forceRedownload)
-- Library.ImageManager.GetAsset(name) - Retorna ID do asset
-- Library.ImageManager.DownloadAsset(name, forceRedownload)

-- ThemeManager setup
-- ThemeManager:SetLibrary(Library) - OBRIGATÓRIO
-- ThemeManager:SetFolder(folder) - Pasta para salvar
-- ThemeManager:ApplyToTab(tab) - Cria UI em aba (cria groupbox automaticamente)
-- ThemeManager:ApplyToGroupbox(groupbox) - Cria UI em groupbox específica
-- ThemeManager:ApplyTheme(themeName) - Aplica tema
-- ThemeManager:SetDefaultTheme(themeTable) - Define tema padrão (antes de ApplyTo*)
-- ThemeManager:SaveCustomTheme(name) - Salva tema atual
-- ThemeManager:LoadDefault() - Carrega tema padrão
-- ThemeManager:SaveDefault(themeName) - Define como padrão
-- Temas built-in: Default, BBot, Fatality, Jester, Mint, Tokyo Night, Ubuntu,
--   Quartz, Nord, Dracula, Monokai, Gruvbox, Solarized, Catppuccin, One Dark,
--   Cyberpunk, Oceanic Next, Material
ThemeManager:SetLibrary(Library)
ThemeManager:SetFolder("ObsidianSettings")
ThemeManager:ApplyToGroupbox(ThemeBox)

-- SaveManager setup
-- SaveManager:SetLibrary(Library) - OBRIGATÓRIO
-- SaveManager:SetFolder(folder) - Pasta raiz
-- SaveManager:SetSubFolder(subfolder) - Subpasta (útil por jogo)
-- SaveManager:BuildConfigSection(tab) - Cria UI (groupbox à direita)
-- SaveManager:IgnoreThemeSettings() - Ignora elementos de tema ao salvar
-- SaveManager:SetIgnoreIndexes(list) - Lista de Idx a ignorar
-- SaveManager:Save(name) / Load(name) / Delete(name)
-- SaveManager:LoadAutoloadConfig() - Carrega config de autoload
-- SaveManager:SaveAutoloadConfig(name) - Define autoload
-- SaveManager:GetAutoloadConfig() - Retorna nome do autoload
-- SaveManager:RefreshConfigList() - Retorna lista de configs
SaveManager:SetLibrary(Library)
SaveManager:SetFolder("ObsidianSettings")
SaveManager:SetSubFolder("DemoScript")
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({"DPIScale"})
SaveManager:BuildConfigSection(SettingsTab)
SaveManager:LoadAutoloadConfig()

-- Temas programáticos
MiscBox:AddDivider("Temas")

MiscBox:AddButton("Tema Dracula", function()
    ThemeManager:ApplyTheme("Dracula")
    Library:Notify("Tema Dracula!", 2)
end)

MiscBox:AddButton("Tema Cyberpunk", function()
    ThemeManager:ApplyTheme("Cyberpunk")
    Library:Notify("Tema Cyberpunk!", 2)
end)

MiscBox:AddButton("Cores Customizadas", function()
    Library.Scheme.AccentColor = Color3.fromRGB(255, 100, 100)
    Library.Scheme.MainColor = Color3.fromRGB(30, 30, 40)
    Library:UpdateColorsUsingRegistry()
    Library:Notify("Cores customizadas!", 2)
end)

-- Notificação final
Library:Notify({
    Title = "Script Carregado!",
    Description = "Obsidian UI Library Demo. Explore todas as abas!",
    Time = 5,
    Icon = "check-circle",
    IconColor = Color3.fromRGB(0, 255, 100)
})

print("Obsidian UI Library - Exemplo Completo Carregado!")
