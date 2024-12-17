CREATE DATABASE DE3

CREATE TABLE DOCGIA(
	MaDG char(5) PRIMARY KEY,
	HoTen varchar(30),
	NgaySinh smalldatetime,
	DiaChi varchar(30),
	SoDT varchar(15)
)

CREATE TABLE SACH(
	MaSach char(5) PRIMARY KEY,
	TenSach varchar(25),
	TheLoai varchar(25),
	NhaXuatBan varchar(30)
)

CREATE TABLE PHIEUTHUE(
	MaPT char(5) PRIMARY KEY,
	MaDG char(5),
	NgayThue smalldatetime,
	NgayTra smalldatetime,
	SoSachThue int
	FOREIGN KEY(MaDG) REFERENCES DOCGIA(MaDG)
)

CREATE TABLE CHITIET_PT(
	MaPT char(5),
	MaSach char(5),
	PRIMARY KEY(MaPT, MaSach),
	FOREIGN KEY(MaPT) REFERENCES PHIEUTHUE(MaPT),
	FOREIGN KEY(MaSach) REFERENCES SACH(MaSach)
)

-- 2.1
	CREATE TRIGGER TRG_PHIEUTHUE_UpdateInsert ON PHIEUTHUE FOR UPDATE, INSERT
	AS BEGIN
		DECLARE @NgayThue smalldatetime, @NgayTra smalldatetime

		SELECT @NgayThue = NgayThue, @NgayTra = NgayTra
		FROM inserted

		IF (DATEDIFF(day, @NgayThue, @NgayTra) > 10)
			BEGIN
				ROLLBACK TRAN
				RAISERROR('Thao tac khong thanh cong!', 16, 1)
			END
		ELSE
			BEGIN
				PRINT('Thao tac thanh cong!')
			ENd
	END
	--------------------------------------------------------
	ALTER TABLE PHIEUTHUE
	ADD CONSTRAINT CHK_PHIEUTHUE CHECK(SoSachThue <= 10);

-- 2.2
/*
					Them		Xoa			Sua
	PHIEUTHUE		+(1)		-			+(SoSachThue)
	CHITIET_PT		+			+			-(*)
*/
	CREATE TRIGGER TRG_CHITIET_PT_Insert ON CHITIET_PT FOR INSERT
	AS BEGIN
		DECLARE @MaPT char(5)

		SELECT @MaPT = MaPT
		FROM inserted

		UPDATE PHIEUTHUE
		SET SoSachThue = (
			SELECT COUNT(DISTINCT ct.MaSach)
			FROM CHITIET_PT ct
			WHERE ct.MaPT = @MaPT
			GROUP BY ct.MaPT
		)
		WHERE MaPT = @MaPT

		PRINT('Thao tac thanh cong!')
	END

	CREATE TRIGGER TRG_CHITIET_PT_Delete ON CHITIET_PT FOR DELETE
	AS BEGIN
		DECLARE @MaPT char(5)

		SELECT @MaPT = MaPT
		FROM deleted

		UPDATE PHIEUTHUE
		SET SoSachThue = (
			SELECT COUNT(DISTINCT ct.MaSach)
			FROM CHITIET_PT ct
			WHERE ct.MaPT = @MaPT
			GROUP BY ct.MaPT
		)
		WHERE MaPT = @MaPT

		PRINT('Thao tac thanh cong!')
	END

-- 3.1
	SELECT dg.MaDG, HoTen
	FROM DOCGIA dg
	JOIN PHIEUTHUE pt ON dg.MaDG = pt.MaDG
	JOIN CHITIET_PT ct ON ct.MaPT = pt.MaPT
	JOIN SACH s ON s.MaSach = ct.MaSach
	WHERE TheLoai = N'Tin học' AND YEAR(NgayThue) = 2007;

-- 3.2
	SELECT TOP 1 WITH TIES dg.MaDG, HoTen
	FROM DOCGIA dg
	JOIN PHIEUTHUE pt ON dg.MaDG = pt.MaDG
	JOIN CHITIET_PT ct ON ct.MaPT = pt.MaPT
	JOIN SACH s ON s.MaSach = ct.MaSach
	GROUP BY dg.MaDG, HoTen
	ORDER BY COUNT(DISTINCT TheLoai) DESC;

-- 3.3
	SELECT TheLoai, TenSach
	FROM SACH s
	JOIN CHITIET_PT ct ON s.MaSach = ct.MaSach
	GROUP BY TheLoai, TenSach
	HAVING COUNT(DISTINCT ct.MaPT) >= ALL(
		SELECT COUNT(DISTINCT ct2.MaPT)
		FROM SACH s2
		JOIN CHITIET_PT ct2 ON ct2.MaSach = s2.MaSach
		WHERE s.TheLoai = s2.TheLoai
		GROUP BY ct2.MaPT
	)