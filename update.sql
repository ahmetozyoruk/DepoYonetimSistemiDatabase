-- Depo ID'si 6 olan depodan cikan siparislerin, eger toplam tutari 5000'den kucuk ise yuzde 15 indirim uygulasin toplam tutar uzerine.
UPDATE tblSiparis
SET ToplamTutar = (SI.ToplamTutar-SI.ToplamTutar*15/100)
FROM tblSiparis SI
WHERE SI.ID IN (SELECT DISTINCT ST.SiparisID 
			FROM tblUrun UR
			INNER JOIN  tblUrunDepoBulunur URDE ON UR.ID = URDE.UrunID 
			iNNER JOIN tblStokFisi ST ON URDE.DepoID = ST.CikisDepoID
			WHERE ST.CikisDepoID = 6 ) AND SI.ToplamTutar < 5000

-- Mal alimini en cok gerceklestirmis olan personelin maasi 8000 tl'nin altindaysa ve yerlestirmede yaptiysa maasina maasina yuxde 5 zam yapilacak. 
UPDATE tblPersonel
SET Maas = (PE.Maas+ PE.Maas*5/100)
FROM tblPersonel PE
INNER JOIN (SELECT  MA.PersonelID 
				FROM tblMalAlim MA
				GROUP BY MA.PersonelID
				HAVING COUNT(MA.PersonelID) = (SELECT MAX(X.[Mal yerlestirme Sayisi]) 'Max Yerlestirme' FROM (SELECT MA.PersonelID,COUNT(MA.PersonelID) 'Mal yerlestirme Sayisi' 
																											  FROM tblMalAlim MA
																											  GROUP BY MA.PersonelID) X)) TA
ON PE.ID = TA.PersonelID
INNER JOIN tblYerlestirme YE ON PE.ID = YE.PersonelID 

-- Oncelikli cikmasi geregen Malin Adresini bulmak ve yeini degistirmek.
UPDATE tblMalAlim
SET AdresID = 3
FROM tblMalAlim MA
INNER JOIN (SELECT TOP 1 MA.ID,MA.AdresID,DATEDIFF(DY,MA.AlimTarihi,MA.SonKullanmaTarihi) AS 'Kalan Gun'
			FROM tblMalAlim MA
			ORDER BY 'Kalan Gun' ASC) AD 
ON AD.ID = MA.ID

-- Alinan sparislerin degeri 50000 liradan buyuk olup gecen senenin urunleri icerisinde yer aliyorsa aciklamasina "gecenyil ki 5000'den fazla satin alinan tutar." yazisini ekle. (tblSiparis.SiparisTipi: 0: Sparis verilir, 1: Sparis Alinir)
UPDATE tblUrun
SET Aciklama = UR.Aciklama + ' gecenyil ki 5000''den fazla satin alinan tutar.'
FROM tblUrun UR
WHERE UR.ID IN (SELECT URBISI.UrunID
				FROM tblMiktarUrunBirimSiparis URBISI
				WHERE URBISI.SiparisID IN (SELECT SI.ID
								FROM tblSiparis SI
								WHERE SI.SiparisTipi = 1 AND SI.ToplamTutar > 50000 )
				INTERSECT
				SELECT URBISI.UrunID
				FROM tblMiktarUrunBirimSiparis URBISI
				WHERE URBISI.SiparisID IN (SELECT SI.ID
								FROM tblSiparis SI
								WHERE YEAR(SI.Tarih) = YEAR(GETDATE())-1))


--Telefon numarasinin sonu 2,3,7,0 numaralarindan herhangi biri ile biten musterilerin aldiklari ununun acilamasi null olan musterilerin urunlerinin agirliklarina 1 ekle.
UPDATE tblUrun
SET Agirlik = UR.Agirlik+1
FROM tblUrun UR
WHERE UR.ID IN (SELECT URBISI.UrunID
				FROM tblMiktarUrunBirimSiparis URBISI
				WHERE URBISI.SiparisID IN (SELECT SI.ID
											FROM tblSiparis SI
											WHERE SI.MusteriID IN (SELECT MU.ID
													FROM tblMusteri MU
													WHERE MU.Tel LIKE '%2' OR MU.Tel LIKE '%3' OR MU.Tel LIKE '%7' OR MU.Tel LIKE '%0')))
				AND ISNULL(UR.Aciklama,'NULL') = 'NULL'

