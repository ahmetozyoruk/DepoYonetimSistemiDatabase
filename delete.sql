--Delete Islemleri

--Yalovada oturan personeller  cikarilsin.
DELETE FROM tblPersonel
WHERE ID IN (SELECT PE.ID
			FROM tblPersonel PE
			WHERE PE.Adres LIKE '%yalova%' AND PE.Adres LIKE '%77___%' ) -- Adresin icerisinde ilcelerin kodlari yer aliyor garanti olsun diye hem bu kodlari 
																		 -- ilk iki basamagindaki il koduna vede yalova sozcugu yer aliyorsa silme islemi gerceklestiriliyor


--8 ay onceki yerlestirme tarihlerini veritabanindan sil
DELETE FROM tblYerlestirme															--Tarih1 veya tarih2 programin istemine yerlestirme baslangici olarak secilebir
WHERE  Tarih1 < DATEADD(mm, -8, GETDATE()) AND Tarih2 < DATEADD(mm, -8, GETDATE())	--ondan dolayida her iki tarihi kontrol etme ihtiyaci duydum


-- toplam tutari en az olan 3 siparisi ait oldugu, musterinin soyismi albayrak kullanicilari veya kullaniciyi sil.
DELETE FROM tblMusteri
WHERE ID IN ( SELECT TOP 3 S.MusteriID
			    FROM tblSiparis S
			    ORDER BY S.ToplamTutar DESC)
			   AND Isim LIKE '%albayrak'

----iD'si 10 olan urunun, en dusuk sayida bulundugu depolardan, son 4 ayda siparis edilmis siparislerin icerisinde urun ID'si 10 olan siparisleri sil.
DELETE FROM tblSiparis 
WHERE ID IN (SELECT SI.ID
				FROM  tblSiparis SI
				INNER JOIN  tblMiktarUrunBirimSiparis MUBS ON MUBS.SiparisID = SI.ID
				WHERE SI.DepoID IN (SELECT TOP 6 UD.DepoID
									FROM tblUrunDepoBulunur UD
									WHERE UD.UrunID = 10
									ORDER BY UD.Miktar ASC)
									AND MUBS.UrunID=10
									AND SI.Tarih > DATEADD(mm, -4, GETDATE()))

--Mal alimi yapip yerlestirme yapmamis personeli sil.
DELETE FROM tblPersonel
WHERE ID IN (SELECT DISTINCT MA.PersonelID
				FROM tblYerlestirme YE
				RIGHT JOIN tblMalAlim MA ON MA.PersonelID = YE.PersonelID
				WHERE ISNULL(YE.PersonelID,NULL) IS NULL)




