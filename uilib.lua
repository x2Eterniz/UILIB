-- Vxizi UI Library
-- Standalone Roblox Lua UI library.
-- Usage:
-- local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/user/repo/main/uilib.lua"))()
-- local window = UI:CreateWindow({ Title = "Vxizi", Icon = "rbxassetid://0" })

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player and player:WaitForChild("PlayerGui")

local DarkUI = {}
DarkUI.__index = DarkUI
DarkUI.Version = "1.2.0"

local function getFont(fontName, fallback)
	local ok, font = pcall(function()
		return Enum.Font[fontName]
	end)

	return ok and font or fallback
end

local function getFontFace(family, weight, style)
	local ok, fontFace = pcall(function()
		return Font.new(
			family,
			weight or Enum.FontWeight.Regular,
			style or Enum.FontStyle.Normal
		)
	end)

	return ok and fontFace or nil
end

local function resolveContentId(value)
	if value == nil then
		return nil
	end

	if type(value) == "number" then
		return "rbxassetid://" .. tostring(math.floor(value))
	end

	local text = tostring(value or "")
	text = string.gsub(text, "^%s+", "")
	text = string.gsub(text, "%s+$", "")
	if text == "" then
		return nil
	end

	local lowered = string.lower(text)
	if string.find(lowered, "rbxassetid://", 1, true)
		or string.find(lowered, "rbxthumb://", 1, true)
		or string.find(lowered, "asset://", 1, true)
		or string.find(lowered, "http://", 1, true)
		or string.find(lowered, "https://", 1, true)
		or string.find(lowered, "data:", 1, true) then
		return text
	end

	local assetIdProtocol = string.match(text, "^assetid://(%d+)$")
	if assetIdProtocol then
		return "rbxassetid://" .. assetIdProtocol
	end

	local queryId = string.match(text, "[%?&]id=(%d+)")
	if queryId then
		return "rbxassetid://" .. queryId
	end

	local numericId = string.match(text, "^(%d+)$")
	if numericId then
		return "rbxassetid://" .. numericId
	end

	return text
end

