CREATE DATABASE DE4

CREATE TABLE KHACHHANG(
	MaKH char(5) PRIMARY KEY,
	HoTen varchar(30),
	DiaChi varchar(30),
	SoDT varchar(15),
	LoaiKH varchar(10)
)

CREATE TABLE BANG_DIA(
	MaBD char(5) PRIMARY KEY,
	TenBD varchar(25),
	TheLoai varchar(25)
)

CREATE TABLE PHIEUTHUE(
	MaPT char(5) PRIMARY KEY,
	MaKH char(5),
	NgayThue smalldatetime,
	NgayTra smalldatetime,
	SoLuongThue int
	FOREIGN KEY(MaKH) REFERENCES KHACHHANG(MaKH)
)

CREATE TABLE CHITIET_PT(
	MaPT char(5),
	MaBD char(5),
	PRIMARY KEY(MaPT, MaBD),
	FOREIGN KEY(MaPT) REFERENCES PHIEUTHUE(MaPT),
	FOREIGN KEY(MaBD) REFERENCES BANG_DIA(MaBD)
)

-- 2.1
	ALTER TABLE BANG_DIA
	ADD CONSTRAINT CHK_BANGDIA CHECK(TheLoai IN (N'ca nhạc', N'phim hành động', N'phim tình cảm', N'phim hoạt hình'))

-- 2.2
/* 
					Them		Xoa			Sua
	KHACHHANG		+			-			+(LoaiKH)
	PHIEUTHUE		+			-			+(MaKH, SoLuongThue)
	CHITIET_PT		+			-			-(*)
*/

	CREATE TRIGGER TRIGGER_CHITIET_PT_Insert ON CHITIET_PT FOR INSERT
	AS BEGIN
		DECLARE @MaPT char(5), @LoaiKH varchar(10), @SoLuongDia int

		SELECT @MaPT = MaPT
		FROM inserted

		SET @SoLuongDia = (
			SELECT COUNT(DISTINCT ct.MaBD)
			FROM CHITIET_PT ct
			WHERE ct.MaPT = @MaPT
			GROUP BY ct.MaPT
		)

		SELECT @LoaiKH = LoaiKH
		FROM KHACHHANG kh
		JOIN PHIEUTHUE pt ON  kh.MaKH = pt.MaKH
		WHERE pt.MaPT = @MaPT

		IF(@LoaiKH != 'Vip' AND @SoLuongDia > 5)
			BEGIN
				ROLLBACK TRAN
				RAISERROR('Thao tac that bai!', 16, 1)
			ENd
		ELSE
			BEGIN
				PRINT('Thao tac thanh cong!')
			END
	END

-- 3.1
	SELECT kh.MaKH, HoTen
	FROM KHACHHANG kh
	JOIN PHIEUTHUE pt ON kh.MaKH = pt.MaKH
	JOIN CHITIET_PT ct ON ct.MaPT = pt.MaPT
	JOIN BANG_DIA bd ON bd.MaBD = ct.MaBD
	WHERE TheLoai = N'Tình cảm'
	GROUP BY kh.MaKH, HoTen
	HAVING COUNT(DISTINCT ct.MaPT) > 3;

-- 3.2
	SELECT TOP 1 WITH TIES
		kh.MaKH, HoTen
	FROM KHACHHANG kh
	JOIN PHIEUTHUE pt ON kh.MaKH = pt.MaKH
	JOIN CHITIET_PT ct ON ct.MaPT  = pt.MaPT
	WHERE LoaiKH = 'Vip'
	GROUP BY kh.MaKH, HOTEN
	ORDER BY COUNT(DISTINCT ct.MaBD) DESC;

-- 3.3
	SELECT bd.TheLoai, HoTen
	FROM KHACHHANG kh
	JOIN PHIEUTHUE pt ON pt.MaKH  = kh.MaKH
	JOIN CHITIET_PT ct ON ct.MaPT = pt.MaPT
	JOIN BANG_DIA bd ON bd.MaBD = ct.MaBD
	GROUP BY bd.TheLoai, HoTen
	HAVING COUNT(DISTINCT ct.MaBD) >= ALL(
		SELECT COUNT(DISTINCT ct2.MaBD)
		FROM PHIEUTHUE pt2
		JOIN CHITIET_PT ct2 ON pt2.MaPT = ct2.MaPT
		JOIN BANG_DIA bd2 ON bd2.MaBD = ct2.MaBD
		WHERE bd.TheLoai = bd2.TheLoai
		GROUP BY pt2.MaKH
	);
