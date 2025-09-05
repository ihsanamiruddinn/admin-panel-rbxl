--[[
	Skrip GUI untuk Orion Library
	
	Deskripsi:
	Skrip ini menggunakan pustaka Orion Library untuk membuat antarmuka pengguna
	yang sesuai dengan permintaan Anda, termasuk tata letak dan fungsionalitas.
	Skrip ini akan memuat pustaka dari URL yang disediakan dan kemudian membangun
	jendela GUI dengan elemen-elemen yang diperlukan.
]]

-- === Memuat Pustaka Orion Library ===
local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/jensonhirst/Orion/main/source')))()

-- === Membuat Jendela Utama ===
-- Menggunakan fungsi OrionLib:MakeWindow dari dokumentasi
-- Jendela ini akan menjadi wadah untuk semua tab dan elemen.
local Window = OrionLib:MakeWindow({
	Name = "TripleS Hub", -- Nama jendela
	HidePremium = false, -- Tampilkan status Premium
	SaveConfig = true, -- Aktifkan fitur simpan konfigurasi
	ConfigFolder = "TripleSConfig", -- Folder untuk menyimpan konfigurasi
	IntroEnabled = true, -- Aktifkan animasi pembuka
	IntroText = "Selamat datang, TripleS!", -- Teks animasi
	IntroIcon = "rbxassetid://4483345998", -- Ganti dengan ID ikon Anda
	CloseCallback = function() -- Fungsi yang dipanggil saat jendela ditutup
		OrionLib:MakeNotification({
			Name = "Keluar",
			Content = "Jendela GUI telah ditutup.",
			Image = "rbxassetid://4483345998", -- Ganti dengan ID ikon Anda
			Time = 5
		})
	end
})

-- === Membuat Tab Utama ===
-- Menggunakan fungsi Window:MakeTab
local MainTab = Window:MakeTab({
	Name = "Utama",
	Icon = "rbxassetid://4483345998", -- Ganti dengan ID ikon tab
	PremiumOnly = false
})

-- Menambahkan teks merek "TripleS" di bagian atas
MainTab:AddLabel("TripleS")

-- Menambahkan kotak teks di bawah teks merek
MainTab:AddTextbox({
	Name = "Input",
	Default = "Masukkan teks...",
	TextDisappear = true,
	Callback = function(Value)
		print("Kotak teks utama: " .. Value)
	end	  
})

-- === Bagian Tombol dan Kotak Teks ===
-- Menggunakan AddSection untuk mengelompokkan elemen secara visual
local ButtonSection1 = MainTab:AddSection({
	Name = "Tombol Berdampingan 1"
})

ButtonSection1:AddButton({
	Name = "Tombol 1",
	Callback = function()
      		print("Tombol 1 ditekan")
  	end    
})
ButtonSection1:AddButton({
	Name = "Tombol 2",
	Callback = function()
      		print("Tombol 2 ditekan")
  	end    
})

local ButtonSection2 = MainTab:AddSection({
	Name = "Tombol Berdampingan 2"
})

ButtonSection2:AddButton({
	Name = "Tombol 3",
	Callback = function()
      		print("Tombol 3 ditekan")
  	end    
})
ButtonSection2:AddButton({
	Name = "Tombol 4",
	Callback = function()
      		print("Tombol 4 ditekan")
  	end    
})

local TextboxSection1 = MainTab:AddSection({
	Name = "Kotak Teks 1"
})
TextboxSection1:AddTextbox({
	Name = "Kotak 1",
	Default = "Input 1",
	TextDisappear = false,
	Callback = function(Value)
		print("Kotak Teks 1: " .. Value)
	end	  
})
TextboxSection1:AddTextbox({
	Name = "Kotak 2",
	Default = "Input 2",
	TextDisappear = false,
	Callback = function(Value)
		print("Kotak Teks 2: " .. Value)
	end	  
})

local TextboxSection2 = MainTab:AddSection({
	Name = "Kotak Teks 2"
})
TextboxSection2:AddTextbox({
	Name = "Kotak 3",
	Default = "Input 3",
	TextDisappear = false,
	Callback = function(Value)
		print("Kotak Teks 3: " .. Value)
	end	  
})

-- === Bagian Footer ===
-- Menambahkan tombol-tombol kecil di bagian bawah
local FooterSection = MainTab:AddSection({
	Name = "Footer"
})

FooterSection:AddButton({
	Name = "SETTING",
	Callback = function()
		OrionLib:MakeNotification({Name = "Notifikasi", Content = "Tombol SETTING ditekan!", Time = 3})
	end
})
FooterSection:AddButton({
	Name = "INFO",
	Callback = function()
		OrionLib:MakeNotification({Name = "Notifikasi", Content = "Tombol INFO ditekan!", Time = 3})
	end
})
FooterSection:AddButton({
	Name = "KEYBIND",
	Callback = function()
		OrionLib:MakeNotification({Name = "Notifikasi", Content = "Tombol KEYBIND ditekan!", Time = 3})
	end
})
FooterSection:AddButton({
	Name = "REJOIN",
	Callback = function()
		game:GetService("TeleportService"):Teleport(game.PlaceId, game.Players.LocalPlayer)
	end
})


-- === Wajib: Menginisialisasi Pustaka ===
OrionLib:Init()