DarkUI.Icons = {
	["lucide-accessibility"] = "rbxassetid://10709751939",
	["lucide-activity"] = "rbxassetid://10709752035",
	["lucide-air-vent"] = "rbxassetid://10709752131",
	["lucide-airplay"] = "rbxassetid://10709752254",
	["lucide-alarm-check"] = "rbxassetid://10709752405",
	["lucide-alarm-clock"] = "rbxassetid://10709752630",
	["lucide-alarm-clock-off"] = "rbxassetid://10709752508",
	["lucide-alarm-minus"] = "rbxassetid://10709752732",
	["lucide-alarm-plus"] = "rbxassetid://10709752825",
	["lucide-album"] = "rbxassetid://10709752906",
	["lucide-alert-circle"] = "rbxassetid://10709752996",
	["lucide-alert-octagon"] = "rbxassetid://10709753064",
	["lucide-alert-triangle"] = "rbxassetid://10709753149",
	["lucide-align-center"] = "rbxassetid://10709753570",
	["lucide-align-center-horizontal"] = "rbxassetid://10709753272",
	["lucide-align-center-vertical"] = "rbxassetid://10709753421",
	["lucide-align-end-horizontal"] = "rbxassetid://10709753692",
	["lucide-align-end-vertical"] = "rbxassetid://10709753808",
	["lucide-align-horizontal-distribute-center"] = "rbxassetid://10747779791",
	["lucide-align-horizontal-distribute-end"] = "rbxassetid://10747784534",
	["lucide-align-horizontal-distribute-start"] = "rbxassetid://10709754118",
	["lucide-align-horizontal-justify-center"] = "rbxassetid://10709754204",
	["lucide-align-horizontal-justify-end"] = "rbxassetid://10709754317",
	["lucide-align-horizontal-justify-start"] = "rbxassetid://10709754436",
	["lucide-align-horizontal-space-around"] = "rbxassetid://10709754590",
	["lucide-align-horizontal-space-between"] = "rbxassetid://10709754749",
	["lucide-align-justify"] = "rbxassetid://10709759610",
	["lucide-align-left"] = "rbxassetid://10709759764",
	["lucide-align-right"] = "rbxassetid://10709759895",
	["lucide-align-start-horizontal"] = "rbxassetid://10709760051",
	["lucide-align-start-vertical"] = "rbxassetid://10709760244",
	["lucide-align-vertical-distribute-center"] = "rbxassetid://10709760351",
	["lucide-align-vertical-distribute-end"] = "rbxassetid://10709760434",
	["lucide-align-vertical-distribute-start"] = "rbxassetid://10709760612",
	["lucide-align-vertical-justify-center"] = "rbxassetid://10709760814",
	["lucide-align-vertical-justify-end"] = "rbxassetid://10709761003",
	["lucide-align-vertical-justify-start"] = "rbxassetid://10709761176",
	["lucide-align-vertical-space-around"] = "rbxassetid://10709761324",
	["lucide-align-vertical-space-between"] = "rbxassetid://10709761434",
	["lucide-anchor"] = "rbxassetid://10709761530",
	["lucide-angry"] = "rbxassetid://10709761629",
	["lucide-annoyed"] = "rbxassetid://10709761722",
	["lucide-aperture"] = "rbxassetid://10709761813",
	["lucide-apple"] = "rbxassetid://10709761889",
	["lucide-archive"] = "rbxassetid://10709762233",
	["lucide-archive-restore"] = "rbxassetid://10709762058",
	["lucide-armchair"] = "rbxassetid://10709762327",
	["lucide-anvil"] = "rbxassetid://77943964625400",
	["lucide-arrow-big-down"] = "rbxassetid://10747796644",
	["lucide-arrow-big-left"] = "rbxassetid://10709762574",
	["lucide-arrow-big-right"] = "rbxassetid://10709762727",
	["lucide-arrow-big-up"] = "rbxassetid://10709762879",
	["lucide-arrow-down"] = "rbxassetid://10709767827",
	["lucide-arrow-down-circle"] = "rbxassetid://10709763034",
	["lucide-arrow-down-left"] = "rbxassetid://10709767656",
	["lucide-arrow-down-right"] = "rbxassetid://10709767750",
	["lucide-arrow-left"] = "rbxassetid://10709768114",
	["lucide-arrow-left-circle"] = "rbxassetid://10709767936",
	["lucide-arrow-left-right"] = "rbxassetid://10709768019",
	["lucide-arrow-right"] = "rbxassetid://10709768347",
	["lucide-arrow-right-circle"] = "rbxassetid://10709768226",
	["lucide-arrow-up"] = "rbxassetid://10709768939",
	["lucide-arrow-up-circle"] = "rbxassetid://10709768432",
	["lucide-arrow-up-down"] = "rbxassetid://10709768538",
	["lucide-arrow-up-left"] = "rbxassetid://10709768661",
	["lucide-arrow-up-right"] = "rbxassetid://10709768787",
	["lucide-asterisk"] = "rbxassetid://10709769095",
	["lucide-at-sign"] = "rbxassetid://10709769286",
	["lucide-award"] = "rbxassetid://10709769406",
	["lucide-axe"] = "rbxassetid://10709769508",
	["lucide-axis-3d"] = "rbxassetid://10709769598",
	["lucide-baby"] = "rbxassetid://10709769732",
	["lucide-backpack"] = "rbxassetid://10709769841",
	["lucide-baggage-claim"] = "rbxassetid://10709769935",
	["lucide-banana"] = "rbxassetid://10709770005",
	["lucide-banknote"] = "rbxassetid://10709770178",
	["lucide-bar-chart"] = "rbxassetid://10709773755",
	["lucide-bar-chart-2"] = "rbxassetid://10709770317",
	["lucide-bar-chart-3"] = "rbxassetid://10709770431",
	["lucide-bar-chart-4"] = "rbxassetid://10709770560",
	["lucide-bar-chart-horizontal"] = "rbxassetid://10709773669",
	["lucide-barcode"] = "rbxassetid://10747360675",
	["lucide-baseline"] = "rbxassetid://10709773863",
	["lucide-bath"] = "rbxassetid://10709773963",
	["lucide-battery"] = "rbxassetid://10709774640",
	["lucide-battery-charging"] = "rbxassetid://10709774068",
	["lucide-battery-full"] = "rbxassetid://10709774206",
	["lucide-battery-low"] = "rbxassetid://10709774370",
	["lucide-battery-medium"] = "rbxassetid://10709774513",
	["lucide-beaker"] = "rbxassetid://10709774756",
	["lucide-bed"] = "rbxassetid://10709775036",
	["lucide-bed-double"] = "rbxassetid://10709774864",
	["lucide-bed-single"] = "rbxassetid://10709774968",
	["lucide-beer"] = "rbxassetid://10709775167",
	["lucide-bell"] = "rbxassetid://10709775704",
	["lucide-bell-minus"] = "rbxassetid://10709775241",
	["lucide-bell-off"] = "rbxassetid://10709775320",
	["lucide-bell-plus"] = "rbxassetid://10709775448",
	["lucide-bell-ring"] = "rbxassetid://10709775560",
	["lucide-bike"] = "rbxassetid://10709775894",
	["lucide-binary"] = "rbxassetid://10709776050",
	["lucide-bitcoin"] = "rbxassetid://10709776126",
	["lucide-bluetooth"] = "rbxassetid://10709776655",
	["lucide-bluetooth-connected"] = "rbxassetid://10709776240",
	["lucide-bluetooth-off"] = "rbxassetid://10709776344",
	["lucide-bluetooth-searching"] = "rbxassetid://10709776501",
	["lucide-bold"] = "rbxassetid://10747813908",
	["lucide-bomb"] = "rbxassetid://10709781460",
	["lucide-bone"] = "rbxassetid://10709781605",
	["lucide-book"] = "rbxassetid://10709781824",
	["lucide-book-open"] = "rbxassetid://10709781717",
	["lucide-bookmark"] = "rbxassetid://10709782154",
	["lucide-bookmark-minus"] = "rbxassetid://10709781919",
	["lucide-bookmark-plus"] = "rbxassetid://10709782044",
	["lucide-bot"] = "rbxassetid://10709782230",
	["lucide-box"] = "rbxassetid://10709782497",
	["lucide-box-select"] = "rbxassetid://10709782342",
	["lucide-boxes"] = "rbxassetid://10709782582",
	["lucide-briefcase"] = "rbxassetid://10709782662",
	["lucide-brush"] = "rbxassetid://10709782758",
	["lucide-bug"] = "rbxassetid://10709782845",
	["lucide-building"] = "rbxassetid://10709783051",
	["lucide-building-2"] = "rbxassetid://10709782939",
	["lucide-bus"] = "rbxassetid://10709783137",
	["lucide-cake"] = "rbxassetid://10709783217",
	["lucide-calculator"] = "rbxassetid://10709783311",
	["lucide-calendar"] = "rbxassetid://10709789505",
	["lucide-calendar-check"] = "rbxassetid://10709783474",
	["lucide-calendar-check-2"] = "rbxassetid://10709783392",
	["lucide-calendar-clock"] = "rbxassetid://10709783577",
	["lucide-calendar-days"] = "rbxassetid://10709783673",
	["lucide-calendar-heart"] = "rbxassetid://10709783835",
	["lucide-calendar-minus"] = "rbxassetid://10709783959",
	["lucide-calendar-off"] = "rbxassetid://10709788784",
	["lucide-calendar-plus"] = "rbxassetid://10709788937",
	["lucide-calendar-range"] = "rbxassetid://10709789053",
	["lucide-calendar-search"] = "rbxassetid://10709789200",
	["lucide-calendar-x"] = "rbxassetid://10709789407",
	["lucide-calendar-x-2"] = "rbxassetid://10709789329",
	["lucide-camera"] = "rbxassetid://10709789686",
	["lucide-camera-off"] = "rbxassetid://10747822677",
	["lucide-car"] = "rbxassetid://10709789810",
	["lucide-carrot"] = "rbxassetid://10709789960",
	["lucide-cast"] = "rbxassetid://10709790097",
	["lucide-charge"] = "rbxassetid://10709790202",
	["lucide-check"] = "rbxassetid://10709790644",
	["lucide-check-circle"] = "rbxassetid://10709790387",
	["lucide-check-circle-2"] = "rbxassetid://10709790298",
	["lucide-check-square"] = "rbxassetid://10709790537",
	["lucide-chef-hat"] = "rbxassetid://10709790757",
	["lucide-cherry"] = "rbxassetid://10709790875",
	["lucide-chevron-down"] = "rbxassetid://10709790948",
	["lucide-chevron-first"] = "rbxassetid://10709791015",
	["lucide-chevron-last"] = "rbxassetid://10709791130",
	["lucide-chevron-left"] = "rbxassetid://10709791281",
	["lucide-chevron-right"] = "rbxassetid://10709791437",
	["lucide-chevron-up"] = "rbxassetid://10709791523",
	["lucide-chevrons-down"] = "rbxassetid://10709796864",
	["lucide-chevrons-down-up"] = "rbxassetid://10709791632",
	["lucide-chevrons-left"] = "rbxassetid://10709797151",
	["lucide-chevrons-left-right"] = "rbxassetid://10709797006",
	["lucide-chevrons-right"] = "rbxassetid://10709797382",
	["lucide-chevrons-right-left"] = "rbxassetid://10709797274",
	["lucide-chevrons-up"] = "rbxassetid://10709797622",
	["lucide-chevrons-up-down"] = "rbxassetid://10709797508",
	["lucide-chrome"] = "rbxassetid://10709797725",
	["lucide-circle"] = "rbxassetid://10709798174",
	["lucide-circle-dot"] = "rbxassetid://10709797837",
	["lucide-circle-ellipsis"] = "rbxassetid://10709797985",
	["lucide-circle-slashed"] = "rbxassetid://10709798100",
	["lucide-citrus"] = "rbxassetid://10709798276",
	["lucide-clapperboard"] = "rbxassetid://10709798350",
	["lucide-clipboard"] = "rbxassetid://10709799288",
	["lucide-clipboard-check"] = "rbxassetid://10709798443",
	["lucide-clipboard-copy"] = "rbxassetid://10709798574",
	["lucide-clipboard-edit"] = "rbxassetid://10709798682",
	["lucide-clipboard-list"] = "rbxassetid://10709798792",
	["lucide-clipboard-signature"] = "rbxassetid://10709798890",
	["lucide-clipboard-type"] = "rbxassetid://10709798999",
	["lucide-clipboard-x"] = "rbxassetid://10709799124",
	["lucide-clock"] = "rbxassetid://10709805144",
	["lucide-clock-1"] = "rbxassetid://10709799535",
	["lucide-clock-10"] = "rbxassetid://10709799718",
	["lucide-clock-11"] = "rbxassetid://10709799818",
	["lucide-clock-12"] = "rbxassetid://10709799962",
	["lucide-clock-2"] = "rbxassetid://10709803876",
	["lucide-clock-3"] = "rbxassetid://10709803989",
	["lucide-clock-4"] = "rbxassetid://10709804164",
	["lucide-clock-5"] = "rbxassetid://10709804291",
	["lucide-clock-6"] = "rbxassetid://10709804435",
	["lucide-clock-7"] = "rbxassetid://10709804599",
	["lucide-clock-8"] = "rbxassetid://10709804784",
	["lucide-clock-9"] = "rbxassetid://10709804996",
	["lucide-cloud"] = "rbxassetid://10709806740",
	["lucide-cloud-cog"] = "rbxassetid://10709805262",
	["lucide-cloud-drizzle"] = "rbxassetid://10709805371",
	["lucide-cloud-fog"] = "rbxassetid://10709805477",
	["lucide-cloud-hail"] = "rbxassetid://10709805596",
	["lucide-cloud-lightning"] = "rbxassetid://10709805727",
	["lucide-cloud-moon"] = "rbxassetid://10709805942",
	["lucide-cloud-moon-rain"] = "rbxassetid://10709805838",
	["lucide-cloud-off"] = "rbxassetid://10709806060",
	["lucide-cloud-rain"] = "rbxassetid://10709806277",
	["lucide-cloud-rain-wind"] = "rbxassetid://10709806166",
	["lucide-cloud-snow"] = "rbxassetid://10709806374",
	["lucide-cloud-sun"] = "rbxassetid://10709806631",
	["lucide-cloud-sun-rain"] = "rbxassetid://10709806475",
	["lucide-cloudy"] = "rbxassetid://10709806859",
	["lucide-clover"] = "rbxassetid://10709806995",
	["lucide-code"] = "rbxassetid://10709810463",
	["lucide-code-2"] = "rbxassetid://10709807111",
	["lucide-codepen"] = "rbxassetid://10709810534",
	["lucide-codesandbox"] = "rbxassetid://10709810676",
	["lucide-coffee"] = "rbxassetid://10709810814",
	["lucide-cog"] = "rbxassetid://10709810948",
	["lucide-coins"] = "rbxassetid://10709811110",
	["lucide-columns"] = "rbxassetid://10709811261",
	["lucide-command"] = "rbxassetid://10709811365",
	["lucide-compass"] = "rbxassetid://10709811445",
	["lucide-component"] = "rbxassetid://10709811595",
	["lucide-concierge-bell"] = "rbxassetid://10709811706",
	["lucide-connection"] = "rbxassetid://10747361219",
	["lucide-contact"] = "rbxassetid://10709811834",
	["lucide-contrast"] = "rbxassetid://10709811939",
	["lucide-cookie"] = "rbxassetid://10709812067",
	["lucide-copy"] = "rbxassetid://10709812159",
	["lucide-copyleft"] = "rbxassetid://10709812251",
	["lucide-copyright"] = "rbxassetid://10709812311",
	["lucide-corner-down-left"] = "rbxassetid://10709812396",
	["lucide-corner-down-right"] = "rbxassetid://10709812485",
	["lucide-corner-left-down"] = "rbxassetid://10709812632",
	["lucide-corner-left-up"] = "rbxassetid://10709812784",
	["lucide-corner-right-down"] = "rbxassetid://10709812939",
	["lucide-corner-right-up"] = "rbxassetid://10709813094",
	["lucide-corner-up-left"] = "rbxassetid://10709813185",
	["lucide-corner-up-right"] = "rbxassetid://10709813281",
	["lucide-cpu"] = "rbxassetid://10709813383",
	["lucide-croissant"] = "rbxassetid://10709818125",
	["lucide-crop"] = "rbxassetid://10709818245",
	["lucide-cross"] = "rbxassetid://10709818399",
	["lucide-crosshair"] = "rbxassetid://10709818534",
	["lucide-crown"] = "rbxassetid://10709818626",
	["lucide-cup-soda"] = "rbxassetid://10709818763",
	["lucide-curly-braces"] = "rbxassetid://10709818847",
	["lucide-currency"] = "rbxassetid://10709818931",
	["lucide-container"] = "rbxassetid://17466205552",
	["lucide-database"] = "rbxassetid://10709818996",
	["lucide-delete"] = "rbxassetid://10709819059",
	["lucide-diamond"] = "rbxassetid://10709819149",
	["lucide-dice-1"] = "rbxassetid://10709819266",
	["lucide-dice-2"] = "rbxassetid://10709819361",
	["lucide-dice-3"] = "rbxassetid://10709819508",
	["lucide-dice-4"] = "rbxassetid://10709819670",
	["lucide-dice-5"] = "rbxassetid://10709819801",
	["lucide-dice-6"] = "rbxassetid://10709819896",
	["lucide-dices"] = "rbxassetid://10723343321",
	["lucide-diff"] = "rbxassetid://10723343416",
	["lucide-disc"] = "rbxassetid://10723343537",
	["lucide-divide"] = "rbxassetid://10723343805",
	["lucide-divide-circle"] = "rbxassetid://10723343636",
	["lucide-divide-square"] = "rbxassetid://10723343737",
	["lucide-dollar-sign"] = "rbxassetid://10723343958",
	["lucide-download"] = "rbxassetid://10723344270",
	["lucide-download-cloud"] = "rbxassetid://10723344088",
	["lucide-door-open"] = "rbxassetid://124179241653522",
	["lucide-droplet"] = "rbxassetid://10723344432",
	["lucide-droplets"] = "rbxassetid://10734883356",
	["lucide-drumstick"] = "rbxassetid://10723344737",
	["lucide-edit"] = "rbxassetid://10734883598",
	["lucide-edit-2"] = "rbxassetid://10723344885",
	["lucide-edit-3"] = "rbxassetid://10723345088",
	["lucide-egg"] = "rbxassetid://10723345518",
	["lucide-egg-fried"] = "rbxassetid://10723345347",
	["lucide-electricity"] = "rbxassetid://10723345749",
	["lucide-electricity-off"] = "rbxassetid://10723345643",
	["lucide-equal"] = "rbxassetid://10723345990",
	["lucide-equal-not"] = "rbxassetid://10723345866",
	["lucide-eraser"] = "rbxassetid://10723346158",
	["lucide-euro"] = "rbxassetid://10723346372",
	["lucide-expand"] = "rbxassetid://10723346553",
	["lucide-external-link"] = "rbxassetid://10723346684",
	["lucide-eye"] = "rbxassetid://10723346959",
	["lucide-eye-off"] = "rbxassetid://10723346871",
	["lucide-factory"] = "rbxassetid://10723347051",
	["lucide-fan"] = "rbxassetid://10723354359",
	["lucide-fast-forward"] = "rbxassetid://10723354521",
	["lucide-feather"] = "rbxassetid://10723354671",
	["lucide-figma"] = "rbxassetid://10723354801",
	["lucide-file"] = "rbxassetid://10723374641",
	["lucide-file-archive"] = "rbxassetid://10723354921",
	["lucide-file-audio"] = "rbxassetid://10723355148",
	["lucide-file-audio-2"] = "rbxassetid://10723355026",
	["lucide-file-axis-3d"] = "rbxassetid://10723355272",
	["lucide-file-badge"] = "rbxassetid://10723355622",
	["lucide-file-badge-2"] = "rbxassetid://10723355451",
	["lucide-file-bar-chart"] = "rbxassetid://10723355887",
	["lucide-file-bar-chart-2"] = "rbxassetid://10723355746",
	["lucide-file-box"] = "rbxassetid://10723355989",
	["lucide-file-check"] = "rbxassetid://10723356210",
	["lucide-file-check-2"] = "rbxassetid://10723356100",
	["lucide-file-clock"] = "rbxassetid://10723356329",
	["lucide-file-code"] = "rbxassetid://10723356507",
	["lucide-file-cog"] = "rbxassetid://10723356830",
	["lucide-file-cog-2"] = "rbxassetid://10723356676",
	["lucide-file-diff"] = "rbxassetid://10723357039",
	["lucide-file-digit"] = "rbxassetid://10723357151",
	["lucide-file-down"] = "rbxassetid://10723357322",
	["lucide-file-edit"] = "rbxassetid://10723357495",
	["lucide-file-heart"] = "rbxassetid://10723357637",
	["lucide-file-image"] = "rbxassetid://10723357790",
	["lucide-file-input"] = "rbxassetid://10723357933",
	["lucide-file-json"] = "rbxassetid://10723364435",
	["lucide-file-json-2"] = "rbxassetid://10723364361",
	["lucide-file-key"] = "rbxassetid://10723364605",
	["lucide-file-key-2"] = "rbxassetid://10723364515",
	["lucide-file-line-chart"] = "rbxassetid://10723364725",
	["lucide-file-lock"] = "rbxassetid://10723364957",
	["lucide-file-lock-2"] = "rbxassetid://10723364861",
	["lucide-file-minus"] = "rbxassetid://10723365254",
	["lucide-file-minus-2"] = "rbxassetid://10723365086",
	["lucide-file-output"] = "rbxassetid://10723365457",
	["lucide-file-pie-chart"] = "rbxassetid://10723365598",
	["lucide-file-plus"] = "rbxassetid://10723365877",
	["lucide-file-plus-2"] = "rbxassetid://10723365766",
	["lucide-file-question"] = "rbxassetid://10723365987",
	["lucide-file-scan"] = "rbxassetid://10723366167",
	["lucide-file-search"] = "rbxassetid://10723366550",
	["lucide-file-search-2"] = "rbxassetid://10723366340",
	["lucide-file-signature"] = "rbxassetid://10723366741",
	["lucide-file-spreadsheet"] = "rbxassetid://10723366962",
	["lucide-file-symlink"] = "rbxassetid://10723367098",
	["lucide-file-terminal"] = "rbxassetid://10723367244",
	["lucide-file-text"] = "rbxassetid://10723367380",
	["lucide-file-type"] = "rbxassetid://10723367606",
	["lucide-file-type-2"] = "rbxassetid://10723367509",
	["lucide-file-up"] = "rbxassetid://10723367734",
	["lucide-file-video"] = "rbxassetid://10723373884",
	["lucide-file-video-2"] = "rbxassetid://10723367834",
	["lucide-file-volume"] = "rbxassetid://10723374172",
	["lucide-file-volume-2"] = "rbxassetid://10723374030",
	["lucide-file-warning"] = "rbxassetid://10723374276",
	["lucide-file-x"] = "rbxassetid://10723374544",
	["lucide-file-x-2"] = "rbxassetid://10723374378",
	["lucide-files"] = "rbxassetid://10723374759",
	["lucide-film"] = "rbxassetid://10723374981",
	["lucide-filter"] = "rbxassetid://10723375128",
	["lucide-fingerprint"] = "rbxassetid://10723375250",
	["lucide-flag"] = "rbxassetid://10723375890",
	["lucide-flag-off"] = "rbxassetid://10723375443",
	["lucide-flag-triangle-left"] = "rbxassetid://10723375608",
	["lucide-flag-triangle-right"] = "rbxassetid://10723375727",
	["lucide-flame"] = "rbxassetid://10723376114",
	["lucide-flashlight"] = "rbxassetid://10723376471",
	["lucide-flashlight-off"] = "rbxassetid://10723376365",
	["lucide-flask-conical"] = "rbxassetid://10734883986",
	["lucide-flask-round"] = "rbxassetid://10723376614",
	["lucide-flip-horizontal"] = "rbxassetid://10723376884",
	["lucide-flip-horizontal-2"] = "rbxassetid://10723376745",
	["lucide-flip-vertical"] = "rbxassetid://10723377138",
	["lucide-flip-vertical-2"] = "rbxassetid://10723377026",
	["lucide-flower"] = "rbxassetid://10747830374",
	["lucide-flower-2"] = "rbxassetid://10723377305",
	["lucide-focus"] = "rbxassetid://10723377537",
	["lucide-folder"] = "rbxassetid://10723387563",
	["lucide-folder-archive"] = "rbxassetid://10723384478",
	["lucide-folder-check"] = "rbxassetid://10723384605",
	["lucide-folder-clock"] = "rbxassetid://10723384731",
	["lucide-folder-closed"] = "rbxassetid://10723384893",
	["lucide-folder-cog"] = "rbxassetid://10723385213",
	["lucide-folder-cog-2"] = "rbxassetid://10723385036",
	["lucide-folder-down"] = "rbxassetid://10723385338",
	["lucide-folder-edit"] = "rbxassetid://10723385445",
	["lucide-folder-heart"] = "rbxassetid://10723385545",
	["lucide-folder-input"] = "rbxassetid://10723385721",
	["lucide-folder-key"] = "rbxassetid://10723385848",
	["lucide-folder-lock"] = "rbxassetid://10723386005",
	["lucide-folder-minus"] = "rbxassetid://10723386127",
	["lucide-folder-open"] = "rbxassetid://10723386277",
	["lucide-folder-output"] = "rbxassetid://10723386386",
	["lucide-folder-plus"] = "rbxassetid://10723386531",
	["lucide-folder-search"] = "rbxassetid://10723386787",
	["lucide-folder-search-2"] = "rbxassetid://10723386674",
	["lucide-folder-symlink"] = "rbxassetid://10723386930",
	["lucide-folder-tree"] = "rbxassetid://10723387085",
	["lucide-folder-up"] = "rbxassetid://10723387265",
	["lucide-folder-x"] = "rbxassetid://10723387448",
	["lucide-folders"] = "rbxassetid://10723387721",
	["lucide-form-input"] = "rbxassetid://10723387841",
	["lucide-forward"] = "rbxassetid://10723388016",
	["lucide-frame"] = "rbxassetid://10723394389",
	["lucide-framer"] = "rbxassetid://10723394565",
	["lucide-frown"] = "rbxassetid://10723394681",
	["lucide-fuel"] = "rbxassetid://10723394846",
	["lucide-function-square"] = "rbxassetid://10723395041",
	["lucide-gamepad"] = "rbxassetid://10723395457",
	["lucide-gamepad-2"] = "rbxassetid://10723395215",
	["lucide-gauge"] = "rbxassetid://10723395708",
	["lucide-gavel"] = "rbxassetid://10723395896",
	["lucide-gem"] = "rbxassetid://10723396000",
	["lucide-ghost"] = "rbxassetid://10723396107",
	["lucide-gift"] = "rbxassetid://10723396402",
	["lucide-gift-card"] = "rbxassetid://10723396225",
	["lucide-git-branch"] = "rbxassetid://10723396676",
	["lucide-git-branch-plus"] = "rbxassetid://10723396542",
	["lucide-git-commit"] = "rbxassetid://10723396812",
	["lucide-git-compare"] = "rbxassetid://10723396954",
	["lucide-git-fork"] = "rbxassetid://10723397049",
	["lucide-git-merge"] = "rbxassetid://10723397165",
	["lucide-git-pull-request"] = "rbxassetid://10723397431",
	["lucide-git-pull-request-closed"] = "rbxassetid://10723397268",
	["lucide-git-pull-request-draft"] = "rbxassetid://10734884302",
	["lucide-glass"] = "rbxassetid://10723397788",
	["lucide-glass-2"] = "rbxassetid://10723397529",
	["lucide-glass-water"] = "rbxassetid://10723397678",
	["lucide-glasses"] = "rbxassetid://10723397895",
	["lucide-globe"] = "rbxassetid://10723404337",
	["lucide-globe-2"] = "rbxassetid://10723398002",
	["lucide-grab"] = "rbxassetid://10723404472",
	["lucide-graduation-cap"] = "rbxassetid://10723404691",
	["lucide-grape"] = "rbxassetid://10723404822",
	["lucide-grid"] = "rbxassetid://10723404936",
	["lucide-grip-horizontal"] = "rbxassetid://10723405089",
	["lucide-grip-vertical"] = "rbxassetid://10723405236",
	["lucide-hammer"] = "rbxassetid://10723405360",
	["lucide-hand"] = "rbxassetid://10723405649",
	["lucide-hand-metal"] = "rbxassetid://10723405508",
	["lucide-hard-drive"] = "rbxassetid://10723405749",
	["lucide-hard-hat"] = "rbxassetid://10723405859",
	["lucide-hash"] = "rbxassetid://10723405975",
	["lucide-haze"] = "rbxassetid://10723406078",
	["lucide-headphones"] = "rbxassetid://10723406165",
	["lucide-heart"] = "rbxassetid://10723406885",
	["lucide-heart-crack"] = "rbxassetid://10723406299",
	["lucide-heart-handshake"] = "rbxassetid://10723406480",
	["lucide-heart-off"] = "rbxassetid://10723406662",
	["lucide-heart-pulse"] = "rbxassetid://10723406795",
	["lucide-help-circle"] = "rbxassetid://10723406988",
	["lucide-hexagon"] = "rbxassetid://10723407092",
	["lucide-highlighter"] = "rbxassetid://10723407192",
	["lucide-history"] = "rbxassetid://10723407335",
	["lucide-home"] = "rbxassetid://10723407389",
	["lucide-hourglass"] = "rbxassetid://10723407498",
	["lucide-ice-cream"] = "rbxassetid://10723414308",
	["lucide-image"] = "rbxassetid://10723415040",
	["lucide-image-minus"] = "rbxassetid://10723414487",
	["lucide-image-off"] = "rbxassetid://10723414677",
	["lucide-image-plus"] = "rbxassetid://10723414827",
	["lucide-import"] = "rbxassetid://10723415205",
	["lucide-inbox"] = "rbxassetid://10723415335",
	["lucide-indent"] = "rbxassetid://10723415494",
	["lucide-indian-rupee"] = "rbxassetid://10723415642",
	["lucide-infinity"] = "rbxassetid://10723415766",
	["lucide-info"] = "rbxassetid://10723415903",
	["lucide-inspect"] = "rbxassetid://10723416057",
	["lucide-italic"] = "rbxassetid://10723416195",
	["lucide-japanese-yen"] = "rbxassetid://10723416363",
	["lucide-joystick"] = "rbxassetid://10723416527",
	["lucide-key"] = "rbxassetid://10723416652",
	["lucide-keyboard"] = "rbxassetid://10723416765",
	["lucide-lamp"] = "rbxassetid://10723417513",
	["lucide-lamp-ceiling"] = "rbxassetid://10723416922",
	["lucide-lamp-desk"] = "rbxassetid://10723417016",
	["lucide-lamp-floor"] = "rbxassetid://10723417131",
	["lucide-lamp-wall-down"] = "rbxassetid://10723417240",
	["lucide-lamp-wall-up"] = "rbxassetid://10723417356",
	["lucide-landmark"] = "rbxassetid://10723417608",
	["lucide-languages"] = "rbxassetid://10723417703",
	["lucide-laptop"] = "rbxassetid://10723423881",
	["lucide-laptop-2"] = "rbxassetid://10723417797",
	["lucide-lasso"] = "rbxassetid://10723424235",
	["lucide-lasso-select"] = "rbxassetid://10723424058",
	["lucide-laugh"] = "rbxassetid://10723424372",
	["lucide-layers"] = "rbxassetid://10723424505",
	["lucide-layout"] = "rbxassetid://10723425376",
	["lucide-layout-dashboard"] = "rbxassetid://10723424646",
	["lucide-layout-grid"] = "rbxassetid://10723424838",
	["lucide-layout-list"] = "rbxassetid://10723424963",
	["lucide-layout-template"] = "rbxassetid://10723425187",
	["lucide-leaf"] = "rbxassetid://10723425539",
	["lucide-library"] = "rbxassetid://10723425615",
	["lucide-life-buoy"] = "rbxassetid://10723425685",
	["lucide-lightbulb"] = "rbxassetid://10723425852",
	["lucide-lightbulb-off"] = "rbxassetid://10723425762",
	["lucide-line-chart"] = "rbxassetid://10723426393",
	["lucide-link"] = "rbxassetid://10723426722",
	["lucide-link-2"] = "rbxassetid://10723426595",
	["lucide-link-2-off"] = "rbxassetid://10723426513",
	["lucide-list"] = "rbxassetid://10723433811",
	["lucide-list-checks"] = "rbxassetid://10734884548",
	["lucide-list-end"] = "rbxassetid://10723426886",
	["lucide-list-minus"] = "rbxassetid://10723426986",
	["lucide-list-music"] = "rbxassetid://10723427081",
	["lucide-list-ordered"] = "rbxassetid://10723427199",
	["lucide-list-plus"] = "rbxassetid://10723427334",
	["lucide-list-start"] = "rbxassetid://10723427494",
	["lucide-list-video"] = "rbxassetid://10723427619",
	["lucide-list-todo"] = "rbxassetid://17376008003",
	["lucide-list-x"] = "rbxassetid://10723433655",
	["lucide-loader"] = "rbxassetid://10723434070",
	["lucide-loader-2"] = "rbxassetid://10723433935",
	["lucide-locate"] = "rbxassetid://10723434557",
	["lucide-locate-fixed"] = "rbxassetid://10723434236",
	["lucide-locate-off"] = "rbxassetid://10723434379",
	["lucide-lock"] = "rbxassetid://10723434711",
	["lucide-log-in"] = "rbxassetid://10723434830",
	["lucide-log-out"] = "rbxassetid://10723434906",
	["lucide-luggage"] = "rbxassetid://10723434993",
	["lucide-magnet"] = "rbxassetid://10723435069",
	["lucide-mail"] = "rbxassetid://10734885430",
	["lucide-mail-check"] = "rbxassetid://10723435182",
	["lucide-mail-minus"] = "rbxassetid://10723435261",
	["lucide-mail-open"] = "rbxassetid://10723435342",
	["lucide-mail-plus"] = "rbxassetid://10723435443",
	["lucide-mail-question"] = "rbxassetid://10723435515",
	["lucide-mail-search"] = "rbxassetid://10734884739",
	["lucide-mail-warning"] = "rbxassetid://10734885015",
	["lucide-mail-x"] = "rbxassetid://10734885247",
	["lucide-mails"] = "rbxassetid://10734885614",
	["lucide-map"] = "rbxassetid://10734886202",
	["lucide-map-pin"] = "rbxassetid://10734886004",
	["lucide-map-pin-off"] = "rbxassetid://10734885803",
	["lucide-maximize"] = "rbxassetid://10734886735",
	["lucide-maximize-2"] = "rbxassetid://10734886496",
	["lucide-medal"] = "rbxassetid://10734887072",
	["lucide-megaphone"] = "rbxassetid://10734887454",
	["lucide-megaphone-off"] = "rbxassetid://10734887311",
	["lucide-meh"] = "rbxassetid://10734887603",
	["lucide-menu"] = "rbxassetid://10734887784",
	["lucide-message-circle"] = "rbxassetid://10734888000",
	["lucide-message-square"] = "rbxassetid://10734888228",
	["lucide-mic"] = "rbxassetid://10734888864",
	["lucide-mic-2"] = "rbxassetid://10734888430",
	["lucide-mic-off"] = "rbxassetid://10734888646",
	["lucide-microscope"] = "rbxassetid://10734889106",
	["lucide-microwave"] = "rbxassetid://10734895076",
	["lucide-milestone"] = "rbxassetid://10734895310",
	["lucide-minimize"] = "rbxassetid://10734895698",
	["lucide-minimize-2"] = "rbxassetid://10734895530",
	["lucide-minus"] = "rbxassetid://10734896206",
	["lucide-minus-circle"] = "rbxassetid://10734895856",
	["lucide-minus-square"] = "rbxassetid://10734896029",
	["lucide-monitor"] = "rbxassetid://10734896881",
	["lucide-monitor-off"] = "rbxassetid://10734896360",
	["lucide-monitor-speaker"] = "rbxassetid://10734896512",
	["lucide-moon"] = "rbxassetid://10734897102",
	["lucide-more-horizontal"] = "rbxassetid://10734897250",
	["lucide-more-vertical"] = "rbxassetid://10734897387",
	["lucide-mountain"] = "rbxassetid://10734897956",
	["lucide-mountain-snow"] = "rbxassetid://10734897665",
	["lucide-mouse"] = "rbxassetid://10734898592",
	["lucide-mouse-pointer"] = "rbxassetid://10734898476",
	["lucide-mouse-pointer-2"] = "rbxassetid://10734898194",
	["lucide-mouse-pointer-click"] = "rbxassetid://10734898355",
	["lucide-move"] = "rbxassetid://10734900011",
	["lucide-move-3d"] = "rbxassetid://10734898756",
	["lucide-move-diagonal"] = "rbxassetid://10734899164",
	["lucide-move-diagonal-2"] = "rbxassetid://10734898934",
	["lucide-move-horizontal"] = "rbxassetid://10734899414",
	["lucide-move-vertical"] = "rbxassetid://10734899821",
	["lucide-music"] = "rbxassetid://10734905958",
	["lucide-music-2"] = "rbxassetid://10734900215",
	["lucide-music-3"] = "rbxassetid://10734905665",
	["lucide-music-4"] = "rbxassetid://10734905823",
	["lucide-navigation"] = "rbxassetid://10734906744",
	["lucide-navigation-2"] = "rbxassetid://10734906332",
	["lucide-navigation-2-off"] = "rbxassetid://10734906144",
	["lucide-navigation-off"] = "rbxassetid://10734906580",
	["lucide-network"] = "rbxassetid://10734906975",
	["lucide-newspaper"] = "rbxassetid://10734907168",
	["lucide-octagon"] = "rbxassetid://10734907361",
	["lucide-option"] = "rbxassetid://10734907649",
	["lucide-outdent"] = "rbxassetid://10734907933",
	["lucide-package"] = "rbxassetid://10734909540",
	["lucide-package-2"] = "rbxassetid://10734908151",
	["lucide-package-check"] = "rbxassetid://10734908384",
	["lucide-package-minus"] = "rbxassetid://10734908626",
	["lucide-package-open"] = "rbxassetid://10734908793",
	["lucide-package-plus"] = "rbxassetid://10734909016",
	["lucide-package-search"] = "rbxassetid://10734909196",
	["lucide-package-x"] = "rbxassetid://10734909375",
	["lucide-paint-bucket"] = "rbxassetid://10734909847",
	["lucide-paintbrush"] = "rbxassetid://10734910187",
	["lucide-paintbrush-2"] = "rbxassetid://10734910030",
	["lucide-palette"] = "rbxassetid://10734910430",
	["lucide-palmtree"] = "rbxassetid://10734910680",
	["lucide-paperclip"] = "rbxassetid://10734910927",
	["lucide-party-popper"] = "rbxassetid://10734918735",
	["lucide-pause"] = "rbxassetid://10734919336",
	["lucide-pause-circle"] = "rbxassetid://10735024209",
	["lucide-pause-octagon"] = "rbxassetid://10734919143",
	["lucide-pen-tool"] = "rbxassetid://10734919503",
	["lucide-pencil"] = "rbxassetid://10734919691",
	["lucide-percent"] = "rbxassetid://10734919919",
	["lucide-person-standing"] = "rbxassetid://10734920149",
	["lucide-phone"] = "rbxassetid://10734921524",
	["lucide-phone-call"] = "rbxassetid://10734920305",
	["lucide-phone-forwarded"] = "rbxassetid://10734920508",
	["lucide-phone-incoming"] = "rbxassetid://10734920694",
	["lucide-phone-missed"] = "rbxassetid://10734920845",
	["lucide-phone-off"] = "rbxassetid://10734921077",
	["lucide-phone-outgoing"] = "rbxassetid://10734921288",
	["lucide-pie-chart"] = "rbxassetid://10734921727",
	["lucide-piggy-bank"] = "rbxassetid://10734921935",
	["lucide-pin"] = "rbxassetid://10734922324",
	["lucide-pin-off"] = "rbxassetid://10734922180",
	["lucide-pipette"] = "rbxassetid://10734922497",
	["lucide-pizza"] = "rbxassetid://10734922774",
	["lucide-plane"] = "rbxassetid://10734922971",
	["lucide-plane-landing"] = "rbxassetid://17376029914",
	["lucide-play"] = "rbxassetid://10734923549",
	["lucide-play-circle"] = "rbxassetid://10734923214",
	["lucide-plus"] = "rbxassetid://10734924532",
	["lucide-plus-circle"] = "rbxassetid://10734923868",
	["lucide-plus-square"] = "rbxassetid://10734924219",
	["lucide-podcast"] = "rbxassetid://10734929553",
	["lucide-pointer"] = "rbxassetid://10734929723",
	["lucide-pound-sterling"] = "rbxassetid://10734929981",
	["lucide-power"] = "rbxassetid://10734930466",
	["lucide-power-off"] = "rbxassetid://10734930257",
	["lucide-printer"] = "rbxassetid://10734930632",
	["lucide-puzzle"] = "rbxassetid://10734930886",
	["lucide-quote"] = "rbxassetid://10734931234",
	["lucide-radio"] = "rbxassetid://10734931596",
	["lucide-radio-receiver"] = "rbxassetid://10734931402",
	["lucide-rectangle-horizontal"] = "rbxassetid://10734931777",
	["lucide-rectangle-vertical"] = "rbxassetid://10734932081",
	["lucide-recycle"] = "rbxassetid://10734932295",
	["lucide-redo"] = "rbxassetid://10734932822",
	["lucide-redo-2"] = "rbxassetid://10734932586",
	["lucide-refresh-ccw"] = "rbxassetid://10734933056",
	["lucide-refresh-cw"] = "rbxassetid://10734933222",
	["lucide-refrigerator"] = "rbxassetid://10734933465",
	["lucide-regex"] = "rbxassetid://10734933655",
	["lucide-repeat"] = "rbxassetid://10734933966",
	["lucide-repeat-1"] = "rbxassetid://10734933826",
	["lucide-reply"] = "rbxassetid://10734934252",
	["lucide-reply-all"] = "rbxassetid://10734934132",
	["lucide-rewind"] = "rbxassetid://10734934347",
	["lucide-rocket"] = "rbxassetid://10734934585",
	["lucide-rocking-chair"] = "rbxassetid://10734939942",
	["lucide-rotate-3d"] = "rbxassetid://10734940107",
	["lucide-rotate-ccw"] = "rbxassetid://10734940376",
	["lucide-rotate-cw"] = "rbxassetid://10734940654",
	["lucide-rss"] = "rbxassetid://10734940825",
	["lucide-ruler"] = "rbxassetid://10734941018",
	["lucide-russian-ruble"] = "rbxassetid://10734941199",
	["lucide-sailboat"] = "rbxassetid://10734941354",
	["lucide-save"] = "rbxassetid://10734941499",
	["lucide-scale"] = "rbxassetid://10734941912",
	["lucide-scale-3d"] = "rbxassetid://10734941739",
	["lucide-scaling"] = "rbxassetid://10734942072",
	["lucide-scan"] = "rbxassetid://10734942565",
	["lucide-scan-face"] = "rbxassetid://10734942198",
	["lucide-scan-line"] = "rbxassetid://10734942351",
	["lucide-scissors"] = "rbxassetid://10734942778",
	["lucide-screen-share"] = "rbxassetid://10734943193",
	["lucide-screen-share-off"] = "rbxassetid://10734942967",
	["lucide-scroll"] = "rbxassetid://10734943448",
	["lucide-search"] = "rbxassetid://10734943674",
	["lucide-send"] = "rbxassetid://10734943902",
	["lucide-separator-horizontal"] = "rbxassetid://10734944115",
	["lucide-separator-vertical"] = "rbxassetid://10734944326",
	["lucide-server"] = "rbxassetid://10734949856",
	["lucide-server-cog"] = "rbxassetid://10734944444",
	["lucide-server-crash"] = "rbxassetid://10734944554",
	["lucide-server-off"] = "rbxassetid://10734944668",
	["lucide-settings"] = "rbxassetid://10734950309",
	["lucide-settings-2"] = "rbxassetid://10734950020",
	["lucide-share"] = "rbxassetid://10734950813",
	["lucide-share-2"] = "rbxassetid://10734950553",
	["lucide-sheet"] = "rbxassetid://10734951038",
	["lucide-shield"] = "rbxassetid://10734951847",
	["lucide-shield-alert"] = "rbxassetid://10734951173",
	["lucide-shield-check"] = "rbxassetid://10734951367",
	["lucide-shield-close"] = "rbxassetid://10734951535",
	["lucide-shield-off"] = "rbxassetid://10734951684",
	["lucide-shirt"] = "rbxassetid://10734952036",
	["lucide-shopping-bag"] = "rbxassetid://10734952273",
	["lucide-shopping-cart"] = "rbxassetid://10734952479",
	["lucide-shovel"] = "rbxassetid://10734952773",
	["lucide-shower-head"] = "rbxassetid://10734952942",
	["lucide-shrink"] = "rbxassetid://10734953073",
	["lucide-shrub"] = "rbxassetid://10734953241",
	["lucide-shuffle"] = "rbxassetid://10734953451",
	["lucide-sidebar"] = "rbxassetid://10734954301",
	["lucide-sidebar-close"] = "rbxassetid://10734953715",
	["lucide-sidebar-open"] = "rbxassetid://10734954000",
	["lucide-sigma"] = "rbxassetid://10734954538",
	["lucide-signal"] = "rbxassetid://10734961133",
	["lucide-signal-high"] = "rbxassetid://10734954807",
	["lucide-signal-low"] = "rbxassetid://10734955080",
	["lucide-signal-medium"] = "rbxassetid://10734955336",
	["lucide-signal-zero"] = "rbxassetid://10734960878",
	["lucide-siren"] = "rbxassetid://10734961284",
	["lucide-skip-back"] = "rbxassetid://10734961526",
	["lucide-skip-forward"] = "rbxassetid://10734961809",
	["lucide-skull"] = "rbxassetid://10734962068",
	["lucide-slack"] = "rbxassetid://10734962339",
	["lucide-slash"] = "rbxassetid://10734962600",
	["lucide-slice"] = "rbxassetid://10734963024",
	["lucide-sliders"] = "rbxassetid://10734963400",
	["lucide-sliders-horizontal"] = "rbxassetid://10734963191",
	["lucide-smartphone"] = "rbxassetid://10734963940",
	["lucide-smartphone-charging"] = "rbxassetid://10734963671",
	["lucide-smile"] = "rbxassetid://10734964441",
	["lucide-smile-plus"] = "rbxassetid://10734964188",
	["lucide-snowflake"] = "rbxassetid://10734964600",
	["lucide-sofa"] = "rbxassetid://10734964852",
	["lucide-sort-asc"] = "rbxassetid://10734965115",
	["lucide-sort-desc"] = "rbxassetid://10734965287",
	["lucide-speaker"] = "rbxassetid://10734965419",
	["lucide-sprout"] = "rbxassetid://10734965572",
	["lucide-square"] = "rbxassetid://10734965702",
	["lucide-star"] = "rbxassetid://10734966248",
	["lucide-star-half"] = "rbxassetid://10734965897",
	["lucide-star-off"] = "rbxassetid://10734966097",
	["lucide-stethoscope"] = "rbxassetid://10734966384",
	["lucide-sticker"] = "rbxassetid://10734972234",
	["lucide-sticky-note"] = "rbxassetid://10734972463",
	["lucide-stop-circle"] = "rbxassetid://10734972621",
	["lucide-stretch-horizontal"] = "rbxassetid://10734972862",
	["lucide-stretch-vertical"] = "rbxassetid://10734973130",
	["lucide-strikethrough"] = "rbxassetid://10734973290",
	["lucide-subscript"] = "rbxassetid://10734973457",
	["lucide-sun"] = "rbxassetid://10734974297",
	["lucide-sun-dim"] = "rbxassetid://10734973645",
	["lucide-sun-medium"] = "rbxassetid://10734973778",
	["lucide-sun-moon"] = "rbxassetid://10734973999",
	["lucide-sun-snow"] = "rbxassetid://10734974130",
	["lucide-sunrise"] = "rbxassetid://10734974522",
	["lucide-sunset"] = "rbxassetid://10734974689",
	["lucide-superscript"] = "rbxassetid://10734974850",
	["lucide-swiss-franc"] = "rbxassetid://10734975024",
	["lucide-switch-camera"] = "rbxassetid://10734975214",
	["lucide-sword"] = "rbxassetid://10734975486",
	["lucide-swords"] = "rbxassetid://10734975692",
	["lucide-syringe"] = "rbxassetid://10734975932",
	["lucide-table"] = "rbxassetid://10734976230",
	["lucide-table-2"] = "rbxassetid://10734976097",
	["lucide-tablet"] = "rbxassetid://10734976394",
	["lucide-tag"] = "rbxassetid://10734976528",
	["lucide-tags"] = "rbxassetid://10734976739",
	["lucide-target"] = "rbxassetid://10734977012",
	["lucide-tent"] = "rbxassetid://10734981750",
	["lucide-terminal"] = "rbxassetid://10734982144",
	["lucide-terminal-square"] = "rbxassetid://10734981995",
	["lucide-text-cursor"] = "rbxassetid://10734982395",
	["lucide-text-cursor-input"] = "rbxassetid://10734982297",
	["lucide-thermometer"] = "rbxassetid://10734983134",
	["lucide-thermometer-snowflake"] = "rbxassetid://10734982571",
	["lucide-thermometer-sun"] = "rbxassetid://10734982771",
	["lucide-thumbs-down"] = "rbxassetid://10734983359",
	["lucide-thumbs-up"] = "rbxassetid://10734983629",
	["lucide-ticket"] = "rbxassetid://10734983868",
	["lucide-timer"] = "rbxassetid://10734984606",
	["lucide-timer-off"] = "rbxassetid://10734984138",
	["lucide-timer-reset"] = "rbxassetid://10734984355",
	["lucide-toggle-left"] = "rbxassetid://10734984834",
	["lucide-toggle-right"] = "rbxassetid://10734985040",
	["lucide-tornado"] = "rbxassetid://10734985247",
	["lucide-toy-brick"] = "rbxassetid://10747361919",
	["lucide-train"] = "rbxassetid://10747362105",
	["lucide-trash"] = "rbxassetid://10747362393",
	["lucide-trash-2"] = "rbxassetid://10747362241",
	["lucide-tree-deciduous"] = "rbxassetid://10747362534",
	["lucide-tree-pine"] = "rbxassetid://10747362748",
	["lucide-trees"] = "rbxassetid://10747363016",
	["lucide-trending-down"] = "rbxassetid://10747363205",
	["lucide-trending-up"] = "rbxassetid://10747363465",
	["lucide-triangle"] = "rbxassetid://10747363621",
	["lucide-trophy"] = "rbxassetid://10747363809",
	["lucide-truck"] = "rbxassetid://10747364031",
	["lucide-tv"] = "rbxassetid://10747364593",
	["lucide-tv-2"] = "rbxassetid://10747364302",
	["lucide-type"] = "rbxassetid://10747364761",
	["lucide-umbrella"] = "rbxassetid://10747364971",
	["lucide-underline"] = "rbxassetid://10747365191",
	["lucide-undo"] = "rbxassetid://10747365484",
	["lucide-undo-2"] = "rbxassetid://10747365359",
	["lucide-unlink"] = "rbxassetid://10747365771",
	["lucide-unlink-2"] = "rbxassetid://10747397871",
	["lucide-unlock"] = "rbxassetid://10747366027",
	["lucide-upload"] = "rbxassetid://10747366434",
	["lucide-upload-cloud"] = "rbxassetid://10747366266",
	["lucide-usb"] = "rbxassetid://10747366606",
	["lucide-user"] = "rbxassetid://10747373176",
	["lucide-user-check"] = "rbxassetid://10747371901",
	["lucide-user-cog"] = "rbxassetid://10747372167",
	["lucide-user-minus"] = "rbxassetid://10747372346",
	["lucide-user-plus"] = "rbxassetid://10747372702",
	["lucide-user-x"] = "rbxassetid://10747372992",
	["lucide-users"] = "rbxassetid://10747373426",
	["lucide-utensils"] = "rbxassetid://10747373821",
	["lucide-utensils-crossed"] = "rbxassetid://10747373629",
	["lucide-venetian-mask"] = "rbxassetid://10747374003",
	["lucide-verified"] = "rbxassetid://10747374131",
	["lucide-vibrate"] = "rbxassetid://10747374489",
	["lucide-vibrate-off"] = "rbxassetid://10747374269",
	["lucide-video"] = "rbxassetid://10747374938",
	["lucide-video-off"] = "rbxassetid://10747374721",
	["lucide-view"] = "rbxassetid://10747375132",
	["lucide-voicemail"] = "rbxassetid://10747375281",
	["lucide-volume"] = "rbxassetid://10747376008",
	["lucide-volume-1"] = "rbxassetid://10747375450",
	["lucide-volume-2"] = "rbxassetid://10747375679",
	["lucide-volume-x"] = "rbxassetid://10747375880",
	["lucide-wheat"] = "rbxassetid://80877624162595",
	["lucide-wallet"] = "rbxassetid://10747376205",
	["lucide-wand"] = "rbxassetid://10747376565",
	["lucide-wand-2"] = "rbxassetid://10747376349",
	["lucide-watch"] = "rbxassetid://10747376722",
	["lucide-waves"] = "rbxassetid://10747376931",
	["lucide-webcam"] = "rbxassetid://10747381992",
	["lucide-wifi"] = "rbxassetid://10747382504",
	["lucide-wifi-off"] = "rbxassetid://10747382268",
	["lucide-wind"] = "rbxassetid://10747382750",
	["lucide-wrap-text"] = "rbxassetid://10747383065",
	["lucide-wrench"] = "rbxassetid://10747383470",
	["lucide-x"] = "rbxassetid://10747384394",
	["lucide-x-circle"] = "rbxassetid://10747383819",
	["lucide-x-octagon"] = "rbxassetid://10747384037",
	["lucide-x-square"] = "rbxassetid://10747384217",
	["lucide-zoom-in"] = "rbxassetid://10747384552",
	["lucide-zoom-out"] = "rbxassetid://10747384679",
	["lucide-cat"] = "rbxassetid://16935650691",
	["lucide-message-circle-question"] = "rbxassetid://16970049192",
	["lucide-webhook"] = "rbxassetid://17320556264",
	["lucide-dumbbell"] = "rbxassetid://18273453053"
}

