IF DB_ID('DepoYonetim') IS NOT NULL
	BEGIN
		ALTER DATABASE [DepoYonetim] SET SINGLE_USER WITH ROLLBACK IMMEDIATE
		USE master
		DROP DATABASE DepoYonetim
	END
GO

CREATE DATABASE DepoYonetim
	ON PRIMARY (
					NAME = 'DepoYonetimdb',
					FILENAME = 'c:\database\DepoYonetim_db.mdf',
					SIZE = 5MB,
					MAXSIZE = 100MB,
					FILEGROWTH = 5MB
				)
	LOG ON		(
					NAME = 'DepoYonetimdb_log',
					FILENAME = 'c:\database\DepoYonetim_log.ldf',
					SIZE = 2MB,
					MAXSIZE = 50MB,
					FILEGROWTH = 1MB
				)
GO

USE DepoYonetim

-- Bu tabloda il isimleri tutulur.
CREATE TABLE tblIl
(
	Kod Char(2) PRIMARY KEY,
	Ad VARCHAR(20) NOT NULL
)
GO

--Bu tabloda her bir ile ait ilceler tutulur.
CREATE TABLE tblIlce
(
	ID INT IDENTITY(1,1) PRIMARY KEY,
	Ad VARCHAR(20) NOT NULL,
	IlKodu CHAR(2) FOREIGN KEY REFERENCES tblIl(Kod)
		ON DELETE CASCADE ON UPDATE CASCADE NOT NULL
)
GO

