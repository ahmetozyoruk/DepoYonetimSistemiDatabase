--sorgu islemleri

--Personellerden Mal alimda mal ilimi yapmamis ve yerlestirmede bulunmamis personellerin id'si, ismi (buyuk harfle)
--adresi, telefonu (Formatli), maas (yuvarla, formatla), mal alim ve yertirmedeki 0 oldugunu gosteren column (toplami degil her ikisinin sifir oldugundaki durumu icin gecerli (intersect)) 
SELECT PE.ID, UPPER(PE.Ad) 'Personel Ad Soyad', PE.Adres, '0 (' + LEFT(PE.Tel,3) + ') ' +SUBSTRING(PE.Tel,4,3) 
		+ ' ' + SUBSTRING(PE.Tel,7,2) + ' ' + RIGHT(PE.Tel,2) AS Tel, FORMAT(ROUND(PE.Maas,0),'C','tr-TR') Maas , X.[Yerlestirme Sayisi] 'Mal Alim ve Yerlestrime Sayisi'
FROM tblPersonel PE
INNER JOIN  (SELECT PE.ID, PE.Ad, COUNT(YE.ID) 'Yerlestirme Sayisi'
			FROM tblPersonel PE
			LEFT JOIN tblYerlestirme YE ON YE.PersonelID = PE.ID
			GROUP BY PE.ID , PE.Ad
			HAVING COUNT(YE.ID) = 0
			INTERSECT
			SELECT PE.ID, PE.Ad, COUNT(MA.ID) 'Yerlestirme Sayisi'
			FROM  tblPersonel PE
			LEFT JOIN tblMalAlim MA ON MA.PersonelID= PE.ID
			GROUP BY PE.ID, PE.Ad
			HAVING COUNT(MA.ID) = 0) X ON X.ID = PE.ID

--Satilan Urunlerin Toplam Satilan Urunler Arasindaki yuzdeligi hesapla. 
--Urunun id'si, Adi,Toplam satilma miktarini, Ana Birimini, Butun Urunlerin satilma icerisindeki oranini hesapla
SELECT U.ID, U.Ad, 
	   SUM(MUBS.Miktar*BS.CevrimKatsayisi) 'Satilan Miktar',BS.AnaBirim,
	   FORMAT((SUM(MUBS.Miktar*BS.CevrimKatsayisi) *1.0/ (SELECT SUM(MUBS.Miktar*BS.CevrimKatsayisi) --1.0 ile carpiyorum cunku bolum ve bolunen int olarak geliyor ondan 
													FROM tblMiktarUrunBirimSiparis MUBS				 --dolayi bolumu decimal yapmak icin 1.0 ile carpiyorum.
													INNER JOIN tblBirimSeti BS ON BS.ID = MUBS.BirimSetiID)),'p') 'Satilma Orani'
FROM tblSiparis S
INNER JOIN tblMiktarUrunBirimSiparis MUBS ON MUBS.SiparisID = S.ID
INNER JOIN tblBirimSeti BS ON BS.ID = MUBS.BirimSetiID
INNER JOIN tblUrun U ON U.ID = MUBS.UrunID
GROUP BY U.ID, U.Ad,BS.AnaBirim


--Illere gore depolarda bulunan en cok urun veya urunler nedir ve bunlarin  ureticisi kimdir?
SELECT DISTINCT I.Kod, I.Ad, UR.ID, UR.Ad, UDB.UrunID, SUM(UDB.Miktar) 'Bulunan Urunun Toplam Sayisi'
FROM tblDepo D
INNER JOIN tblIl I ON D.IlID = I.Kod
INNER JOIN tblUrunDepoBulunur UDB ON UDB.DepoID=D.ID
INNER JOIN tblUrun U ON U.ID = UDB.UrunID
INNER JOIN tblUretici UR ON UR.ID = U.UreticiID
GROUP BY I.Kod, I.Ad, UDB.UrunID, UR.ID, UR.Ad
HAVING SUM(UDB.Miktar) IN (SELECT X2.MaxToplam FROM (SELECT X.Ad, MAX(X.MaxToplam) MaxToplam FROM (SELECT I.Kod, I.Ad, UDB.UrunID, SUM(UDB.Miktar) AS MaxToplam FROM tblDepo D
																																	                           INNER JOIN tblIl I ON D.IlID = I.Kod
																																	                           INNER JOIN tblUrunDepoBulunur UDB ON UDB.DepoID=D.ID
																																	                           GROUP BY I.Kod, I.Ad, UDB.UrunID) X
																																	                           GROUP BY X.Ad) X2)
ORDER BY I.Ad ASC


--Kategorilere gore illerdeki urunlerin dagilimi nedir.
SELECT K.ID, K.Ad, COALESCE(IL.Ad,'ildeki Toplam Miktar') il, U.ID,SUM(UDB.Miktar)  'Toplam Adet'
FROM tblUrunDepoBulunur UDB
INNER JOIN tblDepo D ON UDB.DepoID = D.ID
INNER JOIN tblIl IL ON IL.Kod = D.IlID
INNER JOIN tblUrun U ON U.ID = UDB.UrunID
INNER JOIN tblKategori K ON K.ID = U.KategoriID
GROUP BY K.ID, K.Ad,ROLLUP(IL.Ad), U.ID






