DarkUI.IconAliases = {
	Home = "home",
	Settings = "settings",
	Setting = "settings",
	Search = "search",
	Webhook = "webhook",
	Macro = "terminal",
	Combat = "swords",
	Render = "eye",
	Movement = "move",
	Utility = "wrench",
	World = "globe-2",
	Farm = "sprout",
	AutoFarm = "sprout",
	Shop = "shopping-cart",
	Teleport = "navigation",
	Config = "save",
}

function DarkUI:GetIcon(name)
	if name == nil then
		return nil
	end

	local text = tostring(name)
	text = string.gsub(text, "^%s+", "")
	text = string.gsub(text, "%s+$", "")
	if text == "" then
		return nil
	end

	local directAsset = resolveContentId(text)
	if directAsset and directAsset ~= text then
		return directAsset
	end

	local alias = DarkUI.IconAliases[text] or DarkUI.IconAliases[string.gsub(text, "%s+", "")]
	if alias then
		text = alias
	end

	local lowered = string.lower(text)
	local compact = string.gsub(lowered, "%s+", "-")
	local candidates = {
		text,
		lowered,
		compact,
		"lucide-" .. text,
		"lucide-" .. lowered,
		"lucide-" .. compact,
	}

	for _, key in ipairs(candidates) do
		local icon = DarkUI.Icons[key]
		if icon then
			return icon
		end
	end

	return directAsset
end

local function resolveIcon(value)
	return DarkUI:GetIcon(value) or resolveContentId(value)
end