--Bu tabloda sparis veren Mustesi bilgileri tutulur.
CREATE TABLE tblMusteri
(
	ID INT IDENTITY(1,1) PRIMARY KEY,
	Isim VARCHAR(80) NOT NULL,
	Adres VARCHAR(150),
	Tel CHAR(10) CONSTRAINT chkMusteriTel CHECK (Tel LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'),-- Telefon numarasi '5054653515' gibi 10 basamakli sayilardan olusmali.
	MusteriTip SMALLINT NOT NULL -- 0: Satin Alan, 1: Tedarikci
)
GO
--Bu tabloda Depo bilgileri tutulmakta.
CREATE TABLE tblDepo
(
	ID INT IDENTITY(1,1) PRIMARY KEY,
	Ad VARCHAR(80) UNIQUE NOT NULL,
	PaletKapisitesi INT DEFAULT NULL,
	ToplamGozKapasitesi INT DEFAULT NULL,
	IlID CHAR(2) FOREIGN KEY 
		REFERENCES tblIl(Kod) 
		ON DELETE NO ACTION
		ON UPDATE NO ACTION,
	IlceID INT FOREIGN KEY 
		REFERENCES tblIlce(ID) 
		ON DELETE SET NULL
		ON UPDATE CASCADE
)
GO
--Bu tabloda Musterinin verdigi siparis tablosu tutulmakta.
CREATE TABLE tblSiparis
(
	ID INT IDENTITY(1,1) PRIMARY KEY,
	Tarih DATETIME DEFAULT GETDATE() NOT NULL,
	ToplamTutar FLOAT DEFAULT NULL,
	SiparisTipi SMALLINT NOT NULL, -- 0: Sparis verilir, 1: Sparis Alinir
	DepoID INT FOREIGN KEY REFERENCES TblDepo(ID) NOT NULL,
	MusteriID INT FOREIGN KEY 
		REFERENCES tblMusteri(ID) 
		ON DELETE SET DEFAULT 
		ON UPDATE CASCADE
)
GO
-- Bu tabloda Depo icerisindeki adres bilgileri bulunmakta
CREATE TABLE tblAdres
(
	ID INT IDENTITY(1,1) PRIMARY KEY,
	AdresTipi SMALLINT NOT NULL, -- 0: Depolama Gozu, 1: Toplama Gozu
	DepolamaKapisitesi INT DEFAULT NULL,
	AdresKodu VARCHAR(80) NOT NULL,
	DepoID INT FOREIGN KEY 
		REFERENCES tblDepo(ID) 
		ON DELETE CASCADE 
		ON UPDATE CASCADE NOT NULL
)
GO
-- Bu tabloda Urune ait katagori bilgisi tutulmakta.
CREATE TABLE tblKategori
(
	ID INT IDENTITY(1,1) PRIMARY KEY,
	Ad VARCHAR(80) NOT NULL,
	Aciklama VARCHAR(1000)
)
GO
-- Bu tabloda Urunu ureten uretici bilgileri tutulmakta.
CREATE TABLE tblUretici
(
	ID INT IDENTITY(1,1) PRIMARY KEY,
	Ad VARCHAR(80) NOT NULL,
	Adres VARCHAR(150),
	Tel CHAR(10) CONSTRAINT chkUreticiTel CHECK (Tel LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]')-- Telefon numarasi '5054653515' gibi 10 basamakli sayilardan olusmali.
)
GO
--Bu tabloda Urunle ilgili bilgiler tutulmakta.
CREATE TABLE tblUrun
(
	ID INT IDENTITY(1,1) PRIMARY KEY,
	Ad VARCHAR(80) NOT NULL,
	Aciklama VARCHAR(1000),
	Fotograf VARCHAR(150), -- Resimin disk icerisindeki butun adresi tutulur
	Boyut VARCHAR(20) CONSTRAINT chkUrunBoyut CHECK (Boyut LIKE '%[Xx]%'), -- 'yatay olcu (m) x dikey olcu (m) seklinde boyut tanimlanmali'
	Agirlik FLOAT,--(kg)
	Fiyat DECIMAL(10,2) NOT NULL,
	UreticiID INT FOREIGN KEY 
		REFERENCES tblUretici(ID) 
		ON DELETE SET NULL
		ON UPDATE CASCADE,
	KategoriID INT FOREIGN KEY 
		REFERENCES tblKategori(ID) 
		ON DELETE SET NULL
		ON UPDATE CASCADE,
	AdresID INT FOREIGN KEY 
		REFERENCES tblAdres(ID) 
		ON DELETE SET DEFAULT
		ON UPDATE CASCADE
)
GO
--Bu tabloda Mal alimini vede yerlestirmeyi yapan personel bilgileri tutulmakta
CREATE TABLE tblPersonel
(
	ID INT IDENTITY(1,1) PRIMARY KEY,
	Ad VARCHAR(50) NOT NULL,
	Adres VARCHAR(150),
	Maas DECIMAL(15,2) NOT NULL,
	Tel CHAR(10) UNIQUE CONSTRAINT chkPersonelTel CHECK (Tel LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]')-- Telefon numarasi '5054653515' gibi 10 basamakli sayilardan olusmali.
)
GO
--Bu tabloda stok fisi bilgileri bulunmakta
CREATE TABLE tblStokFisi
(
	ID INT IDENTITY(1,1) PRIMARY KEY,
	GirisTarihi DATETIME DEFAULT GETDATE() NOT NULL,
	CikisTarihi DATETIME DEFAULT NULL,
	SiparisID INT FOREIGN KEY 
		REFERENCES tblSiparis(ID) 
		ON DELETE SET NULL
		ON UPDATE CASCADE,
	GirisDepoID INT FOREIGN KEY 
		REFERENCES tblDepo(ID) 
		ON DELETE SET NULL
		ON UPDATE CASCADE,
	CikisDepoID INT FOREIGN KEY 
		REFERENCES tblDepo(ID) 
		ON DELETE NO ACTION
		ON UPDATE NO ACTION,
	PersonelID INT FOREIGN KEY 
		REFERENCES tblPersonel 
		ON DELETE SET NULL
		ON UPDATE CASCADE
)
GO
--Bu tabloda urunun hangi birimde olduguna dair bilgileri bulunmakta.
CREATE TABLE tblBirimSeti
(
	ID INT IDENTITY(1,1) PRIMARY KEY,
	Ad VARCHAR(50) NOT NULL,
	AnaBirim VARCHAR(20) NOT NULL,
	CevrimKatsayisi INT NOT NULL,
	StokFisiID INT FOREIGN KEY 
		REFERENCES tblStokFisi(ID)
		ON DELETE SET NULL
		ON UPDATE CASCADE,
	UrunID INT FOREIGN KEY 
		REFERENCES tblUrun(ID)
		ON DELETE NO ACTION
		ON UPDATE NO ACTION
)

GO
--Bu tabloda Birim setine ait olan barkod numaralari yer almakta.\
CREATE TABLE tblBarkod
(
	ID INT IDENTITY(1,1) PRIMARY KEY,
	BarkodNo INT  UNIQUE NOT NULL,
	BirimSetiID INT FOREIGN KEY 
		REFERENCES tblBirimSeti(ID)
		ON DELETE CASCADE
		ON UPDATE CASCADE
)

GO
--Bu tabloda Mal alimi surecindeki bilgiler bulunmakta. - SonKullanma tarihini olustururken bir sorun var 2021 ve sonrasini insert ederken 2020'ye yuvarlama yapiyor yil olarak.
CREATE TABLE tblMalAlim
(
	ID INT IDENTITY(1,1) PRIMARY KEY,
	AlimTarihi DATETIME DEFAULT GETDATE() NOT NULL,
	Miktar INT NOT NULL,
	SonKullanmaTarihi DATE DEFAULT GETDATE() NOT NULL,
	PaletKodu INT NOT NULL,
	PersonelID INT FOREIGN KEY 
		REFERENCES tblPersonel(ID) 
		ON DELETE SET NULL
		ON UPDATE CASCADE,
	AdresID INT FOREIGN KEY 
		REFERENCES tblAdres(ID) 
		ON DELETE SET NULL
		ON UPDATE CASCADE,
	UrunID INT FOREIGN KEY 
		REFERENCES tblUrun(ID) 
		ON DELETE NO ACTION
		ON UPDATE NO ACTION,
	StokFisiID INT FOREIGN KEY
		REFERENCES tblStokFisi(ID)
		ON DELETE NO ACTION
		ON UPDATE NO ACTION,
	BirimSetiID INT FOREIGN KEY 
		REFERENCES tblBirimSeti(ID) 
		ON DELETE NO ACTION
		ON UPDATE NO ACTION
)
GO
--Bu tabloda Mal alindiktan sonra veya personelin yerlistirme surecindeki bigiler tutulmakta.
CREATE TABLE tblYerlestirme
(
	ID INT IDENTITY(1,1) PRIMARY KEY,
	Tarih1 DATETIME DEFAULT GETDATE() NOT NULL,
	Tarih2 DATETIME DEFAULT GETDATE() NOT NULL,
	Miktar INT NOT NULL,
	PersonelID INT FOREIGN KEY 
		REFERENCES tblPersonel(ID)
		ON DELETE SET NULL
		ON UPDATE CASCADE,
	MalAlimID INT FOREIGN KEY 
		REFERENCES tblMalAlim(ID) 
		ON DELETE NO ACTION
		ON UPDATE NO ACTION,
	AdresID INT FOREIGN KEY 
		REFERENCES tblAdres(ID) 
		ON DELETE SET NULL
		ON UPDATE SET NULL
)
GO
--Bu tabloda birim seti, siparis, urun arasinda dogan iliskideki miktar bilgilerinin tutmaktadir.
GO
CREATE TABLE tblMiktarUrunBirimSiparis
(
	ID INT IDENTITY(1,1) PRIMARY KEY,
	Miktar INT NOT NULL,
	UrunID INT FOREIGN KEY 
		REFERENCES tblUrun(ID) 
		ON DELETE SET NULL
		ON UPDATE CASCADE,
	SiparisID INT FOREIGN KEY 
		REFERENCES tblSiparis(ID)
		ON DELETE SET NULL
		ON UPDATE CASCADE,
	BirimSetiID INT FOREIGN KEY 
		REFERENCES tblBirimSeti(ID) 
		ON DELETE NO ACTION
		ON UPDATE NO ACTION
)
GO
--Bu tabloda urunlerin depoda nasil tutulacagina iliskisi uzerine bilgiler tutulmaktadir.
CREATE TABLE tblUrunAdresTutulma
(
	ID INT IDENTITY(1,1) PRIMARY KEY,
	PaletKodu INT UNIQUE NOT NULL,
	Miktar INT NOT NULL,
	SonKullanmaTarihi DATE NOT NULL,
	AdresID INT FOREIGN KEY 
		REFERENCES tblAdres(ID)
		ON DELETE NO ACTION
		ON UPDATE NO ACTION,
	UrunID INT FOREIGN KEY 
		REFERENCES tblUrun(ID)
		ON DELETE SET NULL
		ON UPDATE CASCADE
)
GO
--Bu tabloda Urubler hangi depolara ait iliskisi uzerine bilgiler tutlmaktadir.
CREATE TABLE tblUrunDepoBulunur
(
	ID INT IDENTITY(1,1) PRIMARY KEY,
	Miktar INT NOT NULL,
	UrunID INT FOREIGN KEY 
		REFERENCES tblUrun(ID)
		ON DELETE SET NULL
		ON UPDATE CASCADE,
	DepoID INT FOREIGN KEY 
		REFERENCES tblDepo(ID)
		ON DELETE NO ACTION
		ON UPDATE NO ACTION
)
GO