DarkUI.Fonts = {
	Title = getFont("GothamMedium", getFont("GothamSemibold", getFont("GothamBold", Enum.Font.SourceSansBold))),
	Bold = getFont("GothamMedium", getFont("GothamSemibold", getFont("GothamBold", Enum.Font.SourceSansBold))),
	Body = getFont("Gotham", getFont("SourceSans", Enum.Font.SourceSans)),
}
DarkUI.FontFaces = {
	WindowTitle = getFontFace("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
}
DarkUI.TextScale = 1
DarkUI.TextStrokeColor = Color3.fromRGB(27, 30, 35)
DarkUI.TextStrokeTransparency = 1

DarkUI.ThemePresets = {
	Dark = {
		Background = Color3.fromRGB(18, 18, 23),
		Surface = Color3.fromRGB(22, 22, 28),
		Panel = Color3.fromRGB(34, 34, 42),
		PanelLight = Color3.fromRGB(43, 43, 52),
		Tab = Color3.fromRGB(25, 35, 42),
		TabActive = Color3.fromRGB(29, 42, 50),
		Stroke = Color3.fromRGB(44, 44, 54),
		Text = Color3.fromRGB(211, 211, 220),
		Muted = Color3.fromRGB(132, 132, 145),
		Accent = Color3.fromRGB(107, 211, 255),
		Success = Color3.fromRGB(56, 219, 142),
		Warning = Color3.fromRGB(250, 204, 21),
		Error = Color3.fromRGB(248, 93, 106),
	},
	Midnight = {
		Background = Color3.fromRGB(6, 8, 16),
		Surface = Color3.fromRGB(11, 15, 27),
		Panel = Color3.fromRGB(16, 22, 36),
		PanelLight = Color3.fromRGB(24, 32, 50),
		Tab = Color3.fromRGB(10, 13, 24),
		TabActive = Color3.fromRGB(17, 25, 42),
		Stroke = Color3.fromRGB(34, 44, 66),
		Text = Color3.fromRGB(235, 240, 248),
		Muted = Color3.fromRGB(135, 147, 166),
		Accent = Color3.fromRGB(96, 165, 250),
		Success = Color3.fromRGB(52, 211, 153),
		Warning = Color3.fromRGB(251, 191, 36),
		Error = Color3.fromRGB(251, 113, 133),
	},
	Emerald = {
		Background = Color3.fromRGB(7, 12, 11),
		Surface = Color3.fromRGB(12, 19, 18),
		Panel = Color3.fromRGB(17, 26, 25),
		PanelLight = Color3.fromRGB(24, 38, 36),
		Tab = Color3.fromRGB(10, 16, 15),
		TabActive = Color3.fromRGB(18, 31, 29),
		Stroke = Color3.fromRGB(35, 57, 52),
		Text = Color3.fromRGB(232, 241, 237),
		Muted = Color3.fromRGB(129, 154, 146),
		Accent = Color3.fromRGB(52, 211, 153),
		Success = Color3.fromRGB(74, 222, 128),
		Warning = Color3.fromRGB(250, 204, 21),
		Error = Color3.fromRGB(248, 113, 113),
	},
	Crimson = {
		Background = Color3.fromRGB(13, 8, 10),
		Surface = Color3.fromRGB(20, 13, 16),
		Panel = Color3.fromRGB(29, 18, 23),
		PanelLight = Color3.fromRGB(41, 25, 31),
		Tab = Color3.fromRGB(16, 10, 13),
		TabActive = Color3.fromRGB(34, 19, 25),
		Stroke = Color3.fromRGB(60, 35, 44),
		Text = Color3.fromRGB(245, 235, 239),
		Muted = Color3.fromRGB(164, 132, 143),
		Accent = Color3.fromRGB(248, 93, 106),
		Success = Color3.fromRGB(74, 222, 128),
		Warning = Color3.fromRGB(250, 204, 21),
		Error = Color3.fromRGB(248, 113, 113),
	},
	Violet = {
		Background = Color3.fromRGB(11, 9, 17),
		Surface = Color3.fromRGB(17, 14, 25),
		Panel = Color3.fromRGB(24, 20, 36),
		PanelLight = Color3.fromRGB(34, 28, 50),
		Tab = Color3.fromRGB(14, 12, 22),
		TabActive = Color3.fromRGB(29, 24, 44),
		Stroke = Color3.fromRGB(51, 43, 73),
		Text = Color3.fromRGB(240, 236, 248),
		Muted = Color3.fromRGB(148, 136, 166),
		Accent = Color3.fromRGB(168, 85, 247),
		Success = Color3.fromRGB(74, 222, 128),
		Warning = Color3.fromRGB(250, 204, 21),
		Error = Color3.fromRGB(248, 113, 113),
	},
}

DarkUI.Theme = DarkUI.ThemePresets.Dark

local function copyTable(source)
	local nextTable = {}

	for key, value in pairs(source or {}) do
		nextTable[key] = value
	end

	return nextTable
end

local function make(className, props, children)
	local instance = Instance.new(className)

	for key, value in pairs(props or {}) do
		instance[key] = value
	end

	for _, child in ipairs(children or {}) do
		child.Parent = instance
	end

	return instance
end

local function corner(radius)
	return make("UICorner", {
		CornerRadius = UDim.new(0, radius),
	})
end

local function stroke(color, transparency, thickness)
	return make("UIStroke", {
		Color = color,
		Transparency = transparency or 0,
		Thickness = thickness or 1,
	})
end

local function tween(instance, props, duration)
	local tweenInfo = TweenInfo.new(duration or 0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local activeTween = TweenService:Create(instance, tweenInfo, props)
	activeTween:Play()
	return activeTween
end

local function safe(callback, ...)
	if not callback then
		return
	end

	local args = { ... }
	task.spawn(function()
		pcall(function()
			callback(table.unpack(args))
		end)
	end)
end

local function normalizeColor(value, fallback)
	if typeof(value) == "Color3" then
		return value
	end

	if type(value) == "table" then
		if value.R and value.G and value.B then
			return Color3.fromRGB(value.R, value.G, value.B)
		end

		if value[1] and value[2] and value[3] then
			return Color3.fromRGB(value[1], value[2], value[3])
		end
	end

	return fallback
end

local function colorToTable(color)
	return {
		R = math.floor(color.R * 255 + 0.5),
		G = math.floor(color.G * 255 + 0.5),
		B = math.floor(color.B * 255 + 0.5),
	}
end

function DarkUI:Text(props)
	props = props or {}

	local label = make("TextLabel", {
		BackgroundTransparency = 1,
		Font = props.Font or self.Fonts.Body,
		LayoutOrder = props.LayoutOrder or 0,
		Position = props.Position or UDim2.new(),
		RichText = props.RichText or false,
		Size = props.Size or UDim2.new(1, 0, 1, 0),
		Text = props.Text or "",
		TextColor3 = props.TextColor3 or self.Theme.Text,
		TextSize = props.TextSize or 12,
		TextStrokeColor3 = props.TextStrokeColor3 or self.TextStrokeColor,
		TextStrokeTransparency = props.TextStrokeTransparency or self.TextStrokeTransparency,
		TextTransparency = props.TextTransparency or 0,
		TextWrapped = props.TextWrapped or false,
		TextXAlignment = props.TextXAlignment or Enum.TextXAlignment.Left,
		TextYAlignment = props.TextYAlignment or Enum.TextYAlignment.Center,
		Parent = props.Parent,
	})

	if props.FontFace then
		pcall(function()
			label.FontFace = props.FontFace
		end)
	end

	return label
end

function DarkUI:CreateWindow(config)
	config = config or {}

	local themeName = config.Theme or "Dark"
	local theme = copyTable(DarkUI.ThemePresets[themeName] or DarkUI.ThemePresets.Dark)
	if typeof(config.Accent) == "Color3" then
		theme.Accent = config.Accent
	end

	local guiName = config.Name or "VxiziUILibrary"
	local parent = config.Parent or playerGui

	if config.RemoveOld ~= false and parent then
		local oldGui = parent:FindFirstChild(guiName)
		if oldGui then
			oldGui:Destroy()
		end
	end

	local window = {
		Theme = theme,
		ThemeName = themeName,
		TextScale = config.TextScale or DarkUI.TextScale,
		ConfigFolder = config.ConfigFolder or "VxiziUI",
		ConfigName = config.ConfigName or "default.json",
		ConfigValues = {},
		Connections = {},
		Renderers = {},
		Pages = {},
		TabButtons = {},
		TabOrder = {},
		SearchItems = {},
		Sections = {},
		SelectedTab = nil,
		FooterButtons = {},
		FooterRole = "Home",
		FooterHomeTab = nil,
		FooterSettingsTab = nil,
		Destroyed = false,
	}

	local screenGui = make("ScreenGui", {
		Name = guiName,
		DisplayOrder = config.DisplayOrder or 100,
		IgnoreGuiInset = true,
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Global,
		Parent = parent,
	})

	local function connect(signal, callback)
		local connection = signal:Connect(callback)
		table.insert(window.Connections, connection)
		return connection
	end

	function window:Connect(signal, callback)
		return connect(signal, callback)
	end

	local function styledBackground(instance, key)
		instance:SetAttribute("DarkUIBackground", key)
		instance.BackgroundColor3 = window.Theme[key]
		return instance
	end

	local function styledText(instance, key)
		instance:SetAttribute("DarkUIText", key)
		instance.TextColor3 = window.Theme[key]

		if instance:IsA("TextLabel") or instance:IsA("TextButton") or instance:IsA("TextBox") then
			if not instance:GetAttribute("DarkUITextScaled") then
				instance.TextSize = math.floor((instance.TextSize * window.TextScale) + 0.5)
				instance:SetAttribute("DarkUITextScaled", true)
			end

			instance.TextStrokeColor3 = DarkUI.TextStrokeColor
			instance.TextStrokeTransparency = 1
		end

		return instance
	end

	local function styledStroke(instance, key)
		instance:SetAttribute("DarkUIStroke", key)
		instance.Color = window.Theme[key]
		return instance
	end

	local function registerRenderer(callback)
		table.insert(window.Renderers, callback)
		callback()
	end

	local function getScale(guiObject)
		local scale = guiObject:FindFirstChild("DarkUIScale")
		if not scale then
			scale = make("UIScale", {
				Name = "DarkUIScale",
				Scale = 1,
				Parent = guiObject,
			})
		end

		return scale
	end

	local function pop(guiObject, pressedScale, returnScale)
		local scale = getScale(guiObject)
		tween(scale, {
			Scale = pressedScale or 0.96,
		}, 0.06)
		task.delay(0.07, function()
			if scale.Parent then
				tween(scale, {
					Scale = returnScale or 1,
				}, 0.13)
			end
		end)
	end

	local function attachPress(guiObject, pressedScale)
		connect(guiObject.InputBegan, function(input)
			if guiObject:GetAttribute("Disabled") then
				return
			end

			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				pop(guiObject, pressedScale)
			end
		end)
	end

	local function attachHover(guiObject, normalKey, hoverKey, hoverScale)
		connect(guiObject.MouseEnter, function()
			if guiObject:GetAttribute("Disabled") then
				return
			end

			if normalKey and hoverKey then
				tween(guiObject, {
					BackgroundColor3 = window.Theme[hoverKey],
				}, 0.12)
			end

			if hoverScale then
				tween(getScale(guiObject), {
					Scale = hoverScale,
				}, 0.12)
			end
		end)

		connect(guiObject.MouseLeave, function()
			if normalKey then
				tween(guiObject, {
					BackgroundColor3 = window.Theme[normalKey],
				}, 0.12)
			end

			if hoverScale then
				tween(getScale(guiObject), {
					Scale = 1,
				}, 0.12)
			end
		end)
	end

	local headerHeight = 50
	local tabHeight = 44
	local searchHeight = config.Search == true and 36 or 0
	local showFooter = config.Footer == "legacy"
	local footerHeight = showFooter and 54 or 0
	local navWidth = config.NavWidth or 134
	local windowSize = config.Size or UDim2.fromOffset(480, 400)
	local collapsedSize = UDim2.fromOffset(windowSize.X.Offset, headerHeight)
	local windowPosition = config.Position or UDim2.fromScale(0.5, 0.5)
	local windowIcon = resolveIcon(config.Icon)
	local minWindowSize = config.MinSize or Vector2.new(430, 320)
	local resizable = config.Resizable ~= false
	local gripSize = math.max(30, tonumber(config.ResizeGripSize) or 44)

	local function glowSize(size)
		return UDim2.new(size.X.Scale, size.X.Offset + 12, size.Y.Scale, size.Y.Offset + 12)
	end

	local shadow = make("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = Color3.fromRGB(0, 0, 0),
		BackgroundTransparency = 0.68,
		BorderSizePixel = 0,
		Position = UDim2.new(windowPosition.X.Scale, windowPosition.X.Offset + 6, windowPosition.Y.Scale, windowPosition.Y.Offset + 6),
		Size = windowSize,
		Parent = screenGui,
	}, {
		corner(7),
	})

	local glowStroke = stroke(theme.Accent, 0.72, 1)
	glowStroke.Name = "DarkUIGlowStroke"
	local glow = make("Frame", {
		Name = "DarkUIGlow",
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = theme.Accent,
		BackgroundTransparency = 0.965,
		BorderSizePixel = 0,
		Position = windowPosition,
		Size = glowSize(windowSize),
		Parent = screenGui,
	}, {
		corner(8),
		glowStroke,
	})

	local root = make("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = theme.Background,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		Position = windowPosition,
		Size = windowSize,
		Parent = screenGui,
	}, {
		corner(7),
		stroke(theme.Stroke, 0.35, 1),
	})
	root:SetAttribute("DarkUIBackground", "Background")
	root.UIStroke:SetAttribute("DarkUIStroke", "Stroke")

	local rootScale = make("UIScale", {
		Scale = 0.96,
		Parent = root,
	})

	tween(rootScale, { Scale = 1 }, 0.25)

	local header = styledBackground(make("Frame", {
		Name = "Header",
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, headerHeight),
		ZIndex = 50,
		Parent = root,
	}, {
		corner(7),
	}), "Background")

	styledBackground(make("Frame", {
		BorderSizePixel = 0,
		Position = UDim2.new(0, 0, 1, -7),
		Size = UDim2.new(1, 0, 0, 7),
		ZIndex = 50,
		Parent = header,
	}), "Background")

	make("Frame", {
		Name = "DarkUIAccent",
		BorderSizePixel = 0,
		BackgroundColor3 = theme.Accent,
		Position = UDim2.new(0, 0, 1, -1),
		Size = UDim2.new(1, 0, 0, 1),
		ZIndex = 51,
		Parent = header,
	})

	if windowIcon then
		make("ImageLabel", {
			BackgroundTransparency = 1,
			Image = windowIcon,
			Position = UDim2.fromOffset(16, 14),
			ScaleType = Enum.ScaleType.Fit,
			Size = UDim2.fromOffset(20, 20),
			ZIndex = 52,
			Parent = header,
		})
	end

	local titleOffset = windowIcon and 42 or 16
	local title = styledText(DarkUI:Text({
		Font = DarkUI.Fonts.Title,
		FontFace = config.TitleFontFace or DarkUI.FontFaces.WindowTitle,
		Parent = header,
		Position = UDim2.fromOffset(titleOffset, 8),
		RichText = true,
		Size = UDim2.new(1, -150 - titleOffset, 0, 19),
		Text = config.Title or config.Name or "Vxizi Hub",
		TextSize = 14,
	}), "Text")
	title.ZIndex = 52

	local subtitle = styledText(DarkUI:Text({
		Font = DarkUI.Fonts.Body,
		Parent = header,
		Position = UDim2.fromOffset(titleOffset, 27),
		Size = UDim2.new(1, -150 - titleOffset, 0, 14),
		Text = config.Subtitle or config.SubTitle or config.Description or "clean dark interface",
		TextSize = 10,
	}), "Muted")
	subtitle.ZIndex = 52

	local statusPill = styledBackground(make("TextLabel", {
		AnchorPoint = Vector2.new(1, 0.5),
		BorderSizePixel = 0,
		Font = DarkUI.Fonts.Bold,
		Position = UDim2.new(1, -96, 0.5, 0),
		Size = UDim2.fromOffset(78, 26),
		Text = "WORKING",
		TextSize = 10,
		Visible = config.Status == true,
		ZIndex = 52,
		Parent = header,
	}, {
		corner(6),
	}), "Panel")
	styledText(statusPill, "Accent")

	local minimizeButton = styledBackground(make("TextButton", {
		AnchorPoint = Vector2.new(1, 0.5),
		AutoButtonColor = false,
		BorderSizePixel = 0,
		Font = DarkUI.Fonts.Bold,
		Position = UDim2.new(1, -48, 0.5, 0),
		Size = UDim2.fromOffset(26, 26),
		Text = "-",
		TextSize = 14,
		ZIndex = 52,
		Parent = header,
	}, {
		corner(6),
	}), "PanelLight")
	styledText(minimizeButton, "Text")
	attachHover(minimizeButton, "PanelLight", "Panel", 1.04)
	attachPress(minimizeButton, 0.88)

	local closeButton = styledBackground(make("TextButton", {
		AnchorPoint = Vector2.new(1, 0.5),
		AutoButtonColor = false,
		BorderSizePixel = 0,
		Font = DarkUI.Fonts.Bold,
		Position = UDim2.new(1, -16, 0.5, 0),
		Size = UDim2.fromOffset(26, 26),
		Text = "x",
		TextSize = 13,
		ZIndex = 52,
		Parent = header,
	}, {
		corner(6),
	}), "PanelLight")
	styledText(closeButton, "Text")
	attachHover(closeButton, "PanelLight", "Panel", 1.04)
	attachPress(closeButton, 0.88)

	local body = make("Frame", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(0, headerHeight),
		Size = UDim2.new(1, 0, 1, -headerHeight),
		ZIndex = 1,
		Parent = root,
	})

	local resizeHandle = make("TextButton", {
		AnchorPoint = Vector2.new(1, 1),
		Active = true,
		AutoButtonColor = false,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.new(1, -2, 1, -2),
		Size = UDim2.fromOffset(gripSize, gripSize),
		Text = "",
		ZIndex = 220,
		Visible = resizable,
		Parent = root,
	})

	local gripVisual = make("Frame", {
		AnchorPoint = Vector2.new(1, 1),
		BackgroundTransparency = 1,
		Position = UDim2.new(1, -2, 1, -2),
		Size = UDim2.fromOffset(26, 26),
		ZIndex = 221,
		Parent = resizeHandle,
	})

	for index = 0, 2 do
		styledBackground(make("Frame", {
			AnchorPoint = Vector2.new(1, 1),
			BackgroundTransparency = 0.26 + (index * 0.16),
			BorderSizePixel = 0,
			Position = UDim2.new(1, -3 - (index * 6), 1, -3),
			Rotation = -45,
			Size = UDim2.fromOffset(13 + (index * 5), 2),
			ZIndex = 222,
			Parent = gripVisual,
		}, {
			corner(999),
		}), "Accent")
	end

	local navPanel = styledBackground(make("Frame", {
		BorderSizePixel = 0,
		ClipsDescendants = true,
		Size = UDim2.new(0, navWidth, 1, -footerHeight),
		Parent = body,
	}, {
		corner(0),
	}), "Background")

	local navBrandText = tostring(config.NavBrand or "")
	local hasNavBrand = navBrandText ~= ""
	local navHeaderHeight = hasNavBrand and 48 or 0
	local navHeader = make("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, navHeaderHeight),
		Parent = navPanel,
	})

	local navHeaderOffset = 12
	if hasNavBrand and windowIcon then
		make("ImageLabel", {
			BackgroundTransparency = 1,
			Image = windowIcon,
			Position = UDim2.fromOffset(10, 9),
			ScaleType = Enum.ScaleType.Fit,
			Size = UDim2.fromOffset(24, 24),
			Parent = navHeader,
		})
		navHeaderOffset = 38
	end

	if hasNavBrand then
		styledText(DarkUI:Text({
			Font = DarkUI.Fonts.Title,
			Parent = navHeader,
			Position = UDim2.fromOffset(navHeaderOffset, 9),
			Size = UDim2.new(1, -navHeaderOffset - 10, 0, 24),
			Text = navBrandText,
			TextSize = 15,
			TextXAlignment = Enum.TextXAlignment.Left,
		}), "Text")
	end

	if hasNavBrand then
		make("Frame", {
			Name = "DarkUIAccent",
			BorderSizePixel = 0,
			BackgroundColor3 = theme.Accent,
			Position = UDim2.fromOffset(0, navHeaderHeight),
			Size = UDim2.new(1, 0, 0, 1),
			Parent = navPanel,
		})
	end

	local navTabsTopOffset = hasNavBrand and 6 or 0
	local navTabsStartY = navHeaderHeight + navTabsTopOffset
	local tabs = make("ScrollingFrame", {
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		CanvasSize = UDim2.new(),
		ScrollBarImageColor3 = theme.Accent,
		ScrollBarImageTransparency = 0.42,
		ScrollBarThickness = 2,
		Position = UDim2.fromOffset(0, navTabsStartY),
		Size = UDim2.new(1, 0, 1, -(navTabsStartY + 6)),
		Parent = navPanel,
	}, {
		make("UIListLayout", {
			FillDirection = Enum.FillDirection.Vertical,
			Padding = UDim.new(0, 4),
			SortOrder = Enum.SortOrder.LayoutOrder,
			HorizontalAlignment = Enum.HorizontalAlignment.Left,
		}),
		make("UIPadding", {
			PaddingLeft = UDim.new(0, 12),
			PaddingRight = UDim.new(0, 10),
			PaddingTop = UDim.new(0, 6),
			PaddingBottom = UDim.new(0, 4),
		}),
	})

	local contentPanel = make("Frame", {
		BackgroundTransparency = 1,
		Position = UDim2.new(0, navWidth + 12, 0, 10),
		Size = UDim2.new(1, -navWidth - 24, 1, -footerHeight - 18),
		Parent = body,
	})

	local searchBox
	local searchClear
	if config.Search == true then
		local searchStroke = styledStroke(stroke(theme.Stroke, 0.35, 1), "Stroke")
		local searchBar = styledBackground(make("Frame", {
			BorderSizePixel = 0,
			Position = UDim2.fromOffset(0, 0),
			Size = UDim2.new(1, 0, 0, 36),
			Parent = contentPanel,
		}, {
			corner(7),
			searchStroke,
		}), "Panel")

		styledText(DarkUI:Text({
			Font = DarkUI.Fonts.Bold,
			Parent = searchBar,
			Position = UDim2.fromOffset(13, 0),
			Size = UDim2.fromOffset(54, 36),
			Text = "Search",
			TextSize = 13,
		}), "Muted")

		searchBox = make("TextBox", {
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ClearTextOnFocus = false,
			Font = DarkUI.Fonts.Bold,
			PlaceholderColor3 = theme.Muted,
			PlaceholderText = "Find a module...",
			Position = UDim2.fromOffset(70, 0),
			Size = UDim2.new(1, -106, 1, 0),
			Text = "",
			TextColor3 = theme.Text,
			TextSize = 15,
			TextXAlignment = Enum.TextXAlignment.Left,
			Parent = searchBar,
		})
		styledText(searchBox, "Text")

		searchClear = styledBackground(make("TextButton", {
			AnchorPoint = Vector2.new(1, 0.5),
			AutoButtonColor = false,
			BorderSizePixel = 0,
			Font = DarkUI.Fonts.Bold,
			Position = UDim2.new(1, -8, 0.5, 0),
			Size = UDim2.fromOffset(24, 24),
			Text = "x",
			TextSize = 12,
			Visible = false,
			Parent = searchBar,
		}, {
			corner(5),
		}), "Surface")
		styledText(searchClear, "Muted")
		attachHover(searchClear, "Surface", "PanelLight", 1.05)
		attachPress(searchClear, 0.86)

		connect(searchBox.Focused, function()
			tween(searchStroke, {
				Color = window.Theme.Accent,
				Transparency = 0.05,
			}, 0.12)
		end)

		connect(searchBox.FocusLost, function()
			tween(searchStroke, {
				Color = window.Theme.Stroke,
				Transparency = 0.35,
			}, 0.12)
		end)
	end

	local contentTopOffset = (config.Search == true) and (searchHeight + 6) or 0
	local pagesHolder = make("Frame", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(0, contentTopOffset),
		Size = UDim2.new(1, 0, 1, -contentTopOffset),
		Parent = contentPanel,
	})

	local footer = nil
	local footerButtons = {}
	local footerActiveRole = "Home"

	local function isSettingsTabName(tabName)
		local lowered = string.lower(tostring(tabName or ""))
		return string.find(lowered, "setting", 1, true) ~= nil
			or string.find(lowered, "config", 1, true) ~= nil
	end

	local function resolveHomeTabName()
		if window.FooterHomeTab and window.Pages[window.FooterHomeTab] then
			return window.FooterHomeTab
		end

		if config.HomeTabName and window.Pages[config.HomeTabName] then
			return config.HomeTabName
		end

		return window.TabOrder[1]
	end

	local function resolveSettingsTabName()
		if window.FooterSettingsTab and window.Pages[window.FooterSettingsTab] then
			return window.FooterSettingsTab
		end

		if config.SettingsTabName and window.Pages[config.SettingsTabName] then
			return config.SettingsTabName
		end

		for _, tabName in ipairs(window.TabOrder) do
			if isSettingsTabName(tabName) then
				return tabName
			end
		end

		return nil
	end

	local function footerRoleForTab(tabName)
		local settingsTabName = resolveSettingsTabName()
		if settingsTabName and tabName == settingsTabName then
			return "Setting"
		end

		return "Home"
	end

	local function paintFooterIcon(parts, color, animated)
		for _, part in ipairs(parts or {}) do
			if part and part.Parent then
				if animated then
					tween(part, {
						BackgroundColor3 = color,
					}, 0.14)
				else
					part.BackgroundColor3 = color
				end
			end
		end
	end

	local function setFooterActive(role, animated)
		footerActiveRole = role or "Home"
		window.FooterRole = footerActiveRole

		for buttonRole, refs in pairs(footerButtons) do
			local active = buttonRole == footerActiveRole
			local targetBackground = window.Theme[active and "Panel" or "Surface"]
			local targetIconColor = window.Theme[active and "Accent" or "Text"]
			local targetTextColor = window.Theme[active and "Text" or "Muted"]
			local strokeObject = refs.Button:FindFirstChildOfClass("UIStroke")

			refs.Button:SetAttribute("DarkUIBackground", active and "Panel" or "Surface")
			refs.Label:SetAttribute("DarkUIText", active and "Text" or "Muted")
			refs.Button:SetAttribute("DarkUIFooterActive", active)

			if animated then
				tween(refs.Button, {
					BackgroundColor3 = targetBackground,
				}, 0.14)
				paintFooterIcon(refs.IconParts, targetIconColor, true)
				tween(refs.Label, {
					TextColor3 = targetTextColor,
				}, 0.14)
				if strokeObject then
					tween(strokeObject, {
						Transparency = active and 0.16 or 0.4,
					}, 0.14)
				end
			else
				refs.Button.BackgroundColor3 = targetBackground
				paintFooterIcon(refs.IconParts, targetIconColor, false)
				refs.Label.TextColor3 = targetTextColor
				if strokeObject then
					strokeObject.Transparency = active and 0.16 or 0.4
				end
			end
		end
	end

	if footerHeight > 0 then
		footer = styledBackground(make("Frame", {
			AnchorPoint = Vector2.new(0, 1),
			BorderSizePixel = 0,
			ClipsDescendants = true,
			Position = UDim2.new(0, 0, 1, 0),
			Size = UDim2.new(1, 0, 0, footerHeight),
			Parent = body,
		}, {
			corner(10),
		}), "Surface")

		make("Frame", {
			Name = "DarkUIAccent",
			BorderSizePixel = 0,
			BackgroundColor3 = theme.Accent,
			Size = UDim2.new(1, 0, 0, 1),
			Parent = footer,
		})

		local footerCenter = make("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromOffset(220, 44),
			Parent = footer,
		}, {
			make("UIListLayout", {
				FillDirection = Enum.FillDirection.Horizontal,
				Padding = UDim.new(0, 10),
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				VerticalAlignment = Enum.VerticalAlignment.Center,
			}),
		})

		local function createFooterButton(roleName, titleText, iconAssetId, active)
			local button = styledBackground(make("TextButton", {
				Name = "DarkUIFooterButton",
				AutoButtonColor = false,
				BorderSizePixel = 0,
				Size = UDim2.fromOffset(96, 38),
				Text = "",
				Parent = footerCenter,
			}, {
				corner(8),
				styledStroke(stroke(theme.Stroke, active and 0.16 or 0.4, 1), "Stroke"),
			}), active and "Panel" or "Surface")
			button:SetAttribute("DarkUIFooterRole", roleName)
			button:SetAttribute("DarkUIFooterActive", active)

			local footerIconHost = make("Frame", {
				Name = "DarkUIFooterIcon",
				BackgroundTransparency = 1,
				Position = UDim2.new(0.5, -8, 0, 4),
				Size = UDim2.fromOffset(16, 16),
				Parent = button,
			})

			local iconParts = {}
			local function iconPart(props, radius)
				props.BorderSizePixel = 0
				props.BackgroundColor3 = active and theme.Accent or theme.Text
				props.Parent = footerIconHost
				local part = make("Frame", props, radius and { corner(radius) } or nil)
				table.insert(iconParts, part)
				return part
			end

			if roleName == "Setting" then
				iconPart({
					Position = UDim2.fromOffset(6, 6),
					Size = UDim2.fromOffset(4, 4),
				}, 999)
				iconPart({ Position = UDim2.fromOffset(7, 1), Size = UDim2.fromOffset(2, 3) }, 1)
				iconPart({ Position = UDim2.fromOffset(7, 12), Size = UDim2.fromOffset(2, 3) }, 1)
				iconPart({ Position = UDim2.fromOffset(1, 7), Size = UDim2.fromOffset(3, 2) }, 1)
				iconPart({ Position = UDim2.fromOffset(12, 7), Size = UDim2.fromOffset(3, 2) }, 1)
				iconPart({ Position = UDim2.fromOffset(3, 3), Size = UDim2.fromOffset(2, 2) }, 1)
				iconPart({ Position = UDim2.fromOffset(11, 3), Size = UDim2.fromOffset(2, 2) }, 1)
				iconPart({ Position = UDim2.fromOffset(3, 11), Size = UDim2.fromOffset(2, 2) }, 1)
				iconPart({ Position = UDim2.fromOffset(11, 11), Size = UDim2.fromOffset(2, 2) }, 1)
			else
				iconPart({
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.fromOffset(6, 6),
					Size = UDim2.fromOffset(7, 2),
					Rotation = -45,
				}, 999)
				iconPart({
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.fromOffset(10, 6),
					Size = UDim2.fromOffset(7, 2),
					Rotation = 45,
				}, 999)
				iconPart({ Position = UDim2.fromOffset(3, 8), Size = UDim2.fromOffset(2, 6) }, 1)
				iconPart({ Position = UDim2.fromOffset(11, 8), Size = UDim2.fromOffset(2, 6) }, 1)
				iconPart({ Position = UDim2.fromOffset(3, 13), Size = UDim2.fromOffset(10, 2) }, 1)
				iconPart({ Position = UDim2.fromOffset(7, 10), Size = UDim2.fromOffset(2, 4) }, 1)
			end

			local footerLabel = styledText(DarkUI:Text({
				Font = DarkUI.Fonts.Bold,
				Parent = button,
				Position = UDim2.fromOffset(0, 19),
				Size = UDim2.new(1, 0, 0, 17),
				Text = titleText,
				TextSize = 12,
				TextXAlignment = Enum.TextXAlignment.Center,
			}), active and "Text" or "Muted")
			footerLabel.Name = "DarkUIFooterLabel"

			footerButtons[roleName] = {
				Button = button,
				IconParts = iconParts,
				Label = footerLabel,
			}
			window.FooterButtons[roleName] = button

			connect(button.MouseEnter, function()
				tween(getScale(button), {
					Scale = 1.02,
				}, 0.12)
				if not button:GetAttribute("DarkUIFooterActive") then
					tween(button, {
						BackgroundColor3 = window.Theme.Panel,
					}, 0.12)
				end
			end)

			connect(button.MouseLeave, function()
				tween(getScale(button), {
					Scale = 1,
				}, 0.12)
				if button:GetAttribute("DarkUIFooterActive") then
					tween(button, {
						BackgroundColor3 = window.Theme.Panel,
					}, 0.12)
				else
					tween(button, {
						BackgroundColor3 = window.Theme.Surface,
					}, 0.12)
				end
			end)

			attachPress(button, 0.92)
			connect(button.MouseButton1Click, function()
				if roleName == "Setting" then
					local settingsTabName = resolveSettingsTabName()
					if settingsTabName then
						window:SelectTab(settingsTabName)
					end
				else
					local homeTabName = resolveHomeTabName()
					if homeTabName then
						window:SelectTab(homeTabName)
					end
				end
			end)
		end

		createFooterButton("Home", "Home", "170940874", true)
		createFooterButton("Setting", "Setting", "17824369886", false)
		setFooterActive("Home", false)
	end

	local notifications = make("Frame", {
		AnchorPoint = Vector2.new(1, 1),
		BackgroundTransparency = 1,
		Position = UDim2.new(1, -18, 1, -18),
		Size = UDim2.fromOffset(300, 240),
		Parent = screenGui,
	}, {
		make("UIListLayout", {
			FillDirection = Enum.FillDirection.Vertical,
			HorizontalAlignment = Enum.HorizontalAlignment.Right,
			Padding = UDim.new(0, 8),
			SortOrder = Enum.SortOrder.LayoutOrder,
			VerticalAlignment = Enum.VerticalAlignment.Bottom,
		}),
	})

	local tooltip = styledBackground(make("Frame", {
		BackgroundTransparency = 0,
		BorderSizePixel = 0,
		Size = UDim2.fromOffset(180, 30),
		Visible = false,
		ZIndex = 80,
		Parent = screenGui,
	}, {
		corner(6),
		styledStroke(stroke(theme.Stroke, 0.25, 1), "Stroke"),
	}), "Surface")

	local tooltipText = styledText(DarkUI:Text({
		Font = DarkUI.Fonts.Body,
		Parent = tooltip,
		Position = UDim2.fromOffset(9, 0),
		Size = UDim2.new(1, -18, 1, 0),
		TextSize = 12,
		TextWrapped = true,
	}), "Text")
	tooltipText.ZIndex = 81

	window.Gui = screenGui
	window.Root = root
	window.Shadow = shadow
	window.Glow = glow
	window.Header = header
	window.Body = body
	window.NavPanel = navPanel
	window.Footer = footer
	window.StatusPill = statusPill
	window.SearchBox = searchBox

	function window:_applyTheme()
		for _, descendant in ipairs(screenGui:GetDescendants()) do
			local backgroundKey = descendant:GetAttribute("DarkUIBackground")
			local textKey = descendant:GetAttribute("DarkUIText")
			local strokeKey = descendant:GetAttribute("DarkUIStroke")

			if backgroundKey and descendant:IsA("GuiObject") then
				descendant.BackgroundColor3 = self.Theme[backgroundKey]
			end

			if textKey and (descendant:IsA("TextLabel") or descendant:IsA("TextButton") or descendant:IsA("TextBox")) then
				descendant.TextColor3 = self.Theme[textKey]
				descendant.TextStrokeColor3 = DarkUI.TextStrokeColor
				descendant.TextStrokeTransparency = 1
				if descendant:IsA("TextBox") then
					descendant.PlaceholderColor3 = self.Theme.Muted
				end
			end

			if strokeKey and descendant:IsA("UIStroke") then
				descendant.Color = self.Theme[strokeKey]
			end

			if descendant.Name == "DarkUIAccent" and descendant:IsA("Frame") and not backgroundKey then
				descendant.BackgroundColor3 = self.Theme.Accent
			elseif descendant.Name == "DarkUIAccentGradient" and descendant:IsA("UIGradient") then
				descendant.Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.fromRGB(58, 58, 58)),
					ColorSequenceKeypoint.new(0.5, self.Theme.Accent),
					ColorSequenceKeypoint.new(1, Color3.fromRGB(58, 58, 58)),
				})
			elseif descendant.Name == "DarkUITabActiveGlow" and descendant:IsA("Frame") then
				descendant.BackgroundColor3 = self.Theme.Accent
			elseif descendant.Name == "DarkUIGlow" and descendant:IsA("Frame") then
				descendant.BackgroundColor3 = self.Theme.Accent
			elseif descendant.Name == "DarkUIGlowStroke" and descendant:IsA("UIStroke") then
				descendant.Color = self.Theme.Accent
			elseif descendant.Name == "DarkUIFooterIcon" and descendant:IsA("ImageLabel") then
				local mode = descendant:GetAttribute("DarkUIFooterIconState")
				descendant.ImageColor3 = mode == "Active" and self.Theme.Accent or self.Theme.Muted
			elseif descendant:IsA("ScrollingFrame") then
				descendant.ScrollBarImageColor3 = self.Theme.Accent
			end
		end

		for _, renderer in ipairs(self.Renderers) do
			renderer()
		end

		if self.SelectedTab then
			self:SelectTab(self.SelectedTab)
		end
	end

	function window:SetAccentColor(color)
		self.Theme.Accent = normalizeColor(color, self.Theme.Accent)
		self:_applyTheme()
	end

	function window:SetTheme(nameOrTheme)
		if type(nameOrTheme) == "string" and DarkUI.ThemePresets[nameOrTheme] then
			self.ThemeName = nameOrTheme
			self.Theme = copyTable(DarkUI.ThemePresets[nameOrTheme])
		elseif type(nameOrTheme) == "table" then
			for key, value in pairs(nameOrTheme) do
				self.Theme[key] = value
			end
		end

		self:_applyTheme()
	end

	function window:SetStatus(text, good)
		statusPill.Text = text or "READY"
		statusPill.Visible = true
		statusPill:SetAttribute("DarkUIText", good == false and "Error" or "Accent")
		statusPill.TextColor3 = good == false and self.Theme.Error or self.Theme.Accent
	end

	function window:AttachTooltip(guiObject, text)
		if not text or text == "" then
			return
		end

		local function move(x, y)
			tooltip.Position = UDim2.fromOffset(x + 12, y + 14)
		end

		connect(guiObject.MouseEnter, function(x, y)
			tooltipText.Text = text
			tooltip.Size = UDim2.fromOffset(math.clamp(#text * 6 + 24, 130, 260), 32)
			move(x, y)
			tooltip.Visible = true
		end)

		connect(guiObject.MouseMoved, move)
		connect(guiObject.MouseLeave, function()
			tooltip.Visible = false
		end)
	end

	local function getFileApi()
		return type(writefile) == "function"
			and type(readfile) == "function"
			and type(isfile) == "function"
	end

	local function configPath()
		return window.ConfigFolder .. "/" .. window.ConfigName
	end

	local function setConfigName(name)
		if name and name ~= "" then
			name = tostring(name)
			if not string.find(name, "%.json$") then
				name = name .. ".json"
			end
			window.ConfigName = name
		end
	end

	function window:RegisterConfig(flag, control)
		if flag then
			self.ConfigValues[flag] = control
		end
	end

	function window:GetConfig()
		local data = {}

		for flag, control in pairs(self.ConfigValues) do
			if type(control.Get) == "function" then
				data[flag] = control:Get()
			end
		end

		data.__theme = self.ThemeName
		data.__accent = colorToTable(self.Theme.Accent)
		return data
	end

	function window:ApplyConfig(data)
		if type(data) ~= "table" then
			return false
		end

		if data.__theme then
			self:SetTheme(data.__theme)
		end

		if data.__accent then
			self:SetAccentColor(normalizeColor(data.__accent, self.Theme.Accent))
		end

		for flag, value in pairs(data) do
			local control = self.ConfigValues[flag]
			if control and type(control.Set) == "function" then
				control:Set(value, true, true)
			end
		end

		return true
	end

	function window:SaveConfig(name)
		setConfigName(name)

		if not getFileApi() then
			self:Notify("Config", "File API is not available.", "Warning")
			return false
		end

		if type(isfolder) == "function" and type(makefolder) == "function" and not isfolder(self.ConfigFolder) then
			local ok = pcall(function()
				makefolder(self.ConfigFolder)
			end)

			if not ok then
				self:Notify("Config", "Could not create config folder.", "Error")
				return false
			end
		end

		local ok = pcall(function()
			writefile(configPath(), HttpService:JSONEncode(self:GetConfig()))
		end)

		self:Notify("Config", ok and "Settings saved." or "Settings could not be saved.", ok and "Success" or "Error")
		return ok
	end

	function window:LoadConfig(name)
		setConfigName(name)

		if not getFileApi() then
			self:Notify("Config", "File API is not available.", "Warning")
			return false
		end

		if not isfile(configPath()) then
			self:Notify("Config", "No saved config found.", "Warning")
			return false
		end

		local ok, decoded = pcall(function()
			return HttpService:JSONDecode(readfile(configPath()))
		end)

		if ok then
			self:ApplyConfig(decoded)
		end

		self:Notify("Config", ok and "Settings loaded." or "Config could not be read.", ok and "Success" or "Error")
		return ok
	end

	function window:DeleteConfig(name)
		setConfigName(name)

		if type(delfile) ~= "function" or type(isfile) ~= "function" then
			self:Notify("Config", "Delete file API is not available.", "Warning")
			return false
		end

		if isfile(configPath()) then
			delfile(configPath())
		end

		self:Notify("Config", "Config deleted.", "Success")
		return true
	end

	function window:Notify(titleText, message, notifyType, duration)
		notifyType = notifyType or "Info"
		local colorKey = notifyType == "Success" and "Success"
			or notifyType == "Warning" and "Warning"
			or notifyType == "Error" and "Error"
			or "Accent"

		local note = styledBackground(make("Frame", {
			BorderSizePixel = 0,
			ClipsDescendants = true,
			Size = UDim2.fromOffset(300, 0),
			Parent = notifications,
		}, {
			corner(8),
			styledStroke(stroke(theme.Stroke, 0.25, 1), "Stroke"),
		}), "Surface")
		local noteScale = make("UIScale", {
			Scale = 0.94,
			Parent = note,
		})

		local accent = make("Frame", {
			Name = "DarkUIAccent",
			BackgroundColor3 = self.Theme[colorKey],
			BorderSizePixel = 0,
			Size = UDim2.new(0, 3, 1, 0),
			Parent = note,
		})
		accent:SetAttribute("DarkUIBackground", colorKey)

		styledText(DarkUI:Text({
			Font = DarkUI.Fonts.Bold,
			Parent = note,
			Position = UDim2.fromOffset(15, 8),
			Size = UDim2.new(1, -30, 0, 20),
			Text = titleText or notifyType,
			TextSize = 15,
		}), "Text")

		styledText(DarkUI:Text({
			Font = DarkUI.Fonts.Body,
			Parent = note,
			Position = UDim2.fromOffset(15, 31),
			Size = UDim2.new(1, -30, 0, 34),
			Text = message or "",
			TextSize = 13,
			TextWrapped = true,
			TextYAlignment = Enum.TextYAlignment.Top,
		}), "Muted")

		tween(note, { Size = UDim2.fromOffset(300, 74) }, 0.22)
		tween(noteScale, { Scale = 1 }, 0.22)

		task.delay(duration or 2.6, function()
			if note.Parent then
				tween(noteScale, { Scale = 0.96 }, 0.18)
				tween(note, { Size = UDim2.fromOffset(300, 0), BackgroundTransparency = 1 }, 0.18)
				task.wait(0.2)
				if note.Parent then
					note:Destroy()
				end
			end
		end)
	end

	function window:Confirm(options)
		options = options or {}

		local overlay = make("Frame", {
			BackgroundColor3 = Color3.fromRGB(0, 0, 0),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.fromScale(1, 1),
			ZIndex = 100,
			Parent = screenGui,
		})

		local dialog = styledBackground(make("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BorderSizePixel = 0,
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromOffset(340, 156),
			ZIndex = 101,
			Parent = overlay,
		}, {
			corner(9),
			styledStroke(stroke(theme.Stroke, 0.15, 1), "Stroke"),
		}), "Surface")
		local dialogScale = make("UIScale", {
			Scale = 0.92,
			Parent = dialog,
		})
		tween(dialogScale, {
			Scale = 1,
		}, 0.18)
		tween(overlay, {
			BackgroundTransparency = 0.35,
		}, 0.16)

		local confirmTitle = styledText(DarkUI:Text({
			Font = DarkUI.Fonts.Bold,
			Parent = dialog,
			Position = UDim2.fromOffset(18, 14),
			Size = UDim2.new(1, -36, 0, 24),
			Text = options.Title or "Confirm",
			TextSize = 18,
		}), "Text")
		confirmTitle.ZIndex = 102

		local confirmBody = styledText(DarkUI:Text({
			Font = DarkUI.Fonts.Body,
			Parent = dialog,
			Position = UDim2.fromOffset(18, 44),
			Size = UDim2.new(1, -36, 0, 52),
			Text = options.Text or options.Message or "Are you sure?",
			TextSize = 14,
			TextWrapped = true,
			TextYAlignment = Enum.TextYAlignment.Top,
		}), "Muted")
		confirmBody.ZIndex = 102

		local cancel = styledBackground(make("TextButton", {
			AutoButtonColor = false,
			BorderSizePixel = 0,
			Font = DarkUI.Fonts.Bold,
			Position = UDim2.new(1, -198, 1, -48),
			Size = UDim2.fromOffset(84, 32),
			Text = options.CancelText or "Cancel",
			TextSize = 14,
			ZIndex = 102,
			Parent = dialog,
		}, {
			corner(6),
		}), "PanelLight")
		styledText(cancel, "Text")
		attachHover(cancel, "PanelLight", "Panel", 1.03)
		attachPress(cancel, 0.92)

		local confirm = styledBackground(make("TextButton", {
			AutoButtonColor = false,
			BorderSizePixel = 0,
			Font = DarkUI.Fonts.Bold,
			Position = UDim2.new(1, -104, 1, -48),
			Size = UDim2.fromOffset(86, 32),
			Text = options.ConfirmText or "Confirm",
			TextSize = 14,
			ZIndex = 102,
			Parent = dialog,
		}, {
			corner(6),
		}), "PanelLight")
		styledText(confirm, "Accent")
		attachHover(confirm, "PanelLight", "Panel", 1.03)
		attachPress(confirm, 0.92)

		connect(cancel.MouseButton1Click, function()
			overlay:Destroy()
			safe(options.CancelCallback)
		end)

		connect(confirm.MouseButton1Click, function()
			overlay:Destroy()
			safe(options.Callback or options.ConfirmCallback)
		end)

		return overlay
	end

	local function setSearchText(row, text)
		row:SetAttribute("SearchText", string.lower(tostring(text or "")))
	end

	function window:ApplySearch(query)
		query = string.lower(tostring(query or ""))

		if searchClear then
			searchClear.Visible = query ~= ""
		end

		for _, item in ipairs(self.SearchItems) do
			local row = item.Row
			local baseVisible = row:GetAttribute("BaseVisible") ~= false
			local matches = query == "" or string.find(row:GetAttribute("SearchText") or "", query, 1, true) ~= nil
			row.Visible = baseVisible and matches
		end

		for _, section in ipairs(self.Sections) do
			section:UpdateVisibility()
		end
	end

	if searchBox then
		connect(searchBox:GetPropertyChangedSignal("Text"), function()
			window:ApplySearch(searchBox.Text)
		end)

		connect(searchClear.MouseButton1Click, function()
			searchBox.Text = ""
		end)
	end

	function window:SelectTab(name)
		for tabName, page in pairs(self.Pages) do
			local selected = tabName == name
			page.Visible = selected

			local tabButton = self.TabButtons[tabName]
			if tabButton then
				tween(tabButton, {
					BackgroundColor3 = selected and self.Theme.TabActive or self.Theme.Background,
				}, 0.14)

				local tabTitle = tabButton:FindFirstChild("TabTitle")
				if tabTitle then
					tween(tabTitle, {
						TextColor3 = selected and self.Theme.Text or Color3.fromRGB(
							math.floor((self.Theme.Text.R * 255) * 0.84 + 0.5),
							math.floor((self.Theme.Text.G * 255) * 0.84 + 0.5),
							math.floor((self.Theme.Text.B * 255) * 0.84 + 0.5)
						),
					}, 0.14)
				end

				local tabDesc = tabButton:FindFirstChild("TabDesc")
				if tabDesc then
					tween(tabDesc, {
						TextColor3 = self.Theme.Muted,
						TextTransparency = selected and 0.1 or 0.42,
					}, 0.14)
				end

				local activeGlow = tabButton:FindFirstChild("DarkUITabActiveGlow")
				if activeGlow then
					tween(activeGlow, {
						BackgroundTransparency = selected and 0 or 1,
					}, 0.14)
				end

				local accent = tabButton:FindFirstChild("DarkUIAccent")
				if accent then
					if selected then
						accent.Visible = true
					end
					tween(accent, {
						Size = selected and UDim2.new(0, 3, 1, -14) or UDim2.new(0, 3, 0, 0),
						BackgroundTransparency = selected and 0 or 0.4,
					}, 0.16)
					if not selected then
						task.delay(0.16, function()
							if accent.Parent and self.SelectedTab ~= tabName then
								accent.Visible = false
							end
						end)
					end
				end
			end
		end

		self.SelectedTab = name
		setFooterActive(footerRoleForTab(name), true)
		self:ApplySearch(searchBox and searchBox.Text or "")
	end

	local function buildControlApi(row, render)
		row:SetAttribute("BaseVisible", true)

		local control = {
			Row = row,
			Disabled = false,
			Changed = {},
		}

		function control:SetDisabled(disabled)
			self.Disabled = disabled == true
			row:SetAttribute("Disabled", self.Disabled)
			row.BackgroundTransparency = self.Disabled and 0.35 or 0

			for _, descendant in ipairs(row:GetDescendants()) do
				if descendant:IsA("TextLabel") or descendant:IsA("TextButton") or descendant:IsA("TextBox") then
					descendant.TextTransparency = self.Disabled and 0.38 or 0
				end
			end

			if render then
				render(true)
			end
		end

		function control:SetVisible(visible)
			row:SetAttribute("BaseVisible", visible ~= false)
			window:ApplySearch(searchBox and searchBox.Text or "")
		end

		function control:OnChanged(callback)
			table.insert(self.Changed, callback)
			return function()
				for index, current in ipairs(self.Changed) do
					if current == callback then
						table.remove(self.Changed, index)
						break
					end
				end
			end
		end

		function control:_fire(value)
			for _, callback in ipairs(self.Changed) do
				safe(callback, value)
			end
		end

		function control:DependsOn(otherControl, expected, mode)
			local function evaluate(value)
				local passed
				if type(expected) == "function" then
					passed = expected(value)
				elseif expected == nil then
					passed = value == true
				else
					passed = value == expected
				end

				if mode == "Disable" then
					self:SetDisabled(not passed)
				else
					self:SetVisible(passed)
				end
			end

			if otherControl and type(otherControl.Get) == "function" then
				evaluate(otherControl:Get())
				return otherControl:OnChanged(evaluate)
			end
		end

		return control
	end

	function window:CreateTab(tabConfig, icon)
		if type(tabConfig) == "string" then
			tabConfig = {
				Name = tabConfig,
				Icon = icon,
			}
		end

		tabConfig = tabConfig or {}
		local tabName = tabConfig.Name or ("Tab " .. tostring(#self.TabButtons + 1))
		local tabIcon = resolveIcon(tabConfig.Icon)

		local tabDescription = tabConfig.Description or tabConfig.Subtitle
		if not tabDescription or tabDescription == "" then
			local loweredName = string.lower(tabName)
			if string.find(loweredName, "setting", 1, true) then
				tabDescription = "UI tools, themes, config"
			elseif string.find(loweredName, "webhook", 1, true) then
				tabDescription = "Discord log and payload"
			else
				tabDescription = "Auto farm and more..."
			end
		end
		local tabButton = styledBackground(make("TextButton", {
			AutoButtonColor = false,
			BorderSizePixel = 0,
			Font = DarkUI.Fonts.Bold,
			Size = UDim2.new(1, 0, 0, tabConfig.Height or tabHeight),
			Text = "",
			Parent = tabs,
		}, {
			corner(7),
		}), "Background")
		attachPress(tabButton, 0.97)

		local activeGlow = make("Frame", {
			Name = "DarkUITabActiveGlow",
			BackgroundColor3 = self.Theme.Accent,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.fromScale(1, 1),
			Parent = tabButton,
		}, {
			corner(7),
			make("UIGradient", {
				Rotation = 0,
				Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0.86),
					NumberSequenceKeypoint.new(0.45, 0.92),
					NumberSequenceKeypoint.new(1, 1),
				}),
			}),
		})

		local textOffset = tabIcon and 32 or 14
		if tabIcon then
			make("ImageLabel", {
				BackgroundTransparency = 1,
				Image = tabIcon,
				Position = UDim2.fromOffset(10, 12),
				ScaleType = Enum.ScaleType.Fit,
				Size = UDim2.fromOffset(16, 16),
				Parent = tabButton,
			})
		end

		local titleLabel = styledText(DarkUI:Text({
			Font = DarkUI.Fonts.Bold,
			Parent = tabButton,
			Position = UDim2.fromOffset(textOffset, 7),
			Size = UDim2.new(1, -textOffset - 8, 0, 17),
			Text = tabName,
			TextSize = 12,
			TextXAlignment = Enum.TextXAlignment.Left,
		}), "Text")
		titleLabel.Name = "TabTitle"

		local descLabel = styledText(DarkUI:Text({
			Font = DarkUI.Fonts.Body,
			Parent = tabButton,
			Position = UDim2.fromOffset(textOffset, 23),
			Size = UDim2.new(1, -textOffset - 8, 0, 14),
			Text = tabDescription,
			TextSize = 9,
			TextXAlignment = Enum.TextXAlignment.Left,
		}), "Muted")
		descLabel.Name = "TabDesc"
		descLabel.TextTransparency = 0.42

		make("Frame", {
			Name = "DarkUIAccent",
			AnchorPoint = Vector2.new(0, 0),
			BackgroundColor3 = self.Theme.Accent,
			BorderSizePixel = 0,
			Position = UDim2.new(0, 0, 0, 6),
			Size = UDim2.new(0, 3, 0, 0),
			Visible = false,
			Parent = tabButton,
		}, {
			corner(999),
		})

		connect(tabButton.MouseEnter, function()
			if window.SelectedTab ~= tabName then
				tween(tabButton, {
					BackgroundColor3 = window.Theme.Tab,
				}, 0.12)
				tween(getScale(tabButton), {
					Scale = 1.006,
				}, 0.12)
			end
		end)

		connect(tabButton.MouseLeave, function()
			if window.SelectedTab ~= tabName then
				tween(tabButton, {
					BackgroundColor3 = window.Theme.Background,
				}, 0.12)
			end
			tween(getScale(tabButton), {
				Scale = 1,
			}, 0.12)
		end)

		local columnCount = tabConfig.Columns or config.Columns or 1
		local useTwoColumns = columnCount ~= 1
		local page = make("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 1),
			Visible = false,
			Parent = pagesHolder,
		}, {
			make("UIListLayout", {
				FillDirection = Enum.FillDirection.Horizontal,
				Padding = UDim.new(0, useTwoColumns and 10 or 0),
				SortOrder = Enum.SortOrder.LayoutOrder,
			}),
		})

		local left = make("ScrollingFrame", {
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			CanvasSize = UDim2.new(),
			LayoutOrder = 1,
			ScrollBarImageColor3 = self.Theme.Accent,
			ScrollBarImageTransparency = 0.4,
			ScrollBarThickness = 2,
			Size = useTwoColumns and UDim2.new(0.5, -5, 1, 0) or UDim2.new(1, 0, 1, 0),
			Parent = page,
		}, {
			make("UIListLayout", {
				FillDirection = Enum.FillDirection.Vertical,
				Padding = UDim.new(0, 8),
				SortOrder = Enum.SortOrder.LayoutOrder,
			}),
			make("UIPadding", {
				PaddingBottom = UDim.new(0, 6),
				PaddingTop = UDim.new(0, 4),
			}),
		})

		local right = make("ScrollingFrame", {
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			CanvasSize = UDim2.new(),
			LayoutOrder = 2,
			ScrollBarImageColor3 = self.Theme.Accent,
			ScrollBarImageTransparency = 0.4,
			ScrollBarThickness = 2,
			Size = useTwoColumns and UDim2.new(0.5, -5, 1, 0) or UDim2.new(0, 0, 1, 0),
			Visible = useTwoColumns,
			Parent = page,
		}, {
			make("UIListLayout", {
				FillDirection = Enum.FillDirection.Vertical,
				Padding = UDim.new(0, 8),
				SortOrder = Enum.SortOrder.LayoutOrder,
			}),
			make("UIPadding", {
				PaddingBottom = UDim.new(0, 6),
				PaddingTop = UDim.new(0, 4),
			}),
		})

		self.Pages[tabName] = page
		self.TabButtons[tabName] = tabButton
		table.insert(self.TabOrder, tabName)

		if not self.FooterHomeTab then
			self.FooterHomeTab = tabName
		end

		if not self.FooterSettingsTab and isSettingsTabName(tabName) then
			self.FooterSettingsTab = tabName
		end

		local tab = {
			Name = tabName,
			Page = page,
			Window = self,
			Columns = useTwoColumns and { left, right } or { left },
			SectionOrder = 0,
		}

		function tab:AddSection(options)
			if type(options) == "string" then
				options = {
					Title = options,
				}
			end

			options = options or {}
			self.SectionOrder += 1

			local target
			if options.Side == "Right" and self.Columns[2] then
				target = self.Columns[2]
			elseif options.Side == "Left" then
				target = self.Columns[1]
			else
				target = self.Columns[((self.SectionOrder - 1) % #self.Columns) + 1]
			end

			local section = styledBackground(make("Frame", {
				AutomaticSize = Enum.AutomaticSize.Y,
				BorderSizePixel = 0,
				BackgroundTransparency = 1,
				LayoutOrder = self.SectionOrder,
				Size = UDim2.new(1, -4, 0, 0),
				Parent = target,
			}, {
				corner(0),
				styledStroke(stroke(window.Theme.Stroke, 1, 1), "Stroke"),
				make("UIPadding", {
					PaddingBottom = UDim.new(0, 4),
					PaddingLeft = UDim.new(0, 0),
					PaddingRight = UDim.new(0, 0),
					PaddingTop = UDim.new(0, 0),
				}),
				make("UIListLayout", {
					FillDirection = Enum.FillDirection.Vertical,
					Padding = UDim.new(0, 7),
					SortOrder = Enum.SortOrder.LayoutOrder,
				}),
			}), "Background")

			local headerButton = make("TextButton", {
				AutoButtonColor = false,
				BackgroundTransparency = 1,
				LayoutOrder = 0,
				Size = UDim2.new(1, 0, 0, 32),
				Text = "",
				Parent = section,
			})

			styledText(DarkUI:Text({
				Font = DarkUI.Fonts.Bold,
				Parent = headerButton,
				Position = UDim2.fromOffset(0, 1),
				Size = UDim2.new(1, -26, 0, 24),
				Text = options.Title or "Section",
				TextSize = 20,
				TextXAlignment = Enum.TextXAlignment.Left,
			}), "Text")

			local isCollapsible = options.Collapsible ~= false
			local foldIcon = make("Frame", {
				AnchorPoint = Vector2.new(1, 0),
				BackgroundTransparency = 1,
				Position = UDim2.new(1, -5, 0, 4),
				Rotation = options.DefaultOpen == false and 90 or 0,
				Size = UDim2.fromOffset(22, 22),
				Visible = isCollapsible,
				Parent = headerButton,
			})
			local foldIconScale = make("UIScale", {
				Scale = 1,
				Parent = foldIcon,
			})
			local foldHorizontal = styledBackground(make("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BorderSizePixel = 0,
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromOffset(12, 2),
				Parent = foldIcon,
			}, {
				corner(999),
			}), "Muted")
			local foldVertical = styledBackground(make("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = options.DefaultOpen == false and 0 or 1,
				BorderSizePixel = 0,
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromOffset(2, 12),
				Parent = foldIcon,
			}, {
				corner(999),
			}), "Muted")

			make("Frame", {
				Name = "DarkUIAccent",
				AnchorPoint = Vector2.new(0.5, 0),
				BackgroundColor3 = window.Theme.Accent,
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Position = UDim2.new(0.5, 0, 1, -1),
				Size = UDim2.new(1, 0, 0, 1),
				Parent = headerButton,
			}, {
				make("UIGradient", {
					Name = "DarkUIAccentGradient",
					Color = ColorSequence.new({
						ColorSequenceKeypoint.new(0, Color3.fromRGB(58, 58, 58)),
						ColorSequenceKeypoint.new(0.5, window.Theme.Accent),
						ColorSequenceKeypoint.new(1, Color3.fromRGB(58, 58, 58)),
					}),
					Transparency = NumberSequence.new({
						NumberSequenceKeypoint.new(0, 0.86),
						NumberSequenceKeypoint.new(0.5, 0),
						NumberSequenceKeypoint.new(1, 0.86),
					}),
				}),
			})

			local bodyFrame = make("Frame", {
				AutomaticSize = Enum.AutomaticSize.Y,
				BackgroundTransparency = 1,
				LayoutOrder = 1,
				Size = UDim2.new(1, 0, 0, 0),
				Visible = options.DefaultOpen ~= false,
				Parent = section,
			}, {
				make("UIListLayout", {
					FillDirection = Enum.FillDirection.Vertical,
					Padding = UDim.new(0, 5),
					SortOrder = Enum.SortOrder.LayoutOrder,
				}),
			})

			local sectionApi = {
				Container = section,
				Body = bodyFrame,
				Header = headerButton,
				Window = window,
				ItemOrder = 0,
				Collapsed = options.DefaultOpen == false,
			}

			function sectionApi:UpdateVisibility()
				local anyVisible = false
				for _, child in ipairs(self.Body:GetChildren()) do
					if child:IsA("GuiObject") and child.Visible then
						anyVisible = true
						break
					end
				end

				self.Container.Visible = anyVisible or not searchBox or searchBox.Text == ""
			end

			function sectionApi:SetCollapsed(collapsed)
				if not isCollapsible then
					return
				end

				self.Collapsed = collapsed == true
				self.Body.Visible = not self.Collapsed
				tween(foldIconScale, {
					Scale = 0.82,
				}, 0.07)
				tween(foldIcon, {
					Rotation = self.Collapsed and 90 or 0,
				}, 0.18)
				tween(foldVertical, {
					BackgroundTransparency = self.Collapsed and 0 or 1,
				}, 0.14)
				tween(foldHorizontal, {
					BackgroundTransparency = 0,
				}, 0.14)
				task.delay(0.07, function()
					if foldIconScale.Parent then
						tween(foldIconScale, {
							Scale = 1,
						}, 0.12)
					end
				end)
			end

			function sectionApi:NextOrder()
				self.ItemOrder += 1
				return self.ItemOrder
			end

			local function addSearchRow(row, text)
				setSearchText(row, text)
				table.insert(window.SearchItems, {
					Row = row,
					Section = sectionApi,
				})
			end

			local function createRow(options, height)
				options = options or {}

				local row = styledBackground(make("Frame", {
					BorderSizePixel = 0,
					LayoutOrder = sectionApi:NextOrder(),
					Size = UDim2.new(1, 0, 0, height),
					Parent = bodyFrame,
				}, {
					corner(5),
					styledStroke(stroke(window.Theme.Stroke, 0.82, 1), "Stroke"),
				}), "PanelLight")

				attachHover(row, "PanelLight", "Panel")
				addSearchRow(row, (options.Title or "") .. " " .. (options.Description or "") .. " " .. (options.SearchText or ""))
				return row
			end

			connect(headerButton.MouseButton1Click, function()
				pop(headerButton, 0.985)
				sectionApi:SetCollapsed(not sectionApi.Collapsed)
			end)

			table.insert(window.Sections, sectionApi)

			function sectionApi:AddLabel(text)
				local label = styledText(DarkUI:Text({
					Font = DarkUI.Fonts.Body,
					LayoutOrder = self:NextOrder(),
					Parent = bodyFrame,
					Size = UDim2.new(1, 0, 0, 20),
					Text = text or "Label",
					TextSize = 13,
				}), "Muted")
				addSearchRow(label, text or "Label")
				return label
			end

			function sectionApi:AddDivider()
				return styledBackground(make("Frame", {
					BorderSizePixel = 0,
					LayoutOrder = self:NextOrder(),
					Size = UDim2.new(1, 0, 0, 1),
					Parent = bodyFrame,
				}), "Stroke")
			end

			function sectionApi:AddParagraph(options)
				options = options or {}
				local row = createRow(options, 72)
				row:SetAttribute("DarkUIBackground", "Surface")
				row.BackgroundColor3 = window.Theme.Surface

				styledText(DarkUI:Text({
					Font = DarkUI.Fonts.Bold,
					Parent = row,
					Position = UDim2.fromOffset(14, 8),
					Size = UDim2.new(1, -28, 0, 18),
					Text = options.Title or "Info",
					TextSize = 13,
				}), "Text")

				local bodyText = styledText(DarkUI:Text({
					Font = DarkUI.Fonts.Body,
					Parent = row,
					Position = UDim2.fromOffset(14, 31),
					Size = UDim2.new(1, -28, 0, 34),
					Text = options.Text or "",
					TextSize = 13,
					TextWrapped = true,
					TextYAlignment = Enum.TextYAlignment.Top,
				}), "Muted")

				local control = buildControlApi(row)
				function control:Set(text)
					bodyText.Text = text
					setSearchText(row, (options.Title or "") .. " " .. text)
				end

				return control
			end

			function sectionApi:AddButton(options)
				options = options or {}
				local buttonIcon = resolveIcon(options.Icon)
				local row = createRow(options, 44)

				local button = styledBackground(make("TextButton", {
					AutoButtonColor = false,
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					Font = DarkUI.Fonts.Bold,
					Size = UDim2.fromScale(1, 1),
					Text = "",
					Parent = row,
				}), "Panel")

				if buttonIcon then
					make("ImageLabel", {
						BackgroundTransparency = 1,
						Image = buttonIcon,
						Position = UDim2.fromOffset(14, 12),
						ScaleType = Enum.ScaleType.Fit,
						Size = UDim2.fromOffset(20, 20),
						Parent = button,
					})
				end

				styledText(DarkUI:Text({
					Font = DarkUI.Fonts.Bold,
					Parent = button,
					Position = UDim2.fromOffset(buttonIcon and 42 or 0, 0),
					Size = UDim2.new(1, buttonIcon and -56 or 0, 1, 0),
					Text = options.Title or "Button",
					TextSize = 15,
					TextXAlignment = buttonIcon and Enum.TextXAlignment.Left or Enum.TextXAlignment.Center,
				}), "Text")

				local control = buildControlApi(row)
				attachPress(row, 0.985)
				connect(button.MouseButton1Click, function()
					if not control.Disabled then
						safe(options.Callback)
					end
				end)

				window:AttachTooltip(row, options.Tooltip)
				return control
			end

			function sectionApi:AddToggle(options)
				options = options or {}
				local value = options.Default == true
				local hasDescription = options.Description and options.Description ~= ""
				local row = createRow(options, hasDescription and 64 or 48)

				styledText(DarkUI:Text({
					Font = DarkUI.Fonts.Bold,
					Parent = row,
					Position = UDim2.fromOffset(12, hasDescription and 8 or 0),
					Size = UDim2.new(1, -72, 0, hasDescription and 17 or 48),
					Text = options.Title or "Toggle",
					TextSize = 13,
				}), "Text")

				if hasDescription then
					styledText(DarkUI:Text({
						Font = DarkUI.Fonts.Body,
						Parent = row,
						Position = UDim2.fromOffset(12, 26),
						Size = UDim2.new(1, -80, 0, 32),
						Text = options.Description,
						TextSize = 10,
						TextWrapped = true,
						TextYAlignment = Enum.TextYAlignment.Top,
					}), "Muted")
				end

				local shellStroke = stroke(window.Theme.Stroke, 0.52, 1)
				local shell = styledBackground(make("TextButton", {
					AnchorPoint = Vector2.new(1, 0.5),
					AutoButtonColor = false,
					BorderSizePixel = 0,
					Position = UDim2.new(1, -10, 0.5, 0),
					Size = UDim2.fromOffset(44, 26),
					Text = "",
					Parent = row,
				}, {
					corner(999),
					shellStroke,
				}), "Panel")

				local innerStroke = stroke(window.Theme.Stroke, 0.22, 1)
				local innerBox = make("Frame", {
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundColor3 = Color3.fromRGB(245, 245, 247),
					BorderSizePixel = 0,
					Position = value and UDim2.fromScale(0.72, 0.5) or UDim2.fromScale(0.28, 0.5),
					Size = UDim2.fromOffset(18, 18),
					Parent = shell,
				}, {
					corner(999),
					innerStroke,
				})

				local check = make("Frame", {
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundTransparency = 1,
					Position = UDim2.fromScale(0.5, 0.5),
					Size = UDim2.fromOffset(18, 16),
					Parent = innerBox,
				}, {
					make("Frame", {
						AnchorPoint = Vector2.new(0.5, 0.5),
						BackgroundColor3 = Color3.fromRGB(255, 255, 255),
						BorderSizePixel = 0,
						Position = UDim2.fromOffset(6, 10),
						Rotation = 45,
						Size = UDim2.fromOffset(7, 3),
					}, {
						corner(999),
					}),
					make("Frame", {
						AnchorPoint = Vector2.new(0.5, 0.5),
						BackgroundColor3 = Color3.fromRGB(255, 255, 255),
						BorderSizePixel = 0,
						Position = UDim2.fromOffset(11, 8),
						Rotation = -45,
						Size = UDim2.fromOffset(13, 3),
					}, {
						corner(999),
					}),
				})
				local checkScale = make("UIScale", {
					Scale = 0,
					Parent = check,
				})

				local control
				local function render(animated)
					local onColor = window.Theme.Accent
					local shellProps = {
						BackgroundColor3 = value and window.Theme.Accent or window.Theme.Panel,
					}
					local shellStrokeProps = {
						Color = value and onColor or window.Theme.Stroke,
						Transparency = value and 0.16 or 0.52,
					}
					local innerProps = {
						BackgroundColor3 = Color3.fromRGB(245, 245, 247),
						Position = value and UDim2.fromScale(0.72, 0.5) or UDim2.fromScale(0.28, 0.5),
					}
					local innerStrokeProps = {
						Color = value and Color3.fromRGB(245, 245, 247) or Color3.fromRGB(54, 60, 76),
						Transparency = 1,
					}

					check.Visible = false

					if animated then
						tween(shell, shellProps, 0.14)
						tween(shellStroke, shellStrokeProps, 0.14)
						tween(innerBox, innerProps, 0.14)
						tween(innerStroke, innerStrokeProps, 0.14)
						tween(checkScale, { Scale = 0 }, 0.13)
						for _, child in ipairs(check:GetChildren()) do
							if child:IsA("Frame") then
								tween(child, {
									BackgroundTransparency = value and 0 or 1,
								}, 0.1)
							end
						end
					else
						shell.BackgroundColor3 = shellProps.BackgroundColor3
						shellStroke.Color = shellStrokeProps.Color
						shellStroke.Transparency = shellStrokeProps.Transparency
						innerBox.BackgroundColor3 = innerProps.BackgroundColor3
						innerBox.Position = innerProps.Position
						innerStroke.Color = innerStrokeProps.Color
						innerStroke.Transparency = innerStrokeProps.Transparency
						checkScale.Scale = 0
						check.Visible = false
						for _, child in ipairs(check:GetChildren()) do
							if child:IsA("Frame") then
								child.BackgroundTransparency = value and 0 or 1
							end
						end
					end
				end

				control = buildControlApi(row, render)

				function control:Set(nextValue, silent)
					value = nextValue == true
					render(true)
					if not silent then
						safe(options.Callback, value)
						self:_fire(value)
					end
				end

				function control:Get()
					return value
				end

				function control:Toggle()
					if not self.Disabled then
						self:Set(not value)
					end
				end

				local lastToggle = 0
				local function requestToggle()
					local now = os.clock()
					if now - lastToggle < 0.05 then
						return
					end

					lastToggle = now
					pop(shell, 0.88)
					control:Toggle()
				end

				connect(row.InputBegan, function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
						requestToggle()
					end
				end)

				connect(shell.MouseButton1Click, function()
					requestToggle()
				end)

				registerRenderer(render)
				window:RegisterConfig(options.Flag, control)
				window:AttachTooltip(row, options.Tooltip)
				return control
			end

			function sectionApi:AddSlider(options)
				options = options or {}
				local minValue = options.Min or 0
				local maxValue = options.Max or 100
				if maxValue < minValue then
					minValue, maxValue = maxValue, minValue
				end

				local decimals = options.Decimals or 0
				local factor = 10 ^ decimals
				local value = math.clamp(options.Default or minValue, minValue, maxValue)
				local row = createRow(options, 64)

				styledText(DarkUI:Text({
					Font = DarkUI.Fonts.Bold,
					Parent = row,
					Position = UDim2.fromOffset(12, 6),
					Size = UDim2.new(1, -24, 0, 18),
					Text = options.Title or "Slider",
					TextSize = 13,
				}), "Text")

				local valueBoxStroke = styledStroke(stroke(window.Theme.Stroke, 0.45, 1), "Stroke")
				local valueBox = styledBackground(make("TextBox", {
					AnchorPoint = Vector2.new(1, 0.5),
					BorderSizePixel = 0,
					ClearTextOnFocus = false,
					Font = DarkUI.Fonts.Bold,
					PlaceholderColor3 = window.Theme.Muted,
					PlaceholderText = "0",
					Position = UDim2.new(1, -12, 0, 43),
					Size = UDim2.fromOffset(72, 28),
					Text = tostring(value),
					TextSize = 13,
					TextXAlignment = Enum.TextXAlignment.Center,
					Parent = row,
				}, {
					corner(6),
					valueBoxStroke,
				}), "Panel")
				styledText(valueBox, "Accent")
				local valueBoxFocused = false

				local track = styledBackground(make("Frame", {
					BorderSizePixel = 0,
					Position = UDim2.fromOffset(12, 42),
					Size = UDim2.new(1, -104, 0, 6),
					Parent = row,
				}, {
					corner(999),
				}), "Surface")

				local fill = make("Frame", {
					Name = "DarkUIAccent",
					BackgroundColor3 = window.Theme.Accent,
					BorderSizePixel = 0,
					Size = UDim2.fromScale(0, 1),
					Parent = track,
				}, {
					corner(999),
				})

				local knob = make("Frame", {
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundColor3 = window.Theme.Accent,
					BorderSizePixel = 0,
					Position = UDim2.fromScale(0, 0.5),
					Size = UDim2.fromOffset(15, 15),
					Parent = track,
				}, {
					corner(999),
				})
				knob.Name = "DarkUIAccent"

				local dragging = false
				local control

				local function round(nextValue)
					return math.floor((nextValue * factor) + 0.5) / factor
				end

				local function render(animated)
					local percent = maxValue == minValue and 0 or math.clamp((value - minValue) / (maxValue - minValue), 0, 1)
					if not valueBoxFocused then
						valueBox.Text = tostring(value)
					end
					if animated then
						tween(fill, {
							Size = UDim2.fromScale(percent, 1),
						}, 0.08)
						tween(knob, {
							Position = UDim2.fromScale(percent, 0.5),
						}, 0.08)
					else
						fill.Size = UDim2.fromScale(percent, 1)
						knob.Position = UDim2.fromScale(percent, 0.5)
					end
				end

				local function applyTextValue()
					local nextValue = tonumber(valueBox.Text)
					if nextValue then
						control:Set(nextValue)
					else
						valueBox.Text = tostring(value)
					end
				end

				local function updateFromInput(input)
					local percent = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
					control:Set(minValue + ((maxValue - minValue) * percent))
				end

				control = buildControlApi(row, render)

				function control:Set(nextValue, silent)
					value = round(math.clamp(tonumber(nextValue) or minValue, minValue, maxValue))
					render(true)
					if not silent then
						safe(options.Callback, value)
						self:_fire(value)
					end
				end

				function control:Get()
					return value
				end

				connect(valueBox.Focused, function()
					valueBoxFocused = true
					if not control.Disabled then
						tween(valueBoxStroke, {
							Color = window.Theme.Accent,
							Transparency = 0.08,
						}, 0.12)
						pop(valueBox, 0.98)
					end
				end)

				connect(valueBox.FocusLost, function()
					valueBoxFocused = false
					tween(valueBoxStroke, {
						Color = window.Theme.Stroke,
						Transparency = 0.45,
					}, 0.12)
					if not control.Disabled then
						applyTextValue()
					end
				end)

				connect(track.InputBegan, function(input)
					if control.Disabled then
						return
					end

					if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
						dragging = true
						tween(getScale(knob), {
							Scale = 1.18,
						}, 0.1)
						updateFromInput(input)
					end
				end)

				connect(UserInputService.InputChanged, function(input)
					if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
						updateFromInput(input)
					end
				end)

				connect(UserInputService.InputEnded, function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
						dragging = false
						tween(getScale(knob), {
							Scale = 1,
						}, 0.12)
					end
				end)

				registerRenderer(render)
				window:RegisterConfig(options.Flag, control)
				window:AttachTooltip(row, options.Tooltip)
				return control
			end

			local function makeDropdown(options, multi)
				options = options or {}
				local items = options.Items or {}
				local selected = multi and {} or options.Default or items[1]
				local searchable = options.Searchable ~= false
				local discordCollapse = options.DiscordCollapse ~= false
				if multi then
					for _, item in ipairs(options.Default or {}) do
						selected[tostring(item)] = true
					end
				end

				local row = createRow(options, 44)
				local open = false
				local listHeight = 0
				local filteredCount = #items
				local searchQuery = ""

				styledText(DarkUI:Text({
					Font = DarkUI.Fonts.Bold,
					Parent = row,
					Position = UDim2.fromOffset(12, 0),
					Size = UDim2.new(0.42, -12, 0, 44),
					Text = options.Title or "Dropdown",
					TextSize = 14,
				}), "Text")

				local button = styledBackground(make("TextButton", {
					AnchorPoint = Vector2.new(1, 0),
					AutoButtonColor = false,
					BorderSizePixel = 0,
					Font = DarkUI.Fonts.Bold,
					Position = UDim2.new(1, -12, 0, 8),
					Size = UDim2.new(0.58, -8, 0, 28),
					Text = "",
					Parent = row,
				}, {
					corner(6),
					styledStroke(stroke(window.Theme.Stroke, 0.55, 1), "Stroke"),
				}), "Surface")

				local selectedText = styledText(DarkUI:Text({
					Font = DarkUI.Fonts.Bold,
					Parent = button,
					Position = UDim2.fromOffset(9, 0),
					Size = UDim2.new(1, -32, 1, 0),
					Text = "",
					TextSize = 13,
				}), "Text")

				local arrow = make("Frame", {
					AnchorPoint = Vector2.new(1, 0.5),
					BackgroundTransparency = 1,
					Position = UDim2.new(1, -9, 0.5, 0),
					Rotation = discordCollapse and -90 or 0,
					Size = UDim2.fromOffset(20, 18),
					Parent = button,
				}, {
					styledBackground(make("Frame", {
						AnchorPoint = Vector2.new(0.5, 0.5),
						BorderSizePixel = 0,
						Position = UDim2.fromOffset(7, 9),
						Rotation = 45,
						Size = UDim2.fromOffset(11, 3),
					}, {
						corner(999),
					}), "Accent"),
					styledBackground(make("Frame", {
						AnchorPoint = Vector2.new(0.5, 0.5),
						BorderSizePixel = 0,
						Position = UDim2.fromOffset(13, 9),
						Rotation = -45,
						Size = UDim2.fromOffset(11, 3),
					}, {
						corner(999),
					}), "Accent"),
				})
				attachHover(button, "Surface", "PanelLight", 1.01)
				attachPress(button, 0.96)

				local list = make("Frame", {
					BackgroundTransparency = 1,
					ClipsDescendants = true,
					Position = UDim2.fromOffset(12, 42),
					Size = UDim2.new(1, -24, 0, 0),
					Visible = false,
					Parent = row,
				}, {
					make("UIListLayout", {
						FillDirection = Enum.FillDirection.Vertical,
						Padding = UDim.new(0, 5),
						SortOrder = Enum.SortOrder.LayoutOrder,
					}),
				})

				local searchBox
				if searchable then
					searchBox = styledBackground(make("TextBox", {
						BorderSizePixel = 0,
						ClearTextOnFocus = false,
						Font = DarkUI.Fonts.Bold,
						LayoutOrder = 0,
						PlaceholderColor3 = window.Theme.Muted,
						PlaceholderText = "Search...",
						Size = UDim2.new(1, 0, 0, 30),
						Text = "",
						TextSize = 13,
						Parent = list,
					}, {
						corner(5),
						styledStroke(stroke(window.Theme.Stroke, 0.55, 1), "Stroke"),
						make("UIPadding", {
							PaddingLeft = UDim.new(0, 8),
							PaddingRight = UDim.new(0, 8),
						}),
					}), "Surface")
					styledText(searchBox, "Text")
				end

				local control
				local itemButtons = {}
				local itemChecks = {}

				local function selectedList()
					local listItems = {}
					for _, item in ipairs(items) do
						if selected[tostring(item)] then
							table.insert(listItems, item)
						end
					end
					return listItems
				end

				local function renderText()
					if multi then
						local values = selectedList()
						selectedText.Text = #values == 0 and "None" or table.concat(values, ", ")
					else
						selectedText.Text = tostring(selected or "None")
					end

					for key, itemButton in pairs(itemButtons) do
						local active = multi and selected[key] == true or tostring(selected) == key
						itemButton.BackgroundColor3 = active and window.Theme.TabActive or window.Theme.Surface
						if itemChecks[key] then
							itemChecks[key].Visible = active
						end
					end
				end

				local function setOpen(nextOpen)
					open = nextOpen == true
					local searchHeight = searchable and 35 or 0
					listHeight = open and (searchHeight + (filteredCount * 41)) or 0
					if open then
						list.Visible = true
					end
					tween(row, {
						Size = UDim2.new(1, 0, 0, 44 + listHeight),
					}, 0.16)
					tween(list, {
						Size = UDim2.new(1, -24, 0, listHeight),
					}, 0.16)
					tween(arrow, {
						Rotation = open and 0 or (discordCollapse and -90 or 0),
					}, 0.16)
					if not open then
						task.delay(0.16, function()
							if list.Parent and not open then
								list.Visible = false
							end
						end)
					end
				end

				local function rebuild()
					for _, child in ipairs(list:GetChildren()) do
						if child:IsA("GuiObject") and child ~= searchBox then
							child:Destroy()
						end
					end

					itemButtons = {}
					itemChecks = {}
					filteredCount = 0

					local normalizedQuery = string.lower(searchQuery)
					for index, item in ipairs(items) do
						local itemKey = tostring(item)
						local matches = normalizedQuery == "" or string.find(string.lower(itemKey), normalizedQuery, 1, true) ~= nil
						local itemButton = styledBackground(make("TextButton", {
							AutoButtonColor = false,
							BorderSizePixel = 0,
							Font = DarkUI.Fonts.Bold,
							LayoutOrder = searchable and (index + 1) or index,
							Size = UDim2.new(1, 0, 0, 36),
							Text = "",
							TextSize = 10,
							Visible = matches,
							Parent = list,
						}, {
							corner(5),
						}), "Surface")

						styledText(DarkUI:Text({
							Font = DarkUI.Fonts.Bold,
							Parent = itemButton,
							Position = UDim2.fromOffset(12, 0),
							Size = UDim2.new(1, -48, 1, 0),
							Text = itemKey,
							TextSize = 14,
						}), "Text")

						local itemCheck = make("Frame", {
							AnchorPoint = Vector2.new(1, 0.5),
							BackgroundTransparency = 1,
							Position = UDim2.new(1, -9, 0.5, 0),
							Size = UDim2.fromOffset(20, 20),
							Visible = false,
							Parent = itemButton,
						}, {
							styledBackground(make("Frame", {
								AnchorPoint = Vector2.new(0.5, 0.5),
								BorderSizePixel = 0,
								Position = UDim2.fromOffset(7, 12),
								Rotation = 45,
								Size = UDim2.fromOffset(8, 3),
							}, {
								corner(999),
							}), "Accent"),
							styledBackground(make("Frame", {
								AnchorPoint = Vector2.new(0.5, 0.5),
								BorderSizePixel = 0,
								Position = UDim2.fromOffset(13, 9),
								Rotation = -45,
								Size = UDim2.fromOffset(14, 3),
							}, {
								corner(999),
							}), "Accent"),
						})

						itemButtons[itemKey] = itemButton
						itemChecks[itemKey] = itemCheck
						if matches then
							filteredCount += 1
						end
						attachHover(itemButton, "Surface", "PanelLight", 1.01)
						attachPress(itemButton, 0.96)
						connect(itemButton.MouseLeave, function()
							local active = multi and selected[itemKey] == true or tostring(selected) == itemKey
							tween(itemButton, {
								BackgroundColor3 = active and window.Theme.TabActive or window.Theme.Surface,
							}, 0.1)
						end)

						connect(itemButton.MouseButton1Click, function()
							if control.Disabled then
								return
							end

							if multi then
								selected[itemKey] = not selected[itemKey]
								control:Set(selectedList())
							else
								control:Set(item)
								setOpen(false)
							end
						end)
					end

					if open then
						setOpen(true)
					end
				end

				control = buildControlApi(row, renderText)

				function control:Set(nextValue, silent)
					if multi then
						selected = {}
						for _, item in ipairs(nextValue or {}) do
							selected[tostring(item)] = true
						end
					else
						selected = nextValue
					end

					renderText()
					if not silent then
						safe(options.Callback, self:Get())
						self:_fire(self:Get())
					end
				end

				function control:Get()
					return multi and selectedList() or selected
				end

				function control:SetItems(nextItems)
					items = nextItems or {}
					rebuild()
					setOpen(open)
				end

				connect(button.MouseButton1Click, function()
					if not control.Disabled then
						setOpen(not open)
					end
				end)

				if searchBox then
					connect(searchBox:GetPropertyChangedSignal("Text"), function()
						searchQuery = searchBox.Text or ""
						rebuild()
						renderText()
					end)
				end

				rebuild()
				renderText()
				setOpen(false)
				registerRenderer(renderText)
				window:RegisterConfig(options.Flag, control)
				window:AttachTooltip(row, options.Tooltip)
				return control
			end

			function sectionApi:AddDropdown(options)
				return makeDropdown(options, false)
			end

			function sectionApi:AddMultiDropdown(options)
				return makeDropdown(options, true)
			end

			function sectionApi:AddTextBox(options)
				options = options or {}
				local row = createRow(options, 44)

				styledText(DarkUI:Text({
					Font = DarkUI.Fonts.Bold,
					Parent = row,
					Position = UDim2.fromOffset(12, 0),
					Size = UDim2.new(0.42, -12, 1, 0),
					Text = options.Title or "Text",
					TextSize = 14,
				}), "Text")

				local boxStroke = styledStroke(stroke(window.Theme.Stroke, 0.55, 1), "Stroke")
				local box = styledBackground(make("TextBox", {
					AnchorPoint = Vector2.new(1, 0.5),
					BorderSizePixel = 0,
					ClearTextOnFocus = false,
					Font = DarkUI.Fonts.Bold,
					PlaceholderColor3 = window.Theme.Muted,
					PlaceholderText = options.Placeholder or "Type...",
					Position = UDim2.new(1, -12, 0.5, 0),
					Size = UDim2.new(0.58, -8, 0, 28),
					Text = options.Default or "",
					TextSize = 13,
					Parent = row,
				}, {
					corner(6),
					make("UIPadding", {
						PaddingLeft = UDim.new(0, 8),
						PaddingRight = UDim.new(0, 8),
					}),
					boxStroke,
				}), "Surface")
				styledText(box, "Text")

				local control = buildControlApi(row)
				function control:Set(text, silent)
					box.Text = tostring(text or "")
					if not silent then
						safe(options.Callback, box.Text)
						self:_fire(box.Text)
					end
				end

				function control:Get()
					return box.Text
				end

				connect(box.FocusLost, function()
					tween(boxStroke, {
						Color = window.Theme.Stroke,
						Transparency = 0.55,
					}, 0.12)
					if not control.Disabled then
						control:Set(box.Text)
					end
				end)

				connect(box.Focused, function()
					if not control.Disabled then
						tween(boxStroke, {
							Color = window.Theme.Accent,
							Transparency = 0.1,
						}, 0.12)
						pop(box, 0.985)
					end
				end)

				window:RegisterConfig(options.Flag, control)
				window:AttachTooltip(row, options.Tooltip)
				return control
			end

			function sectionApi:AddKeybind(options)
				options = options or {}
				local key = options.Default or Enum.KeyCode.RightShift
				local listening = false
				local row = createRow(options, 44)

				styledText(DarkUI:Text({
					Font = DarkUI.Fonts.Bold,
					Parent = row,
					Position = UDim2.fromOffset(12, 0),
					Size = UDim2.new(1, -120, 1, 0),
					Text = options.Title or "Keybind",
					TextSize = 14,
				}), "Text")

				local keyButton = styledBackground(make("TextButton", {
					AnchorPoint = Vector2.new(1, 0.5),
					AutoButtonColor = false,
					BorderSizePixel = 0,
					Font = DarkUI.Fonts.Bold,
					Position = UDim2.new(1, -12, 0.5, 0),
					Size = UDim2.fromOffset(96, 28),
					Text = key.Name,
					TextSize = 13,
					Parent = row,
				}, {
					corner(6),
					styledStroke(stroke(window.Theme.Stroke, 0.55, 1), "Stroke"),
				}), "Surface")
				styledText(keyButton, "Text")
				attachHover(keyButton, "Surface", "PanelLight", 1.02)
				attachPress(keyButton, 0.94)

				local control = buildControlApi(row)
				function control:Set(nextKey, silent)
					if typeof(nextKey) == "EnumItem" then
						key = nextKey
					elseif type(nextKey) == "string" and Enum.KeyCode[nextKey] then
						key = Enum.KeyCode[nextKey]
					end

					keyButton.Text = key.Name
					if not silent then
						safe(options.Callback, key)
						self:_fire(key)
					end
				end

				function control:Get()
					return key.Name
				end

				connect(keyButton.MouseButton1Click, function()
					if control.Disabled then
						return
					end
					listening = true
					keyButton.Text = "..."
					pop(keyButton, 0.9)
				end)

				connect(UserInputService.InputBegan, function(input, processed)
					if listening and not processed and input.KeyCode ~= Enum.KeyCode.Unknown then
						listening = false
						control:Set(input.KeyCode)
					elseif not listening and not processed and input.KeyCode == key then
						safe(options.Pressed or options.Callback, key)
					end
				end)

				window:RegisterConfig(options.Flag, control)
				window:AttachTooltip(row, options.Tooltip)
				return control
			end

			function sectionApi:AddColorPicker(options)
				options = options or {}
				local colors = options.Colors or {
					Color3.fromRGB(173, 206, 255),
					Color3.fromRGB(96, 165, 250),
					Color3.fromRGB(52, 211, 153),
					Color3.fromRGB(168, 85, 247),
					Color3.fromRGB(248, 93, 106),
					Color3.fromRGB(250, 204, 21),
					Color3.fromRGB(232, 236, 243),
				}
				local selected = normalizeColor(options.Default, colors[1])
				local row = createRow(options, 72)

				styledText(DarkUI:Text({
					Font = DarkUI.Fonts.Bold,
					Parent = row,
					Position = UDim2.fromOffset(12, 6),
					Size = UDim2.new(1, -58, 0, 18),
					Text = options.Title or "Color",
					TextSize = 14,
				}), "Text")

				local preview = make("Frame", {
					AnchorPoint = Vector2.new(1, 0),
					BackgroundColor3 = selected,
					BorderSizePixel = 0,
					Position = UDim2.new(1, -12, 0, 8),
					Size = UDim2.fromOffset(28, 16),
					Parent = row,
				}, {
					corner(5),
					styledStroke(stroke(window.Theme.Stroke, 0.25, 1), "Stroke"),
				})

				local swatches = make("Frame", {
					BackgroundTransparency = 1,
					Position = UDim2.fromOffset(12, 34),
					Size = UDim2.new(1, -24, 0, 28),
					Parent = row,
				}, {
					make("UIListLayout", {
						FillDirection = Enum.FillDirection.Horizontal,
						Padding = UDim.new(0, 7),
						SortOrder = Enum.SortOrder.LayoutOrder,
					}),
				})

				local control = buildControlApi(row)
				function control:Set(color, silent)
					selected = normalizeColor(color, selected)
					tween(preview, {
						BackgroundColor3 = selected,
					}, 0.12)
					pop(preview, 0.86)
					if not silent then
						safe(options.Callback, selected)
						self:_fire(selected)
					end
				end

				function control:Get()
					return colorToTable(selected)
				end

				for index, color in ipairs(colors) do
					local swatch = make("TextButton", {
						AutoButtonColor = false,
						BackgroundColor3 = color,
						BorderSizePixel = 0,
						LayoutOrder = index,
						Size = UDim2.fromOffset(26, 26),
						Text = "",
						Parent = swatches,
					}, {
						corner(6),
						styledStroke(stroke(window.Theme.Stroke, 0.25, 1), "Stroke"),
					})
					attachHover(swatch, nil, nil, 1.12)
					attachPress(swatch, 0.82)

					connect(swatch.MouseButton1Click, function()
						if not control.Disabled then
							control:Set(color)
						end
					end)
				end

				window:RegisterConfig(options.Flag, control)
				window:AttachTooltip(row, options.Tooltip)
				return control
			end

			function sectionApi:AddStatGrid(names)
				local statGrid = make("Frame", {
					BackgroundTransparency = 1,
					LayoutOrder = self:NextOrder(),
					Size = UDim2.new(1, 0, 0, math.ceil(#names / 3) * 52),
					Parent = bodyFrame,
				}, {
					make("UIGridLayout", {
						CellPadding = UDim2.fromOffset(10, 10),
						CellSize = UDim2.new(0.333, -8, 0, 42),
						FillDirectionMaxCells = 3,
						SortOrder = Enum.SortOrder.LayoutOrder,
					}),
				})
				addSearchRow(statGrid, table.concat(names, " "))

				local stats = {}
				for index, name in ipairs(names) do
					local stat = styledBackground(make("Frame", {
						BorderSizePixel = 0,
						LayoutOrder = index,
						Parent = statGrid,
					}, {
						corner(9),
						styledStroke(stroke(window.Theme.Stroke, 0.62, 1), "Stroke"),
					}), "Panel")
					attachHover(stat, "Panel", "PanelLight")

					styledText(DarkUI:Text({
						Font = DarkUI.Fonts.Bold,
						Parent = stat,
						Position = UDim2.fromOffset(10, 4),
						Size = UDim2.new(1, -20, 0, 14),
						Text = name,
						TextSize = 11,
					}), "Muted")

					local valueLabel = styledText(DarkUI:Text({
						Font = DarkUI.Fonts.Bold,
						Parent = stat,
						Position = UDim2.fromOffset(10, 20),
						Size = UDim2.new(1, -20, 0, 18),
						Text = "--",
						TextSize = 15,
					}), "Text")

					stats[name] = {
						Label = valueLabel,
						Set = function(_, nextValue, color)
							valueLabel.Text = tostring(nextValue)
							valueLabel.TextColor3 = color or window.Theme.Text
						end,
					}
				end

				return stats
			end

			function sectionApi:AddThemeManager()
				local themes = {}
				for name in pairs(DarkUI.ThemePresets) do
					table.insert(themes, name)
				end

				self:AddDropdown({
					Title = "Theme",
					Items = themes,
					Default = window.ThemeName,
					Flag = "ui_theme",
					Callback = function(value)
						window:SetTheme(value)
					end,
				})

				self:AddColorPicker({
					Title = "Accent",
					Default = window.Theme.Accent,
					Flag = "ui_accent",
					Callback = function(color)
						window:SetAccentColor(color)
					end,
				})
			end

			function sectionApi:AddConfigManager()
				local configName = self:AddTextBox({
					Title = "Config",
					Default = string.gsub(window.ConfigName, "%.json$", ""),
					Placeholder = "default",
				})

				self:AddButton({
					Title = "Save Config",
					Callback = function()
						window:SaveConfig(configName:Get())
					end,
				})

				self:AddButton({
					Title = "Load Config",
					Callback = function()
						window:LoadConfig(configName:Get())
					end,
				})

				self:AddButton({
					Title = "Delete Config",
					Callback = function()
						window:Confirm({
							Title = "Delete Config",
							Text = "Delete this config profile?",
							ConfirmText = "Delete",
							Callback = function()
								window:DeleteConfig(configName:Get())
							end,
						})
					end,
				})
			end

			return sectionApi
		end

		connect(tabButton.MouseButton1Click, function()
			window:SelectTab(tabName)
		end)

		if not self.SelectedTab then
			self:SelectTab(tabName)
		end

		return tab
	end

	function window:AddThemeManager(section)
		if section and section.AddThemeManager then
			section:AddThemeManager()
		end
	end

	function window:AddConfigManager(section)
		if section and section.AddConfigManager then
			section:AddConfigManager()
		end
	end

	function window:Destroy()
		if self.Destroyed then
			return
		end

		self.Destroyed = true
		for _, connection in ipairs(self.Connections) do
			pcall(function()
				connection:Disconnect()
			end)
		end

		self.Connections = {}
		tween(rootScale, { Scale = 0.94 }, 0.12)
		tween(root, { BackgroundTransparency = 1 }, 0.12)
		tween(shadow, { BackgroundTransparency = 1 }, 0.12)
		tween(glow, { BackgroundTransparency = 1 }, 0.12)
		task.delay(0.14, function()
			if screenGui.Parent then
				screenGui:Destroy()
			end
		end)
	end

	local expanded = true
	connect(minimizeButton.MouseButton1Click, function()
		expanded = not expanded
		minimizeButton.Text = expanded and "-" or "+"
		body.Visible = expanded
		tween(root, { Size = expanded and windowSize or collapsedSize }, 0.2)
		tween(shadow, { Size = expanded and windowSize or collapsedSize }, 0.2)
		tween(glow, { Size = expanded and glowSize(windowSize) or glowSize(collapsedSize) }, 0.2)
	end)

	connect(closeButton.MouseButton1Click, function()
		window:Confirm({
			Title = "Close UI",
			Text = "Close this window?",
			ConfirmText = "Close",
			Callback = function()
				window:Destroy()
			end,
		})
	end)

	local dragging = false
	local resizing = false
	local dragStart
	local startPosition
	local resizeStart
	local resizeStartSize
	local resizeStartPosition

	local function setWindowGeometry(size, position)
		windowSize = size
		collapsedSize = UDim2.fromOffset(windowSize.X.Offset, headerHeight)
		root.Size = expanded and windowSize or collapsedSize
		shadow.Size = root.Size
		glow.Size = glowSize(root.Size)

		if position then
			root.Position = position
			shadow.Position = UDim2.new(position.X.Scale, position.X.Offset + 6, position.Y.Scale, position.Y.Offset + 6)
			glow.Position = position
		end
	end

	connect(header.InputBegan, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			if resizing then
				return
			end
			dragging = true
			dragStart = input.Position
			startPosition = root.Position
		end
	end)

	connect(resizeHandle.InputBegan, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			if not expanded then
				expanded = true
				minimizeButton.Text = "-"
				body.Visible = true
			end

			resizing = true
			dragging = false
			resizeStart = input.Position
			resizeStartSize = windowSize
			resizeStartPosition = root.Position
			tween(getScale(resizeHandle), { Scale = 1.1 }, 0.1)
		end
	end)

	connect(UserInputService.InputChanged, function(input)
		if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then
			return
		end

		if resizing then
			local delta = input.Position - resizeStart
			local nextWidth = math.max(minWindowSize.X, resizeStartSize.X.Offset + delta.X)
			local nextHeight = math.max(minWindowSize.Y, resizeStartSize.Y.Offset + delta.Y)
			local nextPosition = UDim2.new(
				resizeStartPosition.X.Scale,
				resizeStartPosition.X.Offset + ((nextWidth - resizeStartSize.X.Offset) / 2),
				resizeStartPosition.Y.Scale,
				resizeStartPosition.Y.Offset + ((nextHeight - resizeStartSize.Y.Offset) / 2)
			)
			setWindowGeometry(UDim2.fromOffset(nextWidth, nextHeight), nextPosition)
		elseif dragging then
			local delta = input.Position - dragStart
			local nextPosition = UDim2.new(
				startPosition.X.Scale,
				startPosition.X.Offset + delta.X,
				startPosition.Y.Scale,
				startPosition.Y.Offset + delta.Y
			)
			root.Position = nextPosition
			shadow.Position = UDim2.new(nextPosition.X.Scale, nextPosition.X.Offset + 6, nextPosition.Y.Scale, nextPosition.Y.Offset + 6)
			glow.Position = nextPosition
		end
	end)

	connect(UserInputService.InputEnded, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
			if resizing then
				resizing = false
				tween(getScale(resizeHandle), { Scale = 1 }, 0.12)
			end
		end
	end)

	connect(UserInputService.InputBegan, function(input, processed)
		if not processed and input.KeyCode == (config.ToggleKey or Enum.KeyCode.RightShift) then
			screenGui.Enabled = not screenGui.Enabled
		end
	end)

	window:_applyTheme()
	return window
end

return DarkUI
